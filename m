From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: use-after-free in usbnet
Date: Fri, 20 Apr 2012 21:37:40 +0800
Message-ID: <CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	Huajun Li <huajun.li.lee@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>, Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53440 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850Ab2DTNhm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 09:37:42 -0400
In-Reply-To: <CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 5:30 PM, Ming Lei <tom.leiming@gmail.com> wrote=
:
> On Thu, Mar 22, 2012 at 5:08 PM, Oliver Neukum <oneukum@suse.de> wrot=
e:
>>
>> this looks good, but could you add a comment explaining the reason f=
or
>> taking a reference?
>
> OK, I will post a formal one if you have no objection on the below.
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 4b8b52c..febfdce 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -589,6 +589,14 @@ static int unlink_urbs (struct usbnet *dev,
> struct sk_buff_head *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry =3D (struct skb_data *) skb->cb;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0urb =3D entry->urb;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Get a reference count of the URB t=
o avoid it to be
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* freed during usb_unlink_urb, which=
 may trigger
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* use-after-free problem inside usb_=
unlink_urb since
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* usb_unlink_urb is always racing wi=
th .complete
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* handler(include defer_bh).
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_get_urb(urb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&q->lock, flags=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// during some PM-driven resume scenar=
ios,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0// these (async) unlinks complete imme=
diately
> @@ -597,6 +605,7 @@ static int unlink_urbs (struct usbnet *dev, struc=
t
> sk_buff_head *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_dbg(dev->net, "=
unlink urb err, %d\n", retval);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_put_urb(urb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_irqsave(&q->lock, flags);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0spin_unlock_irqrestore (&q->lock, flags);
>
>


Above patch has already been integrated to mainline. However, maybe
there still exists another potentail use-after-free issue, here is a
case:
      After release the lock in unlink_urbs(), defer_bh() may move
current skb from rxq/txq to dev->done queue, even cause the skb be
released. Then in next loop cycle, it can't refer to expected skb, and
may Oops again.

To easily reproduce it, in unlink_urbs(), you can delay a short time
after usb_put_urb(urb), then disconnect your device while transferring
data, and repeat it times you will find errors on your screen.

=46ollowing is a draft patch to guarantee the queue consistent, and
refer to expected skb in each loop cycle:

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index b7b3f5b..6da0141 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -578,16 +578,28 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
 static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 {
 	unsigned long		flags;
-	struct sk_buff		*skb, *skbnext;
+	struct sk_buff		*skb;
 	int			count =3D 0;

 	spin_lock_irqsave (&q->lock, flags);
-	skb_queue_walk_safe(q, skb, skbnext) {
+	while (!skb_queue_empty(q)) {
 		struct skb_data		*entry;
 		struct urb		*urb;
 		int			retval;

-		entry =3D (struct skb_data *) skb->cb;
+		skb_queue_walk(q, skb) {
+			entry =3D (struct skb_data *)skb->cb;
+			if (entry->state =3D=3D rx_done ||
+				entry->state =3D=3D tx_done ||
+				entry->state =3D=3D rx_cleanup)
+				continue;
+			else
+				break;
+		}
+
+		if (skb =3D=3D (struct sk_buff *)(q))
+			break;
+
 		urb =3D entry->urb;


Thanks,
--Huajun Li
