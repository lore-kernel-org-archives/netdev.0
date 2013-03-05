From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 14:18:35 +0100
Message-ID: <87hakqouhg.fsf@nemi.mork.no>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<87fw0aqqel.fsf@nemi.mork.no>
	<CACVXFVM=PcxTLb1-Bo-11Lz0FzthQJTRKt5=sn6W85K9p8xE4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60173 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755163Ab3CENTg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 08:19:36 -0500
In-Reply-To: <CACVXFVM=PcxTLb1-Bo-11Lz0FzthQJTRKt5=sn6W85K9p8xE4A@mail.gmail.com>
	(Ming Lei's message of "Tue, 5 Mar 2013 18:55:42 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

> On Tue, Mar 5, 2013 at 3:03 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
>> Ming Lei <ming.lei@canonical.com> writes:
>>
>>> Hi,
>>>
>>> This patch adds comments on interface driver suspend callback
>>> to emphasize that the failure return value is ignored by
>>> USB core in system sleep context, so do not try to recover
>>> device for this case, otherwise the URB traffic scheduled
>>> in recovery of failure path may cross system sleep, and may
>>> cause problems.
>>
>> Well, an unexpected error did happen so problems are to be expected,
>> yes.
>>
>>> Also fixes the USB serial, HID and several usbnet drivers
>>> which may recover device in suspend failure path of system sleep.
>>
>> I believe all of these are wrong unless you have any real bug which =
is
>> fixed by this.
>
> It is really a bug if one driver submits URBs and keeps them schedule=
d
> on bus before system sleep, because the bus transaction can't be kept
> across system sleep cycle.

1. You do not fix that.  You just ignore that the driver failed to
   cancel *one* of its URBs and return to the caller in an unknown
   state.  That's not even papering over the bug, it is just adding a
   new one without solving anything

2. I asked for a *real* bug, as opposed to theoretical bug.  Working
  around real issues by papering over them may sometimes be acceptable
  if the real issue is bad enough.  Working around theoretical bugs thi=
s
  way never is.

Yes, I can also see the theoretical issue.  Feel free to fix that if yo=
u
know how. I don't.

>> All these drivers suspend in multiple steps, where each step can
>> fail. If a later step fails then they revert any previously successf=
ul
>> step before returning the failure, thereby ensuring that the
>> device/driver state when suspend returns is consistently either
>> suspended or resumed.
>
> IMO, for autosuspend, that is right, but it is not for system suspend=
,
> and the driver's suspend callback can't return in resumed state

OK.  You do realize that the code you are changing tries to deal with
the case where suspend already failed, so returning in suspended state
is impossible?  If you cannot return in resumed state, then you have tw=
o
options:
 a) define a new state
 b) don't return

You seem to want to do a).  But that is far more work than just ignorin=
g
partial errors.  You need to add the state, make the caller deal with
it, make resume deal with it etc.

Personally I believe that alternative

c) revert to resumed state and return error

like these drivers do is a better option.

> because the USB core will ignore the failure return value and force
> to suspend the device.

Yes, I know that. So fix that then if it is an issue. My claim is that
it is not, and that is why the USB core can ignore the failure.  If it
were an issue then the core could not ignore it.  Simple as that.

You cannot keep pushing this down to "Do not allow operation to ever
fail" for every small task involved in a suspend.  It involves
hardware.  It can and will fail.

>> I am going to NAK the cdc_mbim and qmi_wwan pacthes unless you can
>> convince me that we need to add a "partly-suspended" state for the
>> system suspend error case.  In which case the patch will need to inc=
lude
>> the corresponding resume fix for the "partly-suspended" state.
>>
>
> Yes, you may argue that the device might be in partly-suspended state=
,
> but it doesn't matter since the device will be put into suspend later=
 and

Where will it do that?  AFAICS, usb_suspend_both() will resume all
already suspended interfaces if a driver fails suspend.  From the
function docs:

 * This is the central routine for suspending USB devices.  It calls th=
e
 * suspend methods for all the interface drivers in @udev and then call=
s
 * the suspend method for @udev itself.  If an error occurs at any stag=
e,
 * all the interfaces which were suspended are resumed so that they rem=
ain
 * in the same state as the device.


You do want the *failing* interface driver/function to have the same
state as the rest of the device functions, i.e. resumed, on return from
suspend.

> the resume callback can recover from the partly-suspend state.

It can.  But it won't magically just do that by ignoring errors in
suspend.

> These patches doesn't break previous failure path of system suspend
> and just avoid to submit new URBs, so how about letting later delta
> patches fix for the corresponding resume?

=46rom Documentation/usb/power-management.txt :

        The suspend method is called to warn the driver that the
        device is going to be suspended.  If the driver returns a
        negative error code, the suspend will be aborted.  Normally
        the driver will return 0, in which case it must cancel all
        outstanding URBs (usb_kill_urb()) and not submit any more.


The driver need only cancel outstanding URBs if it returns 0.  How the
USB core handles this is up to the USB core.  It is not for the
drivers to deal with.  Unless you modify the API to say that suspend
cannot fail in the !PMSG_IS_AUTO(message) case.

But I really think all that ugly PMSG_IS_AUTO(message) testing in the
USB drivers is contradicting the simple design of the USB core, using a
single common suspend for both runtime and system suspend and leaving i=
t
up to the USB core to handle the differences.

AFAICS, it does that just fine.  If you think it does not, then please
fix that in the USB core or redefine the API.  But don't just randomly
make drivers ignore errors.


Bj=C3=B8rn
