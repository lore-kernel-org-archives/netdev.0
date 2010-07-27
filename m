From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 4/8] bnx2x: Create bnx2x_cmn.* files
Date: Wed, 28 Jul 2010 01:34:34 +0300
Message-ID: <1280270074.11551.103.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2722 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001Ab0G0Wmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 18:42:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newly created files have no functionality changes,
but includes some functionality from bnx2x_main.c which
is common for PF and coming in the future VF driver.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/Makefile     |    2 +-
 drivers/net/bnx2x/bnx2x.h      |    1 +
 drivers/net/bnx2x/bnx2x_cmn.c  | 2251 ++++++++++++++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_cmn.h  |  652 ++++++++++
 drivers/net/bnx2x/bnx2x_main.c | 2637 +---------------------------------------
 5 files changed, 2943 insertions(+), 2600 deletions(-)
 create mode 100644 drivers/net/bnx2x/bnx2x_cmn.c
 create mode 100644 drivers/net/bnx2x/bnx2x_cmn.h

diff --git a/drivers/net/bnx2x/Makefile b/drivers/net/bnx2x/Makefile
index 46c853b..ef4eebb 100644
--- a/drivers/net/bnx2x/Makefile
+++ b/drivers/net/bnx2x/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_BNX2X) += bnx2x.o
 
-bnx2x-objs := bnx2x_main.o bnx2x_link.o
+bnx2x-objs := bnx2x_main.o bnx2x_link.o bnx2x_cmn.o
diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 4afd292..2605070 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -45,6 +45,7 @@
 #endif
 
 #include <linux/mdio.h>
