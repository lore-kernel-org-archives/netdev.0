From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] IPoIB: Convert to netdevice internal stats
Date: Fri, 28 Sep 2007 15:18:01 -0700
Message-ID: <ada641umo2u.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org
To: davem@davemloft.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:43949 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbXI1WST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 18:18:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the stats member of struct netdevice in IPoIB, so we can save
memory by deleting the stats member of struct ipoib_dev_priv, and save
code by deleting ipoib_get_stats().

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
Dave, can you queue this in net-2.6.24 please?  I would ordinarily
merge IPoIB changes but since this depends on the netdevice internal
stats change it becomes a cross-tree dependency if I try to do that.
And I'd like to get it queued in git now before the merge window.

Thanks...

 drivers/infiniband/ulp/ipoib/ipoib.h           |    2 --
 drivers/infiniband/ulp/ipoib/ipoib_cm.c        |   20 ++++++++++----------
 drivers/infiniband/ulp/ipoib/ipoib_ib.c        |   18 +++++++++---------
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   22 +++++++---------------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   10 +++++-----
 5 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 3a6ef14..1e627ee 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -300,8 +300,6 @@ struct ipoib_dev_priv {
 
 	struct ib_event_handler event_handler;
 
-	struct net_device_stats stats;
-
 	struct net_device *parent;
 	struct list_head child_intfs;
 	struct list_head list;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 08b4676..1afd93c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -430,7 +430,7 @@ void ipoib_cm_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 		ipoib_dbg(priv, "cm recv error "
 			   "(status=%d, wrid=%d vend_err %x)\n",
 			   wc->status, wr_id, wc->vendor_err);
-		++priv->stats.rx_dropped;
+		++dev->stats.rx_dropped;
 		goto repost;
 	}
 
@@ -457,7 +457,7 @@ void ipoib_cm_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 		 * this packet and reuse the old buffer.
 		 */
 		ipoib_dbg(priv, "failed to allocate receive buffer %d\n", wr_id);
-		++priv->stats.rx_dropped;
+		++dev->stats.rx_dropped;
 		goto repost;
 	}
 
@@ -474,8 +474,8 @@ void ipoib_cm_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 	skb_pull(skb, IPOIB_ENCAP_LEN);
 
 	dev->last_rx = jiffies;
-	++priv->stats.rx_packets;
-	priv->stats.rx_bytes += skb->len;
+	++dev->stats.rx_packets;
+	dev->stats.rx_bytes += skb->len;
 
 	skb->dev = dev;
 	/* XXX get correct PACKET_ type here */
@@ -512,8 +512,8 @@ void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_
 	if (unlikely(skb->len > tx->mtu)) {
 		ipoib_warn(priv, "packet len %d (> %d) too long to send, dropping\n",
 			   skb->len, tx->mtu);
-		++priv->stats.tx_dropped;
-		++priv->stats.tx_errors;
+		++dev->stats.tx_dropped;
+		++dev->stats.tx_errors;
 		ipoib_cm_skb_too_long(dev, skb, tx->mtu - IPOIB_ENCAP_LEN);
 		return;
 	}
