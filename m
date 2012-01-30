From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 16/16] netfront: split event channels support.
Date: Mon, 30 Jan 2012 14:45:34 +0000
Message-ID: <1327934734-8908-17-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44845 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab2A3Opz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:55 -0500
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this feature is not activated, rx_irq = tx_irq. See corresponding
netback change log for details.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |  147 ++++++++++++++++++++++++++++++++++----------
 1 files changed, 115 insertions(+), 32 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 32ec212..72c0429 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -98,7 +98,9 @@ struct netfront_info {
 
 	unsigned long rx_gso_checksum_fixup;
 
-	unsigned int evtchn;
+	unsigned int split_evtchn;
+	unsigned int tx_evtchn, rx_evtchn;
+	unsigned int tx_irq, rx_irq;
 	struct xenbus_device *xbdev;
 
 	spinlock_t   tx_lock;
@@ -344,7 +346,7 @@ no_skb:
  push:
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->rx, notify);
 	if (notify)
-		notify_remote_via_irq(np->netdev->irq);
+		notify_remote_via_irq(np->rx_irq);
 }
 
 static int xennet_open(struct net_device *dev)
@@ -577,7 +579,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->tx, notify);
 	if (notify)
-		notify_remote_via_irq(np->netdev->irq);
+		notify_remote_via_irq(np->tx_irq);
 
 	u64_stats_update_begin(&stats->syncp);
 	stats->tx_bytes += skb->len;
@@ -1242,22 +1244,35 @@ static int xennet_set_features(struct net_device *dev, u32 features)
 	return 0;
 }
 
-static irqreturn_t xennet_interrupt(int irq, void *dev_id)
+static irqreturn_t xennet_tx_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct netfront_info *np = netdev_priv(dev);
+	struct netfront_info *np = dev_id;
+	struct net_device *dev = np->netdev;
 	unsigned long flags;
 
 	spin_lock_irqsave(&np->tx_lock, flags);
+	xennet_tx_buf_gc(dev);
+	spin_unlock_irqrestore(&np->tx_lock, flags);
 
-	if (likely(netif_carrier_ok(dev))) {
-		xennet_tx_buf_gc(dev);
-		/* Under tx_lock: protects access to rx shared-ring indexes. */
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			napi_schedule(&np->napi);
-	}
+	return IRQ_HANDLED;
+}
 
-	spin_unlock_irqrestore(&np->tx_lock, flags);
+static irqreturn_t xennet_rx_interrupt(int irq, void *dev_id)
+{
+	struct netfront_info *np = dev_id;
+	struct net_device *dev = np->netdev;
+
+	if (likely(netif_carrier_ok(dev)) &&
+	    RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		napi_schedule(&np->napi);
+
+	return IRQ_HANDLED;
+}
+static irqreturn_t xennet_interrupt(int irq, void *dev_id)
+{
+	xennet_tx_interrupt(0, dev_id);
+
+	xennet_rx_interrupt(0, dev_id);
 
 	return IRQ_HANDLED;
 }
@@ -1436,9 +1451,14 @@ static void xennet_disconnect_backend(struct netfront_info *info)
 	spin_unlock_irq(&info->tx_lock);
 	spin_unlock_bh(&info->rx_lock);
 
-	if (info->netdev->irq)
-		unbind_from_irqhandler(info->netdev->irq, info->netdev);
-	info->evtchn = info->netdev->irq = 0;
+	if (info->tx_irq && (info->tx_irq == info->rx_irq))
+		unbind_from_irqhandler(info->tx_irq, info);
+	if (info->tx_irq && (info->tx_irq != info->rx_irq)) {
+		unbind_from_irqhandler(info->tx_irq, info);
+		unbind_from_irqhandler(info->rx_irq, info);
+	}
+	info->tx_evtchn = info->tx_irq = 0;
+	info->rx_evtchn = info->rx_irq = 0;
 
 	for (i = 0; i < info->tx_ring_pages; i++) {
 		int ref = info->tx_ring_ref[i];
@@ -1507,6 +1527,7 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	int err;
 	struct net_device *netdev = info->netdev;
 	unsigned int max_tx_ring_page_order, max_rx_ring_page_order;
+	unsigned int split_evtchn;
 	int i, j;
 
 	for (i = 0; i < XENNET_MAX_RING_PAGES; i++) {
@@ -1515,7 +1536,6 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	}
 	info->rx.sring = NULL;
 	info->tx.sring = NULL;
-	netdev->irq = 0;
 
 	err = xen_net_read_mac(dev, netdev->dev_addr);
 	if (err) {
@@ -1524,6 +1544,12 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	}
 
 	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
+			   "split-event-channels", "%u",
+			   &split_evtchn);
+	if (err < 0)
+		split_evtchn = 0;
+
+	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
 			   "max-tx-ring-page-order", "%u",
 			   &max_tx_ring_page_order);
 	if (err < 0) {
@@ -1589,20 +1615,59 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		info->rx_ring_ref[j] = err;
 	}
 
