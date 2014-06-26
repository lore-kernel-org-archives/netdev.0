From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 2/3] net: systemport: fix UniMAC reset logic
Date: Thu, 26 Jun 2014 10:06:45 -0700
Message-ID: <1403802406-10992-3-git-send-email-f.fainelli@gmail.com>
References: <1403802406-10992-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:43916 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633AbaFZRH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:07:27 -0400
Received: by mail-pb0-f42.google.com with SMTP id ma3so3398661pbc.15
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:07:27 -0700 (PDT)
In-Reply-To: <1403802406-10992-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UniMAC CMD_SW_RESET bit is not a self-clearing bit, so we need to
assert it, wait a bit and clear it manually. As a result, umac_reset()
is updated not to return any value. The previous version of the code
simply wrote 0 to the CMD register, which would make the busy-waiting
loop exit immediately, having zero effect.

By writing 0 to the CMD register, we were clearing all bits in the CMD
register, and not using the hardware reset default values which are
set on purpose.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- clarify the commit message and make it accurate with what the code
  did before

 drivers/net/ethernet/broadcom/bcmsysport.c | 33 ++++++++----------------------
 1 file changed, 9 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index f6bccd847ee6..d31f7d239064 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1254,28 +1254,17 @@ static inline void umac_enable_set(struct bcm_sysport_priv *priv,
 		usleep_range(1000, 2000);
 }
 
-static inline int umac_reset(struct bcm_sysport_priv *priv)
+static inline void umac_reset(struct bcm_sysport_priv *priv)
 {
-	unsigned int timeout = 0;
 	u32 reg;
-	int ret = 0;
-
-	umac_writel(priv, 0, UMAC_CMD);
-	while (timeout++ < 1000) {
-		reg = umac_readl(priv, UMAC_CMD);
-		if (!(reg & CMD_SW_RESET))
-			break;
-
-		udelay(1);
-	}
-
-	if (timeout == 1000) {
-		dev_err(&priv->pdev->dev,
-			"timeout waiting for MAC to come out of reset\n");
-		ret = -ETIMEDOUT;
-	}
 
-	return ret;
+	reg = umac_readl(priv, UMAC_CMD);
+	reg |= CMD_SW_RESET;
+	umac_writel(priv, reg, UMAC_CMD);
+	udelay(10);
+	reg = umac_readl(priv, UMAC_CMD);
+	reg &= ~CMD_SW_RESET;
+	umac_writel(priv, reg, UMAC_CMD);
 }
 
 static void umac_set_hw_addr(struct bcm_sysport_priv *priv,
@@ -1303,11 +1292,7 @@ static int bcm_sysport_open(struct net_device *dev)
 	int ret;
 
 	/* Reset UniMAC */
-	ret = umac_reset(priv);
-	if (ret) {
-		netdev_err(dev, "UniMAC reset failed\n");
-		return ret;
-	}
+	umac_reset(priv);
 
 	/* Flush TX and RX FIFOs at TOPCTRL level */
 	topctrl_flush(priv);
-- 
1.9.1
