From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH] usbnet: fix skb traversing races during unlink
Date: Fri, 27 Apr 2012 18:21:35 +0800
Message-ID: <1335522095-9012-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <tom.leiming@gmail.com>,
	Huajun Li <huajun.li.lee@gmail.com>,
	Oliver Neukum <oneukum@suse.de>, stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:33912 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444Ab2D0KVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 06:21:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
Signed-off-by: Ming Lei <tom.leiming@gmail.com>
Cc: Oliver Neukum <oneukum@suse.de>
Cc: stable@kernel.org

---

This patch depends on the usb_block_urb patch from Oliver.

 drivers/net/usb/usbnet.c   |   54 ++++++++++++++++++++++++++++++++------------
 include/linux/usb/usbnet.h |    3 ++-
 2 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index db99536..dff5e1b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -281,17 +281,30 @@ int usbnet_change_mtu (struct net_device *net, int new_mtu)
 }
 EXPORT_SYMBOL_GPL(usbnet_change_mtu);
 
+/*The caller must hold list->lock*/
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
@@ -339,7 +352,6 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->state = rx_start;
 	entry->length = 0;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->in,
@@ -371,7 +383,7 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
-			__skb_queue_tail (&dev->rxq, skb);
+			__usbnet_queue_skb(&dev->rxq, skb, rx_start);
 		}
 	} else {
 		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
@@ -422,16 +434,17 @@ static void rx_complete (struct urb *urb)
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
@@ -470,7 +483,7 @@ static void rx_complete (struct urb *urb)
 				  "rx throttle %d\n", urb_status);
 		}
 block:
-		entry->state = rx_cleanup;
+		state = rx_cleanup;
 		entry->urb = urb;
 		urb = NULL;
 		break;
@@ -481,13 +494,13 @@ block:
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
@@ -578,16 +591,24 @@ EXPORT_SYMBOL_GPL(usbnet_purge_paused_rxq);
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
+				break;
+		}
+		if (skb == (struct sk_buff *)q)
+			break;
+
+		entry->state = unlink_start;
 		urb = entry->urb;
 
 		/*
@@ -598,6 +619,10 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 		 * handler(include defer_bh).
 		 */
 		usb_get_urb(urb);
+
+		/*speedup unlink by blocking resubmit*/
+		usb_block_urb(urb);
+
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
@@ -606,6 +631,7 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		usb_unblock_urb(urb);
 		usb_put_urb(urb);
 		spin_lock_irqsave(&q->lock, flags);
 	}
@@ -1039,8 +1065,7 @@ static void tx_complete (struct urb *urb)
 	}
 
 	usb_autopm_put_interface_async(dev->intf);
-	entry->state = tx_done;
-	defer_bh(dev, skb, &dev->txq);
+	defer_bh(dev, skb, &dev->txq, tx_done);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -1096,7 +1121,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->state = tx_start;
 	entry->length = length;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
@@ -1155,7 +1179,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
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
