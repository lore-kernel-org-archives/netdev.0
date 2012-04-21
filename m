From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 09:49:51 +0800
Message-ID: <CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
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
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60274 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2DUBtw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 21:49:52 -0400
In-Reply-To: <CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 20, 2012 at 10:56 PM, Huajun Li <huajun.li.lee@gmail.com> w=
rote:
> On Fri, Apr 20, 2012 at 10:22 PM, Ming Lei <tom.leiming@gmail.com> wr=
ote:
>> On Fri, Apr 20, 2012 at 9:37 PM, Huajun Li <huajun.li.lee@gmail.com>=
 wrote:
>>>
>>> Above patch has already been integrated to mainline. However, maybe
>>> there still exists another potentail use-after-free issue, here is =
a
>>> case:
>>> =A0 =A0 =A0After release the lock in unlink_urbs(), defer_bh() may =
move
>>> current skb from rxq/txq to dev->done queue, even cause the skb be
>>> released. Then in next loop cycle, it can't refer to expected skb, =
and
>>> may Oops again.
>>
>> Could you explain in a bit detail? Why can't the expected skb be ref=
ered
>> to in next loop?
>
>
> =A0 =A0 =A0unlink_urbs() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete handler
> --------------------------------------
> -------------------------------------------------
> =A0 =A0 spin_unlock_irqrestore()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_complete=
()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0derver_bh()
>
> =A0__skb_unlink()
>
> =A0__skb_queue_tail(&dev->done, skb) =A0 =3D=3D=3D=3D=3D=3D=3D> skb i=
s moved to
> dev->done, and can be freed by usbnet_bh()
> =A0 =A0 =A0skb_queue_walk_safe()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tmp =3D skb->next =A0 =3D=3D=
=3D> refer to freed skb

I see the problem, so looks skb_queue_walk_safe is not safe.
I don' know why the 2nd ' tmp =3D skb->next' in  skb_queue_walk_safe
is needed and it may become unsafe if skb is freed during current loop.

But removing the 2nd 'tmp =3D skb->next' doesn't help the problem, beca=
use
tmp still may become freed after releasing lock.

> If its state is x_done/tx_done/rx_cleanup, that means the the skb wil=
l
> be released soon, right? If so, it should avoid calling
> usb_unlink_urb().

Even though you can avoid calling unlink for completed URBs, the skbs
still may be freed in unlink path because complete handler will be trig=
gered
by unlink and the referenced skb may be freed before next loop, so your
patch can't fix the oops.

As far as I can think of, we can hold lock of done queue to forbid skb =
free
during unlinking. The below patch may fix the problem, are you OK
with it?

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index db99536..a9809d4 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -581,7 +581,8 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 	struct sk_buff		*skb, *skbnext;
 	int			count =3D 0;

-	spin_lock_irqsave (&q->lock, flags);
+	spin_lock_irqsave(&dev->done.lock, flags);
+	spin_lock(&q->lock);
 	skb_queue_walk_safe(q, skb, skbnext) {
 		struct skb_data		*entry;
 		struct urb		*urb;
@@ -598,7 +599,7 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 		 * handler(include defer_bh).
 		 */
 		usb_get_urb(urb);
-		spin_unlock_irqrestore(&q->lock, flags);
+		spin_unlock(&q->lock);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
 		retval =3D usb_unlink_urb (urb);
@@ -607,9 +608,10 @@ static int unlink_urbs (struct usbnet *dev,
struct sk_buff_head *q)
 		else
 			count++;
 		usb_put_urb(urb);
-		spin_lock_irqsave(&q->lock, flags);
+		spin_lock(&q->lock);
 	}
-	spin_unlock_irqrestore (&q->lock, flags);
+	spin_unlock(&q->lock);
+	spin_unlock_irqrestore(&dev->done.lock, flags);
 	return count;
 }



Thanks,
--=20
Ming Lei
