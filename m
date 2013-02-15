From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 8/8] netfront: split event channels support
Date: Fri, 15 Feb 2013 16:00:09 +0000
Message-ID: <1360944010-15336-9-git-send-email-wei.liu2@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:30891 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935937Ab3BOQA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 11:00:56 -0500
In-Reply-To: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this feature is not activated, rx_irq = tx_irq. See corresponding netback
change log for details.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |  184 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 152 insertions(+), 32 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index de73a71..ea9b656 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -100,7 +100,12 @@ struct netfront_info {
 
 	struct napi_struct napi;
 
-	unsigned int evtchn;
+	/* 
+	 * Split event channels support, tx_* == rx_* when using
+	 * single event channel.
+	 */
+	unsigned int tx_evtchn, rx_evtchn;
+	unsigned int tx_irq, rx_irq;
 	struct xenbus_device *xbdev;
 
 	spinlock_t   tx_lock;
@@ -344,7 +349,7 @@ no_skb:
  push:
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->rx, notify);
 	if (notify)
-		notify_remote_via_irq(np->netdev->irq);
+		notify_remote_via_irq(np->rx_irq);
 }
 
 static int xennet_open(struct net_device *dev)
@@ -633,7 +638,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->tx, notify);
 	if (notify)
-		notify_remote_via_irq(np->netdev->irq);
+		notify_remote_via_irq(np->tx_irq);
 
 	u64_stats_update_begin(&stats->syncp);
 	stats->tx_bytes += skb->len;
@@ -1263,26 +1268,41 @@ static int xennet_set_features(struct net_device *dev,
 	return 0;
 }
 
-static irqreturn_t xennet_interrupt(int irq, void *dev_id)
+/* Used for tx completion */
+static irqreturn_t xennet_tx_interrupt(int tx_irq, void *dev_id)
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
+/* Used for rx */
+static irqreturn_t xennet_rx_interrupt(int rx_irq, void *dev_id)
+{
+	struct netfront_info *np = dev_id;
+	struct net_device *dev = np->netdev;
+
+	if (likely(netif_carrier_ok(dev) &&
+		   RING_HAS_UNCONSUMED_RESPONSES(&np->rx)))
+		napi_schedule(&np->napi);
 
 	return IRQ_HANDLED;
 }
 
+/* Used for single event channel configuration */
+static irqreturn_t xennet_interrupt(int irq, void *dev_id)
+{
+	xennet_tx_interrupt(irq, dev_id);
+	xennet_rx_interrupt(irq, dev_id);
+	return IRQ_HANDLED;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xennet_poll_controller(struct net_device *dev)
 {
@@ -1451,9 +1471,14 @@ static void xennet_disconnect_backend(struct netfront_info *info)
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
+	info->tx_evtchn = info->rx_evtchn = 0;
+	info->tx_irq = info->rx_irq = 0;
 
 	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->tx.sring);
 	free_pages((unsigned long)info->tx.sring, info->tx_ring_page_order);
@@ -1503,11 +1528,86 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
 	return 0;
 }
 
