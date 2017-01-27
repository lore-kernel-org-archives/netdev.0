From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 2/2] ixgbe: add af_packet direct copy support
Date: Fri, 27 Jan 2017 13:34:11 -0800
Message-ID: <20170127213411.14162.22553.stgit@john-Precision-Tower-5810>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35590 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751614AbdA0Ve1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:34:27 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so19271734pfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:34:27 -0800 (PST)
In-Reply-To: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the ndo ops for direct dma socket option. This is
to start looking at the interface and driver work needed to enable
it.

Note error paths are not handled and I'm aware of a few bugs.
For example interface must be up before attaching socket or else
it will fail silently. TBD fix all these things.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  255 +++++++++++++++++++++++++
 2 files changed, 256 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index ef81c3d..198f90c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -266,6 +266,7 @@ struct ixgbe_ring {
 		struct ixgbe_tx_buffer *tx_buffer_info;
 		struct ixgbe_rx_buffer *rx_buffer_info;
 	};
+	unsigned int buffer_size;
 	unsigned long state;
 	u8 __iomem *tail;
 	dma_addr_t dma;			/* phys. address of descriptor ring */
@@ -299,6 +300,8 @@ struct ixgbe_ring {
 		struct ixgbe_tx_queue_stats tx_stats;
 		struct ixgbe_rx_queue_stats rx_stats;
 	};
