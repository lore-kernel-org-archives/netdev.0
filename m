From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH 1/3] pch_gbe: create functions for MAC_RX {en,dis}able
Date: Mon, 22 Oct 2012 16:43:23 +0200
Message-ID: <1350917005-26350-2-git-send-email-vfalico@redhat.com>
References: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	tshimizu818@gmail.com, andy.cress@us.kontron.com,
	erwan.velu@zodiacaerospace.com, agospoda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754817Ab2JVOnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 10:43:37 -0400
In-Reply-To: <1350917005-26350-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move MAC_RX-related bits into separate functions.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   26 +++++++++++++++----
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b2a94d0..d5190bf 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -420,6 +420,22 @@ static void pch_gbe_mac_reset_rx(struct pch_gbe_hw *hw)
 	return;
 }
 
+static void pch_gbe_disable_mac_rx(struct pch_gbe_hw *hw)
+{
+	u32 rctl;
+	/* Disables Receive MAC */
+	rctl = ioread32(&hw->reg->MAC_RX_EN);
+	iowrite32((rctl & ~PCH_GBE_MRE_MAC_RX_EN), &hw->reg->MAC_RX_EN);
+}
+
+static void pch_gbe_enable_mac_rx(struct pch_gbe_hw *hw)
+{
+	u32 rctl;
+	/* Enables Receive MAC */
+	rctl = ioread32(&hw->reg->MAC_RX_EN);
+	iowrite32((rctl | PCH_GBE_MRE_MAC_RX_EN), &hw->reg->MAC_RX_EN);
+}
+
 /**
  * pch_gbe_mac_init_rx_addrs - Initialize receive address's
  * @hw:	Pointer to the HW structure
@@ -913,7 +929,7 @@ static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
 static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
 {
 	struct pch_gbe_hw *hw = &adapter->hw;
-	u32 rdba, rdlen, rctl, rxdma;
+	u32 rdba, rdlen, rxdma;
 
 	pr_debug("dma adr = 0x%08llx  size = 0x%08x\n",
 		 (unsigned long long)adapter->rx_ring->dma,
@@ -921,9 +937,7 @@ static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
 
 	pch_gbe_mac_force_mac_fc(hw);
 
-	/* Disables Receive MAC */
-	rctl = ioread32(&hw->reg->MAC_RX_EN);
-	iowrite32((rctl & ~PCH_GBE_MRE_MAC_RX_EN), &hw->reg->MAC_RX_EN);
+	pch_gbe_disable_mac_rx(hw);
 
 	/* Disables Receive DMA */
 	rxdma = ioread32(&hw->reg->DMA_CTRL);
@@ -1355,8 +1369,8 @@ static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
 	rxdma = ioread32(&hw->reg->DMA_CTRL);
 	rxdma |= PCH_GBE_RX_DMA_EN;
 	iowrite32(rxdma, &hw->reg->DMA_CTRL);
-	/* Enables Receive */
-	iowrite32(PCH_GBE_MRE_MAC_RX_EN, &hw->reg->MAC_RX_EN);
+
+	pch_gbe_enable_mac_rx(hw);
 	return;
 }
 
-- 
1.7.1