+#include <linux/pci.h>
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
 #include "bnx2x_hsi.h"
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
new file mode 100644
index 0000000..30d20c7
--- /dev/null
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -0,0 +1,2251 @@
+/* bnx2x_cmn.c: Broadcom Everest network driver.
+ *
+ * Copyright (c) 2007-2010 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
+ * Based on code from Michael Chan's bnx2 driver
+ * UDP CSUM errata workaround by Arik Gendelman
+ * Slowpath and fastpath rework by Vladislav Zolotarov
+ * Statistics and Link management by Yitchak Gertner
+ *
+ */
+
+
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include "bnx2x_cmn.h"
+
+#ifdef BCM_VLAN
+#include <linux/if_vlan.h>
+#endif
+
+static int bnx2x_poll(struct napi_struct *napi, int budget);
+
+/* free skb in the packet ring at pos idx
+ * return idx of last bd freed
+ */
+static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			     u16 idx)
+{
+	struct sw_tx_bd *tx_buf = &fp->tx_buf_ring[idx];
+	struct eth_tx_start_bd *tx_start_bd;
+	struct eth_tx_bd *tx_data_bd;
+	struct sk_buff *skb = tx_buf->skb;
+	u16 bd_idx = TX_BD(tx_buf->first_bd), new_cons;
+	int nbd;
+
+	/* prefetch skb end pointer to speedup dev_kfree_skb() */
+	prefetch(&skb->end);
+
+	DP(BNX2X_MSG_OFF, "pkt_idx %d  buff @(%p)->skb %p\n",
+	   idx, tx_buf, skb);
+
+	/* unmap first bd */
+	DP(BNX2X_MSG_OFF, "free bd_idx %d\n", bd_idx);
+	tx_start_bd = &fp->tx_desc_ring[bd_idx].start_bd;
+	dma_unmap_single(&bp->pdev->dev, BD_UNMAP_ADDR(tx_start_bd),
+			 BD_UNMAP_LEN(tx_start_bd), PCI_DMA_TODEVICE);
+
+	nbd = le16_to_cpu(tx_start_bd->nbd) - 1;
+#ifdef BNX2X_STOP_ON_ERROR
+	if ((nbd - 1) > (MAX_SKB_FRAGS + 2)) {
+		BNX2X_ERR("BAD nbd!\n");
+		bnx2x_panic();
+	}
+#endif
+	new_cons = nbd + tx_buf->first_bd;
+
+	/* Get the next bd */
+	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+
+	/* Skip a parse bd... */
+	--nbd;
+	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+
+	/* ...and the TSO split header bd since they have no mapping */
+	if (tx_buf->flags & BNX2X_TSO_SPLIT_BD) {
+		--nbd;
+		bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+	}
+
+	/* now free frags */
+	while (nbd > 0) {
+
+		DP(BNX2X_MSG_OFF, "free frag bd_idx %d\n", bd_idx);
+		tx_data_bd = &fp->tx_desc_ring[bd_idx].reg_bd;
+		dma_unmap_page(&bp->pdev->dev, BD_UNMAP_ADDR(tx_data_bd),
+			       BD_UNMAP_LEN(tx_data_bd), DMA_TO_DEVICE);
+		if (--nbd)
+			bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+	}
+
+	/* release skb */
+	WARN_ON(!skb);
+	dev_kfree_skb(skb);
+	tx_buf->first_bd = 0;
+	tx_buf->skb = NULL;
+
+	return new_cons;
+}
+
+int bnx2x_tx_int(struct bnx2x_fastpath *fp)
+{
+	struct bnx2x *bp = fp->bp;
+	struct netdev_queue *txq;
+	u16 hw_cons, sw_cons, bd_cons = fp->tx_bd_cons;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return -1;
+#endif
+
+	txq = netdev_get_tx_queue(bp->dev, fp->index);
+	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
+	sw_cons = fp->tx_pkt_cons;
+
+	while (sw_cons != hw_cons) {
+		u16 pkt_cons;
+
+		pkt_cons = TX_BD(sw_cons);
+
+		/* prefetch(bp->tx_buf_ring[pkt_cons].skb); */
+
+		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %u\n",
+		   hw_cons, sw_cons, pkt_cons);
+
+/*		if (NEXT_TX_IDX(sw_cons) != hw_cons) {
+			rmb();
+			prefetch(fp->tx_buf_ring[NEXT_TX_IDX(sw_cons)].skb);
+		}
+*/
+		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
+		sw_cons++;
+	}
+
+	fp->tx_pkt_cons = sw_cons;
+	fp->tx_bd_cons = bd_cons;
+
+	/* Need to make the tx_bd_cons update visible to start_xmit()
+	 * before checking for netif_tx_queue_stopped().  Without the
+	 * memory barrier, there is a small possibility that
+	 * start_xmit() will miss it and cause the queue to be stopped
+	 * forever.
+	 */
+	smp_mb();
+
+	/* TBD need a thresh? */
+	if (unlikely(netif_tx_queue_stopped(txq))) {
+		/* Taking tx_lock() is needed to prevent reenabling the queue
+		 * while it's empty. This could have happen if rx_action() gets
+		 * suspended in bnx2x_tx_int() after the condition before
+		 * netif_tx_wake_queue(), while tx_action (bnx2x_start_xmit()):
+		 *
+		 * stops the queue->sees fresh tx_bd_cons->releases the queue->
+		 * sends some packets consuming the whole queue again->
+		 * stops the queue
+		 */
+
+		__netif_tx_lock(txq, smp_processor_id());
+
+		if ((netif_tx_queue_stopped(txq)) &&
+		    (bp->state == BNX2X_STATE_OPEN) &&
+		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
+			netif_tx_wake_queue(txq);
+
+		__netif_tx_unlock(txq);
+	}
+	return 0;
+}
+
+static inline void bnx2x_update_last_max_sge(struct bnx2x_fastpath *fp,
+					     u16 idx)
+{
+	u16 last_max = fp->last_max_sge;
+
+	if (SUB_S16(idx, last_max) > 0)
+		fp->last_max_sge = idx;
+}
+
+static void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
+				  struct eth_fast_path_rx_cqe *fp_cqe)
+{
+	struct bnx2x *bp = fp->bp;
+	u16 sge_len = SGE_PAGE_ALIGN(le16_to_cpu(fp_cqe->pkt_len) -
+				     le16_to_cpu(fp_cqe->len_on_bd)) >>
+		      SGE_PAGE_SHIFT;
+	u16 last_max, last_elem, first_elem;
+	u16 delta = 0;
+	u16 i;
+
+	if (!sge_len)
+		return;
+
+	/* First mark all used pages */
+	for (i = 0; i < sge_len; i++)
+		SGE_MASK_CLEAR_BIT(fp, RX_SGE(le16_to_cpu(fp_cqe->sgl[i])));
+
+	DP(NETIF_MSG_RX_STATUS, "fp_cqe->sgl[%d] = %d\n",
+	   sge_len - 1, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
+
+	/* Here we assume that the last SGE index is the biggest */
+	prefetch((void *)(fp->sge_mask));
+	bnx2x_update_last_max_sge(fp, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
+
+	last_max = RX_SGE(fp->last_max_sge);
+	last_elem = last_max >> RX_SGE_MASK_ELEM_SHIFT;
+	first_elem = RX_SGE(fp->rx_sge_prod) >> RX_SGE_MASK_ELEM_SHIFT;
+
+	/* If ring is not full */
+	if (last_elem + 1 != first_elem)
+		last_elem++;
+
+	/* Now update the prod */
+	for (i = first_elem; i != last_elem; i = NEXT_SGE_MASK_ELEM(i)) {
+		if (likely(fp->sge_mask[i]))
+			break;
+
+		fp->sge_mask[i] = RX_SGE_MASK_ELEM_ONE_MASK;
+		delta += RX_SGE_MASK_ELEM_SZ;
+	}
+
+	if (delta > 0) {
+		fp->rx_sge_prod += delta;
+		/* clear page-end entries */
+		bnx2x_clear_sge_mask_next_elems(fp);
+	}
+
+	DP(NETIF_MSG_RX_STATUS,
+	   "fp->last_max_sge = %d  fp->rx_sge_prod = %d\n",
+	   fp->last_max_sge, fp->rx_sge_prod);
+}
+
+static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
+			    struct sk_buff *skb, u16 cons, u16 prod)
+{
+	struct bnx2x *bp = fp->bp;
+	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
+	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
+	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
+	dma_addr_t mapping;
+
+	/* move empty skb from pool to prod and map it */
+	prod_rx_buf->skb = fp->tpa_pool[queue].skb;
+	mapping = dma_map_single(&bp->pdev->dev, fp->tpa_pool[queue].skb->data,
+				 bp->rx_buf_size, DMA_FROM_DEVICE);
+	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
+
+	/* move partial skb from cons to pool (don't unmap yet) */
+	fp->tpa_pool[queue] = *cons_rx_buf;
+
+	/* mark bin state as start - print error if current state != stop */
+	if (fp->tpa_state[queue] != BNX2X_TPA_STOP)
+		BNX2X_ERR("start of bin not in stop [%d]\n", queue);
+
+	fp->tpa_state[queue] = BNX2X_TPA_START;
+
+	/* point prod_bd to new skb */
+	prod_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	prod_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+
+#ifdef BNX2X_STOP_ON_ERROR
+	fp->tpa_queue_used |= (1 << queue);
+#ifdef _ASM_GENERIC_INT_L64_H
+	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
+#else
+	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
+#endif
+	   fp->tpa_queue_used);
+#endif
+}
+
+static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			       struct sk_buff *skb,
+			       struct eth_fast_path_rx_cqe *fp_cqe,
+			       u16 cqe_idx)
+{
+	struct sw_rx_page *rx_pg, old_rx_pg;
+	u16 len_on_bd = le16_to_cpu(fp_cqe->len_on_bd);
+	u32 i, frag_len, frag_size, pages;
+	int err;
+	int j;
+
+	frag_size = le16_to_cpu(fp_cqe->pkt_len) - len_on_bd;
+	pages = SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
+
+	/* This is needed in order to enable forwarding support */
+	if (frag_size)
+		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
+					       max(frag_size, (u32)len_on_bd));
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (pages > min_t(u32, 8, MAX_SKB_FRAGS)*SGE_PAGE_SIZE*PAGES_PER_SGE) {
+		BNX2X_ERR("SGL length is too long: %d. CQE index is %d\n",
+			  pages, cqe_idx);
+		BNX2X_ERR("fp_cqe->pkt_len = %d  fp_cqe->len_on_bd = %d\n",
+			  fp_cqe->pkt_len, len_on_bd);
+		bnx2x_panic();
+		return -EINVAL;
+	}
+#endif
+
+	/* Run through the SGL and compose the fragmented skb */
+	for (i = 0, j = 0; i < pages; i += PAGES_PER_SGE, j++) {
+		u16 sge_idx = RX_SGE(le16_to_cpu(fp_cqe->sgl[j]));
+
+		/* FW gives the indices of the SGE as if the ring is an array
+		   (meaning that "next" element will consume 2 indices) */
+		frag_len = min(frag_size, (u32)(SGE_PAGE_SIZE*PAGES_PER_SGE));
+		rx_pg = &fp->rx_page_ring[sge_idx];
+		old_rx_pg = *rx_pg;
+
+		/* If we fail to allocate a substitute page, we simply stop
+		   where we are and drop the whole packet */
+		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx);
+		if (unlikely(err)) {
+			fp->eth_q_stats.rx_skb_alloc_failed++;
+			return err;
+		}
+
+		/* Unmap the page as we r going to pass it to the stack */
+		dma_unmap_page(&bp->pdev->dev,
+			       dma_unmap_addr(&old_rx_pg, mapping),
+			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
+
+		/* Add one frag and update the appropriate fields in the skb */
+		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
+
+		skb->data_len += frag_len;
+		skb->truesize += frag_len;
+		skb->len += frag_len;
+
+		frag_size -= frag_len;
+	}
+
+	return 0;
+}
+
+static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			   u16 queue, int pad, int len, union eth_rx_cqe *cqe,
+			   u16 cqe_idx)
+{
+	struct sw_rx_bd *rx_buf = &fp->tpa_pool[queue];
+	struct sk_buff *skb = rx_buf->skb;
+	/* alloc new skb */
+	struct sk_buff *new_skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+
+	/* Unmap skb in the pool anyway, as we are going to change
+	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
+	   fails. */
+	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
+			 bp->rx_buf_size, DMA_FROM_DEVICE);
+
+	if (likely(new_skb)) {
+		/* fix ip xsum and give it to the stack */
+		/* (no need to map the new skb) */
+#ifdef BCM_VLAN
+		int is_vlan_cqe =
+			(le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
+			 PARSING_FLAGS_VLAN);
+		int is_not_hwaccel_vlan_cqe =
+			(is_vlan_cqe && (!(bp->flags & HW_VLAN_RX_FLAG)));
+#endif
+
+		prefetch(skb);
+		prefetch(((char *)(skb)) + 128);
+
+#ifdef BNX2X_STOP_ON_ERROR
+		if (pad + len > bp->rx_buf_size) {
+			BNX2X_ERR("skb_put is about to fail...  "
+				  "pad %d  len %d  rx_buf_size %d\n",
+				  pad, len, bp->rx_buf_size);
+			bnx2x_panic();
+			return;
+		}
+#endif
+
+		skb_reserve(skb, pad);
+		skb_put(skb, len);
+
+		skb->protocol = eth_type_trans(skb, bp->dev);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		{
+			struct iphdr *iph;
+
+			iph = (struct iphdr *)skb->data;
+#ifdef BCM_VLAN
+			/* If there is no Rx VLAN offloading -
+			   take VLAN tag into an account */
+			if (unlikely(is_not_hwaccel_vlan_cqe))
+				iph = (struct iphdr *)((u8 *)iph + VLAN_HLEN);
+#endif
+			iph->check = 0;
+			iph->check = ip_fast_csum((u8 *)iph, iph->ihl);
+		}
+
+		if (!bnx2x_fill_frag_skb(bp, fp, skb,
+					 &cqe->fast_path_cqe, cqe_idx)) {
+#ifdef BCM_VLAN
+			if ((bp->vlgrp != NULL) && is_vlan_cqe &&
+			    (!is_not_hwaccel_vlan_cqe))
+				vlan_gro_receive(&fp->napi, bp->vlgrp,
+						 le16_to_cpu(cqe->fast_path_cqe.
+							     vlan_tag), skb);
+			else
+#endif
+				napi_gro_receive(&fp->napi, skb);
+		} else {
+			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new pages"
+			   " - dropping packet!\n");
+			dev_kfree_skb(skb);
+		}
+
+
+		/* put new skb in bin */
+		fp->tpa_pool[queue].skb = new_skb;
+
+	} else {
+		/* else drop the packet and keep the buffer in the bin */
+		DP(NETIF_MSG_RX_STATUS,
+		   "Failed to allocate new skb - dropping packet!\n");
+		fp->eth_q_stats.rx_skb_alloc_failed++;
+	}
+
+	fp->tpa_state[queue] = BNX2X_TPA_STOP;
+}
+
+/* Set Toeplitz hash value in the skb using the value from the
+ * CQE (calculated by HW).
+ */
+static inline void bnx2x_set_skb_rxhash(struct bnx2x *bp, union eth_rx_cqe *cqe,
+					struct sk_buff *skb)
+{
+	/* Set Toeplitz hash from CQE */
+	if ((bp->dev->features & NETIF_F_RXHASH) &&
+	    (cqe->fast_path_cqe.status_flags &
+	     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
+		skb->rxhash =
+		le32_to_cpu(cqe->fast_path_cqe.rss_hash_result);
+}
+
+int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
+{
+	struct bnx2x *bp = fp->bp;
+	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
+	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
+	int rx_pkt = 0;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return 0;
+#endif
+
+	/* CQ "next element" is of the size of the regular element,
+	   that's why it's ok here */
+	hw_comp_cons = le16_to_cpu(*fp->rx_cons_sb);
+	if ((hw_comp_cons & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
+		hw_comp_cons++;
+
+	bd_cons = fp->rx_bd_cons;
+	bd_prod = fp->rx_bd_prod;
+	bd_prod_fw = bd_prod;
+	sw_comp_cons = fp->rx_comp_cons;
+	sw_comp_prod = fp->rx_comp_prod;
+
+	/* Memory barrier necessary as speculative reads of the rx
+	 * buffer can be ahead of the index in the status block
+	 */
+	rmb();
+
+	DP(NETIF_MSG_RX_STATUS,
+	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
+	   fp->index, hw_comp_cons, sw_comp_cons);
+
+	while (sw_comp_cons != hw_comp_cons) {
+		struct sw_rx_bd *rx_buf = NULL;
+		struct sk_buff *skb;
+		union eth_rx_cqe *cqe;
+		u8 cqe_fp_flags;
+		u16 len, pad;
+
+		comp_ring_cons = RCQ_BD(sw_comp_cons);
+		bd_prod = RX_BD(bd_prod);
+		bd_cons = RX_BD(bd_cons);
+
+		/* Prefetch the page containing the BD descriptor
+		   at producer's index. It will be needed when new skb is
+		   allocated */
+		prefetch((void *)(PAGE_ALIGN((unsigned long)
+					     (&fp->rx_desc_ring[bd_prod])) -
+				  PAGE_SIZE + 1));
+
+		cqe = &fp->rx_comp_ring[comp_ring_cons];
+		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
+
+		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
+		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
+		   cqe_fp_flags, cqe->fast_path_cqe.status_flags,
+		   le32_to_cpu(cqe->fast_path_cqe.rss_hash_result),
+		   le16_to_cpu(cqe->fast_path_cqe.vlan_tag),
+		   le16_to_cpu(cqe->fast_path_cqe.pkt_len));
+
+		/* is this a slowpath msg? */
+		if (unlikely(CQE_TYPE(cqe_fp_flags))) {
+			bnx2x_sp_event(fp, cqe);
+			goto next_cqe;
+
+		/* this is an rx packet */
+		} else {
+			rx_buf = &fp->rx_buf_ring[bd_cons];
+			skb = rx_buf->skb;
+			prefetch(skb);
+			len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
+			pad = cqe->fast_path_cqe.placement_offset;
+
+			/* If CQE is marked both TPA_START and TPA_END
+			   it is a non-TPA CQE */
+			if ((!fp->disable_tpa) &&
+			    (TPA_TYPE(cqe_fp_flags) !=
+					(TPA_TYPE_START | TPA_TYPE_END))) {
+				u16 queue = cqe->fast_path_cqe.queue_index;
+
+				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_START) {
+					DP(NETIF_MSG_RX_STATUS,
+					   "calling tpa_start on queue %d\n",
+					   queue);
+
+					bnx2x_tpa_start(fp, queue, skb,
+							bd_cons, bd_prod);
+
+					/* Set Toeplitz hash for an LRO skb */
+					bnx2x_set_skb_rxhash(bp, cqe, skb);
+
+					goto next_rx;
+				}
+
+				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_END) {
+					DP(NETIF_MSG_RX_STATUS,
+					   "calling tpa_stop on queue %d\n",
+					   queue);
+
+					if (!BNX2X_RX_SUM_FIX(cqe))
+						BNX2X_ERR("STOP on none TCP "
+							  "data\n");
+
+					/* This is a size of the linear data
+					   on this skb */
+					len = le16_to_cpu(cqe->fast_path_cqe.
+								len_on_bd);
+					bnx2x_tpa_stop(bp, fp, queue, pad,
+						    len, cqe, comp_ring_cons);
+#ifdef BNX2X_STOP_ON_ERROR
+					if (bp->panic)
+						return 0;
+#endif
+
+					bnx2x_update_sge_prod(fp,
+							&cqe->fast_path_cqe);
+					goto next_cqe;
+				}
+			}
+
+			dma_sync_single_for_device(&bp->pdev->dev,
+					dma_unmap_addr(rx_buf, mapping),
+						   pad + RX_COPY_THRESH,
+						   DMA_FROM_DEVICE);
+			prefetch(((char *)(skb)) + 128);
+
+			/* is this an error packet? */
+			if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
+				DP(NETIF_MSG_RX_ERR,
+				   "ERROR  flags %x  rx packet %u\n",
+				   cqe_fp_flags, sw_comp_cons);
+				fp->eth_q_stats.rx_err_discard_pkt++;
+				goto reuse_rx;
+			}
+
+			/* Since we don't have a jumbo ring
+			 * copy small packets if mtu > 1500
+			 */
+			if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
+			    (len <= RX_COPY_THRESH)) {
+				struct sk_buff *new_skb;
+
+				new_skb = netdev_alloc_skb(bp->dev,
+							   len + pad);
+				if (new_skb == NULL) {
+					DP(NETIF_MSG_RX_ERR,
+					   "ERROR  packet dropped "
+					   "because of alloc failure\n");
+					fp->eth_q_stats.rx_skb_alloc_failed++;
+					goto reuse_rx;
+				}
+
+				/* aligned copy */
+				skb_copy_from_linear_data_offset(skb, pad,
+						    new_skb->data + pad, len);
+				skb_reserve(new_skb, pad);
+				skb_put(new_skb, len);
+
+				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
+
+				skb = new_skb;
+
+			} else
+			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
+				dma_unmap_single(&bp->pdev->dev,
+					dma_unmap_addr(rx_buf, mapping),
+						 bp->rx_buf_size,
+						 DMA_FROM_DEVICE);
+				skb_reserve(skb, pad);
+				skb_put(skb, len);
+
+			} else {
+				DP(NETIF_MSG_RX_ERR,
+				   "ERROR  packet dropped because "
+				   "of alloc failure\n");
+				fp->eth_q_stats.rx_skb_alloc_failed++;
+reuse_rx:
+				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
+				goto next_rx;
+			}
+
+			skb->protocol = eth_type_trans(skb, bp->dev);
+
+			/* Set Toeplitz hash for a none-LRO skb */
+			bnx2x_set_skb_rxhash(bp, cqe, skb);
+
+			skb->ip_summed = CHECKSUM_NONE;
+			if (bp->rx_csum) {
+				if (likely(BNX2X_RX_CSUM_OK(cqe)))
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				else
+					fp->eth_q_stats.hw_csum_err++;
+			}
+		}
+
+		skb_record_rx_queue(skb, fp->index);
+
+#ifdef BCM_VLAN
+		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
+		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
+		     PARSING_FLAGS_VLAN))
+			vlan_gro_receive(&fp->napi, bp->vlgrp,
+				le16_to_cpu(cqe->fast_path_cqe.vlan_tag), skb);
+		else
+#endif
+			napi_gro_receive(&fp->napi, skb);
+
+
+next_rx:
+		rx_buf->skb = NULL;
+
+		bd_cons = NEXT_RX_IDX(bd_cons);
+		bd_prod = NEXT_RX_IDX(bd_prod);
+		bd_prod_fw = NEXT_RX_IDX(bd_prod_fw);
+		rx_pkt++;
+next_cqe:
+		sw_comp_prod = NEXT_RCQ_IDX(sw_comp_prod);
+		sw_comp_cons = NEXT_RCQ_IDX(sw_comp_cons);
+
+		if (rx_pkt == budget)
+			break;
+	} /* while */
+
+	fp->rx_bd_cons = bd_cons;
+	fp->rx_bd_prod = bd_prod_fw;
+	fp->rx_comp_cons = sw_comp_cons;
+	fp->rx_comp_prod = sw_comp_prod;
+
+	/* Update producers */
+	bnx2x_update_rx_prod(bp, fp, bd_prod_fw, sw_comp_prod,
+			     fp->rx_sge_prod);
+
+	fp->rx_pkt += rx_pkt;
+	fp->rx_calls++;
+
+	return rx_pkt;
+}
+
+static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
+{
+	struct bnx2x_fastpath *fp = fp_cookie;
+	struct bnx2x *bp = fp->bp;
+
+	/* Return here if interrupt is disabled */
+	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
+		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
+		return IRQ_HANDLED;
+	}
+
+	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
+	   fp->index, fp->sb_id);
+	bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return IRQ_HANDLED;
+#endif
+
+	/* Handle Rx and Tx according to MSI-X vector */
+	prefetch(fp->rx_cons_sb);
+	prefetch(fp->tx_cons_sb);
+	prefetch(&fp->status_blk->u_status_block.status_block_index);
+	prefetch(&fp->status_blk->c_status_block.status_block_index);
+	napi_schedule(&bnx2x_fp(bp, fp->index, napi));
+
+	return IRQ_HANDLED;
+}
+
+
+/* HW Lock for shared dual port PHYs */
+void bnx2x_acquire_phy_lock(struct bnx2x *bp)
+{
+	mutex_lock(&bp->port.phy_mutex);
+
+	if (bp->port.need_hw_lock)
+		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
+}
+
+void bnx2x_release_phy_lock(struct bnx2x *bp)
+{
+	if (bp->port.need_hw_lock)
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
+
+	mutex_unlock(&bp->port.phy_mutex);
+}
+
+void bnx2x_link_report(struct bnx2x *bp)
+{
+	if (bp->flags & MF_FUNC_DIS) {
+		netif_carrier_off(bp->dev);
+		netdev_err(bp->dev, "NIC Link is Down\n");
+		return;
+	}
+
+	if (bp->link_vars.link_up) {
+		u16 line_speed;
+
+		if (bp->state == BNX2X_STATE_OPEN)
+			netif_carrier_on(bp->dev);
+		netdev_info(bp->dev, "NIC Link is Up, ");
+
+		line_speed = bp->link_vars.line_speed;
+		if (IS_E1HMF(bp)) {
+			u16 vn_max_rate;
+
+			vn_max_rate =
+				((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
+				 FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+			if (vn_max_rate < line_speed)
+				line_speed = vn_max_rate;
+		}
+		pr_cont("%d Mbps ", line_speed);
+
+		if (bp->link_vars.duplex == DUPLEX_FULL)
+			pr_cont("full duplex");
+		else
+			pr_cont("half duplex");
+
+		if (bp->link_vars.flow_ctrl != BNX2X_FLOW_CTRL_NONE) {
+			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) {
+				pr_cont(", receive ");
+				if (bp->link_vars.flow_ctrl &
+				    BNX2X_FLOW_CTRL_TX)
+					pr_cont("& transmit ");
+			} else {
+				pr_cont(", transmit ");
+			}
+			pr_cont("flow control ON");
+		}
+		pr_cont("\n");
+
+	} else { /* link_down */
+		netif_carrier_off(bp->dev);
+		netdev_err(bp->dev, "NIC Link is Down\n");
+	}
+}
+
+void bnx2x_init_rx_rings(struct bnx2x *bp)
+{
+	int func = BP_FUNC(bp);
+	int max_agg_queues = CHIP_IS_E1(bp) ? ETH_MAX_AGGREGATION_QUEUES_E1 :
+					      ETH_MAX_AGGREGATION_QUEUES_E1H;
+	u16 ring_prod, cqe_ring_prod;
+	int i, j;
+
+	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN;
+	DP(NETIF_MSG_IFUP,
+	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
+
+	if (bp->flags & TPA_ENABLE_FLAG) {
+
+		for_each_queue(bp, j) {
+			struct bnx2x_fastpath *fp = &bp->fp[j];
+
+			for (i = 0; i < max_agg_queues; i++) {
+				fp->tpa_pool[i].skb =
+				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+				if (!fp->tpa_pool[i].skb) {
+					BNX2X_ERR("Failed to allocate TPA "
+						  "skb pool for queue[%d] - "
+						  "disabling TPA on this "
+						  "queue!\n", j);
+					bnx2x_free_tpa_pool(bp, fp, i);
+					fp->disable_tpa = 1;
+					break;
+				}
+				dma_unmap_addr_set((struct sw_rx_bd *)
+							&bp->fp->tpa_pool[i],
+						   mapping, 0);
+				fp->tpa_state[i] = BNX2X_TPA_STOP;
+			}
+		}
+	}
+
+	for_each_queue(bp, j) {
+		struct bnx2x_fastpath *fp = &bp->fp[j];
+
+		fp->rx_bd_cons = 0;
+		fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
+		fp->rx_bd_cons_sb = BNX2X_RX_SB_BD_INDEX;
+
+		/* "next page" elements initialization */
+		/* SGE ring */
+		for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
+			struct eth_rx_sge *sge;
+
+			sge = &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
+			sge->addr_hi =
+				cpu_to_le32(U64_HI(fp->rx_sge_mapping +
+					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+			sge->addr_lo =
+				cpu_to_le32(U64_LO(fp->rx_sge_mapping +
+					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
+		}
+
+		bnx2x_init_sge_ring_bit_mask(fp);
+
+		/* RX BD ring */
+		for (i = 1; i <= NUM_RX_RINGS; i++) {
+			struct eth_rx_bd *rx_bd;
+
+			rx_bd = &fp->rx_desc_ring[RX_DESC_CNT * i - 2];
+			rx_bd->addr_hi =
+				cpu_to_le32(U64_HI(fp->rx_desc_mapping +
+					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
+			rx_bd->addr_lo =
+				cpu_to_le32(U64_LO(fp->rx_desc_mapping +
+					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
+		}
+
+		/* CQ ring */
+		for (i = 1; i <= NUM_RCQ_RINGS; i++) {
+			struct eth_rx_cqe_next_page *nextpg;
+
+			nextpg = (struct eth_rx_cqe_next_page *)
+				&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
+			nextpg->addr_hi =
+				cpu_to_le32(U64_HI(fp->rx_comp_mapping +
+					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+			nextpg->addr_lo =
+				cpu_to_le32(U64_LO(fp->rx_comp_mapping +
+					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
+		}
+
+		/* Allocate SGEs and initialize the ring elements */
+		for (i = 0, ring_prod = 0;
+		     i < MAX_RX_SGE_CNT*NUM_RX_SGE_PAGES; i++) {
+
+			if (bnx2x_alloc_rx_sge(bp, fp, ring_prod) < 0) {
+				BNX2X_ERR("was only able to allocate "
+					  "%d rx sges\n", i);
+				BNX2X_ERR("disabling TPA for queue[%d]\n", j);
+				/* Cleanup already allocated elements */
+				bnx2x_free_rx_sge_range(bp, fp, ring_prod);
+				bnx2x_free_tpa_pool(bp, fp, max_agg_queues);
+				fp->disable_tpa = 1;
+				ring_prod = 0;
+				break;
+			}
+			ring_prod = NEXT_SGE_IDX(ring_prod);
+		}
+		fp->rx_sge_prod = ring_prod;
+
+		/* Allocate BDs and initialize BD ring */
+		fp->rx_comp_cons = 0;
+		cqe_ring_prod = ring_prod = 0;
+		for (i = 0; i < bp->rx_ring_size; i++) {
+			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
+				BNX2X_ERR("was only able to allocate "
+					  "%d rx skbs on queue[%d]\n", i, j);
+				fp->eth_q_stats.rx_skb_alloc_failed++;
+				break;
+			}
+			ring_prod = NEXT_RX_IDX(ring_prod);
+			cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
+			WARN_ON(ring_prod <= i);
+		}
+
+		fp->rx_bd_prod = ring_prod;
+		/* must not have more available CQEs than BDs */
+		fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
+					 cqe_ring_prod);
+		fp->rx_pkt = fp->rx_calls = 0;
+
+		/* Warning!
+		 * this will generate an interrupt (to the TSTORM)
+		 * must only be done after chip is initialized
+		 */
+		bnx2x_update_rx_prod(bp, fp, ring_prod, fp->rx_comp_prod,
+				     fp->rx_sge_prod);
+		if (j != 0)
+			continue;
+
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func),
+		       U64_LO(fp->rx_comp_mapping));
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func) + 4,
+		       U64_HI(fp->rx_comp_mapping));
+	}
+}
+static void bnx2x_free_tx_skbs(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		u16 bd_cons = fp->tx_bd_cons;
+		u16 sw_prod = fp->tx_pkt_prod;
+		u16 sw_cons = fp->tx_pkt_cons;
+
+		while (sw_cons != sw_prod) {
+			bd_cons = bnx2x_free_tx_pkt(bp, fp, TX_BD(sw_cons));
+			sw_cons++;
+		}
+	}
+}
+
+static void bnx2x_free_rx_skbs(struct bnx2x *bp)
+{
+	int i, j;
+
+	for_each_queue(bp, j) {
+		struct bnx2x_fastpath *fp = &bp->fp[j];
+
+		for (i = 0; i < NUM_RX_BD; i++) {
+			struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[i];
+			struct sk_buff *skb = rx_buf->skb;
+
+			if (skb == NULL)
+				continue;
+
+			dma_unmap_single(&bp->pdev->dev,
+					 dma_unmap_addr(rx_buf, mapping),
+					 bp->rx_buf_size, DMA_FROM_DEVICE);
+
+			rx_buf->skb = NULL;
+			dev_kfree_skb(skb);
+		}
+		if (!fp->disable_tpa)
+			bnx2x_free_tpa_pool(bp, fp, CHIP_IS_E1(bp) ?
+					    ETH_MAX_AGGREGATION_QUEUES_E1 :
+					    ETH_MAX_AGGREGATION_QUEUES_E1H);
+	}
+}
+
+void bnx2x_free_skbs(struct bnx2x *bp)
+{
+	bnx2x_free_tx_skbs(bp);
+	bnx2x_free_rx_skbs(bp);
+}
+
+static void bnx2x_free_msix_irqs(struct bnx2x *bp)
+{
+	int i, offset = 1;
+
+	free_irq(bp->msix_table[0].vector, bp->dev);
+	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
+	   bp->msix_table[0].vector);
+
+#ifdef BCM_CNIC
+	offset++;
+#endif
+	for_each_queue(bp, i) {
+		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
+		   "state %x\n", i, bp->msix_table[i + offset].vector,
+		   bnx2x_fp(bp, i, state));
+
+		free_irq(bp->msix_table[i + offset].vector, &bp->fp[i]);
+	}
+}
+
+void bnx2x_free_irq(struct bnx2x *bp, bool disable_only)
+{
+	if (bp->flags & USING_MSIX_FLAG) {
+		if (!disable_only)
+			bnx2x_free_msix_irqs(bp);
+		pci_disable_msix(bp->pdev);
+		bp->flags &= ~USING_MSIX_FLAG;
+
+	} else if (bp->flags & USING_MSI_FLAG) {
+		if (!disable_only)
+			free_irq(bp->pdev->irq, bp->dev);
+		pci_disable_msi(bp->pdev);
+		bp->flags &= ~USING_MSI_FLAG;
+
+	} else if (!disable_only)
+		free_irq(bp->pdev->irq, bp->dev);
+}
+
+static int bnx2x_enable_msix(struct bnx2x *bp)
+{
+	int i, rc, offset = 1;
+	int igu_vec = 0;
+
+	bp->msix_table[0].entry = igu_vec;
+	DP(NETIF_MSG_IFUP, "msix_table[0].entry = %d (slowpath)\n", igu_vec);
+
+#ifdef BCM_CNIC
+	igu_vec = BP_L_ID(bp) + offset;
+	bp->msix_table[1].entry = igu_vec;
+	DP(NETIF_MSG_IFUP, "msix_table[1].entry = %d (CNIC)\n", igu_vec);
+	offset++;
+#endif
+	for_each_queue(bp, i) {
+		igu_vec = BP_L_ID(bp) + offset + i;
+		bp->msix_table[i + offset].entry = igu_vec;
+		DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d "
+		   "(fastpath #%u)\n", i + offset, igu_vec, i);
+	}
+
+	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
+			     BNX2X_NUM_QUEUES(bp) + offset);
+
+	/*
+	 * reconfigure number of tx/rx queues according to available
+	 * MSI-X vectors
+	 */
+	if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
+		/* vectors available for FP */
+		int fp_vec = rc - BNX2X_MSIX_VEC_FP_START;
+
+		DP(NETIF_MSG_IFUP,
+		   "Trying to use less MSI-X vectors: %d\n", rc);
+
+		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
+
+		if (rc) {
+			DP(NETIF_MSG_IFUP,
+			   "MSI-X is not attainable  rc %d\n", rc);
+			return rc;
+		}
+
+		bp->num_queues = min(bp->num_queues, fp_vec);
+
+		DP(NETIF_MSG_IFUP, "New queue configuration set: %d\n",
+				  bp->num_queues);
+	} else if (rc) {
+		DP(NETIF_MSG_IFUP, "MSI-X is not attainable  rc %d\n", rc);
+		return rc;
+	}
+
+	bp->flags |= USING_MSIX_FLAG;
+
+	return 0;
+}
+
+static int bnx2x_req_msix_irqs(struct bnx2x *bp)
+{
+	int i, rc, offset = 1;
+
+	rc = request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
+			 bp->dev->name, bp->dev);
+	if (rc) {
+		BNX2X_ERR("request sp irq failed\n");
+		return -EBUSY;
+	}
+
+#ifdef BCM_CNIC
+	offset++;
+#endif
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
+			 bp->dev->name, i);
+
+		rc = request_irq(bp->msix_table[i + offset].vector,
+				 bnx2x_msix_fp_int, 0, fp->name, fp);
+		if (rc) {
+			BNX2X_ERR("request fp #%d irq failed  rc %d\n", i, rc);
+			bnx2x_free_msix_irqs(bp);
+			return -EBUSY;
+		}
+
+		fp->state = BNX2X_FP_STATE_IRQ;
+	}
+
+	i = BNX2X_NUM_QUEUES(bp);
+	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d"
+	       " ... fp[%d] %d\n",
+	       bp->msix_table[0].vector,
+	       0, bp->msix_table[offset].vector,
+	       i - 1, bp->msix_table[offset + i - 1].vector);
+
+	return 0;
+}
+
+static int bnx2x_enable_msi(struct bnx2x *bp)
+{
+	int rc;
+
+	rc = pci_enable_msi(bp->pdev);
+	if (rc) {
+		DP(NETIF_MSG_IFUP, "MSI is not attainable\n");
+		return -1;
+	}
+	bp->flags |= USING_MSI_FLAG;
+
+	return 0;
+}
+
+static int bnx2x_req_irq(struct bnx2x *bp)
+{
+	unsigned long flags;
+	int rc;
+
+	if (bp->flags & USING_MSI_FLAG)
+		flags = 0;
+	else
+		flags = IRQF_SHARED;
+
+	rc = request_irq(bp->pdev->irq, bnx2x_interrupt, flags,
+			 bp->dev->name, bp->dev);
+	if (!rc)
+		bnx2x_fp(bp, 0, state) = BNX2X_FP_STATE_IRQ;
+
+	return rc;
+}
+
+static void bnx2x_napi_enable(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i)
+		napi_enable(&bnx2x_fp(bp, i, napi));
+}
+
+static void bnx2x_napi_disable(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_queue(bp, i)
+		napi_disable(&bnx2x_fp(bp, i, napi));
+}
+
+void bnx2x_netif_start(struct bnx2x *bp)
+{
+	int intr_sem;
+
+	intr_sem = atomic_dec_and_test(&bp->intr_sem);
+	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
+
+	if (intr_sem) {
+		if (netif_running(bp->dev)) {
+			bnx2x_napi_enable(bp);
+			bnx2x_int_enable(bp);
+			if (bp->state == BNX2X_STATE_OPEN)
+				netif_tx_wake_all_queues(bp->dev);
+		}
+	}
+}
+
+void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
+{
+	bnx2x_int_disable_sync(bp, disable_hw);
+	bnx2x_napi_disable(bp);
+	netif_tx_disable(bp->dev);
+}
+static int bnx2x_set_num_queues(struct bnx2x *bp)
+{
+	int rc = 0;
+
+	switch (bp->int_mode) {
+	case INT_MODE_INTx:
+	case INT_MODE_MSI:
+		bp->num_queues = 1;
+		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
+		break;
+	default:
+		/* Set number of queues according to bp->multi_mode value */
+		bnx2x_set_num_queues_msix(bp);
+
+		DP(NETIF_MSG_IFUP, "set number of queues to %d\n",
+		   bp->num_queues);
+
+		/* if we can't use MSI-X we only need one fp,
+		 * so try to enable MSI-X with the requested number of fp's
+		 * and fallback to MSI or legacy INTx with one fp
+		 */
+		rc = bnx2x_enable_msix(bp);
+		if (rc)
+			/* failed to enable MSI-X */
+			bp->num_queues = 1;
+		break;
+	}
+	bp->dev->real_num_tx_queues = bp->num_queues;
+	return rc;
+}
+
+/* must be called with rtnl_lock */
+int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
+{
+	u32 load_code;
+	int i, rc;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return -EPERM;
+#endif
+
+	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
+
+	rc = bnx2x_set_num_queues(bp);
+
+	if (bnx2x_alloc_mem(bp)) {
+		bnx2x_free_irq(bp, true);
+		return -ENOMEM;
+	}
+
+	for_each_queue(bp, i)
+		bnx2x_fp(bp, i, disable_tpa) =
+					((bp->flags & TPA_ENABLE_FLAG) == 0);
+
+	for_each_queue(bp, i)
+		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
+			       bnx2x_poll, 128);
+
+	bnx2x_napi_enable(bp);
+
+	if (bp->flags & USING_MSIX_FLAG) {
+		rc = bnx2x_req_msix_irqs(bp);
+		if (rc) {
+			bnx2x_free_irq(bp, true);
+			goto load_error1;
+		}
+	} else {
+		/* Fall to INTx if failed to enable MSI-X due to lack of
+		   memory (in bnx2x_set_num_queues()) */
+		if ((rc != -ENOMEM) && (bp->int_mode != INT_MODE_INTx))
+			bnx2x_enable_msi(bp);
+		bnx2x_ack_int(bp);
+		rc = bnx2x_req_irq(bp);
+		if (rc) {
+			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
+			bnx2x_free_irq(bp, true);
+			goto load_error1;
+		}
+		if (bp->flags & USING_MSI_FLAG) {
+			bp->dev->irq = bp->pdev->irq;
+			netdev_info(bp->dev, "using MSI  IRQ %d\n",
+				    bp->pdev->irq);
+		}
+	}
+
+	/* Send LOAD_REQUEST command to MCP
+	   Returns the type of LOAD command:
+	   if it is the first port to be initialized
+	   common blocks should be initialized, otherwise - not
+	*/
+	if (!BP_NOMCP(bp)) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, aborting\n");
+			rc = -EBUSY;
+			goto load_error2;
+		}
+		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
+			rc = -EBUSY; /* other port in diagnostic mode */
+			goto load_error2;
+		}
+
+	} else {
+		int port = BP_PORT(bp);
+
+		DP(NETIF_MSG_IFUP, "NO MCP - load counts      %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		load_count[0]++;
+		load_count[1 + port]++;
+		DP(NETIF_MSG_IFUP, "NO MCP - new load counts  %d, %d, %d\n",
+		   load_count[0], load_count[1], load_count[2]);
+		if (load_count[0] == 1)
+			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
+		else if (load_count[1 + port] == 1)
+			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
+		else
+			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
+	}
+
+	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
+	    (load_code == FW_MSG_CODE_DRV_LOAD_PORT))
+		bp->port.pmf = 1;
+	else
+		bp->port.pmf = 0;
+	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
+
+	/* Initialize HW */
+	rc = bnx2x_init_hw(bp, load_code);
+	if (rc) {
+		BNX2X_ERR("HW init failed, aborting\n");
+		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+		goto load_error2;
+	}
+
+	/* Setup NIC internals and enable interrupts */
+	bnx2x_nic_init(bp, load_code);
+
+	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) &&
+	    (bp->common.shmem2_base))
+		SHMEM2_WR(bp, dcc_support,
+			  (SHMEM_DCC_SUPPORT_DISABLE_ENABLE_PF_TLV |
+			   SHMEM_DCC_SUPPORT_BANDWIDTH_ALLOCATION_TLV));
+
+	/* Send LOAD_DONE command to MCP */
+	if (!BP_NOMCP(bp)) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, aborting\n");
+			rc = -EBUSY;
+			goto load_error3;
+		}
+	}
+
+	bp->state = BNX2X_STATE_OPENING_WAIT4_PORT;
+
+	rc = bnx2x_setup_leading(bp);
+	if (rc) {
+		BNX2X_ERR("Setup leading failed!\n");
+#ifndef BNX2X_STOP_ON_ERROR
+		goto load_error3;
+#else
+		bp->panic = 1;
+		return -EBUSY;
+#endif
+	}
+
+	if (CHIP_IS_E1H(bp))
+		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
+			DP(NETIF_MSG_IFUP, "mf_cfg function disabled\n");
+			bp->flags |= MF_FUNC_DIS;
+		}
+
+	if (bp->state == BNX2X_STATE_OPEN) {
+#ifdef BCM_CNIC
+		/* Enable Timer scan */
+		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 1);
+#endif
+		for_each_nondefault_queue(bp, i) {
+			rc = bnx2x_setup_multi(bp, i);
+			if (rc)
+#ifdef BCM_CNIC
+				goto load_error4;
+#else
+				goto load_error3;
+#endif
+		}
+
+		if (CHIP_IS_E1(bp))
+			bnx2x_set_eth_mac_addr_e1(bp, 1);
+		else
+			bnx2x_set_eth_mac_addr_e1h(bp, 1);
+#ifdef BCM_CNIC
+		/* Set iSCSI L2 MAC */
+		mutex_lock(&bp->cnic_mutex);
+		if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
+			bnx2x_set_iscsi_eth_mac_addr(bp, 1);
+			bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
+			bnx2x_init_sb(bp, bp->cnic_sb, bp->cnic_sb_mapping,
+				      CNIC_SB_ID(bp));
+		}
+		mutex_unlock(&bp->cnic_mutex);
+#endif
+	}
+
+	if (bp->port.pmf)
+		bnx2x_initial_phy_init(bp, load_mode);
+
+	/* Start fast path */
+	switch (load_mode) {
+	case LOAD_NORMAL:
+		if (bp->state == BNX2X_STATE_OPEN) {
+			/* Tx queue should be only reenabled */
+			netif_tx_wake_all_queues(bp->dev);
+		}
+		/* Initialize the receive filter. */
+		bnx2x_set_rx_mode(bp->dev);
+		break;
+
+	case LOAD_OPEN:
+		netif_tx_start_all_queues(bp->dev);
+		if (bp->state != BNX2X_STATE_OPEN)
+			netif_tx_disable(bp->dev);
+		/* Initialize the receive filter. */
+		bnx2x_set_rx_mode(bp->dev);
+		break;
+
+	case LOAD_DIAG:
+		/* Initialize the receive filter. */
+		bnx2x_set_rx_mode(bp->dev);
+		bp->state = BNX2X_STATE_DIAG;
+		break;
+
+	default:
+		break;
+	}
+
+	if (!bp->port.pmf)
+		bnx2x__link_status_update(bp);
+
+	/* start the timer */
+	mod_timer(&bp->timer, jiffies + bp->current_interval);
+
+#ifdef BCM_CNIC
+	bnx2x_setup_cnic_irq_info(bp);
+	if (bp->state == BNX2X_STATE_OPEN)
+		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
+#endif
+	bnx2x_inc_load_cnt(bp);
+
+	return 0;
+
+#ifdef BCM_CNIC
+load_error4:
+	/* Disable Timer scan */
+	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 0);
+#endif
+load_error3:
+	bnx2x_int_disable_sync(bp, 1);
+	if (!BP_NOMCP(bp)) {
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+	}
+	bp->port.pmf = 0;
+	/* Free SKBs, SGEs, TPA pool and driver internals */
+	bnx2x_free_skbs(bp);
+	for_each_queue(bp, i)
+		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
+load_error2:
+	/* Release IRQs */
+	bnx2x_free_irq(bp, false);
+load_error1:
+	bnx2x_napi_disable(bp);
+	for_each_queue(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
+	bnx2x_free_mem(bp);
+
+	return rc;
+}
+
+/* must be called with rtnl_lock */
+int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
+{
+	int i;
+
+	if (bp->state == BNX2X_STATE_CLOSED) {
+		/* Interface has been removed - nothing to recover */
+		bp->recovery_state = BNX2X_RECOVERY_DONE;
+		bp->is_leader = 0;
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
+		smp_wmb();
+
+		return -EINVAL;
+	}
+
+#ifdef BCM_CNIC
+	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
+#endif
+	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
+
+	/* Set "drop all" */
+	bp->rx_mode = BNX2X_RX_MODE_NONE;
+	bnx2x_set_storm_rx_mode(bp);
+
+	/* Disable HW interrupts, NAPI and Tx */
+	bnx2x_netif_stop(bp, 1);
+	netif_carrier_off(bp->dev);
+
+	del_timer_sync(&bp->timer);
+	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
+		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
+	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+
+	/* Release IRQs */
+	bnx2x_free_irq(bp, false);
+
+	/* Cleanup the chip if needed */
+	if (unload_mode != UNLOAD_RECOVERY)
+		bnx2x_chip_cleanup(bp, unload_mode);
+
+	bp->port.pmf = 0;
+
+	/* Free SKBs, SGEs, TPA pool and driver internals */
+	bnx2x_free_skbs(bp);
+	for_each_queue(bp, i)
+		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
+	for_each_queue(bp, i)
+		netif_napi_del(&bnx2x_fp(bp, i, napi));
+	bnx2x_free_mem(bp);
+
+	bp->state = BNX2X_STATE_CLOSED;
+
+	/* The last driver must disable a "close the gate" if there is no
+	 * parity attention or "process kill" pending.
+	 */
+	if ((!bnx2x_dec_load_cnt(bp)) && (!bnx2x_chk_parity_attn(bp)) &&
+	    bnx2x_reset_is_done(bp))
+		bnx2x_disable_close_the_gate(bp);
+
+	/* Reset MCP mail box sequence if there is on going recovery */
+	if (unload_mode == UNLOAD_RECOVERY)
+		bp->fw_seq = 0;
+
+	return 0;
+}
+int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
+{
+	u16 pmcsr;
+
+	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmcsr);
+
+	switch (state) {
+	case PCI_D0:
+		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
+				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
+				       PCI_PM_CTRL_PME_STATUS));
+
+		if (pmcsr & PCI_PM_CTRL_STATE_MASK)
+			/* delay required during transition out of D3hot */
+			msleep(20);
+		break;
+
+	case PCI_D3hot:
+		/* If there are other clients above don't
+		   shut down the power */
+		if (atomic_read(&bp->pdev->enable_cnt) != 1)
+			return 0;
+		/* Don't shut down the power for emulation and FPGA */
+		if (CHIP_REV_IS_SLOW(bp))
+			return 0;
+
+		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
+		pmcsr |= 3;
+
+		if (bp->wol)
+			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
+
+		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
+				      pmcsr);
+
+		/* No more memory access after this point until
+		* device is brought back to D0.
+		*/
+		break;
+
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
+
+
+/*
+ * net_device service functions
+ */
+
+static int bnx2x_poll(struct napi_struct *napi, int budget)
+{
+	int work_done = 0;
+	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
+						 napi);
+	struct bnx2x *bp = fp->bp;
+
+	while (1) {
+#ifdef BNX2X_STOP_ON_ERROR
+		if (unlikely(bp->panic)) {
+			napi_complete(napi);
+			return 0;
+		}
+#endif
+
+		if (bnx2x_has_tx_work(fp))
+			bnx2x_tx_int(fp);
+
+		if (bnx2x_has_rx_work(fp)) {
+			work_done += bnx2x_rx_int(fp, budget - work_done);
+
+			/* must not complete if we consumed full budget */
+			if (work_done >= budget)
+				break;
+		}
+
+		/* Fall out from the NAPI loop if needed */
+		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+			bnx2x_update_fpsb_idx(fp);
+		/* bnx2x_has_rx_work() reads the status block, thus we need
+		 * to ensure that status block indices have been actually read
+		 * (bnx2x_update_fpsb_idx) prior to this check
+		 * (bnx2x_has_rx_work) so that we won't write the "newer"
+		 * value of the status block to IGU (if there was a DMA right
+		 * after bnx2x_has_rx_work and if there is no rmb, the memory
+		 * reading (bnx2x_update_fpsb_idx) may be postponed to right
+		 * before bnx2x_ack_sb). In this case there will never be
+		 * another interrupt until there is another update of the
+		 * status block, while there is still unhandled work.
+		 */
+			rmb();
+
+			if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+				napi_complete(napi);
+				/* Re-enable interrupts */
+				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
+					     le16_to_cpu(fp->fp_c_idx),
+					     IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
+					     le16_to_cpu(fp->fp_u_idx),
+					     IGU_INT_ENABLE, 1);
+				break;
+			}
+		}
+	}
+
+	return work_done;
+}
+
+
+/* we split the first BD into headers and data BDs
+ * to ease the pain of our fellow microcode engineers
+ * we use one mapping for both BDs
+ * So far this has only been observed to happen
+ * in Other Operating Systems(TM)
+ */
+static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
+				   struct bnx2x_fastpath *fp,
+				   struct sw_tx_bd *tx_buf,
+				   struct eth_tx_start_bd **tx_bd, u16 hlen,
+				   u16 bd_prod, int nbd)
+{
+	struct eth_tx_start_bd *h_tx_bd = *tx_bd;
+	struct eth_tx_bd *d_tx_bd;
+	dma_addr_t mapping;
+	int old_len = le16_to_cpu(h_tx_bd->nbytes);
+
+	/* first fix first BD */
+	h_tx_bd->nbd = cpu_to_le16(nbd);
+	h_tx_bd->nbytes = cpu_to_le16(hlen);
+
+	DP(NETIF_MSG_TX_QUEUED,	"TSO split header size is %d "
+	   "(%x:%x) nbd %d\n", h_tx_bd->nbytes, h_tx_bd->addr_hi,
+	   h_tx_bd->addr_lo, h_tx_bd->nbd);
+
+	/* now get a new data BD
+	 * (after the pbd) and fill it */
+	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+	d_tx_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
+
+	mapping = HILO_U64(le32_to_cpu(h_tx_bd->addr_hi),
+			   le32_to_cpu(h_tx_bd->addr_lo)) + hlen;
+
+	d_tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	d_tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+	d_tx_bd->nbytes = cpu_to_le16(old_len - hlen);
+
+	/* this marks the BD as one that has no individual mapping */
+	tx_buf->flags |= BNX2X_TSO_SPLIT_BD;
+
+	DP(NETIF_MSG_TX_QUEUED,
+	   "TSO split data size is %d (%x:%x)\n",
+	   d_tx_bd->nbytes, d_tx_bd->addr_hi, d_tx_bd->addr_lo);
+
+	/* update tx_bd */
+	*tx_bd = (struct eth_tx_start_bd *)d_tx_bd;
+
+	return bd_prod;
+}
+
+static inline u16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8 fix)
+{
+	if (fix > 0)
+		csum = (u16) ~csum_fold(csum_sub(csum,
+				csum_partial(t_header - fix, fix, 0)));
+
+	else if (fix < 0)
+		csum = (u16) ~csum_fold(csum_add(csum,
+				csum_partial(t_header, -fix, 0)));
+
+	return swab16(csum);
+}
+
+static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
+{
+	u32 rc;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		rc = XMIT_PLAIN;
+
+	else {
+		if (skb->protocol == htons(ETH_P_IPV6)) {
+			rc = XMIT_CSUM_V6;
+			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+				rc |= XMIT_CSUM_TCP;
+
+		} else {
+			rc = XMIT_CSUM_V4;
+			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+				rc |= XMIT_CSUM_TCP;
+		}
+	}
+
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
+
+	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
+
+	return rc;
+}
+
+#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
+/* check if packet requires linearization (packet is too fragmented)
+   no need to check fragmentation if page size > 8K (there will be no
+   violation to FW restrictions) */
+static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
+			     u32 xmit_type)
+{
+	int to_copy = 0;
+	int hlen = 0;
+	int first_bd_sz = 0;
+
+	/* 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
+	if (skb_shinfo(skb)->nr_frags >= (MAX_FETCH_BD - 3)) {
+
+		if (xmit_type & XMIT_GSO) {
+			unsigned short lso_mss = skb_shinfo(skb)->gso_size;
+			/* Check if LSO packet needs to be copied:
+			   3 = 1 (for headers BD) + 2 (for PBD and last BD) */
+			int wnd_size = MAX_FETCH_BD - 3;
+			/* Number of windows to check */
+			int num_wnds = skb_shinfo(skb)->nr_frags - wnd_size;
+			int wnd_idx = 0;
+			int frag_idx = 0;
+			u32 wnd_sum = 0;
+
+			/* Headers length */
+			hlen = (int)(skb_transport_header(skb) - skb->data) +
+				tcp_hdrlen(skb);
+
+			/* Amount of data (w/o headers) on linear part of SKB*/
+			first_bd_sz = skb_headlen(skb) - hlen;
+
+			wnd_sum  = first_bd_sz;
+
+			/* Calculate the first sum - it's special */
+			for (frag_idx = 0; frag_idx < wnd_size - 1; frag_idx++)
+				wnd_sum +=
+					skb_shinfo(skb)->frags[frag_idx].size;
+
+			/* If there was data on linear skb data - check it */
+			if (first_bd_sz > 0) {
+				if (unlikely(wnd_sum < lso_mss)) {
+					to_copy = 1;
+					goto exit_lbl;
+				}
+
+				wnd_sum -= first_bd_sz;
+			}
+
+			/* Others are easier: run through the frag list and
+			   check all windows */
+			for (wnd_idx = 0; wnd_idx <= num_wnds; wnd_idx++) {
+				wnd_sum +=
+			  skb_shinfo(skb)->frags[wnd_idx + wnd_size - 1].size;
+
+				if (unlikely(wnd_sum < lso_mss)) {
+					to_copy = 1;
+					break;
+				}
+				wnd_sum -=
+					skb_shinfo(skb)->frags[wnd_idx].size;
+			}
+		} else {
+			/* in non-LSO too fragmented packet should always
+			   be linearized */
+			to_copy = 1;
+		}
+	}
+
+exit_lbl:
+	if (unlikely(to_copy))
+		DP(NETIF_MSG_TX_QUEUED,
+		   "Linearization IS REQUIRED for %s packet. "
+		   "num_frags %d  hlen %d  first_bd_sz %d\n",
+		   (xmit_type & XMIT_GSO) ? "LSO" : "non-LSO",
+		   skb_shinfo(skb)->nr_frags, hlen, first_bd_sz);
+
+	return to_copy;
+}
+#endif
+
+/* called with netif_tx_lock
+ * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
+ * netif_wake_queue()
+ */
+netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	struct bnx2x_fastpath *fp;
+	struct netdev_queue *txq;
+	struct sw_tx_bd *tx_buf;
+	struct eth_tx_start_bd *tx_start_bd;
+	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
+	struct eth_tx_parse_bd *pbd = NULL;
+	u16 pkt_prod, bd_prod;
+	int nbd, fp_index;
+	dma_addr_t mapping;
+	u32 xmit_type = bnx2x_xmit_type(bp, skb);
+	int i;
+	u8 hlen = 0;
+	__le16 pkt_size = 0;
+	struct ethhdr *eth;
+	u8 mac_type = UNICAST_ADDRESS;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (unlikely(bp->panic))
+		return NETDEV_TX_BUSY;
+#endif
+
+	fp_index = skb_get_queue_mapping(skb);
+	txq = netdev_get_tx_queue(dev, fp_index);
+
+	fp = &bp->fp[fp_index];
+
+	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
+		fp->eth_q_stats.driver_xoff++;
+		netif_tx_stop_queue(txq);
+		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
+		return NETDEV_TX_BUSY;
+	}
+
+	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)"
+	   "  gso type %x  xmit_type %x\n",
+	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
+	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
+
+	eth = (struct ethhdr *)skb->data;
+
+	/* set flag according to packet type (UNICAST_ADDRESS is default)*/
+	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
+		if (is_broadcast_ether_addr(eth->h_dest))
+			mac_type = BROADCAST_ADDRESS;
+		else
+			mac_type = MULTICAST_ADDRESS;
+	}
+
+#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
+	/* First, check if we need to linearize the skb (due to FW
+	   restrictions). No need to check fragmentation if page size > 8K
+	   (there will be no violation to FW restrictions) */
+	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
+		/* Statistics of linearization */
+		bp->lin_cnt++;
+		if (skb_linearize(skb) != 0) {
+			DP(NETIF_MSG_TX_QUEUED, "SKB linearization failed - "
+			   "silently dropping this SKB\n");
+			dev_kfree_skb_any(skb);
+			return NETDEV_TX_OK;
+		}
+	}
+#endif
+
+	/*
+	Please read carefully. First we use one BD which we mark as start,
+	then we have a parsing info BD (used for TSO or xsum),
+	and only then we have the rest of the TSO BDs.
+	(don't forget to mark the last one as last,
+	and to unmap only AFTER you write to the BD ...)
+	And above all, all pdb sizes are in words - NOT DWORDS!
+	*/
+
+	pkt_prod = fp->tx_pkt_prod++;
+	bd_prod = TX_BD(fp->tx_bd_prod);
+
+	/* get a tx_buf and first BD */
+	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
+	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
+
+	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
+	tx_start_bd->general_data =  (mac_type <<
+					ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
+	/* header nbd */
+	tx_start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
+
+	/* remember the first BD of the packet */
+	tx_buf->first_bd = fp->tx_bd_prod;
+	tx_buf->skb = skb;
+	tx_buf->flags = 0;
+
+	DP(NETIF_MSG_TX_QUEUED,
+	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
+	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_start_bd);
+
+#ifdef BCM_VLAN
+	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb) &&
+	    (bp->flags & HW_VLAN_TX_FLAG)) {
+		tx_start_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
+	} else
+#endif
+		tx_start_bd->vlan = cpu_to_le16(pkt_prod);
+
+	/* turn on parsing and get a BD */
+	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+	pbd = &fp->tx_desc_ring[bd_prod].parse_bd;
+
+	memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
+
+	if (xmit_type & XMIT_CSUM) {
+		hlen = (skb_network_header(skb) - skb->data) / 2;
+
+		/* for now NS flag is not used in Linux */
+		pbd->global_data =
+			(hlen | ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
+				 ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
+
+		pbd->ip_hlen = (skb_transport_header(skb) -
+				skb_network_header(skb)) / 2;
+
+		hlen += pbd->ip_hlen + tcp_hdrlen(skb) / 2;
+
+		pbd->total_hlen = cpu_to_le16(hlen);
+		hlen = hlen*2;
+
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
+
+		if (xmit_type & XMIT_CSUM_V4)
+			tx_start_bd->bd_flags.as_bitfield |=
+						ETH_TX_BD_FLAGS_IP_CSUM;
+		else
+			tx_start_bd->bd_flags.as_bitfield |=
+						ETH_TX_BD_FLAGS_IPV6;
+
+		if (xmit_type & XMIT_CSUM_TCP) {
+			pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
+
+		} else {
+			s8 fix = SKB_CS_OFF(skb); /* signed! */
+
+			pbd->global_data |= ETH_TX_PARSE_BD_UDP_CS_FLG;
+
+			DP(NETIF_MSG_TX_QUEUED,
+			   "hlen %d  fix %d  csum before fix %x\n",
+			   le16_to_cpu(pbd->total_hlen), fix, SKB_CS(skb));
+
+			/* HW bug: fixup the CSUM */
+			pbd->tcp_pseudo_csum =
+				bnx2x_csum_fix(skb_transport_header(skb),
+					       SKB_CS(skb), fix);
+
+			DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
+			   pbd->tcp_pseudo_csum);
+		}
+	}
+
+	mapping = dma_map_single(&bp->pdev->dev, skb->data,
+				 skb_headlen(skb), DMA_TO_DEVICE);
+
+	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+	nbd = skb_shinfo(skb)->nr_frags + 2; /* start_bd + pbd + frags */
+	tx_start_bd->nbd = cpu_to_le16(nbd);
+	tx_start_bd->nbytes = cpu_to_le16(skb_headlen(skb));
+	pkt_size = tx_start_bd->nbytes;
+
+	DP(NETIF_MSG_TX_QUEUED, "first bd @%p  addr (%x:%x)  nbd %d"
+	   "  nbytes %d  flags %x  vlan %x\n",
+	   tx_start_bd, tx_start_bd->addr_hi, tx_start_bd->addr_lo,
+	   le16_to_cpu(tx_start_bd->nbd), le16_to_cpu(tx_start_bd->nbytes),
+	   tx_start_bd->bd_flags.as_bitfield, le16_to_cpu(tx_start_bd->vlan));
+
+	if (xmit_type & XMIT_GSO) {
+
+		DP(NETIF_MSG_TX_QUEUED,
+		   "TSO packet len %d  hlen %d  total len %d  tso size %d\n",
+		   skb->len, hlen, skb_headlen(skb),
+		   skb_shinfo(skb)->gso_size);
+
+		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
+
+		if (unlikely(skb_headlen(skb) > hlen))
+			bd_prod = bnx2x_tx_split(bp, fp, tx_buf, &tx_start_bd,
+						 hlen, bd_prod, ++nbd);
+
+		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
+		pbd->tcp_flags = pbd_tcp_flags(skb);
+
+		if (xmit_type & XMIT_GSO_V4) {
+			pbd->ip_id = swab16(ip_hdr(skb)->id);
+			pbd->tcp_pseudo_csum =
+				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
+							  ip_hdr(skb)->daddr,
+							  0, IPPROTO_TCP, 0));
+
+		} else
+			pbd->tcp_pseudo_csum =
+				swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+							&ipv6_hdr(skb)->daddr,
+							0, IPPROTO_TCP, 0));
+
+		pbd->global_data |= ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
+	}
+	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+		tx_data_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
+		if (total_pkt_bd == NULL)
+			total_pkt_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
+
+		mapping = dma_map_page(&bp->pdev->dev, frag->page,
+				       frag->page_offset,
+				       frag->size, DMA_TO_DEVICE);
+
+		tx_data_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+		tx_data_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+		tx_data_bd->nbytes = cpu_to_le16(frag->size);
+		le16_add_cpu(&pkt_size, frag->size);
+
+		DP(NETIF_MSG_TX_QUEUED,
+		   "frag %d  bd @%p  addr (%x:%x)  nbytes %d\n",
+		   i, tx_data_bd, tx_data_bd->addr_hi, tx_data_bd->addr_lo,
+		   le16_to_cpu(tx_data_bd->nbytes));
+	}
+
+	DP(NETIF_MSG_TX_QUEUED, "last bd @%p\n", tx_data_bd);
+
+	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
+
+	/* now send a tx doorbell, counting the next BD
+	 * if the packet contains or ends with it
+	 */
+	if (TX_BD_POFF(bd_prod) < nbd)
+		nbd++;
+
+	if (total_pkt_bd != NULL)
+		total_pkt_bd->total_pkt_bytes = pkt_size;
+
+	if (pbd)
+		DP(NETIF_MSG_TX_QUEUED,
+		   "PBD @%p  ip_data %x  ip_hlen %u  ip_id %u  lso_mss %u"
+		   "  tcp_flags %x  xsum %x  seq %u  hlen %u\n",
+		   pbd, pbd->global_data, pbd->ip_hlen, pbd->ip_id,
+		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
+		   pbd->tcp_send_seq, le16_to_cpu(pbd->total_hlen));
+
+	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
+
+	/*
+	 * Make sure that the BD data is updated before updating the producer
+	 * since FW might read the BD right after the producer is updated.
+	 * This is only applicable for weak-ordered memory model archs such
+	 * as IA-64. The following barrier is also mandatory since FW will
+	 * assumes packets must have BDs.
+	 */
+	wmb();
+
+	fp->tx_db.data.prod += nbd;
+	barrier();
+	DOORBELL(bp, fp->index, fp->tx_db.raw);
+
+	mmiowb();
+
+	fp->tx_bd_prod += nbd;
+
+	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
+		netif_tx_stop_queue(txq);
+
+		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
+		 * ordering of set_bit() in netif_tx_stop_queue() and read of
+		 * fp->bd_tx_cons */
+		smp_mb();
+
+		fp->eth_q_stats.driver_xoff++;
+		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
+			netif_tx_wake_queue(txq);
+	}
+	fp->tx_pkt++;
+
+	return NETDEV_TX_OK;
+}
+/* called with rtnl_lock */
+int bnx2x_change_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct bnx2x *bp = netdev_priv(dev);
+
+	if (!is_valid_ether_addr((u8 *)(addr->sa_data)))
+		return -EINVAL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	if (netif_running(dev)) {
+		if (CHIP_IS_E1(bp))
+			bnx2x_set_eth_mac_addr_e1(bp, 1);
+		else
+			bnx2x_set_eth_mac_addr_e1h(bp, 1);
+	}
+
+	return 0;
+}
+
+/* called with rtnl_lock */
+int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int rc = 0;
+
+	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		return -EAGAIN;
+	}
+
+	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
+	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE))
+		return -EINVAL;
+
+	/* This does not race with packet allocation
+	 * because the actual alloc size is
+	 * only updated as part of load
+	 */
+	dev->mtu = new_mtu;
+
+	if (netif_running(dev)) {
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
+	}
+
+	return rc;
+}
+
+void bnx2x_tx_timeout(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+#ifdef BNX2X_STOP_ON_ERROR
+	if (!bp->panic)
+		bnx2x_panic();
+#endif
+	/* This allows the netif to be shutdown gracefully before resetting */
+	schedule_delayed_work(&bp->reset_task, 0);
+}
+
+#ifdef BCM_VLAN
+/* called with rtnl_lock */
+void bnx2x_vlan_rx_register(struct net_device *dev,
+				   struct vlan_group *vlgrp)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	bp->vlgrp = vlgrp;
+
+	/* Set flags according to the required capabilities */
+	bp->flags &= ~(HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
+
+	if (dev->features & NETIF_F_HW_VLAN_TX)
+		bp->flags |= HW_VLAN_TX_FLAG;
+
+	if (dev->features & NETIF_F_HW_VLAN_RX)
+		bp->flags |= HW_VLAN_RX_FLAG;
+
+	if (netif_running(dev))
+		bnx2x_set_client_config(bp);
+}
+
+#endif
+int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2x *bp;
+
+	if (!dev) {
+		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
+		return -ENODEV;
+	}
+	bp = netdev_priv(dev);
+
+	rtnl_lock();
+
+	pci_save_state(pdev);
+
+	if (!netif_running(dev)) {
+		rtnl_unlock();
+		return 0;
+	}
+
+	netif_device_detach(dev);
+
+	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+
+	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
+
+	rtnl_unlock();
+
+	return 0;
+}
+
+int bnx2x_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct bnx2x *bp;
+	int rc;
+
+	if (!dev) {
+		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
+		return -ENODEV;
+	}
+	bp = netdev_priv(dev);
+
+	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
+		return -EAGAIN;
+	}
+
+	rtnl_lock();
+
+	pci_restore_state(pdev);
+
+	if (!netif_running(dev)) {
+		rtnl_unlock();
+		return 0;
+	}
+
+	bnx2x_set_power_state(bp, PCI_D0);
+	netif_device_attach(dev);
+
+	rc = bnx2x_nic_load(bp, LOAD_OPEN);
+
+	rtnl_unlock();
+
+	return rc;
+}
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
new file mode 100644
index 0000000..d1979b1
--- /dev/null
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -0,0 +1,652 @@
+/* bnx2x_cmn.h: Broadcom Everest network driver.
+ *
+ * Copyright (c) 2007-2010 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ *
+ * Maintained by: Eilon Greenstein <eilong@broadcom.com>
+ * Written by: Eliezer Tamir
+ * Based on code from Michael Chan's bnx2 driver
+ * UDP CSUM errata workaround by Arik Gendelman
+ * Slowpath and fastpath rework by Vladislav Zolotarov
+ * Statistics and Link management by Yitchak Gertner
+ *
+ */
+#ifndef BNX2X_CMN_H
+#define BNX2X_CMN_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+
+
+#include "bnx2x.h"
+
+
+/*********************** Interfaces ****************************
+ *  Functions that need to be implemented by each driver version
+ */
+
+/**
+ * Initialize link parameters structure variables.
+ *
+ * @param bp
+ * @param load_mode
+ *
+ * @return u8
+ */
+u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode);
+
+/**
+ * Configure hw according to link parameters structure.
+ *
+ * @param bp
+ */
+void bnx2x_link_set(struct bnx2x *bp);
+
+/**
+ * Query link status
+ *
+ * @param bp
+ *
+ * @return 0 - link is UP
+ */
+u8 bnx2x_link_test(struct bnx2x *bp);
+
+/**
+ * Handles link status change
+ *
+ * @param bp
+ */
+void bnx2x__link_status_update(struct bnx2x *bp);
+
+/**
+ * MSI-X slowpath interrupt handler
+ *
+ * @param irq
+ * @param dev_instance
+ *
+ * @return irqreturn_t
+ */
+irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance);
+
+/**
+ * non MSI-X interrupt handler
+ *
+ * @param irq
+ * @param dev_instance
+ *
+ * @return irqreturn_t
+ */
+irqreturn_t bnx2x_interrupt(int irq, void *dev_instance);
+#ifdef BCM_CNIC
+
+/**
+ * Send command to cnic driver
+ *
+ * @param bp
+ * @param cmd
+ */
+int bnx2x_cnic_notify(struct bnx2x *bp, int cmd);
+
+/**
+ * Provides cnic information for proper interrupt handling
+ *
+ * @param bp
+ */
+void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
+#endif
+
+/**
+ * Enable HW interrupts.
+ *
+ * @param bp
+ */
+void bnx2x_int_enable(struct bnx2x *bp);
+
+/**
+ * Disable interrupts. This function ensures that there are no
+ * ISRs or SP DPCs (sp_task) are running after it returns.
+ *
+ * @param bp
+ * @param disable_hw if true, disable HW interrupts.
+ */
+void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw);
+
+/**
+ * Init HW blocks according to current initialization stage:
+ * COMMON, PORT or FUNCTION.
+ *
+ * @param bp
+ * @param load_code: COMMON, PORT or FUNCTION
+ *
+ * @return int
+ */
+int bnx2x_init_hw(struct bnx2x *bp, u32 load_code);
+
+/**
+ * Init driver internals:
+ *  - rings
+ *  - status blocks
+ *  - etc.
+ *
+ * @param bp
+ * @param load_code COMMON, PORT or FUNCTION
+ */
+void bnx2x_nic_init(struct bnx2x *bp, u32 load_code);
+
+/**
+ * Allocate driver's memory.
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_alloc_mem(struct bnx2x *bp);
+
+/**
+ * Release driver's memory.
+ *
+ * @param bp
+ */
+void bnx2x_free_mem(struct bnx2x *bp);
+
+/**
+ * Bring up a leading (the first) eth Client.
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_setup_leading(struct bnx2x *bp);
+
+/**
+ * Setup non-leading eth Client.
+ *
+ * @param bp
+ * @param fp
+ *
+ * @return int
+ */
+int bnx2x_setup_multi(struct bnx2x *bp, int index);
+
+/**
+ * Set number of quueus according to mode and number of available
+ * msi-x vectors
+ *
+ * @param bp
+ *
+ */
+void bnx2x_set_num_queues_msix(struct bnx2x *bp);
+
+/**
+ * Cleanup chip internals:
+ * - Cleanup MAC configuration.
+ * - Close clients.
+ * - etc.
+ *
+ * @param bp
+ * @param unload_mode
+ */
+void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode);
+
+/**
+ * Acquire HW lock.
+ *
+ * @param bp
+ * @param resource Resource bit which was locked
+ *
+ * @return int
+ */
+int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource);
+
+/**
+ * Release HW lock.
+ *
+ * @param bp driver handle
+ * @param resource Resource bit which was locked
+ *
+ * @return int
+ */
+int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource);
+
+/**
+ * Configure eth MAC address in the HW according to the value in
+ * netdev->dev_addr for 57711
+ *
+ * @param bp driver handle
+ * @param set
+ */
+void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set);
+
+/**
+ * Configure eth MAC address in the HW according to the value in
+ * netdev->dev_addr for 57710
+ *
+ * @param bp driver handle
+ * @param set
+ */
+void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set);
+
+#ifdef BCM_CNIC
+/**
+ * Set iSCSI MAC(s) at the next enties in the CAM after the ETH
+ * MAC(s). The function will wait until the ramrod completion
+ * returns.
+ *
+ * @param bp driver handle
+ * @param set set or clear the CAM entry
+ *
+ * @return 0 if cussess, -ENODEV if ramrod doesn't return.
+ */
+int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set);
+#endif
+
+/**
+ * Initialize status block in FW and HW
+ *
+ * @param bp driver handle
+ * @param sb host_status_block
+ * @param dma_addr_t mapping
+ * @param int sb_id
+ */
+void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
+			  dma_addr_t mapping, int sb_id);
+
+/**
+ * Reconfigure FW/HW according to dev->flags rx mode
+ *
+ * @param dev net_device
+ *
+ */
+void bnx2x_set_rx_mode(struct net_device *dev);
+
+/**
+ * Configure MAC filtering rules in a FW.
+ *
+ * @param bp driver handle
+ */
+void bnx2x_set_storm_rx_mode(struct bnx2x *bp);
+
+/* Parity errors related */
+void bnx2x_inc_load_cnt(struct bnx2x *bp);
+u32 bnx2x_dec_load_cnt(struct bnx2x *bp);
+bool bnx2x_chk_parity_attn(struct bnx2x *bp);
+bool bnx2x_reset_is_done(struct bnx2x *bp);
+void bnx2x_disable_close_the_gate(struct bnx2x *bp);
+
+/**
+ * Perform statistics handling according to event
+ *
+ * @param bp driver handle
+ * @param even tbnx2x_stats_event
+ */
+void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
+
+/**
+ * Configures FW with client paramteres (like HW VLAN removal)
+ * for each active client.
+ *
+ * @param bp
+ */
+void bnx2x_set_client_config(struct bnx2x *bp);
+
+/**
+ * Handle sp events
+ *
+ * @param fp fastpath handle for the event
+ * @param rr_cqe eth_rx_cqe
+ */
+void bnx2x_sp_event(struct bnx2x_fastpath *fp,  union eth_rx_cqe *rr_cqe);
+
+
+static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
+{
+	struct host_status_block *fpsb = fp->status_blk;
+
+	barrier(); /* status block is written to by the chip */
+	fp->fp_c_idx = fpsb->c_status_block.status_block_index;
+	fp->fp_u_idx = fpsb->u_status_block.status_block_index;
+}
+
+static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
+					struct bnx2x_fastpath *fp,
+					u16 bd_prod, u16 rx_comp_prod,
+					u16 rx_sge_prod)
+{
+	struct ustorm_eth_rx_producers rx_prods = {0};
+	int i;
+
+	/* Update producers */
+	rx_prods.bd_prod = bd_prod;
+	rx_prods.cqe_prod = rx_comp_prod;
+	rx_prods.sge_prod = rx_sge_prod;
+
+	/*
+	 * Make sure that the BD and SGE data is updated before updating the
+	 * producers since FW might read the BD/SGE right after the producer
+	 * is updated.
+	 * This is only applicable for weak-ordered memory model archs such
+	 * as IA-64. The following barrier is also mandatory since FW will
+	 * assumes BDs must have buffers.
+	 */
+	wmb();
+
+	for (i = 0; i < sizeof(struct ustorm_eth_rx_producers)/4; i++)
+		REG_WR(bp, BAR_USTRORM_INTMEM +
+		       USTORM_RX_PRODS_OFFSET(BP_PORT(bp), fp->cl_id) + i*4,
+		       ((u32 *)&rx_prods)[i]);
+
+	mmiowb(); /* keep prod updates ordered */
+
+	DP(NETIF_MSG_RX_STATUS,
+	   "queue[%d]:  wrote  bd_prod %u  cqe_prod %u  sge_prod %u\n",
+	   fp->index, bd_prod, rx_comp_prod, rx_sge_prod);
+}
+
+
+
+static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
+				u8 storm, u16 index, u8 op, u8 update)
+{
+	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
+		       COMMAND_REG_INT_ACK);
+	struct igu_ack_register igu_ack;
+
+	igu_ack.status_block_index = index;
+	igu_ack.sb_id_and_flags =
+			((sb_id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
+			 (storm << IGU_ACK_REGISTER_STORM_ID_SHIFT) |
+			 (update << IGU_ACK_REGISTER_UPDATE_INDEX_SHIFT) |
+			 (op << IGU_ACK_REGISTER_INTERRUPT_MODE_SHIFT));
+
+	DP(BNX2X_MSG_OFF, "write 0x%08x to HC addr 0x%x\n",
+	   (*(u32 *)&igu_ack), hc_addr);
+	REG_WR(bp, hc_addr, (*(u32 *)&igu_ack));
+
+	/* Make sure that ACK is written */
+	mmiowb();
+	barrier();
+}
+static inline u16 bnx2x_ack_int(struct bnx2x *bp)
+{
+	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
+		       COMMAND_REG_SIMD_MASK);
+	u32 result = REG_RD(bp, hc_addr);
+
+	DP(BNX2X_MSG_OFF, "read 0x%08x from HC addr 0x%x\n",
+	   result, hc_addr);
+
+	return result;
+}
+
+/*
+ * fast path service functions
+ */
+
+static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
+{
+	/* Tell compiler that consumer and producer can change */
+	barrier();
+	return (fp->tx_pkt_prod != fp->tx_pkt_cons);
+}
+
+static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
+{
+	s16 used;
+	u16 prod;
+	u16 cons;
+
+	prod = fp->tx_bd_prod;
+	cons = fp->tx_bd_cons;
+
+	/* NUM_TX_RINGS = number of "next-page" entries
+	   It will be used as a threshold */
+	used = SUB_S16(prod, cons) + (s16)NUM_TX_RINGS;
+
+#ifdef BNX2X_STOP_ON_ERROR
+	WARN_ON(used < 0);
+	WARN_ON(used > fp->bp->tx_ring_size);
+	WARN_ON((fp->bp->tx_ring_size - used) > MAX_TX_AVAIL);
+#endif
+
+	return (s16)(fp->bp->tx_ring_size) - used;
+}
+
+static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
+{
+	u16 hw_cons;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
+	return hw_cons != fp->tx_pkt_cons;
+}
+
+static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
+				     struct bnx2x_fastpath *fp, u16 index)
+{
+	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
+	struct page *page = sw_buf->page;
+	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+
+	/* Skip "next page" elements */
+	if (!page)
+		return;
+
+	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
+		       SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+	__free_pages(page, PAGES_PER_SGE_SHIFT);
+
+	sw_buf->page = NULL;
+	sge->addr_hi = 0;
+	sge->addr_lo = 0;
+}
+
+static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
+					   struct bnx2x_fastpath *fp, int last)
+{
+	int i;
+
+	for (i = 0; i < last; i++)
+		bnx2x_free_rx_sge(bp, fp, i);
+}
+
+static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
+				     struct bnx2x_fastpath *fp, u16 index)
+{
+	struct page *page = alloc_pages(GFP_ATOMIC, PAGES_PER_SGE_SHIFT);
+	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
+	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+	dma_addr_t mapping;
+
+	if (unlikely(page == NULL))
+		return -ENOMEM;
+
+	mapping = dma_map_page(&bp->pdev->dev, page, 0,
+			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
+		__free_pages(page, PAGES_PER_SGE_SHIFT);
+		return -ENOMEM;
+	}
+
+	sw_buf->page = page;
+	dma_unmap_addr_set(sw_buf, mapping, mapping);
+
+	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
+	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
+
+	return 0;
+}
+static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
+				     struct bnx2x_fastpath *fp, u16 index)
+{
+	struct sk_buff *skb;
+	struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[index];
+	struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
+	dma_addr_t mapping;
+
+	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	if (unlikely(skb == NULL))
+		return -ENOMEM;
+
+	mapping = dma_map_single(&bp->pdev->dev, skb->data, bp->rx_buf_size,
+				 DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
+		dev_kfree_skb(skb);
+		return -ENOMEM;
+	}
+
+	rx_buf->skb = skb;
+	dma_unmap_addr_set(rx_buf, mapping, mapping);
+
+	rx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
+	rx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
+
+	return 0;
+}
+
+/* note that we are not allocating a new skb,
+ * we are just moving one from cons to prod
+ * we are not creating a new mapping,
+ * so there is no need to check for dma_mapping_error().
+ */
+static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
+			       struct sk_buff *skb, u16 cons, u16 prod)
+{
+	struct bnx2x *bp = fp->bp;
+	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
+	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
+	struct eth_rx_bd *cons_bd = &fp->rx_desc_ring[cons];
+	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
+
+	dma_sync_single_for_device(&bp->pdev->dev,
+				   dma_unmap_addr(cons_rx_buf, mapping),
+				   RX_COPY_THRESH, DMA_FROM_DEVICE);
+
+	prod_rx_buf->skb = cons_rx_buf->skb;
+	dma_unmap_addr_set(prod_rx_buf, mapping,
+			   dma_unmap_addr(cons_rx_buf, mapping));
+	*prod_bd = *cons_bd;
+}
+
+static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
+{
+	int i, j;
+
+	for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
+		int idx = RX_SGE_CNT * i - 1;
+
+		for (j = 0; j < 2; j++) {
+			SGE_MASK_CLEAR_BIT(fp, idx);
+			idx--;
+		}
+	}
+}
+
+static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
+{
+	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
+	memset(fp->sge_mask, 0xff,
+	       (NUM_RX_SGE >> RX_SGE_MASK_ELEM_SHIFT)*sizeof(u64));
+
+	/* Clear the two last indices in the page to 1:
+	   these are the indices that correspond to the "next" element,
+	   hence will never be indicated and should be removed from
+	   the calculations. */
+	bnx2x_clear_sge_mask_next_elems(fp);
+}
+static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
+				       struct bnx2x_fastpath *fp, int last)
+{
+	int i;
+
+	for (i = 0; i < last; i++) {
+		struct sw_rx_bd *rx_buf = &(fp->tpa_pool[i]);
+		struct sk_buff *skb = rx_buf->skb;
+
+		if (skb == NULL) {
+			DP(NETIF_MSG_IFDOWN, "tpa bin %d empty on free\n", i);
+			continue;
+		}
+
+		if (fp->tpa_state[i] == BNX2X_TPA_START)
+			dma_unmap_single(&bp->pdev->dev,
+					 dma_unmap_addr(rx_buf, mapping),
+					 bp->rx_buf_size, DMA_FROM_DEVICE);
+
+		dev_kfree_skb(skb);
+		rx_buf->skb = NULL;
+	}
+}
+
+
+static inline void bnx2x_init_tx_ring(struct bnx2x *bp)
+{
+	int i, j;
+
+	for_each_queue(bp, j) {
+		struct bnx2x_fastpath *fp = &bp->fp[j];
+
+		for (i = 1; i <= NUM_TX_RINGS; i++) {
+			struct eth_tx_next_bd *tx_next_bd =
+				&fp->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
+
+			tx_next_bd->addr_hi =
+				cpu_to_le32(U64_HI(fp->tx_desc_mapping +
+					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+			tx_next_bd->addr_lo =
+				cpu_to_le32(U64_LO(fp->tx_desc_mapping +
+					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+		}
+
+		fp->tx_db.data.header.header = DOORBELL_HDR_DB_TYPE;
+		fp->tx_db.data.zero_fill1 = 0;
+		fp->tx_db.data.prod = 0;
+
+		fp->tx_pkt_prod = 0;
+		fp->tx_pkt_cons = 0;
+		fp->tx_bd_prod = 0;
+		fp->tx_bd_cons = 0;
+		fp->tx_cons_sb = BNX2X_TX_SB_INDEX;
+		fp->tx_pkt = 0;
+	}
+}
+static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
+{
+	u16 rx_cons_sb;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
+	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
+		rx_cons_sb++;
+	return (fp->rx_comp_cons != rx_cons_sb);
+}
+
+/* HW Lock for shared dual port PHYs */
+void bnx2x_acquire_phy_lock(struct bnx2x *bp);
+void bnx2x_release_phy_lock(struct bnx2x *bp);
+
+void bnx2x_link_report(struct bnx2x *bp);
+int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget);
+int bnx2x_tx_int(struct bnx2x_fastpath *fp);
+void bnx2x_init_rx_rings(struct bnx2x *bp);
+netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
+
+int bnx2x_change_mac_addr(struct net_device *dev, void *p);
+void bnx2x_tx_timeout(struct net_device *dev);
+void bnx2x_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp);
+void bnx2x_netif_start(struct bnx2x *bp);
+void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
+void bnx2x_free_irq(struct bnx2x *bp, bool disable_only);
+int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state);
+int bnx2x_resume(struct pci_dev *pdev);
+void bnx2x_free_skbs(struct bnx2x *bp);
+int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
+int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
+int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
+int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
+
+#endif /* BNX2X_CMN_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 0beaefb..0c00e50 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -56,6 +56,7 @@
 #include "bnx2x_init.h"
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
+#include "bnx2x_cmn.h"
 
 #define DRV_MODULE_VERSION	"1.52.53-1"
 #define DRV_MODULE_RELDATE	"2010/18/04"
@@ -652,7 +653,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	BNX2X_ERR("end crash dump -----------------\n");
 }
 
