From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 21:19:13 -0700
Message-ID: <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
	 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47299 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaI2ETQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 00:19:16 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so776496pab.36
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 21:19:15 -0700 (PDT)
In-Reply-To: <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

First I implemented skb->xmit_more support, and pktgen throughput
went from ~5Mpps to ~10Mpps.

Then, looking closely at this driver I found false sharing problems that
should be addressed by this patch, as my pktgen now reaches 14.7 Mpps
on a single TX queue, with a burst factor of 8.

So this patch in a whole permits to improve raw performance on a single
TX queue from about 5 Mpps to 14.9 Mpps.

Note that if packets are below the inline_thold threshold (104 bytes),
driver copies packets content into tx descriptor, and throughput
is lowered to ~7.5 Mpps :
->      We might reconsider inline strategy in a followup patch.

I could split this patch into multiple components, but I prefer not
spend days on this work.

Lets instead list all changes I did :

1) align struct mlx4_en_tx_info to a cache line

2) add frag0_dma/frag0_byte_count into mlx4_en_tx_info to avoid a cache
   line miss in TX completion for frames having one dma element.
   (We avoid reading back the tx descriptor)
   Note this could be extended to 2/3 dma elements later,
   as we have free room in mlx4_en_tx_info

3) reorganize struct mlx4_en_tx_ring to have 
   3.1 - One cache line containing last_nr_txbb & cons & wake_queue,
     used by tx completion.
   3.2 - One cache line containing fields dirtied by mlx4_en_xmit()  
   3.3 - Following part is read mostly and shared by cpus.

4) struct mlx4_bf @offset field reduced to unsigned int to save space
 
5) doorbell_qpn is stored in the cpu_to_be32() way to avoid bswap() in
   fast path.

6) mdev->mr.key stored in ring->mr_key to also avoid bswap() and access
   to cold cache line.

7) mlx4_en_free_tx_desc() no longer accesses skb_shinfo(). We use a new
   nr_maps fields in mlx4_en_tx_info to avoid 2 or 3 cache misses.

8) mlx4_en_free_tx_desc() uses a prefetchw(&skb->users) to speed up
   consume_skb()

9) mlx4_en_process_tx_cq() carefully fetches and writes
   ring->last_nr_txbb & ring->cons only one time to avoid false sharing

10) mlx4_en_xmit() reads ring->cons once, and ahead of time to avoid
    stalls.

11) prefetchw(&ring->tx_queue->dql) to speed up BQL update

12) properly clears tx_info->ts_requested :
    This field was never cleared.

13) remove false sharing on prot_stats.tso_packets 

14) reorganize code to call is_inline() once, so compiler can inline it.

15) rename @i variable to @i_frag to avoid confusion, as the
    "goto tx_drop_unmap;" relied on this @i variable.
 
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: prot_stats.tso_packets false sharing
    wake_queue moved into first cache line
    Missing <linux/prefetch.h>
    tx_info allocated with kmalloc() instead of vmalloc()
    A bug in mlx4_en_free_tx_desc() was fixed.
    xmit_more part was already merged by David.

 drivers/net/ethernet/mellanox/mlx4/en_port.c |   15 
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  327 ++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   90 ++--
 include/linux/mlx4/device.h                  |    2 
 4 files changed, 254 insertions(+), 180 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index c2cfb05e7290..132805799fca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -150,14 +150,17 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.tx_chksum_offload = 0;
 	priv->port_stats.queue_stopped = 0;
 	priv->port_stats.wake_queue = 0;
+	priv->port_stats.tso_packets = 0;
 
 	for (i = 0; i < priv->tx_ring_num; i++) {
-		stats->tx_packets += priv->tx_ring[i]->packets;
-		stats->tx_bytes += priv->tx_ring[i]->bytes;
-		priv->port_stats.tx_chksum_offload += priv->tx_ring[i]->tx_csum;
-		priv->port_stats.queue_stopped +=
-			priv->tx_ring[i]->queue_stopped;
-		priv->port_stats.wake_queue += priv->tx_ring[i]->wake_queue;
+		const struct mlx4_en_tx_ring *ring = priv->tx_ring[i];
+
+		stats->tx_packets += ring->packets;
+		stats->tx_bytes += ring->bytes;
+		priv->port_stats.tx_chksum_offload += ring->tx_csum;
+		priv->port_stats.queue_stopped += ring->queue_stopped;
+		priv->port_stats.wake_queue += ring->wake_queue;
+		priv->port_stats.tso_packets += ring->tso_packets;
 	}
 
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index adedc47e947d..8816592ed7be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -37,6 +37,7 @@
 #include <linux/mlx4/qp.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
