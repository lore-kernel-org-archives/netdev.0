From: David Hollis <dhollis@davehollis.com>
Subject: [RFC usbnet.c] - Add packet aggregation capability
Date: Wed, 10 Jun 2009 13:57:39 -0400
Message-ID: <1244656659.2845.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-azFxmGl2ad9Gzq0uxukm"
Cc: netdev <netdev@vger.kernel.org>, mark@asix.com.tw,
	donald@asix.com.tw, Louis <louis@asix.com.tw>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pool-173-65-162-118.tampfl.fios.verizon.net ([173.65.162.118]:38114
	"EHLO smtp.davehollis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbZFJSF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 14:05:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-azFxmGl2ad9Gzq0uxukm
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The ASIX AX88772 and AX88178 devices have the ability to transmit up 16K
worth of packets in a single bulk transfer.  The asix.c driver currently
doesn't support aggregating multiple packets into this buffer so that
packets can be transmitted in a single transfer.  On some systems -
notably ARM - high cpu utilization is experienced when transmitting
large numbers of packets.

The attached set of patches provided by ASIX add this capability to the
usbnet.c driver and add the implementation for the asix.c driver.  

These patches are not yet ready for merging but we are very interested
in any review and comments that can be provided at this time.

One item that I have is how to handle the portion in usbnet_probe() that
sets the hard_start_xmit handler with the change to netdevice_ops:

-	net->hard_start_xmit = usbnet_start_xmit;
+	if (info->tx_gather)
+		net->hard_start_xmit = usbnet_bundle_xmit;
+	else
+		net->hard_start_xmit = usbnet_start_xmit;


Would it be the most appropriate to merge the
usbnet_aggregate_skb_xmit() pieces into the existing usbnet_start_xmit
with appropriate conditionals?


--=-azFxmGl2ad9Gzq0uxukm
Content-Disposition: inline; filename="usbnet.h.patch"
Content-Type: text/x-patch; name="usbnet.h.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- ../../linux-2.6.29.4/include/linux/usb/usbnet.h	2009-05-19 07:52:34.000000000 +0800
+++ usbnet.h	2009-06-08 13:27:16.000000000 +0800
@@ -48,11 +48,15 @@
 	u32			xid;
 	u32			hard_mtu;	/* count any extra framing */
 	size_t			rx_urb_size;	/* size for rx urbs */
+	size_t			tx_threshold;
 	struct mii_if_info	mii;
 
 	/* various kinds of pending driver work */
 	struct sk_buff_head	rxq;
 	struct sk_buff_head	txq;
+	struct sk_buff_head	tx_waitq;
+	u32			tx_wait_bytes;
+	u32			tx_busy_pkt;
 	struct sk_buff_head	done;
 	struct urb		*interrupt;
 	struct tasklet_struct	bh;
@@ -114,6 +118,10 @@
 	struct sk_buff	*(*tx_fixup)(struct usbnet *dev,
 				struct sk_buff *skb, gfp_t flags);
 
+	/* aggregate tx packets */
+	struct sk_buff	*(*tx_gather)(struct usbnet *dev,
+				struct sk_buff_head *q, size_t *actual_len);
+
 	/* early initialization code, can sleep. This is for minidrivers
 	 * having 'subminidrivers' that need to do extra initialization
 	 * right after minidriver have initialized hardware. */
@@ -174,6 +182,7 @@
 	struct usbnet		*dev;
 	enum skb_state		state;
 	size_t			length;
+	size_t			pkt_cnt;
 };
 
 

--=-azFxmGl2ad9Gzq0uxukm
Content-Disposition: inline; filename="usbnet.c.patch"
Content-Type: text/x-patch; name="usbnet.c.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- ../../linux-2.6.29.4/drivers/net/usb/usbnet.c	2009-05-19 07:52:34.000000000 +0800
+++ usbnet.c	2009-06-10 10:18:18.000000000 +0800
@@ -45,6 +45,8 @@
 
 #define DRIVER_VERSION		"22-Aug-2005"
 
+static int usbnet_aggreate_skb_ximt (struct usbnet *dev,
+			struct sk_buff_head *q);
 
 /*-------------------------------------------------------------------------*/
 