+	bool ddma;	      /* ring data buffers mapped to userspace */
+	struct sock *rx_kick; /* rx kick userspace */
 } ____cacheline_internodealigned_in_smp;
 
 enum ixgbe_ring_f_enum {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1e2f39e..c5ab44a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1608,8 +1608,19 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 	i -= rx_ring->count;
 
 	do {
-		if (!ixgbe_alloc_mapped_page(rx_ring, bi))
-			break;
+		/* If direct dma has not released packet yet stop */
+		if (rx_ring->ddma) {
+			int align = TPACKET_ALIGN(TPACKET2_HDRLEN);
+			int hdrlen = ALIGN(align, L1_CACHE_BYTES);
+			struct tpacket2_hdr *hdr;
+
+			hdr = page_address(bi->page) + bi->page_offset - hdrlen;
+			if (unlikely(TP_STATUS_USER & hdr->tp_status))
+				break;
+		} else {
+			if (!ixgbe_alloc_mapped_page(rx_ring, bi))
+				break;
+		}
 
 		/*
 		 * Refresh the desc even if buffer_addrs didn't change
@@ -2005,6 +2016,97 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	return true;
 }
 
+/* ixgbe_do_ddma - direct dma routine to populate PACKET_RX_RING mmap region
+ *
+ * The packet socket interface builds a shared memory region using mmap after
+ * it is specified by the PACKET_RX_RING socket option. This will create a
+ * circular ring of memory slots. Typical software usage case copies the skb
+ * into these pages via tpacket_rcv() routine.
+ *
+ * Here we do direct DMA from the hardware (82599 in this case) into the
+ * mmap regions and populate the uhdr (think user space descriptor). This
+ * requires the hardware to support Scatter Gather and HighDMA which should
+ * be standard on most (all?) 10/40 Gbps devices.
+ *
+ * The buffer mapping should have already been done so that rx_buffer pages
+ * are handed to the driver from the mmap setup done at the socket layer.
+ *
+ * See ./include/uapi/linux/if_packet.h for details on packet layout here
+ * we can only use tpacket2_hdr type. v3 of the header type introduced bulk
+ * polling modes which do not work correctly with hardware DMA engine. The
+ * primary issue is we can not stop a DMA transaction from occurring after it
+ * has been configured. What results is the software timer advances the
+ * ring ahead of the hardware and the ring state is lost. Maybe there is
+ * a clever way to resolve this by I haven't thought it up yet.
+ */
+static int ixgbe_do_ddma(struct ixgbe_ring *rx_ring,
+			 union ixgbe_adv_rx_desc *rx_desc)
+{
+	int hdrlen = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES);
+	struct ixgbe_adapter *adapter = netdev_priv(rx_ring->netdev);
+	struct ixgbe_rx_buffer *rx_buffer;
+	struct tpacket2_hdr *h2; /* userspace descriptor */
+	struct sockaddr_ll *sll;
+	struct ethhdr *eth;
+	int len = 0;
+	u64 ns = 0;
+	s32 rem;
+
+	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
+	if (!rx_buffer->dma)
+		return -EBUSY;
+
+	prefetchw(rx_buffer->page);
+
+	/* test for any known error cases */
+	WARN_ON(ixgbe_test_staterr(rx_desc,
+				   IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
+				   !(rx_ring->netdev->features & NETIF_F_RXALL));
+
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      rx_ring->buffer_size,
+				      DMA_FROM_DEVICE);
+
+	/* Update the last_rx_timestamp timer in order to enable watchdog check
+	 * for error case of latched timestamp on a dropped packet.
+	 */
+	adapter->last_rx_timestamp = jiffies;
+	h2 = page_address(rx_buffer->page) + rx_buffer->page_offset - hdrlen;
+	eth = page_address(rx_buffer->page) + rx_buffer->page_offset,
+
+	/* This indicates a bug in ixgbe leaving for testing purposes */
+	WARN_ON(TP_STATUS_USER & h2->tp_status);
+	len = le16_to_cpu(rx_desc->wb.upper.length);
+	h2->tp_len = len;
+	h2->tp_snaplen = len;
+	h2->tp_mac = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES);
+	h2->tp_net = h2->tp_mac + ETH_HLEN;
+	h2->tp_sec = div_s64_rem(ns, NSEC_PER_SEC, &rem);
+	h2->tp_nsec = rem;
+
+	sll = (void *)h2 + TPACKET_ALIGN(sizeof(struct tpacket2_hdr));
+	sll->sll_halen = ETH_HLEN;
+	memcpy(sll->sll_addr, eth->h_source, ETH_ALEN);
+	sll->sll_family = AF_PACKET;
+	sll->sll_hatype = rx_ring->netdev->type;
+	sll->sll_protocol = eth->h_proto;
+	sll->sll_pkttype = PACKET_HOST;
+	sll->sll_ifindex = rx_ring->netdev->ifindex;
+
+	smp_mb();
+	h2->tp_status = TP_STATUS_USER;
+	rx_ring->rx_kick->sk_data_ready(rx_ring->rx_kick);
+
+	/* TBD handle non-EOP frames? - I think this is an invalid case
+	 * assuming ring slots are setup correctly.
+	 */
+	if (ixgbe_is_non_eop(rx_ring, rx_desc, NULL))
+		e_warn(drv, "Direct DMA received non-eop descriptor!");
+	return len;
+}
+
 static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 					     union ixgbe_adv_rx_desc *rx_desc)
 {
@@ -2134,6 +2236,21 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		 */
 		dma_rmb();
 
+		/* If we use direct DMA to shmem then we do not need SKBs
+		 * because user space descriptors are populated directly.
+		 */
+		if (rx_ring->ddma) {
+			int len = ixgbe_do_ddma(rx_ring, rx_desc);
+
+			if (len) {
+				total_rx_packets++;
+				total_rx_bytes += len;
+				cleaned_count++;
+				continue;
+			}
+			break;
+		}
+
 		/* retrieve a buffer from the ring */
 		skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
 
@@ -4887,6 +5004,12 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 	if (!rx_ring->rx_buffer_info)
 		return;
 
+	/* Buffers are owned by direct dma endpoint so we should not free
+	 * them here and instead wait for endpoint to claim buffers.
+	 */
+	if (rx_ring->ddma)
+		return;
+
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		struct ixgbe_rx_buffer *rx_buffer = &rx_ring->rx_buffer_info[i];
@@ -9264,6 +9387,132 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	return features;
 }
 
