From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 5 Mar 2013 18:55:42 +0800
Message-ID: <CACVXFVM=PcxTLb1-Bo-11Lz0FzthQJTRKt5=sn6W85K9p8xE4A@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<87fw0aqqel.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <87fw0aqqel.fsf@nemi.mork.no>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 5, 2013 at 3:03 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>
>> Hi,
>>
>> This patch adds comments on interface driver suspend callback
>> to emphasize that the failure return value is ignored by
>> USB core in system sleep context, so do not try to recover
>> device for this case, otherwise the URB traffic scheduled
>> in recovery of failure path may cross system sleep, and may
>> cause problems.
>
> Well, an unexpected error did happen so problems are to be expected,
> yes.
>
>> Also fixes the USB serial, HID and several usbnet drivers
>> which may recover device in suspend failure path of system sleep.
>
> I believe all of these are wrong unless you have any real bug which i=
s
> fixed by this.

It is really a bug if one driver submits URBs and keeps them scheduled
on bus before system sleep, because the bus transaction can't be kept
across system sleep cycle.

>
> All these drivers suspend in multiple steps, where each step can
> fail. If a later step fails then they revert any previously successfu=
l
> step before returning the failure, thereby ensuring that the
> device/driver state when suspend returns is consistently either
> suspended or resumed.

IMO, for autosuspend, that is right, but it is not for system suspend,
and the driver's suspend callback can't return in resumed state
because the USB core will ignore the failure return value and force
to suspend the device.

>
> The error recovery they do in suspend is not about preventing suspend=
 at
> all.  It is about ensuring that that the driver and device is in a
> consistent state, which is "resumed" if suspend fails.

No, only putting the device as "suspended" in system suspend failure
can keep the state as consistent, see the above explanation.

>
> Your patch set make the drivers return from suspend in some intermedi=
ate
> state, where the device and/or driver is neither suspended nor resume=
d.
> This is wrong.  You still did not necessarily kill all URBs, but you
> killed some of them.  What is resume() going to do then?

These patches try to avoid submitting new URBs in the failure path of
system suspend, and we can comments these fixes in each patch one
by one.

>
> I am going to NAK the cdc_mbim and qmi_wwan pacthes unless you can
> convince me that we need to add a "partly-suspended" state for the
> system suspend error case.  In which case the patch will need to incl=
ude
> the corresponding resume fix for the "partly-suspended" state.
>

Yes, you may argue that the device might be in partly-suspended state,
but it doesn't matter since the device will be put into suspend later a=
nd
the resume callback can recover from the partly-suspend state.

These patches doesn't break previous failure path of system suspend
and just avoid to submit new URBs, so how about letting later delta
patches fix for the corresponding resume?


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
