From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 8/10 REV5] [IPoIB] Post and work completion handler changes
Date: Fri, 14 Sep 2007 14:33:58 +0530
Message-ID: <20070914090353.17589.26052.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:47681 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbXINJCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 05:02:04 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E924oJ023412
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:04 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E923AE680834
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:03 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E920aL011251
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:03 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPoIB internal post and work completion handler changes.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib_ib.c |  212 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 168 insertions(+), 44 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_ib.c new/drivers/infiniband/ulp/ipoib/ipoib_ib.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-13 09:10:58.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-09-14 10:25:36.000000000 +0530
@@ -242,6 +242,8 @@ repost:
 static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int num_completions, to_process;
+	unsigned int tx_ring_index;
 	unsigned int wr_id = wc->wr_id;
 	struct ipoib_tx_buf *tx_req;
 	unsigned long flags;
@@ -255,18 +257,51 @@ static void ipoib_ib_handle_tx_wc(struct
 		return;
 	}
 
-	tx_req = &priv->tx_ring[wr_id];
+	/* Get first WC to process (no one can update tx_tail at this time) */
+	tx_ring_index = priv->tx_tail & (ipoib_sendq_size - 1);
 
-	ib_dma_unmap_single(priv->ca, tx_req->mapping,
-			    tx_req->skb->len, DMA_TO_DEVICE);
+	/* Find number of WC's to process */
+	num_completions = wr_id - tx_ring_index + 1;
+	if (unlikely(num_completions <= 0))
+		num_completions += ipoib_sendq_size;
+	to_process = num_completions;
 
-	++priv->stats.tx_packets;
-	priv->stats.tx_bytes += tx_req->skb->len;
+	/*
+	 * Handle WC's from earlier (possibly multiple) post_sends in this
+	 * iteration as we move from tx_tail to wr_id, since if the last WR
+	 * (which is the one which requested completion notification) failed
+	 * to be sent for any of those earlier request(s), no completion
+	 * notification is generated for successful WR's of those earlier
+	 * request(s). Use a infinite loop to handle the regular case of
+	 * one skb processing faster.
+	 */
+	tx_req = &priv->tx_ring[tx_ring_index];
+	while (1) {
+		if (likely(tx_req->skb)) {
+			ib_dma_unmap_single(priv->ca, tx_req->mapping,
+					    tx_req->skb->len, DMA_TO_DEVICE);
+
+			++priv->stats.tx_packets;
+			priv->stats.tx_bytes += tx_req->skb->len;
+
+			dev_kfree_skb_any(tx_req->skb);
+		}
+		/*
+		 * else this skb failed synchronously when posted and was
+		 * freed immediately.
+		 */
+
+		if (--to_process == 0)
+			break;
 
-	dev_kfree_skb_any(tx_req->skb);
+		if (likely(++tx_ring_index != ipoib_sendq_size))
+			tx_req++;
+		else
+			tx_req = &priv->tx_ring[0];
+	}
 
 	spin_lock_irqsave(&priv->tx_lock, flags);
-	++priv->tx_tail;
+	priv->tx_tail += num_completions;
 	if (unlikely(test_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags)) &&
 	    priv->tx_head - priv->tx_tail <= ipoib_sendq_size >> 1) {
 		clear_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags);
@@ -335,29 +370,57 @@ void ipoib_ib_completion(struct ib_cq *c
 	netif_rx_schedule(dev, &priv->napi);
 }
 
-static inline int post_send(struct ipoib_dev_priv *priv,
-			    unsigned int wr_id,
-			    struct ib_ah *address, u32 qpn,
-			    u64 addr, int len)
+/*
+ * post_send : Post WR(s) to the device.
+ *
+ * num_skbs is the number of WR's, first_wr is the first slot in tx_wr[] (or
+ * tx_sge[]). first_wr is normally zero unless a previous post_send returned
+ * error and we are trying to post the untried WR's, in which case first_wr
+ * is the index to the first untried WR.
+ *
+ * Break the WR link before posting so that provider knows how many WR's to
+ * process, and this is set back after the post.
+ */
+static inline int post_send(struct ipoib_dev_priv *priv, u32 qpn,
+			    int first_wr, int num_skbs,
+			    struct ib_send_wr **bad_wr)
 {
-	struct ib_send_wr *bad_wr;
+	int ret;
+	struct ib_send_wr *last_wr, *next_wr;
+
+	last_wr = &priv->tx_wr[first_wr + num_skbs - 1];
+
+	/* Set Completion Notification for last WR */
+	last_wr->send_flags = IB_SEND_SIGNALED;
 
-	priv->tx_sge.addr             = addr;
-	priv->tx_sge.length           = len;
+	/* Terminate the last WR */
+	next_wr = last_wr->next;
+	last_wr->next = NULL;
 
-	priv->tx_wr.wr_id 	      = wr_id;
-	priv->tx_wr.wr.ud.remote_qpn  = qpn;
-	priv->tx_wr.wr.ud.ah 	      = address;
+	/* Send all the WR's in one doorbell */
+	ret = ib_post_send(priv->qp, &priv->tx_wr[first_wr], bad_wr);
 
-	return ib_post_send(priv->qp, &priv->tx_wr, &bad_wr);
+	/* Restore send_flags & WR chain */
+	last_wr->send_flags = 0;
+	last_wr->next = next_wr;
+
+	return ret;
 }
 
-void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 qpn)
+/*
+ * Map skb & store skb/mapping in tx_ring; and details of the WR in tx_wr
+ * to pass to the provider.
+ *
+ * Returns:
+ *	1: Error and the skb is freed.
+ *	0 skb processed successfully.
+ */
+int ipoib_process_skb(struct net_device *dev, struct sk_buff *skb,
+		      struct ipoib_dev_priv *priv, struct ipoib_ah *address,
+		      u32 qpn, int wr_num)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-	struct ipoib_tx_buf *tx_req;
 	u64 addr;
