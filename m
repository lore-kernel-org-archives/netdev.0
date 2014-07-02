From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: systemport: update umac_enable_set to take a bitmask
Date: Tue,  1 Jul 2014 21:08:36 -0700
Message-ID: <1404274120-5717-2-git-send-email-f.fainelli@gmail.com>
References: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:59790 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaGBEJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:09:09 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so9261367qcr.2
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:09:08 -0700 (PDT)
In-Reply-To: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quite often we need to enable either the transmitter or the receiver
bits in UMAC_CMD, use umac_enable_set() to do that for us.

This is a preliminary change to introduce suspend/resume support in the
driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 141160ef249a..bbe74494c629 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1236,15 +1236,15 @@ static void bcm_sysport_set_rx_mode(struct net_device *dev)
 }
 
 static inline void umac_enable_set(struct bcm_sysport_priv *priv,
-					unsigned int enable)
+					u32 mask, unsigned int enable)
 {
 	u32 reg;
 
 	reg = umac_readl(priv, UMAC_CMD);
 	if (enable)
-		reg |= CMD_RX_EN | CMD_TX_EN;
+		reg |= mask;
 	else
-		reg &= ~(CMD_RX_EN | CMD_TX_EN);
+		reg &= ~mask;
 	umac_writel(priv, reg, UMAC_CMD);
 
 	/* UniMAC stops on a packet boundary, wait for a full-sized packet
@@ -1313,7 +1313,7 @@ static int bcm_sysport_open(struct net_device *dev)
 	topctrl_flush(priv);
 
 	/* Disable the UniMAC RX/TX */
-	umac_enable_set(priv, 0);
+	umac_enable_set(priv, CMD_RX_EN | CMD_TX_EN, 0);
 
 	/* Enable RBUF 2bytes alignment and Receive Status Block */
 	reg = rbuf_readl(priv, RBUF_CONTROL);
@@ -1398,7 +1398,7 @@ static int bcm_sysport_open(struct net_device *dev)
 	napi_enable(&priv->napi);
 
 	/* Turn on UniMAC TX/RX */
-	umac_enable_set(priv, 1);
+	umac_enable_set(priv, CMD_RX_EN | CMD_TX_EN, 1);
 
 	phy_start(priv->phydev);
 
@@ -1429,7 +1429,6 @@ static int bcm_sysport_stop(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	unsigned int i;
-	u32 reg;
 	int ret;
 
 	/* stop all software from updating hardware */
@@ -1444,9 +1443,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
 
 	/* Disable UniMAC RX */
-	reg = umac_readl(priv, UMAC_CMD);
-	reg &= ~CMD_RX_EN;
-	umac_writel(priv, reg, UMAC_CMD);
+	umac_enable_set(priv, CMD_RX_EN, 0);
 
 	ret = tdma_enable_set(priv, 0);
 	if (ret) {
@@ -1464,9 +1461,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 	}
 
 	/* Disable UniMAC TX */
-	reg = umac_readl(priv, UMAC_CMD);
-	reg &= ~CMD_TX_EN;
-	umac_writel(priv, reg, UMAC_CMD);
+	umac_enable_set(priv, CMD_TX_EN, 0);
 
 	/* Free RX/TX rings SW structures */
 	for (i = 0; i < dev->num_tx_queues; i++)
-- 
1.9.1
