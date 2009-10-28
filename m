From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 18/23] igb: cleanup clean_rx_irq_adv and
	alloc_rx_buffers_adv
Date: Wed, 28 Oct 2009 02:51:16 -0700
Message-ID: <20091028095115.13156.73668.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:53203
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751670AbZJ1JzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:55:00 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch cleans up some whitespace issues in clean_rx_irq_adv.  It also
adds NUMA aware page allocation and dma error handling to
alloc_rx_buffers_adv.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8f8b7cc..d3e8316 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4952,6 +4952,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
+
 		next_rxd = E1000_RX_DESC_ADV(*rx_ring, i);
 		prefetch(next_rxd);
 		next_buffer = &rx_ring->buffer_info[i];
@@ -4989,7 +4990,6 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 
 			skb->len += length;
 			skb->data_len += length;
-
 			skb->truesize += length;
 		}
 
@@ -5071,7 +5071,7 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 
 		if ((bufsz < IGB_RXBUFFER_1024) && !buffer_info->page_dma) {
 			if (!buffer_info->page) {
-				buffer_info->page = alloc_page(GFP_ATOMIC);
+				buffer_info->page = netdev_alloc_page(netdev);
 				if (!buffer_info->page) {
 					rx_ring->rx_stats.alloc_failed++;
 					goto no_buffers;
@@ -5085,9 +5085,16 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 					     buffer_info->page_offset,
 					     PAGE_SIZE / 2,
 					     PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(rx_ring->pdev,
+			                          buffer_info->page_dma)) {
+				buffer_info->page_dma = 0;
+				rx_ring->rx_stats.alloc_failed++;
+				goto no_buffers;
+			}
 		}
 
-		if (!buffer_info->skb) {
+		skb = buffer_info->skb;
+		if (!skb) {
 			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_failed++;
@@ -5095,10 +5102,18 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 			}
 
 			buffer_info->skb = skb;
+		}
+		if (!buffer_info->dma) {
 			buffer_info->dma = pci_map_single(rx_ring->pdev,
 			                                  skb->data,
 							  bufsz,
 							  PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(rx_ring->pdev,
+			                          buffer_info->dma)) {
+				buffer_info->dma = 0;
+				rx_ring->rx_stats.alloc_failed++;
+				goto no_buffers;
+			}
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
@@ -5107,8 +5122,7 @@ void igb_alloc_rx_buffers_adv(struct igb_ring *rx_ring, int cleaned_count)
 			     cpu_to_le64(buffer_info->page_dma);
 			rx_desc->read.hdr_addr = cpu_to_le64(buffer_info->dma);
 		} else {
-			rx_desc->read.pkt_addr =
-			     cpu_to_le64(buffer_info->dma);
+			rx_desc->read.pkt_addr = cpu_to_le64(buffer_info->dma);
 			rx_desc->read.hdr_addr = 0;
 		}
 

