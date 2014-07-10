From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 02/11] net: bcmgenet: add umac_enable_set helper
Date: Thu, 10 Jul 2014 15:46:15 -0700
Message-ID: <1405032384-24006-3-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33491 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbaGJWqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:30 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so233479ier.6
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:29 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor the code touching the UniMAC RX/TX enable bits since we are going
to re-use it for implementing suspend/resume.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 37 +++++++++++++++++---------
 1 file changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index cece54e68b88..ae5a0c50e6ca 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1444,6 +1444,25 @@ static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
 	}
 }
 
+static void umac_enable_set(struct bcmgenet_priv *priv, u32 mask,
+				unsigned int enable)
+{
+	u32 reg;
+
+	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
+	if (enable)
+		reg |= mask;
+	else
+		reg &= ~mask;
+	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+
+	/* UniMAC stops on a packet boundary, wait for a full-size packet
+	 * to be processed
+	 */
+	if (enable == 0)
+		usleep_range(1000, 2000);
+}
+
 static int reset_umac(struct bcmgenet_priv *priv)
 {
 	struct device *kdev = &priv->pdev->dev;
@@ -1995,9 +2014,7 @@ static int bcmgenet_open(struct net_device *dev)
 		goto err_clk_disable;
 
 	/* disable ethernet MAC while updating its registers */
-	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
-	reg &= ~(CMD_TX_EN | CMD_RX_EN);
-	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, 0);
 
 	bcmgenet_set_hw_addr(priv, dev->dev_addr);
 
@@ -2043,11 +2060,10 @@ static int bcmgenet_open(struct net_device *dev)
 	/* Start the network engine */
 	napi_enable(&priv->napi);
 
-	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
-	reg |= (CMD_TX_EN | CMD_RX_EN);
-	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, 1);
 
 	/* Make sure we reflect the value of CRC_CMD_FWD */
+	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
 	priv->crc_fwd_en = !!(reg & CMD_CRC_FWD);
 
 	device_set_wakeup_capable(&dev->dev, 1);
@@ -2128,16 +2144,13 @@ static int bcmgenet_close(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	int ret;
-	u32 reg;
 
 	netif_dbg(priv, ifdown, dev, "bcmgenet_close\n");
 
 	phy_stop(priv->phydev);
 
 	/* Disable MAC receive */
-	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
-	reg &= ~CMD_RX_EN;
-	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+	umac_enable_set(priv, CMD_RX_EN, 0);
 
 	netif_tx_stop_all_queues(dev);
 
@@ -2146,9 +2159,7 @@ static int bcmgenet_close(struct net_device *dev)
 		return ret;
 
 	/* Disable MAC transmit. TX DMA disabled have to done before this */
-	reg = bcmgenet_umac_readl(priv, UMAC_CMD);
-	reg &= ~CMD_TX_EN;
-	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
+	umac_enable_set(priv, CMD_TX_EN, 0);
 
 	napi_disable(&priv->napi);
 
-- 
1.9.1
