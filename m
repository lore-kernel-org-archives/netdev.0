From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 15/18] igb: add page recycling support
Date: Fri, 27 Jun 2008 11:01:47 -0700
Message-ID: <20080627180144.22428.33113.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for page recycling by splitting the page into two
usable portions and tracking the reference count.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    4 -
 drivers/net/igb/igb_main.c |  138 ++++++++++++++++++++------------------------
 2 files changed, 63 insertions(+), 79 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 97f03da..da7bbaf 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -125,6 +125,7 @@ struct igb_buffer {
 		struct {
 			struct page *page;
 			u64 page_dma;
+			unsigned int page_offset;
 		};
 	};
 };
@@ -163,9 +164,6 @@ struct igb_ring {
 		};
 		/* RX */
 		struct {
-			/* arrays of page information for packet split */
-			struct sk_buff *pending_skb;
-			int pending_skb_page;
 			int no_itr_adjust;
 			struct igb_queue_stats rx_stats;
 			struct napi_struct napi;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 43f288a..2b5dbc7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1698,7 +1698,6 @@ int igb_setup_rx_resources(struct igb_adapter *adapter,
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
-	rx_ring->pending_skb = NULL;
 
 	rx_ring->adapter = adapter;
 
@@ -1790,15 +1789,6 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 			rctl |= E1000_RCTL_SZ_2048;
 			rctl &= ~E1000_RCTL_BSEX;
 			break;
-		case IGB_RXBUFFER_4096:
-			rctl |= E1000_RCTL_SZ_4096;
-			break;
-		case IGB_RXBUFFER_8192:
-			rctl |= E1000_RCTL_SZ_8192;
-			break;
-		case IGB_RXBUFFER_16384:
-			rctl |= E1000_RCTL_SZ_16384;
-			break;
 		}
 	} else {
 		rctl &= ~E1000_RCTL_BSEX;
@@ -1816,10 +1806,8 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	 * so only enable packet split for jumbo frames */
 	if (rctl & E1000_RCTL_LPE) {
 		adapter->rx_ps_hdr_size = IGB_RXBUFFER_128;
-		srrctl = adapter->rx_ps_hdr_size <<
+		srrctl |= adapter->rx_ps_hdr_size <<
 			 E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
-		/* buffer size is ALWAYS one page */
-		srrctl |= PAGE_SIZE >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
 	} else {
 		adapter->rx_ps_hdr_size = 0;
@@ -2124,20 +2112,17 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 			buffer_info->skb = NULL;
 		}
 		if (buffer_info->page) {
-			pci_unmap_page(pdev, buffer_info->page_dma,
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			if (buffer_info->page_dma)
+				pci_unmap_page(pdev, buffer_info->page_dma,
+					       PAGE_SIZE / 2,
+					       PCI_DMA_FROMDEVICE);
 			put_page(buffer_info->page);
 			buffer_info->page = NULL;
 			buffer_info->page_dma = 0;
+			buffer_info->page_offset = 0;
 		}
 	}
 
-	/* there also may be some cached data from a chained receive */
-	if (rx_ring->pending_skb) {
-		dev_kfree_skb(rx_ring->pending_skb);
-		rx_ring->pending_skb = NULL;
-	}
-
 	size = sizeof(struct igb_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
 
@@ -3064,7 +3049,11 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	else if (max_frame <= IGB_RXBUFFER_2048)
 		adapter->rx_buffer_len = IGB_RXBUFFER_2048;
 	else
-		adapter->rx_buffer_len = IGB_RXBUFFER_4096;
+#if (PAGE_SIZE / 2) > IGB_RXBUFFER_16384
+		adapter->rx_buffer_len = IGB_RXBUFFER_16384;
+#else
+		adapter->rx_buffer_len = PAGE_SIZE / 2;
+#endif
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE))
@@ -3770,7 +3759,7 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 	union e1000_adv_rx_desc *rx_desc , *next_rxd;
 	struct igb_buffer *buffer_info , *next_buffer;
 	struct sk_buff *skb;
-	unsigned int i, j;
+	unsigned int i;
 	u32 length, hlen, staterr;
 	bool cleaned = false;
 	int cleaned_count = 0;
@@ -3800,61 +3789,46 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 		cleaned = true;
 		cleaned_count++;
 
