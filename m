From: Paul Stewart <pstew@chromium.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 07:58:06 -0700
Message-ID: <BANLkTik7Da6K4Fn7=dpo8RwwctCp8kV_iw@mail.gmail.com>
References: <20110420214452.C599321126@glenhelen.mtv.corp.google.com>
	<Pine.LNX.4.44L0.1104210958560.1939-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	davem@davemloft.net, greg@kroah.com
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:28056 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab1DUO6L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 10:58:11 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3LEwA57029146
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 07:58:10 -0700
Received: from ywf9 (ywf9.prod.google.com [10.192.6.9])
	by hpaq1.eem.corp.google.com with ESMTP id p3LEw7GG002220
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 07:58:08 -0700
Received: by ywf9 with SMTP id 9so754686ywf.22
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 07:58:07 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.44L0.1104210958560.1939-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2011 at 7:03 AM, Alan Stern <stern@rowland.harvard.edu>=
 wrote:
> On Tue, 19 Apr 2011, Paul Stewart wrote:
>
>> Set a flag if the interrupt URB completes with ENOENT as this
>> occurs legitimately during system suspend. =A0When the
>> usbnet_resume is called, test this flag and try once to resubmit
>> the interrupt URB.
>
> I still don't think this is the best way to go.
>
>> This version of the patch moves the urb submit directly into
>> usbnet_resume. =A0Is it okay to submit a GFP_KERNEL urb from
>> usbnet_resume()?
>
> Yes, it is.
>
>> Signed-off-by: Paul Stewart <pstew@chromium.org>
>> ---
>> =A0drivers/net/usb/usbnet.c =A0 | =A0 13 ++++++++++++-
>> =A0include/linux/usb/usbnet.h | =A0 =A01 +
>> =A02 files changed, 13 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 02d25c7..3651a48 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -482,6 +482,7 @@ static void intr_complete (struct urb *urb)
>> =A0 =A0 =A0 case -ESHUTDOWN: =A0 =A0 =A0 =A0/* hardware gone */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_ifdown (dev))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 devdbg (dev, "intr shutd=
own, code %d", status);
>> + =A0 =A0 =A0 =A0 =A0 =A0 set_bit(EVENT_INTR_HALT, &dev->flags);
>
> Is this new flag really needed?
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 /* NOTE: =A0not throttling like RX/TX, since this endpoi=
nt
>> @@ -1294,9 +1295,19 @@ int usbnet_resume (struct usb_interface *intf=
)
>> =A0{
>> =A0 =A0 =A0 struct usbnet =A0 =A0 =A0 =A0 =A0 *dev =3D usb_get_intfd=
ata(intf);
>>
>> - =A0 =A0 if (!--dev->suspend_count)
>> + =A0 =A0 if (!--dev->suspend_count) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule (&dev->bh);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* resubmit interrupt URB if it was halted=
 by suspend */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (dev->interrupt && netif_running(dev->n=
et) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_device_present(dev->net) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 test_bit(EVENT_INTR_HALT, &dev->fl=
ags)) {
>
> Why do you need the test_bit()? =A0If the other conditions are all tr=
ue,
> don't you want to resubmit the interrupt URB regardless?

I'm trying to handle two separate issues, one of which I can't say I
fully understand.  The first, which is the most straightforward, is
for systems in which USB devices remained powered across
suspend-resume.  For this case for sure, we don't need a flag.  The
interrupt URBs are halted (either done so by the HCD as I've observed,
or the drive can choose to kill them in usbnet_suspend()).  On system
resume, we're guaranteed URBs have stopped, and we can just submit
one.

In a second scenario, for other systems USB devices go unpowered
during suspend.  At resume time, there's a quick succession where the
device appears to detach and reattach and enumerate.  This is where
things get strange.  It appears that since the enumeration happens in
the course of system resume, when usbnet_open() gets called, and
usb_autopm_get_interface(), there's a call path that leads to
usbnet_resume(). If there's no flag, then we submit the interrupt urb
from usbnet_resume(), so the submit_urb() in usbnet_open() fails in an
error.  This makes actions like "ifconfig eth0 up" fail on the
interface after resume from suspend.

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(EVENT_INTR_HALT,=
 &dev->flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_submit_urb(dev->interr=
upt, GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> +}
>> +
>> =A0 =A0 =A0 return 0;
>> =A0}
>
> Alan Stern
>
>
