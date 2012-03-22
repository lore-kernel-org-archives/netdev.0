From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] usbnet: increase URB reference count before usb_unlink_urb
Date: Thu, 22 Mar 2012 21:22:18 +0800
Message-ID: <1332422538-6597-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
recursive locking in usbnet_stop()) fixes the recursive locking
problem by releasing the skb queue lock, but it makes usb_unlink_urb
racing with defer_bh, and the URB to being unlinked may be freed before
or during calling usb_unlink_urb, so use-after-free problem may be
triggerd inside usb_unlink_urb.

The patch fixes the use-after-free problem by increasing URB
reference count with skb queue lock held before calling
usb_unlink_urb, so the URB won't be freed until return from
usb_unlink_urb.

Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Reported-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4b8b52c..febfdce 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -589,6 +589,14 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 		entry = (struct skb_data *) skb->cb;
 		urb = entry->urb;
 
+		/*
+		 * Get reference count of the URB to avoid it to be
+		 * freed during usb_unlink_urb, which may trigger
+		 * use-after-free problem inside usb_unlink_urb since
+		 * usb_unlink_urb is always racing with .complete
+		 * handler(include defer_bh).
+		 */
+		usb_get_urb(urb);
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
@@ -597,6 +605,7 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		usb_put_urb(urb);
 		spin_lock_irqsave(&q->lock, flags);
 	}
 	spin_unlock_irqrestore (&q->lock, flags);
-- 
1.7.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
