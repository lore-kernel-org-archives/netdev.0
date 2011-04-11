From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/3] stmmac: fix open funct when exit on error
Date: Mon, 11 Apr 2011 11:16:45 +0200
Message-ID: <1302513406-3758-2-git-send-email-peppe.cavallaro@st.com>
References: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Shiraz Hashim <shiraz.hashim@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:55421 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753907Ab1DKJRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 05:17:08 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C934014E
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 09:17:02 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1EC421A79
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 09:17:02 +0000 (GMT)
In-Reply-To: <1302513406-3758-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reviews the open function and fixes some
errors when exit with an error state.
It also moves the request_irq after core is initialized
when interrupts are properly masked.

Signed-off-by: Shiraz Hashim <shiraz.hashim@st.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |   48 ++++++++++++++++++++++---------------
 1 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 62fa51e..442a7ca 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -780,21 +780,6 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_verify_args();
 
-	ret = stmmac_init_phy(dev);
-	if (unlikely(ret)) {
-		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
-		return ret;
-	}
-
-	/* Request the IRQ lines */
-	ret = request_irq(dev->irq, stmmac_interrupt,
-			  IRQF_SHARED, dev->name, dev);
-	if (unlikely(ret < 0)) {
-		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
-		       __func__, dev->irq, ret);
-		return ret;
-	}
-
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
 	if (unlikely(priv->tm == NULL)) {
@@ -813,6 +798,11 @@ static int stmmac_open(struct net_device *dev)
 	} else
 		priv->tm->enable = 1;
 #endif
+	ret = stmmac_init_phy(dev);
+	if (unlikely(ret)) {
+		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
+		goto open_error;
+	}
 
 	/* Create and initialize the TX/RX descriptors chains. */
 	priv->dma_tx_size = STMMAC_ALIGN(dma_txsize);
@@ -821,12 +811,11 @@ static int stmmac_open(struct net_device *dev)
 	init_dma_desc_rings(dev);
 
 	/* DMA initialization and SW reset */
-	if (unlikely(priv->hw->dma->init(priv->ioaddr, priv->plat->pbl,
-					 priv->dma_tx_phy,
-					 priv->dma_rx_phy) < 0)) {
-
+	ret = priv->hw->dma->init(priv->ioaddr, priv->plat->pbl,
+				  priv->dma_tx_phy, priv->dma_rx_phy);
+	if (ret < 0) {
 		pr_err("%s: DMA initialization failed\n", __func__);
-		return -1;
+		goto open_error;
 	}
 
 	/* Copy the MAC addr into the HW  */
@@ -848,6 +837,15 @@ static int stmmac_open(struct net_device *dev)
 	writel(0xffffffff, priv->ioaddr + MMC_HIGH_INTR_MASK);
 	writel(0xffffffff, priv->ioaddr + MMC_LOW_INTR_MASK);
 
+	/* Request the IRQ lines */
+	ret = request_irq(dev->irq, stmmac_interrupt,
+			 IRQF_SHARED, dev->name, dev);
+	if (unlikely(ret < 0)) {
+		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
+		       __func__, dev->irq, ret);
+		goto open_error;
+	}
+
 	/* Enable the MAC Rx/Tx */
 	stmmac_enable_mac(priv->ioaddr);
 
@@ -878,7 +876,17 @@ static int stmmac_open(struct net_device *dev)
 	napi_enable(&priv->napi);
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
+
 	return 0;
+
+open_error:
+#ifdef CONFIG_STMMAC_TIMER
+	kfree(priv->tm);
+#endif
+	if (priv->phydev)
+		phy_disconnect(priv->phydev);
+
+	return ret;
 }
 
 /**
-- 
1.7.4.2