@@ -532,7 +532,7 @@ void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_
 	tx_req->skb = skb;
 	addr = ib_dma_map_single(priv->ca, skb->data, skb->len, DMA_TO_DEVICE);
 	if (unlikely(ib_dma_mapping_error(priv->ca, addr))) {
-		++priv->stats.tx_errors;
+		++dev->stats.tx_errors;
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -542,7 +542,7 @@ void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_
 	if (unlikely(post_send(priv, tx, tx->tx_head & (ipoib_sendq_size - 1),
 			        addr, skb->len))) {
 		ipoib_warn(priv, "post_send failed\n");
-		++priv->stats.tx_errors;
+		++dev->stats.tx_errors;
 		ib_dma_unmap_single(priv->ca, addr, skb->len, DMA_TO_DEVICE);
 		dev_kfree_skb_any(skb);
 	} else {
@@ -580,8 +580,8 @@ static void ipoib_cm_handle_tx_wc(struct net_device *dev, struct ipoib_cm_tx *tx
 	ib_dma_unmap_single(priv->ca, tx_req->mapping, tx_req->skb->len, DMA_TO_DEVICE);
 
 	/* FIXME: is this right? Shouldn't we only increment on success? */
-	++priv->stats.tx_packets;
-	priv->stats.tx_bytes += tx_req->skb->len;
+	++dev->stats.tx_packets;
+	dev->stats.tx_bytes += tx_req->skb->len;
 
 	dev_kfree_skb_any(tx_req->skb);
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index b664b98..1a77e79 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -208,7 +208,7 @@ static void ipoib_ib_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 	 * this packet and reuse the old buffer.
 	 */
 	if (unlikely(ipoib_alloc_rx_skb(dev, wr_id))) {
-		++priv->stats.rx_dropped;
+		++dev->stats.rx_dropped;
 		goto repost;
 	}
 
@@ -225,8 +225,8 @@ static void ipoib_ib_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 	skb_pull(skb, IPOIB_ENCAP_LEN);
 
 	dev->last_rx = jiffies;
-	++priv->stats.rx_packets;
-	priv->stats.rx_bytes += skb->len;
+	++dev->stats.rx_packets;
+	dev->stats.rx_bytes += skb->len;
 
 	skb->dev = dev;
 	/* XXX get correct PACKET_ type here */
@@ -260,8 +260,8 @@ static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 	ib_dma_unmap_single(priv->ca, tx_req->mapping,
 			    tx_req->skb->len, DMA_TO_DEVICE);
 
-	++priv->stats.tx_packets;
-	priv->stats.tx_bytes += tx_req->skb->len;
+	++dev->stats.tx_packets;
+	dev->stats.tx_bytes += tx_req->skb->len;
 
 	dev_kfree_skb_any(tx_req->skb);
 
@@ -362,8 +362,8 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 	if (unlikely(skb->len > priv->mcast_mtu + IPOIB_ENCAP_LEN)) {
 		ipoib_warn(priv, "packet len %d (> %d) too long to send, dropping\n",
 			   skb->len, priv->mcast_mtu + IPOIB_ENCAP_LEN);
-		++priv->stats.tx_dropped;
-		++priv->stats.tx_errors;
+		++dev->stats.tx_dropped;
+		++dev->stats.tx_errors;
 		ipoib_cm_skb_too_long(dev, skb, priv->mcast_mtu);
 		return;
 	}
@@ -383,7 +383,7 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 	addr = ib_dma_map_single(priv->ca, skb->data, skb->len,
 				 DMA_TO_DEVICE);
 	if (unlikely(ib_dma_mapping_error(priv->ca, addr))) {
-		++priv->stats.tx_errors;
+		++dev->stats.tx_errors;
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -392,7 +392,7 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 	if (unlikely(post_send(priv, priv->tx_head & (ipoib_sendq_size - 1),
 			       address->ah, qpn, addr, skb->len))) {
 		ipoib_warn(priv, "post_send failed\n");
-		++priv->stats.tx_errors;
+		++dev->stats.tx_errors;
 		ib_dma_unmap_single(priv->ca, addr, skb->len, DMA_TO_DEVICE);
 		dev_kfree_skb_any(skb);
 	} else {
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index d8754dd..e079cca 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -519,7 +519,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 
 	neigh = ipoib_neigh_alloc(skb->dst->neighbour);
 	if (!neigh) {
-		++priv->stats.tx_dropped;
+		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -584,7 +584,7 @@ err_list:
 err_path:
 	ipoib_neigh_free(dev, neigh);
 err_drop:
-	++priv->stats.tx_dropped;
+	++dev->stats.tx_dropped;
 	dev_kfree_skb_any(skb);
 
 	spin_unlock(&priv->lock);
@@ -633,7 +633,7 @@ static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 			} else
 				__path_add(dev, path);
 		} else {
-			++priv->stats.tx_dropped;
+			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb);
 		}
 
@@ -652,7 +652,7 @@ static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 		skb_push(skb, sizeof *phdr);
 		__skb_queue_tail(&path->queue, skb);
 	} else {
-		++priv->stats.tx_dropped;
+		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
 	}
 
@@ -720,7 +720,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			__skb_queue_tail(&neigh->queue, skb);
 			spin_unlock(&priv->lock);
 		} else {
-			++priv->stats.tx_dropped;
+			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb);
 		}
 	} else {
@@ -746,7 +746,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					   IPOIB_QPN(phdr->hwaddr),
 					   IPOIB_GID_RAW_ARG(phdr->hwaddr + 4));
 				dev_kfree_skb_any(skb);