-		if (rx_ring->pending_skb != NULL) {
-			skb = rx_ring->pending_skb;
-			rx_ring->pending_skb = NULL;
-			j = rx_ring->pending_skb_page;
-		} else {
-			skb = buffer_info->skb;
-			prefetch(skb->data - NET_IP_ALIGN);
-			buffer_info->skb = NULL;
-			if (hlen) {
-				pci_unmap_single(pdev, buffer_info->dma,
-						 adapter->rx_ps_hdr_size +
-						   NET_IP_ALIGN,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb, hlen);
-			} else {
-				pci_unmap_single(pdev, buffer_info->dma,
-						 adapter->rx_buffer_len +
-						   NET_IP_ALIGN,
-						 PCI_DMA_FROMDEVICE);
-				skb_put(skb, length);
-				goto send_up;
-			}
-			j = 0;
+		skb = buffer_info->skb;
+		prefetch(skb->data - NET_IP_ALIGN);
+		buffer_info->skb = NULL;
+		if (!adapter->rx_ps_hdr_size) {
+			pci_unmap_single(pdev, buffer_info->dma,
+					 adapter->rx_buffer_len +
+					   NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, length);
+			goto send_up;
+		}
+
+		if (!skb_shinfo(skb)->nr_frags) {
+			pci_unmap_single(pdev, buffer_info->dma,
+					 adapter->rx_ps_hdr_size +
+					   NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, hlen);
 		}
 
-		while (length) {
+		if (length) {
 			pci_unmap_page(pdev, buffer_info->page_dma,
-				PAGE_SIZE, PCI_DMA_FROMDEVICE);
+				       PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma = 0;
-			skb_fill_page_desc(skb, j, buffer_info->page,
-						0, length);
-			buffer_info->page = NULL;
+
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+						buffer_info->page,
+						buffer_info->page_offset,
+						length);
+
+			if ((adapter->rx_buffer_len > (PAGE_SIZE / 2)) ||
+			    (page_count(buffer_info->page) != 1))
+				buffer_info->page = NULL;
+			else
+				get_page(buffer_info->page);
 
 			skb->len += length;
 			skb->data_len += length;
-			skb->truesize += length;
-			rx_desc->wb.upper.status_error = 0;
-			if (staterr & E1000_RXD_STAT_EOP)
-				break;
-
-			j++;
-			cleaned_count++;
-			i++;
-			if (i == rx_ring->count)
-				i = 0;
 
-			buffer_info = &rx_ring->buffer_info[i];
-			rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
-			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
-			length = le16_to_cpu(rx_desc->wb.upper.length);
-			if (!(staterr & E1000_RXD_STAT_DD)) {
-				rx_ring->pending_skb = skb;
-				rx_ring->pending_skb_page = j;
-				goto out;
-			}
+			skb->truesize += length;
 		}
 send_up:
 		i++;
@@ -3864,6 +3838,12 @@ send_up:
 		prefetch(next_rxd);
 		next_buffer = &rx_ring->buffer_info[i];
 
+		if (!(staterr & E1000_RXD_STAT_EOP)) {
+			buffer_info->skb = xchg(&next_buffer->skb, skb);
+			buffer_info->dma = xchg(&next_buffer->dma, 0);
+			goto next_desc;
+		}
+
 		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
@@ -3896,7 +3876,7 @@ next_desc:
 
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
-out:
+
 	rx_ring->next_to_clean = i;
 	cleaned_count = IGB_DESC_UNUSED(rx_ring);
 
@@ -3934,16 +3914,22 @@ static void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring,
 	while (cleaned_count--) {
 		rx_desc = E1000_RX_DESC_ADV(*rx_ring, i);
 
-		if (adapter->rx_ps_hdr_size && !buffer_info->page) {
-			buffer_info->page = alloc_page(GFP_ATOMIC);
+		if (adapter->rx_ps_hdr_size && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
-				adapter->alloc_rx_buff_failed++;
-				goto no_buffers;
+				buffer_info->page = alloc_page(GFP_ATOMIC);
+				if (!buffer_info->page) {
+					adapter->alloc_rx_buff_failed++;
+					goto no_buffers;
+				}
+				buffer_info->page_offset = 0;
+			} else {
+				buffer_info->page_offset ^= PAGE_SIZE / 2;
 			}
 			buffer_info->page_dma =
 				pci_map_page(pdev,
 					     buffer_info->page,
-					     0, PAGE_SIZE,
+					     buffer_info->page_offset,
+					     PAGE_SIZE / 2,
 					     PCI_DMA_FROMDEVICE);
 		}
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
