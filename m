From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next] net: hns: optimize XGE capability by reducing cpu usage
Date: Sat, 5 Dec 2015 15:32:29 +0800
Message-ID: <1449300749-50275-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<linuxarm@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <yankejian@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<xuwei5@hisilicon.com>, <liguozhu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:25627 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbLEHRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:17:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here is the patch raising the performance of XGE by:
1)changes the way page management method for enet momery, and
2)reduces the count of rmb, and
3)adds Memory prefetching

Signed-off-by: yankejian <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |  5 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  1 -
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 79 +++++++++++++++--------
 3 files changed, 55 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index d1f3316..6ca94dc 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -341,7 +341,8 @@ struct hnae_queue {
 	void __iomem *io_base;
 	phys_addr_t phy_base;
 	struct hnae_ae_dev *dev;	/* the device who use this queue */
-	struct hnae_ring rx_ring, tx_ring;
+	struct hnae_ring rx_ring ____cacheline_internodealigned_in_smp;
+	struct hnae_ring tx_ring ____cacheline_internodealigned_in_smp;
 	struct hnae_handle *handle;
 };
 
@@ -597,11 +598,9 @@ static inline void hnae_replace_buffer(struct hnae_ring *ring, int i,
 				       struct hnae_desc_cb *res_cb)
 {
 	struct hnae_buf_ops *bops = ring->q->handle->bops;
-	struct hnae_desc_cb tmp_cb = ring->desc_cb[i];
 
 	bops->unmap_buffer(ring, &ring->desc_cb[i]);
 	ring->desc_cb[i] = *res_cb;
-	*res_cb = tmp_cb;
 	ring->desc[i].addr = (__le64)ring->desc_cb[i].dma;
 	ring->desc[i].rx.ipoff_bnum_pid_flag = 0;
 }
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 77c6edb..522b264 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -341,7 +341,6 @@ void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 	else
 		flag = RCB_INT_FLAG_RX;
 
-	hns_rcb_int_clr_hw(ring->q, flag);
 	hns_rcb_int_ctrl_hw(ring->q, flag, mask);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index cad2663..e2be510 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -33,6 +33,7 @@
 
 #define RCB_IRQ_NOT_INITED 0
 #define RCB_IRQ_INITED 1
+#define HNS_BUFFER_SIZE_2048 2048
 
 #define BD_MAX_SEND_SIZE 8191
 #define SKB_TMP_LEN(SKB) \
@@ -491,13 +492,51 @@ static unsigned int hns_nic_get_headlen(unsigned char *data, u32 flag,
 		return max_size;
 }
 
