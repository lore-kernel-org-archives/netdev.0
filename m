From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v2 03/13] net: ethernet: aquantia: Add ring support code
Date: Mon,  9 Jan 2017 14:16:01 -0800
Message-ID: <6dfadde2e1fe39b46d814c83fb7460566e860095.1483999588.git.vomlehn@texas.net>
References: <cover.1483999588.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:42510 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932080AbdAIWQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:16:52 -0500
In-Reply-To: <cover.1483999588.git.vomlehn@texas.net>
In-Reply-To: <6d32f594bb99a6f56f82f13f6aa54885a06b1e22.1483999588.git.vomlehn@texas.net>
References: <cover.1483999588.git.vomlehn@texas.net> <0b0d8974bdbfa66ab3bc4460f32f7916dd54b85a.1483999588.git.vomlehn@texas.net> <6d32f594bb99a6f56f82f13f6aa54885a06b1e22.1483999588.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add code to support the transmit and receive ring buffers.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/aq_ring.c | 344 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/aquantia/aq_ring.h | 147 ++++++++++++++
 2 files changed, 491 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/aq_ring.c
 create mode 100644 drivers/net/ethernet/aquantia/aq_ring.h

diff --git a/drivers/net/ethernet/aquantia/aq_ring.c b/drivers/net/ethernet/aquantia/aq_ring.c
new file mode 100644
index 0000000..3aeedb6
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_ring.c
@@ -0,0 +1,344 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_ring.c: Definition of functions for Rx/Tx rings. */
+
+#include "aq_ring.h"
+#include "aq_nic.h"
+#include "aq_hw.h"
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+
+static struct aq_ring_s *aq_ring_alloc(struct aq_ring_s *self,
+				       struct aq_nic_s *aq_nic)
+{
+	int err = 0;
+
+	self->buff_ring = (struct aq_ring_buff_s *)
+		kzalloc(sizeof(struct aq_ring_buff_s) * self->size, GFP_KERNEL);
+
+	if (!self->buff_ring) {
+		err = -ENOMEM;
+		goto err_exit;
+	}
+	self->dx_ring = dma_alloc_coherent(aq_nic_get_dev(aq_nic),
+						self->size * self->dx_size,
+						&self->dx_ring_pa, GFP_KERNEL);
+	if (!self->dx_ring) {
+		err = -ENOMEM;
+		goto err_exit;
+	}
+
+err_exit:
+	if (err < 0) {
+		aq_ring_free(self);
+		self = NULL;
+	}
+	return self;
+}
+
+struct aq_ring_s *aq_ring_tx_alloc(struct aq_ring_s *self,
+				   struct aq_nic_s *aq_nic,
+				   unsigned int idx,
+				   struct aq_nic_cfg_s *aq_nic_cfg)
+{
+	int err = 0;
+
+	self->aq_nic = aq_nic;
+	self->idx = idx;
+	self->size = aq_nic_cfg->txds;
+	self->dx_size = aq_nic_cfg->aq_hw_caps->txd_size;
+
+	self = aq_ring_alloc(self, aq_nic);
+	if (!self) {
+		err = -ENOMEM;
+		goto err_exit;
+	}
+
+err_exit:
+	if (err < 0) {
+		aq_ring_free(self);
+		self = NULL;
+	}
+	return self;
+}
+
+struct aq_ring_s *aq_ring_rx_alloc(struct aq_ring_s *self,
+				   struct aq_nic_s *aq_nic,
+				   unsigned int idx,
+				   struct aq_nic_cfg_s *aq_nic_cfg)
+{
+	int err = 0;
+
+	self->aq_nic = aq_nic;
+	self->idx = idx;
+	self->size = aq_nic_cfg->rxds;
+	self->dx_size = aq_nic_cfg->aq_hw_caps->rxd_size;
+
+	self = aq_ring_alloc(self, aq_nic);
+	if (!self) {
+		err = -ENOMEM;
+		goto err_exit;
+	}
+
+err_exit:
+	if (err < 0) {
+		aq_ring_free(self);
+		self = NULL;
+	}
+	return self;
+}
+
+void aq_ring_init(struct aq_ring_s *self)
+{
+	self->hw_head = 0;
+	self->sw_head = 0;
+	self->sw_tail = 0;
+}
+
+void aq_ring_free(struct aq_ring_s *self)
+{
+	if (!self)
+		return;
+
+	kfree(self->buff_ring);
+
+	if (self->dx_ring)
+		dma_free_coherent(aq_nic_get_dev(self->aq_nic),
+				  self->size * self->dx_size, self->dx_ring,
+				  self->dx_ring_pa);
+}
+
+void aq_ring_tx_append_buffs(struct aq_ring_s *self,
+			     struct aq_ring_buff_s *buffer,
+			     unsigned int buffers)
+{
+	if (likely(self->sw_tail + buffers < self->size)) {
+		memcpy(&self->buff_ring[self->sw_tail], buffer,
+		       sizeof(buffer[0]) * buffers);
+	} else {
+		unsigned int first_part = self->size - self->sw_tail;
+		unsigned int second_part = buffers - first_part;
+
+		memcpy(&self->buff_ring[self->sw_tail], buffer,
+		       sizeof(buffer[0]) * first_part);
+
+		memcpy(&self->buff_ring[0], &buffer[first_part],
+		       sizeof(buffer[0]) * second_part);
+	}
+}
+
+void aq_ring_tx_clean(struct aq_ring_s *self)
+{
+	struct device *dev = aq_nic_get_dev(self->aq_nic);
+	struct net_device *ndev = aq_nic_get_ndev(self->aq_nic);
+
+	for (; self->sw_head != self->hw_head;
+		self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
+		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
+
+		++self->stats.tx_packets;
+		++ndev->stats.tx_packets;
+		ndev->stats.tx_bytes += buff->len;
+
+		if (likely(buff->is_mapped)) {
+			if (unlikely(buff->is_sop))
+				dma_unmap_single(dev, buff->pa, buff->len,
+						 DMA_TO_DEVICE);
+			else
+				dma_unmap_page(dev, buff->pa, buff->len,
+					       DMA_TO_DEVICE);
+		}
+
+		if (unlikely(buff->is_eop))
+			dev_kfree_skb_any(buff->skb);
+	}
+
+	if (aq_ring_avail_dx(self) > AQ_CFG_SKB_FRAGS_MAX)
+		aq_nic_ndev_queue_start(self->aq_nic, self->idx);
+}
+
+static inline unsigned int aq_ring_dx_in_range(unsigned int h, unsigned int i,
+					       unsigned int t)
+{
+	return (h < t) ? ((h < i) && (i < t)) : ((h < i) || (i < t));
+}
+
+void aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget)
+{
+	struct net_device *ndev = aq_nic_get_ndev(self->aq_nic);
+	bool is_rsc_completed = true;
+
+	for (; (self->sw_head != self->hw_head) && budget;
+		self->sw_head = aq_ring_next_dx(self, self->sw_head),
+		--budget, ++(*work_done)) {
+		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
+		struct sk_buff *skb = NULL;
+		unsigned int next_ = 0U;
+		unsigned int i = 0U;
+		struct aq_ring_buff_s *buff_ = NULL;
+
+		if (buff->is_error) {
+			__free_pages(buff->page, 0);
+			continue;
+		}
+
+		if (buff->is_cleaned)
+			continue;
+
+		++self->stats.rx_packets;
+		++ndev->stats.rx_packets;
+		ndev->stats.rx_bytes += buff->len;
+
+		if (!buff->is_eop) {
+			for (next_ = buff->next,
+			     buff_ = &self->buff_ring[next_]; true;
+			     next_ = buff_->next,
+			     buff_ = &self->buff_ring[next_]) {
+				is_rsc_completed =
+					aq_ring_dx_in_range(self->sw_head,
+							    next_,
+							    self->hw_head);
+
+				if (unlikely(!is_rsc_completed)) {
+					is_rsc_completed = false;
+					break;
+				}
+
+				if (buff_->is_eop)
+					break;
+			}
+
+			if (!is_rsc_completed)
+				return;
+		}
+
+		skb = netdev_alloc_skb(ndev, ETH_HLEN);
+		skb_put(skb, ETH_HLEN);
+		memcpy(skb->data, page_address(buff->page), ETH_HLEN);
+
+		skb_add_rx_frag(skb, 0, buff->page, ETH_HLEN,
+				buff->len - ETH_HLEN,
+				SKB_TRUESIZE(buff->len - ETH_HLEN));
+		if (!buff->is_eop) {
+			for (i = 1U, next_ = buff->next,
+			     buff_ = &self->buff_ring[next_]; true;
+			     next_ = buff_->next,
+			     buff_ = &self->buff_ring[next_], ++i) {
+				skb_add_rx_frag(skb, i, buff_->page, 0,
+						buff_->len,
+						SKB_TRUESIZE(buff->len -
+						ETH_HLEN));
+				buff_->is_cleaned = 1;
+
+				if (buff_->is_eop)
+					break;
+			}
+		}
+
+		skb->protocol = eth_type_trans(skb, ndev);
+		if (unlikely(buff->is_cso_err)) {
+			++self->stats.rx_errors;
+			__skb_mark_checksum_bad(skb);
+		} else {
+			if (buff->is_ip_cso) {
+				__skb_incr_checksum_unnecessary(skb);
+				if (buff->is_udp_cso || buff->is_tcp_cso)
+					__skb_incr_checksum_unnecessary(skb);
+			} else {
+				skb->ip_summed = CHECKSUM_NONE;
+			}
+		}
+
+		skb_set_hash(skb, buff->rss_hash,
+			     buff->is_hash_l4 ? PKT_HASH_TYPE_L4 :
+			     PKT_HASH_TYPE_NONE);
+
+		skb_record_rx_queue(skb, self->idx);
+
+		netif_receive_skb(skb);
+	}
+}
+
+void aq_ring_tx_drop(struct aq_ring_s *self)
+{
+	for (; self->sw_head != self->sw_tail;
+		self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
+		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
+		struct device *ndev = aq_nic_get_dev(self->aq_nic);
+
+		if (likely(buff->is_mapped)) {
+			if (unlikely(buff->is_sop))
+				dma_unmap_single(ndev, buff->pa, buff->len,
+						 DMA_TO_DEVICE);
+			else
+				dma_unmap_page(ndev, buff->pa, buff->len,
+					       DMA_TO_DEVICE);
+		}
+
+		if (unlikely(buff->is_eop))
+			dev_kfree_skb_any(buff->skb);
+	}
+}
+
+void aq_ring_rx_drop(struct aq_ring_s *self)
+{
+	for (; self->sw_head != self->sw_tail;
+		self->sw_head = aq_ring_next_dx(self, self->sw_head)) {
+		struct aq_ring_buff_s *buff = &self->buff_ring[self->sw_head];
+
+		dma_unmap_page(aq_nic_get_dev(self->aq_nic), buff->pa,
+			       AQ_CFG_RX_FRAME_MAX, DMA_FROM_DEVICE);
+
+		__free_pages(buff->page, 0);
+	}
+}
+
+int aq_ring_rx_fill(struct aq_ring_s *self)
+{
+	struct aq_ring_buff_s *buff = NULL;
+	int err = 0;
+	int i = 0;
+
+	for (i = aq_ring_avail_dx(self); i--;
+		self->sw_tail = aq_ring_next_dx(self, self->sw_tail)) {
+		buff = &self->buff_ring[self->sw_tail];
+
+		buff->flags = 0U;
+		buff->len = AQ_CFG_RX_FRAME_MAX;
+
+		buff->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
+					 __GFP_COMP, 0);
+		if (!buff->page) {
+			err = -ENOMEM;
+			goto err_exit;
+		}
+
+		buff->pa = dma_map_page(aq_nic_get_dev(self->aq_nic),
+					buff->page, 0,
+					AQ_CFG_RX_FRAME_MAX, DMA_FROM_DEVICE);
+
+		err = dma_mapping_error(aq_nic_get_dev(self->aq_nic), buff->pa);
+		if (err < 0)
+			goto err_exit;
+
+		buff = NULL;
+	}
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	if (err < 0)
+		if (buff && buff->page)
+			__free_pages(buff->page, 0);
+
+	return err;
+}
+
diff --git a/drivers/net/ethernet/aquantia/aq_ring.h b/drivers/net/ethernet/aquantia/aq_ring.h
new file mode 100644
index 0000000..3749c9b
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_ring.h
@@ -0,0 +1,147 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_ring.h: Declaration of functions for Rx/Tx rings. */
+
+#ifndef AQ_RING_H
+#define AQ_RING_H
+
+#include "aq_common.h"
+
+struct page;
+
+/*           TxC       SOP        DX         EOP
+ *         +----------+----------+----------+-----------
+ *   8bytes|len l3,l4 | pa       | pa       | pa
+ *         +----------+----------+----------+-----------
+ * 4/8bytes|len pkt   |len pkt   |          | skb
+ *         +----------+----------+----------+-----------
+ * 4/8bytes|is_txc    |len,flags |len       |len,is_eop
+ *         +----------+----------+----------+-----------
+ *
+ *  This aq_ring_buff_s doesn't have endianness dependency.
+ *  It is __packed for cache line optimizations.
+ */
+struct __packed aq_ring_buff_s {
+	union {
+		/* RX */
+		struct {
+			u32 rss_hash;
+			u16 next;
+			u8 is_hash_l4;
+			u8 rsvd1;
+			struct page *page;
+		};
+		/* EOP */
+		struct {
+			dma_addr_t pa_eop;
+			struct sk_buff *skb;
+		};
+		/* DX */
+		struct {
+			dma_addr_t pa;
+		};
+		/* SOP */
+		struct {
+			dma_addr_t pa_sop;
+			u32 len_pkt_sop;
+		};
+		/* TxC */
+		struct {
+			u32 mss;
+			u8 len_l2;
+			u8 len_l3;
+			u8 len_l4;
+			u8 rsvd2;
+			u32 len_pkt;
+		};
+	};
+	union {
+		struct {
+			u32 len:16;
+			u32 is_ip_cso:1;
+			u32 is_udp_cso:1;
+			u32 is_tcp_cso:1;
+			u32 is_cso_err:1;
+			u32 is_sop:1;
+			u32 is_eop:1;
+			u32 is_txc:1;
+			u32 is_mapped:1;
+			u32 is_cleaned:1;
+			u32 is_error:1;
+			u32 rsvd3:6;
+		};
+		u32 flags;
+	};
+};
+
+struct aq_ring_stats_s {
+	u64 rx_packets;
+	u64 tx_packets;
+	u64 lro_packets;
+	u64 jumbo_packets;
+	u64 rx_errors;
+};
+
+struct aq_ring_s {
+	AQ_OBJ_HEADER;
+	struct aq_ring_buff_s *buff_ring;
+	u8 *dx_ring;		/* descriptors ring, dma shared mem */
+	struct aq_nic_s *aq_nic;
+	unsigned int idx;	/* for HW layer registers operations */
+	unsigned int hw_head;
+	unsigned int sw_head;
+	unsigned int sw_tail;
+	unsigned int size;	/* descriptors number */
+	unsigned int dx_size;	/* TX or RX descriptor size,  */
+				/* stored here for fater math */
+	struct aq_ring_stats_s stats;
+	dma_addr_t dx_ring_pa;
+};
+
+struct aq_ring_param_s {
+	unsigned int vec_idx;
+	unsigned int cpu;
+	cpumask_t affinity_mask;
+};
+
+static inline unsigned int aq_ring_next_dx(struct aq_ring_s *self,
+					   unsigned int dx)
+{
+	return (++dx >= self->size) ? 0U : dx;
+}
+
+static inline unsigned int aq_ring_avail_dx(struct aq_ring_s *self)
+{
+	return (((self->sw_tail >= self->sw_head)) ?
+		(self->size - 1) - self->sw_tail + self->sw_head :
+		self->sw_head - self->sw_tail - 1);
+}
+
+struct aq_ring_s *aq_ring_tx_alloc(struct aq_ring_s *self,
+				   struct aq_nic_s *aq_nic,
+				   unsigned int idx,
+				   struct aq_nic_cfg_s *aq_nic_cfg);
+struct aq_ring_s *aq_ring_rx_alloc(struct aq_ring_s *self,
+				   struct aq_nic_s *aq_nic,
+				   unsigned int idx,
+				   struct aq_nic_cfg_s *aq_nic_cfg);
+void aq_ring_init(struct aq_ring_s *self);
+void aq_ring_free(struct aq_ring_s *self);
+void aq_ring_tx_append_buffs(struct aq_ring_s *ring,
+			     struct aq_ring_buff_s *buffer,
+			     unsigned int buffers);
+void aq_ring_tx_clean(struct aq_ring_s *self);
+void aq_ring_rx_clean(struct aq_ring_s *self, int *work_done, int budget);
+void aq_ring_tx_drop(struct aq_ring_s *self);
+void aq_ring_rx_drop(struct aq_ring_s *self);
+int aq_ring_rx_fill(struct aq_ring_s *self);
+
+#endif /* AQ_RING_H */
+
-- 
2.7.4