+static int setup_netfront_single(struct netfront_info *info)
+{
+	int err;
+
+	err = xenbus_alloc_evtchn(info->xbdev, &info->tx_evtchn);
+	if (err < 0)
+		goto fail;
+
+	err = bind_evtchn_to_irqhandler(info->tx_evtchn,
+					xennet_interrupt,
+					0, info->netdev->name, info);
+	if (err < 0)
+		goto bind_fail;
+	info->rx_evtchn = info->tx_evtchn;
+	info->rx_irq = info->tx_irq = err;
+	dev_info(&info->xbdev->dev,
+		 "single event channel, evtchn = %d, irq = %d\n",
+		 info->tx_evtchn, info->tx_irq);
+
+	return 0;
+
+bind_fail:
+	xenbus_free_evtchn(info->xbdev, info->tx_evtchn);
+	info->tx_evtchn = 0;
+fail:
+	return err;
+}
+
+static int setup_netfront_split(struct netfront_info *info)
+{
+	int err;
+
+	err = xenbus_alloc_evtchn(info->xbdev, &info->tx_evtchn);
+	if (err)
+		goto fail;
+	err = xenbus_alloc_evtchn(info->xbdev, &info->rx_evtchn);
+	if (err)
+		goto alloc_rx_evtchn_fail;
+
+	err = bind_evtchn_to_irqhandler(info->tx_evtchn,
+					xennet_tx_interrupt,
+					0, info->netdev->name, info);
+	if (err < 0)
+		goto bind_tx_fail;
+	info->tx_irq = err;
+
+	err = bind_evtchn_to_irqhandler(info->rx_evtchn,
+					xennet_rx_interrupt,
+					0, info->netdev->name, info);
+	if (err < 0)
+		goto bind_rx_fail;
+
+	info->rx_irq = err;
+
+	dev_info(&info->xbdev->dev,
+		 "split event channels, tx_evtchn/irq = %d/%d, rx_evtchn/irq = %d/%d",
+		 info->tx_evtchn, info->tx_irq,
+		 info->rx_evtchn, info->rx_irq);
+
+	return 0;
+
+bind_rx_fail:
+	unbind_from_irqhandler(info->tx_irq, info);
+	info->tx_irq = 0;
+bind_tx_fail:
+	xenbus_free_evtchn(info->xbdev, info->rx_evtchn);
+	info->rx_evtchn = 0;
+alloc_rx_evtchn_fail:
+	xenbus_free_evtchn(info->xbdev, info->tx_evtchn);
+	info->tx_evtchn = 0;
+fail:
+	return err;
+}
+
 static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 {
 	struct xen_netif_tx_sring *txs;
 	struct xen_netif_rx_sring *rxs;
 	int err;
+	unsigned int feature_split_evtchn;
 	struct net_device *netdev = info->netdev;
 	unsigned int max_tx_ring_page_order, max_rx_ring_page_order;
 	int i;
@@ -1527,6 +1627,12 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	}
 
 	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
+			   "feature-split-event-channels", "%u",
+			   &feature_split_evtchn);
+	if (err < 0)
+		feature_split_evtchn = 0;
+
+	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
 			   "max-tx-ring-page-order", "%u",
 			   &max_tx_ring_page_order);
 	if (err < 0) {
@@ -1598,20 +1704,17 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	if (err < 0)
 		goto grant_rx_ring_fail;
 
-	err = xenbus_alloc_evtchn(dev, &info->evtchn);
+	if (feature_split_evtchn)
+		err = setup_netfront_split(info);
+	else
+		err = setup_netfront_single(info);
+
 	if (err)
-		goto alloc_evtchn_fail;
+		goto setup_evtchn_fail;
 
-	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					0, netdev->name, netdev);
-	if (err < 0)
-		goto bind_fail;
-	netdev->irq = err;
 	return 0;
 
-bind_fail:
-	xenbus_free_evtchn(dev, info->evtchn);
-alloc_evtchn_fail:
+setup_evtchn_fail:
 	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->rx.sring);
 grant_rx_ring_fail:
 	free_pages((unsigned long)info->rx.sring, info->rx_ring_page_order);
@@ -1696,11 +1799,26 @@ again:
 		}
 	}
 
-	err = xenbus_printf(xbt, dev->nodename,
-			    "event-channel", "%u", info->evtchn);
-	if (err) {
-		message = "writing event-channel";
-		goto abort_transaction;
+	if (info->tx_evtchn == info->rx_evtchn) {
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
@@ -1814,7 +1932,9 @@ static int xennet_connect(struct net_device *dev)
 	 * packets.
 	 */
 	netif_carrier_on(np->netdev);
-	notify_remote_via_irq(np->netdev->irq);
+	notify_remote_via_irq(np->tx_irq);
+	if (np->tx_irq != np->rx_irq)
+		notify_remote_via_irq(np->rx_irq);
 	xennet_tx_buf_gc(dev);
 	xennet_alloc_rx_buffers(dev);
 
-- 
1.7.10.4
