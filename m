From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ixgbe: Fix DMA mapping/unmapping issues when
	HWRSC is enabled on IOMMU enabled kernels
Date: Fri, 26 Feb 2010 01:14:37 -0800
Message-ID: <20100226091318.19796.70225.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:52756
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935611Ab0BZJO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:14:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

Work around 82599 HW issue when HWRSC is enabled on IOMMU enabled
kernels. 82599 HW is updating the header information after setting the
descriptor to done, resulting DMA mapping/unmapping issues on IOMMU
enabled systems. To work around the issue delay unmapping of first packet
that carries the header information until end of packet is reached.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   32 +++++++++++++++++++++++++++++---
 1 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3308790..4a01022 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -818,6 +818,12 @@ static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb,
 	return skb;
 }
 
+struct ixgbe_rsc_cb {
+	dma_addr_t dma;
+};
+
+#define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
+
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
                                struct ixgbe_ring *rx_ring,
                                int *work_done, int work_to_do)
@@ -867,9 +873,21 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		rx_buffer_info->skb = NULL;
 
 		if (rx_buffer_info->dma) {
-			pci_unmap_single(pdev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len,
-			                 PCI_DMA_FROMDEVICE);
+			if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
+			    (!(staterr & IXGBE_RXD_STAT_EOP)) &&
+				 (!(skb->prev)))
+				/*
+				 * When HWRSC is enabled, delay unmapping
+				 * of the first packet. It carries the
+				 * header information, HW may still
+				 * access the header after the writeback.
+				 * Only unmap it when EOP is reached
+				 */
+				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
+			else
+				pci_unmap_single(pdev, rx_buffer_info->dma,
+				                 rx_ring->rx_buf_len,
+				                 PCI_DMA_FROMDEVICE);
 			rx_buffer_info->dma = 0;
 			skb_put(skb, len);
 		}
@@ -917,6 +935,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			if (skb->prev)
 				skb = ixgbe_transform_rsc_queue(skb, &(rx_ring->rsc_count));
 			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
+				if (IXGBE_RSC_CB(skb)->dma)
+					pci_unmap_single(pdev, IXGBE_RSC_CB(skb)->dma,
+					                 rx_ring->rx_buf_len,
+					                 PCI_DMA_FROMDEVICE);
 				if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)
 					rx_ring->rsc_count += skb_shinfo(skb)->nr_frags;
 				else
@@ -3104,6 +3126,10 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 			rx_buffer_info->skb = NULL;
 			do {
 				struct sk_buff *this = skb;
+				if (IXGBE_RSC_CB(this)->dma)
+					pci_unmap_single(pdev, IXGBE_RSC_CB(this)->dma,
+					                 rx_ring->rx_buf_len,
+					                 PCI_DMA_FROMDEVICE);
 				skb = skb->prev;
 				dev_kfree_skb(this);
 			} while (skb);

