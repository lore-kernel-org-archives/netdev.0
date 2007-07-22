From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 11/12 -Rev2] IPoIB xmit API addition
Date: Sun, 22 Jul 2007 14:36:49 +0530
Message-ID: <20070722090649.7787.47960.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	hadi@cyberus.ca, kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib_ib.c rev2/drivers/infiniband/ulp/ipoib/ipoib_ib.c
--- org/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-07-20 07:49:28.000000000 +0530
+++ rev2/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2007-07-22 00:08:37.000000000 +0530
@@ -242,8 +242,9 @@ repost:
 static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int i = 0, num_completions;
+	int tx_ring_index = priv->tx_tail & (ipoib_sendq_size - 1);
 	unsigned int wr_id = wc->wr_id;
-	struct ipoib_tx_buf *tx_req;
 	unsigned long flags;
 
 	ipoib_dbg_data(priv, "send completion: id %d, status: %d\n",
@@ -255,23 +256,57 @@ static void ipoib_ib_handle_tx_wc(struct
 		return;
 	}
 
-	tx_req = &priv->tx_ring[wr_id];
+	num_completions = wr_id - tx_ring_index + 1;
+	if (num_completions <= 0)
+		num_completions += ipoib_sendq_size;
 
-	ib_dma_unmap_single(priv->ca, tx_req->mapping,
-			    tx_req->skb->len, DMA_TO_DEVICE);
+	/*
+	 * Handle skbs completion from tx_tail to wr_id. It is possible to
+	 * handle WC's from earlier post_sends (possible multiple) in this
+	 * iteration as we move from tx_tail to wr_id, since if the last
+	 * WR (which is the one which had a completion request) failed to be
+	 * sent for any of those earlier request(s), no completion
+	 * notification is generated for successful WR's of those earlier
+	 * request(s).
+	 */
+	while (1) {
+		/*
+		 * Could use while (i < num_completions), but it is costly
+		 * since in most cases there is 1 completion, and we end up
+		 * doing an extra "index = (index+1) & (ipoib_sendq_size-1)"
+		 */
+		struct ipoib_tx_buf *tx_req = &priv->tx_ring[tx_ring_index];
+
+		if (likely(tx_req->skb)) {
+			ib_dma_unmap_single(priv->ca, tx_req->mapping,
+					    tx_req->skb->len, DMA_TO_DEVICE);
 
-	++priv->stats.tx_packets;
-	priv->stats.tx_bytes += tx_req->skb->len;
+			++priv->stats.tx_packets;
+			priv->stats.tx_bytes += tx_req->skb->len;
 
-	dev_kfree_skb_any(tx_req->skb);
+			dev_kfree_skb_any(tx_req->skb);
+		}
+		/*
+		 * else this skb failed synchronously when posted and was
+		 * freed immediately.
+		 */
+
+		if (++i == num_completions)
+			break;
+
+		/* More WC's to handle */
+		tx_ring_index = (tx_ring_index + 1) & (ipoib_sendq_size - 1);
+	}
 
 	spin_lock_irqsave(&priv->tx_lock, flags);
-	++priv->tx_tail;
+
+	priv->tx_tail += num_completions;
 	if (unlikely(test_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags)) &&
 	    priv->tx_head - priv->tx_tail <= ipoib_sendq_size >> 1) {
 		clear_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags);
 		netif_wake_queue(dev);
 	}