-static void bnx2x_int_enable(struct bnx2x *bp)
+void bnx2x_int_enable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -734,7 +735,7 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
 }
 
-static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
+void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 {
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
 	int i, offset;
@@ -804,235 +805,12 @@ static bool bnx2x_trylock_hw_lock(struct bnx2x *bp, u32 resource)
 	return false;
 }
 
-static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
-				u8 storm, u16 index, u8 op, u8 update)
-{
-	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
-		       COMMAND_REG_INT_ACK);
-	struct igu_ack_register igu_ack;
-
-	igu_ack.status_block_index = index;
-	igu_ack.sb_id_and_flags =
-			((sb_id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
-			 (storm << IGU_ACK_REGISTER_STORM_ID_SHIFT) |
-			 (update << IGU_ACK_REGISTER_UPDATE_INDEX_SHIFT) |
-			 (op << IGU_ACK_REGISTER_INTERRUPT_MODE_SHIFT));
-
-	DP(BNX2X_MSG_OFF, "write 0x%08x to HC addr 0x%x\n",
-	   (*(u32 *)&igu_ack), hc_addr);
-	REG_WR(bp, hc_addr, (*(u32 *)&igu_ack));
-
-	/* Make sure that ACK is written */
-	mmiowb();
-	barrier();
-}
-
-static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
-{
-	struct host_status_block *fpsb = fp->status_blk;
-
-	barrier(); /* status block is written to by the chip */
-	fp->fp_c_idx = fpsb->c_status_block.status_block_index;
-	fp->fp_u_idx = fpsb->u_status_block.status_block_index;
-}
-
-static u16 bnx2x_ack_int(struct bnx2x *bp)
-{
-	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
-		       COMMAND_REG_SIMD_MASK);
-	u32 result = REG_RD(bp, hc_addr);
-
-	DP(BNX2X_MSG_OFF, "read 0x%08x from HC addr 0x%x\n",
-	   result, hc_addr);
-
-	return result;
-}
-
-
-/*
- * fast path service functions
- */
-
-static inline int bnx2x_has_tx_work_unload(struct bnx2x_fastpath *fp)
-{
-	/* Tell compiler that consumer and producer can change */
-	barrier();
-	return (fp->tx_pkt_prod != fp->tx_pkt_cons);
-}
-
-/* free skb in the packet ring at pos idx
- * return idx of last bd freed
- */
-static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
-			     u16 idx)
-{
-	struct sw_tx_bd *tx_buf = &fp->tx_buf_ring[idx];
-	struct eth_tx_start_bd *tx_start_bd;
-	struct eth_tx_bd *tx_data_bd;
-	struct sk_buff *skb = tx_buf->skb;
-	u16 bd_idx = TX_BD(tx_buf->first_bd), new_cons;
-	int nbd;
-
-	/* prefetch skb end pointer to speedup dev_kfree_skb() */
-	prefetch(&skb->end);
-
-	DP(BNX2X_MSG_OFF, "pkt_idx %d  buff @(%p)->skb %p\n",
-	   idx, tx_buf, skb);
-
-	/* unmap first bd */
-	DP(BNX2X_MSG_OFF, "free bd_idx %d\n", bd_idx);
-	tx_start_bd = &fp->tx_desc_ring[bd_idx].start_bd;
-	dma_unmap_single(&bp->pdev->dev, BD_UNMAP_ADDR(tx_start_bd),
-			 BD_UNMAP_LEN(tx_start_bd), PCI_DMA_TODEVICE);
-
-	nbd = le16_to_cpu(tx_start_bd->nbd) - 1;
-#ifdef BNX2X_STOP_ON_ERROR
-	if ((nbd - 1) > (MAX_SKB_FRAGS + 2)) {
-		BNX2X_ERR("BAD nbd!\n");
-		bnx2x_panic();
-	}
-#endif
-	new_cons = nbd + tx_buf->first_bd;
-
-	/* Get the next bd */
-	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
-
-	/* Skip a parse bd... */
-	--nbd;
-	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
-
-	/* ...and the TSO split header bd since they have no mapping */
-	if (tx_buf->flags & BNX2X_TSO_SPLIT_BD) {
-		--nbd;
-		bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
-	}
-
-	/* now free frags */
-	while (nbd > 0) {
-
-		DP(BNX2X_MSG_OFF, "free frag bd_idx %d\n", bd_idx);
-		tx_data_bd = &fp->tx_desc_ring[bd_idx].reg_bd;
-		dma_unmap_page(&bp->pdev->dev, BD_UNMAP_ADDR(tx_data_bd),
-			       BD_UNMAP_LEN(tx_data_bd), DMA_TO_DEVICE);
-		if (--nbd)
-			bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
-	}
-
-	/* release skb */
-	WARN_ON(!skb);
-	dev_kfree_skb(skb);
-	tx_buf->first_bd = 0;
-	tx_buf->skb = NULL;
-
-	return new_cons;
-}
-
-static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
-{
-	s16 used;
-	u16 prod;
-	u16 cons;
-
-	prod = fp->tx_bd_prod;
-	cons = fp->tx_bd_cons;
-
-	/* NUM_TX_RINGS = number of "next-page" entries
-	   It will be used as a threshold */
-	used = SUB_S16(prod, cons) + (s16)NUM_TX_RINGS;
-
-#ifdef BNX2X_STOP_ON_ERROR
-	WARN_ON(used < 0);
-	WARN_ON(used > fp->bp->tx_ring_size);
-	WARN_ON((fp->bp->tx_ring_size - used) > MAX_TX_AVAIL);
-#endif
-
-	return (s16)(fp->bp->tx_ring_size) - used;
-}
-
-static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
-{
-	u16 hw_cons;
-
-	/* Tell compiler that status block fields can change */
-	barrier();
-	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
-	return hw_cons != fp->tx_pkt_cons;
-}
-
-static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
-{
-	struct bnx2x *bp = fp->bp;
-	struct netdev_queue *txq;
-	u16 hw_cons, sw_cons, bd_cons = fp->tx_bd_cons;
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return -1;
-#endif
-
-	txq = netdev_get_tx_queue(bp->dev, fp->index);
-	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
-	sw_cons = fp->tx_pkt_cons;
-
-	while (sw_cons != hw_cons) {
-		u16 pkt_cons;
-
-		pkt_cons = TX_BD(sw_cons);
-
-		/* prefetch(bp->tx_buf_ring[pkt_cons].skb); */
-
-		DP(NETIF_MSG_TX_DONE, "hw_cons %u  sw_cons %u  pkt_cons %u\n",
-		   hw_cons, sw_cons, pkt_cons);
-
-/*		if (NEXT_TX_IDX(sw_cons) != hw_cons) {
-			rmb();
-			prefetch(fp->tx_buf_ring[NEXT_TX_IDX(sw_cons)].skb);
-		}
-*/
-		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
-		sw_cons++;
-	}
-
-	fp->tx_pkt_cons = sw_cons;
-	fp->tx_bd_cons = bd_cons;
-
-	/* Need to make the tx_bd_cons update visible to start_xmit()
-	 * before checking for netif_tx_queue_stopped().  Without the
-	 * memory barrier, there is a small possibility that
-	 * start_xmit() will miss it and cause the queue to be stopped
-	 * forever.
-	 */
-	smp_mb();
-
-	/* TBD need a thresh? */
-	if (unlikely(netif_tx_queue_stopped(txq))) {
-		/* Taking tx_lock() is needed to prevent reenabling the queue
-		 * while it's empty. This could have happen if rx_action() gets
-		 * suspended in bnx2x_tx_int() after the condition before
-		 * netif_tx_wake_queue(), while tx_action (bnx2x_start_xmit()):
-		 *
-		 * stops the queue->sees fresh tx_bd_cons->releases the queue->
-		 * sends some packets consuming the whole queue again->
-		 * stops the queue
-		 */
-
-		__netif_tx_lock(txq, smp_processor_id());
-
-		if ((netif_tx_queue_stopped(txq)) &&
-		    (bp->state == BNX2X_STATE_OPEN) &&
-		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
-			netif_tx_wake_queue(txq);
-
-		__netif_tx_unlock(txq);
-	}
-	return 0;
-}
 
 #ifdef BCM_CNIC
 static void bnx2x_cnic_cfc_comp(struct bnx2x *bp, int cid);
 #endif
 
-static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
+void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 			   union eth_rx_cqe *rr_cqe)
 {
 	struct bnx2x *bp = fp->bp;
@@ -1116,717 +894,7 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 	mb(); /* force bnx2x_wait_ramrod() to see the change */
 }
 
