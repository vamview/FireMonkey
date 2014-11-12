unit FMX.Dialogs.Wait;

{
The MIT License (MIT)

Copyright (c) 2014, Takehiko Iwanaga.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
}

interface
uses
    System.Classes, System.SysUtils, System.UITypes, FMX.Dialogs, FMX.Forms;

function MessageDlgWait(const AMessage: string; const ADialogType: TMsgDlgType; const AButtons: TMsgDlgButtons; const AHelpContext: LongInt): Integer;


implementation
type
    TDialogThread = class(TThread)
    private
        F_Message: String;
        F_DialogType: TMsgDlgType;
        F_Buttons: TMsgDlgButtons;
        F_HelpContext: LongInt;
        F_Result: Integer;
        F_IsFinished: Boolean;
    protected
        procedure Execute; override;
    public
        constructor Create;
        procedure Start(const AMessage: string; const ADialogType: TMsgDlgType; const AButtons: TMsgDlgButtons; const AHelpContext: LongInt);
        property Result:Integer read F_Result write F_Result;
    end;


constructor TDialogThread.Create;
begin
    inherited Create(True);
    FreeOnTerminate := False;
end;

procedure TDialogThread.Start(const AMessage: string; const ADialogType: TMsgDlgType; const AButtons: TMsgDlgButtons; const AHelpContext: LongInt);
begin
    F_Message := AMessage;
    F_DialogType := ADialogType;
    F_Buttons := AButtons;
    F_HelpContext := AHelpContext;
    inherited Start();
end;

procedure TDialogThread.Execute;
var
    IsFinished: Boolean;
begin
    IsFinished := False;
    Synchronize(procedure begin
        MessageDlg(F_Message, F_DialogType, F_Buttons, F_HelpContext,
            procedure(const AResult: TModalResult) begin
                F_Result := AResult;
                IsFinished := True;
            end
        )
    end);

    repeat
        Sleep(100);
        Application.ProcessMessages;
    until (IsFinished);
end;

function MessageDlgWait(const AMessage: string; const ADialogType: TMsgDlgType; const AButtons: TMsgDlgButtons; const AHelpContext: LongInt): Integer;
{$IFDEF ANDROID}
var
    DialogThread: TDialogThread;
begin
    DialogThread := TDialogThread.Create();
    DialogThread.Start(AMessage, ADialogType, AButtons, AHelpContext);
    DialogThread.WaitFor();
    Result := DialogThread.Result;

    FreeAndNil(DialogThread);
end;
{$ELSE}
begin
    Result := MessageDlg(AMessage, ADialogType, AButtons, AHelpContext);
end;
{$ENDIF}

end.
