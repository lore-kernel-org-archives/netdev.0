From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: Use bool flag to see if the packet
	unmapping is delayed in HWRSC
Date: Thu, 13 May 2010 20:33:21 -0700
Message-ID: <20100514033319.30716.22999.stgit@localhost.localdomain>
References: <20100514033233.30716.30144.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:48671
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757237Ab0ENDdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 23:33:39 -0400
In-Reply-To: <20100514033233.30716.30144.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

We can't use zero magic "bad" value to check if IXGBE_RSC_CB(skb)->dma
is valid. It is only valid in x86/arm/m68k/alpha architectures and in
spark, powerPC and other architectures it should be ~0. As per
Benjamin Herrenschmidt feedback use a bool flag to decide if
the packet unmapping is delayed in hardware RSC till EOP is reached

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 15032c7..3fb9f23 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1160,6 +1160,7 @@ static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb,
 
 struct ixgbe_rsc_cb {
 	dma_addr_t dma;
+	bool delay_unmap;
 };
 
 #define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
@@ -1215,7 +1216,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		if (rx_buffer_info->dma) {
 			if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
 			    (!(staterr & IXGBE_RXD_STAT_EOP)) &&
-				 (!(skb->prev)))
+				 (!(skb->prev))) {
 				/*
 				 * When HWRSC is enabled, delay unmapping
 				 * of the first packet. It carries the
@@ -1223,12 +1224,14 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				 * access the header after the writeback.
 				 * Only unmap it when EOP is reached
 				 */
+				IXGBE_RSC_CB(skb)->delay_unmap = true;
 				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
-			else
+			} else {
 				dma_unmap_single(&pdev->dev,
-						 rx_buffer_info->dma,
+				                 rx_buffer_info->dma,
 				                 rx_ring->rx_buf_len,
-						 DMA_FROM_DEVICE);
+				                 DMA_FROM_DEVICE);
+			}
 			rx_buffer_info->dma = 0;
 			skb_put(skb, len);
 		}
@@ -1276,12 +1279,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			if (skb->prev)
 				skb = ixgbe_transform_rsc_queue(skb, &(rx_ring->rsc_count));
 			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-				if (IXGBE_RSC_CB(skb)->dma) {
+				if (IXGBE_RSC_CB(skb)->delay_unmap) {
 					dma_unmap_single(&pdev->dev,
 							 IXGBE_RSC_CB(skb)->dma,
 					                 rx_ring->rx_buf_len,
 							 DMA_FROM_DEVICE);
 					IXGBE_RSC_CB(skb)->dma = 0;
+					IXGBE_RSC_CB(skb)->delay_unmap = false;
 				}
 				if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)
 					rx_ring->rsc_count += skb_shinfo(skb)->nr_frags;
@@ -3505,12 +3509,13 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 			rx_buffer_info->skb = NULL;
 			do {
 				struct sk_buff *this = skb;
-				if (IXGBE_RSC_CB(this)->dma) {
+				if (IXGBE_RSC_CB(this)->delay_unmap) {
 					dma_unmap_single(&pdev->dev,
 							 IXGBE_RSC_CB(this)->dma,
 					                 rx_ring->rx_buf_len,
 							 DMA_FROM_DEVICE);
 					IXGBE_RSC_CB(this)->dma = 0;
+					IXGBE_RSC_CB(skb)->delay_unmap = false;
 				}
 				skb = skb->prev;
 				dev_kfree_skb(this);