-static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
-				     struct bnx2x_fastpath *fp, u16 index)
-{
-	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
-	struct page *page = sw_buf->page;
-	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
-
-	/* Skip "next page" elements */
-	if (!page)
-		return;
-
-	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
-		       SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
-	__free_pages(page, PAGES_PER_SGE_SHIFT);
-
-	sw_buf->page = NULL;
-	sge->addr_hi = 0;
-	sge->addr_lo = 0;
-}
-
-static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
-					   struct bnx2x_fastpath *fp, int last)
-{
-	int i;
-
-	for (i = 0; i < last; i++)
-		bnx2x_free_rx_sge(bp, fp, i);
-}
-
-static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
-				     struct bnx2x_fastpath *fp, u16 index)
-{
-	struct page *page = alloc_pages(GFP_ATOMIC, PAGES_PER_SGE_SHIFT);
-	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
-	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
-	dma_addr_t mapping;
-
-	if (unlikely(page == NULL))
-		return -ENOMEM;
-
-	mapping = dma_map_page(&bp->pdev->dev, page, 0,
-			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		__free_pages(page, PAGES_PER_SGE_SHIFT);
-		return -ENOMEM;
-	}
-
-	sw_buf->page = page;
-	dma_unmap_addr_set(sw_buf, mapping, mapping);
-
-	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
-	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
-
-	return 0;
-}
-
-static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
-				     struct bnx2x_fastpath *fp, u16 index)
-{
-	struct sk_buff *skb;
-	struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[index];
-	struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
-	dma_addr_t mapping;
-
-	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
-	if (unlikely(skb == NULL))
-		return -ENOMEM;
-
-	mapping = dma_map_single(&bp->pdev->dev, skb->data, bp->rx_buf_size,
-				 DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		dev_kfree_skb(skb);
-		return -ENOMEM;
-	}
-
-	rx_buf->skb = skb;
-	dma_unmap_addr_set(rx_buf, mapping, mapping);
-
-	rx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-	rx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-
-	return 0;
-}
-
-/* note that we are not allocating a new skb,
- * we are just moving one from cons to prod
- * we are not creating a new mapping,
- * so there is no need to check for dma_mapping_error().
- */
-static void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
-			       struct sk_buff *skb, u16 cons, u16 prod)
-{
-	struct bnx2x *bp = fp->bp;
-	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
-	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
-	struct eth_rx_bd *cons_bd = &fp->rx_desc_ring[cons];
-	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
-
-	dma_sync_single_for_device(&bp->pdev->dev,
-				   dma_unmap_addr(cons_rx_buf, mapping),
-				   RX_COPY_THRESH, DMA_FROM_DEVICE);
-
-	prod_rx_buf->skb = cons_rx_buf->skb;
-	dma_unmap_addr_set(prod_rx_buf, mapping,
-			   dma_unmap_addr(cons_rx_buf, mapping));
-	*prod_bd = *cons_bd;
-}
-
-static inline void bnx2x_update_last_max_sge(struct bnx2x_fastpath *fp,
-					     u16 idx)
-{
-	u16 last_max = fp->last_max_sge;
-
-	if (SUB_S16(idx, last_max) > 0)
-		fp->last_max_sge = idx;
-}
-
-static void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
-{
-	int i, j;
-
-	for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
-		int idx = RX_SGE_CNT * i - 1;
-
-		for (j = 0; j < 2; j++) {
-			SGE_MASK_CLEAR_BIT(fp, idx);
-			idx--;
-		}
-	}
-}
-
-static void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
-				  struct eth_fast_path_rx_cqe *fp_cqe)
-{
-	struct bnx2x *bp = fp->bp;
-	u16 sge_len = SGE_PAGE_ALIGN(le16_to_cpu(fp_cqe->pkt_len) -
-				     le16_to_cpu(fp_cqe->len_on_bd)) >>
-		      SGE_PAGE_SHIFT;
-	u16 last_max, last_elem, first_elem;
-	u16 delta = 0;
-	u16 i;
-
-	if (!sge_len)
-		return;
-
-	/* First mark all used pages */
-	for (i = 0; i < sge_len; i++)
-		SGE_MASK_CLEAR_BIT(fp, RX_SGE(le16_to_cpu(fp_cqe->sgl[i])));
-
-	DP(NETIF_MSG_RX_STATUS, "fp_cqe->sgl[%d] = %d\n",
-	   sge_len - 1, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
-
-	/* Here we assume that the last SGE index is the biggest */
-	prefetch((void *)(fp->sge_mask));
-	bnx2x_update_last_max_sge(fp, le16_to_cpu(fp_cqe->sgl[sge_len - 1]));
-
-	last_max = RX_SGE(fp->last_max_sge);
-	last_elem = last_max >> RX_SGE_MASK_ELEM_SHIFT;
-	first_elem = RX_SGE(fp->rx_sge_prod) >> RX_SGE_MASK_ELEM_SHIFT;
-
-	/* If ring is not full */
-	if (last_elem + 1 != first_elem)
-		last_elem++;
-
-	/* Now update the prod */
-	for (i = first_elem; i != last_elem; i = NEXT_SGE_MASK_ELEM(i)) {
-		if (likely(fp->sge_mask[i]))
-			break;
-
-		fp->sge_mask[i] = RX_SGE_MASK_ELEM_ONE_MASK;
-		delta += RX_SGE_MASK_ELEM_SZ;
-	}
-
-	if (delta > 0) {
-		fp->rx_sge_prod += delta;
-		/* clear page-end entries */
-		bnx2x_clear_sge_mask_next_elems(fp);
-	}
-
-	DP(NETIF_MSG_RX_STATUS,
-	   "fp->last_max_sge = %d  fp->rx_sge_prod = %d\n",
-	   fp->last_max_sge, fp->rx_sge_prod);
-}
-
-static inline void bnx2x_init_sge_ring_bit_mask(struct bnx2x_fastpath *fp)
-{
-	/* Set the mask to all 1-s: it's faster to compare to 0 than to 0xf-s */
-	memset(fp->sge_mask, 0xff,
-	       (NUM_RX_SGE >> RX_SGE_MASK_ELEM_SHIFT)*sizeof(u64));
-
-	/* Clear the two last indices in the page to 1:
-	   these are the indices that correspond to the "next" element,
-	   hence will never be indicated and should be removed from
-	   the calculations. */
-	bnx2x_clear_sge_mask_next_elems(fp);
-}
-
-static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
-			    struct sk_buff *skb, u16 cons, u16 prod)
-{
-	struct bnx2x *bp = fp->bp;
-	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
-	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
-	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
-	dma_addr_t mapping;
-
-	/* move empty skb from pool to prod and map it */
-	prod_rx_buf->skb = fp->tpa_pool[queue].skb;
-	mapping = dma_map_single(&bp->pdev->dev, fp->tpa_pool[queue].skb->data,
-				 bp->rx_buf_size, DMA_FROM_DEVICE);
-	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
-
-	/* move partial skb from cons to pool (don't unmap yet) */
-	fp->tpa_pool[queue] = *cons_rx_buf;
-
-	/* mark bin state as start - print error if current state != stop */
-	if (fp->tpa_state[queue] != BNX2X_TPA_STOP)
-		BNX2X_ERR("start of bin not in stop [%d]\n", queue);
-
-	fp->tpa_state[queue] = BNX2X_TPA_START;
-
-	/* point prod_bd to new skb */
-	prod_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-	prod_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-
-#ifdef BNX2X_STOP_ON_ERROR
-	fp->tpa_queue_used |= (1 << queue);
-#ifdef _ASM_GENERIC_INT_L64_H
-	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
-#else
-	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
-#endif
-	   fp->tpa_queue_used);
-#endif
-}
-
-static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
-			       struct sk_buff *skb,
-			       struct eth_fast_path_rx_cqe *fp_cqe,
-			       u16 cqe_idx)
-{
-	struct sw_rx_page *rx_pg, old_rx_pg;
-	u16 len_on_bd = le16_to_cpu(fp_cqe->len_on_bd);
-	u32 i, frag_len, frag_size, pages;
-	int err;
-	int j;
-
-	frag_size = le16_to_cpu(fp_cqe->pkt_len) - len_on_bd;
-	pages = SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
-
-	/* This is needed in order to enable forwarding support */
-	if (frag_size)
-		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
-					       max(frag_size, (u32)len_on_bd));
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (pages > min_t(u32, 8, MAX_SKB_FRAGS)*SGE_PAGE_SIZE*PAGES_PER_SGE) {
-		BNX2X_ERR("SGL length is too long: %d. CQE index is %d\n",
-			  pages, cqe_idx);
-		BNX2X_ERR("fp_cqe->pkt_len = %d  fp_cqe->len_on_bd = %d\n",
-			  fp_cqe->pkt_len, len_on_bd);
-		bnx2x_panic();
-		return -EINVAL;
-	}
-#endif
-
-	/* Run through the SGL and compose the fragmented skb */
-	for (i = 0, j = 0; i < pages; i += PAGES_PER_SGE, j++) {
-		u16 sge_idx = RX_SGE(le16_to_cpu(fp_cqe->sgl[j]));
-
-		/* FW gives the indices of the SGE as if the ring is an array
-		   (meaning that "next" element will consume 2 indices) */
-		frag_len = min(frag_size, (u32)(SGE_PAGE_SIZE*PAGES_PER_SGE));
-		rx_pg = &fp->rx_page_ring[sge_idx];
-		old_rx_pg = *rx_pg;
-
-		/* If we fail to allocate a substitute page, we simply stop
-		   where we are and drop the whole packet */
-		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx);
-		if (unlikely(err)) {
-			fp->eth_q_stats.rx_skb_alloc_failed++;
-			return err;
-		}
-
-		/* Unmap the page as we r going to pass it to the stack */
-		dma_unmap_page(&bp->pdev->dev,
-			       dma_unmap_addr(&old_rx_pg, mapping),
-			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
-
-		/* Add one frag and update the appropriate fields in the skb */
-		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
-
-		skb->data_len += frag_len;
-		skb->truesize += frag_len;
-		skb->len += frag_len;
-
-		frag_size -= frag_len;
-	}
-
-	return 0;
-}
-
-static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
-			   u16 queue, int pad, int len, union eth_rx_cqe *cqe,
-			   u16 cqe_idx)
-{
-	struct sw_rx_bd *rx_buf = &fp->tpa_pool[queue];
-	struct sk_buff *skb = rx_buf->skb;
-	/* alloc new skb */
-	struct sk_buff *new_skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
-
-	/* Unmap skb in the pool anyway, as we are going to change
-	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
-	   fails. */
-	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
-			 bp->rx_buf_size, DMA_FROM_DEVICE);
-
-	if (likely(new_skb)) {
-		/* fix ip xsum and give it to the stack */
-		/* (no need to map the new skb) */
-#ifdef BCM_VLAN
-		int is_vlan_cqe =
-			(le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
-			 PARSING_FLAGS_VLAN);
-		int is_not_hwaccel_vlan_cqe =
-			(is_vlan_cqe && (!(bp->flags & HW_VLAN_RX_FLAG)));
-#endif
-
-		prefetch(skb);
-		prefetch(((char *)(skb)) + 128);
-
-#ifdef BNX2X_STOP_ON_ERROR
-		if (pad + len > bp->rx_buf_size) {
-			BNX2X_ERR("skb_put is about to fail...  "
-				  "pad %d  len %d  rx_buf_size %d\n",
-				  pad, len, bp->rx_buf_size);
-			bnx2x_panic();
-			return;
-		}
-#endif
-
-		skb_reserve(skb, pad);
-		skb_put(skb, len);
-
-		skb->protocol = eth_type_trans(skb, bp->dev);
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-		{
-			struct iphdr *iph;
-
-			iph = (struct iphdr *)skb->data;
-#ifdef BCM_VLAN
-			/* If there is no Rx VLAN offloading -
-			   take VLAN tag into an account */
-			if (unlikely(is_not_hwaccel_vlan_cqe))
-				iph = (struct iphdr *)((u8 *)iph + VLAN_HLEN);
-#endif
-			iph->check = 0;
-			iph->check = ip_fast_csum((u8 *)iph, iph->ihl);
-		}
-
-		if (!bnx2x_fill_frag_skb(bp, fp, skb,
-					 &cqe->fast_path_cqe, cqe_idx)) {
-#ifdef BCM_VLAN
-			if ((bp->vlgrp != NULL) && is_vlan_cqe &&
-			    (!is_not_hwaccel_vlan_cqe))
-				vlan_gro_receive(&fp->napi, bp->vlgrp,
-						 le16_to_cpu(cqe->fast_path_cqe.
-							     vlan_tag), skb);
-			else
-#endif
-				napi_gro_receive(&fp->napi, skb);
-		} else {
-			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new pages"
-			   " - dropping packet!\n");
-			dev_kfree_skb(skb);
-		}
-
-
-		/* put new skb in bin */
-		fp->tpa_pool[queue].skb = new_skb;
-
-	} else {
-		/* else drop the packet and keep the buffer in the bin */
-		DP(NETIF_MSG_RX_STATUS,
-		   "Failed to allocate new skb - dropping packet!\n");
-		fp->eth_q_stats.rx_skb_alloc_failed++;
-	}
-
-	fp->tpa_state[queue] = BNX2X_TPA_STOP;
-}
-
-static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
-					struct bnx2x_fastpath *fp,
-					u16 bd_prod, u16 rx_comp_prod,
-					u16 rx_sge_prod)
-{
-	struct ustorm_eth_rx_producers rx_prods = {0};
-	int i;
-
-	/* Update producers */
-	rx_prods.bd_prod = bd_prod;
-	rx_prods.cqe_prod = rx_comp_prod;
-	rx_prods.sge_prod = rx_sge_prod;
-
-	/*
-	 * Make sure that the BD and SGE data is updated before updating the
-	 * producers since FW might read the BD/SGE right after the producer
-	 * is updated.
-	 * This is only applicable for weak-ordered memory model archs such
-	 * as IA-64. The following barrier is also mandatory since FW will
-	 * assumes BDs must have buffers.
-	 */
-	wmb();
-
-	for (i = 0; i < sizeof(struct ustorm_eth_rx_producers)/4; i++)
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_RX_PRODS_OFFSET(BP_PORT(bp), fp->cl_id) + i*4,
-		       ((u32 *)&rx_prods)[i]);
-
-	mmiowb(); /* keep prod updates ordered */
-
-	DP(NETIF_MSG_RX_STATUS,
-	   "queue[%d]:  wrote  bd_prod %u  cqe_prod %u  sge_prod %u\n",
-	   fp->index, bd_prod, rx_comp_prod, rx_sge_prod);
-}
-
-/* Set Toeplitz hash value in the skb using the value from the
- * CQE (calculated by HW).
- */
-static inline void bnx2x_set_skb_rxhash(struct bnx2x *bp, union eth_rx_cqe *cqe,
-					struct sk_buff *skb)
-{
-	/* Set Toeplitz hash from CQE */
-	if ((bp->dev->features & NETIF_F_RXHASH) &&
-	    (cqe->fast_path_cqe.status_flags &
-	     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
-		skb->rxhash =
-		le32_to_cpu(cqe->fast_path_cqe.rss_hash_result);
-}
-
-static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
-{
-	struct bnx2x *bp = fp->bp;
-	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
-	u16 hw_comp_cons, sw_comp_cons, sw_comp_prod;
-	int rx_pkt = 0;
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return 0;
-#endif
-
-	/* CQ "next element" is of the size of the regular element,
-	   that's why it's ok here */
-	hw_comp_cons = le16_to_cpu(*fp->rx_cons_sb);
-	if ((hw_comp_cons & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		hw_comp_cons++;
-
-	bd_cons = fp->rx_bd_cons;
-	bd_prod = fp->rx_bd_prod;
-	bd_prod_fw = bd_prod;
-	sw_comp_cons = fp->rx_comp_cons;
-	sw_comp_prod = fp->rx_comp_prod;
-
-	/* Memory barrier necessary as speculative reads of the rx
-	 * buffer can be ahead of the index in the status block
-	 */
-	rmb();
-
-	DP(NETIF_MSG_RX_STATUS,
-	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
-	   fp->index, hw_comp_cons, sw_comp_cons);
-
-	while (sw_comp_cons != hw_comp_cons) {
-		struct sw_rx_bd *rx_buf = NULL;
-		struct sk_buff *skb;
-		union eth_rx_cqe *cqe;
-		u8 cqe_fp_flags;
-		u16 len, pad;
-
-		comp_ring_cons = RCQ_BD(sw_comp_cons);
-		bd_prod = RX_BD(bd_prod);
-		bd_cons = RX_BD(bd_cons);
-
-		/* Prefetch the page containing the BD descriptor
-		   at producer's index. It will be needed when new skb is
-		   allocated */
-		prefetch((void *)(PAGE_ALIGN((unsigned long)
-					     (&fp->rx_desc_ring[bd_prod])) -
-				  PAGE_SIZE + 1));
-
-		cqe = &fp->rx_comp_ring[comp_ring_cons];
-		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
-
-		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
-		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
-		   cqe_fp_flags, cqe->fast_path_cqe.status_flags,
-		   le32_to_cpu(cqe->fast_path_cqe.rss_hash_result),
-		   le16_to_cpu(cqe->fast_path_cqe.vlan_tag),
-		   le16_to_cpu(cqe->fast_path_cqe.pkt_len));
-
-		/* is this a slowpath msg? */
-		if (unlikely(CQE_TYPE(cqe_fp_flags))) {
-			bnx2x_sp_event(fp, cqe);
-			goto next_cqe;
-
-		/* this is an rx packet */
-		} else {
-			rx_buf = &fp->rx_buf_ring[bd_cons];
-			skb = rx_buf->skb;
-			prefetch(skb);
-			len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
-			pad = cqe->fast_path_cqe.placement_offset;
-
-			/* If CQE is marked both TPA_START and TPA_END
-			   it is a non-TPA CQE */
-			if ((!fp->disable_tpa) &&
-			    (TPA_TYPE(cqe_fp_flags) !=
-					(TPA_TYPE_START | TPA_TYPE_END))) {
-				u16 queue = cqe->fast_path_cqe.queue_index;
-
-				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_START) {
-					DP(NETIF_MSG_RX_STATUS,
-					   "calling tpa_start on queue %d\n",
-					   queue);
-
-					bnx2x_tpa_start(fp, queue, skb,
-							bd_cons, bd_prod);
-
-					/* Set Toeplitz hash for an LRO skb */
-					bnx2x_set_skb_rxhash(bp, cqe, skb);
-
-					goto next_rx;
-				}
-
-				if (TPA_TYPE(cqe_fp_flags) == TPA_TYPE_END) {
-					DP(NETIF_MSG_RX_STATUS,
-					   "calling tpa_stop on queue %d\n",
-					   queue);
-
-					if (!BNX2X_RX_SUM_FIX(cqe))
-						BNX2X_ERR("STOP on none TCP "
-							  "data\n");
-
-					/* This is a size of the linear data
-					   on this skb */
-					len = le16_to_cpu(cqe->fast_path_cqe.
-								len_on_bd);
-					bnx2x_tpa_stop(bp, fp, queue, pad,
-						    len, cqe, comp_ring_cons);
-#ifdef BNX2X_STOP_ON_ERROR
-					if (bp->panic)
-						return 0;
-#endif
-
-					bnx2x_update_sge_prod(fp,
-							&cqe->fast_path_cqe);
-					goto next_cqe;
-				}
-			}
-
-			dma_sync_single_for_device(&bp->pdev->dev,
-					dma_unmap_addr(rx_buf, mapping),
-						   pad + RX_COPY_THRESH,
-						   DMA_FROM_DEVICE);
-			prefetch(((char *)(skb)) + 128);
-
-			/* is this an error packet? */
-			if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
-				DP(NETIF_MSG_RX_ERR,
-				   "ERROR  flags %x  rx packet %u\n",
-				   cqe_fp_flags, sw_comp_cons);
-				fp->eth_q_stats.rx_err_discard_pkt++;
-				goto reuse_rx;
-			}
-
-			/* Since we don't have a jumbo ring
-			 * copy small packets if mtu > 1500
-			 */
-			if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
-			    (len <= RX_COPY_THRESH)) {
-				struct sk_buff *new_skb;
-
-				new_skb = netdev_alloc_skb(bp->dev,
-							   len + pad);
-				if (new_skb == NULL) {
-					DP(NETIF_MSG_RX_ERR,
-					   "ERROR  packet dropped "
-					   "because of alloc failure\n");
-					fp->eth_q_stats.rx_skb_alloc_failed++;
-					goto reuse_rx;
-				}
-
-				/* aligned copy */
-				skb_copy_from_linear_data_offset(skb, pad,
-						    new_skb->data + pad, len);
-				skb_reserve(new_skb, pad);
-				skb_put(new_skb, len);
-
-				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
-
-				skb = new_skb;
-
-			} else
-			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
-				dma_unmap_single(&bp->pdev->dev,
-					dma_unmap_addr(rx_buf, mapping),
-						 bp->rx_buf_size,
-						 DMA_FROM_DEVICE);
-				skb_reserve(skb, pad);
-				skb_put(skb, len);
-
-			} else {
-				DP(NETIF_MSG_RX_ERR,
-				   "ERROR  packet dropped because "
-				   "of alloc failure\n");
-				fp->eth_q_stats.rx_skb_alloc_failed++;
-reuse_rx:
-				bnx2x_reuse_rx_skb(fp, skb, bd_cons, bd_prod);
-				goto next_rx;
-			}
-
-			skb->protocol = eth_type_trans(skb, bp->dev);
-
-			/* Set Toeplitz hash for a none-LRO skb */
-			bnx2x_set_skb_rxhash(bp, cqe, skb);
-
-			skb->ip_summed = CHECKSUM_NONE;
-			if (bp->rx_csum) {
-				if (likely(BNX2X_RX_CSUM_OK(cqe)))
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				else
-					fp->eth_q_stats.hw_csum_err++;
-			}
-		}
-
-		skb_record_rx_queue(skb, fp->index);
-
-#ifdef BCM_VLAN
-		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
-		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
-		     PARSING_FLAGS_VLAN))
-			vlan_gro_receive(&fp->napi, bp->vlgrp,
-				le16_to_cpu(cqe->fast_path_cqe.vlan_tag), skb);
-		else
-#endif
-			napi_gro_receive(&fp->napi, skb);
-
-
-next_rx:
-		rx_buf->skb = NULL;
-
-		bd_cons = NEXT_RX_IDX(bd_cons);
-		bd_prod = NEXT_RX_IDX(bd_prod);
-		bd_prod_fw = NEXT_RX_IDX(bd_prod_fw);
-		rx_pkt++;
-next_cqe:
-		sw_comp_prod = NEXT_RCQ_IDX(sw_comp_prod);
-		sw_comp_cons = NEXT_RCQ_IDX(sw_comp_cons);
-
-		if (rx_pkt == budget)
-			break;
-	} /* while */
-
-	fp->rx_bd_cons = bd_cons;
-	fp->rx_bd_prod = bd_prod_fw;
-	fp->rx_comp_cons = sw_comp_cons;
-	fp->rx_comp_prod = sw_comp_prod;
-
-	/* Update producers */
-	bnx2x_update_rx_prod(bp, fp, bd_prod_fw, sw_comp_prod,
-			     fp->rx_sge_prod);
-
-	fp->rx_pkt += rx_pkt;
-	fp->rx_calls++;
-
-	return rx_pkt;
-}
-
-static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
-{
-	struct bnx2x_fastpath *fp = fp_cookie;
-	struct bnx2x *bp = fp->bp;
-
-	/* Return here if interrupt is disabled */
-	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
-		return IRQ_HANDLED;
-	}
-
-	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
-	   fp->index, fp->sb_id);
-	bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return IRQ_HANDLED;
-#endif
-
-	/* Handle Rx and Tx according to MSI-X vector */
-	prefetch(fp->rx_cons_sb);
-	prefetch(fp->tx_cons_sb);
-	prefetch(&fp->status_blk->u_status_block.status_block_index);
-	prefetch(&fp->status_blk->c_status_block.status_block_index);
-	napi_schedule(&bnx2x_fp(bp, fp->index, napi));
-
-	return IRQ_HANDLED;
-}
-
-static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
+irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 {
 	struct bnx2x *bp = netdev_priv(dev_instance);
 	u16 status = bnx2x_ack_int(bp);
@@ -1900,7 +968,6 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 
 /* end of fast path */
 
-static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
 
 /* Link */
 
@@ -1908,7 +975,7 @@ static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
  * General service functions
  */
 
-static int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource)
+int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
@@ -1953,7 +1020,7 @@ static int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource)
 	return -EAGAIN;
 }
 
