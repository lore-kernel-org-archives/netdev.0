From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] i40e: Drop packet split receive routine
Date: Fri,  6 May 2016 00:03:39 -0700
Message-ID: <1462518228-30527-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40771 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757915AbcEFHGa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 03:06:30 -0400
In-Reply-To: <1462518228-30527-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As part of preparation for the rx-refactor, remove the
packet split receive routine and ancillary code.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |   3 -
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  19 --
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  49 +----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 245 +------------------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   7 -
 6 files changed, 10 insertions(+), 317 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 00c4738..ea6a69a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -101,7 +101,6 @@
 #define I40E_PRIV_FLAGS_LINKPOLL_FLAG	BIT(1)
 #define I40E_PRIV_FLAGS_FD_ATR		BIT(2)
 #define I40E_PRIV_FLAGS_VEB_STATS	BIT(3)
-#define I40E_PRIV_FLAGS_PS		BIT(4)
 #define I40E_PRIV_FLAGS_HW_ATR_EVICT	BIT(5)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
@@ -320,8 +319,6 @@ struct i40e_pf {
 #define I40E_FLAG_RX_CSUM_ENABLED		BIT_ULL(1)
 #define I40E_FLAG_MSI_ENABLED			BIT_ULL(2)
 #define I40E_FLAG_MSIX_ENABLED			BIT_ULL(3)
-#define I40E_FLAG_RX_1BUF_ENABLED		BIT_ULL(4)
-#define I40E_FLAG_RX_PS_ENABLED			BIT_ULL(5)
 #define I40E_FLAG_RSS_ENABLED			BIT_ULL(6)
 #define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
 #define I40E_FLAG_FDIR_REQUIRES_REINIT		BIT_ULL(8)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 83dccf1..f119a74 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -273,8 +273,8 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 			 rx_ring->rx_buf_len,
 			 rx_ring->dtype);
 		dev_info(&pf->pdev->dev,
-			 "    rx_rings[%i]: hsplit = %d, next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
-			 i, ring_is_ps_enabled(rx_ring),
+			 "    rx_rings[%i]: next_to_use = %d, next_to_clean = %d, ring_active = %i\n",
+			 i,
 			 rx_ring->next_to_use,
 			 rx_ring->next_to_clean,
 			 rx_ring->ring_active);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8e56c43..858e169 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2829,8 +2829,6 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_FD_ATR : 0;
 	ret_flags |= pf->flags & I40E_FLAG_VEB_STATS_ENABLED ?
 		I40E_PRIV_FLAGS_VEB_STATS : 0;
-	ret_flags |= pf->flags & I40E_FLAG_RX_PS_ENABLED ?
-		I40E_PRIV_FLAGS_PS : 0;
 	ret_flags |= pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE ?
 		0 : I40E_PRIV_FLAGS_HW_ATR_EVICT;
 
@@ -2851,23 +2849,6 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 
 	/* NOTE: MFP is not settable */
 
-	/* allow the user to control the method of receive
-	 * buffer DMA, whether the packet is split at header
-	 * boundaries into two separate buffers.  In some cases
-	 * one routine or the other will perform better.
-	 */
-	if ((flags & I40E_PRIV_FLAGS_PS) &&
-	    !(pf->flags & I40E_FLAG_RX_PS_ENABLED)) {
-		pf->flags |= I40E_FLAG_RX_PS_ENABLED;
-		pf->flags &= ~I40E_FLAG_RX_1BUF_ENABLED;
-		reset_required = true;
-	} else if (!(flags & I40E_PRIV_FLAGS_PS) &&
-		   (pf->flags & I40E_FLAG_RX_PS_ENABLED)) {
-		pf->flags &= ~I40E_FLAG_RX_PS_ENABLED;
-		pf->flags |= I40E_FLAG_RX_1BUF_ENABLED;
-		reset_required = true;
-	}
-
 	if (flags & I40E_PRIV_FLAGS_LINKPOLL_FLAG)
 		pf->flags |= I40E_FLAG_LINK_POLLING_ENABLED;
 	else
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f6da6b7..84e8d4e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2871,18 +2871,9 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	}
 
 	rx_ctx.dtype = vsi->dtype;
-	if (vsi->dtype) {
-		set_ring_ps_enabled(ring);
-		rx_ctx.hsplit_0 = I40E_RX_SPLIT_L2      |
-				  I40E_RX_SPLIT_IP      |
-				  I40E_RX_SPLIT_TCP_UDP |
-				  I40E_RX_SPLIT_SCTP;
-	} else {
-		rx_ctx.hsplit_0 = 0;
-	}
+	rx_ctx.hsplit_0 = 0;
 