-	err = xenbus_alloc_evtchn(dev, &info->evtchn);
-	if (err)
-		goto alloc_evtchn_fail;
+	if (!split_evtchn) {
+		err = xenbus_alloc_evtchn(dev, &info->tx_evtchn);
+		if (err)
+			goto alloc_evtchn_fail;
 
-	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					0, netdev->name, netdev);
-	if (err < 0)
-		goto bind_fail;
-	netdev->irq = err;
+		err = bind_evtchn_to_irqhandler(info->tx_evtchn,
+						xennet_interrupt,
+						0, netdev->name, info);
+		if (err < 0)
+			goto bind_fail;
+		info->rx_evtchn = info->tx_evtchn;
+		info->tx_irq = info->rx_irq = err;
+		info->split_evtchn = 0;
+		dev_info(&dev->dev, "single event channel, irq = %d\n",
+			 info->tx_irq);
+	} else {
+		err = xenbus_alloc_evtchn(dev, &info->tx_evtchn);
+		if (err)
+			goto alloc_evtchn_fail;
+		err = xenbus_alloc_evtchn(dev, &info->rx_evtchn);
+		if (err) {
+			xenbus_free_evtchn(dev, info->tx_evtchn);
+			goto alloc_evtchn_fail;
+		}
+		err = bind_evtchn_to_irqhandler(info->tx_evtchn,
+						xennet_tx_interrupt,
+						0, netdev->name, info);
+		if (err < 0)
+			goto bind_fail;
+		info->tx_irq = err;
+		err = bind_evtchn_to_irqhandler(info->rx_evtchn,
+						xennet_rx_interrupt,
+						0, netdev->name, info);
+		if (err < 0) {
+			unbind_from_irqhandler(info->tx_irq, info);
+			goto bind_fail;
+		}
+		info->rx_irq = err;
+		info->split_evtchn = 1;
+		dev_info(&dev->dev, "split event channels,"
+			 " tx_irq = %d, rx_irq = %d\n",
+			 info->tx_irq, info->rx_irq);
+	}
 
 	return 0;
 
 bind_fail:
-	xenbus_free_evtchn(dev, info->evtchn);
+	if (!split_evtchn)
+		xenbus_free_evtchn(dev, info->tx_evtchn);
+	else {
+		xenbus_free_evtchn(dev, info->tx_evtchn);
+		xenbus_free_evtchn(dev, info->rx_evtchn);
+	}
 alloc_evtchn_fail:
 	for (; j >= 0; j--) {
 		int ref = info->rx_ring_ref[j];
@@ -1690,11 +1755,27 @@ again:
 		}
 	}
 
-	err = xenbus_printf(xbt, dev->nodename,
-			    "event-channel", "%u", info->evtchn);
-	if (err) {
-		message = "writing event-channel";
-		goto abort_transaction;
+
+	if (!info->split_evtchn) {
+		err = xenbus_printf(xbt, dev->nodename,
+				    "event-channel", "%u", info->tx_evtchn);
+		if (err) {
+			message = "writing event-channel";
+			goto abort_transaction;
+		}
+	} else {
+		err = xenbus_printf(xbt, dev->nodename,
+				    "event-channel-tx", "%u", info->tx_evtchn);
+		if (err) {
+			message = "writing event-channel-tx";
+			goto abort_transaction;
+		}
+		err = xenbus_printf(xbt, dev->nodename,
+				    "event-channel-rx", "%u", info->rx_evtchn);
+		if (err) {
+			message = "writing event-channel-rx";
+			goto abort_transaction;
+		}
 	}
 
 	err = xenbus_printf(xbt, dev->nodename, "request-rx-copy", "%u",
@@ -1808,7 +1889,9 @@ static int xennet_connect(struct net_device *dev)
 	 * packets.
 	 */
 	netif_carrier_on(np->netdev);
-	notify_remote_via_irq(np->netdev->irq);
+	notify_remote_via_irq(np->tx_irq);
+	if (np->split_evtchn)
+		notify_remote_via_irq(np->rx_irq);
 	xennet_tx_buf_gc(dev);
 	xennet_alloc_rx_buffers(dev);
 
-- 
1.7.2.5
