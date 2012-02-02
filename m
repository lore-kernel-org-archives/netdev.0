From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 13/13] netfront: split event channels support.
Date: Thu, 2 Feb 2012 16:49:23 +0000
Message-ID: <1328201363-13915-14-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20721 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755596Ab2BBQtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 11:49:43 -0500
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If this feature is not activated, rx_irq = tx_irq. See corresponding
netback change log for details.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |  178 +++++++++++++++++++++++++++++++++++--------
 1 files changed, 145 insertions(+), 33 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a1cfb24..9d70665 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -98,7 +98,9 @@ struct netfront_info {
 
 	unsigned long rx_gso_checksum_fixup;
 
-	unsigned int evtchn;
+	unsigned int tx_evtchn, rx_evtchn;
+	unsigned int tx_irq, rx_irq;
+
 	struct xenbus_device *xbdev;
 
 	spinlock_t   tx_lock;
@@ -342,7 +344,7 @@ no_skb:
  push:
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->rx, notify);
 	if (notify)
-		notify_remote_via_irq(np->netdev->irq);
+		notify_remote_via_irq(np->rx_irq);
 }
 
 static int xennet_open(struct net_device *dev)
@@ -575,7 +577,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->tx, notify);
 	if (notify)
-		notify_remote_via_irq(np->netdev->irq);
+		notify_remote_via_irq(np->tx_irq);
 
 	u64_stats_update_begin(&stats->syncp);
 	stats->tx_bytes += skb->len;
@@ -1240,22 +1242,36 @@ static int xennet_set_features(struct net_device *dev, u32 features)
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
+	if (likely(netif_carrier_ok(dev) &&
+		   RING_HAS_UNCONSUMED_RESPONSES(&np->rx)))
+		napi_schedule(&np->napi);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xennet_interrupt(int irq, void *dev_id)
+{
+	xennet_tx_interrupt(irq, dev_id);
+
+	xennet_rx_interrupt(irq, dev_id);
 
 	return IRQ_HANDLED;
 }
@@ -1431,9 +1447,15 @@ static void xennet_disconnect_backend(struct netfront_info *info)
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
+
+	info->tx_evtchn = info->tx_irq = 0;
+	info->rx_evtchn = info->rx_irq = 0;
 
 	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->tx.sring);
 	free_pages((unsigned long)info->tx.sring, info->tx_ring_page_order);
@@ -1483,11 +1505,80 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
 	return 0;
 }
 
+static int setup_netfront_single(struct netfront_info *info)
+{
+	int err;
+
+	err = xenbus_alloc_evtchn(info->xbdev, &info->tx_evtchn);
+
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
+	dev_info(&info->xbdev->dev, "single event channel, irq = %d\n",
+		 info->tx_irq);
+
+	return 0;
+
+bind_fail:
+	xenbus_free_evtchn(info->xbdev, info->tx_evtchn);
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
+	err = bind_evtchn_to_irqhandler(info->rx_evtchn,
+					xennet_rx_interrupt,
+					0, info->netdev->name, info);
+	if (err < 0)
+		goto bind_rx_fail;
+
+	info->rx_irq = err;
+	dev_info(&info->xbdev->dev, "split event channels,"
+		 " tx_irq = %d, rx_irq = %d\n",
+		 info->tx_irq, info->rx_irq);
+
+
+	return 0;
+
+bind_rx_fail:
+	unbind_from_irqhandler(info->tx_irq, info);
+bind_tx_fail:
+	xenbus_free_evtchn(info->xbdev, info->rx_evtchn);
+alloc_rx_evtchn_fail:
+	xenbus_free_evtchn(info->xbdev, info->tx_evtchn);
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
@@ -1507,6 +1598,13 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	}
 
 	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
+			   "feature-split-event-channels", "%u",
+			   &feature_split_evtchn);
+
+	if (err < 0)
+		feature_split_evtchn = 0;
+
+	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
 			   "max-tx-ring-page-order", "%u",
 			   &max_tx_ring_page_order);
 	if (err < 0) {
@@ -1568,21 +1666,17 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 
 	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE * info->rx_ring_pages);
 
-	err = xenbus_alloc_evtchn(dev, &info->evtchn);
-	if (err)
-		goto alloc_evtchn_fail;
+	if (!feature_split_evtchn)
+		err = setup_netfront_single(info);
+	else
+		err = setup_netfront_split(info);
 
-	err = bind_evtchn_to_irqhandler(info->evtchn, xennet_interrupt,
-					0, netdev->name, netdev);
-	if (err < 0)
-		goto bind_fail;
-	netdev->irq = err;
+	if (err)
+		goto setup_evtchn_failed;
 
 	return 0;
 
-bind_fail:
-	xenbus_free_evtchn(dev, info->evtchn);
-alloc_evtchn_fail:
+setup_evtchn_failed:
 	xenbus_unmap_ring_vfree(info->xbdev, (void *)info->rx.sring);
 grant_rx_ring_fail:
 	free_pages((unsigned long)info->rx.sring, info->rx_ring_page_order);
@@ -1659,11 +1753,27 @@ again:
 		}
 	}
 
-	err = xenbus_printf(xbt, dev->nodename,
-			    "event-channel", "%u", info->evtchn);
-	if (err) {
-		message = "writing event-channel";
-		goto abort_transaction;
+
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
@@ -1777,7 +1887,9 @@ static int xennet_connect(struct net_device *dev)
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
1.7.2.5