+#include <linux/prefetch.h>
 #include <linux/vmalloc.h>
 #include <linux/tcp.h>
 #include <linux/ip.h>
@@ -68,7 +69,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->inline_thold = priv->prof->inline_thold;
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
-	ring->tx_info = vmalloc_node(tmp, node);
+	ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
 	if (!ring->tx_info) {
 		ring->tx_info = vmalloc(tmp);
 		if (!ring->tx_info) {
@@ -151,7 +152,7 @@ err_bounce:
 	kfree(ring->bounce_buf);
 	ring->bounce_buf = NULL;
 err_info:
-	vfree(ring->tx_info);
+	kvfree(ring->tx_info);
 	ring->tx_info = NULL;
 err_ring:
 	kfree(ring);
@@ -174,7 +175,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	kfree(ring->bounce_buf);
 	ring->bounce_buf = NULL;
-	vfree(ring->tx_info);
+	kvfree(ring->tx_info);
 	ring->tx_info = NULL;
 	kfree(ring);
 	*pring = NULL;
@@ -191,12 +192,12 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	ring->prod = 0;
 	ring->cons = 0xffffffff;
 	ring->last_nr_txbb = 1;
-	ring->poll_cnt = 0;
 	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
 	memset(ring->buf, 0, ring->buf_size);
 
 	ring->qp_state = MLX4_QP_STATE_RST;
-	ring->doorbell_qpn = ring->qp.qpn << 8;
+	ring->doorbell_qpn = cpu_to_be32(ring->qp.qpn << 8);
+	ring->mr_key = cpu_to_be32(mdev->mr.key);
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
 				ring->cqn, user_prio, &ring->context);
@@ -259,38 +260,45 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring,
 				int index, u8 owner, u64 timestamp)
 {
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
 	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
 	struct mlx4_wqe_data_seg *data = (void *) tx_desc + tx_info->data_offset;
-	struct sk_buff *skb = tx_info->skb;
-	struct skb_frag_struct *frag;
 	void *end = ring->buf + ring->buf_size;
-	int frags = skb_shinfo(skb)->nr_frags;
+	struct sk_buff *skb = tx_info->skb;
+	int nr_maps = tx_info->nr_maps;
 	int i;
-	struct skb_shared_hwtstamps hwts;
 
-	if (timestamp) {
-		mlx4_en_fill_hwtstamps(mdev, &hwts, timestamp);
+	/* We do not touch skb here, so prefetch skb->users location
+	 * to speedup consume_skb()
+	 */
+	prefetchw(&skb->users);
+
+	if (unlikely(timestamp)) {
+		struct skb_shared_hwtstamps hwts;
+
+		mlx4_en_fill_hwtstamps(priv->mdev, &hwts, timestamp);
 		skb_tstamp_tx(skb, &hwts);
 	}
 
 	/* Optimize the common case when there are no wraparounds */
 	if (likely((void *) tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
 		if (!tx_info->inl) {
-			if (tx_info->linear) {
+			if (tx_info->linear)
 				dma_unmap_single(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data->addr),
-					 be32_to_cpu(data->byte_count),
-					 PCI_DMA_TODEVICE);
-				++data;
-			}
-
-			for (i = 0; i < frags; i++) {
-				frag = &skb_shinfo(skb)->frags[i];
+						tx_info->map0_dma,
+						tx_info->map0_byte_count,
+						PCI_DMA_TODEVICE);
+			else
+				dma_unmap_page(priv->ddev,
+					       tx_info->map0_dma,
+					       tx_info->map0_byte_count,
+					       PCI_DMA_TODEVICE);
+			for (i = 1; i < nr_maps; i++) {
+				data++;
 				dma_unmap_page(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data[i].addr),
-					skb_frag_size(frag), PCI_DMA_TODEVICE);
+					(dma_addr_t)be64_to_cpu(data->addr),
+					be32_to_cpu(data->byte_count),
+					PCI_DMA_TODEVICE);
 			}
 		}
 	} else {
@@ -299,23 +307,25 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				data = ring->buf + ((void *)data - end);
 			}
 
