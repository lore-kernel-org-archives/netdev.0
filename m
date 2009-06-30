From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/4] ixgbe: fix unmap length bug
Date: Tue, 30 Jun 2009 14:44:56 -0700
Message-ID: <20090630214456.17464.70554.stgit@localhost.localdomain>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Joerg Roedel <joerg.roedel@amd.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:54323
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753254AbZF3VpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 17:45:15 -0400
In-Reply-To: <20090630214349.17464.25370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch addresses three WARN_ON statements from DMA-API debug code

ixgbe is mapping more than it unmaps, reduce the length of the map call and
remove the "used once" local variable.

found by Joerg Roedel <joerg.roedel@amd.com> in 2.6.30, so is a candidate
for -stable.

in addition, fix missing ->dma = 0 after unmap to prevent double free with
pci_unmap_single

and lastly, don't unmap (half) pages that aren't mapped.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Joerg Roedel <joerg.roedel@amd.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fce2ef4..5588ef4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -563,7 +563,6 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
-	unsigned int bufsz = rx_ring->rx_buf_len + NET_IP_ALIGN;
 
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
@@ -593,7 +592,9 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 
 		if (!bi->skb) {
 			struct sk_buff *skb;
-			skb = netdev_alloc_skb(adapter->netdev, bufsz);
+			skb = netdev_alloc_skb(adapter->netdev,
+			                       (rx_ring->rx_buf_len +
+			                        NET_IP_ALIGN));
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
@@ -608,7 +609,8 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			skb_reserve(skb, NET_IP_ALIGN);
 
 			bi->skb = skb;
-			bi->dma = pci_map_single(pdev, skb->data, bufsz,
+			bi->dma = pci_map_single(pdev, skb->data,
+			                         rx_ring->rx_buf_len,
 			                         PCI_DMA_FROMDEVICE);
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
@@ -732,6 +734,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			pci_unmap_single(pdev, rx_buffer_info->dma,
 			                 rx_ring->rx_buf_len,
 			                 PCI_DMA_FROMDEVICE);
+			rx_buffer_info->dma = 0;
 			skb_put(skb, len);
 		}
 
@@ -2815,9 +2818,11 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		}
 		if (!rx_buffer_info->page)
 			continue;
-		pci_unmap_page(pdev, rx_buffer_info->page_dma, PAGE_SIZE / 2,
-		               PCI_DMA_FROMDEVICE);
-		rx_buffer_info->page_dma = 0;
+		if (rx_buffer_info->page_dma) {
+			pci_unmap_page(pdev, rx_buffer_info->page_dma,
+			               PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
+			rx_buffer_info->page_dma = 0;
+		}
 		put_page(rx_buffer_info->page);
 		rx_buffer_info->page = NULL;
 		rx_buffer_info->page_offset = 0;

