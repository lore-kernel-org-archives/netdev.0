From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/7] net: phy: mdio-bcm-unimac: factor busy polling loop
Date: Mon, 31 Jul 2017 12:04:22 -0700
Message-ID: <20170731190429.24204-2-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36192 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdGaTEk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:40 -0400
Received: by mail-wm0-f65.google.com with SMTP id d40so8081328wma.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:39 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor the code that does the busy polling on the MDIO_BUSY bit since we
will have different code-paths for for completion depending on whether
we are using interrupts or polling.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 43 +++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 34395230ce70..226fdccfa1a8 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -57,10 +57,26 @@ static inline unsigned int unimac_mdio_busy(struct unimac_mdio_priv *priv)
 	return __raw_readl(priv->base + MDIO_CMD) & MDIO_START_BUSY;
 }
 
+static int unimac_mdio_poll(struct unimac_mdio_priv *priv)
+{
+	unsigned int timeout = 1000;
+
+	do {
+		if (!unimac_mdio_busy(priv))
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	if (!timeout)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
 static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 {
 	struct unimac_mdio_priv *priv = bus->priv;
-	unsigned int timeout = 1000;
 	u32 cmd;
 
 	/* Prepare the read operation */
@@ -70,15 +86,9 @@ static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 	/* Start MDIO transaction */
 	unimac_mdio_start(priv);
 
-	do {
-		if (!unimac_mdio_busy(priv))
-			break;
-
-		usleep_range(1000, 2000);
-	} while (timeout--);
-
-	if (!timeout)
-		return -ETIMEDOUT;
+	ret = unimac_mdio_poll(priv);
+	if (ret)
+		return ret;
 
 	cmd = __raw_readl(priv->base + MDIO_CMD);
 
@@ -97,7 +107,6 @@ static int unimac_mdio_write(struct mii_bus *bus, int phy_id,
 			     int reg, u16 val)
 {
 	struct unimac_mdio_priv *priv = bus->priv;
-	unsigned int timeout = 1000;
 	u32 cmd;
 
 	/* Prepare the write operation */
@@ -107,17 +116,7 @@ static int unimac_mdio_write(struct mii_bus *bus, int phy_id,
 
 	unimac_mdio_start(priv);
 
-	do {
-		if (!unimac_mdio_busy(priv))
-			break;
-
-		usleep_range(1000, 2000);
-	} while (timeout--);
-
-	if (!timeout)
-		return -ETIMEDOUT;
-
-	return 0;
+	return unimac_mdio_poll(priv);
 }
 
 /* Workaround for integrated BCM7xxx Gigabit PHYs which have a problem with
-- 
2.9.3
