From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Wed, 12 Mar 2008 01:23:23 +0000
Message-ID: <20080312012322.GD24160@solarflare.com>
References: <20080312012102.GB24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54836 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752710AbYCLCW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 22:22:56 -0400
Content-Disposition: inline
In-Reply-To: <20080312012102.GB24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
new file mode 100644
index 0000000..cf74b5f
--- /dev/null
+++ b/drivers/net/sfc/rx.c
@@ -0,0 +1,875 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <net/ip.h>
+#include <net/checksum.h>
+#include "net_driver.h"
+#include "rx.h"
+#include "efx.h"
+#include "falcon.h"
+#include "workarounds.h"
+
+/* Number of RX descriptors pushed at once. */
+#define EFX_RX_BATCH  8
+
+/* Size of buffer allocated for skb header area. */
+#define EFX_SKB_HEADERS  64u
+
+/*
+ * rx_alloc_method - RX buffer allocation method
+ *
+ * This driver supports two methods for allocating and using RX buffers:
+ * each RX buffer may be backed by an skb or by an order-n page.
+ *
+ * When LRO is in use then the second method has a lower overhead,
+ * since we don't have to allocate then free skbs on reassembled frames.
+ *
+ * Values:
+ *   - RX_ALLOC_METHOD_AUTO = 0
+ *   - RX_ALLOC_METHOD_SKB  = 1
+ *   - RX_ALLOC_METHOD_PAGE = 2
+ *
+ * The heuristic for %RX_ALLOC_METHOD_AUTO is a simple hysteresis count
+ * controlled by the parameters below.
+ *
+ *   - Since pushing and popping descriptors are separated by the rx_queue
+ *     size, so the watermarks should be ~rxd_size.
+ *   - The performance win by using page-based allocation for LRO is less
+ *     than the performance hit of using page-based allocation of non-LRO,
+ *     so the watermarks should reflect this.
+ *
+ * Per channel we maintain a single variable, updated by each channel:
+ *
+ *   rx_alloc_level += (lro_performed ? RX_ALLOC_FACTOR_LRO :
+ *                      RX_ALLOC_FACTOR_SKB)
+ * Per NAPI poll interval, we constrain rx_alloc_level to 0..MAX (which
+ * limits the hysteresis), and update the allocation strategy:
+ *
+ *   rx_alloc_method = (rx_alloc_level > RX_ALLOC_LEVEL_LRO ?
+ *                      RX_ALLOC_METHOD_PAGE : RX_ALLOC_METHOD_SKB)
+ */
+static int rx_alloc_method = RX_ALLOC_METHOD_PAGE;
+
+#define RX_ALLOC_LEVEL_LRO 0x2000
+#define RX_ALLOC_LEVEL_MAX 0x3000
+#define RX_ALLOC_FACTOR_LRO 1
+#define RX_ALLOC_FACTOR_SKB -2
+
+/* This is the percentage fill level below which new RX descriptors
+ * will be added to the RX descriptor ring.
+ */
+static unsigned int rx_refill_threshold = 90;
+
+/* This is the percentage fill level to which an RX queue will be refilled
+ * when the "RX refill threshold" is reached.
+ */
+static unsigned int rx_refill_limit = 95;
+
+/*
+ * RX maximum head room required.
+ *
+ * This must be at least 1 to prevent overflow and at least 2 to allow
+ * pipelined receives.
+ */
+#define EFX_RXD_HEAD_ROOM 2
+
+/* Macros for zero-order pages (potentially) containing multiple RX buffers */
+#define RX_DATA_OFFSET(_data)				\
+	(((unsigned long) (_data)) & (PAGE_SIZE-1))
+#define RX_BUF_OFFSET(_rx_buf)				\
+	RX_DATA_OFFSET((_rx_buf)->data)
+
+#define RX_PAGE_SIZE(_efx)				\
+	(PAGE_SIZE * (1u << (_efx)->rx_buffer_order))
+
+
+/**************************************************************************
+ *
+ * Linux generic LRO handling
+ *
+ **************************************************************************
+ */
+
+static int efx_lro_get_skb_hdr(struct sk_buff *skb, void **ip_hdr,
+			       void **tcpudp_hdr, u64 *hdr_flags, void *priv)
+{
+	struct efx_channel *channel = (struct efx_channel *)priv;
+	struct iphdr *iph;
+	struct tcphdr *th;
+
+	iph = (struct iphdr *)skb->data;
+	if (skb->protocol != htons(ETH_P_IP) || iph->protocol != IPPROTO_TCP)
+		goto fail;
+
+	th = (struct tcphdr *)(skb->data + iph->ihl * 4);
+
+	*tcpudp_hdr = th;
+	*ip_hdr = iph;
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+
+	channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
+	return 0;
+fail:
+	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
+	return -1;
+}
+
+static int efx_get_frag_hdr(struct skb_frag_struct *frag, void **mac_hdr,
+			    void **ip_hdr, void **tcpudp_hdr, u64 *hdr_flags,
+			    void *priv)
+{
+	struct efx_channel *channel = (struct efx_channel *)priv;
+	struct ethhdr *eh;
+	struct iphdr *iph;
+
+	/* We support EtherII and VLAN encapsulated IPv4 */
+	eh = (struct ethhdr *)(page_address(frag->page) + frag->page_offset);
+	*mac_hdr = eh;
+
+	if (eh->h_proto == htons(ETH_P_IP)) {
+		iph = (struct iphdr *)(eh + 1);
+	} else {
+		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)eh;
+		if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
+			goto fail;
+
+		iph = (struct iphdr *)(veh + 1);
+	}
+	*ip_hdr = iph;
+
+	/* We can only do LRO over TCP */
+	if (iph->protocol != IPPROTO_TCP)
+		goto fail;
+
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+	*tcpudp_hdr = (struct tcphdr *)((u8 *) iph + iph->ihl * 4);
+
+	channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
+	return 0;
+ fail:
+	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
+	return -1;
+}
+
+int efx_lro_init(struct net_lro_mgr *lro_mgr, struct efx_nic *efx)
+{
+	size_t s = sizeof(struct net_lro_desc) * EFX_MAX_LRO_DESCRIPTORS;
+	struct net_lro_desc *lro_arr;
+
+	/* Allocate the LRO descriptors structure */
+	lro_arr = kzalloc(s, GFP_KERNEL);
+	if (lro_arr == NULL)
+		return -ENOMEM;
+
+	lro_mgr->lro_arr = lro_arr;
+	lro_mgr->max_desc = EFX_MAX_LRO_DESCRIPTORS;
+	lro_mgr->max_aggr = EFX_MAX_LRO_AGGR;
+	lro_mgr->frag_align_pad = EFX_PAGE_SKB_ALIGN;
+
+	lro_mgr->get_skb_header = efx_lro_get_skb_hdr;
+	lro_mgr->get_frag_header = efx_get_frag_hdr;
+	lro_mgr->dev = efx->net_dev;
+
+	lro_mgr->features = LRO_F_NAPI;
+
+	/* We can pass packets up with the checksum intact */
+	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
+
+	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+
+	return 0;
+}
+
+void efx_lro_fini(struct net_lro_mgr *lro_mgr)
+{
+	kfree(lro_mgr->lro_arr);
+	lro_mgr->lro_arr = NULL;
+}
+
+/**
+ * efx_init_rx_buffer_skb - create new RX buffer using skb-based allocation
+ *
+ * @rx_queue:		Efx RX queue
+ * @rx_buf:		RX buffer structure to populate
+ *
+ * This allocates memory for a new receive buffer, maps it for DMA,
+ * and populates a struct efx_rx_buffer with the relevant
+ * information.  Return a negative error code or 0 on success.
+ */
+static inline int efx_init_rx_buffer_skb(struct efx_rx_queue *rx_queue,
+					 struct efx_rx_buffer *rx_buf)
+{
+	struct efx_nic *efx = rx_queue->efx;
+	struct net_device *net_dev = efx->net_dev;
+	int skb_len = efx->rx_buffer_len;
+
+	rx_buf->skb = netdev_alloc_skb(net_dev, skb_len);
+	if (unlikely(!rx_buf->skb))
+		return -ENOMEM;
+
+	/* Adjust the SKB for padding and checksum */
+	skb_reserve(rx_buf->skb, NET_IP_ALIGN);
+	rx_buf->len = skb_len - NET_IP_ALIGN;
+	rx_buf->data = (char *)rx_buf->skb->data;
+	rx_buf->skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	rx_buf->dma_addr = pci_map_single(efx->pci_dev,
+					  rx_buf->data, rx_buf->len,
+					  PCI_DMA_FROMDEVICE);
+
+	if (unlikely(pci_dma_mapping_error(rx_buf->dma_addr))) {
+		dev_kfree_skb_any(rx_buf->skb);
+		rx_buf->skb = NULL;
+		return -EIO;
+	}
+
+	return 0;
+}
+
+/**
+ * efx_init_rx_buffer_page - create new RX buffer using page-based allocation
+ *
+ * @rx_queue:		Efx RX queue
+ * @rx_buf:		RX buffer structure to populate
+ *
+ * This allocates memory for a new receive buffer, maps it for DMA,
+ * and populates a struct efx_rx_buffer with the relevant
+ * information.  Return a negative error code or 0 on success.
+ */
+static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
+					  struct efx_rx_buffer *rx_buf)
+{
+	struct efx_nic *efx = rx_queue->efx;
+	int bytes, space, offset;
+
+	bytes = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
+
+	/* If there is space left in the previously allocated page,
+	 * then use it. Otherwise allocate a new one */
+	rx_buf->page = rx_queue->buf_page;
+	if (rx_buf->page == NULL) {
+		dma_addr_t dma_addr;
+
+		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
+					   efx->rx_buffer_order);
+		if (unlikely(rx_buf->page == NULL))
+			return -ENOMEM;
+
+		dma_addr = pci_map_page(efx->pci_dev, rx_buf->page,
+					0, RX_PAGE_SIZE(efx),
+					PCI_DMA_FROMDEVICE);
+
+		if (unlikely(pci_dma_mapping_error(dma_addr))) {
+			__free_pages(rx_buf->page, efx->rx_buffer_order);
+			rx_buf->page = NULL;
+			return -EIO;
+		}
+
+		rx_queue->buf_page = rx_buf->page;
+		rx_queue->buf_dma_addr = dma_addr;
+		rx_queue->buf_data = ((char *) page_address(rx_buf->page) +
+				      EFX_PAGE_IP_ALIGN);
+	}
+
+	offset = RX_DATA_OFFSET(rx_queue->buf_data);
+	rx_buf->len = bytes;
+	rx_buf->dma_addr = rx_queue->buf_dma_addr + offset;
+	rx_buf->data = rx_queue->buf_data;
+
+	/* Try to pack multiple buffers per page */
+	if (efx->rx_buffer_order == 0) {
+		/* The next buffer starts on the next 512 byte boundary */
+		rx_queue->buf_data += ((bytes + 0x1ff) & ~0x1ff);
+		offset += ((bytes + 0x1ff) & ~0x1ff);
+
+		space = RX_PAGE_SIZE(efx) - offset;
+		if (space >= bytes) {
+			/* Refs dropped on kernel releasing each skb */
+			get_page(rx_queue->buf_page);
+			goto out;
+		}
+	}
+
+	/* This is the final RX buffer for this page, so mark it for
+	 * unmapping */
+	rx_queue->buf_page = NULL;
+	rx_buf->unmap_addr = rx_queue->buf_dma_addr;
+
+ out:
+	return 0;
+}
+
+/* This allocates memory for a new receive buffer, maps it for DMA,
+ * and populates a struct efx_rx_buffer with the relevant
+ * information.
+ */
+static inline int efx_init_rx_buffer(struct efx_rx_queue *rx_queue,
+				     struct efx_rx_buffer *new_rx_buf)
+{
+	int rc = 0;
+
+	if (rx_queue->channel->rx_alloc_push_pages) {
+		new_rx_buf->skb = NULL;
+		rc = efx_init_rx_buffer_page(rx_queue, new_rx_buf);
+		rx_queue->alloc_page_count++;
+	} else {
+		new_rx_buf->page = NULL;
+		rc = efx_init_rx_buffer_skb(rx_queue, new_rx_buf);
+		rx_queue->alloc_skb_count++;
+	}
+
+	if (unlikely(rc < 0))
+		EFX_LOG_RL(rx_queue->efx, "%s RXQ[%d] =%d\n", __func__,
+			   rx_queue->queue, rc);
+	return rc;
+}
+
+static inline void efx_unmap_rx_buffer(struct efx_nic *efx,
+				       struct efx_rx_buffer *rx_buf)
+{
+	if (rx_buf->page) {
+		EFX_BUG_ON_PARANOID(rx_buf->skb);
+		if (rx_buf->unmap_addr) {
+			pci_unmap_page(efx->pci_dev, rx_buf->unmap_addr,
+				       RX_PAGE_SIZE(efx), PCI_DMA_FROMDEVICE);
+			rx_buf->unmap_addr = 0;
+		}
+	} else if (likely(rx_buf->skb)) {
+		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
+				 rx_buf->len, PCI_DMA_FROMDEVICE);
+	}
+}
+
+static inline void efx_free_rx_buffer(struct efx_nic *efx,
+				      struct efx_rx_buffer *rx_buf)
+{
+	if (rx_buf->page) {
+		__free_pages(rx_buf->page, efx->rx_buffer_order);
+		rx_buf->page = NULL;
+	} else if (likely(rx_buf->skb)) {
+		dev_kfree_skb_any(rx_buf->skb);
+		rx_buf->skb = NULL;
+	}
+}
+
+static inline void efx_fini_rx_buffer(struct efx_rx_queue *rx_queue,
+				      struct efx_rx_buffer *rx_buf)
+{
+	efx_unmap_rx_buffer(rx_queue->efx, rx_buf);
+	efx_free_rx_buffer(rx_queue->efx, rx_buf);
+}
+
+/**
+ * efx_fast_push_rx_descriptors - push new RX descriptors quickly
+ * @rx_queue:		RX descriptor queue
+ * @retry:              Recheck the fill level
+ * This will aim to fill the RX descriptor queue up to
+ * @rx_queue->@fast_fill_limit. If there is insufficient atomic
+ * memory to do so, the caller should retry.
+ */
+static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
+					  int retry)
+{
+	struct efx_rx_buffer *rx_buf;
+	unsigned fill_level, index;
+	int i, space, rc = 0;
+
+	/* Calculate current fill level.  Do this outside the lock,
+	 * because most of the time we'll end up not wanting to do the
+	 * fill anyway.
+	 */
+	fill_level = (rx_queue->added_count - rx_queue->removed_count);
+	EFX_BUG_ON_PARANOID(fill_level >
+			    rx_queue->efx->type->rxd_ring_mask + 1);
+
+	/* Don't fill if we don't need to */
+	if (fill_level >= rx_queue->fast_fill_trigger)
+		return 0;
+
+	/* Record minimum fill level */
+	if (unlikely(fill_level < rx_queue->min_fill))
+		if (fill_level)
+			rx_queue->min_fill = fill_level;
+
+	/* Acquire RX add lock.  If this lock is contended, then a fast
+	 * fill must already be in progress (e.g. in the refill
+	 * tasklet), so we don't need to do anything
+	 */
+	if (!spin_trylock_bh(&rx_queue->add_lock))
+		return -1;
+
+ retry:
+	/* Recalculate current fill level now that we have the lock */
+	fill_level = (rx_queue->added_count - rx_queue->removed_count);
+	EFX_BUG_ON_PARANOID(fill_level >
+			    rx_queue->efx->type->rxd_ring_mask + 1);
+	space = rx_queue->fast_fill_limit - fill_level;
+	if (space < EFX_RX_BATCH)
+		goto out_unlock;
+
+	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filling descriptor ring from"
+		  " level %d to level %d using %s allocation\n",
+		  rx_queue->queue, fill_level, rx_queue->fast_fill_limit,
+		  rx_queue->channel->rx_alloc_push_pages ? "page" : "skb");
+
+	do {
+		for (i = 0; i < EFX_RX_BATCH; ++i) {
+			index = (rx_queue->added_count &
+				 rx_queue->efx->type->rxd_ring_mask);
+			rx_buf = efx_rx_buffer(rx_queue, index);
+			rc = efx_init_rx_buffer(rx_queue, rx_buf);
+			if (unlikely(rc))
+				goto out;
+			++rx_queue->added_count;
+		}
+	} while ((space -= EFX_RX_BATCH) >= EFX_RX_BATCH);
+
+	EFX_TRACE(rx_queue->efx, "RX queue %d fast-filled descriptor ring "
+		  "to level %d\n", rx_queue->queue,
+		  rx_queue->added_count - rx_queue->removed_count);
+
+ out:
+	/* Send write pointer to card. */
+	falcon_notify_rx_desc(rx_queue);
+
+	/* If the fast fill is running inside from the refill tasklet, then
+	 * for SMP systems it may be running on a different CPU to
+	 * RX event processing, which means that the fill level may now be
+	 * out of date. */
+	if (unlikely(retry && (rc == 0)))
+		goto retry;
+
+ out_unlock:
+	spin_unlock_bh(&rx_queue->add_lock);
+
+	return rc;
+}
+
+/**
+ * efx_fast_push_rx_descriptors - push new RX descriptors quickly
+ * @rx_queue:		RX descriptor queue
+ *
+ * This will aim to fill the RX descriptor queue up to
+ * @rx_queue->@fast_fill_limit.  If there is insufficient memory to do so,
+ * it will schedule a work item to immediately continue the fast fill
+ */
+void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
+{
+	int rc;
+
+	rc = __efx_fast_push_rx_descriptors(rx_queue, 0);
+	if (unlikely(rc)) {
+		/* Schedule the work item to run immediately. The hope is
+		 * that work is immediately pending to free some memory
+		 * (e.g. an RX event or TX completion)
+		 */
+		efx_schedule_slow_fill(rx_queue, 0);
+	}
+}
+
+void efx_rx_work(struct work_struct *data)
+{
+	struct efx_rx_queue *rx_queue;
+	int rc;
+
+	rx_queue = container_of(data, struct efx_rx_queue, work.work);
+
+	if (unlikely(!rx_queue->channel->enabled))
+		return;
+
+	EFX_TRACE(rx_queue->efx, "RX queue %d worker thread executing on CPU "
+		  "%d\n", rx_queue->queue, raw_smp_processor_id());
+
+	++rx_queue->slow_fill_count;
+	/* Push new RX descriptors, allowing at least 1 jiffy for
+	 * the kernel to free some more memory. */
+	rc = __efx_fast_push_rx_descriptors(rx_queue, 1);
+	if (rc)
+		efx_schedule_slow_fill(rx_queue, 1);
+}
+
+static inline void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
+					    struct efx_rx_buffer *rx_buf,
+					    int len, int *discard,
+					    int *leak_packet)
+{
+	struct efx_nic *efx = rx_queue->efx;
+	unsigned max_len = rx_buf->len - efx->type->rx_buffer_padding;
+
+	if (likely(len <= max_len))
+		return;
+
+	/* The packet must be discarded, but this is only a fatal error
+	 * if the caller indicated it was
+	 */
+	*discard = 1;
+
+	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
+		EFX_ERR_RL(efx, " RX queue %d seriously overlength "
+			   "RX event (0x%x > 0x%x+0x%x). Leaking\n",
+			   rx_queue->queue, len, max_len,
+			   efx->type->rx_buffer_padding);
+		/* If this buffer was skb-allocated, then the meta
+		 * data at the end of the skb will be trashed. So
+		 * we have no choice but to leak the fragment.
+		 */
+		*leak_packet = (rx_buf->skb != NULL);
+		efx_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
+	} else {
+		EFX_ERR_RL(efx, " RX queue %d overlength RX event "
+			   "(0x%x > 0x%x)\n", rx_queue->queue, len, max_len);
+	}
+
+	rx_queue->channel->n_rx_overlength++;
+}
+
+/* Pass a received packet up through the generic LRO stack
+ *
+ * Handles driverlink veto, and passes the fragment up via
+ * the appropriate LRO method
+ */
+static inline void efx_rx_packet_lro(struct efx_channel *channel,
+				     struct efx_rx_buffer *rx_buf)
+{
+	struct net_lro_mgr *lro_mgr = &channel->lro_mgr;
+	void *priv = channel;
+
+	/* Pass the skb/page into the LRO engine */
+	if (rx_buf->page) {
+		struct skb_frag_struct frags;
+
+		frags.page = rx_buf->page;
+		frags.page_offset = RX_BUF_OFFSET(rx_buf);
+		frags.size = rx_buf->len;
+
+		lro_receive_frags(lro_mgr, &frags, rx_buf->len,
+				  rx_buf->len, priv, 0);
+
+		EFX_BUG_ON_PARANOID(rx_buf->skb);
+		rx_buf->page = NULL;
+	} else {
+		EFX_BUG_ON_PARANOID(!rx_buf->skb);
+
+		lro_receive_skb(lro_mgr, rx_buf->skb, priv);
+		rx_buf->skb = NULL;
+	}
+}
+
+/* Allocate and construct an SKB around a struct page.*/
+static inline struct sk_buff *efx_rx_mk_skb(struct efx_rx_buffer *rx_buf,
+					    struct efx_nic *efx,
+					    int hdr_len)
+{
+	struct sk_buff *skb;
+
+	/* Allocate an SKB to store the headers */
+	skb = netdev_alloc_skb(efx->net_dev, hdr_len + EFX_PAGE_SKB_ALIGN);
+	if (unlikely(skb == NULL)) {
+		EFX_ERR_RL(efx, "RX out of memory for skb\n");
+		return NULL;
+	}
+
+	EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags);
+	EFX_BUG_ON_PARANOID(rx_buf->len < hdr_len);
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb_reserve(skb, EFX_PAGE_SKB_ALIGN);
+
+	skb->len = rx_buf->len;
+	skb->truesize = rx_buf->len + sizeof(struct sk_buff);
+	memcpy(skb->data, rx_buf->data, hdr_len);
+	skb->tail += hdr_len;
+
+	/* Append the remaining page onto the frag list */
+	if (unlikely(rx_buf->len > hdr_len)) {
+		struct skb_frag_struct *frag = skb_shinfo(skb)->frags;
+		frag->page = rx_buf->page;
+		frag->page_offset = RX_BUF_OFFSET(rx_buf) + hdr_len;
+		frag->size = skb->len - hdr_len;
+		skb_shinfo(skb)->nr_frags = 1;
+		skb->data_len = frag->size;
+	} else {
+		__free_pages(rx_buf->page, efx->rx_buffer_order);
+		skb->data_len = 0;
+	}
+
+	/* Ownership has transferred from the rx_buf to skb */
+	rx_buf->page = NULL;
+
+	/* Move past the ethernet header */
+	skb->protocol = eth_type_trans(skb, efx->net_dev);
+
+	return skb;
+}
+
+void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
+		   unsigned int len, int checksummed, int discard)
+{
+	struct efx_nic *efx = rx_queue->efx;
+	struct efx_rx_buffer *rx_buf;
+	int leak_packet = 0;
+
+	rx_buf = efx_rx_buffer(rx_queue, index);
+	EFX_BUG_ON_PARANOID(!rx_buf->data);
+	EFX_BUG_ON_PARANOID(rx_buf->skb && rx_buf->page);
+	EFX_BUG_ON_PARANOID(!(rx_buf->skb || rx_buf->page));
+
+	/* This allows the refill path to post another buffer.
+	 * EFX_RXD_HEAD_ROOM ensures that the slot we are using
+	 * isn't overwritten yet.
+	 */
+	rx_queue->removed_count++;
+
+	/* Validate the length encoded in the event vs the descriptor pushed */
+	efx_rx_packet__check_len(rx_queue, rx_buf, len,
+				 &discard, &leak_packet);
+
+	EFX_TRACE(efx, "RX queue %d received id %x at %llx+%x %s%s\n",
+		  rx_queue->queue, index,
+		  (unsigned long long)rx_buf->dma_addr, len,
+		  (checksummed ? " [SUMMED]" : ""),
+		  (discard ? " [DISCARD]" : ""));
+
+	/* Discard packet, if instructed to do so */
+	if (unlikely(discard)) {
+		if (unlikely(leak_packet))
+			rx_queue->channel->n_skbuff_leaks++;
+		else
+			/* We haven't called efx_unmap_rx_buffer yet,
+			 * so fini the entire rx_buffer here */
+			efx_fini_rx_buffer(rx_queue, rx_buf);
+		return;
+	}
+
+	/* Release card resources - assumes all RX buffers consumed in-order
+	 * per RX queue
+	 */
+	efx_unmap_rx_buffer(efx, rx_buf);
+
+	/* Prefetch nice and early so data will (hopefully) be in cache by
+	 * the time we look at it.
+	 */
+	prefetch(rx_buf->data);
+
+	/* Pipeline receives so that we give time for packet headers to be
+	 * prefetched into cache.
+	 */
+	rx_buf->len = len;
+	if (rx_queue->channel->rx_pkt)
+		__efx_rx_packet(rx_queue->channel,
+				rx_queue->channel->rx_pkt,
+				rx_queue->channel->rx_pkt_csummed);
+	rx_queue->channel->rx_pkt = rx_buf;
+	rx_queue->channel->rx_pkt_csummed = checksummed;
+}
+
+/* Handle a received packet.  Second half: Touches packet payload. */
+void __efx_rx_packet(struct efx_channel *channel,
+		     struct efx_rx_buffer *rx_buf, int checksummed)
+{
+	struct efx_nic *efx = channel->efx;
+	struct sk_buff *skb;
+	int lro = efx->net_dev->features & NETIF_F_LRO;
+
+	if (rx_buf->skb) {
+		prefetch(skb_shinfo(rx_buf->skb));
+
+		skb_put(rx_buf->skb, rx_buf->len);
+
+		/* Move past the ethernet header. rx_buf->data still points
+		 * at the ethernet header */
+		rx_buf->skb->protocol = eth_type_trans(rx_buf->skb,
+						       efx->net_dev);
+	}
+
+	/* Both our generic-LRO and SFC-SSR support skb and page based
+	 * allocation, but neither support switching from one to the
+	 * other on the fly. If we spot that the allocation mode has
+	 * changed, then flush the LRO state.
+	 */
+	if (unlikely(channel->rx_alloc_pop_pages != (rx_buf->page != NULL))) {
+		efx_flush_lro(channel);
+		channel->rx_alloc_pop_pages = (rx_buf->page != NULL);
+	}
+	if (likely(checksummed && lro)) {
+		efx_rx_packet_lro(channel, rx_buf);
+		goto done;
+	}
+
+	/* Form an skb if required */
+	if (rx_buf->page) {
+		int hdr_len = min(rx_buf->len, EFX_SKB_HEADERS);
+		skb = efx_rx_mk_skb(rx_buf, efx, hdr_len);
+		if (unlikely(skb == NULL)) {
+			efx_free_rx_buffer(efx, rx_buf);
+			goto done;
+		}
+	} else {
+		/* We now own the SKB */
+		skb = rx_buf->skb;
+		rx_buf->skb = NULL;
+	}
+
+	EFX_BUG_ON_PARANOID(rx_buf->page);
+	EFX_BUG_ON_PARANOID(rx_buf->skb);
+	EFX_BUG_ON_PARANOID(!skb);
+
+	/* Set the SKB flags */
+	if (unlikely(!checksummed || !efx->rx_checksum_enabled))
+		skb->ip_summed = CHECKSUM_NONE;
+
+	/* Pass the packet up */
+	netif_receive_skb(skb);
+
+	/* Update allocation strategy method */
+	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
+
+	/* fall-thru */
+done:
+	efx->net_dev->last_rx = jiffies;
+}
+
+void efx_rx_strategy(struct efx_channel *channel)
+{
+	enum efx_rx_alloc_method method = rx_alloc_method;
+
+	/* Only makes sense to use page based allocation if LRO is enabled */
+	if (!(channel->efx->net_dev->features & NETIF_F_LRO)) {
+		method = RX_ALLOC_METHOD_SKB;
+	} else if (method == RX_ALLOC_METHOD_AUTO) {
+		/* Constrain the rx_alloc_level */
+		if (channel->rx_alloc_level < 0)
+			channel->rx_alloc_level = 0;
+		else if (channel->rx_alloc_level > RX_ALLOC_LEVEL_MAX)
+			channel->rx_alloc_level = RX_ALLOC_LEVEL_MAX;
+
+		/* Decide on the allocation method */
+		method = ((channel->rx_alloc_level > RX_ALLOC_LEVEL_LRO) ?
+			  RX_ALLOC_METHOD_PAGE : RX_ALLOC_METHOD_SKB);
+	}
+
+	/* Push the option */
+	channel->rx_alloc_push_pages = (method == RX_ALLOC_METHOD_PAGE);
+}
+
+int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
+{
+	struct efx_nic *efx = rx_queue->efx;
+	unsigned int rxq_size;
+	int rc;
+
+	EFX_LOG(efx, "creating RX queue %d\n", rx_queue->queue);
+
+	/* Allocate RX buffers */
+	rxq_size = (efx->type->rxd_ring_mask + 1) * sizeof(*rx_queue->buffer);
+	rx_queue->buffer = kzalloc(rxq_size, GFP_KERNEL);
+	if (!rx_queue->buffer) {
+		rc = -ENOMEM;
+		goto fail1;
+	}
+
+	rc = falcon_probe_rx(rx_queue);
+	if (rc)
+		goto fail2;
+
+	return 0;
+
+ fail2:
+	kfree(rx_queue->buffer);
+	rx_queue->buffer = NULL;
+ fail1:
+	rx_queue->used = 0;
+
+	return rc;
+}
+
+int efx_init_rx_queue(struct efx_rx_queue *rx_queue)
+{
+	struct efx_nic *efx = rx_queue->efx;
+	unsigned int max_fill, trigger, limit;
+
+	EFX_LOG(rx_queue->efx, "initialising RX queue %d\n", rx_queue->queue);
+
+	/* Initialise ptr fields */
+	rx_queue->added_count = 0;
+	rx_queue->notified_count = 0;
+	rx_queue->removed_count = 0;
+	rx_queue->min_fill = -1U;
+	rx_queue->min_overfill = -1U;
+
+	/* Initialise limit fields */
+	max_fill = efx->type->rxd_ring_mask + 1 - EFX_RXD_HEAD_ROOM;
+	trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
+	limit = max_fill * min(rx_refill_limit, 100U) / 100U;
+
+	rx_queue->max_fill = max_fill;
+	rx_queue->fast_fill_trigger = trigger;
+	rx_queue->fast_fill_limit = limit;
+
+	/* Set up RX descriptor ring */
+	return falcon_init_rx(rx_queue);
+}
+
+void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
+{
+	int i;
+	struct efx_rx_buffer *rx_buf;
+
+	EFX_LOG(rx_queue->efx, "shutting down RX queue %d\n", rx_queue->queue);
+
+	falcon_fini_rx(rx_queue);
+
+	/* Release RX buffers NB start at index 0 not current HW ptr */
+	if (rx_queue->buffer) {
+		for (i = 0; i <= rx_queue->efx->type->rxd_ring_mask; i++) {
+			rx_buf = efx_rx_buffer(rx_queue, i);
+			efx_fini_rx_buffer(rx_queue, rx_buf);
+		}
+	}
+
+	/* For a page that is part-way through splitting into RX buffers */
+	if (rx_queue->buf_page != NULL) {
+		pci_unmap_page(rx_queue->efx->pci_dev, rx_queue->buf_dma_addr,
+			       RX_PAGE_SIZE(rx_queue->efx), PCI_DMA_FROMDEVICE);
+		__free_pages(rx_queue->buf_page,
+			     rx_queue->efx->rx_buffer_order);
+		rx_queue->buf_page = NULL;
+	}
+}
+
+void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
+{
+	EFX_LOG(rx_queue->efx, "destroying RX queue %d\n", rx_queue->queue);
+
+	falcon_remove_rx(rx_queue);
+
+	kfree(rx_queue->buffer);
+	rx_queue->buffer = NULL;
+	rx_queue->used = 0;
+}
+
+void efx_flush_lro(struct efx_channel *channel)
+{
+	lro_flush_all(&channel->lro_mgr);
+}
+
+
+module_param(rx_alloc_method, int, 0644);
+MODULE_PARM_DESC(rx_alloc_method, "Allocation method used for RX buffers");
+
+module_param(rx_refill_threshold, uint, 0444);
+MODULE_PARM_DESC(rx_refill_threshold,
+		 "RX descriptor ring fast/slow fill threshold (%)");
+
diff --git a/drivers/net/sfc/rx.h b/drivers/net/sfc/rx.h
new file mode 100644
index 0000000..f35e377
--- /dev/null
+++ b/drivers/net/sfc/rx.h
@@ -0,0 +1,29 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_RX_H
+#define EFX_RX_H
+
+#include "net_driver.h"
+
+int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
+void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
+int efx_init_rx_queue(struct efx_rx_queue *rx_queue);
+void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
+
+int efx_lro_init(struct net_lro_mgr *lro_mgr, struct efx_nic *efx);
+void efx_lro_fini(struct net_lro_mgr *lro_mgr);
+void efx_flush_lro(struct efx_channel *channel);
+void efx_rx_strategy(struct efx_channel *channel);
+void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
+void efx_rx_work(struct work_struct *data);
+void __efx_rx_packet(struct efx_channel *channel,
+		     struct efx_rx_buffer *rx_buf, int checksummed);
+
+#endif /* EFX_RX_H */
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
new file mode 100644
index 0000000..7dc70a2
--- /dev/null
+++ b/drivers/net/sfc/tx.c
@@ -0,0 +1,465 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/pci.h>
+#include <linux/tcp.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/if_ether.h>
+#include <linux/highmem.h>
+#include "net_driver.h"
+#include "tx.h"
+#include "efx.h"
+#include "falcon.h"
+#include "workarounds.h"
+
+/*
+ * TX descriptor ring full threshold
+ *
+ * The tx_queue descriptor ring fill-level must fall below this value
+ * before we restart the netif queue
+ */
+#define EFX_NETDEV_TX_THRESHOLD(_tx_queue)	\
+	(_tx_queue->efx->type->txd_ring_mask / 2u)
+
+/* We want to be able to nest calls to netif_stop_queue(), since each
+ * channel can have an individual stop on the queue.
+ */
+void efx_stop_queue(struct efx_nic *efx)
+{
+	spin_lock_bh(&efx->netif_stop_lock);
+	EFX_TRACE(efx, "stop TX queue\n");
+
+	atomic_inc(&efx->netif_stop_count);
+	if (likely(efx->net_dev_registered))
+		netif_stop_queue(efx->net_dev);
+
+	spin_unlock_bh(&efx->netif_stop_lock);
+}
+
+/* Wake netif's TX queue
+ * We want to be able to nest calls to netif_stop_queue(), since each
+ * channel can have an individual stop on the queue.
+ */
+inline void efx_wake_queue(struct efx_nic *efx)
+{
+	local_bh_disable();
+	if (atomic_dec_and_lock(&efx->netif_stop_count,
+				&efx->netif_stop_lock)) {
+		EFX_TRACE(efx, "waking TX queue\n");
+		if (likely(efx->net_dev_registered))
+			netif_wake_queue(efx->net_dev);
+		spin_unlock(&efx->netif_stop_lock);
+	}
+	local_bh_enable();
+}
+
+/*
+ * Add a socket buffer to a TX queue
+ *
+ * This maps all fragments of a socket buffer for DMA and adds them to
+ * the TX queue.  The queue's insert pointer will be incremented by
+ * the number of fragments in the socket buffer.
+ *
+ * If any DMA mapping fails, any mapped fragments will be unmapped,
+ * the queue's insert pointer will be restored to its original value.
+ *
+ * Returns NETDEV_TX_OK or NETDEV_TX_BUSY
+ * You must hold netif_tx_lock() to call this function.
+ */
+static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
+				  const struct sk_buff *skb)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	struct pci_dev *pci_dev = efx->pci_dev;
+	struct efx_tx_buffer *buffer;
+	skb_frag_t *fragment;
+	struct page *page;
+	int page_offset;
+	unsigned int len, unmap_len = 0, fill_level, insert_ptr, misalign;
+	dma_addr_t dma_addr, unmap_addr = 0;
+	unsigned int dma_len;
+	unsigned unmap_single;
+	int q_space, i = 0;
+	int rc = NETDEV_TX_OK;
+
+	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
+
+	/* Get size of the initial fragment */
+	len = skb_headlen(skb);
+
+	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
+	q_space = efx->type->txd_ring_mask - 1 - fill_level;
+
+	/* Map for DMA.  Use pci_map_single rather than pci_map_page
+	 * since this is more efficient on machines with sparse
+	 * memory.
+	 */
+	unmap_single = 1;
+	dma_addr = pci_map_single(pci_dev, skb->data, len, PCI_DMA_TODEVICE);
+
+	/* Process all fragments */
+	while (1) {
+		if (unlikely(pci_dma_mapping_error(dma_addr)))
+			goto pci_err;
+
+		/* Store fields for marking in the per-fragment final
+		 * descriptor */
+		unmap_len = len;
+		unmap_addr = dma_addr;
+
+		/* Add to TX queue, splitting across DMA boundaries */
+		do {
+			if (unlikely(q_space-- <= 0)) {
+				/* It might be that completions have
+				 * happened since the xmit path last
+				 * checked.  Update the xmit path's
+				 * copy of read_count.
+				 */
+				++tx_queue->stopped;
+				/* This memory barrier protects the
+				 * change of stopped from the access
+				 * of read_count. */
+				smp_mb();
+				tx_queue->old_read_count =
+					*(volatile unsigned *)
+					&tx_queue->read_count;
+				fill_level = (tx_queue->insert_count
+					      - tx_queue->old_read_count);
+				q_space = (efx->type->txd_ring_mask - 1 -
+					   fill_level);
+				if (unlikely(q_space-- <= 0))
+					goto stop;
+				smp_mb();
+				--tx_queue->stopped;
+			}
+
+			insert_ptr = (tx_queue->insert_count &
+				      efx->type->txd_ring_mask);
+			buffer = &tx_queue->buffer[insert_ptr];
+			EFX_BUG_ON_PARANOID(buffer->skb);
+			EFX_BUG_ON_PARANOID(buffer->len);
+			EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+			EFX_BUG_ON_PARANOID(buffer->unmap_len);
+
+			dma_len = (((~dma_addr) & efx->type->tx_dma_mask) + 1);
+			if (likely(dma_len > len))
+				dma_len = len;
+
+			misalign = (unsigned)dma_addr & efx->type->bug5391_mask;
+			if (misalign && dma_len + misalign > 512)
+				dma_len = 512 - misalign;
+
+			/* Fill out per descriptor fields */
+			buffer->len = dma_len;
+			buffer->dma_addr = dma_addr;
+			len -= dma_len;
+			dma_addr += dma_len;
+			++tx_queue->insert_count;
+		} while (len);
+
+		/* Transfer ownership of the unmapping to the final buffer */
+		buffer->unmap_addr = unmap_addr;
+		buffer->unmap_single = unmap_single;
+		buffer->unmap_len = unmap_len;
+		unmap_len = 0;
+
+		/* Get address and size of next fragment */
+		if (i >= skb_shinfo(skb)->nr_frags)
+			break;
+		fragment = &skb_shinfo(skb)->frags[i];
+		len = fragment->size;
+		page = fragment->page;
+		page_offset = fragment->page_offset;
+		i++;
+		/* Map for DMA */
+		unmap_single = 0;
+		dma_addr = pci_map_page(pci_dev, page, page_offset, len,
+					PCI_DMA_TODEVICE);
+	}
+
+	/* Transfer ownership of the skb to the final buffer */
+	buffer->skb = skb;
+	buffer->continuation = 0;
+
+	/* Pass off to hardware */
+	falcon_push_buffers(tx_queue);
+
+	return NETDEV_TX_OK;
+
+ pci_err:
+	EFX_ERR_RL(efx, " TX queue %d could not map skb with %d bytes %d "
+		   "fragments for DMA\n", tx_queue->queue, skb->len,
+		   skb_shinfo(skb)->nr_frags + 1);
+
+	/* Mark the packet as transmitted, and free the SKB ourselves */
+	dev_kfree_skb_any((struct sk_buff *)skb);
+	goto unwind;
+
+ stop:
+	rc = NETDEV_TX_BUSY;
+
+	if (tx_queue->stopped == 1)
+		efx_stop_queue(efx);
+
+ unwind:
+	/* Work backwards until we hit the original insert pointer value */
+	while (tx_queue->insert_count != tx_queue->write_count) {
+		--tx_queue->insert_count;
+		insert_ptr = tx_queue->insert_count & efx->type->txd_ring_mask;
+		buffer = &tx_queue->buffer[insert_ptr];
+		if (buffer->unmap_len) {
+			if (buffer->unmap_single)
+				pci_unmap_single(pci_dev, buffer->unmap_addr,
+						 buffer->unmap_len,
+						 PCI_DMA_TODEVICE);
+			else
+				pci_unmap_page(pci_dev, buffer->unmap_addr,
+					       buffer->unmap_len,
+					       PCI_DMA_TODEVICE);
+		}
+		buffer->unmap_len = 0;
+		buffer->len = 0;
+	}
+
+	/* Free the fragment we were mid-way through pushing */
+	if (unmap_len)
+		pci_unmap_page(pci_dev, unmap_addr, unmap_len,
+			       PCI_DMA_TODEVICE);
+
+	return rc;
+}
+
+/* Remove packets from the TX queue
+ *
+ * This removes packets from the TX queue, up to and including the
+ * specified index.
+ */
+static inline void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
+				       unsigned int index)
+{
+	struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
+	struct efx_tx_buffer *buffer;
+	unsigned int stop_index, read_ptr;
+
+	/* Calculate the stopping point.  Doing the check this way
+	 * avoids wrongly completing every buffer in the ring if we
+	 * get called twice with the same index.  (Hardware should
+	 * never do this, since it can't complete that many buffers in
+	 * one go.)
+	 */
+	stop_index = (index + 1) & tx_queue->efx->type->txd_ring_mask;
+	read_ptr = tx_queue->read_count & tx_queue->efx->type->txd_ring_mask;
+
+	while (read_ptr != stop_index) {
+		buffer = &tx_queue->buffer[read_ptr];
+		if (unlikely(buffer->len == 0)) {
+			EFX_ERR(tx_queue->efx, "TX queue %d spurious TX "
+				"completion id %x\n", tx_queue->queue,
+				read_ptr);
+			/* Don't reset */
+		} else {
+			if (buffer->unmap_len) {
+				if (buffer->unmap_single)
+					pci_unmap_single(pci_dev,
+							 buffer->unmap_addr,
+							 buffer->unmap_len,
+							 PCI_DMA_TODEVICE);
+				else
+					pci_unmap_page(pci_dev,
+						       buffer->unmap_addr,
+						       buffer->unmap_len,
+						       PCI_DMA_TODEVICE);
+				buffer->unmap_single = 0;
+				buffer->unmap_len = 0;
+			}
+			if (buffer->skb) {
+				dev_kfree_skb_any((struct sk_buff *)
+						  buffer->skb);
+				buffer->skb = NULL;
+				EFX_TRACE(tx_queue->efx, "TX queue %d "
+					  "transmission id %x complete\n",
+					  tx_queue->queue, read_ptr);
+			}
+			buffer->continuation = 1;
+			buffer->len = 0;
+		}
+		++tx_queue->read_count;
+		read_ptr = (tx_queue->read_count &
+			    tx_queue->efx->type->txd_ring_mask);
+	}
+}
+
+/* Initiate a packet transmission on the specified TX queue.
+ * Note that returning anything other than NETDEV_TX_OK will cause the
+ * OS to free the skb.
+ *
+ * This function is split out from efx_hard_start_xmit to allow the
+ * loopback test to direct packets via specific TX queues.  It is
+ * therefore a non-static inline, so as not to penalise performance
+ * for non-loopback transmissions.
+ *
+ * Context: netif_tx_lock held
+ */
+inline int efx_xmit(struct efx_nic *efx,
+		    struct efx_tx_queue *tx_queue, struct sk_buff *skb)
+{
+	int rc;
+
+	/* Map fragments for DMA and add to TX queue */
+	rc = efx_enqueue_skb(tx_queue, skb);
+	if (unlikely(rc != NETDEV_TX_OK))
+		goto out;
+
+	/* Update last TX timer */
+	efx->net_dev->trans_start = jiffies;
+
+ out:
+	return rc;
+}
+
+/* Initiate a packet transmission.  We use one channel per CPU
+ * (sharing when we have more CPUs than channels).  On Falcon, the TX
+ * completion events will be directed back to the CPU that transmitted
+ * the packet, which should be cache-efficient.
+ *
+ * Context: non-blocking.
+ * Note that returning anything other than NETDEV_TX_OK will cause the
+ * OS to free the skb.
+ */
+int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
+{
+	struct efx_nic *efx = net_dev->priv;
+	return efx_xmit(efx, &efx->tx_queue[0], skb);
+}
+
+void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
+{
+	unsigned long flags __attribute__ ((unused));
+	unsigned fill_level;
+	struct efx_nic *efx = tx_queue->efx;
+
+	EFX_BUG_ON_PARANOID(index > efx->type->txd_ring_mask);
+
+	efx_dequeue_buffers(tx_queue, index);
+
+	/* See if we need to restart the netif queue.  This barrier
+	 * separates the update of read_count from the test of
+	 * stopped. */
+	smp_mb();
+	if (unlikely(tx_queue->stopped)) {
+		fill_level = tx_queue->insert_count - tx_queue->read_count;
+		if (fill_level < EFX_NETDEV_TX_THRESHOLD(tx_queue)) {
+			/* If the port is stopped and the net_dev isn't
+			 * registered, then the caller must be performing
+			 * flow control manually */
+			if (unlikely(!efx->net_dev_registered))
+				return;
+
+			/* Do this under netif_tx_lock(), to avoid racing
+			 * with efx_xmit(). */
+			netif_tx_lock(efx->net_dev);
+			if (tx_queue->stopped) {
+				tx_queue->stopped = 0;
+				efx_wake_queue(efx);
+			}
+			netif_tx_unlock(efx->net_dev);
+		}
+	}
+}
+
+int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
+{
+	struct efx_nic *efx = tx_queue->efx;
+	unsigned int txq_size;
+	int i, rc;
+
+	EFX_LOG(efx, "creating TX queue %d\n", tx_queue->queue);
+
+	/* Allocate software ring */
+	txq_size = (efx->type->txd_ring_mask + 1) * sizeof(*tx_queue->buffer);
+	tx_queue->buffer = kzalloc(txq_size, GFP_KERNEL);
+	if (!tx_queue->buffer) {
+		rc = -ENOMEM;
+		goto fail1;
+	}
+	for (i = 0; i <= efx->type->txd_ring_mask; ++i)
+		tx_queue->buffer[i].continuation = 1;
+
+	/* Allocate hardware ring */
+	rc = falcon_probe_tx(tx_queue);
+	if (rc)
+		goto fail2;
+
+	return 0;
+
+ fail2:
+	kfree(tx_queue->buffer);
+	tx_queue->buffer = NULL;
+ fail1:
+	tx_queue->used = 0;
+
+	return rc;
+}
+
+int efx_init_tx_queue(struct efx_tx_queue *tx_queue)
+{
+	EFX_LOG(tx_queue->efx, "initialising TX queue %d\n", tx_queue->queue);
+
+	tx_queue->insert_count = 0;
+	tx_queue->write_count = 0;
+	tx_queue->read_count = 0;
+	tx_queue->old_read_count = 0;
+	BUG_ON(tx_queue->stopped);
+
+	/* Set up TX descriptor ring */
+	return falcon_init_tx(tx_queue);
+}
+
+void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
+{
+	unsigned int last_index, mask;
+	if (tx_queue->buffer) {
+		/* Free any buffers left in the ring */
+		mask = tx_queue->efx->type->txd_ring_mask;
+		last_index = (tx_queue->insert_count - 1) & mask;
+		EFX_LOG(tx_queue->efx, "Will dequeue up to 0x%x from 0x%x\n",
+			last_index, tx_queue->read_count & mask);
+		efx_dequeue_buffers(tx_queue, last_index);
+	}
+}
+
+void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
+{
+	EFX_LOG(tx_queue->efx, "shutting down TX queue %d\n", tx_queue->queue);
+
+	/* Flush TX queue, remove descriptor ring */
+	falcon_fini_tx(tx_queue);
+
+	efx_release_tx_buffers(tx_queue);
+
+	/* Release queue's stop on port, if any */
+	if (tx_queue->stopped) {
+		tx_queue->stopped = 0;
+		efx_wake_queue(tx_queue->efx);
+	}
+}
+
+void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
+{
+	EFX_LOG(tx_queue->efx, "destroying TX queue %d\n", tx_queue->queue);
+	falcon_remove_tx(tx_queue);
+
+	kfree(tx_queue->buffer);
+	tx_queue->buffer = NULL;
+	tx_queue->used = 0;
+}
+
+
diff --git a/drivers/net/sfc/tx.h b/drivers/net/sfc/tx.h
new file mode 100644
index 0000000..1526a73
--- /dev/null
+++ b/drivers/net/sfc/tx.h
@@ -0,0 +1,24 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_TX_H
+#define EFX_TX_H
+
+#include "net_driver.h"
+
+int efx_probe_tx_queue(struct efx_tx_queue *tx_queue);
+void efx_remove_tx_queue(struct efx_tx_queue *tx_queue);
+int efx_init_tx_queue(struct efx_tx_queue *tx_queue);
+void efx_fini_tx_queue(struct efx_tx_queue *tx_queue);
+
+int efx_hard_start_xmit(struct sk_buff *skb, struct net_device *net_dev);
+void efx_release_tx_buffers(struct efx_tx_queue *tx_queue);
+
+#endif /* EFX_TX_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
