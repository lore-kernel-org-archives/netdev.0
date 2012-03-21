From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 09:34:41 +0800
Message-ID: <CACVXFVPK9vj8oqjr1SFr2MgoQn-2XoDqyb95oW+7LCHT7020Ow@mail.gmail.com>
References: <20120319151224.GA16031@redhat.com>
	<CACVXFVN5O2S0hsnzHoi=LX+KAnccHc_F0SXq9-hMOXnaoUOdkg@mail.gmail.com>
	<CACVXFVP9-Ao_UyBoxkxzq5dg8TfkZ9CECqEUFW5bD_JRzfQybw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	Dave Jones <davej@redhat.com>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59793 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756277Ab2CUBem convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 21:34:42 -0400
In-Reply-To: <CACVXFVP9-Ao_UyBoxkxzq5dg8TfkZ9CECqEUFW5bD_JRzfQybw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 9:04 AM, Ming Lei <tom.leiming@gmail.com> wrote=
:
> On Tue, Mar 20, 2012 at 5:40 PM, Ming Lei <tom.leiming@gmail.com> wro=
te:
>> Hi,
>>
>> On Mon, Mar 19, 2012 at 11:12 PM, Dave Jones <davej@redhat.com> wrot=
e:
>>> We've had two reports of this use after free in Fedora now recently=
=2E.
>>
>> Could you provide output of 'dmesg' and 'lsusb -v' from the reported=
 machine?
>
> Looks I have figured out why your problem is triggered.
>
> If the URB being unlinked is freed before usb_put_dev
> inside usb_hcd_unlink_urb, the use-after-free will be triggered.
> And the below patch[1] should fix the problem.
>
> Also there is another bug in tx_complete() of usbnet, the line below
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb->dev =3D NULL;
>
> should be removed to avoid possible oops or memory leak in unlink pat=
h.
>
> Please test the patch if you can reproduce the problem.
>
> [1],
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 59681f0..4f4e028 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -592,7 +592,9 @@ static int unlink_urbs (struct usbnet *dev, struc=
t
> sk_buff_head *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&q->lock, flags=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// during some PM-driven resume scenar=
ios,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// these (async) unlinks complete imme=
diately
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_disable();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D usb_unlink_urb (urb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_enable();

Looks it is a general issue about usb_hcd_unlink_urb.

Alan, how about increasing URB reference count before calling unlink1
inside usb_hcd_unlink_urb to fix this kind of problem?

Thanks,
--=20
Ming Lei
