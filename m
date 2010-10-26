From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] stmmac: enable/disable rx/tx in the core with a single write.
Date: Tue, 26 Oct 2010 06:58:14 +0200
Message-ID: <1288069094-25365-1-git-send-email-peppe.cavallaro@st.com>
Cc: avisconti <armando.visconti@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:58768 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751088Ab0JZE60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 00:58:26 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 878F667
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 04:58:22 +0000 (GMT)
Received: from mail1.ctn.st.com (mail1.ctn.st.com [164.130.116.128])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 50266131E
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 04:58:22 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: avisconti <armando.visconti@st.com>

This patch enables and disables the rx and tx bits in the MAC control reg
by using a single write operation.
This also solves a possible problem (spotted on SPEAr platforms) at 10Mbps
where two consecutive writes to a MAC control register can take more than
4 phy_clk cycles.

Signed-off-by: Armando Visconti <armando.visconti@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |   40 +++++++++----------------------------
 1 files changed, 10 insertions(+), 30 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 823b9e6..06bc603 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -337,33 +337,19 @@ static int stmmac_init_phy(struct net_device *dev)
 	return 0;
 }
 
-static inline void stmmac_mac_enable_rx(void __iomem *ioaddr)
+static inline void stmmac_enable_mac(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
-	value |= MAC_RNABLE_RX;
-	/* Set the RE (receive enable bit into the MAC CTRL register).  */
-	writel(value, ioaddr + MAC_CTRL_REG);
-}
 
-static inline void stmmac_mac_enable_tx(void __iomem *ioaddr)
-{
-	u32 value = readl(ioaddr + MAC_CTRL_REG);
-	value |= MAC_ENABLE_TX;
-	/* Set the TE (transmit enable bit into the MAC CTRL register).  */
+	value |= MAC_RNABLE_RX | MAC_ENABLE_TX;
 	writel(value, ioaddr + MAC_CTRL_REG);
 }
 
-static inline void stmmac_mac_disable_rx(void __iomem *ioaddr)
+static inline void stmmac_disable_mac(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
-	value &= ~MAC_RNABLE_RX;
-	writel(value, ioaddr + MAC_CTRL_REG);
-}
 
-static inline void stmmac_mac_disable_tx(void __iomem *ioaddr)
-{
-	u32 value = readl(ioaddr + MAC_CTRL_REG);
-	value &= ~MAC_ENABLE_TX;
+	value &= ~(MAC_ENABLE_TX | MAC_RNABLE_RX);
 	writel(value, ioaddr + MAC_CTRL_REG);
 }
 
@@ -857,8 +843,7 @@ static int stmmac_open(struct net_device *dev)
 	writel(0xffffffff, priv->ioaddr + MMC_LOW_INTR_MASK);
 
 	/* Enable the MAC Rx/Tx */
-	stmmac_mac_enable_rx(priv->ioaddr);
-	stmmac_mac_enable_tx(priv->ioaddr);
+	stmmac_enable_mac(priv->ioaddr);
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
@@ -928,9 +913,8 @@ static int stmmac_release(struct net_device *dev)
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
 
-	/* Disable the MAC core */
-	stmmac_mac_disable_tx(priv->ioaddr);
-	stmmac_mac_disable_rx(priv->ioaddr);
+	/* Disable the MAC Rx/Tx */
+	stmmac_disable_mac(priv->ioaddr);
 
 	netif_carrier_off(dev);
 
@@ -1787,8 +1771,7 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
-	stmmac_mac_disable_rx(priv->ioaddr);
-	stmmac_mac_disable_tx(priv->ioaddr);
+	stmmac_disable_mac(priv->ioaddr);
 
 	netif_carrier_off(ndev);
 
@@ -1839,13 +1822,11 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 					     dis_ic);
 		priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 
-		stmmac_mac_disable_tx(priv->ioaddr);
-
 		/* Enable Power down mode by programming the PMT regs */
 		if (device_can_wakeup(priv->device))
 			priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
 		else
-			stmmac_mac_disable_rx(priv->ioaddr);
+			stmmac_disable_mac(priv->ioaddr);
 	} else {
 		priv->shutdown = 1;
 		/* Although this can appear slightly redundant it actually
@@ -1886,8 +1867,7 @@ static int stmmac_resume(struct platform_device *pdev)
 	netif_device_attach(dev);
 
 	/* Enable the MAC and DMA */
-	stmmac_mac_enable_rx(priv->ioaddr);
-	stmmac_mac_enable_tx(priv->ioaddr);
+	stmmac_enable_mac(priv->ioaddr);
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
-- 
1.5.5.6

