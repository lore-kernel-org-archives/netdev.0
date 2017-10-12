From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next V7 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion and
 allocation
Date: Thu, 12 Oct 2017 14:26:59 +0200
Message-ID: <150781121989.9409.14542782810603037426.stgit@firesoul>
References: <150781116384.9409.2491501775270038284.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Jesper Dangaard Brouer <brouer@redhat.com>, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9293 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756532AbdJLM1B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Oct 2017 08:27:01 -0400
In-Reply-To: <150781116384.9409.2491501775270038284.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes cpumap functional, by adding SKB allocation and
invoking the network stack on the dequeuing CPU.

For constructing the SKB on the remote CPU, the xdp_buff in converted
into a struct xdp_pkt, and it mapped into the top headroom of the
packet, to avoid allocating separate mem.  For now, struct xdp_pkt is
just a cpumap internal data structure, with info carried between
enqueue to dequeue.

If a driver doesn't have enough headroom it is simply dropped, with
return code -EOVERFLOW.  This will be picked up the xdp tracepoint
infrastructure, to allow users to catch this.

V2: take into account xdp->data_meta

V4:
 - Drop busypoll tricks, keeping it more simple.
 - Skip RPS and Generic-XDP-recursive-reinjection, suggested by Alexei

V5: correct RCU read protection around __netif_receive_skb_core.

V6: Setting TASK_RUNNING vs TASK_INTERRUPTIBLE based on talk with Rik van Riel

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/netdevice.h |    1 
 kernel/bpf/cpumap.c       |  152 ++++++++++++++++++++++++++++++++++++++-------
 net/core/dev.c            |   27 ++++++++
 3 files changed, 158 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 31bb3010c69b..bf014afcb914 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3260,6 +3260,7 @@ int do_xdp_generic(struct bpf_prog *xdp_prog, struct sk_buff *skb);
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb(struct sk_buff *skb);
+int netif_receive_skb_core(struct sk_buff *skb);
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
diff --git a/kernel/bpf/cpumap.c b/kernel/bpf/cpumap.c
index bc989a9ae049..cae73d95be00 100644
--- a/kernel/bpf/cpumap.c
+++ b/kernel/bpf/cpumap.c
@@ -25,6 +25,9 @@
 #include <linux/kthread.h>
 #include <linux/capability.h>
 
