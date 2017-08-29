From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] net: phy: mdio-bcm-unimac: Use correct I/O accessors
Date: Tue, 29 Aug 2017 13:35:18 -0700
Message-ID: <1504038918-49254-5-git-send-email-f.fainelli@gmail.com>
References: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:32893 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdH2UlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:41:25 -0400
Received: by mail-qk0-f195.google.com with SMTP id k126so486410qkb.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:41:25 -0700 (PDT)
In-Reply-To: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently uses __raw_{read,write}l which works for all
platforms supported: Broadcom MIPS LE/BE (native endian), ARM LE (native
endian) but not ARM BE (registers are still LE). Switch to using the
proper accessors for all platforms and explain why Broadcom MIPS BE is
special here, in doing so, we introduce a couple of helper functions to
abstract these differences.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 73c5267a11fd..08e0647b85e2 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -47,18 +47,38 @@ struct unimac_mdio_priv {
 	void			*wait_func_data;
 };
 
+static inline u32 unimac_mdio_readl(struct unimac_mdio_priv *priv, u32 offset)
+{
+	/* MIPS chips strapped for BE will automagically configure the
+	 * peripheral registers for CPU-native byte order.
+	 */
+	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
+		return __raw_readl(priv->base + offset);
+	else
+		return readl_relaxed(priv->base + offset);
+}
+
+static inline void unimac_mdio_writel(struct unimac_mdio_priv *priv, u32 val,
+				      u32 offset)
+{
+	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
+		__raw_writel(val, priv->base + offset);
+	else
+		writel_relaxed(val, priv->base + offset);
+}
+
 static inline void unimac_mdio_start(struct unimac_mdio_priv *priv)
 {
 	u32 reg;
 
-	reg = __raw_readl(priv->base + MDIO_CMD);
+	reg = unimac_mdio_readl(priv, MDIO_CMD);
 	reg |= MDIO_START_BUSY;
-	__raw_writel(reg, priv->base + MDIO_CMD);
+	unimac_mdio_writel(priv, reg, MDIO_CMD);
 }
 
 static inline unsigned int unimac_mdio_busy(struct unimac_mdio_priv *priv)
 {
-	return __raw_readl(priv->base + MDIO_CMD) & MDIO_START_BUSY;
+	return unimac_mdio_readl(priv, MDIO_CMD) & MDIO_START_BUSY;
 }
 
 static int unimac_mdio_poll(void *wait_func_data)
@@ -87,7 +107,7 @@ static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 
 	/* Prepare the read operation */
 	cmd = MDIO_RD | (phy_id << MDIO_PMD_SHIFT) | (reg << MDIO_REG_SHIFT);
-	__raw_writel(cmd, priv->base + MDIO_CMD);
+	unimac_mdio_writel(priv, cmd, MDIO_CMD);
 
 	/* Start MDIO transaction */
 	unimac_mdio_start(priv);
@@ -96,7 +116,7 @@ static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	if (ret)
 		return ret;
 
-	cmd = __raw_readl(priv->base + MDIO_CMD);
+	cmd = unimac_mdio_readl(priv, MDIO_CMD);
 
 	/* Some broken devices are known not to release the line during
 	 * turn-around, e.g: Broadcom BCM53125 external switches, so check for
@@ -118,7 +138,7 @@ static int unimac_mdio_write(struct mii_bus *bus, int phy_id,
 	/* Prepare the write operation */
 	cmd = MDIO_WR | (phy_id << MDIO_PMD_SHIFT) |
 		(reg << MDIO_REG_SHIFT) | (0xffff & val);
-	__raw_writel(cmd, priv->base + MDIO_CMD);
+	unimac_mdio_writel(priv, cmd, MDIO_CMD);
 
 	unimac_mdio_start(priv);
 
-- 
1.9.1
