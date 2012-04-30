From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] usbnet: fix skb traversing races during unlink(v1)
Date: Mon, 30 Apr 2012 16:51:04 +0800
Message-ID: <1335775864-4873-4-git-send-email-tom.leiming@gmail.com>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335775864-4873-1-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 4231d47e6fe69f061f96c98c30eaf9fb4c14b96d(net/usbnet: avoid
recursive locking in usbnet_stop()) fixes the recursive locking
problem by releasing the skb queue lock before unlink, but may
cause skb traversing races:
	- after URB is unlinked and the queue lock is released,
	the refered skb and skb->next may be moved to done queue,
	even be released
	- in skb_queue_walk_safe, the next skb is still obtained
	by next pointer of the last skb
	- so maybe trigger oops or other problems

This patch extends the usage of entry->state to describe 'start_unlink'
state, so always holding the queue(rx/tx) lock to change the state if
the referd skb is in rx or tx queue because we need to know if the
refered urb has been started unlinking in unlink_urbs.

Also the patch uses usb_block_urb introduced by Oliver to block
URB resubmit in complete handler if the URB will be unlinked.

The other part of this patch is based on Huajun's patch:
always traverse from head of the tx/rx queue to get skb which is
to be unlinked but not been started unlinking.

Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
---
v1:
	- fix comment style and avoiding to expose the internal
	details of SKB lists, as suggested by David Miller

This patch depends on the usb_block_urb/usb_unblock_urb patch from
Oliver.

 drivers/net/usb/usbnet.c   |   53 +++++++++++++++++++++++++++++++-------------
 include/linux/usb/usbnet.h |    3 ++-
 2 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 80b837c..2013001 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -282,17 +282,30 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 }
 EXPORT_SYMBOL_GPL(usbnet_change_mtu);
 
+/* The caller must hold list->lock */
+static void __usbnet_queue_skb(struct sk_buff_head *list,
+			struct sk_buff *newsk, enum skb_state state)
+{
+	struct skb_data *entry = (struct skb_data *) newsk->cb;
+
+	__skb_queue_tail(list, newsk);
+	entry->state = state;
+}
+
 /*-------------------------------------------------------------------------*/
 
 /* some LK 2.4 HCDs oopsed if we freed or resubmitted urbs from
  * completion callbacks.  2.5 should have fixed those bugs...
  */
 
-static void defer_bh(struct usbnet *dev, struct sk_buff *skb, struct sk_buff_head *list)
+static void defer_bh(struct usbnet *dev, struct sk_buff *skb,
+		struct sk_buff_head *list, enum skb_state state)
 {
 	unsigned long		flags;
+	struct skb_data *entry = (struct skb_data *) skb->cb;
 
 	spin_lock_irqsave(&list->lock, flags);
+	entry->state = state;
 	__skb_unlink(skb, list);
 	spin_unlock(&list->lock);
 	spin_lock(&dev->done.lock);
@@ -340,7 +353,6 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->state = rx_start;
 	entry->length = 0;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->in,
@@ -372,7 +384,7 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
-			__skb_queue_tail (&dev->rxq, skb);
+			__usbnet_queue_skb(&dev->rxq, skb, rx_start);
 		}
 	} else {
 		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
@@ -423,16 +435,17 @@ static void rx_complete (struct urb *urb)
 	struct skb_data		*entry = (struct skb_data *) skb->cb;
 	struct usbnet		*dev = entry->dev;
 	int			urb_status = urb->status;
+	enum skb_state		state;
 
 	skb_put (skb, urb->actual_length);
-	entry->state = rx_done;
+	state = rx_done;
 	entry->urb = NULL;
 
 	switch (urb_status) {
 	/* success */
 	case 0:
 		if (skb->len < dev->net->hard_header_len) {
-			entry->state = rx_cleanup;
+			state = rx_cleanup;
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_length_errors++;
 			netif_dbg(dev, rx_err, dev->net,
@@ -471,7 +484,7 @@ static void rx_complete (struct urb *urb)
 				  "rx throttle %d\n", urb_status);
 		}
 block:
-		entry->state = rx_cleanup;
+		state = rx_cleanup;
 		entry->urb = urb;
 		urb = NULL;
 		break;
@@ -482,13 +495,13 @@ block:
 		// FALLTHROUGH
 
 	default:
-		entry->state = rx_cleanup;
+		state = rx_cleanup;
 		dev->net->stats.rx_errors++;
 		netif_dbg(dev, rx_err, dev->net, "rx status %d\n", urb_status);
 		break;
 	}
 
-	defer_bh(dev, skb, &dev->rxq);
+	defer_bh(dev, skb, &dev->rxq, state);
 
 	if (urb) {
 		if (netif_running (dev->net) &&
@@ -579,16 +592,23 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
 static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 {
 	unsigned long		flags;
-	struct sk_buff		*skb, *skbnext;
+	struct sk_buff		*skb;
 	int			count = 0;
 
 	spin_lock_irqsave (&q->lock, flags);
-	skb_queue_walk_safe(q, skb, skbnext) {
+	while (!skb_queue_empty(q)) {
 		struct skb_data		*entry;
 		struct urb		*urb;
 		int			retval;
 
-		entry = (struct skb_data *) skb->cb;
+		skb_queue_walk(q, skb) {
+			entry = (struct skb_data *) skb->cb;
+			if (entry->state != unlink_start)
+				goto found;
+		}
+		break;
+found:
+		entry->state = unlink_start;
 		urb = entry->urb;
 
 		/*
@@ -599,6 +619,10 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 		 * handler(include defer_bh).
 		 */
 		usb_get_urb(urb);
+
+		/* speedup unlink by blocking resubmit */
+		usb_block_urb(urb);
+
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
@@ -607,6 +631,7 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		usb_unblock_urb(urb);
 		usb_put_urb(urb);
 		spin_lock_irqsave(&q->lock, flags);
 	}
@@ -1040,8 +1065,7 @@ static void tx_complete (struct urb *urb)
 	}
 
 	usb_autopm_put_interface_async(dev->intf);
-	entry->state = tx_done;
-	defer_bh(dev, skb, &dev->txq);
+	defer_bh(dev, skb, &dev->txq, tx_done);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -1097,7 +1121,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->state = tx_start;
 	entry->length = length;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
@@ -1156,7 +1179,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		break;
 	case 0:
 		net->trans_start = jiffies;
-		__skb_queue_tail (&dev->txq, skb);
+		__usbnet_queue_skb(&dev->txq, skb, tx_start);
 		if (dev->txq.qlen >= TX_QLEN (dev))
 			netif_stop_queue (net);
 	}
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 605b0aa..76f4396 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -191,7 +191,8 @@ extern void usbnet_cdc_status(struct usbnet *, struct urb *);
 enum skb_state {
 	illegal = 0,
 	tx_start, tx_done,
-	rx_start, rx_done, rx_cleanup
+	rx_start, rx_done, rx_cleanup,
+	unlink_start
 };
 
 struct skb_data {	/* skb->cb is one of these */
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