-				++priv->stats.tx_dropped;
+				++dev->stats.tx_dropped;
 				goto out;
 			}
 
@@ -760,13 +760,6 @@ out:
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *ipoib_get_stats(struct net_device *dev)
-{
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-
-	return &priv->stats;
-}
-
 static void ipoib_timeout(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -867,7 +860,7 @@ void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh)
 	struct sk_buff *skb;
 	*to_ipoib_neigh(neigh->neighbour) = NULL;
 	while ((skb = __skb_dequeue(&neigh->queue))) {
-		++priv->stats.tx_dropped;
+		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
 	}
 	if (ipoib_cm_get(neigh))
@@ -950,7 +943,6 @@ static void ipoib_setup(struct net_device *dev)
 	dev->stop 		 = ipoib_stop;
 	dev->change_mtu 	 = ipoib_change_mtu;
 	dev->hard_start_xmit 	 = ipoib_start_xmit;
-	dev->get_stats 		 = ipoib_get_stats;
 	dev->tx_timeout 	 = ipoib_timeout;
 	dev->hard_header 	 = ipoib_hard_header;
 	dev->set_multicast_list  = ipoib_set_mcast_list;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 94a5709..8b92ea8 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -103,7 +103,7 @@ static void ipoib_mcast_free(struct ipoib_mcast *mcast)
 	}
 
 	spin_lock_irqsave(&priv->tx_lock, flags);
-	priv->stats.tx_dropped += tx_dropped;
+	dev->stats.tx_dropped += tx_dropped;
 	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 	kfree(mcast);
@@ -298,7 +298,7 @@ ipoib_mcast_sendonly_join_complete(int status,
 		/* Flush out any queued packets */
 		spin_lock_irq(&priv->tx_lock);
 		while (!skb_queue_empty(&mcast->pkt_queue)) {
-			++priv->stats.tx_dropped;
+			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb_dequeue(&mcast->pkt_queue));
 		}
 		spin_unlock_irq(&priv->tx_lock);
@@ -653,7 +653,7 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 	if (!test_bit(IPOIB_MCAST_STARTED, &priv->flags)	||
 	    !priv->broadcast					||
 	    !test_bit(IPOIB_MCAST_FLAG_ATTACHED, &priv->broadcast->flags)) {
-		++priv->stats.tx_dropped;
+		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
 		goto unlock;
 	}
@@ -668,7 +668,7 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 		if (!mcast) {
 			ipoib_warn(priv, "unable to allocate memory for "
 				   "multicast structure\n");
-			++priv->stats.tx_dropped;
+			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb);
 			goto out;
 		}
@@ -683,7 +683,7 @@ void ipoib_mcast_send(struct net_device *dev, void *mgid, struct sk_buff *skb)
 		if (skb_queue_len(&mcast->pkt_queue) < IPOIB_MAX_MCAST_QUEUE)
 			skb_queue_tail(&mcast->pkt_queue, skb);
 		else {
-			++priv->stats.tx_dropped;
+			++dev->stats.tx_dropped;
 			dev_kfree_skb_any(skb);
 		}
 
