From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after
	unmapping the address
Date: Fri, 19 Mar 2010 07:41:33 -0700
Message-ID: <20100319144132.10528.79305.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:48523 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752450Ab0CSOlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 10:41:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

As per Simon Horman's feedback set IXGBE_RSC_CB(skb)->dma to zero
after unmapping HWRSC DMA address to avoid double freeing.

Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 18b5b21..d75c46f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -935,10 +935,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			if (skb->prev)
 				skb = ixgbe_transform_rsc_queue(skb, &(rx_ring->rsc_count));
 			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-				if (IXGBE_RSC_CB(skb)->dma)
+				if (IXGBE_RSC_CB(skb)->dma) {
 					pci_unmap_single(pdev, IXGBE_RSC_CB(skb)->dma,
 					                 rx_ring->rx_buf_len,
 					                 PCI_DMA_FROMDEVICE);
+					IXGBE_RSC_CB(skb)->dma = 0;
+				}
 				if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)
 					rx_ring->rsc_count += skb_shinfo(skb)->nr_frags;
 				else
@@ -3126,10 +3128,12 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 			rx_buffer_info->skb = NULL;
 			do {
 				struct sk_buff *this = skb;
-				if (IXGBE_RSC_CB(this)->dma)
+				if (IXGBE_RSC_CB(this)->dma) {
 					pci_unmap_single(pdev, IXGBE_RSC_CB(this)->dma,
 					                 rx_ring->rx_buf_len,
 					                 PCI_DMA_FROMDEVICE);
+					IXGBE_RSC_CB(this)->dma = 0;
+				}
 				skb = skb->prev;
 				dev_kfree_skb(this);
 			} while (skb);

