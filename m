From: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: [PATCH] net/usbnet: avoid recursive locking in usbnet_stop()
Date: Mon, 20 Feb 2012 17:01:48 +0100
Message-ID: <20120220160148.GA7910@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

|kernel BUG at kernel/rtmutex.c:724!
|[<c029599c>] (rt_spin_lock_slowlock+0x108/0x2bc) from [<c01c2330>] (de=
fer_bh+0x1c/0xb4)
|[<c01c2330>] (defer_bh+0x1c/0xb4) from [<c01c3afc>] (rx_complete+0x14c=
/0x194)
|[<c01c3afc>] (rx_complete+0x14c/0x194) from [<c01cac88>] (usb_hcd_give=
back_urb+0xa0/0xf0)
|[<c01cac88>] (usb_hcd_giveback_urb+0xa0/0xf0) from [<c01e1ff4>] (musb_=
giveback+0x34/0x40)
|[<c01e1ff4>] (musb_giveback+0x34/0x40) from [<c01e2b1c>] (musb_advance=
_schedule+0xb4/0x1c0)
|[<c01e2b1c>] (musb_advance_schedule+0xb4/0x1c0) from [<c01e2ca8>] (mus=
b_cleanup_urb.isra.9+0x80/0x8c)
|[<c01e2ca8>] (musb_cleanup_urb.isra.9+0x80/0x8c) from [<c01e2ed0>] (mu=
sb_urb_dequeue+0xec/0x108)
|[<c01e2ed0>] (musb_urb_dequeue+0xec/0x108) from [<c01cbb90>] (unlink1+=
0xbc/0xcc)
|[<c01cbb90>] (unlink1+0xbc/0xcc) from [<c01cc2ec>] (usb_hcd_unlink_urb=
+0x54/0xa8)
|[<c01cc2ec>] (usb_hcd_unlink_urb+0x54/0xa8) from [<c01c2a84>] (unlink_=
urbs.isra.17+0x2c/0x58)
|[<c01c2a84>] (unlink_urbs.isra.17+0x2c/0x58) from [<c01c2b44>] (usbnet=
_terminate_urbs+0x94/0x10c)
|[<c01c2b44>] (usbnet_terminate_urbs+0x94/0x10c) from [<c01c2d68>] (usb=
net_stop+0x100/0x15c)
|[<c01c2d68>] (usbnet_stop+0x100/0x15c) from [<c020f718>] (__dev_close_=
many+0x94/0xc8)

defer_bh() takes the lok which is hold during unlink_urbs(). The safe
walk suggest that the skb will be removed from the list and this is don=
e
by defer_bh() so it seems to be okay to drop the lock here.

Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Reported-by: An=C3=ADbal Almeida Pinto <anibal.pinto-K2AfXPJZHq/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index fae0fbd..81b96e3 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -589,6 +589,7 @@ static int unlink_urbs (struct usbnet *dev, struct =
sk_buff_head *q)
 		entry =3D (struct skb_data *) skb->cb;
 		urb =3D entry->urb;
=20
+		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
 		retval =3D usb_unlink_urb (urb);
@@ -596,6 +597,7 @@ static int unlink_urbs (struct usbnet *dev, struct =
sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		spin_lock_irqsave(&q->lock, flags);
 	}
 	spin_unlock_irqrestore (&q->lock, flags);
 	return count;
--=20
1.7.9
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