@@ -551,6 +553,7 @@
 static int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
+	struct sk_buff		*skb;
 	int			temp;
 	DECLARE_WAIT_QUEUE_HEAD_ONSTACK (unlink_wakeup);
 	DECLARE_WAITQUEUE (wait, current);
@@ -579,6 +582,11 @@
 	dev->wait = NULL;
 	remove_wait_queue (&unlink_wakeup, &wait);
 
+	while (!skb_queue_empty (&dev->tx_waitq)) {
+		skb = skb_dequeue(&dev->tx_waitq);
+		dev_kfree_skb (skb);
+	}
+
 	usb_kill_urb(dev->interrupt);
 
 	/* deferred work (task, timer, softirq) must also stop.
@@ -863,13 +871,20 @@
 	struct sk_buff		*skb = (struct sk_buff *) urb->context;
 	struct skb_data		*entry = (struct skb_data *) skb->cb;
 	struct usbnet		*dev = entry->dev;
+	struct driver_info	*info = dev->driver_info;
+	unsigned long		flags;
+
+	if (info->tx_gather) {
+		spin_lock_irqsave (&dev->tx_waitq.lock, flags);
+		dev->tx_busy_pkt -= entry->pkt_cnt;
+		spin_unlock (&dev->tx_waitq.lock);
+	}
 
 	if (urb->status == 0) {
-		dev->stats.tx_packets++;
 		dev->stats.tx_bytes += entry->length;
+		dev->stats.tx_packets += entry->pkt_cnt;
 	} else {
-		dev->stats.tx_errors++;
-
+		dev->stats.tx_errors += entry->pkt_cnt;
 		switch (urb->status) {
 		case -EPIPE:
 			usbnet_defer_kevent (dev, EVENT_TX_HALT);
@@ -920,6 +935,113 @@
 
 /*-------------------------------------------------------------------------*/
 
+static int usbnet_aggreate_skb_xmit (struct usbnet *dev, struct sk_buff_head *q)
+{
+
+	struct sk_buff		*skb = NULL;//, *skbnext = NULL;
+	int			pkt_cnt = 0;
+	struct skb_data		*entry;
+	int			retval = NET_XMIT_SUCCESS;
+	struct urb		*urb = NULL;
+	struct driver_info	*info = dev->driver_info;
+	size_t			actual_len = 0;
+
+	if (skb_queue_empty (q)) {
+		return retval;
+	}
+
+	spin_lock (&q->lock);
+
+	pkt_cnt = skb_queue_len (q);
+	skb = info->tx_gather (dev, q, &actual_len);
+
+	dev->tx_wait_bytes -= actual_len;
+	dev->tx_busy_pkt += pkt_cnt;
+
+	spin_unlock (&q->lock);	
+
+	if (!skb){
+		goto drop;
+	}
+
+	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
+		if (netif_msg_tx_err (dev))
+			devdbg (dev, "no urb");	
+		goto drop;
+	}else{
+		entry = (struct skb_data *) skb->cb;
+		entry->length = actual_len;
+		entry->pkt_cnt = pkt_cnt;
+		entry->urb = urb;
+		entry->dev = dev;
+		entry->state = tx_start;
+
+		usb_fill_bulk_urb (urb, dev->udev, dev->out,
+				skb->data, skb->len, tx_complete, skb);
+	}
+
+	switch ((retval = usb_submit_urb (urb, GFP_ATOMIC))) {		
+	case -EPIPE:
+		netif_stop_queue (dev->net);
+		usbnet_defer_kevent (dev, EVENT_TX_HALT);
+		break;
+	default:
+		if (netif_msg_tx_err (dev))
+			devdbg (dev, "tx: submit urb err %d", retval);
+		break;
+	case 0:
+		dev->net->trans_start = jiffies;
+		__skb_queue_tail (&dev->txq, skb);
+	}
+
+	if (retval) {
+		if (netif_msg_tx_err (dev))
+			devdbg (dev, "drop, code %d", retval);
+drop:
+		spin_lock (&q->lock);
+		dev->tx_busy_pkt -= pkt_cnt;
+		spin_unlock (&q->lock);
+
+		retval = NET_XMIT_SUCCESS;
+		dev->stats.tx_dropped += pkt_cnt;
+		if (skb)
+			dev_kfree_skb_any (skb);
+		usb_free_urb (urb);
+	} else if (netif_msg_tx_queued (dev)) {
+		devdbg (dev, "> tx, len %d, type 0x%x",
+			skb->len, skb->protocol);
+	}
+
+	return retval;
+}
+
+static int usbnet_bundle_xmit (struct sk_buff *skb, struct net_device *net)
+{
+	struct usbnet		*dev = netdev_priv(net);
+	int			retval = NET_XMIT_SUCCESS;
+	unsigned long		flags;
+
+	spin_lock_irqsave (&dev->tx_waitq.lock, flags);
+	__skb_queue_tail (&dev->tx_waitq, skb);
+	dev->tx_wait_bytes += skb->len;
+	spin_unlock (&dev->tx_waitq.lock);
+
+	spin_lock (&dev->txq.lock);
+
+	if (skb_queue_empty (&dev->txq) ||
+	    (dev->tx_wait_bytes >= dev->tx_threshold) ||
+	    (dev->tx_waitq.qlen > 16)) {
+		retval = usbnet_aggreate_skb_xmit (dev, &dev->tx_waitq);
+	}
+
+	if ((dev->tx_busy_pkt + dev->tx_waitq.qlen) >= TX_QLEN (dev))
+		netif_stop_queue (net);
+
+	spin_unlock_irqrestore (&dev->txq.lock, flags);
+
+	return 	retval;
+}
+
 static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
