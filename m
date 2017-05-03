From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 02/15] vmbus: fix unnecessary signal events as result of NAPI
Date: Wed,  3 May 2017 16:01:04 -0700
Message-ID: <20170503230117.20070-3-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35585 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbdECXBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:23 -0400
Received: by mail-pg0-f46.google.com with SMTP id o3so1960517pgn.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:22 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With NAPI, the ring buffer is processed in incremental steps so
the read index needs to be updated after each section. But this can
lead to lots of bogus vmbus signal events which hurts performance.

This patch rearranges the host incoming signalling logic to be
more complete and eliminate unnecessary ring buffer bookkeeping.
The new code also looks at mask flag from host to avoid signaling
even more.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/hv/ring_buffer.c    | 59 ++++++++++++++++++++++++++++++++------
 drivers/net/hyperv/netvsc.c | 13 ++++++---
 include/linux/hyperv.h      | 70 +--------------------------------------------
 3 files changed, 60 insertions(+), 82 deletions(-)

diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
index 4bffeae6990b..3fba9490a1bb 100644
--- a/drivers/hv/ring_buffer.c
+++ b/drivers/hv/ring_buffer.c
@@ -361,9 +361,6 @@ struct vmpacket_descriptor *hv_pkt_iter_first(struct vmbus_channel *channel)
 {
 	struct hv_ring_buffer_info *rbi = &channel->inbound;
 
-	/* set state for later hv_signal_on_read() */
-	rbi->cached_read_index = rbi->ring_buffer->read_index;
-
 	if (hv_pkt_iter_avail(rbi) < sizeof(struct vmpacket_descriptor))
 		return NULL;
 
@@ -390,20 +387,27 @@ __hv_pkt_iter_next(struct vmbus_channel *channel,
 	if (rbi->priv_read_index >= dsize)
 		rbi->priv_read_index -= dsize;
 
-	/* more data? */
-	if (hv_pkt_iter_avail(rbi) < sizeof(struct vmpacket_descriptor))
-		return NULL;
-	else
-		return hv_get_ring_buffer(rbi) + rbi->priv_read_index;
+	return hv_pkt_iter_first(channel);
 }
 EXPORT_SYMBOL_GPL(__hv_pkt_iter_next);
 
 /*
  * Update host ring buffer after iterating over packets.
+ *
+ * Avoid unnecessary signaling of the host by making sure that all
+ * data is read, and the host has not masked off the interrupt.
+ *
+ * In addition, in Windows 8 or later there is an extension for the
+ * host to indicate how much space needs to be available before
+ * signaling. The hos sets pending_send_sz to the number of bytes
+ * that it is waiting to send.
  */
 void hv_pkt_iter_close(struct vmbus_channel *channel)
 {
 	struct hv_ring_buffer_info *rbi = &channel->inbound;
+	u32 orig_write_sz;
+
+	orig_write_sz = hv_get_bytes_to_write(rbi);
 
 	/*
 	 * Make sure all reads are done before we update the read index since
@@ -411,8 +415,45 @@ void hv_pkt_iter_close(struct vmbus_channel *channel)
 	 * is updated.
 	 */
 	virt_rmb();
+
+	/* Update the position where ring buffer has been read from */
 	rbi->ring_buffer->read_index = rbi->priv_read_index;
 
-	hv_signal_on_read(channel);
+	/* If more data is available then no need to signal */
+	if (hv_get_bytes_to_read(rbi))
+		return;
+
+	/*
+	 * If the reading of the pend_sz were to be reordered and read
+	 * before we commit the new read index.  Then we could have if
+	 * the host were to set the pending_sz after we have already
+	 * sampled pending_sz.
+	 */
+	virt_wmb();
+
+	/* If host has disabled notifications then skip */
+	if (rbi->ring_buffer->interrupt_mask)
+		return;
+
+	/* If host supports pending send size feature
+	 * then don't signal until that amount of space is available.
+	 */
+	if (rbi->ring_buffer->feature_bits.feat_pending_send_sz) {
+		u32 pending_sz = READ_ONCE(rbi->ring_buffer->pending_send_sz);
+
+		/*
+		 * If there was space before we began iteration, then
+		 * host was not blocked. If pending_sz is zero then
+		 * host has nothing pending.
+		 */
+		if (orig_write_sz > pending_sz)
+			return;
+
+		/* If pending write will not fit, don't give false hope. */
+		if (hv_get_bytes_to_write(rbi) < pending_sz)
+			return;
+	}
+
+	vmbus_setevent(channel);
 }
 EXPORT_SYMBOL_GPL(hv_pkt_iter_close);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 15749d359e60..8108e119d8a5 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1251,9 +1251,13 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	while (nvchan->desc && work_done < budget) {
 		work_done += netvsc_process_raw_pkt(device, channel, net_device,
 						    ndev, nvchan->desc, budget);
-		nvchan->desc = hv_pkt_iter_next(channel, nvchan->desc);
+		nvchan->desc = __hv_pkt_iter_next(channel, nvchan->desc);
 	}
 
+	hv_pkt_iter_close(channel);
+
+	netvsc_chk_recv_comp(net_device, channel, q_idx);
+
 	/* If receive ring was exhausted
 	 * and not doing busy poll
 	 * then re-enable host interrupts
@@ -1261,10 +1265,11 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	 */
 	if (work_done < budget &&
 	    napi_complete_done(napi, work_done) &&
-	    hv_end_read(&channel->inbound) != 0)
+	    hv_end_read(&channel->inbound) != 0) {
+		/* special case if new messages are available */
+		hv_begin_read(&channel->inbound);
 		napi_reschedule(napi);
-
-	netvsc_chk_recv_comp(net_device, channel, q_idx);
+	}
 
 	/* Driver may overshoot since multiple packets per descriptor */
 	return min(work_done, budget);
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 0c170a3f0d8b..545feabfe70b 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -124,10 +124,7 @@ struct hv_ring_buffer_info {
 	spinlock_t ring_lock;
 
 	u32 ring_datasize;		/* < ring_size */
-	u32 ring_data_startoffset;
-	u32 priv_write_index;
-	u32 priv_read_index;
-	u32 cached_read_index;
+	u32 priv_read_index;		/* read cursor */
 };
 
 /*
@@ -180,19 +177,6 @@ static inline u32 hv_get_bytes_to_write(const struct hv_ring_buffer_info *rbi)
 	return write;
 }
 
-static inline u32 hv_get_cached_bytes_to_write(
-	const struct hv_ring_buffer_info *rbi)
-{
-	u32 read_loc, write_loc, dsize, write;
-
-	dsize = rbi->ring_datasize;
-	read_loc = rbi->cached_read_index;
-	write_loc = rbi->ring_buffer->write_index;
-
-	write = write_loc >= read_loc ? dsize - (write_loc - read_loc) :
-		read_loc - write_loc;
-	return write;
-}
 /*
  * VMBUS version is 32 bit entity broken up into
  * two 16 bit quantities: major_number. minor_number.
@@ -1456,58 +1440,6 @@ hv_get_ring_buffer(const struct hv_ring_buffer_info *ring_info)
 {
 	return ring_info->ring_buffer->buffer;
 }
-
-/*
- * To optimize the flow management on the send-side,
- * when the sender is blocked because of lack of
- * sufficient space in the ring buffer, potential the
- * consumer of the ring buffer can signal the producer.
- * This is controlled by the following parameters:
- *
- * 1. pending_send_sz: This is the size in bytes that the
- *    producer is trying to send.
- * 2. The feature bit feat_pending_send_sz set to indicate if
- *    the consumer of the ring will signal when the ring
- *    state transitions from being full to a state where
- *    there is room for the producer to send the pending packet.
- */
-
-static inline  void hv_signal_on_read(struct vmbus_channel *channel)
-{
-	u32 cur_write_sz, cached_write_sz;
-	u32 pending_sz;
-	struct hv_ring_buffer_info *rbi = &channel->inbound;
-
-	/*
-	 * Issue a full memory barrier before making the signaling decision.
-	 * Here is the reason for having this barrier:
-	 * If the reading of the pend_sz (in this function)
-	 * were to be reordered and read before we commit the new read
-	 * index (in the calling function)  we could
-	 * have a problem. If the host were to set the pending_sz after we
-	 * have sampled pending_sz and go to sleep before we commit the
-	 * read index, we could miss sending the interrupt. Issue a full
-	 * memory barrier to address this.
-	 */
-	virt_mb();
-
-	pending_sz = READ_ONCE(rbi->ring_buffer->pending_send_sz);
-	/* If the other end is not blocked on write don't bother. */
-	if (pending_sz == 0)
-		return;
-
-	cur_write_sz = hv_get_bytes_to_write(rbi);
-
-	if (cur_write_sz < pending_sz)
-		return;
-
-	cached_write_sz = hv_get_cached_bytes_to_write(rbi);
-	if (cached_write_sz < pending_sz)
-		vmbus_setevent(channel);
-
-	return;
-}
-
 /*
  * Mask off host interrupt callback notifications
  */
-- 
2.11.0