-			if (tx_info->linear) {
+			if (tx_info->linear)
 				dma_unmap_single(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data->addr),
-					 be32_to_cpu(data->byte_count),
-					 PCI_DMA_TODEVICE);
-				++data;
-			}
-
-			for (i = 0; i < frags; i++) {
+						tx_info->map0_dma,
+						tx_info->map0_byte_count,
+						PCI_DMA_TODEVICE);
+			else
+				dma_unmap_page(priv->ddev,
+					       tx_info->map0_dma,
+					       tx_info->map0_byte_count,
+					       PCI_DMA_TODEVICE);
+			for (i = 1; i < nr_maps; i++) {
+				data++;
 				/* Check for wraparound before unmapping */
 				if ((void *) data >= end)
 					data = ring->buf;
-				frag = &skb_shinfo(skb)->frags[i];
 				dma_unmap_page(priv->ddev,
-					(dma_addr_t) be64_to_cpu(data->addr),
-					 skb_frag_size(frag), PCI_DMA_TODEVICE);
-				++data;
+					(dma_addr_t)be64_to_cpu(data->addr),
+					be32_to_cpu(data->byte_count),
+					PCI_DMA_TODEVICE);
 			}
 		}
 	}
@@ -377,13 +387,18 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	u64 timestamp = 0;
 	int done = 0;
 	int budget = priv->tx_work_limit;
+	u32 last_nr_txbb;
+	u32 ring_cons;
 
 	if (!priv->port_up)
 		return true;
 
+	prefetchw(&ring->tx_queue->dql.limit);
 	index = cons_index & size_mask;
 	cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
-	ring_index = ring->cons & size_mask;
+	last_nr_txbb = ACCESS_ONCE(ring->last_nr_txbb);
+	ring_cons = ACCESS_ONCE(ring->cons);
+	ring_index = ring_cons & size_mask;
 	stamp_index = ring_index;
 
 	/* Process all completed CQEs */