-	rx_ctx.rxmax = min_t(u16, vsi->max_frame,
-				  (chain_len * ring->rx_buf_len));
+	rx_ctx.rxmax = min_t(u16, vsi->max_frame, chain_len * ring->rx_buf_len);
 	if (hw->revision_id == 0)
 		rx_ctx.lrxqthresh = 0;
 	else
@@ -2919,12 +2910,7 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	ring->tail = hw->hw_addr + I40E_QRX_TAIL(pf_q);
 	writel(0, ring->tail);
 
-	if (ring_is_ps_enabled(ring)) {
-		i40e_alloc_rx_headers(ring);
-		i40e_alloc_rx_buffers_ps(ring, I40E_DESC_UNUSED(ring));
-	} else {
-		i40e_alloc_rx_buffers_1buf(ring, I40E_DESC_UNUSED(ring));
-	}
+	i40e_alloc_rx_buffers_1buf(ring, I40E_DESC_UNUSED(ring));
 
 	return 0;
 }
@@ -2963,25 +2949,9 @@ static int i40e_vsi_configure_rx(struct i40e_vsi *vsi)
 	else
 		vsi->max_frame = I40E_RXBUFFER_2048;
 
-	/* figure out correct receive buffer length */
-	switch (vsi->back->flags & (I40E_FLAG_RX_1BUF_ENABLED |
-				    I40E_FLAG_RX_PS_ENABLED)) {
-	case I40E_FLAG_RX_1BUF_ENABLED:
-		vsi->rx_hdr_len = 0;
-		vsi->rx_buf_len = vsi->max_frame;
-		vsi->dtype = I40E_RX_DTYPE_NO_SPLIT;
-		break;
-	case I40E_FLAG_RX_PS_ENABLED:
-		vsi->rx_hdr_len = I40E_RX_HDR_SIZE;
-		vsi->rx_buf_len = I40E_RXBUFFER_2048;
-		vsi->dtype = I40E_RX_DTYPE_HEADER_SPLIT;
-		break;
-	default:
-		vsi->rx_hdr_len = I40E_RX_HDR_SIZE;
-		vsi->rx_buf_len = I40E_RXBUFFER_2048;
-		vsi->dtype = I40E_RX_DTYPE_SPLIT_ALWAYS;
-		break;
-	}
+	vsi->rx_hdr_len = 0;
+	vsi->rx_buf_len = vsi->max_frame;
+	vsi->dtype = I40E_RX_DTYPE_NO_SPLIT;
 
 #ifdef I40E_FCOE
 	/* setup rx buffer for FCoE */
@@ -8460,11 +8430,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    I40E_FLAG_MSI_ENABLED     |
 		    I40E_FLAG_MSIX_ENABLED;
 
-	if (iommu_present(&pci_bus_type))
-		pf->flags |= I40E_FLAG_RX_PS_ENABLED;
-	else
-		pf->flags |= I40E_FLAG_RX_1BUF_ENABLED;
-
 	/* Set default ITR */
 	pf->rx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF;
 	pf->tx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_TX_DEF;
@@ -10699,7 +10664,7 @@ static void i40e_print_features(struct i40e_pf *pf)
 	i += snprintf(&buf[i], REMAIN(i), " VSIs: %d QP: %d RX: %s",
 		      pf->hw.func_caps.num_vsis,
 		      pf->vsi[pf->lan_vsi]->num_queue_pairs,
-		      pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
+		      "1BUF");
 
 	if (pf->flags & I40E_FLAG_RSS_ENABLED)
 		i += snprintf(&buf[i], REMAIN(i), " RSS");
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index dab733c..450ecdd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1032,22 +1032,6 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		return;
 
