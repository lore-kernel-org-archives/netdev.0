From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [Patch RFC 06/10 v2] mlx4_en: en_tx
Date: Wed, 20 Aug 2008 16:00:46 +0300
Message-ID: <48AC157E.1060906@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49122 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754240AbYHTNBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 09:01:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 18 Aug 2008 11:36:48 +0300
Subject: [PATCH] mlx4_en: en_tx

This file implements the tx flow, allocation and destruction
of tx rings.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |  741 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 741 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_tx.c

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
new file mode 100644
index 0000000..3e8322b
--- /dev/null
+++ b/drivers/net/mlx4/en_tx.c
@@ -0,0 +1,741 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
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
+ *
+ */
+
+#include <linux/mlx4/cq.h>
+#include <linux/mlx4/qp.h>
+#include <linux/skbuff.h>
+#include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
+
+#include "mlx4_en.h"
+
+int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
+			   struct mlx4_en_tx_ring *ring, u32 size,
+			   u16 stride)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int tmp;
+	int err;
+
+	ring->size = size;
+	ring->size_mask = size - 1;
+	ring->stride = stride;
+
+	tmp = size * sizeof(struct mlx4_en_tx_info);
+	ring->tx_info = vmalloc(tmp);
+	if (!ring->tx_info) {
+		mlx4_err(mdev, "Failed allocating tx_info ring\n");
+		return -ENOMEM;
+	}
+	mlx4_dbg(mdev, "Allocated tx_info ring at addr:%p size:%d\n",
+		 ring->tx_info, tmp);
+
+	ring->bounce_buf = kmalloc(MAX_DESC_SIZE, GFP_KERNEL);
+	if (!ring->bounce_buf) {
+		mlx4_err(mdev, "Failed allocating bounce buffer\n");
+		err = -ENOMEM;
+		goto err_tx;
+	}
+	ring->buf_size = ALIGN(size * ring->stride, MLX4_EN_PAGE_SIZE);
+
+	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size,
+				 ring->buf_size);
+	if (err)
+		goto err_bounce;
+
+	ring->buf = ring->wqres.buf.direct.buf;
+
+	mlx4_dbg(mdev, "Allocated TX ring (addr:%p) - buf:%p size:%d "
+		 "buf_size:%d dma:%llx\n", ring, ring->buf, ring->size,
+		 ring->buf_size, ring->wqres.buf.u.direct.map);
+
+	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &ring->qpn);
+	if (err) {
+		mlx4_err(mdev, "Failed reserving qp for tx ring.\n");
+		goto err_hwq_res;
+	}
+
+	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp);
+	if (err) {
+		mlx4_err(mdev, "Failed allocating qp %d\n", ring->qpn);
+		goto err_reserve;
+	}
+
+	return 0;
+
+err_reserve:
+	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
+err_hwq_res:
+	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
+err_bounce:
+	kfree(ring->bounce_buf);
+	ring->bounce_buf = NULL;
+err_tx:
+	vfree(ring->tx_info);
+	ring->tx_info = NULL;
+	return err;
+}
+
+void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
+			     struct mlx4_en_tx_ring *ring)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	mlx4_dbg(mdev, "Destroying tx ring, qpn: %d\n", ring->qpn);
+
+	mlx4_qp_remove(mdev->dev, &ring->qp);
+	mlx4_qp_free(mdev->dev, &ring->qp);
+	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
+	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
+	kfree(ring->bounce_buf);
+	ring->bounce_buf = NULL;
+	vfree(ring->tx_info);
+	ring->tx_info = NULL;
+}
+
+int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
+			     struct mlx4_en_tx_ring *ring,
+			     int cq, int srqn)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int err;
+
+	ring->cqn = cq;
+	ring->prod = 0;
+	ring->cons = 0xffffffff;
+	ring->last_nr_txbb = 1;
+	ring->poll_cnt = 0;
+	ring->blocked = 0;
+	memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
+	memset(ring->buf, 0, ring->buf_size);
+
+	ring->qp_state = MLX4_QP_STATE_RST;
+	ring->doorbell_qpn = swab32(ring->qp.qpn << 8);
+
+	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
+				ring->cqn, srqn, &ring->context);
+
+	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
+			       &ring->qp, &ring->qp_state);
+
+	return err;
+}
+
+void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
+				struct mlx4_en_tx_ring *ring)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	mlx4_qp_modify(mdev->dev, NULL, ring->qp_state,
+		       MLX4_QP_STATE_RST, NULL, 0, 0, &ring->qp);
+}
+
+
+static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
+				struct mlx4_en_tx_ring *ring,
+				int index, u8 owner)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
+	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
+	struct mlx4_wqe_data_seg *data = (void *) tx_desc + tx_info->data_offset;
+	struct sk_buff *skb = tx_info->skb;
+	struct skb_frag_struct *frag;
+	void *end = ring->buf + ring->buf_size;
+	int frags = tx_info->frags;
+	int i;
+	u32 *ptr = (u32 *) tx_desc;
+	__be32 stamp = cpu_to_be32(STAMP_VAL | (!!owner << STAMP_SHIFT));
+
+	mlx4_dbg(mdev, "Processing desc with linear:%d frags:%d\n",
+		  tx_info->linear, frags);
+
+	/* Optimize the common case when there are no wraparounds */
+	if (likely((void *) tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
+		if (tx_info->linear) {
+			mlx4_dbg(mdev, "Unmapping Tx linear area, "
+				       "DMA:%llx size:%x\n",
+				 (dma_addr_t) be64_to_cpu(data->addr),
+				 be32_to_cpu(data->byte_count));
+			pci_unmap_single(mdev->pdev,
+					 (dma_addr_t) be64_to_cpu(data->addr),
+					 be32_to_cpu(data->byte_count),
+					 PCI_DMA_TODEVICE);
+			++data;
+		}
+
+		for (i = 0; i < frags; i++) {
+			frag = &skb_shinfo(skb)->frags[i];
+			mlx4_dbg(mdev, "Unmapping Tx fragment at "
+				       "DMA:0x%llx size:0x%x\n",
+				 (dma_addr_t) be64_to_cpu(data[i].addr),
+				 frag->size);
+			pci_unmap_page(mdev->pdev,
+				       (dma_addr_t) be64_to_cpu(data[i].addr),
+				       frag->size, PCI_DMA_TODEVICE);
+		}
+		/* Stamp the freed descriptor */
+		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE; i += STAMP_STRIDE) {
+			*ptr = stamp;
+			ptr += STAMP_DWORDS;
+		}
+
+	} else {
+		if ((void *) data >= end) {
+			data = (struct mlx4_wqe_data_seg *)
+					(ring->buf + ((void *) data - end));
+		}
+
+		if (tx_info->linear) {
+			mlx4_dbg(mdev, "Unmapping Tx linear area -"
+				       " DMA:%llx size:%x\n",
+				  (dma_addr_t) be64_to_cpu(data->addr),
+				  be32_to_cpu(data->byte_count));
+			pci_unmap_single(mdev->pdev,
+					 (dma_addr_t) be64_to_cpu(data->addr),
+					 be32_to_cpu(data->byte_count),
+					 PCI_DMA_TODEVICE);
+			++data;
+		}
+
+		for (i = 0; i < frags; i++) {
+			/* Check for wraparound before unmapping */
+			if ((void *) data >= end)
+				data = (struct mlx4_wqe_data_seg *) ring->buf;
+			frag = &skb_shinfo(skb)->frags[i];
+			mlx4_dbg(mdev, "Unmapping Tx fragment at "
+				       "DMA:0x%llx size:0x%x\n",
+				 (dma_addr_t) be64_to_cpu(data->addr), frag->size);
+			pci_unmap_page(mdev->pdev,
+					(dma_addr_t) be64_to_cpu(data->addr),
+					 frag->size, PCI_DMA_TODEVICE);
+		}
+		/* Stamp the freed descriptor */
+		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE; i += STAMP_STRIDE) {
+			*ptr = stamp;
+			ptr += STAMP_DWORDS;
+			if ((void *) ptr >= end) {
+				ptr = ring->buf;
+				stamp ^= cpu_to_be32(0x80000000);
+			}
+		}
+
+	}
+	dev_kfree_skb_any(skb);
+	return tx_info->nr_txbb;
+}
+
+
+int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int cnt = 0;
+
+	/* Skip last polled descriptor */
+	ring->cons += ring->last_nr_txbb;
+	mlx4_dbg(priv->mdev, "Freeing Tx buf - cons:0x%x prod:0x%x\n",
+		 ring->cons, ring->prod);
+
+	if ((u32) (ring->prod - ring->cons) > ring->size) {
+		mlx4_dbg(priv->mdev, "Tx consumer passed producer!\n");
+		return 0;
+	}
+
+	while (ring->cons != ring->prod) {
+		ring->last_nr_txbb = mlx4_en_free_tx_desc(priv, ring,
+						ring->cons & ring->size_mask,
+						!!(ring->cons & ring->size));
+		ring->cons += ring->last_nr_txbb;
+		cnt++;
+	}
+
+	if (cnt)
+		mlx4_warn(priv->mdev, "Freed %d uncompleted tx descriptors\n", cnt);
+
+	return cnt;
+}
+
+void mlx4_en_set_prio_map(struct mlx4_en_dev *mdev, u16 *prio_map, u32 ring_num)
+{
+	int block = 8 / ring_num;
+	int extra = 8 - (block * ring_num);
+	int num = 0;
+	u16 ring = 1;
+	int prio;
+
+	mlx4_dbg(mdev, "Assigning priorities for %d rings:\n", ring_num);
+
+	if (ring_num == 1) {
+		for (prio = 0; prio < 8; prio++)
+			prio_map[prio] = 0;
+		return;
+	}
+
+	for (prio = 0; prio < 8; prio++) {
+		if (extra && (num == block + 1)) {
+			ring++;
+			num = 0;
+			extra--;
+		} else if (!extra && (num == block)) {
+			ring++;
+			num = 0;
+		}
+		prio_map[prio] = ring;
+		mlx4_dbg(mdev, "  prio:%d --> ring:%d\n", prio, ring);
+		num++;
+	}
+}
+
+void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_cq *mcq = &cq->mcq;
+	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];
+	struct mlx4_cqe *cqe = cq->buf;
+	u16 index;
+	u16 new_index;
+	u32 txbbs_skipped = 0;
+	u32 cq_last_sav;
+
+	/* index always points to the first TXBB of the last polled descriptor */
+	index = ring->cons & ring->size_mask;
+	new_index = be16_to_cpu(cqe->wqe_index) & ring->size_mask;
+	if (index == new_index)
+		return;
+
+	mlx4_dbg(mdev, "Starting to process Tx CQ for Tx ring:%d at index:%x "
+			"new_index:%x CPU:%d\n", cq->ring, index, new_index,
+			smp_processor_id());
+
+	if (!priv->port_up) {
+		mlx4_dbg(mdev, "tx cq processing attempted while port down\n");
+		return;
+	}
+
+	/*
+	 * We use a two-stage loop:
+	 * - the first samples the HW-updated CQE
+	 * - the second frees TXBBs until the last sample
+	 * This lets us amortize CQE cache misses, while still polling the CQ
+	 * until is quiescent.
+	 */
+	cq_last_sav = mcq->cons_index;
+	do {
+		do {
+			/* Skip over last polled CQE */
+			index = (index + ring->last_nr_txbb) & ring->size_mask;
+			txbbs_skipped += ring->last_nr_txbb;
+			mlx4_dbg(mdev, "Skipped %d TXBBs, new CQE to poll at "
+					"index:0x%x\n", txbbs_skipped, index);
+
+			/* Poll next CQE */
+			ring->last_nr_txbb = mlx4_en_free_tx_desc(
+						priv, ring, index,
+						!!((ring->cons + txbbs_skipped) &
+						   ring->size));
+			++mcq->cons_index;
+
+
+			mlx4_dbg(mdev, "Polled CQ consumed %d TXBBs, cq->last "
+					"incremented to:%d\n",
+					ring->last_nr_txbb, mcq->cons_index);
+
+		} while (index != new_index);
+
+		new_index = be16_to_cpu(cqe->wqe_index) & ring->size_mask;
+		mlx4_dbg(mdev, "Sampled new_index:%x\n", new_index);
+	} while (index != new_index);
+	AVG_PERF_COUNTER(priv->pstats.tx_coal_avg,
+			 (u32) (mcq->cons_index - cq_last_sav));
+
+	/*
+	 * To prevent CQ overflow we first update CQ consumer and only then
+	 * the ring consumer.
+	 */
+	mlx4_dbg(mdev, "Updating Tx CQ ci - cons:0x%x\n", mcq->cons_index);
+	mlx4_cq_set_ci(mcq);
+	wmb();
+	ring->cons += txbbs_skipped;
+
+	/* Wakeup Tx queue if this ring stopped it */
+	if (unlikely(ring->blocked)) {
+		mlx4_dbg(mdev, "Detected blocked (full) Tx queue\n");
+		if ((u32) (ring->prod - ring->cons - 1 + HEADROOM) <=
+		    ring->size - MAX_DESC_TXBBS - 1) {
+
+			mlx4_dbg(mdev, "reenabling transmission by Tx "
+					"ring:%d\n", cq->ring);
+
+			/* TODO: support multiqueue netdevs. Currently, we block
+			 * when *any* ring is full. Note that:
+			 * - 2 Tx rings can unblock at the same time and call
+			 *   netif_wake_queue(), which is OK since this
+			 *   operation is idempotent.
+			 * - We might wake the queue just after another ring
+			 *   stopped it. This is no big deal because the next
+			 *   transmission on that ring would stop the queue.
+			 */
+			ring->blocked = 0;
+			netif_wake_queue(dev);
+		}
+	}
+}
+
+void mlx4_en_poll_tx_cq(unsigned long data)
+{
+	struct mlx4_en_cq *cq = (struct mlx4_en_cq *) data;
+	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
+	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];
+	u32 inflight;
+
+	mlx4_dbg(priv->mdev, "tx timer called for ring:%d\n", cq->ring);
+	INC_PERF_COUNTER(priv->pstats.tx_poll);
+
+	netif_tx_lock(priv->dev);
+	mlx4_en_process_tx_cq(cq->dev, cq);
+	inflight = (u32) (ring->prod - ring->cons - ring->last_nr_txbb);
+
+	/* If there are still packets in flight and the timer has not already
+	 * been scheduled by the Tx routine then schedule it here to guarantee
+	 * completion processing of these packets */
+	if (inflight && priv->port_up) {
+		mlx4_dbg(priv->mdev, "Poll completed with %d packets inflight: "
+			 "rescheduling\n", inflight);
+		mod_timer(&cq->timer, ring->blocked ?
+				      1 : jiffies + MLX4_EN_TX_POLL_TIMEOUT);
+	}
+	netif_tx_unlock(priv->dev);
+}
+
+static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
+						      struct mlx4_en_tx_ring *ring,
+						      u32 index,
+						      unsigned int desc_size)
+{
+	u32 copy = (ring->size - index) * TXBB_SIZE;
+	int i;
+
+	for (i = desc_size - copy - 4; i >= 0; i -= 4) {
+		*((u32 *) (ring->buf + i)) =
+			*((u32 *) (ring->bounce_buf + copy + i));
+	}
+
+	for (i = copy - 4; i >= 4 ; i -= 4) {
+		*((u32 *) (ring->buf + index * TXBB_SIZE + i)) =
+			*((u32 *) (ring->bounce_buf + i));
+	}
+
+	/* Return real descriptor location */
+	return ring->buf + index * TXBB_SIZE;
+}
+
+static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)
+{
+	struct mlx4_en_cq *cq = &priv->tx_cq[tx_ind];
+	struct mlx4_en_tx_ring *ring = &priv->tx_ring[tx_ind];
+
+	/* If we don't have a pending timer, set one up to catch our recent
+	   post in case the interface becomes idle */
+	if (!timer_pending(&cq->timer)) {
+		mlx4_dbg(priv->mdev, "Setting new timer\n");
+		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);
+	}
+
+	/* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
+	if ((ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) == 0) {
+		mlx4_dbg(priv->mdev, "Polling Tx CQ from xmit\n");
+		mlx4_en_process_tx_cq(priv->dev, cq);
+	}
+	mlx4_dbg(priv->mdev, "Done polling tx ring %d\n", tx_ind);
+}
+
+int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_tx_ring *ring;
+	struct mlx4_en_cq *cq;
+	struct mlx4_en_tx_desc *tx_desc;
+	struct mlx4_wqe_data_seg *data;
+	struct skb_frag_struct *frag;
+	struct mlx4_en_tx_info *tx_info;
+	int tx_ind = 0;
+	unsigned int nr_frags;
+	int nr_txbb;
+	unsigned int desc_size;
+	unsigned int real_size;
+	dma_addr_t dma;
+	u32 index;
+	__be32 op_own;
+	u16 vlan_tag = 0;
+	int lso_header_size = 0;
+	int len;
+	int i;
+
+	mlx4_dbg(mdev, "xmit called on CPU:%d\n", smp_processor_id());
+
+	if (!skb->len) {
+		dev_kfree_skb_any(skb);
+		return 0;
+	}
+	len = skb_headlen(skb);
+
+	/* Calculate descriptor size and check limits */
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	desc_size = CTRL_SIZE + nr_frags * DS_SIZE;
+	if (skb_is_gso(skb)) {
+		lso_header_size = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		desc_size += ALIGN(lso_header_size + 4, DS_SIZE);
+		if (unlikely(lso_header_size != len)) {
+			/* We add a segment for the skb linear buffer only if
+			 * it contains data */
+			if (lso_header_size < len)
+				desc_size += DS_SIZE;
+			else {
+				mlx4_warn(mdev, "Non-linear headers\n");
+				dev_kfree_skb_any(skb);
+				return 0;
+			}
+		}
+		if (unlikely(lso_header_size > MAX_LSO_HDR_SIZE)) {
+			mlx4_dbg(mdev, "Lso header size too big\n");
+			dev_kfree_skb_any(skb);
+			return 0;
+		}
+	} else {
+		/* Add a segment for the skb linear buffer */
+		desc_size += DS_SIZE;
+	}
+
+	/* Allign descriptor to TXBB size */
+	real_size = desc_size;
+	desc_size = ALIGN(desc_size, TXBB_SIZE);
+	mlx4_dbg(mdev, "Base desc size:%d actual size:%d\n",
+			real_size, desc_size);
+	nr_txbb = desc_size / TXBB_SIZE;
+	if (unlikely(nr_txbb > MAX_DESC_TXBBS)) {
+		mlx4_warn(mdev, "Oversized header or SG list\n");
+		dev_kfree_skb_any(skb);
+		return 0;
+	}
+
+	/* Obtain VLAN information if present */
+	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
+		vlan_tag = vlan_tx_tag_get(skb);
+		mlx4_dbg(mdev, "Accepted Tx packet with vlan:0x%x prio:%d\n",
+			  vlan_tag, vlan_tag >> 13);
+		/* Set the Tx ring to use according to vlan priority */
+		tx_ind = priv->tx_prio_map[vlan_tag >> 13];
+	}
+	mlx4_dbg(mdev, "Using Tx ring:%d\n", tx_ind);
+
+	/* Occasionally give up the opportunity to send to let other CPUs
+	 * do so. This prevents cpu softlocks when another CPU is pumping
+	 * frames into the qdisc and HW process frames at a faster rate
+	 * than the qdisc is dequeud. */
+	ring = &priv->tx_ring[tx_ind];
+	++ring->poll_cnt;
+	if (!ring->poll_cnt)
+		return NETDEV_TX_BUSY;
+
+	/* Now that we know what Tx ring to use */
+	if (unlikely(!priv->port_up)) {
+		mlx4_dbg(mdev, "xmit: port down!\n");
+		dev_kfree_skb_any(skb);
+		return 0;
+	}
+
+	/* Track current inflight packets for performance analysis */
+	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
+			 (u32) (ring->prod - ring->cons - 1));
+
+	/* Check available TXBBs + 1 spare TXBB for owenership.
+	 * And 2K spare for prefetch */
+	if (unlikely(((int)((ring->cons - ring->prod) & ring->size_mask) -
+							nr_txbb) < HEADROOM)) {
+		/* every full Tx ring stops queue.
+		 * TODO: implement multi-queue support (per-queue stop) */
+		mlx4_dbg(mdev, "Out of TXBBs in ring:%d - "
+				"stopping queue\n", tx_ind);
+		netif_stop_queue(dev);
+		ring->blocked = 1;
+		priv->port_stats.queue_stopped++;
+
+		/* Schedule a timer as soon
+		 * as possible to check the queue again */
+		cq = &priv->tx_cq[tx_ind];
+		mod_timer(&cq->timer, jiffies + 1);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Packet is good - grab an index and transmit it */
+	index = ring->prod & ring->size_mask;
+
+	/* See if we have enough space for whole descriptor + 1 TXBB for setting
+	 * SW ownership on next descriptor; if not, use a bounce buffer. */
+	if (index + nr_txbb <= ring->size) {
+		tx_desc = ring->buf + index * TXBB_SIZE;
+		PREFETCH((void *) tx_desc + 2 * SMP_CACHE_BYTES);
+		PREFETCH((void *) tx_desc + 3 * SMP_CACHE_BYTES);
+	} else
+		tx_desc = (struct mlx4_en_tx_desc *) ring->bounce_buf;
+
+	mlx4_dbg(mdev, "Writing Tx descriptor at addr:%p offset:0x%x "
+			"size:%d\n", tx_desc, index * TXBB_SIZE, desc_size);
+
+	/* Save skb in tx_info ring */
+	tx_info = &ring->tx_info[index];
+	tx_info->skb = skb;
+	tx_info->nr_txbb = nr_txbb;
+	tx_info->frags = nr_frags;
+
+	/* Prepare ctrl segement apart opcode+ownership, which depends on
+	 * whether LSO is used */
+	tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
+	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!tx_ind;
+	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
+	tx_desc->ctrl.srcrb_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
+						MLX4_WQE_CTRL_SOLICITED);
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
+		mlx4_dbg(mdev, "Requesting HW Tx checksum\n");
+		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
+							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
+	}
+
+	/* Handle LSO (TSO) packets */
+	if (lso_header_size) {
+		mlx4_dbg(mdev, "Appending LSO segment (header size:%d)\n",
+			  lso_header_size);
+
+		/* Mark opcode as LSO */
+		op_own = cpu_to_be32(MLX4_OPCODE_LSO | (1 << 6)) |
+			((ring->prod & ring->size) ?
+				cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
+
+		/* Fill in the LSO prefix */
+		tx_desc->lso.mss_hdr_size = cpu_to_be32(
+			skb_shinfo(skb)->gso_size << 16 | lso_header_size);
+
+		/* Copy headers;
+		 * note that we already verified that it is linear */
+		memcpy(tx_desc->lso.header, skb->data, lso_header_size);
+		data = ((void *) &tx_desc->lso +
+			ALIGN(lso_header_size + 4, DS_SIZE));
+
+		INC_PERF_COUNTER(priv->pstats.tso);
+		SET_SW_COUNTER(i, ((skb->len - lso_header_size) /
+				   skb_shinfo(skb)->gso_size) +
+				   !!((skb->len - lso_header_size) %
+				   skb_shinfo(skb)->gso_size));
+		ADD_SW_COUNTER(ring->bytes, skb->len + (i - 1) * lso_header_size);
+		ADD_SW_COUNTER(ring->packets, i);
+	} else {
+		/* Normal (Non LSO) packet */
+		op_own = cpu_to_be32(MLX4_OPCODE_SEND) |
+			((ring->prod & ring->size) ?
+			 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
+		data = &tx_desc->data;
+		ADD_SW_COUNTER(ring->bytes, MAX(skb->len, ETH_ZLEN));
+		INC_SW_COUNTER(ring->packets);
+
+	}
+	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, skb->len);
+
+	tx_info->data_offset = (void *) data - (void *) tx_desc;
+	mlx4_dbg(mdev, "Data starts at <%p> \n", data);
+
+	tx_info->linear = (lso_header_size < len) ? 1 : 0;
+	data += nr_frags + tx_info->linear - 1;
+
+	/* Map fragments */
+	for (i = nr_frags - 1; i >= 0; i--) {
+		frag = &skb_shinfo(skb)->frags[i];
+		dma = pci_map_page(mdev->dev->pdev, frag->page, frag->page_offset,
+				   frag->size, PCI_DMA_TODEVICE);
+		data->addr = cpu_to_be64(dma);
+		data->lkey = cpu_to_be32(mdev->mr.key);
+		wmb();
+		data->byte_count = cpu_to_be32(frag->size);
+		mlx4_dbg(mdev, "Mapping Tx fragment at dma:%llx size:%d\n",
+			  (u64) dma, frag->size);
+		--data;
+	}
+
+	/* Map linear part */
+	if (tx_info->linear) {
+		dma = pci_map_single(mdev->dev->pdev, skb->data + lso_header_size,
+				     len - lso_header_size, PCI_DMA_TODEVICE);
+		data->addr = cpu_to_be64(dma);
+		data->lkey = cpu_to_be32(mdev->mr.key);
+		wmb();
+		data->byte_count = cpu_to_be32(len - lso_header_size);
+		mlx4_dbg(mdev, "Mapping Tx buffer at addr:%p dma:%llx size:%d "
+			  "(skb-len:%d skb-datalen:%d)\n", skb->data, (u64) dma,
+			  len - lso_header_size, skb->len, skb->data_len);
+	} else {
+		++tx_info;
+		mlx4_dbg(mdev, "SKB linear buffer contains only LSO headers\n");
+	}
+
+	ring->prod += nr_txbb;
+
+	/* If we used a bounce buffer then copy descriptor back into place */
+	if (tx_desc == (struct mlx4_en_tx_desc *) ring->bounce_buf)
+		tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
+
+	/* Run destructor before passing skb to HW */
+	if (likely(!skb_shared(skb)))
+		skb_orphan(skb);
+
+	/* Ensure new descirptor hits memory
+	 * before setting ownership of this descriptor to HW */
+	wmb();
+	tx_desc->ctrl.owner_opcode = op_own;
+
+	/* Ring doorbell! */
+	wmb();
+	mlx4_dbg(mdev, "Ringing Tx DB\n");
+	writel(ring->doorbell_qpn, mdev->uar_map + MLX4_SEND_DOORBELL);
+	dev->trans_start = jiffies;
+
+	/* Poll CQ here */
+	mlx4_en_xmit_poll(priv, tx_ind);
+
+	return 0;
+}
+
+
+
+
+
+
-- 
1.5.4