@@ -408,19 +423,19 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		new_index = be16_to_cpu(cqe->wqe_index) & size_mask;
 
 		do {
-			txbbs_skipped += ring->last_nr_txbb;
-			ring_index = (ring_index + ring->last_nr_txbb) & size_mask;
+			txbbs_skipped += last_nr_txbb;
+			ring_index = (ring_index + last_nr_txbb) & size_mask;
 			if (ring->tx_info[ring_index].ts_requested)
 				timestamp = mlx4_en_get_cqe_ts(cqe);
 
 			/* free next descriptor */
-			ring->last_nr_txbb = mlx4_en_free_tx_desc(
+			last_nr_txbb = mlx4_en_free_tx_desc(
 					priv, ring, ring_index,
-					!!((ring->cons + txbbs_skipped) &
+					!!((ring_cons + txbbs_skipped) &
 					ring->size), timestamp);
 
 			mlx4_en_stamp_wqe(priv, ring, stamp_index,
-					  !!((ring->cons + txbbs_stamp) &
+					  !!((ring_cons + txbbs_stamp) &
 						ring->size));
 			stamp_index = ring_index;
 			txbbs_stamp = txbbs_skipped;
@@ -441,7 +456,11 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 	mcq->cons_index = cons_index;
 	mlx4_cq_set_ci(mcq);
 	wmb();
-	ring->cons += txbbs_skipped;
+
+	/* we want to dirty this cache line once */
+	ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
+	ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
+
 	netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
 
 	/*
@@ -512,30 +531,35 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 	return ring->buf + index * TXBB_SIZE;
 }
 
-static int is_inline(int inline_thold, struct sk_buff *skb, void **pfrag)
+/* Decide if skb can be inlined in tx descriptor to avoid dma mapping
+ *
+ * It seems strange we do not simply use skb_copy_bits().
+ * This would allow to inline all skbs iff skb->len <= inline_thold
+ *
+ * Note that caller already checked skb was not a gso packet
+ */
+static bool is_inline(int inline_thold, const struct sk_buff *skb,
+		      const struct skb_shared_info *shinfo,
+		      void **pfrag)
 {
 	void *ptr;
 
-	if (inline_thold && !skb_is_gso(skb) && skb->len <= inline_thold) {
-		if (skb_shinfo(skb)->nr_frags == 1) {
-			ptr = skb_frag_address_safe(&skb_shinfo(skb)->frags[0]);
-			if (unlikely(!ptr))
-				return 0;
-
-			if (pfrag)
-				*pfrag = ptr;
+	if (skb->len > inline_thold || !inline_thold)
+		return false;
 
-			return 1;
-		} else if (unlikely(skb_shinfo(skb)->nr_frags))
-			return 0;
-		else
-			return 1;
+	if (shinfo->nr_frags == 1) {
+		ptr = skb_frag_address_safe(&shinfo->frags[0]);
+		if (unlikely(!ptr))
+			return false;
+		*pfrag = ptr;
+		return true;
 	}
-
-	return 0;
+	if (shinfo->nr_frags)
+		return false;
+	return true;
 }
 
-static int inline_size(struct sk_buff *skb)
+static int inline_size(const struct sk_buff *skb)
 {
 	if (skb->len + CTRL_SIZE + sizeof(struct mlx4_wqe_inline_seg)
 	    <= MLX4_INLINE_ALIGN)
@@ -546,18 +570,23 @@ static int inline_size(struct sk_buff *skb)
 			     sizeof(struct mlx4_wqe_inline_seg), 16);
 }
 
-static int get_real_size(struct sk_buff *skb, struct net_device *dev,
-			 int *lso_header_size)
+static int get_real_size(const struct sk_buff *skb,
+			 const struct skb_shared_info *shinfo,
+			 struct net_device *dev,
+			 int *lso_header_size,
+			 bool *inline_ok,
+			 void **pfrag)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int real_size;
 
-	if (skb_is_gso(skb)) {
+	if (shinfo->gso_size) {
+		*inline_ok = false;
 		if (skb->encapsulation)
 			*lso_header_size = (skb_inner_transport_header(skb) - skb->data) + inner_tcp_hdrlen(skb);
 		else
 			*lso_header_size = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		real_size = CTRL_SIZE + skb_shinfo(skb)->nr_frags * DS_SIZE +
+		real_size = CTRL_SIZE + shinfo->nr_frags * DS_SIZE +
 			ALIGN(*lso_header_size + 4, DS_SIZE);
 		if (unlikely(*lso_header_size != skb_headlen(skb))) {
 			/* We add a segment for the skb linear buffer only if
@@ -572,20 +601,28 @@ static int get_real_size(struct sk_buff *skb, struct net_device *dev,
 		}
 	} else {
 		*lso_header_size = 0;
-		if (!is_inline(priv->prof->inline_thold, skb, NULL))
-			real_size = CTRL_SIZE + (skb_shinfo(skb)->nr_frags + 1) * DS_SIZE;
-		else
+		*inline_ok = is_inline(priv->prof->inline_thold, skb,
+				       shinfo, pfrag);
+
+		if (*inline_ok)
 			real_size = inline_size(skb);
+		else
+			real_size = CTRL_SIZE +
+				    (shinfo->nr_frags + 1) * DS_SIZE;
 	}
 
 	return real_size;
 }
 
-static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *skb,
-			     int real_size, u16 *vlan_tag, int tx_ind, void *fragptr)
+static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc,
+			     const struct sk_buff *skb,
+			     const struct skb_shared_info *shinfo,
+			     int real_size, u16 *vlan_tag,
+			     int tx_ind, void *fragptr)
 {
 	struct mlx4_wqe_inline_seg *inl = &tx_desc->inl;
 	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
+	unsigned int hlen = skb_headlen(skb);
 
 	if (skb->len <= spc) {
 		if (likely(skb->len >= MIN_PKT_LEN)) {
@@ -595,19 +632,19 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 			memset(((void *)(inl + 1)) + skb->len, 0,
 			       MIN_PKT_LEN - skb->len);
 		}
-		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
-		if (skb_shinfo(skb)->nr_frags)
-			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
-			       skb_frag_size(&skb_shinfo(skb)->frags[0]));
+		skb_copy_from_linear_data(skb, inl + 1, hlen);
+		if (shinfo->nr_frags)
+			memcpy(((void *)(inl + 1)) + hlen, fragptr,
+			       skb_frag_size(&shinfo->frags[0]));
 
 	} else {
 		inl->byte_count = cpu_to_be32(1 << 31 | spc);
-		if (skb_headlen(skb) <= spc) {
-			skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
-			if (skb_headlen(skb) < spc) {
-				memcpy(((void *)(inl + 1)) + skb_headlen(skb),
-					fragptr, spc - skb_headlen(skb));
-				fragptr +=  spc - skb_headlen(skb);
+		if (hlen <= spc) {
+			skb_copy_from_linear_data(skb, inl + 1, hlen);
+			if (hlen < spc) {
+				memcpy(((void *)(inl + 1)) + hlen,
+					fragptr, spc - hlen);
+				fragptr +=  spc - hlen;
 			}
 			inl = (void *) (inl + 1) + spc;
 			memcpy(((void *)(inl + 1)), fragptr, skb->len - spc);
@@ -615,10 +652,11 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 			skb_copy_from_linear_data(skb, inl + 1, spc);
 			inl = (void *) (inl + 1) + spc;
 			skb_copy_from_linear_data_offset(skb, spc, inl + 1,
-					skb_headlen(skb) - spc);
-			if (skb_shinfo(skb)->nr_frags)
-				memcpy(((void *)(inl + 1)) + skb_headlen(skb) - spc,
-					fragptr, skb_frag_size(&skb_shinfo(skb)->frags[0]));
+							 hlen - spc);
+			if (shinfo->nr_frags)
+				memcpy(((void *)(inl + 1)) + hlen - spc,
+				       fragptr,
+				       skb_frag_size(&shinfo->frags[0]));
 		}
 
 		wmb();
@@ -642,15 +680,16 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return fallback(dev, skb) % rings_p_up + up * rings_p_up;
 }
 
-static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
+static void mlx4_bf_copy(void __iomem *dst, const void *src,
+			 unsigned int bytecnt)
 {
 	__iowrite64_copy(dst, src, bytecnt / 8);
 }
 
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct device *ddev = priv->ddev;
 	struct mlx4_en_tx_ring *ring;
 	struct mlx4_en_tx_desc *tx_desc;
@@ -663,16 +702,25 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 index, bf_index;
 	__be32 op_own;
 	u16 vlan_tag = 0;
-	int i;
+	int i_frag;
 	int lso_header_size;
-	void *fragptr;
+	void *fragptr = NULL;
 	bool bounce = false;
 	bool send_doorbell;
+	bool inline_ok;
+	u32 ring_cons;
 
 	if (!priv->port_up)
 		goto tx_drop;
 
-	real_size = get_real_size(skb, dev, &lso_header_size);
+	tx_ind = skb_get_queue_mapping(skb);
+	ring = priv->tx_ring[tx_ind];
+
+	/* fetch ring->cons far ahead before needing it to avoid stall */
+	ring_cons = ACCESS_ONCE(ring->cons);
+
+	real_size = get_real_size(skb, shinfo, dev, &lso_header_size,
+				  &inline_ok, &fragptr);
 	if (unlikely(!real_size))
 		goto tx_drop;
 
@@ -685,13 +733,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
-	tx_ind = skb->queue_mapping;
-	ring = priv->tx_ring[tx_ind];
 	if (vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
 
 	/* Check available TXBBs And 2K spare for prefetch */
-	if (unlikely(((int)(ring->prod - ring->cons)) >
+	if (unlikely(((int)(ring->prod - ring_cons)) >
 		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 		/* every full Tx ring stops queue */
 		netif_tx_stop_queue(ring->tx_queue);
@@ -705,7 +751,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		wmb();
 
-		if (unlikely(((int)(ring->prod - ring->cons)) <=
+		ring_cons = ACCESS_ONCE(ring->cons);
+		if (unlikely(((int)(ring->prod - ring_cons)) <=
 			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
 			netif_tx_wake_queue(ring->tx_queue);
 			ring->wake_queue++;
@@ -714,9 +761,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	prefetchw(&ring->tx_queue->dql);
+
 	/* Track current inflight packets for performance analysis */
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
-			 (u32) (ring->prod - ring->cons - 1));
+			 (u32)(ring->prod - ring_cons - 1));
 
 	/* Packet is good - grab an index and transmit it */
 	index = ring->prod & ring->size_mask;
@@ -736,46 +785,48 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_info->skb = skb;
 	tx_info->nr_txbb = nr_txbb;
 
+	data = &tx_desc->data;
 	if (lso_header_size)
 		data = ((void *)&tx_desc->lso + ALIGN(lso_header_size + 4,
 						      DS_SIZE));
-	else
-		data = &tx_desc->data;
 
 	/* valid only for none inline segments */
 	tx_info->data_offset = (void *)data - (void *)tx_desc;
 
+	tx_info->inl = inline_ok;
+
 	tx_info->linear = (lso_header_size < skb_headlen(skb) &&
-			   !is_inline(ring->inline_thold, skb, NULL)) ? 1 : 0;
+			   !inline_ok) ? 1 : 0;
 
-	data += skb_shinfo(skb)->nr_frags + tx_info->linear - 1;
+	tx_info->nr_maps = shinfo->nr_frags + tx_info->linear;
+	data += tx_info->nr_maps - 1;
 
-	if (is_inline(ring->inline_thold, skb, &fragptr)) {
-		tx_info->inl = 1;
-	} else {
-		/* Map fragments */
-		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
-			struct skb_frag_struct *frag;
-			dma_addr_t dma;
+	if (!tx_info->inl) {
+		dma_addr_t dma = 0;
+		u32 byte_count = 0;
 
-			frag = &skb_shinfo(skb)->frags[i];
+		/* Map fragments if any */
+		for (i_frag = shinfo->nr_frags - 1; i_frag >= 0; i_frag--) {
+			const struct skb_frag_struct *frag;
+
+			frag = &shinfo->frags[i_frag];
+			byte_count = skb_frag_size(frag);
 			dma = skb_frag_dma_map(ddev, frag,
-					       0, skb_frag_size(frag),
+					       0, byte_count,
 					       DMA_TO_DEVICE);
 			if (dma_mapping_error(ddev, dma))
 				goto tx_drop_unmap;
 
 			data->addr = cpu_to_be64(dma);
-			data->lkey = cpu_to_be32(mdev->mr.key);
+			data->lkey = ring->mr_key;
 			wmb();
-			data->byte_count = cpu_to_be32(skb_frag_size(frag));
+			data->byte_count = cpu_to_be32(byte_count);
 			--data;
 		}
 
-		/* Map linear part */
+		/* Map linear part if needed */
 		if (tx_info->linear) {
-			u32 byte_count = skb_headlen(skb) - lso_header_size;
-			dma_addr_t dma;
+			byte_count = skb_headlen(skb) - lso_header_size;
 
 			dma = dma_map_single(ddev, skb->data +
 					     lso_header_size, byte_count,
@@ -784,29 +835,28 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto tx_drop_unmap;
 
 			data->addr = cpu_to_be64(dma);
-			data->lkey = cpu_to_be32(mdev->mr.key);
+			data->lkey = ring->mr_key;
 			wmb();
 			data->byte_count = cpu_to_be32(byte_count);
 		}
-		tx_info->inl = 0;
+		/* tx completion can avoid cache line miss for common cases */
+		tx_info->map0_dma = dma;
+		tx_info->map0_byte_count = byte_count;
 	}
 
 	/*
 	 * For timestamping add flag to skb_shinfo and
 	 * set flag for further reference
 	 */
-	if (ring->hwtstamp_tx_type == HWTSTAMP_TX_ON &&
-	    skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) {
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+	tx_info->ts_requested = 0;
+	if (unlikely(ring->hwtstamp_tx_type == HWTSTAMP_TX_ON &&
+		     shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
+		shinfo->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_info->ts_requested = 1;
 	}
 
 	/* Prepare ctrl segement apart opcode+ownership, which depends on
 	 * whether LSO is used */
-	tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
-		!!vlan_tx_tag_present(skb);
-	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
@@ -827,6 +877,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
+		int i;
+
 		/* Mark opcode as LSO */
 		op_own = cpu_to_be32(MLX4_OPCODE_LSO | (1 << 6)) |
 			((ring->prod & ring->size) ?
@@ -834,15 +886,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* Fill in the LSO prefix */
 		tx_desc->lso.mss_hdr_size = cpu_to_be32(
-			skb_shinfo(skb)->gso_size << 16 | lso_header_size);
+			shinfo->gso_size << 16 | lso_header_size);
 
 		/* Copy headers;
 		 * note that we already verified that it is linear */
 		memcpy(tx_desc->lso.header, skb->data, lso_header_size);
 
-		priv->port_stats.tso_packets++;
-		i = ((skb->len - lso_header_size) / skb_shinfo(skb)->gso_size) +
-			!!((skb->len - lso_header_size) % skb_shinfo(skb)->gso_size);
+		ring->tso_packets++;
+
+		i = ((skb->len - lso_header_size) / shinfo->gso_size) +
+			!!((skb->len - lso_header_size) % shinfo->gso_size);
 		tx_info->nr_bytes = skb->len + (i - 1) * lso_header_size;
 		ring->packets += i;
 	} else {
@@ -852,16 +905,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
 		tx_info->nr_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 		ring->packets++;
-
 	}
 	ring->bytes += tx_info->nr_bytes;
 	netdev_tx_sent_queue(ring->tx_queue, tx_info->nr_bytes);
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, skb->len);
 
-	if (tx_info->inl) {
-		build_inline_wqe(tx_desc, skb, real_size, &vlan_tag, tx_ind, fragptr);
-		tx_info->inl = 1;
-	}
+	if (tx_info->inl)
+		build_inline_wqe(tx_desc, skb, shinfo, real_size,
+				 &vlan_tag, tx_ind, fragptr);
 
 	if (skb->encapsulation) {
 		struct iphdr *ipv4 = (struct iphdr *)skb_inner_network_header(skb);
@@ -874,16 +925,19 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod += nr_txbb;
 
 	/* If we used a bounce buffer then copy descriptor back into place */
-	if (bounce)
+	if (unlikely(bounce))
 		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
 
 	skb_tx_timestamp(skb);
 
 	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
 
+	real_size = (real_size / 16) & 0x3f;
+
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
 	    !vlan_tx_tag_present(skb) && send_doorbell) {
-		tx_desc->ctrl.bf_qpn |= cpu_to_be32(ring->doorbell_qpn);
+		tx_desc->ctrl.bf_qpn = ring->doorbell_qpn |
+				       cpu_to_be32(real_size);
 
 		op_own |= htonl((bf_index & 0xffff) << 8);
 		/* Ensure new descriptor hits memory
@@ -894,13 +948,18 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		wmb();
 
-		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned long *) &tx_desc->ctrl,
-		     desc_size);
+		mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
+			     desc_size);
 
 		wmb();
 
 		ring->bf.offset ^= ring->bf.buf_size;
 	} else {
+		tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
+		tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
+			!!vlan_tx_tag_present(skb);
+		tx_desc->ctrl.fence_size = real_size;
+
 		/* Ensure new descriptor hits memory
 		 * before setting ownership of this descriptor to HW
 		 */
@@ -918,8 +977,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 tx_drop_unmap:
 	en_err(priv, "DMA mapping error\n");
 
-	for (i++; i < skb_shinfo(skb)->nr_frags; i++) {
-		data++;
+	while (++i_frag < shinfo->nr_frags) {
+		++data;
 		dma_unmap_page(ddev, (dma_addr_t) be64_to_cpu(data->addr),
 			       be32_to_cpu(data->byte_count),
 			       PCI_DMA_TODEVICE);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6a4fc2394cf2..8731aac89244 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -216,13 +216,16 @@ enum cq_type {
 
 struct mlx4_en_tx_info {
 	struct sk_buff *skb;
-	u32 nr_txbb;
-	u32 nr_bytes;
-	u8 linear;
-	u8 data_offset;
-	u8 inl;
-	u8 ts_requested;
-};
+	dma_addr_t	map0_dma;
+	u32		map0_byte_count;
+	u32		nr_txbb;
+	u32		nr_bytes;
+	u8		linear;
+	u8		data_offset;
+	u8		inl;
+	u8		ts_requested;
+	u8		nr_maps;
+} ____cacheline_aligned_in_smp;
 
 
 #define MLX4_EN_BIT_DESC_OWN	0x80000000
@@ -253,39 +256,48 @@ struct mlx4_en_rx_alloc {
 };
 
 struct mlx4_en_tx_ring {
+			/* cache line used and dirtied in tx completion
+			 * (mlx4_en_free_tx_buf())
+			 */
+	u32			last_nr_txbb;
+	u32			cons;
+	unsigned long		wake_queue;
+
+			/* cache line used and dirtied in mlx4_en_xmit()
+			 */
+	u32			prod ____cacheline_aligned_in_smp;
+	unsigned long		bytes;
+	unsigned long		packets;
+	unsigned long		tx_csum;
+	unsigned long		tso_packets;
+	struct mlx4_bf		bf;
+	unsigned long		queue_stopped;
+
+			/* Following part should be mostly read
+			 */
+	cpumask_t		affinity_mask;
+	struct mlx4_qp		qp;
 	struct mlx4_hwq_resources wqres;
-	u32 size ; /* number of TXBBs */
-	u32 size_mask;
-	u16 stride;
-	u16 cqn;	/* index of port CQ associated with this ring */
-	u32 prod;
-	u32 cons;
-	u32 buf_size;
-	u32 doorbell_qpn;
-	void *buf;
-	u16 poll_cnt;
-	struct mlx4_en_tx_info *tx_info;
-	u8 *bounce_buf;
-	u8 queue_index;
-	cpumask_t affinity_mask;
-	u32 last_nr_txbb;
-	struct mlx4_qp qp;
-	struct mlx4_qp_context context;
-	int qpn;
-	enum mlx4_qp_state qp_state;
-	struct mlx4_srq dummy;
-	unsigned long bytes;
-	unsigned long packets;
-	unsigned long tx_csum;
-	unsigned long queue_stopped;
-	unsigned long wake_queue;
-	struct mlx4_bf bf;
-	bool bf_enabled;
-	bool bf_alloced;
-	struct netdev_queue *tx_queue;
-	int hwtstamp_tx_type;
-	int inline_thold;
-};
+	u32			size ; /* number of TXBBs */
+	u32			size_mask;
+	u16			stride;
+	u16			cqn;	/* index of port CQ associated with this ring */
+	u32			buf_size;
+	__be32			doorbell_qpn;
+	__be32			mr_key;
+	void			*buf;
+	struct mlx4_en_tx_info	*tx_info;
+	u8			*bounce_buf;
+	struct mlx4_qp_context	context;
+	int			qpn;
+	enum mlx4_qp_state	qp_state;
+	u8			queue_index;
+	bool			bf_enabled;
+	bool			bf_alloced;
+	struct netdev_queue	*tx_queue;
+	int			hwtstamp_tx_type;
+	int			inline_thold;
+} ____cacheline_aligned_in_smp;
 
 struct mlx4_en_rx_desc {
 	/* actual number of entries depends on rx ring stride */
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 03b5608a4329..5e5ad07548b8 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -583,7 +583,7 @@ struct mlx4_uar {
 };
 
 struct mlx4_bf {
-	unsigned long		offset;
+	unsigned int		offset;
 	int			buf_size;
 	struct mlx4_uar	       *uar;
 	void __iomem	       *reg;
