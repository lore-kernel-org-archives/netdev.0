From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 14/15] netvsc: optimize receive completions
Date: Wed,  3 May 2017 16:01:16 -0700
Message-ID: <20170503230117.20070-15-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33890 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752889AbdECXBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:46 -0400
Received: by mail-pg0-f45.google.com with SMTP id v1so1977999pgv.1
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:46 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle receive completions better:
 * format message directly in ring rather than in different bookkeeping structure
 * eliminate atomic operation
 * get rid of modulus (divide) on ring wrap
 * avoid potential stall if ring gets full
 * don't make ring element opaque

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  16 +++-
 drivers/net/hyperv/netvsc.c       | 168 +++++++++++---------------------------
 drivers/net/hyperv/rndis_filter.c |  11 +--
 3 files changed, 64 insertions(+), 131 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 29555317ca05..a4417100a040 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -650,16 +650,24 @@ struct multi_send_data {
 
 struct recv_comp_data {
 	u64 tid; /* transaction id */
-	u32 status;
+	struct  {
+		struct nvsp_message_header hdr;
+		u32 status;
+	} msg __packed;
 };
 
 struct multi_recv_comp {
-	void *buf; /* queued receive completions */
-	u32 first; /* first data entry */
-	u32 next; /* next entry for writing */
+	struct recv_comp_data *ring;
+	u32 read;
+	u32 write;
 	u32 size; /* number of slots in ring */
 };
 
+static inline bool recv_complete_ring_empty(const struct multi_recv_comp *mrc)
+{
+	return mrc->read == mrc->write;
+}
+
 struct netvsc_stats {
 	u64 packets;
 	u64 bytes;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index eb9f3e517fa5..2938f1a2b765 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -72,8 +72,8 @@ static struct netvsc_device *alloc_net_device(u32 recvslot_max)
 
 	mrc = &net_device->chan_table[0].mrc;
 	mrc->size = recvslot_max;
-	mrc->buf = vzalloc(recvslot_max * sizeof(struct recv_comp_data));
-	if (!mrc->buf) {
+	mrc->ring = vzalloc(recvslot_max * sizeof(struct recv_comp_data));
+	if (!mrc->ring) {
 		kfree(net_device);
 		return NULL;
 	}
@@ -96,7 +96,7 @@ static void free_netvsc_device(struct rcu_head *head)
 	int i;
 
 	for (i = 0; i < VRSS_CHANNEL_MAX; i++)
-		vfree(nvdev->chan_table[i].mrc.buf);
+		vfree(nvdev->chan_table[i].mrc.ring);
 
 	kfree(nvdev);
 }
@@ -974,120 +974,51 @@ int netvsc_send(struct hv_device *device,
 	return ret;
 }
 
-static int netvsc_send_recv_completion(struct vmbus_channel *channel,
-				       u64 transaction_id, u32 status)
-{
-	struct nvsp_message recvcompMessage;
-	int ret;
-
-	recvcompMessage.hdr.msg_type =
-				NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE;
-
-	recvcompMessage.msg.v1_msg.send_rndis_pkt_complete.status = status;
-
-	/* Send the completion */
-	ret = vmbus_sendpacket(channel, &recvcompMessage,
-			       sizeof(struct nvsp_message_header) + sizeof(u32),
-			       transaction_id, VM_PKT_COMP, 0);
-
-	return ret;
-}
-
-static inline void count_recv_comp_slot(struct netvsc_device *nvdev, u16 q_idx,
-					u32 *filled, u32 *avail)
-{
-	struct multi_recv_comp *mrc = &nvdev->chan_table[q_idx].mrc;
-	u32 first = mrc->first;
-	u32 next = mrc->next;
-
-	*filled = (first > next) ? mrc->size - first + next :
-		  next - first;
-
-	*avail = mrc->size - *filled - 1;
-}
 
-/* Read the first filled slot, no change to index */
-static inline struct recv_comp_data *read_recv_comp_slot(struct netvsc_device
-							 *nvdev, u16 q_idx)
+/* Check and send pending recv completions */
+static int send_receive_comp(struct netvsc_device *nvdev,
+			     struct vmbus_channel *channel, u16 q_idx)
 {
 	struct multi_recv_comp *mrc = &nvdev->chan_table[q_idx].mrc;
-	u32 filled, avail;
 
-	if (unlikely(!mrc->buf))
-		return NULL;
+	while (!recv_complete_ring_empty(mrc)) {
+		struct recv_comp_data *rcd = mrc->ring + mrc->read;
+		int ret;
 
-	count_recv_comp_slot(nvdev, q_idx, &filled, &avail);
-	if (!filled)
-		return NULL;
+		ret = vmbus_sendpacket(channel, &rcd->msg, sizeof(rcd->msg),
+				       rcd->tid, VM_PKT_COMP, 0);
 
-	return mrc->buf + mrc->first * sizeof(struct recv_comp_data);
-}
+		/* if ring to host gets full, retry later */
+		if (unlikely(ret != 0))
+			return ret;
 
-/* Put the first filled slot back to available pool */
-static inline void put_recv_comp_slot(struct netvsc_device *nvdev, u16 q_idx)
-{
-	struct multi_recv_comp *mrc = &nvdev->chan_table[q_idx].mrc;
-	int num_recv;
-
-	mrc->first = (mrc->first + 1) % mrc->size;
-
-	num_recv = atomic_dec_return(&nvdev->num_outstanding_recvs);
+		if (++mrc->read == mrc->size)
+			mrc->read = 0;
+	}
 
-	if (nvdev->destroy && num_recv == 0)
+	/* ring now empty */
+	if (unlikely(nvdev->destroy))
 		wake_up(&nvdev->wait_drain);
+	return 0;
 }
 
-/* Check and send pending recv completions */
-static void netvsc_chk_recv_comp(struct netvsc_device *nvdev,
-				 struct vmbus_channel *channel, u16 q_idx)
-{
-	struct recv_comp_data *rcd;
-	int ret;
-
-	while (true) {
-		rcd = read_recv_comp_slot(nvdev, q_idx);
-		if (!rcd)
-			break;
-
-		ret = netvsc_send_recv_completion(channel, rcd->tid,
-						  rcd->status);
-		if (ret)
-			break;
-
-		put_recv_comp_slot(nvdev, q_idx);
-	}
-}
-
-#define NETVSC_RCD_WATERMARK 80
-
 /* Get next available slot */
-static inline struct recv_comp_data *get_recv_comp_slot(
-	struct netvsc_device *nvdev, struct vmbus_channel *channel, u16 q_idx)
+static struct recv_comp_data *
+get_recv_comp_slot(struct netvsc_device *nvdev,
+		   struct vmbus_channel *channel, u16 q_idx)
 {
 	struct multi_recv_comp *mrc = &nvdev->chan_table[q_idx].mrc;
-	u32 filled, avail, next;
 	struct recv_comp_data *rcd;
+	u32 next = mrc->write;
 
-	if (unlikely(!nvdev->recv_section))
-		return NULL;
-
-	if (unlikely(!mrc->buf))
-		return NULL;
-
-	if (atomic_read(&nvdev->num_outstanding_recvs) >
-	    nvdev->recv_section->num_sub_allocs * NETVSC_RCD_WATERMARK / 100)
-		netvsc_chk_recv_comp(nvdev, channel, q_idx);
+	if (++next == mrc->size)
+		next = 0;
 
-	count_recv_comp_slot(nvdev, q_idx, &filled, &avail);
-	if (!avail)
+	if (unlikely(next == mrc->read))
 		return NULL;
 
-	next = mrc->next;
-	rcd = mrc->buf + next * sizeof(struct recv_comp_data);
-	mrc->next = (next + 1) % mrc->size;
-
-	atomic_inc(&nvdev->num_outstanding_recvs);
-
+	rcd = mrc->ring + mrc->write;
+	mrc->write = next;
 	return rcd;
 }
 
@@ -1104,9 +1035,8 @@ static int netvsc_receive(struct net_device *ndev,
 	u16 q_idx = channel->offermsg.offer.sub_channel_index;
 	char *recv_buf = net_device->recv_buf;
 	u32 status = NVSP_STAT_SUCCESS;
-	int i;
-	int count = 0;
-	int ret;
+	struct recv_comp_data *rcd;
+	int i, count = 0;
 
 	/* Make sure this is a valid nvsp packet */
 	if (unlikely(nvsp->hdr.msg_type != NVSP_MSG1_TYPE_SEND_RNDIS_PKT)) {
@@ -1137,25 +1067,16 @@ static int netvsc_receive(struct net_device *ndev,
 					      channel, data, buflen);
 	}
 
-	if (net_device->chan_table[q_idx].mrc.buf) {
-		struct recv_comp_data *rcd;
-
-		rcd = get_recv_comp_slot(net_device, channel, q_idx);
-		if (rcd) {
-			rcd->tid = vmxferpage_packet->d.trans_id;
-			rcd->status = status;
-		} else {
-			netdev_err(ndev, "Recv_comp full buf q:%hd, tid:%llx\n",
-				   q_idx, vmxferpage_packet->d.trans_id);
-		}
+	rcd = get_recv_comp_slot(net_device, channel, q_idx);
+	if (likely(rcd)) {
+		rcd->tid = vmxferpage_packet->d.trans_id;
+		rcd->msg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE;
+		rcd->msg.status = status;
 	} else {
-		ret = netvsc_send_recv_completion(channel,
-						  vmxferpage_packet->d.trans_id,
-						  status);
-		if (ret)
-			netdev_err(ndev, "Recv_comp q:%hd, tid:%llx, err:%d\n",
-				   q_idx, vmxferpage_packet->d.trans_id, ret);
+		netdev_err(ndev, "Recv_comp full buf q:%hd, tid:%llx\n",
+			   q_idx, vmxferpage_packet->d.trans_id);
 	}
+
 	return count;
 }
 
@@ -1258,6 +1179,9 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	struct netvsc_device *net_device = net_device_to_netvsc_device(ndev);
 	int work_done = 0;
 
+	/* If ring has leftover completions flush them now */
+	send_receive_comp(net_device, channel, q_idx);
+
 	/* If starting a new interval */
 	if (!nvchan->desc)
 		nvchan->desc = hv_pkt_iter_first(channel);
@@ -1270,14 +1194,14 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 
 	hv_pkt_iter_close(channel);
 
-	netvsc_chk_recv_comp(net_device, channel, q_idx);
-
-	/* If receive ring was exhausted
+	/* If all receive completions sent to host
+	 * and budget was not used up
 	 * and not doing busy poll
 	 * then re-enable host interrupts
 	 *  and reschedule if ring is not empty.
 	 */
-	if (work_done < budget &&
+	if (send_receive_comp(net_device, channel, q_idx) == 0 &&
+	    work_done < budget &&
 	    napi_complete_done(napi, work_done) &&
 	    hv_end_read(&channel->inbound) != 0) {
 		/* special case if new messages are available */
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 2a89bbd6e42b..1b8ce9bc0ce7 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -901,12 +901,12 @@ static bool netvsc_device_idle(const struct netvsc_device *nvdev)
 {
 	int i;
 
-	if (atomic_read(&nvdev->num_outstanding_recvs) > 0)
-		return false;
-
 	for (i = 0; i < nvdev->num_chn; i++) {
 		const struct netvsc_channel *nvchan = &nvdev->chan_table[i];
 
+		if (!recv_complete_ring_empty(&nvchan->mrc))
+			return false;
+
 		if (atomic_read(&nvchan->queue_sends) > 0)
 			return false;
 	}
@@ -997,8 +997,9 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 
 	nvchan = nvscdev->chan_table + chn_index;
 	nvchan->mrc.size = nvscdev->recv_buf_size / ETH_DATA_LEN + 1;
-	nvchan->mrc.buf = vzalloc(nvchan->mrc.size * sizeof(struct recv_comp_data));
-	if (!nvchan->mrc.buf)
+	nvchan->mrc.ring = vzalloc(nvchan->mrc.size
+				   * sizeof(struct recv_comp_data));
+	if (!nvchan->mrc.ring)
 		return;
 
 	/* Because the device uses NAPI, all the interrupt batching and
-- 
2.11.0