-	if (ring_is_ps_enabled(rx_ring)) {
-		int bufsz = ALIGN(rx_ring->rx_hdr_len, 256) * rx_ring->count;
-
-		rx_bi = &rx_ring->rx_bi[0];
-		if (rx_bi->hdr_buf) {
-			dma_free_coherent(dev,
-					  bufsz,
-					  rx_bi->hdr_buf,
-					  rx_bi->dma);
-			for (i = 0; i < rx_ring->count; i++) {
-				rx_bi = &rx_ring->rx_bi[i];
-				rx_bi->dma = 0;
-				rx_bi->hdr_buf = NULL;
-			}
-		}
-	}
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		rx_bi = &rx_ring->rx_bi[i];
@@ -1503,230 +1487,6 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
 }
 
 /**
- * i40e_clean_rx_irq_ps - Reclaim resources after receive; packet split
- * @rx_ring:  rx ring to clean
- * @budget:   how many cleans we're allowed
- *
- * Returns true if there's any budget left (e.g. the clean is finished)
- **/
-static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
-{
-	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
-	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
-	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
-	struct i40e_vsi *vsi = rx_ring->vsi;
-	u16 i = rx_ring->next_to_clean;
-	union i40e_rx_desc *rx_desc;
-	u32 rx_error, rx_status;
-	bool failure = false;
-	u8 rx_ptype;
-	u64 qword;
-	u32 copysize;
-
-	if (budget <= 0)
-		return 0;
-
-	do {
-		struct i40e_rx_buffer *rx_bi;
-		struct sk_buff *skb;
-		u16 vlan_tag;
-		/* return some buffers to hardware, one at a time is too slow */
-		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			failure = failure ||
-				  i40e_alloc_rx_buffers_ps(rx_ring,
-							   cleaned_count);
-			cleaned_count = 0;
-		}
-
-		i = rx_ring->next_to_clean;
-		rx_desc = I40E_RX_DESC(rx_ring, i);
-		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
-			I40E_RXD_QW1_STATUS_SHIFT;
-
-		if (!(rx_status & BIT(I40E_RX_DESC_STATUS_DD_SHIFT)))
-			break;
-
-		/* This memory barrier is needed to keep us from reading
-		 * any other fields out of the rx_desc until we know the
-		 * DD bit is set.
-		 */
-		dma_rmb();
-		/* sync header buffer for reading */
-		dma_sync_single_range_for_cpu(rx_ring->dev,
-					      rx_ring->rx_bi[0].dma,
-					      i * rx_ring->rx_hdr_len,
-					      rx_ring->rx_hdr_len,
-					      DMA_FROM_DEVICE);
-		if (i40e_rx_is_programming_status(qword)) {
-			i40e_clean_programming_status(rx_ring, rx_desc);
-			I40E_RX_INCREMENT(rx_ring, i);
-			continue;
-		}
-		rx_bi = &rx_ring->rx_bi[i];
-		skb = rx_bi->skb;
-		if (likely(!skb)) {
-			skb = __netdev_alloc_skb_ip_align(rx_ring->netdev,
-							  rx_ring->rx_hdr_len,
-							  GFP_ATOMIC |
-							  __GFP_NOWARN);
-			if (!skb) {
-				rx_ring->rx_stats.alloc_buff_failed++;
-				failure = true;
-				break;
-			}
-
-			/* initialize queue mapping */
-			skb_record_rx_queue(skb, rx_ring->queue_index);
-			/* we are reusing so sync this buffer for CPU use */
-			dma_sync_single_range_for_cpu(rx_ring->dev,
-						      rx_ring->rx_bi[0].dma,
-						      i * rx_ring->rx_hdr_len,
-						      rx_ring->rx_hdr_len,
-						      DMA_FROM_DEVICE);
-		}
-		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
-				I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
-		rx_header_len = (qword & I40E_RXD_QW1_LENGTH_HBUF_MASK) >>
-				I40E_RXD_QW1_LENGTH_HBUF_SHIFT;
-		rx_sph = (qword & I40E_RXD_QW1_LENGTH_SPH_MASK) >>
-			 I40E_RXD_QW1_LENGTH_SPH_SHIFT;
-
-		rx_error = (qword & I40E_RXD_QW1_ERROR_MASK) >>
-			   I40E_RXD_QW1_ERROR_SHIFT;
-		rx_hbo = rx_error & BIT(I40E_RX_DESC_ERROR_HBO_SHIFT);
-		rx_error &= ~BIT(I40E_RX_DESC_ERROR_HBO_SHIFT);
-
-		rx_ptype = (qword & I40E_RXD_QW1_PTYPE_MASK) >>
-			   I40E_RXD_QW1_PTYPE_SHIFT;
-		/* sync half-page for reading */
-		dma_sync_single_range_for_cpu(rx_ring->dev,
-					      rx_bi->page_dma,
-					      rx_bi->page_offset,
-					      PAGE_SIZE / 2,
-					      DMA_FROM_DEVICE);
-		prefetch(page_address(rx_bi->page) + rx_bi->page_offset);
-		rx_bi->skb = NULL;
-		cleaned_count++;
-		copysize = 0;
-		if (rx_hbo || rx_sph) {
-			int len;
-
-			if (rx_hbo)
-				len = I40E_RX_HDR_SIZE;
-			else
-				len = rx_header_len;
-			memcpy(__skb_put(skb, len), rx_bi->hdr_buf, len);
-		} else if (skb->len == 0) {
-			int len;
-			unsigned char *va = page_address(rx_bi->page) +
-					    rx_bi->page_offset;
-
-			len = min(rx_packet_len, rx_ring->rx_hdr_len);
-			memcpy(__skb_put(skb, len), va, len);
-			copysize = len;
-			rx_packet_len -= len;
-		}
-		/* Get the rest of the data if this was a header split */
-		if (rx_packet_len) {
-			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-					rx_bi->page,
-					rx_bi->page_offset + copysize,
-					rx_packet_len, I40E_RXBUFFER_2048);
-
-			/* If the page count is more than 2, then both halves
-			 * of the page are used and we need to free it. Do it
-			 * here instead of in the alloc code. Otherwise one
-			 * of the half-pages might be released between now and
-			 * then, and we wouldn't know which one to use.
-			 * Don't call get_page and free_page since those are
-			 * both expensive atomic operations that just change
-			 * the refcount in opposite directions. Just give the
-			 * page to the stack; he can have our refcount.
-			 */
-			if (page_count(rx_bi->page) > 2) {
-				dma_unmap_page(rx_ring->dev,
-					       rx_bi->page_dma,
-					       PAGE_SIZE,
-					       DMA_FROM_DEVICE);
-				rx_bi->page = NULL;
-				rx_bi->page_dma = 0;
-				rx_ring->rx_stats.realloc_count++;
-			} else {
-				get_page(rx_bi->page);
-				/* switch to the other half-page here; the
-				 * allocation code programs the right addr
-				 * into HW. If we haven't used this half-page,
-				 * the address won't be changed, and HW can
-				 * just use it next time through.
-				 */
-				rx_bi->page_offset ^= PAGE_SIZE / 2;
-			}
-
-		}
-		I40E_RX_INCREMENT(rx_ring, i);
-
-		if (unlikely(
-		    !(rx_status & BIT(I40E_RX_DESC_STATUS_EOF_SHIFT)))) {
-			struct i40e_rx_buffer *next_buffer;
-
-			next_buffer = &rx_ring->rx_bi[i];
-			next_buffer->skb = skb;
-			rx_ring->rx_stats.non_eop_descs++;
-			continue;
-		}
-
-		/* ERR_MASK will only have valid bits if EOP set */
-		if (unlikely(rx_error & BIT(I40E_RX_DESC_ERROR_RXE_SHIFT))) {
-			dev_kfree_skb_any(skb);
-			continue;
-		}
-
-		i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
-
-		if (unlikely(rx_status & I40E_RXD_QW1_STATUS_TSYNVALID_MASK)) {
-			i40e_ptp_rx_hwtstamp(vsi->back, skb, (rx_status &
-					   I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
-					   I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT);
-			rx_ring->last_rx_timestamp = jiffies;
-		}
-
-		/* probably a little skewed due to removing CRC */
-		total_rx_bytes += skb->len;
-		total_rx_packets++;
-
-		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
-
-		i40e_rx_checksum(vsi, skb, rx_status, rx_error, rx_ptype);
-
-		vlan_tag = rx_status & BIT(I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)
-			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
-			 : 0;
-#ifdef I40E_FCOE
-		if (unlikely(
-		    i40e_rx_is_fcoe(rx_ptype) &&
-		    !i40e_fcoe_handle_offload(rx_ring, rx_desc, skb))) {
-			dev_kfree_skb_any(skb);
-			continue;
-		}
-#endif
-		i40e_receive_skb(rx_ring, skb, vlan_tag);
-
-		rx_desc->wb.qword1.status_error_len = 0;
-
-	} while (likely(total_rx_packets < budget));
-
-	u64_stats_update_begin(&rx_ring->syncp);
-	rx_ring->stats.packets += total_rx_packets;
-	rx_ring->stats.bytes += total_rx_bytes;
-	u64_stats_update_end(&rx_ring->syncp);
-	rx_ring->q_vector->rx.total_packets += total_rx_packets;
-	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
-
-	return failure ? budget : total_rx_packets;
-}
-
-/**
  * i40e_clean_rx_irq_1buf - Reclaim resources after receive; single buffer
  * @rx_ring:  rx ring to clean
  * @budget:   how many cleans we're allowed
@@ -2001,10 +1761,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	i40e_for_each_ring(ring, q_vector->rx) {
 		int cleaned;
 
-		if (ring_is_ps_enabled(ring))
-			cleaned = i40e_clean_rx_irq_ps(ring, budget_per_ring);
-		else
-			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
+		cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
 
 		work_done += cleaned;
 		/* if we clean as many as budgeted, we must not be done */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 6b2b191..5a2d0fe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -245,16 +245,9 @@ struct i40e_rx_queue_stats {
 enum i40e_ring_state_t {
 	__I40E_TX_FDIR_INIT_DONE,
 	__I40E_TX_XPS_INIT_DONE,
-	__I40E_RX_PS_ENABLED,
 	__I40E_RX_16BYTE_DESC_ENABLED,
 };
 
-#define ring_is_ps_enabled(ring) \
-	test_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
-#define set_ring_ps_enabled(ring) \
-	set_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
-#define clear_ring_ps_enabled(ring) \
-	clear_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
 #define ring_is_16byte_desc_enabled(ring) \
 	test_bit(__I40E_RX_16BYTE_DESC_ENABLED, &(ring)->state)
 #define set_ring_16byte_desc_enabled(ring) \
-- 
2.5.5
