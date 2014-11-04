From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 5/5] stmmac: fix atomicity in pm routines
Date: Tue, 4 Nov 2014 17:08:09 +0100
Message-ID: <1415117289-7733-6-git-send-email-peppe.cavallaro@st.com>
References: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Hao Liang <hliang1025@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47618 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbaKDQUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:20:07 -0500
In-Reply-To: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the atomicity when suspend and resume the
driver. The clk api have been changed (as reported by Hao Liang)
and the skb allocation is done out of the hw setup function and
taking care about the GFP flags.

Reported-by: Hao Liang <hliang1025@gmail.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>
Cc: Hao Liang <hliang1025@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   29 +++++++++++---------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 9c79bf2..18c46bb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -964,12 +964,12 @@ static void stmmac_clear_descriptors(struct stmmac_priv *priv)
 }
 
 static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
-				  int i)
+				  int i, gfp_t flags)
 {
 	struct sk_buff *skb;
 
 	skb = __netdev_alloc_skb(priv->dev, priv->dma_buf_sz + NET_IP_ALIGN,
-				 GFP_KERNEL);
+				 flags);
 	if (!skb) {
 		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
 		return -ENOMEM;
@@ -1011,7 +1011,7 @@ static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
  * and allocates the socket buffers. It suppors the chained and ring
  * modes.
  */
-static int init_dma_desc_rings(struct net_device *dev)
+static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 {
 	int i;
 	struct stmmac_priv *priv = netdev_priv(dev);
@@ -1046,7 +1046,7 @@ static int init_dma_desc_rings(struct net_device *dev)
 		else
 			p = priv->dma_rx + i;
 
-		ret = stmmac_init_rx_buffers(priv, p, i);
+		ret = stmmac_init_rx_buffers(priv, p, i, flags);
 		if (ret)
 			goto err_init_rx_buffers;
 
@@ -1652,11 +1652,6 @@ static int stmmac_hw_setup(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
-	ret = init_dma_desc_rings(dev);
-	if (ret < 0) {
-		pr_err("%s: DMA descriptors initialization failed\n", __func__);
-		return ret;
-	}
 	/* DMA initialization and SW reset */
 	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
@@ -1710,8 +1705,6 @@ static int stmmac_hw_setup(struct net_device *dev)
 	}
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
 
-	stmmac_init_tx_coalesce(priv);
-
 	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
 		priv->rx_riwt = MAX_DMA_RIWT;
 		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
@@ -1764,12 +1757,20 @@ static int stmmac_open(struct net_device *dev)
 		goto dma_desc_error;
 	}
 
+	ret = init_dma_desc_rings(dev, GFP_KERNEL);
+	if (ret < 0) {
+		pr_err("%s: DMA descriptors initialization failed\n", __func__);
+		goto init_error;
+	}
+
 	ret = stmmac_hw_setup(dev);
 	if (ret < 0) {
 		pr_err("%s: Hw setup failed\n", __func__);
 		goto init_error;
 	}
 
+	stmmac_init_tx_coalesce(priv);
+
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
@@ -2953,7 +2954,7 @@ int stmmac_suspend(struct net_device *ndev)
 		stmmac_set_mac(priv->ioaddr, false);
 		pinctrl_pm_select_sleep_state(priv->device);
 		/* Disable clock in case of PWM is off */
-		clk_disable_unprepare(priv->stmmac_clk);
+		clk_disable(priv->stmmac_clk);
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -2985,7 +2986,7 @@ int stmmac_resume(struct net_device *ndev)
 	} else {
 		pinctrl_pm_select_default_state(priv->device);
 		/* enable the clk prevously disabled */
-		clk_prepare_enable(priv->stmmac_clk);
+		clk_enable(priv->stmmac_clk);
 		/* reset the phy so that it's ready */
 		if (priv->mii)
 			stmmac_mdio_reset(priv->mii);
@@ -2993,7 +2994,9 @@ int stmmac_resume(struct net_device *ndev)
 
 	netif_device_attach(ndev);
 
+	init_dma_desc_rings(ndev, GFP_ATOMIC);
 	stmmac_hw_setup(ndev);
+	stmmac_init_tx_coalesce(priv);
 
 	napi_enable(&priv->napi);
 
-- 
1.7.4.4
