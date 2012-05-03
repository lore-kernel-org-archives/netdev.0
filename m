From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] usbnet: fix skb traversing races during unlink(v1)
Date: Thu, 3 May 2012 09:04:50 +0800
Message-ID: <20120503090450.41704527@tom-ThinkPad-T410>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
	<1335775864-4873-4-git-send-email-tom.leiming@gmail.com>
	<20120502.201212.909292764269133334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120502.201212.909292764269133334.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>From a87ff961f0a5d50223bd084dfac4fe5ce84f3913 Mon Sep 17 00:00:00 2001
From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 26 Apr 2012 11:33:46 +0800
Subject: [PATCH] usbnet: fix skb traversing races during unlink(v2)

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

The other part of this patch is based on Huajun's patch:
always traverse from head of the tx/rx queue to get skb which is
to be unlinked but not been started unlinking.

Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
---
v2:
	- if the Rx URB has been marked as being unlink, just not resubmit it
	in complete handler, so usb_block_urb/usb_unblock_urb can be avoided,
	then make backporting for -stable easier.
v1:
	- fix comment style and avoiding to expose the internal
	details of SKB lists, as suggested by David Miller

 drivers/net/usb/usbnet.c   |   54 +++++++++++++++++++++++++++++++-------------
 include/linux/usb/usbnet.h |    3 ++-
 2 files changed, 40 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 80b837c..9f58330 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -282,17 +282,32 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
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
+static enum skb_state defer_bh(struct usbnet *dev, struct sk_buff *skb,
+		struct sk_buff_head *list, enum skb_state state)
 {
 	unsigned long		flags;
+	enum skb_state 		old_state;
+	struct skb_data *entry = (struct skb_data *) skb->cb;
 
 	spin_lock_irqsave(&list->lock, flags);
+	old_state = entry->state;
+	entry->state = state;
 	__skb_unlink(skb, list);
 	spin_unlock(&list->lock);
 	spin_lock(&dev->done.lock);
@@ -300,6 +315,7 @@ static void defer_bh(struct usbnet *dev, struct sk_buff *skb, struct sk_buff_hea
 	if (dev->done.qlen == 1)
 		tasklet_schedule(&dev->bh);
 	spin_unlock_irqrestore(&dev->done.lock, flags);
+	return old_state;
 }
 
 /* some work can't be done in tasklets, so we use keventd
@@ -340,7 +356,6 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->state = rx_start;
 	entry->length = 0;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->in,
@@ -372,7 +387,7 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
-			__skb_queue_tail (&dev->rxq, skb);
+			__usbnet_queue_skb(&dev->rxq, skb, rx_start);
 		}
 	} else {
 		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
@@ -423,16 +438,17 @@ static void rx_complete (struct urb *urb)
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
@@ -471,7 +487,7 @@ static void rx_complete (struct urb *urb)
 				  "rx throttle %d\n", urb_status);
 		}
 block:
-		entry->state = rx_cleanup;
+		state = rx_cleanup;
 		entry->urb = urb;
 		urb = NULL;
 		break;
@@ -482,17 +498,18 @@ block:
 		// FALLTHROUGH
 
 	default:
-		entry->state = rx_cleanup;
+		state = rx_cleanup;
 		dev->net->stats.rx_errors++;
 		netif_dbg(dev, rx_err, dev->net, "rx status %d\n", urb_status);
 		break;
 	}
 
-	defer_bh(dev, skb, &dev->rxq);
+	state = defer_bh(dev, skb, &dev->rxq, state);
 
 	if (urb) {
 		if (netif_running (dev->net) &&
-		    !test_bit (EVENT_RX_HALT, &dev->flags)) {
+		    !test_bit (EVENT_RX_HALT, &dev->flags) &&
+		    state != unlink_start) {
 			rx_submit (dev, urb, GFP_ATOMIC);
 			usb_mark_last_busy(dev->udev);
 			return;
@@ -579,16 +596,23 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
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
@@ -1040,8 +1064,7 @@ static void tx_complete (struct urb *urb)
 	}
 
 	usb_autopm_put_interface_async(dev->intf);
-	entry->state = tx_done;
-	defer_bh(dev, skb, &dev->txq);
+	(void) defer_bh(dev, skb, &dev->txq, tx_done);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -1097,7 +1120,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->state = tx_start;
 	entry->length = length;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
@@ -1156,7 +1178,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
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


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