+
 	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 	if (wc->status != IB_WC_SUCCESS &&
@@ -340,78 +375,178 @@ void ipoib_ib_completion(struct ib_cq *c
 	netif_rx_schedule(dev_ptr);
 }
 
-static inline int post_send(struct ipoib_dev_priv *priv,
-			    unsigned int wr_id,
-			    struct ib_ah *address, u32 qpn,
-			    u64 addr, int len)
+/*
+ * post_send : Post WR(s) to the device.
+ *
+ * num_skbs is the number of WR's, 'start_index' is the first slot in
+ * tx_wr[] or tx_sge[]. Note: 'start_index' is normally zero, unless a
+ * previous post_send returned error and we are trying to send the untried
+ * WR's, in which case start_index will point to the first untried WR.
+ *
+ * We also break the WR link before posting so that the driver knows how
+ * many WR's to process, and this is set back after the post.
+ */
+static inline int post_send(struct ipoib_dev_priv *priv, u32 qpn,
+			    int start_index, int num_skbs,
+			    struct ib_send_wr **bad_wr)
 {
-	struct ib_send_wr *bad_wr;
+	int ret;
+	struct ib_send_wr *last_wr, *next_wr;
+
+	last_wr = &priv->tx_wr[start_index + num_skbs - 1];
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
+	ret = ib_post_send(priv->qp, &priv->tx_wr[start_index], bad_wr);
 
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
+ * Map skb & store skb/mapping in tx_req; and details of the WR in tx_wr
+ * to pass to the driver.
+ *
+ * Returns :
+ *	- 0 on successful processing of the skb
+ *	- 1 if the skb was freed.
+ */
+int ipoib_process_skb(struct net_device *dev, struct sk_buff *skb,
+		      struct ipoib_dev_priv *priv, int wr_num,
+		      int tx_ring_index, struct ipoib_ah *address, u32 qpn)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-	struct ipoib_tx_buf *tx_req;
 	u64 addr;
+	struct ipoib_tx_buf *tx_req;
 
 	if (unlikely(skb->len > priv->mcast_mtu + IPOIB_ENCAP_LEN)) {
-		ipoib_warn(priv, "packet len %d (> %d) too long to send, dropping\n",
+		ipoib_warn(priv, "packet len %d (> %d) too long to "
+			   "send, dropping\n",
 			   skb->len, priv->mcast_mtu + IPOIB_ENCAP_LEN);
 		++priv->stats.tx_dropped;
 		++priv->stats.tx_errors;
 		ipoib_cm_skb_too_long(dev, skb, priv->mcast_mtu);
-		return;
+		return 1;
 	}
 
-	ipoib_dbg_data(priv, "sending packet, length=%d address=%p qpn=0x%06x\n",
+	ipoib_dbg_data(priv, "sending packet, length=%d address=%p "
+		       "qpn=0x%06x\n",
 		       skb->len, address, qpn);
 
 	/*
 	 * We put the skb into the tx_ring _before_ we call post_send()
 	 * because it's entirely possible that the completion handler will
-	 * run before we execute anything after the post_send().  That
+	 * run before we execute anything after the post_send(). That
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
+
+	tx_req = &priv->tx_ring[tx_ring_index];
+	tx_req->skb = skb;
 	tx_req->mapping = addr;
+	priv->tx_sge[wr_num].addr = addr;
+	priv->tx_sge[wr_num].length = skb->len;
+	priv->tx_wr[wr_num].wr_id = tx_ring_index;
+	priv->tx_wr[wr_num].wr.ud.remote_qpn = qpn;
+	priv->tx_wr[wr_num].wr.ud.ah = address->ah;
 
-	if (unlikely(post_send(priv, priv->tx_head & (ipoib_sendq_size - 1),
-			       address->ah, qpn, addr, skb->len))) {
-		ipoib_warn(priv, "post_send failed\n");
-		++priv->stats.tx_errors;
-		ib_dma_unmap_single(priv->ca, addr, skb->len, DMA_TO_DEVICE);
-		dev_kfree_skb_any(skb);
-	} else {
-		dev->trans_start = jiffies;
+	return 0;
+}
+
+/*
+ * If an skb is passed to this function, it is the single, unprocessed skb
+ * send case. Otherwise if skb is NULL, it means that all skbs are already
+ * processed and put on the priv->tx_wr,tx_sge,tx_ring, etc.
+ */
+void ipoib_send(struct net_device *dev, struct sk_buff *skb,
+		struct ipoib_ah *address, u32 qpn, int num_skbs)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int start_index = 0;
 
-		address->last_send = priv->tx_head;
-		++priv->tx_head;
+	if (skb && ipoib_process_skb(dev, skb, priv, 0, priv->tx_head &
+				     (ipoib_sendq_size - 1), address, qpn))
+		return;
 
-		if (priv->tx_head - priv->tx_tail == ipoib_sendq_size) {
-			ipoib_dbg(priv, "TX ring full, stopping kernel net queue\n");
-			netif_stop_queue(dev);
-			set_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags);
+	/* Send out all the skb's in one post */
+	while (num_skbs) {
+		struct ib_send_wr *bad_wr;
+
+		if (unlikely((post_send(priv, qpn, start_index, num_skbs,
+					&bad_wr)))) {
+			int done;
+
+			/*
+			 * Better error handling can be done here, like free
+			 * all untried skbs if err == -ENOMEM. However at this
+			 * time, we re-try all the skbs, all of which will
+			 * likely fail anyway (unless device finished sending
+			 * some out in the meantime). This is not a regression
+			 * since the earlier code is not doing this either.
+			 */
+			ipoib_warn(priv, "post_send failed\n");
+
+			/* Get #WR's that finished successfully */
+			done = bad_wr - &priv->tx_wr[start_index];
+
+			/* Handle 1 error */
+			priv->stats.tx_errors++;
+			ib_dma_unmap_single(priv->ca,
+				priv->tx_sge[start_index + done].addr,
+				priv->tx_sge[start_index + done].length,
+				DMA_TO_DEVICE);
+
+			/* Handle 'n' successes */
+			if (done) {
+				dev->trans_start = jiffies;
+				address->last_send = priv->tx_head;
+			}
+
+			/* Free failed WR & reset for WC handler to recognize */
+			dev_kfree_skb_any(priv->tx_ring[bad_wr->wr_id].skb);
+			priv->tx_ring[bad_wr->wr_id].skb = NULL;
+
+			/* Move head to first untried WR */
+			priv->tx_head += (done + 1);
+				/* + 1 for WR that was tried & failed */
+
+			/* Get count of skbs that were not tried */
+			num_skbs -= (done + 1);
+
+			/* Get start index for next iteration */
+			start_index += (done + 1);
+		} else {
+			dev->trans_start = jiffies;
+
+			address->last_send = priv->tx_head;
+			priv->tx_head += num_skbs;
+			num_skbs = 0;
 		}
 	}
+
+	if (unlikely(priv->tx_head - priv->tx_tail == ipoib_sendq_size)) {
+		/*
+		 * Not accurate as some intermediate slots could have been
+		 * freed on error, but no harm - only queue stopped earlier.
+		 */
+		ipoib_dbg(priv, "TX ring full, stopping kernel net queue\n");
+		netif_stop_queue(dev);
+		set_bit(IPOIB_FLAG_NETIF_STOPPED, &priv->flags);
+	}
 }
 
 static void __ipoib_reap_ah(struct net_device *dev)