-static int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource)
+int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
@@ -1989,22 +1056,6 @@ static int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource)
 	return 0;
 }
 
-/* HW Lock for shared dual port PHYs */
-static void bnx2x_acquire_phy_lock(struct bnx2x *bp)
-{
-	mutex_lock(&bp->port.phy_mutex);
-
-	if (bp->port.need_hw_lock)
-		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
-}
-
-static void bnx2x_release_phy_lock(struct bnx2x *bp)
-{
-	if (bp->port.need_hw_lock)
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_MDIO);
-
-	mutex_unlock(&bp->port.phy_mutex);
-}
 
 int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port)
 {
@@ -2181,7 +1232,7 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 	return 0;
 }
 
-static void bnx2x_calc_fc_adv(struct bnx2x *bp)
+void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
 	switch (bp->link_vars.ieee_fc &
 		MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK) {
@@ -2206,58 +1257,8 @@ static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 	}
 }
 
-static void bnx2x_link_report(struct bnx2x *bp)
-{
-	if (bp->flags & MF_FUNC_DIS) {
-		netif_carrier_off(bp->dev);
-		netdev_err(bp->dev, "NIC Link is Down\n");
-		return;
-	}
-
-	if (bp->link_vars.link_up) {
-		u16 line_speed;
-
-		if (bp->state == BNX2X_STATE_OPEN)
-			netif_carrier_on(bp->dev);
-		netdev_info(bp->dev, "NIC Link is Up, ");
-
-		line_speed = bp->link_vars.line_speed;
-		if (IS_E1HMF(bp)) {
-			u16 vn_max_rate;
-
-			vn_max_rate =
-				((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
-				 FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
-			if (vn_max_rate < line_speed)
-				line_speed = vn_max_rate;
-		}
-		pr_cont("%d Mbps ", line_speed);
-
-		if (bp->link_vars.duplex == DUPLEX_FULL)
-			pr_cont("full duplex");
-		else
-			pr_cont("half duplex");
-
-		if (bp->link_vars.flow_ctrl != BNX2X_FLOW_CTRL_NONE) {
-			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) {
-				pr_cont(", receive ");
-				if (bp->link_vars.flow_ctrl &
-				    BNX2X_FLOW_CTRL_TX)
-					pr_cont("& transmit ");
-			} else {
-				pr_cont(", transmit ");
-			}
-			pr_cont("flow control ON");
-		}
-		pr_cont("\n");
-
-	} else { /* link_down */
-		netif_carrier_off(bp->dev);
-		netdev_err(bp->dev, "NIC Link is Down\n");
-	}
-}
 
-static u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
+u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 {
 	if (!BP_NOMCP(bp)) {
 		u8 rc;
@@ -2292,7 +1293,7 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 	return -EINVAL;
 }
 
-static void bnx2x_link_set(struct bnx2x *bp)
+void bnx2x_link_set(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
@@ -2314,7 +1315,7 @@ static void bnx2x__link_reset(struct bnx2x *bp)
 		BNX2X_ERR("Bootcode is missing - can not reset link\n");
 }
 
-static u8 bnx2x_link_test(struct bnx2x *bp)
+u8 bnx2x_link_test(struct bnx2x *bp)
 {
 	u8 rc = 0;
 
@@ -2546,7 +1547,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	}
 }
 
-static void bnx2x__link_status_update(struct bnx2x *bp)
+void bnx2x__link_status_update(struct bnx2x *bp)
 {
 	if ((bp->state != BNX2X_STATE_OPEN) || (bp->flags & MF_FUNC_DIS))
 		return;
@@ -2627,9 +1628,6 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	return rc;
 }
 
-static void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set);
-static void bnx2x_set_rx_mode(struct net_device *dev);
-
 static void bnx2x_e1h_disable(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
@@ -2757,7 +1755,7 @@ static inline void bnx2x_sp_prod_update(struct bnx2x *bp)
 }
 
 /* the slow path queue is odd since completions arrive on the fastpath ring */
