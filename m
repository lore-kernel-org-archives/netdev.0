From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V4 10/12] net/mlx5: Ethernet Datapath files
Date: Sun, 17 May 2015 16:02:21 +0300
Message-ID: <1431867743-13149-11-git-send-email-amirv@mellanox.com>
References: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:40725 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753148AbbEQNEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 09:04:05 -0400
In-Reply-To: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

en_[rt]x.c contains the data path related code specific to tx or rx.
en_txrx.c contains data path code which is common for both the rx and
tx, this is mainly napi related code.

Below are the objects that are being used by the hardware and the driver
in the data path:

Channel - one channel per IRQ. Every channel object contains:
  RQ  - describes the rx queue
  TIR - One TIR (Transport Interface Receive) object per flow type. TIR
        contains attributes for a type of rx flow (e.g IPv4, IPv6 etc).
        A flow is defined in the Flow Table.
        Currently TIR describes the RSS hash parameters if exists and LRO
        attributes.
  SQ  - describes the a tx queue. There is one SQ (Send Queue) per
        TC (traffic class).
  TIS - There is one TIS (Transport Interface Send) per TC.  It
        describes the TC and may later be extended to describe more
	transport properties.

Both RQ and SQ inherit from the object WQ (work queue). This common code
to describe the layout of CQE's WQE's in memory is in the files wq.[cj]

For every channel there is one NAPI context that is used for RX and
for TX.

Driver is using netdev_alloc_skb() to allocate skb's.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 249 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 344 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 107 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/wq.c      | 183 ++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/wq.h      | 171 +++++++++++
 5 files changed, 1054 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
