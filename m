From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 23:07:57 +0800
Message-ID: <CACVXFVPfnFLaRFbAgTzQCrPJeaMZ_kEu4q1g-wHesEb2pbdz9w@mail.gmail.com>
References: <20120319151224.GA16031@redhat.com>
	<CACVXFVN5O2S0hsnzHoi=LX+KAnccHc_F0SXq9-hMOXnaoUOdkg@mail.gmail.com>
	<CACVXFVP9-Ao_UyBoxkxzq5dg8TfkZ9CECqEUFW5bD_JRzfQybw@mail.gmail.com>
	<20120321144441.GB14043@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53893 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab2CUPH5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 11:07:57 -0400
In-Reply-To: <20120321144441.GB14043@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 10:44 PM, Greg KH <greg@kroah.com> wrote:
> On Wed, Mar 21, 2012 at 09:04:15AM +0800, Ming Lei wrote:
>> On Tue, Mar 20, 2012 at 5:40 PM, Ming Lei <tom.leiming@gmail.com> wr=
ote:
>> > Hi,
>> >
>> > On Mon, Mar 19, 2012 at 11:12 PM, Dave Jones <davej@redhat.com> wr=
ote:
>> >> We've had two reports of this use after free in Fedora now recent=
ly..
>> >
>> > Could you provide output of 'dmesg' and 'lsusb -v' from the report=
ed machine?
>>
>> Looks I have figured out why your problem is triggered.
>>
>> If the URB being unlinked is freed before usb_put_dev
>> inside usb_hcd_unlink_urb, the use-after-free will be triggered.
>> And the below patch[1] should fix the problem.
>
> With the reference counting we have, how can the urb be freed at this
> point in time? =A0Is the driver doing wierd things with the urb refer=
ence
> counts?

The problem is that the .complete may schedule a tasklet to
free the completed URB. And the .complete may be run inside
unlink path, so the use-after-free will be triggered if the
tasklet is excuted before usb_put_dev inside usb_hcd_unlink_urb.

>
>> Also there is another bug in tx_complete() of usbnet, the line below
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 urb->dev =3D NULL;
>>
>> should be removed to avoid possible oops or memory leak in unlink pa=
th.
>>
>> Please test the patch if you can reproduce the problem.
>>
>> [1],
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 59681f0..4f4e028 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -592,7 +592,9 @@ static int unlink_urbs (struct usbnet *dev, stru=
ct
>> sk_buff_head *q)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&q->lock, flags);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 // during some PM-driven resume scenario=
s,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 // these (async) unlinks complete immedi=
ately
>> + =A0 =A0 =A0 =A0 =A0 =A0 local_bh_disable();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D usb_unlink_urb (urb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 local_bh_enable();
>
> That doesn't seem right, as you point out in your follow-up message.
> This shouldn't be needed, unless you are doing some really wierd thin=
gs
> with the urb :(

Looks the driver doesn't do any wierd things, as said above.


Thanks,
--=20
Ming Lei