-static void
-hns_nic_reuse_page(struct hnae_desc_cb *desc_cb, int tsize, int last_offset)
+static void hns_nic_reuse_page(struct sk_buff *skb, int i,
+			       struct hnae_ring *ring, int pull_len,
+			       struct hnae_desc_cb *desc_cb)
 {
+	struct hnae_desc *desc;
+	int truesize, size;
+	int last_offset = 0;
+
+	desc = &ring->desc[ring->next_to_clean];
+	size = le16_to_cpu(desc->rx.size);
+
+#if (PAGE_SIZE < 8192)
+	if (hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048) {
+		truesize = hnae_buf_size(ring);
+	} else {
+		truesize = ALIGN(size, L1_CACHE_BYTES);
+		last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
+	}
+
+#else
+		truesize = ALIGN(size, L1_CACHE_BYTES);
+		last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
+#endif
+
+	skb_add_rx_frag(skb, i, desc_cb->priv, desc_cb->page_offset + pull_len,
+			size - pull_len, truesize - pull_len);
+
 	 /* avoid re-using remote pages,flag default unreuse */
 	if (likely(page_to_nid(desc_cb->priv) == numa_node_id())) {
+#if (PAGE_SIZE < 8192)
+		if (hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048) {
+			/* if we are only owner of page we can reuse it */
+			if (likely(page_count(desc_cb->priv) == 1)) {
+				/* flip page offset to other buffer */
+				desc_cb->page_offset ^= truesize;
+
+				desc_cb->reuse_flag = 1;
+				/* bump ref count on page before it is given*/
+				get_page(desc_cb->priv);
+			}
+			return;
+		}
+#endif
 		/* move offset up to the next cache line */
-		desc_cb->page_offset += tsize;
+		desc_cb->page_offset += truesize;
 
 		if (desc_cb->page_offset <= last_offset) {
 			desc_cb->reuse_flag = 1;
@@ -529,11 +568,10 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 	struct hnae_desc *desc;
 	struct hnae_desc_cb *desc_cb;
 	unsigned char *va;
-	int bnum, length, size, i, truesize, last_offset;
+	int bnum, length, i;
 	int pull_len;
 	u32 bnum_flag;
 
-	last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
 	desc = &ring->desc[ring->next_to_clean];
 	desc_cb = &ring->desc_cb[ring->next_to_clean];
 
@@ -555,17 +593,12 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 		return -ENOMEM;
 	}
 
+	prefetchw(skb->data);
 	length = le16_to_cpu(desc->rx.pkt_len);
 	bnum_flag = le32_to_cpu(desc->rx.ipoff_bnum_pid_flag);
 	priv->ops.get_rxd_bnum(bnum_flag, &bnum);
 	*out_bnum = bnum;
 
-	/* we will be copying header into skb->data in
-	 * pskb_may_pull so it is in our interest to prefetch
-	 * it now to avoid a possible cache miss
-	 */
-	prefetchw(skb->data);
-
 	if (length <= HNS_RX_HEAD_SIZE) {
 		memcpy(__skb_put(skb, length), va, ALIGN(length, sizeof(long)));
 
@@ -588,13 +621,7 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 		memcpy(__skb_put(skb, pull_len), va,
 		       ALIGN(pull_len, sizeof(long)));
 
-		size = le16_to_cpu(desc->rx.size);
-		truesize = ALIGN(size, L1_CACHE_BYTES);
-		skb_add_rx_frag(skb, 0, desc_cb->priv,
-				desc_cb->page_offset + pull_len,
-				size - pull_len, truesize - pull_len);
-
-		hns_nic_reuse_page(desc_cb, truesize, last_offset);
+		hns_nic_reuse_page(skb, 0, ring, pull_len, desc_cb);
 		ring_ptr_move_fw(ring, next_to_clean);
 
 		if (unlikely(bnum >= (int)MAX_SKB_FRAGS)) { /* check err*/
@@ -604,13 +631,8 @@ static int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
 		for (i = 1; i < bnum; i++) {
 			desc = &ring->desc[ring->next_to_clean];
 			desc_cb = &ring->desc_cb[ring->next_to_clean];
-			size = le16_to_cpu(desc->rx.size);
-			truesize = ALIGN(size, L1_CACHE_BYTES);
-			skb_add_rx_frag(skb, i, desc_cb->priv,
-					desc_cb->page_offset,
-					size, truesize);
 
-			hns_nic_reuse_page(desc_cb, truesize, last_offset);
+			hns_nic_reuse_page(skb, i, ring, 0, desc_cb);
 			ring_ptr_move_fw(ring, next_to_clean);
 		}
 	}
@@ -750,9 +772,10 @@ recv:
 	/* make all data has been write before submit */
 	if (recv_pkts < budget) {
 		ex_num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
-		rmb(); /*complete read rx ring bd number*/
+
 		if (ex_num > clean_count) {
 			num += ex_num - clean_count;
+			rmb(); /*complete read rx ring bd number*/
 			goto recv;
 		}
 	}
@@ -849,8 +872,11 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 
 	bytes = 0;
 	pkts = 0;
-	while (head != ring->next_to_clean)
+	while (head != ring->next_to_clean) {
 		hns_nic_reclaim_one_desc(ring, &bytes, &pkts);
+		/* issue prefetch for next Tx descriptor */
+		prefetch(&ring->desc_cb[ring->next_to_clean]);
+	}
 
 	NETIF_TX_UNLOCK(ndev);
 
@@ -926,6 +952,7 @@ static int hns_nic_common_poll(struct napi_struct *napi, int budget)
 			ring_data->ring, 0);
 
 		ring_data->fini_process(ring_data);
+		return 0;
 	}
 
 	return clean_complete;
-- 
1.9.1