new file mode 100644
index 0000000..ce1317c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -0,0 +1,249 @@
+/*
+ * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include "en.h"
+
+static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
+				     struct mlx5e_rx_wqe *wqe, u16 ix)
+{
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+
+	skb = netdev_alloc_skb(rq->netdev, rq->wqe_sz);
+	if (unlikely(!skb))
+		return -ENOMEM;
+
+	skb_reserve(skb, MLX5E_NET_IP_ALIGN);
+
+	dma_addr = dma_map_single(rq->pdev,
+				  /* hw start padding */
+				  skb->data - MLX5E_NET_IP_ALIGN,
+				  /* hw   end padding */
+				  rq->wqe_sz,
+				  DMA_FROM_DEVICE);
+
+	if (unlikely(dma_mapping_error(rq->pdev, dma_addr)))
+		goto err_free_skb;
+
+	*((dma_addr_t *)skb->cb) = dma_addr;
+	wqe->data.addr = cpu_to_be64(dma_addr + MLX5E_NET_IP_ALIGN);
+
+	rq->skb[ix] = skb;
+
+	return 0;
+
+err_free_skb:
+	dev_kfree_skb(skb);
+
+	return -ENOMEM;
+}
+
+bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
+{
+	struct mlx5_wq_ll *wq = &rq->wq;
+
+	if (unlikely(!test_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state)))
+		return false;
+
+	while (!mlx5_wq_ll_is_full(wq)) {
+		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
+
+		if (unlikely(mlx5e_alloc_rx_wqe(rq, wqe, wq->head)))
+			break;
+
+		mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
+	}
+
+	/* ensure wqes are visible to device before updating doorbell record */
+	dma_wmb();
+
+	mlx5_wq_ll_update_db_record(wq);
+
+	return !mlx5_wq_ll_is_full(wq);
+}
+
+static void mlx5e_lro_update_hdr(struct sk_buff *skb, struct mlx5_cqe64 *cqe)
+{
+	struct ethhdr	*eth	= (struct ethhdr *)(skb->data);
+	struct iphdr	*ipv4	= (struct iphdr *)(skb->data + ETH_HLEN);
+	struct ipv6hdr	*ipv6	= (struct ipv6hdr *)(skb->data + ETH_HLEN);
+	struct tcphdr	*tcp;
+
+	u8 l4_hdr_type = get_cqe_l4_hdr_type(cqe);
+	int tcp_ack = ((CQE_L4_HDR_TYPE_TCP_ACK_NO_DATA  == l4_hdr_type) ||
+		       (CQE_L4_HDR_TYPE_TCP_ACK_AND_DATA == l4_hdr_type));
+
+	u16 tot_len = be32_to_cpu(cqe->byte_cnt) - ETH_HLEN;
+
+	if (eth->h_proto == htons(ETH_P_IP)) {
+		tcp = (struct tcphdr *)(skb->data + ETH_HLEN +
+					sizeof(struct iphdr));
+		ipv6 = NULL;
+	} else {
+		tcp = (struct tcphdr *)(skb->data + ETH_HLEN +
+					sizeof(struct ipv6hdr));
+		ipv4 = NULL;
+	}
+
+	if (get_cqe_lro_tcppsh(cqe))
+		tcp->psh                = 1;
+
+	if (tcp_ack) {
+		tcp->ack                = 1;
+		tcp->ack_seq            = cqe->lro_ack_seq_num;
+		tcp->window             = cqe->lro_tcp_win;
+	}
+
+	if (ipv4) {
+		ipv4->ttl               = cqe->lro_min_ttl;
+		ipv4->tot_len           = cpu_to_be16(tot_len);
+		ipv4->check             = 0;
+		ipv4->check             = ip_fast_csum((unsigned char *)ipv4,
+						       ipv4->ihl);
+	} else {
+		ipv6->hop_limit         = cqe->lro_min_ttl;
+		ipv6->payload_len       = cpu_to_be16(tot_len -
+						      sizeof(struct ipv6hdr));
+	}
+}
+
+static inline void mlx5e_skb_set_hash(struct mlx5_cqe64 *cqe,
+				      struct sk_buff *skb)
+{
+	u8 cht = cqe->rss_hash_type;
+	int ht = (cht & CQE_RSS_HTYPE_L4) ? PKT_HASH_TYPE_L4 :
+		 (cht & CQE_RSS_HTYPE_IP) ? PKT_HASH_TYPE_L3 :
+					    PKT_HASH_TYPE_NONE;
+	skb_set_hash(skb, be32_to_cpu(cqe->rss_hash_result), ht);
+}
+
+static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
+				      struct mlx5e_rq *rq,
+				      struct sk_buff *skb)
+{
+	struct net_device *netdev = rq->netdev;
+	u32 cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
+	int lro_num_seg;
+
+	skb_put(skb, cqe_bcnt);
+
+	lro_num_seg = be32_to_cpu(cqe->srqn) >> 24;
+	if (lro_num_seg > 1) {
+		mlx5e_lro_update_hdr(skb, cqe);
+		skb_shinfo(skb)->gso_size = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
+		rq->stats.lro_packets++;
+		rq->stats.lro_bytes += cqe_bcnt;
+	}
+
+	if (likely(netdev->features & NETIF_F_RXCSUM) &&
+	    (cqe->hds_ip_ext & CQE_L2_OK) &&
+	    (cqe->hds_ip_ext & CQE_L3_OK) &&
+	    (cqe->hds_ip_ext & CQE_L4_OK)) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	} else {
+		skb->ip_summed = CHECKSUM_NONE;
+		rq->stats.csum_none++;
+	}
+
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	skb_record_rx_queue(skb, rq->ix);
+
+	if (likely(netdev->features & NETIF_F_RXHASH))
+		mlx5e_skb_set_hash(cqe, skb);
+
+	if (cqe_has_vlan(cqe))
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       be16_to_cpu(cqe->vlan_info));
+}
+
+bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
+{
+	struct mlx5e_rq *rq = cq->sqrq;
+	int i;
+
+	/* avoid accessing cq (dma coherent memory) if not needed */
+	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
+		return false;
+
+	for (i = 0; i < budget; i++) {
+		struct mlx5e_rx_wqe *wqe;
+		struct mlx5_cqe64 *cqe;
+		struct sk_buff *skb;
+		__be16 wqe_counter_be;
+		u16 wqe_counter;
+
+		cqe = mlx5e_get_cqe(cq);
+		if (!cqe)
+			break;
+
+		wqe_counter_be = cqe->wqe_counter;
+		wqe_counter    = be16_to_cpu(wqe_counter_be);
+		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
+		skb            = rq->skb[wqe_counter];
+		rq->skb[wqe_counter] = NULL;
+
+		dma_unmap_single(rq->pdev,
+				 *((dma_addr_t *)skb->cb),
+				 skb_end_offset(skb),
+				 DMA_FROM_DEVICE);
+
+		if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
+			rq->stats.wqe_err++;
+			dev_kfree_skb(skb);
+			goto wq_ll_pop;
+		}
+
+		mlx5e_build_rx_skb(cqe, rq, skb);
+		rq->stats.packets++;
+		napi_gro_receive(cq->napi, skb);
+
+wq_ll_pop:
+		mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
+			       &wqe->next.next_wqe_index);
+	}
+
+	mlx5_cqwq_update_db_record(&cq->wq);
+
+	/* ensure cq space is freed before enabling more cqes */
+	wmb();
+
+	if (i == budget) {
+		set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
+		return true;
+	}
+
+	return false;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
new file mode 100644
index 0000000..8020986
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -0,0 +1,344 @@
+/*
+ * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/tcp.h>
+#include <linux/if_vlan.h>
+#include "en.h"
+
+static void mlx5e_dma_pop_last_pushed(struct mlx5e_sq *sq, dma_addr_t *addr,
+				      u32 *size)
+{
+	sq->dma_fifo_pc--;
+	*addr = sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].addr;
+	*size = sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].size;
+}
+
+static void mlx5e_dma_unmap_wqe_err(struct mlx5e_sq *sq, struct sk_buff *skb)
+{
+	dma_addr_t addr;
+	u32 size;
+	int i;
+
+	for (i = 0; i < MLX5E_TX_SKB_CB(skb)->num_dma; i++) {
+		mlx5e_dma_pop_last_pushed(sq, &addr, &size);
+		dma_unmap_single(sq->pdev, addr, size, DMA_TO_DEVICE);
+	}
+}
+
+static inline void mlx5e_dma_push(struct mlx5e_sq *sq, dma_addr_t addr,
+				  u32 size)
+{
+	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].addr = addr;
+	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].size = size;
+	sq->dma_fifo_pc++;
+}
+
+static inline void mlx5e_dma_get(struct mlx5e_sq *sq, u32 i, dma_addr_t *addr,
+				 u32 *size)
+{
+	*addr = sq->dma_fifo[i & sq->dma_fifo_mask].addr;
+	*size = sq->dma_fifo[i & sq->dma_fifo_mask].size;
+}
+
+u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
+		       void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int channel_ix = fallback(dev, skb);
+	int up = skb_vlan_tag_present(skb)        ?
+		 skb->vlan_tci >> VLAN_PRIO_SHIFT :
+		 priv->default_vlan_prio;
+	int tc = netdev_get_prio_tc_map(dev, up);
+
+	return (tc << priv->order_base_2_num_channels) | channel_ix;
+}
+
+static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
+					    struct sk_buff *skb)
+{
+#define MLX5E_MIN_INLINE 16 /* eth header with vlan (w/o next ethertype) */
+	return MLX5E_MIN_INLINE;
+}
+
+static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs)
+{
+	struct vlan_ethhdr *vhdr = (struct vlan_ethhdr *)start;
+	int cpy1_sz = 2 * ETH_ALEN;
+	int cpy2_sz = ihs - cpy1_sz - VLAN_HLEN;
+
+	skb_copy_from_linear_data(skb, vhdr, cpy1_sz);
+	skb_pull_inline(skb, cpy1_sz);
+	vhdr->h_vlan_proto = skb->vlan_proto;
+	vhdr->h_vlan_TCI = cpu_to_be16(skb_vlan_tag_get(skb));
+	skb_copy_from_linear_data(skb, &vhdr->h_vlan_encapsulated_proto,
+				  cpy2_sz);
+	skb_pull_inline(skb, cpy2_sz);
+}
+
+static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
+{
+	struct mlx5_wq_cyc       *wq   = &sq->wq;
+
+	u16 pi = sq->pc & wq->sz_m1;
+	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+
+	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
+	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
+	struct mlx5_wqe_data_seg *dseg;
+
+	u8  opcode = MLX5_OPCODE_SEND;
+	dma_addr_t dma_addr = 0;
+	u16 headlen;
+	u16 ds_cnt;
+	u16 ihs;
+	int i;
+
+	memset(wqe, 0, sizeof(*wqe));
+
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL))
+		eseg->cs_flags	= MLX5_ETH_WQE_L3_CSUM | MLX5_ETH_WQE_L4_CSUM;
+	else
+		sq->stats.csum_offload_none++;
+
+	if (skb_is_gso(skb)) {
+		u32 payload_len;
+		int num_pkts;
+
+		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
+		opcode       = MLX5_OPCODE_LSO;
+		ihs          = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		payload_len  = skb->len - ihs;
+		num_pkts     =    (payload_len / skb_shinfo(skb)->gso_size) +
+				!!(payload_len % skb_shinfo(skb)->gso_size);
+		MLX5E_TX_SKB_CB(skb)->num_bytes = skb->len +
+						  (num_pkts - 1) * ihs;
+		sq->stats.tso_packets++;
+		sq->stats.tso_bytes += payload_len;
+	} else {
+		ihs             = mlx5e_get_inline_hdr_size(sq, skb);
+		MLX5E_TX_SKB_CB(skb)->num_bytes = max_t(unsigned int, skb->len,
+							ETH_ZLEN);
+	}
+
+	if (skb_vlan_tag_present(skb)) {
+		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs);
+	} else {
+		skb_copy_from_linear_data(skb, eseg->inline_hdr_start, ihs);
+		skb_pull_inline(skb, ihs);
+	}
+
+	eseg->inline_hdr_sz	= cpu_to_be16(ihs);
+
+	ds_cnt  = sizeof(*wqe) / MLX5_SEND_WQE_DS;
+	ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr_start),
+			       MLX5_SEND_WQE_DS);
+	dseg    = (struct mlx5_wqe_data_seg *)cseg + ds_cnt;
+
+	MLX5E_TX_SKB_CB(skb)->num_dma = 0;
+
+	headlen = skb_headlen(skb);
+	if (headlen) {
+		dma_addr = dma_map_single(sq->pdev, skb->data, headlen,
+					  DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(sq->pdev, dma_addr)))
+			goto dma_unmap_wqe_err;
+
+		dseg->addr       = cpu_to_be64(dma_addr);
+		dseg->lkey       = sq->mkey_be;
+		dseg->byte_count = cpu_to_be32(headlen);
+
+		mlx5e_dma_push(sq, dma_addr, headlen);
+		MLX5E_TX_SKB_CB(skb)->num_dma++;
+
+		dseg++;
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		int fsz = skb_frag_size(frag);
+
+		dma_addr = skb_frag_dma_map(sq->pdev, frag, 0, fsz,
+					    DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(sq->pdev, dma_addr)))
+			goto dma_unmap_wqe_err;
+
+		dseg->addr       = cpu_to_be64(dma_addr);
+		dseg->lkey       = sq->mkey_be;
+		dseg->byte_count = cpu_to_be32(fsz);
+
+		mlx5e_dma_push(sq, dma_addr, fsz);
+		MLX5E_TX_SKB_CB(skb)->num_dma++;
+
+		dseg++;
+	}
+
+	ds_cnt += MLX5E_TX_SKB_CB(skb)->num_dma;
+
+	cseg->opmod_idx_opcode	= cpu_to_be32((sq->pc << 8) | opcode);
+	cseg->qpn_ds		= cpu_to_be32((sq->sqn << 8) | ds_cnt);
+	cseg->fm_ce_se		= MLX5_WQE_CTRL_CQ_UPDATE;
+
+	sq->skb[pi] = skb;
+
+	MLX5E_TX_SKB_CB(skb)->num_wqebbs = DIV_ROUND_UP(ds_cnt,
+							MLX5_SEND_WQEBB_NUM_DS);
+	sq->pc += MLX5E_TX_SKB_CB(skb)->num_wqebbs;
+
+	netdev_tx_sent_queue(sq->txq, MLX5E_TX_SKB_CB(skb)->num_bytes);
+
+	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5_SEND_WQE_MAX_WQEBBS))) {
+		netif_tx_stop_queue(sq->txq);
+		sq->stats.stopped++;
+	}
+
+	if (!skb->xmit_more || netif_xmit_stopped(sq->txq))
+		mlx5e_tx_notify_hw(sq, wqe);
+
+	sq->stats.packets++;
+	return NETDEV_TX_OK;
+
+dma_unmap_wqe_err:
+	sq->stats.dropped++;
+	mlx5e_dma_unmap_wqe_err(sq, skb);
+
+	dev_kfree_skb_any(skb);
+
+	return NETDEV_TX_OK;
+}
+
+netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int ix = skb->queue_mapping;
+	int tc = 0;
+	struct mlx5e_channel *c = priv->channel[ix];
+	struct mlx5e_sq *sq = &c->sq[tc];
+
+	return mlx5e_sq_xmit(sq, skb);
+}
+
+netdev_tx_t mlx5e_xmit_multi_tc(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int ix = skb->queue_mapping & priv->queue_mapping_channel_mask;
+	int tc = skb->queue_mapping >> priv->order_base_2_num_channels;
+	struct mlx5e_channel *c = priv->channel[ix];
+	struct mlx5e_sq *sq = &c->sq[tc];
+
+	return mlx5e_sq_xmit(sq, skb);
+}
+
+bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
+{
+	struct mlx5e_sq *sq;
+	u32 dma_fifo_cc;
+	u32 nbytes;
+	u16 npkts;
+	u16 sqcc;
+	int i;
+
+	/* avoid accessing cq (dma coherent memory) if not needed */
+	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
+		return false;
+
+	sq = cq->sqrq;
+
+	npkts = 0;
+	nbytes = 0;
+
+	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
+	 * otherwise a cq overrun may occur
+	 */
+	sqcc = sq->cc;
+
+	/* avoid dirtying sq cache line every cqe */
+	dma_fifo_cc = sq->dma_fifo_cc;
+
+	for (i = 0; i < MLX5E_TX_CQ_POLL_BUDGET; i++) {
+		struct mlx5_cqe64 *cqe;
+		struct sk_buff *skb;
+		u16 ci;
+		int j;
+
+		cqe = mlx5e_get_cqe(cq);
+		if (!cqe)
+			break;
+
+		ci = sqcc & sq->wq.sz_m1;
+		skb = sq->skb[ci];
+
+		if (unlikely(!skb)) { /* nop */
+			sq->stats.nop++;
+			sqcc++;
+			goto free_skb;
+		}
+
+		for (j = 0; j < MLX5E_TX_SKB_CB(skb)->num_dma; j++) {
+			dma_addr_t addr;
+			u32 size;
+
+			mlx5e_dma_get(sq, dma_fifo_cc, &addr, &size);
+			dma_fifo_cc++;
+			dma_unmap_single(sq->pdev, addr, size, DMA_TO_DEVICE);
+		}
+
+		npkts++;
+		nbytes += MLX5E_TX_SKB_CB(skb)->num_bytes;
+		sqcc += MLX5E_TX_SKB_CB(skb)->num_wqebbs;
+
+free_skb:
+		dev_kfree_skb(skb);
+	}
+
+	mlx5_cqwq_update_db_record(&cq->wq);
+
+	/* ensure cq space is freed before enabling more cqes */
+	wmb();
+
+	sq->dma_fifo_cc = dma_fifo_cc;
+	sq->cc = sqcc;
+
+	netdev_tx_completed_queue(sq->txq, npkts, nbytes);
+
+	if (netif_tx_queue_stopped(sq->txq) &&
+	    mlx5e_sq_has_room_for(sq, MLX5_SEND_WQE_MAX_WQEBBS) &&
+	    likely(test_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state))) {
+				netif_tx_wake_queue(sq->txq);
+				sq->stats.wake++;
+	}
+	if (i == MLX5E_TX_CQ_POLL_BUDGET) {
+		set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
+		return true;
+	}
+
+	return false;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
new file mode 100644
index 0000000..088bc42
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -0,0 +1,107 @@
+/*
+ * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include "en.h"
+
+struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
+{
+	struct mlx5_cqwq *wq = &cq->wq;
+	u32 ci = mlx5_cqwq_get_ci(wq);
+	struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(wq, ci);
+	int cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
+	int sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
+
+	if (cqe_ownership_bit != sw_ownership_val)
+		return NULL;
+
+	mlx5_cqwq_pop(wq);
+
+	/* ensure cqe content is read after cqe ownership bit */
+	rmb();
+
+	return cqe;
+}
+
+int mlx5e_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
+					       napi);
+	bool busy = false;
+	int i;
+
+	clear_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
+
+	for (i = 0; i < c->num_tc; i++)
+		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
+
+	busy |= mlx5e_poll_rx_cq(&c->rq.cq, budget);
+
+	busy |= mlx5e_post_rx_wqes(c->rq.cq.sqrq);
+
+	if (busy)
+		return budget;
+
+	napi_complete(napi);
+
+	/* avoid losing completion event during/after polling cqs */
+	if (test_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags)) {
+		napi_schedule(napi);
+		return 0;
+	}
+
+	for (i = 0; i < c->num_tc; i++)
+		mlx5e_cq_arm(&c->sq[i].cq);
+	mlx5e_cq_arm(&c->rq.cq);
+
+	return 0;
+}
+
+void mlx5e_completion_event(struct mlx5_core_cq *mcq)
+{
+	struct mlx5e_cq *cq = container_of(mcq, struct mlx5e_cq, mcq);
+
+	set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
+	set_bit(MLX5E_CHANNEL_NAPI_SCHED, &cq->channel->flags);
+	barrier();
+	napi_schedule(cq->napi);
+}
+
+void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event)
+{
+	struct mlx5e_cq *cq = container_of(mcq, struct mlx5e_cq, mcq);
+	struct mlx5e_channel *c = cq->channel;
+	struct mlx5e_priv *priv = c->priv;
+	struct net_device *netdev = priv->netdev;
+
+	netdev_err(netdev, "%s: cqn=0x%.6x event=0x%.2x\n",
+		   __func__, mcq->cqn, event);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.c b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
new file mode 100644
index 0000000..8388411
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/mlx5/driver.h>
+#include "wq.h"
+#include "mlx5_core.h"
+
+u32 mlx5_wq_cyc_get_size(struct mlx5_wq_cyc *wq)
+{
+	return (u32)wq->sz_m1 + 1;
+}
+
+u32 mlx5_cqwq_get_size(struct mlx5_cqwq *wq)
+{
+	return wq->sz_m1 + 1;
+}
+
+u32 mlx5_wq_ll_get_size(struct mlx5_wq_ll *wq)
+{
+	return (u32)wq->sz_m1 + 1;
+}
+
+static u32 mlx5_wq_cyc_get_byte_size(struct mlx5_wq_cyc *wq)
+{
+	return mlx5_wq_cyc_get_size(wq) << wq->log_stride;
+}
+
+static u32 mlx5_cqwq_get_byte_size(struct mlx5_cqwq *wq)
+{
+	return mlx5_cqwq_get_size(wq) << wq->log_stride;
+}
+
+static u32 mlx5_wq_ll_get_byte_size(struct mlx5_wq_ll *wq)
+{
+	return mlx5_wq_ll_get_size(wq) << wq->log_stride;
+}
+
+int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		       void *wqc, struct mlx5_wq_cyc *wq,
+		       struct mlx5_wq_ctrl *wq_ctrl)
+{
+	int err;
+
+	wq->log_stride = MLX5_GET(wq, wqc, log_wq_stride);
+	wq->sz_m1 = (1 << MLX5_GET(wq, wqc, log_wq_sz)) - 1;
+
+	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5_buf_alloc(mdev, mlx5_wq_cyc_get_byte_size(wq), &wq_ctrl->buf);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		goto err_db_free;
+	}
+
+	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->db  = wq_ctrl->db.db;
+
+	wq_ctrl->mdev = mdev;
+
+	return 0;
+
+err_db_free:
+	mlx5_db_free(mdev, &wq_ctrl->db);
+
+	return err;
+}
+
+int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		     void *cqc, struct mlx5_cqwq *wq,
+		     struct mlx5_wq_ctrl *wq_ctrl)
+{
+	int err;
+
+	wq->log_stride = 6 + MLX5_GET(cqc, cqc, cqe_sz);
+	wq->log_sz = MLX5_GET(cqc, cqc, log_cq_size);
+	wq->sz_m1 = (1 << wq->log_sz) - 1;
+
+	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5_buf_alloc(mdev, mlx5_cqwq_get_byte_size(wq), &wq_ctrl->buf);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		goto err_db_free;
+	}
+
+	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->db  = wq_ctrl->db.db;
+
+	wq_ctrl->mdev = mdev;
+
+	return 0;
+
+err_db_free:
+	mlx5_db_free(mdev, &wq_ctrl->db);
+
+	return err;
+}
+
+int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		      void *wqc, struct mlx5_wq_ll *wq,
+		      struct mlx5_wq_ctrl *wq_ctrl)
+{
+	struct mlx5_wqe_srq_next_seg *next_seg;
+	int err;
+	int i;
+
+	wq->log_stride = MLX5_GET(wq, wqc, log_wq_stride);
+	wq->sz_m1 = (1 << MLX5_GET(wq, wqc, log_wq_sz)) - 1;
+
+	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5_buf_alloc(mdev, mlx5_wq_ll_get_byte_size(wq), &wq_ctrl->buf);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		goto err_db_free;
+	}
+
+	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->db  = wq_ctrl->db.db;
+
+	for (i = 0; i < wq->sz_m1; i++) {
+		next_seg = mlx5_wq_ll_get_wqe(wq, i);
+		next_seg->next_wqe_index = cpu_to_be16(i + 1);
+	}
+	next_seg = mlx5_wq_ll_get_wqe(wq, i);
+	wq->tail_next = &next_seg->next_wqe_index;
+
+	wq_ctrl->mdev = mdev;
+
+	return 0;
+
+err_db_free:
+	mlx5_db_free(mdev, &wq_ctrl->db);
+
+	return err;
+}
+
+void mlx5_wq_destroy(struct mlx5_wq_ctrl *wq_ctrl)
+{
+	mlx5_buf_free(wq_ctrl->mdev, &wq_ctrl->buf);
+	mlx5_db_free(wq_ctrl->mdev, &wq_ctrl->db);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.h b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
new file mode 100644
index 0000000..e0ddd69
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
@@ -0,0 +1,171 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __MLX5_WQ_H__
+#define __MLX5_WQ_H__
+
+#include <linux/mlx5/mlx5_ifc.h>
+
+struct mlx5_wq_param {
+	int		linear;
+	int		numa;
+};
+
+struct mlx5_wq_ctrl {
+	struct mlx5_core_dev	*mdev;
+	struct mlx5_buf		buf;
+	struct mlx5_db		db;
+};
+
+struct mlx5_wq_cyc {
+	void			*buf;
+	__be32			*db;
+	u16			sz_m1;
+	u8			log_stride;
+};
+
+struct mlx5_cqwq {
+	void			*buf;
+	__be32			*db;
+	u32			sz_m1;
+	u32			cc; /* consumer counter */
+	u8			log_sz;
+	u8			log_stride;
+};
+
+struct mlx5_wq_ll {
+	void			*buf;
+	__be32			*db;
+	__be16			*tail_next;
+	u16			sz_m1;
+	u16			head;
+	u16			wqe_ctr;
+	u16			cur_sz;
+	u8			log_stride;
+};
+
+int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		       void *wqc, struct mlx5_wq_cyc *wq,
+		       struct mlx5_wq_ctrl *wq_ctrl);
+u32 mlx5_wq_cyc_get_size(struct mlx5_wq_cyc *wq);
+
+int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		     void *cqc, struct mlx5_cqwq *wq,
+		     struct mlx5_wq_ctrl *wq_ctrl);
+u32 mlx5_cqwq_get_size(struct mlx5_cqwq *wq);
+
+int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		      void *wqc, struct mlx5_wq_ll *wq,
+		      struct mlx5_wq_ctrl *wq_ctrl);
+u32 mlx5_wq_ll_get_size(struct mlx5_wq_ll *wq);
+
+void mlx5_wq_destroy(struct mlx5_wq_ctrl *wq_ctrl);
+
+static inline u16 mlx5_wq_cyc_ctr2ix(struct mlx5_wq_cyc *wq, u16 ctr)
+{
+	return ctr & wq->sz_m1;
+}
+
+static inline void *mlx5_wq_cyc_get_wqe(struct mlx5_wq_cyc *wq, u16 ix)
+{
+	return wq->buf + (ix << wq->log_stride);
+}
+
+static inline int mlx5_wq_cyc_cc_bigger(u16 cc1, u16 cc2)
+{
+	int equal   = (cc1 == cc2);
+	int smaller = 0x8000 & (cc1 - cc2);
+
+	return !equal && !smaller;
+}
+
+static inline u32 mlx5_cqwq_get_ci(struct mlx5_cqwq *wq)
+{
+	return wq->cc & wq->sz_m1;
+}
+
+static inline void *mlx5_cqwq_get_wqe(struct mlx5_cqwq *wq, u32 ix)
+{
+	return wq->buf + (ix << wq->log_stride);
+}
+
+static inline u32 mlx5_cqwq_get_wrap_cnt(struct mlx5_cqwq *wq)
+{
+	return wq->cc >> wq->log_sz;
+}
+
+static inline void mlx5_cqwq_pop(struct mlx5_cqwq *wq)
+{
+	wq->cc++;
+}
+
+static inline void mlx5_cqwq_update_db_record(struct mlx5_cqwq *wq)
+{
+	*wq->db = cpu_to_be32(wq->cc & 0xffffff);
+}
+
+static inline int mlx5_wq_ll_is_full(struct mlx5_wq_ll *wq)
+{
+	return wq->cur_sz == wq->sz_m1;
+}
+
+static inline int mlx5_wq_ll_is_empty(struct mlx5_wq_ll *wq)
+{
+	return !wq->cur_sz;
+}
+
+static inline void *mlx5_wq_ll_get_wqe(struct mlx5_wq_ll *wq, u16 ix)
+{
+	return wq->buf + (ix << wq->log_stride);
+}
+
+static inline void mlx5_wq_ll_push(struct mlx5_wq_ll *wq, u16 head_next)
+{
+	wq->head = head_next;
+	wq->wqe_ctr++;
+	wq->cur_sz++;
+}
+
+static inline void mlx5_wq_ll_pop(struct mlx5_wq_ll *wq, __be16 ix,
+				  __be16 *next_tail_next)
+{
+	*wq->tail_next = ix;
+	wq->tail_next = next_tail_next;
+	wq->cur_sz--;
+}
+
+static inline void mlx5_wq_ll_update_db_record(struct mlx5_wq_ll *wq)
+{
+	*wq->db = cpu_to_be32(wq->wqe_ctr);
+}
+
+#endif /* __MLX5_WQ_H__ */
-- 
1.9.3