-static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
+int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 			 u32 data_hi, u32 data_lo, int common)
 {
 	struct eth_spe *spe;
@@ -3169,10 +2167,6 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 	}
 }
 
-static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
-static int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
-
-
 #define BNX2X_MISC_GEN_REG      MISC_REG_GENERIC_POR_1
 #define LOAD_COUNTER_BITS	16 /* Number of bits for load counter */
 #define LOAD_COUNTER_MASK	(((u32)0x1 << LOAD_COUNTER_BITS) - 1)
@@ -3206,7 +2200,7 @@ static inline void bnx2x_set_reset_in_progress(struct bnx2x *bp)
 /*
  * should be run under rtnl lock
  */
-static inline bool bnx2x_reset_is_done(struct bnx2x *bp)
+bool bnx2x_reset_is_done(struct bnx2x *bp)
 {
 	u32 val	= REG_RD(bp, BNX2X_MISC_GEN_REG);
 	DP(NETIF_MSG_HW, "GEN_REG_VAL=0x%08x\n", val);
@@ -3216,7 +2210,7 @@ static inline bool bnx2x_reset_is_done(struct bnx2x *bp)
 /*
  * should be run under rtnl lock
  */
-static inline void bnx2x_inc_load_cnt(struct bnx2x *bp)
+inline void bnx2x_inc_load_cnt(struct bnx2x *bp)
 {
 	u32 val1, val = REG_RD(bp, BNX2X_MISC_GEN_REG);
 
@@ -3231,7 +2225,7 @@ static inline void bnx2x_inc_load_cnt(struct bnx2x *bp)
 /*
  * should be run under rtnl lock
  */
-static inline u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
+u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
 {
 	u32 val1, val = REG_RD(bp, BNX2X_MISC_GEN_REG);
 
@@ -3449,7 +2443,7 @@ static inline bool bnx2x_parity_attn(struct bnx2x *bp, u32 sig0, u32 sig1,
 		return false;
 }
 
-static bool bnx2x_chk_parity_attn(struct bnx2x *bp)
+bool bnx2x_chk_parity_attn(struct bnx2x *bp)
 {
 	struct attn_route attn;
 	int port = BP_PORT(bp);
@@ -3627,7 +2621,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 		     IGU_INT_ENABLE, 1);
 }
 
-static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
+irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct bnx2x *bp = netdev_priv(dev);
@@ -4859,7 +3853,7 @@ static const struct {
 }
 };
 
-static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
+void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 {
 	enum bnx2x_stats_state state = bp->stats_state;
 
@@ -5114,7 +4108,7 @@ static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 			CSTORM_SB_STATUS_BLOCK_C_SIZE / 4);
 }
 
-static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
+void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
 			  dma_addr_t mapping, int sb_id)
 {
 	int port = BP_PORT(bp);
@@ -5293,7 +4287,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 	bnx2x_ack_sb(bp, sb_id, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 }
 
-static void bnx2x_update_coalesce(struct bnx2x *bp)
+void bnx2x_update_coalesce(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int i;
@@ -5323,207 +4317,6 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 	}
 }
 
-static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
-				       struct bnx2x_fastpath *fp, int last)
-{
-	int i;
-
-	for (i = 0; i < last; i++) {
-		struct sw_rx_bd *rx_buf = &(fp->tpa_pool[i]);
-		struct sk_buff *skb = rx_buf->skb;
-
-		if (skb == NULL) {
-			DP(NETIF_MSG_IFDOWN, "tpa bin %d empty on free\n", i);
-			continue;
-		}
-
-		if (fp->tpa_state[i] == BNX2X_TPA_START)
-			dma_unmap_single(&bp->pdev->dev,
-					 dma_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size, DMA_FROM_DEVICE);
-
-		dev_kfree_skb(skb);
-		rx_buf->skb = NULL;
-	}
-}
-
-static void bnx2x_init_rx_rings(struct bnx2x *bp)
-{
-	int func = BP_FUNC(bp);
-	int max_agg_queues = CHIP_IS_E1(bp) ? ETH_MAX_AGGREGATION_QUEUES_E1 :
-					      ETH_MAX_AGGREGATION_QUEUES_E1H;
-	u16 ring_prod, cqe_ring_prod;
-	int i, j;
-
-	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN;
-	DP(NETIF_MSG_IFUP,
-	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
-
-	if (bp->flags & TPA_ENABLE_FLAG) {
-
-		for_each_queue(bp, j) {
-			struct bnx2x_fastpath *fp = &bp->fp[j];
-
-			for (i = 0; i < max_agg_queues; i++) {
-				fp->tpa_pool[i].skb =
-				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
-				if (!fp->tpa_pool[i].skb) {
-					BNX2X_ERR("Failed to allocate TPA "
-						  "skb pool for queue[%d] - "
-						  "disabling TPA on this "
-						  "queue!\n", j);
-					bnx2x_free_tpa_pool(bp, fp, i);
-					fp->disable_tpa = 1;
-					break;
-				}
-				dma_unmap_addr_set((struct sw_rx_bd *)
-							&bp->fp->tpa_pool[i],
-						   mapping, 0);
-				fp->tpa_state[i] = BNX2X_TPA_STOP;
-			}
-		}
-	}
-
-	for_each_queue(bp, j) {
-		struct bnx2x_fastpath *fp = &bp->fp[j];
-
-		fp->rx_bd_cons = 0;
-		fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
-		fp->rx_bd_cons_sb = BNX2X_RX_SB_BD_INDEX;
-
-		/* "next page" elements initialization */
-		/* SGE ring */
-		for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
-			struct eth_rx_sge *sge;
-
-			sge = &fp->rx_sge_ring[RX_SGE_CNT * i - 2];
-			sge->addr_hi =
-				cpu_to_le32(U64_HI(fp->rx_sge_mapping +
-					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
-			sge->addr_lo =
-				cpu_to_le32(U64_LO(fp->rx_sge_mapping +
-					BCM_PAGE_SIZE*(i % NUM_RX_SGE_PAGES)));
-		}
-
-		bnx2x_init_sge_ring_bit_mask(fp);
-
-		/* RX BD ring */
-		for (i = 1; i <= NUM_RX_RINGS; i++) {
-			struct eth_rx_bd *rx_bd;
-
-			rx_bd = &fp->rx_desc_ring[RX_DESC_CNT * i - 2];
-			rx_bd->addr_hi =
-				cpu_to_le32(U64_HI(fp->rx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
-			rx_bd->addr_lo =
-				cpu_to_le32(U64_LO(fp->rx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_RX_RINGS)));
-		}
-
-		/* CQ ring */
-		for (i = 1; i <= NUM_RCQ_RINGS; i++) {
-			struct eth_rx_cqe_next_page *nextpg;
-
-			nextpg = (struct eth_rx_cqe_next_page *)
-				&fp->rx_comp_ring[RCQ_DESC_CNT * i - 1];
-			nextpg->addr_hi =
-				cpu_to_le32(U64_HI(fp->rx_comp_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
-			nextpg->addr_lo =
-				cpu_to_le32(U64_LO(fp->rx_comp_mapping +
-					   BCM_PAGE_SIZE*(i % NUM_RCQ_RINGS)));
-		}
-
-		/* Allocate SGEs and initialize the ring elements */
-		for (i = 0, ring_prod = 0;
-		     i < MAX_RX_SGE_CNT*NUM_RX_SGE_PAGES; i++) {
-
-			if (bnx2x_alloc_rx_sge(bp, fp, ring_prod) < 0) {
-				BNX2X_ERR("was only able to allocate "
-					  "%d rx sges\n", i);
-				BNX2X_ERR("disabling TPA for queue[%d]\n", j);
-				/* Cleanup already allocated elements */
-				bnx2x_free_rx_sge_range(bp, fp, ring_prod);
-				bnx2x_free_tpa_pool(bp, fp, max_agg_queues);
-				fp->disable_tpa = 1;
-				ring_prod = 0;
-				break;
-			}
-			ring_prod = NEXT_SGE_IDX(ring_prod);
-		}
-		fp->rx_sge_prod = ring_prod;
-
-		/* Allocate BDs and initialize BD ring */
-		fp->rx_comp_cons = 0;
-		cqe_ring_prod = ring_prod = 0;
-		for (i = 0; i < bp->rx_ring_size; i++) {
-			if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
-				BNX2X_ERR("was only able to allocate "
-					  "%d rx skbs on queue[%d]\n", i, j);
-				fp->eth_q_stats.rx_skb_alloc_failed++;
-				break;
-			}
-			ring_prod = NEXT_RX_IDX(ring_prod);
-			cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
-			WARN_ON(ring_prod <= i);
-		}
-
-		fp->rx_bd_prod = ring_prod;
-		/* must not have more available CQEs than BDs */
-		fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
-					 cqe_ring_prod);
-		fp->rx_pkt = fp->rx_calls = 0;
-
-		/* Warning!
-		 * this will generate an interrupt (to the TSTORM)
-		 * must only be done after chip is initialized
-		 */
-		bnx2x_update_rx_prod(bp, fp, ring_prod, fp->rx_comp_prod,
-				     fp->rx_sge_prod);
-		if (j != 0)
-			continue;
-
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func),
-		       U64_LO(fp->rx_comp_mapping));
-		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(func) + 4,
-		       U64_HI(fp->rx_comp_mapping));
-	}
-}
-
-static void bnx2x_init_tx_ring(struct bnx2x *bp)
-{
-	int i, j;
-
-	for_each_queue(bp, j) {
-		struct bnx2x_fastpath *fp = &bp->fp[j];
-
-		for (i = 1; i <= NUM_TX_RINGS; i++) {
-			struct eth_tx_next_bd *tx_next_bd =
-				&fp->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
-
-			tx_next_bd->addr_hi =
-				cpu_to_le32(U64_HI(fp->tx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-			tx_next_bd->addr_lo =
-				cpu_to_le32(U64_LO(fp->tx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-		}
-
-		fp->tx_db.data.header.header = DOORBELL_HDR_DB_TYPE;
-		fp->tx_db.data.zero_fill1 = 0;
-		fp->tx_db.data.prod = 0;
-
-		fp->tx_pkt_prod = 0;
-		fp->tx_pkt_cons = 0;
-		fp->tx_bd_prod = 0;
-		fp->tx_bd_cons = 0;
-		fp->tx_cons_sb = BNX2X_TX_SB_INDEX;
-		fp->tx_pkt = 0;
-	}
-}
-
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
@@ -5638,7 +4431,7 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 			bp->fp->cl_id + (i % bp->num_queues));
 }
 
-static void bnx2x_set_client_config(struct bnx2x *bp)
+void bnx2x_set_client_config(struct bnx2x *bp)
 {
 	struct tstorm_eth_client_config tstorm_client = {0};
 	int port = BP_PORT(bp);
@@ -5671,7 +4464,7 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	   ((u32 *)&tstorm_client)[0], ((u32 *)&tstorm_client)[1]);
 }
 
-static void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
+void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
 	struct tstorm_eth_mac_filter_config tstorm_mac_filter = {0};
 	int mode = bp->rx_mode;
@@ -5991,7 +4784,7 @@ static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
 	}
 }
 
-static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
+void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 {
 	int i;
 
@@ -7072,7 +5865,7 @@ static int bnx2x_init_func(struct bnx2x *bp)
 	return 0;
 }
 
-static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
+int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 {
 	int i, rc = 0;
 
@@ -7134,7 +5927,7 @@ init_hw_err:
 	return rc;
 }
 
-static void bnx2x_free_mem(struct bnx2x *bp)
+void bnx2x_free_mem(struct bnx2x *bp)
 {
 
 #define BNX2X_PCI_FREE(x, y, size) \
@@ -7216,7 +6009,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 #undef BNX2X_KFREE
 }
 
-static int bnx2x_alloc_mem(struct bnx2x *bp)
+int bnx2x_alloc_mem(struct bnx2x *bp)
 {
 
 #define BNX2X_PCI_ALLOC(x, y, size) \
@@ -7322,264 +6115,6 @@ alloc_mem_err:
 #undef BNX2X_ALLOC
 }
 