+static int ixgbe_ddma_map(struct net_device *dev, unsigned int ring,
+			  struct sock *sk, struct packet_ring_buffer *prb)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_ring *rx_ring = adapter->rx_ring[ring];
+	unsigned int frames_per_blk = prb->frames_per_block;
+	unsigned int blk_nr = prb->pg_vec_len;
+	struct ixgbe_rx_buffer *bi;
+	int i, j, err = 0;
+
+	/* Verify we are given a valid ring */
+	if (ring >= adapter->num_rx_queues)
+		return -EINVAL;
+	/* Verify we have enough descriptors to support user space ring */
+	if (!frames_per_blk || ((blk_nr * frames_per_blk) != rx_ring->count)) {
+		e_warn(drv, "ddma map requires %i ring slots\n",
+		       blk_nr * frames_per_blk);
+		return -EBUSY;
+	}
+
+	/* Bring the queue down to point buffers at user space */
+	ixgbe_disable_rx_queue(adapter, rx_ring);
+	usleep_range(10000, 20000);
+	ixgbe_irq_disable_queues(adapter, ((u64)1 << ring));
+	ixgbe_clean_rx_ring(rx_ring);
+
+	rx_ring->buffer_size = prb->frame_size;
+
+	/* In Direct DMA mode the descriptor block and tpacket headers are
+	 * held in fixed locations so we can pre-populate most of the fields.
+	 * Similarly the pages, offsets, and sizes for DMA are pre-calculated
+	 * to align with the user space ring and do not need to change.
+	 *
+	 * The layout is fixed to match the PF_PACKET layer in /net/packet/
+	 * which also invokes this routine via ndo_ddma_map().
+	 *
+	 * Couple design comments: Should we create v4 protocol rather than
+	 * trying to leverage v2 for compat. Perhaps. And similarly should
+	 * we generalize the packet_ring_buffer onto something that can be
+	 * generalized for other users?
+	 */
+	for (i = 0; i < blk_nr; i++) {
+		char *kaddr = prb->pg_vec[i].buffer;
+		unsigned int blk_size;
+		struct page *page;
+		size_t offset = 0;
+		dma_addr_t dma;
+
+		/* For DMA usage we can't use vmalloc */
+		if (is_vmalloc_addr(kaddr)) {
+			e_warn(drv, "vmalloc pages not supported in ddma\n");
+			err = -EINVAL;
+			goto unwind_map;
+		}
+
+		/* map page for use */
+		page = virt_to_page(kaddr);
+		blk_size = PAGE_SIZE << prb->pg_vec_order;
+		dma = dma_map_page(rx_ring->dev, page, 0,
+				   blk_size, DMA_FROM_DEVICE);
+		if (dma_mapping_error(rx_ring->dev, dma)) {
+			e_warn(drv, "ddma mapping error DMA_FROM_DEVICE\n");
+			rx_ring->rx_stats.alloc_rx_page_failed++;
+			err = -EBUSY;
+			goto unwind_map;
+		}
+
+		/* We may be able to push multiple frames per block in this case
+		 * set offset correctly to set pkt_addr correctly in descriptor.
+		 */
+		for (j = 0; j < frames_per_blk; j++) {
+			int hdrlen = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN),
+					   L1_CACHE_BYTES);
+			int b = ((i * frames_per_blk) + j);
+
+			bi = &rx_ring->rx_buffer_info[b];
+			if (!bi) // TBD abort here this just stops a panic
+				continue;
+			bi->page = page;
+			bi->dma = dma;
+
+			/* ignore priv for now */
+			bi->page_offset = offset + hdrlen;
+			offset += rx_ring->buffer_size;
+		}
+	}
+
+	rx_ring->ddma = true;
+	rx_ring->rx_kick = sk;
+unwind_map:
+	//tbd error path handling
+	ixgbe_configure_rx_ring(adapter, rx_ring);
+	return err;
+}
+
+static void ixgbe_ddma_unmap(struct net_device *dev, unsigned int ring)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_ring *rx_ring = adapter->rx_ring[ring];
+	int i;
+
+	rx_ring->ddma = false;
+	// tbd live traffic here(?) need to stop queue
+
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rx_ring->count; i++) {
+		struct ixgbe_rx_buffer *rx_buffer;
+
+		rx_buffer = &rx_ring->rx_buffer_info[i];
+		if (!rx_buffer)
+			continue;
+		if (rx_buffer->dma)
+			dma_unmap_page(rx_ring->dev, rx_buffer->dma,
+				       rx_buffer->page_offset,
+				       DMA_FROM_DEVICE);
+
+		rx_buffer->dma = 0;
+		rx_buffer->page_offset = 0;
+		rx_buffer->page = NULL;
+	}
+
+	rtnl_lock();
+	ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
+	rtnl_unlock();
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -9312,6 +9561,8 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	.ndo_udp_tunnel_add	= ixgbe_add_udp_tunnel_port,
 	.ndo_udp_tunnel_del	= ixgbe_del_udp_tunnel_port,
 	.ndo_features_check	= ixgbe_features_check,
+	.ndo_ddma_map		= ixgbe_ddma_map,
+	.ndo_ddma_unmap		= ixgbe_ddma_unmap,
 };
 
 /**
