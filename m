From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Fri, 20 Apr 2012 22:22:59 +0800
Message-ID: <CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:56318 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab2DTOXA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 10:23:00 -0400
In-Reply-To: <CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee@gmail.com> wr=
ote:
>
> Above patch has already been integrated to mainline. However, maybe
> there still exists another potentail use-after-free issue, here is a
> case:
> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may mo=
ve
> current skb from rxq/txq to dev->done queue, even cause the skb be
> released. Then in next loop cycle, it can't refer to expected skb, an=
d
> may Oops again.

Could you explain in a bit detail? Why can't the expected skb be refere=
d
to in next loop?

>
> To easily reproduce it, in unlink_urbs(), you can delay a short time
> after usb_put_urb(urb), then disconnect your device while transferrin=
g
> data, and repeat it times you will find errors on your screen.

Could you post out the error log?

>
> Following is a draft patch to guarantee the queue consistent, and
> refer to expected skb in each loop cycle:
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index b7b3f5b..6da0141 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -578,16 +578,28 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
> =A0static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q=
)
> =A0{
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
> - =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb, *skbnext;
> + =A0 =A0 =A0 struct sk_buff =A0 =A0 =A0 =A0 =A0*skb;
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D =
0;
>
> =A0 =A0 =A0 =A0spin_lock_irqsave (&q->lock, flags);
> - =A0 =A0 =A0 skb_queue_walk_safe(q, skb, skbnext) {
> + =A0 =A0 =A0 while (!skb_queue_empty(q)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct skb_data =A0 =A0 =A0 =A0 *entry=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0 =A0 =A0 =A0 =A0=
*urb;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 retval;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_data *) skb->cb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_walk(q, skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D (struct skb_d=
ata *)skb->cb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->state =3D=3D=
 rx_done ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->=
state =3D=3D tx_done ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->=
state =3D=3D rx_cleanup)

Maybe it is not necessary, if the state has been changed to  rx_done
or tx_done or rx_cleanup, it means the URB referenced to by the skb
has been completed, and the coming usb_unlink_urb can handle the
case correctly.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D (struct sk_buff *)(q))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb =3D entry->urb;
>
>
> Thanks,
> --Huajun Li


Thanks,
--=20
Ming Lei