@@ -953,6 +1075,7 @@
 	entry->dev = dev;
 	entry->state = tx_start;
 	entry->length = length;
+	entry->pkt_cnt = 1;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
 			skb->data, skb->len, tx_complete, skb);
@@ -1014,6 +1137,8 @@
 	struct usbnet		*dev = (struct usbnet *) param;
 	struct sk_buff		*skb;
 	struct skb_data		*entry;
+	struct driver_info	*info = dev->driver_info;
+	unsigned long		flags;
 
 	while ((skb = skb_dequeue (&dev->done))) {
 		entry = (struct skb_data *) skb->cb;
@@ -1062,8 +1187,22 @@
 			if (dev->rxq.qlen < qlen)
 				tasklet_schedule (&dev->bh);
 		}
-		if (dev->txq.qlen < TX_QLEN (dev))
-			netif_wake_queue (dev->net);
+
+		if (info->tx_gather) {
+			spin_lock_irqsave (&dev->txq.lock, flags);
+			if (dev->txq.qlen == 0) {
+				usbnet_aggreate_skb_ximt(dev, &dev->tx_waitq);
+			}
+
+			if ((dev->tx_busy_pkt + dev->tx_waitq.qlen) <
+					 TX_QLEN (dev))
+				netif_wake_queue (dev->net);
+
+			spin_unlock_irqrestore(&dev->txq.lock, flags);
+		} else {
+			if (dev->txq.qlen < TX_QLEN (dev))
+				netif_wake_queue (dev->net);
+		}
 	}
 }
 
@@ -1156,6 +1295,7 @@
 	skb_queue_head_init (&dev->rxq);
 	skb_queue_head_init (&dev->txq);
 	skb_queue_head_init (&dev->done);
+	skb_queue_head_init (&dev->tx_waitq);
 	dev->bh.func = usbnet_bh;
 	dev->bh.data = (unsigned long) dev;
 	INIT_WORK (&dev->kevent, kevent);
@@ -1181,7 +1321,10 @@
 
 	net->change_mtu = usbnet_change_mtu;
 	net->get_stats = usbnet_get_stats;
-	net->hard_start_xmit = usbnet_start_xmit;
+	if (info->tx_gather)
+		net->hard_start_xmit = usbnet_bundle_xmit;
+	else
+		net->hard_start_xmit = usbnet_start_xmit;
 	net->open = usbnet_open;
 	net->stop = usbnet_stop;
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
@@ -1228,6 +1371,8 @@
 
 	if (!dev->rx_urb_size)
 		dev->rx_urb_size = dev->hard_mtu;