-static void bnx2x_free_tx_skbs(struct bnx2x *bp)
-{
-	int i;
-
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-
-		u16 bd_cons = fp->tx_bd_cons;
-		u16 sw_prod = fp->tx_pkt_prod;
-		u16 sw_cons = fp->tx_pkt_cons;
-
-		while (sw_cons != sw_prod) {
-			bd_cons = bnx2x_free_tx_pkt(bp, fp, TX_BD(sw_cons));
-			sw_cons++;
-		}
-	}
-}
-
-static void bnx2x_free_rx_skbs(struct bnx2x *bp)
-{
-	int i, j;
-
-	for_each_queue(bp, j) {
-		struct bnx2x_fastpath *fp = &bp->fp[j];
-
-		for (i = 0; i < NUM_RX_BD; i++) {
-			struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[i];
-			struct sk_buff *skb = rx_buf->skb;
-
-			if (skb == NULL)
-				continue;
-
-			dma_unmap_single(&bp->pdev->dev,
-					 dma_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size, DMA_FROM_DEVICE);
-
-			rx_buf->skb = NULL;
-			dev_kfree_skb(skb);
-		}
-		if (!fp->disable_tpa)
-			bnx2x_free_tpa_pool(bp, fp, CHIP_IS_E1(bp) ?
-					    ETH_MAX_AGGREGATION_QUEUES_E1 :
-					    ETH_MAX_AGGREGATION_QUEUES_E1H);
-	}
-}
-
-static void bnx2x_free_skbs(struct bnx2x *bp)
-{
-	bnx2x_free_tx_skbs(bp);
-	bnx2x_free_rx_skbs(bp);
-}
-
-static void bnx2x_free_msix_irqs(struct bnx2x *bp)
-{
-	int i, offset = 1;
-
-	free_irq(bp->msix_table[0].vector, bp->dev);
-	DP(NETIF_MSG_IFDOWN, "released sp irq (%d)\n",
-	   bp->msix_table[0].vector);
-
-#ifdef BCM_CNIC
-	offset++;
-#endif
-	for_each_queue(bp, i) {
-		DP(NETIF_MSG_IFDOWN, "about to release fp #%d->%d irq  "
-		   "state %x\n", i, bp->msix_table[i + offset].vector,
-		   bnx2x_fp(bp, i, state));
-
-		free_irq(bp->msix_table[i + offset].vector, &bp->fp[i]);
-	}
-}
-
-static void bnx2x_free_irq(struct bnx2x *bp, bool disable_only)
-{
-	if (bp->flags & USING_MSIX_FLAG) {
-		if (!disable_only)
-			bnx2x_free_msix_irqs(bp);
-		pci_disable_msix(bp->pdev);
-		bp->flags &= ~USING_MSIX_FLAG;
-
-	} else if (bp->flags & USING_MSI_FLAG) {
-		if (!disable_only)
-			free_irq(bp->pdev->irq, bp->dev);
-		pci_disable_msi(bp->pdev);
-		bp->flags &= ~USING_MSI_FLAG;
-
-	} else if (!disable_only)
-		free_irq(bp->pdev->irq, bp->dev);
-}
-
-static int bnx2x_enable_msix(struct bnx2x *bp)
-{
-	int i, rc, offset = 1;
-	int igu_vec = 0;
-
-	bp->msix_table[0].entry = igu_vec;
-	DP(NETIF_MSG_IFUP, "msix_table[0].entry = %d (slowpath)\n", igu_vec);
-
-#ifdef BCM_CNIC
-	igu_vec = BP_L_ID(bp) + offset;
-	bp->msix_table[1].entry = igu_vec;
-	DP(NETIF_MSG_IFUP, "msix_table[1].entry = %d (CNIC)\n", igu_vec);
-	offset++;
-#endif
-	for_each_queue(bp, i) {
-		igu_vec = BP_L_ID(bp) + offset + i;
-		bp->msix_table[i + offset].entry = igu_vec;
-		DP(NETIF_MSG_IFUP, "msix_table[%d].entry = %d "
-		   "(fastpath #%u)\n", i + offset, igu_vec, i);
-	}
-
-	rc = pci_enable_msix(bp->pdev, &bp->msix_table[0],
-			     BNX2X_NUM_QUEUES(bp) + offset);
-
-	/*
-	 * reconfigure number of tx/rx queues according to available
-	 * MSI-X vectors
-	 */
-	if (rc >= BNX2X_MIN_MSIX_VEC_CNT) {
-		/* vectors available for FP */
-		int fp_vec = rc - BNX2X_MSIX_VEC_FP_START;
-
-		DP(NETIF_MSG_IFUP,
-		   "Trying to use less MSI-X vectors: %d\n", rc);
-
-		rc = pci_enable_msix(bp->pdev, &bp->msix_table[0], rc);
-
-		if (rc) {
-			DP(NETIF_MSG_IFUP,
-			   "MSI-X is not attainable  rc %d\n", rc);
-			return rc;
-		}
-
-		bp->num_queues = min(bp->num_queues, fp_vec);
-
-		DP(NETIF_MSG_IFUP, "New queue configuration set: %d\n",
-				  bp->num_queues);
-	} else if (rc) {
-		DP(NETIF_MSG_IFUP, "MSI-X is not attainable  rc %d\n", rc);
-		return rc;
-	}
-
-	bp->flags |= USING_MSIX_FLAG;
-
-	return 0;
-}
-
-static int bnx2x_req_msix_irqs(struct bnx2x *bp)
-{
-	int i, rc, offset = 1;
-
-	rc = request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
-			 bp->dev->name, bp->dev);
-	if (rc) {
-		BNX2X_ERR("request sp irq failed\n");
-		return -EBUSY;
-	}
-
-#ifdef BCM_CNIC
-	offset++;
-#endif
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
-			 bp->dev->name, i);
-
-		rc = request_irq(bp->msix_table[i + offset].vector,
-				 bnx2x_msix_fp_int, 0, fp->name, fp);
-		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed  rc %d\n", i, rc);
-			bnx2x_free_msix_irqs(bp);
-			return -EBUSY;
-		}
-
-		fp->state = BNX2X_FP_STATE_IRQ;
-	}
-
-	i = BNX2X_NUM_QUEUES(bp);
-	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d"
-	       " ... fp[%d] %d\n",
-	       bp->msix_table[0].vector,
-	       0, bp->msix_table[offset].vector,
-	       i - 1, bp->msix_table[offset + i - 1].vector);
-
-	return 0;
-}
-
-static int bnx2x_enable_msi(struct bnx2x *bp)
-{
-	int rc;
-
-	rc = pci_enable_msi(bp->pdev);
-	if (rc) {
-		DP(NETIF_MSG_IFUP, "MSI is not attainable\n");
-		return -1;
-	}
-	bp->flags |= USING_MSI_FLAG;
-
-	return 0;
-}
-
-static int bnx2x_req_irq(struct bnx2x *bp)
-{
-	unsigned long flags;
-	int rc;
-
-	if (bp->flags & USING_MSI_FLAG)
-		flags = 0;
-	else
-		flags = IRQF_SHARED;
-
-	rc = request_irq(bp->pdev->irq, bnx2x_interrupt, flags,
-			 bp->dev->name, bp->dev);
-	if (!rc)
-		bnx2x_fp(bp, 0, state) = BNX2X_FP_STATE_IRQ;
-
-	return rc;
-}
-
-static void bnx2x_napi_enable(struct bnx2x *bp)
-{
-	int i;
-
-	for_each_queue(bp, i)
-		napi_enable(&bnx2x_fp(bp, i, napi));
-}
-
-static void bnx2x_napi_disable(struct bnx2x *bp)
-{
-	int i;
-
-	for_each_queue(bp, i)
-		napi_disable(&bnx2x_fp(bp, i, napi));
-}
-
-static void bnx2x_netif_start(struct bnx2x *bp)
-{
-	int intr_sem;
-
-	intr_sem = atomic_dec_and_test(&bp->intr_sem);
-	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
-
-	if (intr_sem) {
-		if (netif_running(bp->dev)) {
-			bnx2x_napi_enable(bp);
-			bnx2x_int_enable(bp);
-			if (bp->state == BNX2X_STATE_OPEN)
-				netif_tx_wake_all_queues(bp->dev);
-		}
-	}
-}
-
-static void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
-{
-	bnx2x_int_disable_sync(bp, disable_hw);
-	bnx2x_napi_disable(bp);
-	netif_tx_disable(bp->dev);
-}
 
 /*
  * Init service functions
@@ -7750,7 +6285,7 @@ static int bnx2x_wait_ramrod(struct bnx2x *bp, int state, int idx,
 	return -EBUSY;
 }
 
-static void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set)
+void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set)
 {
 	bp->set_mac_pending++;
 	smp_wmb();
@@ -7762,7 +6297,7 @@ static void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set)
 	bnx2x_wait_ramrod(bp, 0, 0, &bp->set_mac_pending, set ? 0 : 1);
 }
 
-static void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
+void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
 {
 	bp->set_mac_pending++;
 	smp_wmb();
@@ -7786,7 +6321,7 @@ static void bnx2x_set_eth_mac_addr_e1(struct bnx2x *bp, int set)
  *
  * @return 0 if cussess, -ENODEV if ramrod doesn't return.
  */
-static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
+int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 {
 	u32 cl_bit_vec = (1 << BCM_ISCSI_ETH_CL_ID);
 
@@ -7813,7 +6348,7 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 }
 #endif
 
-static int bnx2x_setup_leading(struct bnx2x *bp)
+int bnx2x_setup_leading(struct bnx2x *bp)
 {
 	int rc;
 
@@ -7829,7 +6364,7 @@ static int bnx2x_setup_leading(struct bnx2x *bp)
 	return rc;
 }
 
-static int bnx2x_setup_multi(struct bnx2x *bp, int index)
+int bnx2x_setup_multi(struct bnx2x *bp, int index)
 {
 	struct bnx2x_fastpath *fp = &bp->fp[index];
 
@@ -7846,9 +6381,8 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 				 &(fp->state), 0);
 }
 
-static int bnx2x_poll(struct napi_struct *napi, int budget);
 
-static void bnx2x_set_num_queues_msix(struct bnx2x *bp)
+void bnx2x_set_num_queues_msix(struct bnx2x *bp)
 {
 
 	switch (bp->multi_mode) {
@@ -7872,292 +6406,7 @@ static void bnx2x_set_num_queues_msix(struct bnx2x *bp)
 	}
 }
 
-static int bnx2x_set_num_queues(struct bnx2x *bp)
-{
-	int rc = 0;
-
-	switch (bp->int_mode) {
-	case INT_MODE_INTx:
-	case INT_MODE_MSI:
-		bp->num_queues = 1;
-		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
-		break;
-	default:
-		/* Set number of queues according to bp->multi_mode value */
-		bnx2x_set_num_queues_msix(bp);
-
-		DP(NETIF_MSG_IFUP, "set number of queues to %d\n",
-		   bp->num_queues);
-
-		/* if we can't use MSI-X we only need one fp,
-		 * so try to enable MSI-X with the requested number of fp's
-		 * and fallback to MSI or legacy INTx with one fp
-		 */
-		rc = bnx2x_enable_msix(bp);
-		if (rc)
-			/* failed to enable MSI-X */
-			bp->num_queues = 1;
-		break;
-	}
-	bp->dev->real_num_tx_queues = bp->num_queues;
-	return rc;
-}
-
-#ifdef BCM_CNIC
-static int bnx2x_cnic_notify(struct bnx2x *bp, int cmd);
-static void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
-#endif
-
-/* must be called with rtnl_lock */
-static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
-{
-	u32 load_code;
-	int i, rc;
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return -EPERM;
-#endif
-
-	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
-
-	rc = bnx2x_set_num_queues(bp);
-
-	if (bnx2x_alloc_mem(bp)) {
-		bnx2x_free_irq(bp, true);
-		return -ENOMEM;
-	}
-
-	for_each_queue(bp, i)
-		bnx2x_fp(bp, i, disable_tpa) =
-					((bp->flags & TPA_ENABLE_FLAG) == 0);
-
-	for_each_queue(bp, i)
-		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, 128);
-
-	bnx2x_napi_enable(bp);
-
-	if (bp->flags & USING_MSIX_FLAG) {
-		rc = bnx2x_req_msix_irqs(bp);
-		if (rc) {
-			bnx2x_free_irq(bp, true);
-			goto load_error1;
-		}
-	} else {
-		/* Fall to INTx if failed to enable MSI-X due to lack of
-		   memory (in bnx2x_set_num_queues()) */
-		if ((rc != -ENOMEM) && (int_mode != INT_MODE_INTx))
-			bnx2x_enable_msi(bp);
-		bnx2x_ack_int(bp);
-		rc = bnx2x_req_irq(bp);
-		if (rc) {
-			BNX2X_ERR("IRQ request failed  rc %d, aborting\n", rc);
-			bnx2x_free_irq(bp, true);
-			goto load_error1;
-		}
-		if (bp->flags & USING_MSI_FLAG) {
-			bp->dev->irq = bp->pdev->irq;
-			netdev_info(bp->dev, "using MSI  IRQ %d\n",
-				    bp->pdev->irq);
-		}
-	}
-
-	/* Send LOAD_REQUEST command to MCP
-	   Returns the type of LOAD command:
-	   if it is the first port to be initialized
-	   common blocks should be initialized, otherwise - not
-	*/
-	if (!BP_NOMCP(bp)) {
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
-		if (!load_code) {
-			BNX2X_ERR("MCP response failure, aborting\n");
-			rc = -EBUSY;
-			goto load_error2;
-		}
-		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
-			rc = -EBUSY; /* other port in diagnostic mode */
-			goto load_error2;
-		}
-
-	} else {
-		int port = BP_PORT(bp);
-
-		DP(NETIF_MSG_IFUP, "NO MCP - load counts      %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		load_count[0]++;
-		load_count[1 + port]++;
-		DP(NETIF_MSG_IFUP, "NO MCP - new load counts  %d, %d, %d\n",
-		   load_count[0], load_count[1], load_count[2]);
-		if (load_count[0] == 1)
-			load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
-		else if (load_count[1 + port] == 1)
-			load_code = FW_MSG_CODE_DRV_LOAD_PORT;
-		else
-			load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
-	}
-
-	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
-	    (load_code == FW_MSG_CODE_DRV_LOAD_PORT))
-		bp->port.pmf = 1;
-	else
-		bp->port.pmf = 0;
-	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
-
-	/* Initialize HW */
-	rc = bnx2x_init_hw(bp, load_code);
-	if (rc) {
-		BNX2X_ERR("HW init failed, aborting\n");
-		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
-		goto load_error2;
-	}
-
-	/* Setup NIC internals and enable interrupts */
-	bnx2x_nic_init(bp, load_code);
-
-	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) &&
-	    (bp->common.shmem2_base))
-		SHMEM2_WR(bp, dcc_support,
-			  (SHMEM_DCC_SUPPORT_DISABLE_ENABLE_PF_TLV |
-			   SHMEM_DCC_SUPPORT_BANDWIDTH_ALLOCATION_TLV));
 
-	/* Send LOAD_DONE command to MCP */
-	if (!BP_NOMCP(bp)) {
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
-		if (!load_code) {
-			BNX2X_ERR("MCP response failure, aborting\n");
-			rc = -EBUSY;
-			goto load_error3;
-		}
-	}
-
-	bp->state = BNX2X_STATE_OPENING_WAIT4_PORT;
-
-	rc = bnx2x_setup_leading(bp);
-	if (rc) {
-		BNX2X_ERR("Setup leading failed!\n");
-#ifndef BNX2X_STOP_ON_ERROR
-		goto load_error3;
-#else
-		bp->panic = 1;
-		return -EBUSY;
-#endif
-	}
-
-	if (CHIP_IS_E1H(bp))
-		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
-			DP(NETIF_MSG_IFUP, "mf_cfg function disabled\n");
-			bp->flags |= MF_FUNC_DIS;
-		}
-
-	if (bp->state == BNX2X_STATE_OPEN) {
-#ifdef BCM_CNIC
-		/* Enable Timer scan */
-		REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 1);
-#endif
-		for_each_nondefault_queue(bp, i) {
-			rc = bnx2x_setup_multi(bp, i);
-			if (rc)
-#ifdef BCM_CNIC
-				goto load_error4;
-#else
-				goto load_error3;
-#endif
-		}
-
-		if (CHIP_IS_E1(bp))
-			bnx2x_set_eth_mac_addr_e1(bp, 1);
-		else
-			bnx2x_set_eth_mac_addr_e1h(bp, 1);
-#ifdef BCM_CNIC
-		/* Set iSCSI L2 MAC */
-		mutex_lock(&bp->cnic_mutex);
-		if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD) {
-			bnx2x_set_iscsi_eth_mac_addr(bp, 1);
-			bp->cnic_flags |= BNX2X_CNIC_FLAG_MAC_SET;
-			bnx2x_init_sb(bp, bp->cnic_sb, bp->cnic_sb_mapping,
-				      CNIC_SB_ID(bp));
-		}
-		mutex_unlock(&bp->cnic_mutex);
-#endif
-	}
-
-	if (bp->port.pmf)
-		bnx2x_initial_phy_init(bp, load_mode);
-
-	/* Start fast path */
-	switch (load_mode) {
-	case LOAD_NORMAL:
-		if (bp->state == BNX2X_STATE_OPEN) {
-			/* Tx queue should be only reenabled */
-			netif_tx_wake_all_queues(bp->dev);
-		}
-		/* Initialize the receive filter. */
-		bnx2x_set_rx_mode(bp->dev);
-		break;
-
-	case LOAD_OPEN:
-		netif_tx_start_all_queues(bp->dev);
-		if (bp->state != BNX2X_STATE_OPEN)
-			netif_tx_disable(bp->dev);
-		/* Initialize the receive filter. */
-		bnx2x_set_rx_mode(bp->dev);
-		break;
-
-	case LOAD_DIAG:
-		/* Initialize the receive filter. */
-		bnx2x_set_rx_mode(bp->dev);
-		bp->state = BNX2X_STATE_DIAG;
-		break;
-
-	default:
-		break;
-	}
-
-	if (!bp->port.pmf)
-		bnx2x__link_status_update(bp);
-
-	/* start the timer */
-	mod_timer(&bp->timer, jiffies + bp->current_interval);
-
-#ifdef BCM_CNIC
-	bnx2x_setup_cnic_irq_info(bp);
-	if (bp->state == BNX2X_STATE_OPEN)
-		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
-#endif
-	bnx2x_inc_load_cnt(bp);
-
-	return 0;
-
-#ifdef BCM_CNIC
-load_error4:
-	/* Disable Timer scan */
-	REG_WR(bp, TM_REG_EN_LINEAR0_TIMER + BP_PORT(bp)*4, 0);
-#endif
-load_error3:
-	bnx2x_int_disable_sync(bp, 1);
-	if (!BP_NOMCP(bp)) {
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
-	}
-	bp->port.pmf = 0;
-	/* Free SKBs, SGEs, TPA pool and driver internals */
-	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
-		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-load_error2:
-	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
-load_error1:
-	bnx2x_napi_disable(bp);
-	for_each_queue(bp, i)
-		netif_napi_del(&bnx2x_fp(bp, i, napi));
-	bnx2x_free_mem(bp);
-
-	return rc;
-}
 
 static int bnx2x_stop_multi(struct bnx2x *bp, int index)
 {
@@ -8315,7 +6564,7 @@ static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 	}
 }
 
-static void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
+void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 {
 	int port = BP_PORT(bp);
 	u32 reset_code = 0;
@@ -8463,7 +6712,7 @@ unload_error:
 
 }
 
-static inline void bnx2x_disable_close_the_gate(struct bnx2x *bp)
+void bnx2x_disable_close_the_gate(struct bnx2x *bp)
 {
 	u32 val;
 
@@ -8485,71 +6734,6 @@ static inline void bnx2x_disable_close_the_gate(struct bnx2x *bp)
 	}
 }
 
-/* must be called with rtnl_lock */
-static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
-{
-	int i;
-
-	if (bp->state == BNX2X_STATE_CLOSED) {
-		/* Interface has been removed - nothing to recover */
-		bp->recovery_state = BNX2X_RECOVERY_DONE;
-		bp->is_leader = 0;
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
-		smp_wmb();
-
-		return -EINVAL;
-	}
-
-#ifdef BCM_CNIC
-	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
-#endif
-	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
-
-	/* Set "drop all" */
-	bp->rx_mode = BNX2X_RX_MODE_NONE;
-	bnx2x_set_storm_rx_mode(bp);
-
-	/* Disable HW interrupts, NAPI and Tx */
-	bnx2x_netif_stop(bp, 1);
-	netif_carrier_off(bp->dev);
-
-	del_timer_sync(&bp->timer);
-	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
-		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
-	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
-
-	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
-
-	/* Cleanup the chip if needed */
-	if (unload_mode != UNLOAD_RECOVERY)
-		bnx2x_chip_cleanup(bp, unload_mode);
-
-	bp->port.pmf = 0;
-
-	/* Free SKBs, SGEs, TPA pool and driver internals */
-	bnx2x_free_skbs(bp);
-	for_each_queue(bp, i)
-		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_queue(bp, i)
-		netif_napi_del(&bnx2x_fp(bp, i, napi));
-	bnx2x_free_mem(bp);
-
-	bp->state = BNX2X_STATE_CLOSED;
-
-	/* The last driver must disable a "close the gate" if there is no
-	 * parity attention or "process kill" pending.
-	 */
-	if ((!bnx2x_dec_load_cnt(bp)) && (!bnx2x_chk_parity_attn(bp)) &&
-	    bnx2x_reset_is_done(bp))
-		bnx2x_disable_close_the_gate(bp);
-
-	/* Reset MCP mail box sequence if there is on going recovery */
-	if (unload_mode == UNLOAD_RECOVERY)
-		bp->fw_seq = 0;
-
-	return 0;
-}
 
 /* Close gates #2, #3 and #4: */
 static void bnx2x_set_234_gates(struct bnx2x *bp, bool close)
@@ -8862,8 +7046,6 @@ exit_leader_reset:
 	return rc;
 }
 
-static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
-
 /* Assumption: runs under rtnl lock. This together with the fact
  * that it's called only from bnx2x_reset_task() ensure that it
  * will never be called when netif_running(bp->dev) is false.
@@ -11938,598 +10120,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 
 /* end of ethtool_ops */
 
