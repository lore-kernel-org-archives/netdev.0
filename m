From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 1/3] pch_gbe: fixed the issue which receives an unnecessary packet.
Date: Fri,  2 Sep 2011 09:20:07 +0900
Message-ID: <1314922809-4041-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixed the issue which receives an unnecessary packet before link

When using PHY of GMII, an unnecessary packet is received,
And it becomes impossible to receive a packet after link up.

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index eac3c5c..48ff87c 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -717,13 +717,6 @@ static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
 	iowrite32(rdba, &hw->reg->RX_DSC_BASE);
 	iowrite32(rdlen, &hw->reg->RX_DSC_SIZE);
 	iowrite32((rdba + rdlen), &hw->reg->RX_DSC_SW_P);
-
-	/* Enables Receive DMA */
-	rxdma = ioread32(&hw->reg->DMA_CTRL);
-	rxdma |= PCH_GBE_RX_DMA_EN;
-	iowrite32(rxdma, &hw->reg->DMA_CTRL);
-	/* Enables Receive */
-	iowrite32(PCH_GBE_MRE_MAC_RX_EN, &hw->reg->MAC_RX_EN);
 }
 
 /**
@@ -1097,6 +1090,19 @@ void pch_gbe_update_stats(struct pch_gbe_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
+static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
+{
+	u32 rxdma;
+
+	/* Enables Receive DMA */
+	rxdma = ioread32(&hw->reg->DMA_CTRL);
+	rxdma |= PCH_GBE_RX_DMA_EN;
+	iowrite32(rxdma, &hw->reg->DMA_CTRL);
+	/* Enables Receive */
+	iowrite32(PCH_GBE_MRE_MAC_RX_EN, &hw->reg->MAC_RX_EN);
+	return;
+}
+
 /**
  * pch_gbe_intr - Interrupt Handler
  * @irq:   Interrupt number
@@ -1717,6 +1723,7 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	pch_gbe_alloc_tx_buffers(adapter, tx_ring);
 	pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
 	adapter->tx_queue_len = netdev->tx_queue_len;
+	pch_gbe_start_receive(&adapter->hw);
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
-- 
1.7.4.4