+#include <linux/netdevice.h>   /* netif_receive_skb_core */
+#include <linux/etherdevice.h> /* eth_type_trans */
+
 /* General idea: XDP packets getting XDP redirected to another CPU,
  * will maximum be stored/queued for one driver ->poll() call.  It is
  * guaranteed that setting flush bit and flush operation happen on
@@ -181,6 +184,92 @@ static void cpu_map_kthread_stop(struct work_struct *work)
 	kthread_stop(rcpu->kthread);
 }
 
+/* For now, xdp_pkt is a cpumap internal data structure, with info
+ * carried between enqueue to dequeue. It is mapped into the top
+ * headroom of the packet, to avoid allocating separate mem.
+ */
+struct xdp_pkt {
+	void *data;
+	u16 len;
+	u16 headroom;
+	u16 metasize;
+	struct net_device *dev_rx;
+};
+
+/* Convert xdp_buff to xdp_pkt */
+static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
+{
+	struct xdp_pkt *xdp_pkt;
+	int metasize;
+	int headroom;
+
+	/* Assure headroom is available for storing info */
+	headroom = xdp->data - xdp->data_hard_start;
+	metasize = xdp->data - xdp->data_meta;
+	metasize = metasize > 0 ? metasize : 0;
+	if ((headroom - metasize) < sizeof(*xdp_pkt))
+		return NULL;
+
+	/* Store info in top of packet */
+	xdp_pkt = xdp->data_hard_start;
+
+	xdp_pkt->data = xdp->data;
+	xdp_pkt->len  = xdp->data_end - xdp->data;
+	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
+	xdp_pkt->metasize = metasize;
+
+	return xdp_pkt;
+}
+
+struct sk_buff *cpu_map_build_skb(struct bpf_cpu_map_entry *rcpu,
+				  struct xdp_pkt *xdp_pkt)
+{
+	unsigned int frame_size;
+	void *pkt_data_start;
+	struct sk_buff *skb;
+
+	/* build_skb need to place skb_shared_info after SKB end, and
+	 * also want to know the memory "truesize".  Thus, need to
+	 * know the memory frame size backing xdp_buff.
+	 *
+	 * XDP was designed to have PAGE_SIZE frames, but this
+	 * assumption is not longer true with ixgbe and i40e.  It
+	 * would be preferred to set frame_size to 2048 or 4096
+	 * depending on the driver.
+	 *   frame_size = 2048;
+	 *   frame_len  = frame_size - sizeof(*xdp_pkt);
+	 *
+	 * Instead, with info avail, skb_shared_info in placed after
+	 * packet len.  This, unfortunately fakes the truesize.
+	 * Another disadvantage of this approach, the skb_shared_info
+	 * is not at a fixed memory location, with mixed length
+	 * packets, which is bad for cache-line hotness.
+	 */
+	frame_size = SKB_DATA_ALIGN(xdp_pkt->len) + xdp_pkt->headroom +
+		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	pkt_data_start = xdp_pkt->data - xdp_pkt->headroom;
+	skb = build_skb(pkt_data_start, frame_size);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, xdp_pkt->headroom);
+	__skb_put(skb, xdp_pkt->len);
+	if (xdp_pkt->metasize)
+		skb_metadata_set(skb, xdp_pkt->metasize);
+
+	/* Essential SKB info: protocol and skb->dev */
+	skb->protocol = eth_type_trans(skb, xdp_pkt->dev_rx);
+
+	/* Optional SKB info, currently missing:
+	 * - HW checksum info		(skb->ip_summed)
+	 * - HW RX hash			(skb_set_hash)
+	 * - RX ring dev queue index	(skb_record_rx_queue)
+	 */
+
+	return skb;
+}
+
 static int cpu_map_kthread_run(void *data)
 {
 	struct bpf_cpu_map_entry *rcpu = data;
@@ -193,15 +282,45 @@ static int cpu_map_kthread_run(void *data)
 	 * kthread_stop signal until queue is empty.
 	 */
 	while (!kthread_should_stop() || !__ptr_ring_empty(rcpu->queue)) {
+		unsigned int processed = 0, drops = 0;
 		struct xdp_pkt *xdp_pkt;
 
-		schedule();
-		/* Do work */
-		while ((xdp_pkt = ptr_ring_consume(rcpu->queue))) {
-			/* For now just "refcnt-free" */
-			page_frag_free(xdp_pkt);
+		/* Release CPU reschedule checks */
+		if (__ptr_ring_empty(rcpu->queue)) {
+			__set_current_state(TASK_INTERRUPTIBLE);
+			schedule();
+		} else {
+			cond_resched();
+		}
+		__set_current_state(TASK_RUNNING);
+
+		/* Process packets in rcpu->queue */
+		local_bh_disable();
+		/*
+		 * The bpf_cpu_map_entry is single consumer, with this
+		 * kthread CPU pinned. Lockless access to ptr_ring
+		 * consume side valid as no-resize allowed of queue.
+		 */
+		while ((xdp_pkt = __ptr_ring_consume(rcpu->queue))) {
+			struct sk_buff *skb;
+			int ret;
+
+			skb = cpu_map_build_skb(rcpu, xdp_pkt);
+			if (!skb) {
+				page_frag_free(xdp_pkt);
+				continue;
+			}
+
+			/* Inject into network stack */
+			ret = netif_receive_skb_core(skb);
+			if (ret == NET_RX_DROP)
+				drops++;
+
+			/* Limit BH-disable period */
+			if (++processed == 8)
+				break;
 		}
-		__set_current_state(TASK_INTERRUPTIBLE);
+		local_bh_enable(); /* resched point, may call do_softirq() */
 	}
 	__set_current_state(TASK_RUNNING);
 
@@ -491,13 +610,6 @@ static int bq_flush_to_queue(struct bpf_cpu_map_entry *rcpu,
 	return 0;
 }
 
-/* Notice: Will change in later patch */
-struct xdp_pkt {
-	void *data;
-	u16 len;
-	u16 headroom;
-};
-
 /* Runs under RCU-read-side, plus in softirq under NAPI protection.
  * Thus, safe percpu variable access.
  */
@@ -525,17 +637,13 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
 		    struct net_device *dev_rx)
 {
 	struct xdp_pkt *xdp_pkt;
-	int headroom;
 
-	/* For now this is just used as a void pointer to data_hard_start.
-	 * Followup patch will generalize this.
-	 */
-	xdp_pkt = xdp->data_hard_start;
+	xdp_pkt = convert_to_xdp_pkt(xdp);
+	if (!xdp_pkt)
+		return -EOVERFLOW;
 
-	/* Fake writing into xdp_pkt->data to measure overhead */
-	headroom = xdp->data - xdp->data_hard_start;
-	if (headroom < sizeof(*xdp_pkt))
-		xdp_pkt->data = xdp->data;
+	/* Info needed when constructing SKB on remote CPU */
+	xdp_pkt->dev_rx = dev_rx;
 
 	bq_enqueue(rcpu, xdp_pkt);
 	return 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index fcddccb6be41..36bb68f3a2c7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4491,6 +4491,33 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 	return ret;
 }
 
+/**
+ *	netif_receive_skb_core - special purpose version of netif_receive_skb
+ *	@skb: buffer to process
+ *
+ *	More direct receive version of netif_receive_skb().  It should
+ *	only be used by callers that have a need to skip RPS and Generic XDP.
+ *	Caller must also take care of handling if (page_is_)pfmemalloc.
+ *
+ *	This function may only be called from softirq context and interrupts
+ *	should be enabled.
+ *
+ *	Return values (usually ignored):
+ *	NET_RX_SUCCESS: no congestion
+ *	NET_RX_DROP: packet was dropped
+ */
+int netif_receive_skb_core(struct sk_buff *skb)
+{
+	int ret;
+
+	rcu_read_lock();
+	ret = __netif_receive_skb_core(skb, false);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(netif_receive_skb_core);
+
 static int __netif_receive_skb(struct sk_buff *skb)
 {
 	int ret;