+	if (!dev->tx_threshold)
+		dev->tx_threshold = dev->rx_urb_size;
 	dev->maxpacket = usb_maxpacket (dev->udev, dev->out, 1);
 
 	SET_NETDEV_DEV(net, &udev->dev);

--=-azFxmGl2ad9Gzq0uxukm
Content-Disposition: inline; filename="asix.c.patch"
Content-Type: text/x-patch; name="asix.c.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- ../../../linux-2.6.29.4/drivers/net/usb/asix.c	2009-05-19 07:52:34.000000000 +0800
+++ asix.c	2009-06-10 10:15:17.000000000 +0800
@@ -354,6 +354,85 @@
 	return 1;
 }
 
+static struct sk_buff *
+ax88772_tx_gather (struct usbnet *dev, struct sk_buff_head *q,
+			size_t *actual_len)
+{
+	struct sk_buff		*skb = NULL, *skb_next = NULL;
+	int			pkt_cnt;
+	u16			pkt_size;
+	u32			skb_len = 0;
+
+	u32			packet_hdr;
+	u32			padbytes = 0xffff0000;
+	u8			padneeded = 0;
+	struct driver_info	*info = dev->driver_info;
+
+	pkt_cnt = skb_queue_len (q);
+
+	*actual_len = 0;
+	for (skb_next = q->next; skb_next != (struct sk_buff *) q;
+	     skb_next = skb_next->next){
+		*actual_len += skb_next->len;
+		pkt_size = (skb_next->len + 4 + 1) & 0xFFFE;
+		skb_len += pkt_size;
+	}
+
+	if ((skb_len % 512) == 0) {
+		skb_len += sizeof (padbytes);
+		padneeded = 1;
+	}
+
+	if (pkt_cnt > 1){
+
+		skb = dev_alloc_skb (skb_len); 
+
+		if (!skb){
+
+			while (pkt_cnt--) {
+				skb_next = __skb_dequeue(q);
+				dev_kfree_skb_any (skb_next);
+			}
+
+			devdbg (dev, "skb is NULL, len %d", skb_len);
+			return skb;
+		}
+
+		while (pkt_cnt--) {
+
+			skb_next = __skb_dequeue(q);
+
+			packet_hdr = ((skb_next->len ^ 0x0000ffff) << 16) +
+						skb_next->len;
+
+			le32_to_cpus(&packet_hdr);
+			memcpy (skb_put(skb, 4),  &packet_hdr, 4);
+			memcpy (skb_put(skb, skb_next->len),  skb_next->data,
+						skb_next->len);
+			if (skb->len & 1)
+				skb_put (skb, 1);
+			dev_kfree_skb_any (skb_next);
+		}
+
+		if (padneeded) {
+			memcpy (skb_put(skb, sizeof (padbytes)),
+					&padbytes, sizeof (padbytes));
+		}
+		
+	}else{ //only one packet to send
+		skb = __skb_dequeue(q);
+
+		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
+		if (!skb) {
+			if (netif_msg_tx_err (dev))
+				devdbg (dev, "can't tx_fixup skb");
+			return skb;
+		}
+	}
+
+	return skb;
+}
+
 static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 					gfp_t flags)
 {
@@ -1011,6 +1090,7 @@
 		/* hard_mtu  is still the default - the device does not support
 		   jumbo eth frames */
 		dev->rx_urb_size = 2048;
+		dev->tx_threshold = 16384;
 	}
 	return 0;
 
@@ -1281,6 +1361,7 @@
 		/* hard_mtu  is still the default - the device does not support
 		   jumbo eth frames */
 		dev->rx_urb_size = 2048;
+		dev->tx_threshold = 16384;
 	}
 	return 0;
 
@@ -1337,6 +1418,7 @@
 	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
 	.rx_fixup = asix_rx_fixup,
 	.tx_fixup = asix_tx_fixup,
+	.tx_gather = ax88772_tx_gather,
 };
 
 static const struct driver_info ax88178_info = {
@@ -1348,6 +1430,7 @@
 	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
 	.rx_fixup = asix_rx_fixup,
 	.tx_fixup = asix_tx_fixup,
+	.tx_gather = ax88772_tx_gather,
 };
 
 static const struct usb_device_id	products [] = {

--=-azFxmGl2ad9Gzq0uxukm--

