From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH net-next 01/13] stmmac: rework get_hw_feature function
Date: Fri, 1 Apr 2016 11:37:25 +0200
Message-ID: <1459503457-22569-2-git-send-email-alexandre.torgue@st.com>
References: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:43885 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753712AbcDAJhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:37:55 -0400
In-Reply-To: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On next GMAC IP generation (4.xx), the way to get hw feature
is not the same than on previous 3.xx. As it is hardware
dependent, the way to get hw capabilities should be defined in dma ops of
each MAC IP. It will avoid also a huge computation of hw capabilities in
stmmac_main.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index f96d257..797a913 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -412,7 +412,8 @@ struct stmmac_dma_ops {
 	int (*dma_interrupt) (void __iomem *ioaddr,
 			      struct stmmac_extra_stats *x);
 	/* If supported then get the optional core features */
-	unsigned int (*get_hw_feature) (void __iomem *ioaddr);
+	void (*get_hw_feature)(void __iomem *ioaddr,
+			       struct dma_features *dma_cap);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog) (void __iomem *ioaddr, u32 riwt);
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index da32d60..99074695 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -215,9 +215,40 @@ static void dwmac1000_dump_dma_regs(void __iomem *ioaddr)
 	}
 }
 
-static unsigned int dwmac1000_get_hw_feature(void __iomem *ioaddr)
+static void dwmac1000_get_hw_feature(void __iomem *ioaddr,
+				     struct dma_features *dma_cap)
 {
-	return readl(ioaddr + DMA_HW_FEATURE);
+	u32 hw_cap = readl(ioaddr + DMA_HW_FEATURE);
+
+	dma_cap->mbps_10_100 = (hw_cap & DMA_HW_FEAT_MIISEL);
+	dma_cap->mbps_1000 = (hw_cap & DMA_HW_FEAT_GMIISEL) >> 1;
+	dma_cap->half_duplex = (hw_cap & DMA_HW_FEAT_HDSEL) >> 2;
+	dma_cap->hash_filter = (hw_cap & DMA_HW_FEAT_HASHSEL) >> 4;
+	dma_cap->multi_addr = (hw_cap & DMA_HW_FEAT_ADDMAC) >> 5;
+	dma_cap->pcs = (hw_cap & DMA_HW_FEAT_PCSSEL) >> 6;
+	dma_cap->sma_mdio = (hw_cap & DMA_HW_FEAT_SMASEL) >> 8;
+	dma_cap->pmt_remote_wake_up = (hw_cap & DMA_HW_FEAT_RWKSEL) >> 9;
+	dma_cap->pmt_magic_frame = (hw_cap & DMA_HW_FEAT_MGKSEL) >> 10;
+	/* MMC */
+	dma_cap->rmon = (hw_cap & DMA_HW_FEAT_MMCSEL) >> 11;
+	/* IEEE 1588-2002 */
+	dma_cap->time_stamp =
+	    (hw_cap & DMA_HW_FEAT_TSVER1SEL) >> 12;
+	/* IEEE 1588-2008 */
+	dma_cap->atime_stamp = (hw_cap & DMA_HW_FEAT_TSVER2SEL) >> 13;
+	/* 802.3az - Energy-Efficient Ethernet (EEE) */
+	dma_cap->eee = (hw_cap & DMA_HW_FEAT_EEESEL) >> 14;
+	dma_cap->av = (hw_cap & DMA_HW_FEAT_AVSEL) >> 15;
+	/* TX and RX csum */
+	dma_cap->tx_coe = (hw_cap & DMA_HW_FEAT_TXCOESEL) >> 16;
+	dma_cap->rx_coe_type1 = (hw_cap & DMA_HW_FEAT_RXTYP1COE) >> 17;
+	dma_cap->rx_coe_type2 = (hw_cap & DMA_HW_FEAT_RXTYP2COE) >> 18;
+	dma_cap->rxfifo_over_2048 = (hw_cap & DMA_HW_FEAT_RXFIFOSIZE) >> 19;
+	/* TX and RX number of channels */
+	dma_cap->number_rx_channel = (hw_cap & DMA_HW_FEAT_RXCHCNT) >> 20;
+	dma_cap->number_tx_channel = (hw_cap & DMA_HW_FEAT_TXCHCNT) >> 22;
+	/* Alternate (enhanced) DESC mode */
+	dma_cap->enh_desc = (hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
 }
 
 static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4c5ce98..d3ebfea 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1558,51 +1558,15 @@ static void stmmac_selec_desc_mode(struct stmmac_priv *priv)
  */
 static int stmmac_get_hw_features(struct stmmac_priv *priv)
 {
-	u32 hw_cap = 0;
+	u32 ret = 0;
 
 	if (priv->hw->dma->get_hw_feature) {
-		hw_cap = priv->hw->dma->get_hw_feature(priv->ioaddr);
-
-		priv->dma_cap.mbps_10_100 = (hw_cap & DMA_HW_FEAT_MIISEL);
-		priv->dma_cap.mbps_1000 = (hw_cap & DMA_HW_FEAT_GMIISEL) >> 1;
-		priv->dma_cap.half_duplex = (hw_cap & DMA_HW_FEAT_HDSEL) >> 2;
-		priv->dma_cap.hash_filter = (hw_cap & DMA_HW_FEAT_HASHSEL) >> 4;
-		priv->dma_cap.multi_addr = (hw_cap & DMA_HW_FEAT_ADDMAC) >> 5;
-		priv->dma_cap.pcs = (hw_cap & DMA_HW_FEAT_PCSSEL) >> 6;
-		priv->dma_cap.sma_mdio = (hw_cap & DMA_HW_FEAT_SMASEL) >> 8;
-		priv->dma_cap.pmt_remote_wake_up =
-		    (hw_cap & DMA_HW_FEAT_RWKSEL) >> 9;
-		priv->dma_cap.pmt_magic_frame =
-		    (hw_cap & DMA_HW_FEAT_MGKSEL) >> 10;
-		/* MMC */
-		priv->dma_cap.rmon = (hw_cap & DMA_HW_FEAT_MMCSEL) >> 11;
-		/* IEEE 1588-2002 */
-		priv->dma_cap.time_stamp =
-		    (hw_cap & DMA_HW_FEAT_TSVER1SEL) >> 12;
-		/* IEEE 1588-2008 */
-		priv->dma_cap.atime_stamp =
-		    (hw_cap & DMA_HW_FEAT_TSVER2SEL) >> 13;
-		/* 802.3az - Energy-Efficient Ethernet (EEE) */
-		priv->dma_cap.eee = (hw_cap & DMA_HW_FEAT_EEESEL) >> 14;
-		priv->dma_cap.av = (hw_cap & DMA_HW_FEAT_AVSEL) >> 15;
-		/* TX and RX csum */
-		priv->dma_cap.tx_coe = (hw_cap & DMA_HW_FEAT_TXCOESEL) >> 16;
-		priv->dma_cap.rx_coe_type1 =
-		    (hw_cap & DMA_HW_FEAT_RXTYP1COE) >> 17;
-		priv->dma_cap.rx_coe_type2 =
-		    (hw_cap & DMA_HW_FEAT_RXTYP2COE) >> 18;
-		priv->dma_cap.rxfifo_over_2048 =
-		    (hw_cap & DMA_HW_FEAT_RXFIFOSIZE) >> 19;
-		/* TX and RX number of channels */
-		priv->dma_cap.number_rx_channel =
-		    (hw_cap & DMA_HW_FEAT_RXCHCNT) >> 20;
-		priv->dma_cap.number_tx_channel =
-		    (hw_cap & DMA_HW_FEAT_TXCHCNT) >> 22;
-		/* Alternate (enhanced) DESC mode */
-		priv->dma_cap.enh_desc = (hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
-	}
-
-	return hw_cap;
+		priv->hw->dma->get_hw_feature(priv->ioaddr,
+					      &priv->dma_cap);
+		ret = 1;
+	}
+
+	return ret;
 }
 
 /**
-- 
1.9.1
