From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 4/8] net: stmicro: mtl rx queue enabled as dcb or avb
Date: Wed,  8 Mar 2017 12:22:44 +0000
Message-ID: <0f8fea4d282b01ddb1f8f05c87112d4499d8d7b2.1488975090.git.jpinto@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:37801 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753283AbdCHORI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 09:17:08 -0500
In-Reply-To: <cover.1488975090.git.jpinto@synopsys.com>
In-Reply-To: <cover.1488975090.git.jpinto@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the enabling of RX queues as DCB or as AVB based
on configuration.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c |  8 ++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 17 ++++++-----------
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index a25b2f8..ad89c47 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -454,7 +454,7 @@ struct stmmac_ops {
 	/* Enable and verify that the IPC module is supported */
 	int (*rx_ipc)(struct mac_device_info *hw);
 	/* Enable RX Queues */
-	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
+	void (*rx_queue_enable)(struct mac_device_info *hw, u8 mode, u32 queue);
 	/* Program RX Algorithms */
 	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
 	/* Program TX Algorithms */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index ccbfa31..deae508 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -59,13 +59,17 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 	writel(value, ioaddr + GMAC_INT_EN);
 }
 
-static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
+static void dwmac4_rx_queue_enable(struct mac_device_info *hw,
+				   u8 mode, u32 queue)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
 
 	value &= GMAC_RX_QUEUE_CLEAR(queue);
-	value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
+	if (mode == MTL_RX_AVB)
+		value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
+	else if (mode == MTL_RX_DCB)
+		value |= GMAC_RX_DCB_QUEUE_ENABLE(queue);
 
 	writel(value, ioaddr + GMAC_RXQ_CTRL0);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index df3b1ee..26be9f3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1256,19 +1256,14 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
  */
 static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
 {
-	int rx_count = priv->dma_cap.number_rx_queues;
+	u32 rx_queues_count = priv->plat->rx_queues_to_use;
 	int queue = 0;
+	u8 mode = 0;
 
-	/* If GMAC does not have multiple queues, then this is not necessary*/
-	if (rx_count == 1)
-		return;
-
-	/**
-	 *  If the core is synthesized with multiple rx queues / multiple
-	 *  dma channels, then rx queues will be disabled by default.
-	 *  For now only rx queue 0 is enabled.
-	 */
-	priv->hw->mac->rx_queue_enable(priv->hw, queue);
+	for (queue = 0; queue < rx_queues_count; queue++) {
+		mode = priv->plat->rx_queues_cfg[queue].mode_to_use;
+		priv->hw->mac->rx_queue_enable(priv->hw, mode, queue);
+	}
 }
 
 /**
-- 
2.9.3