+	unsigned int tx_ring_index;
 
 	if (unlikely(skb->len > priv->mcast_mtu + IPOIB_ENCAP_LEN)) {
 		ipoib_warn(priv, "packet len %d (> %d) too long to send, dropping\n",
@@ -365,7 +428,7 @@ void ipoib_send(struct net_device *dev, 
 		++priv->stats.tx_dropped;
 		++priv->stats.tx_errors;
 		ipoib_cm_skb_too_long(dev, skb, priv->mcast_mtu);
-		return;
+		return 1;
 	}
 
 	ipoib_dbg_data(priv, "sending packet, length=%d address=%p qpn=0x%06x\n",
@@ -378,35 +441,96 @@ void ipoib_send(struct net_device *dev, 
 	 * means we have to make sure everything is properly recorded and
 	 * our state is consistent before we call post_send().
 	 */
-	tx_req = &priv->tx_ring[priv->tx_head & (ipoib_sendq_size - 1)];
-	tx_req->skb = skb;
-	addr = ib_dma_map_single(priv->ca, skb->data, skb->len,
-				 DMA_TO_DEVICE);
+	addr = ib_dma_map_single(priv->ca, skb->data, skb->len, DMA_TO_DEVICE);
 	if (unlikely(ib_dma_mapping_error(priv->ca, addr))) {
 		++priv->stats.tx_errors;
 		dev_kfree_skb_any(skb);
-		return;
+		return 1;
 	}
-	tx_req->mapping = addr;
 
-	if (unlikely(post_send(priv, priv->tx_head & (ipoib_sendq_size - 1),
-			       address->ah, qpn, addr, skb->len))) {
-		ipoib_warn(priv, "post_send failed\n");
-		++priv->stats.tx_errors;
-		ib_dma_unmap_single(priv->ca, addr, skb->len, DMA_TO_DEVICE);
-		dev_kfree_skb_any(skb);
-	} else {
-		dev->trans_start = jiffies;
+	tx_ring_index = priv->tx_head & (ipoib_sendq_size - 1);
+
+	/* Save till completion handler executes */
+	priv->tx_ring[tx_ring_index].skb = skb;
+	priv->tx_ring[tx_ring_index].mapping = addr;
+
+	/* Set WR values for the provider to use */
+	priv->tx_sge[wr_num].addr = addr;
+	priv->tx_sge[wr_num].length = skb->len;
+
+	priv->tx_wr[wr_num].wr_id = tx_ring_index;
+	priv->tx_wr[wr_num].wr.ud.remote_qpn = qpn;
+	priv->tx_wr[wr_num].wr.ud.ah = address->ah;
+
+	priv->tx_head++;
+
+	if (unlikely(priv->tx_head - priv->tx_tail == ipoib_sendq_size)) {
+		ipoib_dbg(priv, "TX ring full, stopping kernel net queue\n");
+		netif_stop_queue(dev);
+		set_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags);
+	}
 
-		address->last_send = priv->tx_head;
-		++priv->tx_head;
+	return 0;
+}
 
-		if (priv->tx_head - priv->tx_tail == ipoib_sendq_size) {
-			ipoib_dbg(priv, "TX ring full, stopping kernel net queue\n");
-			netif_stop_queue(dev);
-			set_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags);
+/*
+ * Send num_skbs to the device. If an skb is passed to this function, it is
+ * single, unprocessed skb send case; otherwise it means that all skbs are
+ * already processed and put on priv->tx_wr,tx_sge,tx_ring, etc.
+ */
+void ipoib_send(struct net_device *dev, struct sk_buff *skb,
+		struct ipoib_ah *address, u32 qpn, int num_skbs)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int first_wr = 0;
+
+	if (skb && ipoib_process_skb(dev, skb, priv, address, qpn, 0))
+		return;
+
+	/* Send all skb's in one post */
+	do {
+		struct ib_send_wr *bad_wr;
+
+		if (unlikely((post_send(priv, qpn, first_wr, num_skbs,
+					&bad_wr)))) {
+			int done;
+
+			ipoib_warn(priv, "post_send failed\n");
+
+			/* Get number of WR's that finished successfully */
+			done = bad_wr - &priv->tx_wr[first_wr];
+
+			/* Handle 1 error */
+			priv->stats.tx_errors++;
+			ib_dma_unmap_single(priv->ca,
+				priv->tx_sge[first_wr + done].addr,
+				priv->tx_sge[first_wr + done].length,
+				DMA_TO_DEVICE);
+
+			/* Free failed WR & reset for WC handler to recognize */
+			dev_kfree_skb_any(priv->tx_ring[bad_wr->wr_id].skb);
+			priv->tx_ring[bad_wr->wr_id].skb = NULL;
+
+			/* Handle 'n' successes */
+			if (done) {
+				dev->trans_start = jiffies;
+				address->last_send = priv->tx_head - (num_skbs -
+								      done) - 1;
+			}
+
+			/* Get count of skbs that were not tried */
+			num_skbs -= (done + 1);
+				/* + 1 for WR that was tried & failed */
+
+			/* Get start index for next iteration */
+			first_wr += (done + 1);
+		} else {
+			dev->trans_start = jiffies;
+
+			address->last_send = priv->tx_head - 1;
+			num_skbs = 0;
 		}
-	}
+	} while (num_skbs);
 }
 
 static void __ipoib_reap_ah(struct net_device *dev)