-/****************************************************************************
-* General service functions
-****************************************************************************/
-
-static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
-{
-	u16 pmcsr;
-
-	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmcsr);
-
-	switch (state) {
-	case PCI_D0:
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
-				      ((pmcsr & ~PCI_PM_CTRL_STATE_MASK) |
-				       PCI_PM_CTRL_PME_STATUS));
-
-		if (pmcsr & PCI_PM_CTRL_STATE_MASK)
-			/* delay required during transition out of D3hot */
-			msleep(20);
-		break;
-
-	case PCI_D3hot:
-		/* If there are other clients above don't
-		   shut down the power */
-		if (atomic_read(&bp->pdev->enable_cnt) != 1)
-			return 0;
-		/* Don't shut down the power for emulation and FPGA */
-		if (CHIP_REV_IS_SLOW(bp))
-			return 0;
-
-		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
-		pmcsr |= 3;
-
-		if (bp->wol)
-			pmcsr |= PCI_PM_CTRL_PME_ENABLE;
-
-		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL,
-				      pmcsr);
-
-		/* No more memory access after this point until
-		* device is brought back to D0.
-		*/
-		break;
-
-	default:
-		return -EINVAL;
-	}
-	return 0;
-}
-
-static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
-{
-	u16 rx_cons_sb;
-
-	/* Tell compiler that status block fields can change */
-	barrier();
-	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
-	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		rx_cons_sb++;
-	return (fp->rx_comp_cons != rx_cons_sb);
-}
-
-/*
- * net_device service functions
- */
-
-static int bnx2x_poll(struct napi_struct *napi, int budget)
-{
-	int work_done = 0;
-	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
-						 napi);
-	struct bnx2x *bp = fp->bp;
-
-	while (1) {
-#ifdef BNX2X_STOP_ON_ERROR
-		if (unlikely(bp->panic)) {
-			napi_complete(napi);
-			return 0;
-		}
-#endif
-
-		if (bnx2x_has_tx_work(fp))
-			bnx2x_tx_int(fp);
-
-		if (bnx2x_has_rx_work(fp)) {
-			work_done += bnx2x_rx_int(fp, budget - work_done);
-
-			/* must not complete if we consumed full budget */
-			if (work_done >= budget)
-				break;
-		}
-
-		/* Fall out from the NAPI loop if needed */
-		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
-			bnx2x_update_fpsb_idx(fp);
-		/* bnx2x_has_rx_work() reads the status block, thus we need
-		 * to ensure that status block indices have been actually read
-		 * (bnx2x_update_fpsb_idx) prior to this check
-		 * (bnx2x_has_rx_work) so that we won't write the "newer"
-		 * value of the status block to IGU (if there was a DMA right
-		 * after bnx2x_has_rx_work and if there is no rmb, the memory
-		 * reading (bnx2x_update_fpsb_idx) may be postponed to right
-		 * before bnx2x_ack_sb). In this case there will never be
-		 * another interrupt until there is another update of the
-		 * status block, while there is still unhandled work.
-		 */
-			rmb();
-
-			if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
-				napi_complete(napi);
-				/* Re-enable interrupts */
-				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-					     le16_to_cpu(fp->fp_c_idx),
-					     IGU_INT_NOP, 1);
-				bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-					     le16_to_cpu(fp->fp_u_idx),
-					     IGU_INT_ENABLE, 1);
-				break;
-			}
-		}
-	}
-
-	return work_done;
-}
-
-
-/* we split the first BD into headers and data BDs
- * to ease the pain of our fellow microcode engineers
- * we use one mapping for both BDs
- * So far this has only been observed to happen
- * in Other Operating Systems(TM)
- */
-static noinline u16 bnx2x_tx_split(struct bnx2x *bp,
-				   struct bnx2x_fastpath *fp,
-				   struct sw_tx_bd *tx_buf,
-				   struct eth_tx_start_bd **tx_bd, u16 hlen,
-				   u16 bd_prod, int nbd)
-{
-	struct eth_tx_start_bd *h_tx_bd = *tx_bd;
-	struct eth_tx_bd *d_tx_bd;
-	dma_addr_t mapping;
-	int old_len = le16_to_cpu(h_tx_bd->nbytes);
-
-	/* first fix first BD */
-	h_tx_bd->nbd = cpu_to_le16(nbd);
-	h_tx_bd->nbytes = cpu_to_le16(hlen);
-
-	DP(NETIF_MSG_TX_QUEUED,	"TSO split header size is %d "
-	   "(%x:%x) nbd %d\n", h_tx_bd->nbytes, h_tx_bd->addr_hi,
-	   h_tx_bd->addr_lo, h_tx_bd->nbd);
-
-	/* now get a new data BD
-	 * (after the pbd) and fill it */
-	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-	d_tx_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
-
-	mapping = HILO_U64(le32_to_cpu(h_tx_bd->addr_hi),
-			   le32_to_cpu(h_tx_bd->addr_lo)) + hlen;
-
-	d_tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-	d_tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-	d_tx_bd->nbytes = cpu_to_le16(old_len - hlen);
-
-	/* this marks the BD as one that has no individual mapping */
-	tx_buf->flags |= BNX2X_TSO_SPLIT_BD;
-
-	DP(NETIF_MSG_TX_QUEUED,
-	   "TSO split data size is %d (%x:%x)\n",
-	   d_tx_bd->nbytes, d_tx_bd->addr_hi, d_tx_bd->addr_lo);
-
-	/* update tx_bd */
-	*tx_bd = (struct eth_tx_start_bd *)d_tx_bd;
-
-	return bd_prod;
-}
-
-static inline u16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8 fix)
-{
-	if (fix > 0)
-		csum = (u16) ~csum_fold(csum_sub(csum,
-				csum_partial(t_header - fix, fix, 0)));
-
-	else if (fix < 0)
-		csum = (u16) ~csum_fold(csum_add(csum,
-				csum_partial(t_header, -fix, 0)));
-
-	return swab16(csum);
-}
-
-static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
-{
-	u32 rc;
-
-	if (skb->ip_summed != CHECKSUM_PARTIAL)
-		rc = XMIT_PLAIN;
-
-	else {
-		if (skb->protocol == htons(ETH_P_IPV6)) {
-			rc = XMIT_CSUM_V6;
-			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
-				rc |= XMIT_CSUM_TCP;
-
-		} else {
-			rc = XMIT_CSUM_V4;
-			if (ip_hdr(skb)->protocol == IPPROTO_TCP)
-				rc |= XMIT_CSUM_TCP;
-		}
-	}
-
-	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
-
-	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
-
-	return rc;
-}
-
-#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
-/* check if packet requires linearization (packet is too fragmented)
-   no need to check fragmentation if page size > 8K (there will be no
-   violation to FW restrictions) */
-static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
-			     u32 xmit_type)
-{
-	int to_copy = 0;
-	int hlen = 0;
-	int first_bd_sz = 0;
-
-	/* 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
-	if (skb_shinfo(skb)->nr_frags >= (MAX_FETCH_BD - 3)) {
-
-		if (xmit_type & XMIT_GSO) {
-			unsigned short lso_mss = skb_shinfo(skb)->gso_size;
-			/* Check if LSO packet needs to be copied:
-			   3 = 1 (for headers BD) + 2 (for PBD and last BD) */
-			int wnd_size = MAX_FETCH_BD - 3;
-			/* Number of windows to check */
-			int num_wnds = skb_shinfo(skb)->nr_frags - wnd_size;
-			int wnd_idx = 0;
-			int frag_idx = 0;
-			u32 wnd_sum = 0;
-
-			/* Headers length */
-			hlen = (int)(skb_transport_header(skb) - skb->data) +
-				tcp_hdrlen(skb);
-
-			/* Amount of data (w/o headers) on linear part of SKB*/
-			first_bd_sz = skb_headlen(skb) - hlen;
-
-			wnd_sum  = first_bd_sz;
-
-			/* Calculate the first sum - it's special */
-			for (frag_idx = 0; frag_idx < wnd_size - 1; frag_idx++)
-				wnd_sum +=
-					skb_shinfo(skb)->frags[frag_idx].size;
-
-			/* If there was data on linear skb data - check it */
-			if (first_bd_sz > 0) {
-				if (unlikely(wnd_sum < lso_mss)) {
-					to_copy = 1;
-					goto exit_lbl;
-				}
-
-				wnd_sum -= first_bd_sz;
-			}
-
-			/* Others are easier: run through the frag list and
-			   check all windows */
-			for (wnd_idx = 0; wnd_idx <= num_wnds; wnd_idx++) {
-				wnd_sum +=
-			  skb_shinfo(skb)->frags[wnd_idx + wnd_size - 1].size;
-
-				if (unlikely(wnd_sum < lso_mss)) {
-					to_copy = 1;
-					break;
-				}
-				wnd_sum -=
-					skb_shinfo(skb)->frags[wnd_idx].size;
-			}
-		} else {
-			/* in non-LSO too fragmented packet should always
-			   be linearized */
-			to_copy = 1;
-		}
-	}
-
-exit_lbl:
-	if (unlikely(to_copy))
-		DP(NETIF_MSG_TX_QUEUED,
-		   "Linearization IS REQUIRED for %s packet. "
-		   "num_frags %d  hlen %d  first_bd_sz %d\n",
-		   (xmit_type & XMIT_GSO) ? "LSO" : "non-LSO",
-		   skb_shinfo(skb)->nr_frags, hlen, first_bd_sz);
-
-	return to_copy;
-}
-#endif
-
-/* called with netif_tx_lock
- * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
- * netif_wake_queue()
- */
-static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-	struct bnx2x_fastpath *fp;
-	struct netdev_queue *txq;
-	struct sw_tx_bd *tx_buf;
-	struct eth_tx_start_bd *tx_start_bd;
-	struct eth_tx_bd *tx_data_bd, *total_pkt_bd = NULL;
-	struct eth_tx_parse_bd *pbd = NULL;
-	u16 pkt_prod, bd_prod;
-	int nbd, fp_index;
-	dma_addr_t mapping;
-	u32 xmit_type = bnx2x_xmit_type(bp, skb);
-	int i;
-	u8 hlen = 0;
-	__le16 pkt_size = 0;
-	struct ethhdr *eth;
-	u8 mac_type = UNICAST_ADDRESS;
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		return NETDEV_TX_BUSY;
-#endif
-
-	fp_index = skb_get_queue_mapping(skb);
-	txq = netdev_get_tx_queue(dev, fp_index);
-
-	fp = &bp->fp[fp_index];
-
-	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
-		fp->eth_q_stats.driver_xoff++;
-		netif_tx_stop_queue(txq);
-		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
-		return NETDEV_TX_BUSY;
-	}
-
-	DP(NETIF_MSG_TX_QUEUED, "SKB: summed %x  protocol %x  protocol(%x,%x)"
-	   "  gso type %x  xmit_type %x\n",
-	   skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
-	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
-
-	eth = (struct ethhdr *)skb->data;
-
-	/* set flag according to packet type (UNICAST_ADDRESS is default)*/
-	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
-		if (is_broadcast_ether_addr(eth->h_dest))
-			mac_type = BROADCAST_ADDRESS;
-		else
-			mac_type = MULTICAST_ADDRESS;
-	}
-
-#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
-	/* First, check if we need to linearize the skb (due to FW
-	   restrictions). No need to check fragmentation if page size > 8K
-	   (there will be no violation to FW restrictions) */
-	if (bnx2x_pkt_req_lin(bp, skb, xmit_type)) {
-		/* Statistics of linearization */
-		bp->lin_cnt++;
-		if (skb_linearize(skb) != 0) {
-			DP(NETIF_MSG_TX_QUEUED, "SKB linearization failed - "
-			   "silently dropping this SKB\n");
-			dev_kfree_skb_any(skb);
-			return NETDEV_TX_OK;
-		}
-	}
-#endif
-
-	/*
-	Please read carefully. First we use one BD which we mark as start,
-	then we have a parsing info BD (used for TSO or xsum),
-	and only then we have the rest of the TSO BDs.
-	(don't forget to mark the last one as last,
-	and to unmap only AFTER you write to the BD ...)
-	And above all, all pdb sizes are in words - NOT DWORDS!
-	*/
-
-	pkt_prod = fp->tx_pkt_prod++;
-	bd_prod = TX_BD(fp->tx_bd_prod);
-
-	/* get a tx_buf and first BD */
-	tx_buf = &fp->tx_buf_ring[TX_BD(pkt_prod)];
-	tx_start_bd = &fp->tx_desc_ring[bd_prod].start_bd;
-
-	tx_start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
-	tx_start_bd->general_data =  (mac_type <<
-					ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
-	/* header nbd */
-	tx_start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
-
-	/* remember the first BD of the packet */
-	tx_buf->first_bd = fp->tx_bd_prod;
-	tx_buf->skb = skb;
-	tx_buf->flags = 0;
-
-	DP(NETIF_MSG_TX_QUEUED,
-	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
-	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_start_bd);
-
-#ifdef BCM_VLAN
-	if ((bp->vlgrp != NULL) && vlan_tx_tag_present(skb) &&
-	    (bp->flags & HW_VLAN_TX_FLAG)) {
-		tx_start_bd->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
-		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
-	} else
-#endif
-		tx_start_bd->vlan = cpu_to_le16(pkt_prod);
-
-	/* turn on parsing and get a BD */
-	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-	pbd = &fp->tx_desc_ring[bd_prod].parse_bd;
-
-	memset(pbd, 0, sizeof(struct eth_tx_parse_bd));
-
-	if (xmit_type & XMIT_CSUM) {
-		hlen = (skb_network_header(skb) - skb->data) / 2;
-
-		/* for now NS flag is not used in Linux */
-		pbd->global_data =
-			(hlen | ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
-				 ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
-
-		pbd->ip_hlen = (skb_transport_header(skb) -
-				skb_network_header(skb)) / 2;
-
-		hlen += pbd->ip_hlen + tcp_hdrlen(skb) / 2;
-
-		pbd->total_hlen = cpu_to_le16(hlen);
-		hlen = hlen*2;
-
-		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_L4_CSUM;
-
-		if (xmit_type & XMIT_CSUM_V4)
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IP_CSUM;
-		else
-			tx_start_bd->bd_flags.as_bitfield |=
-						ETH_TX_BD_FLAGS_IPV6;
-
-		if (xmit_type & XMIT_CSUM_TCP) {
-			pbd->tcp_pseudo_csum = swab16(tcp_hdr(skb)->check);
-
-		} else {
-			s8 fix = SKB_CS_OFF(skb); /* signed! */
-
-			pbd->global_data |= ETH_TX_PARSE_BD_UDP_CS_FLG;
-
-			DP(NETIF_MSG_TX_QUEUED,
-			   "hlen %d  fix %d  csum before fix %x\n",
-			   le16_to_cpu(pbd->total_hlen), fix, SKB_CS(skb));
-
-			/* HW bug: fixup the CSUM */
-			pbd->tcp_pseudo_csum =
-				bnx2x_csum_fix(skb_transport_header(skb),
-					       SKB_CS(skb), fix);
-
-			DP(NETIF_MSG_TX_QUEUED, "csum after fix %x\n",
-			   pbd->tcp_pseudo_csum);
-		}
-	}
-
-	mapping = dma_map_single(&bp->pdev->dev, skb->data,
-				 skb_headlen(skb), DMA_TO_DEVICE);
-
-	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-	nbd = skb_shinfo(skb)->nr_frags + 2; /* start_bd + pbd + frags */
-	tx_start_bd->nbd = cpu_to_le16(nbd);
-	tx_start_bd->nbytes = cpu_to_le16(skb_headlen(skb));
-	pkt_size = tx_start_bd->nbytes;
-
-	DP(NETIF_MSG_TX_QUEUED, "first bd @%p  addr (%x:%x)  nbd %d"
-	   "  nbytes %d  flags %x  vlan %x\n",
-	   tx_start_bd, tx_start_bd->addr_hi, tx_start_bd->addr_lo,
-	   le16_to_cpu(tx_start_bd->nbd), le16_to_cpu(tx_start_bd->nbytes),
-	   tx_start_bd->bd_flags.as_bitfield, le16_to_cpu(tx_start_bd->vlan));
-
-	if (xmit_type & XMIT_GSO) {
-
-		DP(NETIF_MSG_TX_QUEUED,
-		   "TSO packet len %d  hlen %d  total len %d  tso size %d\n",
-		   skb->len, hlen, skb_headlen(skb),
-		   skb_shinfo(skb)->gso_size);
-
-		tx_start_bd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
-
-		if (unlikely(skb_headlen(skb) > hlen))
-			bd_prod = bnx2x_tx_split(bp, fp, tx_buf, &tx_start_bd,
-						 hlen, bd_prod, ++nbd);
-
-		pbd->lso_mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
-		pbd->tcp_send_seq = swab32(tcp_hdr(skb)->seq);
-		pbd->tcp_flags = pbd_tcp_flags(skb);
-
-		if (xmit_type & XMIT_GSO_V4) {
-			pbd->ip_id = swab16(ip_hdr(skb)->id);
-			pbd->tcp_pseudo_csum =
-				swab16(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
-							  ip_hdr(skb)->daddr,
-							  0, IPPROTO_TCP, 0));
-
-		} else
-			pbd->tcp_pseudo_csum =
-				swab16(~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-							&ipv6_hdr(skb)->daddr,
-							0, IPPROTO_TCP, 0));
-
-		pbd->global_data |= ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
-	}
-	tx_data_bd = (struct eth_tx_bd *)tx_start_bd;
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-
-		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-		tx_data_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
-		if (total_pkt_bd == NULL)
-			total_pkt_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
-
-		mapping = dma_map_page(&bp->pdev->dev, frag->page,
-				       frag->page_offset,
-				       frag->size, DMA_TO_DEVICE);
-
-		tx_data_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
-		tx_data_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-		tx_data_bd->nbytes = cpu_to_le16(frag->size);
-		le16_add_cpu(&pkt_size, frag->size);
-
-		DP(NETIF_MSG_TX_QUEUED,
-		   "frag %d  bd @%p  addr (%x:%x)  nbytes %d\n",
-		   i, tx_data_bd, tx_data_bd->addr_hi, tx_data_bd->addr_lo,
-		   le16_to_cpu(tx_data_bd->nbytes));
-	}
-
-	DP(NETIF_MSG_TX_QUEUED, "last bd @%p\n", tx_data_bd);
-
-	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
-
-	/* now send a tx doorbell, counting the next BD
-	 * if the packet contains or ends with it
-	 */
-	if (TX_BD_POFF(bd_prod) < nbd)
-		nbd++;
-
-	if (total_pkt_bd != NULL)
-		total_pkt_bd->total_pkt_bytes = pkt_size;
-
-	if (pbd)
-		DP(NETIF_MSG_TX_QUEUED,
-		   "PBD @%p  ip_data %x  ip_hlen %u  ip_id %u  lso_mss %u"
-		   "  tcp_flags %x  xsum %x  seq %u  hlen %u\n",
-		   pbd, pbd->global_data, pbd->ip_hlen, pbd->ip_id,
-		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
-		   pbd->tcp_send_seq, le16_to_cpu(pbd->total_hlen));
-
-	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd %d  bd %u\n", nbd, bd_prod);
-
-	/*
-	 * Make sure that the BD data is updated before updating the producer
-	 * since FW might read the BD right after the producer is updated.
-	 * This is only applicable for weak-ordered memory model archs such
-	 * as IA-64. The following barrier is also mandatory since FW will
-	 * assumes packets must have BDs.
-	 */
-	wmb();
-
-	fp->tx_db.data.prod += nbd;
-	barrier();
-	DOORBELL(bp, fp->index, fp->tx_db.raw);
-
-	mmiowb();
-
-	fp->tx_bd_prod += nbd;
-
-	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
-		netif_tx_stop_queue(txq);
-
-		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
-		 * ordering of set_bit() in netif_tx_stop_queue() and read of
-		 * fp->bd_tx_cons */
-		smp_mb();
-
-		fp->eth_q_stats.driver_xoff++;
-		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
-			netif_tx_wake_queue(txq);
-	}
-	fp->tx_pkt++;
-
-	return NETDEV_TX_OK;
-}
 
 /* called with rtnl_lock */
 static int bnx2x_open(struct net_device *dev)
@@ -12590,7 +10180,7 @@ static int bnx2x_close(struct net_device *dev)
 }
 
 /* called with netif_tx_lock from dev_mcast.c */
-static void bnx2x_set_rx_mode(struct net_device *dev)
+void bnx2x_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 rx_mode = BNX2X_RX_MODE_NORMAL;
@@ -12710,25 +10300,6 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 	bnx2x_set_storm_rx_mode(bp);
 }
 
-/* called with rtnl_lock */
-static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr = p;
-	struct bnx2x *bp = netdev_priv(dev);
-
-	if (!is_valid_ether_addr((u8 *)(addr->sa_data)))
-		return -EINVAL;
-
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	if (netif_running(dev)) {
-		if (CHIP_IS_E1(bp))
-			bnx2x_set_eth_mac_addr_e1(bp, 1);
-		else
-			bnx2x_set_eth_mac_addr_e1h(bp, 1);
-	}
-
-	return 0;
-}
 
 /* called with rtnl_lock */
 static int bnx2x_mdio_read(struct net_device *netdev, int prtad,
@@ -12804,71 +10375,6 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return mdio_mii_ioctl(&bp->mdio, mdio, cmd);
 }
 
-/* called with rtnl_lock */
-static int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-	int rc = 0;
-
-	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
-		return -EAGAIN;
-	}
-
-	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
-	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE))
-		return -EINVAL;
-
-	/* This does not race with packet allocation
-	 * because the actual alloc size is
-	 * only updated as part of load
-	 */
-	dev->mtu = new_mtu;
-
-	if (netif_running(dev)) {
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
-	}
-
-	return rc;
-}
-
-static void bnx2x_tx_timeout(struct net_device *dev)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-
-#ifdef BNX2X_STOP_ON_ERROR
-	if (!bp->panic)
-		bnx2x_panic();
-#endif
-	/* This allows the netif to be shutdown gracefully before resetting */
-	schedule_delayed_work(&bp->reset_task, 0);
-}
-
-#ifdef BCM_VLAN
-/* called with rtnl_lock */
-static void bnx2x_vlan_rx_register(struct net_device *dev,
-				   struct vlan_group *vlgrp)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-
-	bp->vlgrp = vlgrp;
-
-	/* Set flags according to the required capabilities */
-	bp->flags &= ~(HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
-
-	if (dev->features & NETIF_F_HW_VLAN_TX)
-		bp->flags |= HW_VLAN_TX_FLAG;
-
-	if (dev->features & NETIF_F_HW_VLAN_RX)
-		bp->flags |= HW_VLAN_RX_FLAG;
-
-	if (netif_running(dev))
-		bnx2x_set_client_config(bp);
-}
-
-#endif
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_bnx2x(struct net_device *dev)
 {
@@ -13370,73 +10876,6 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
-static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp;
-
-	if (!dev) {
-		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
-		return -ENODEV;
-	}
-	bp = netdev_priv(dev);
-
-	rtnl_lock();
-
-	pci_save_state(pdev);
-
-	if (!netif_running(dev)) {
-		rtnl_unlock();
-		return 0;
-	}
-
-	netif_device_detach(dev);
-
-	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
-
-	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
-
-	rtnl_unlock();
-
-	return 0;
-}
-
-static int bnx2x_resume(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp;
-	int rc;
-
-	if (!dev) {
-		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
-		return -ENODEV;
-	}
-	bp = netdev_priv(dev);
-
-	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
-		return -EAGAIN;
-	}
-
-	rtnl_lock();
-
-	pci_restore_state(pdev);
-
-	if (!netif_running(dev)) {
-		rtnl_unlock();
-		return 0;
-	}
-
-	bnx2x_set_power_state(bp, PCI_D0);
-	netif_device_attach(dev);
-
-	rc = bnx2x_nic_load(bp, LOAD_OPEN);
-
-	rtnl_unlock();
-
-	return rc;
-}
-
 static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 {
 	int i;
@@ -13758,7 +11197,7 @@ static int bnx2x_cnic_ctl_send_bh(struct bnx2x *bp, struct cnic_ctl_info *ctl)
 /*
  * for commands that have no data
  */
-static int bnx2x_cnic_notify(struct bnx2x *bp, int cmd)
+int bnx2x_cnic_notify(struct bnx2x *bp, int cmd)
 {
 	struct cnic_ctl_info ctl = {0};
 
@@ -13826,7 +11265,7 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 	return rc;
 }
 
-static void bnx2x_setup_cnic_irq_info(struct bnx2x *bp)
+void bnx2x_setup_cnic_irq_info(struct bnx2x *bp)
 {
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
 
-- 
1.7.1




