From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: bcm_sf2: move GPHY enabling to its own function
Date: Thu,  5 Feb 2015 11:40:41 -0800
Message-ID: <1423165242-6042-2-git-send-email-f.fainelli@gmail.com>
References: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49511 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077AbbBETkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:40:55 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so11996299pab.3
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:40:54 -0800 (PST)
In-Reply-To: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the code that touches the single GPHY register from
bcm_sf2_sw_resume() to a separate function since we will have to
enable/disable the GPHY from different locations, and we want the code
to be self-contained.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 09f6b3cc1f66..45c0e2b97f5f 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -233,6 +233,24 @@ static void bcm_sf2_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
 	core_writel(priv, reg, CORE_EEE_EN_CTRL);
 }
 
+static void bcm_sf2_gphy_enable_set(struct dsa_switch *ds, bool enable)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u32 reg;
+
+	if (!enable)
+		return;
+
+	reg = reg_readl(priv, REG_SPHY_CNTRL);
+	reg |= PHY_RESET;
+	reg &= ~(EXT_PWR_DOWN | IDDQ_BIAS);
+	reg_writel(priv, reg, REG_SPHY_CNTRL);
+	udelay(21);
+	reg = reg_readl(priv, REG_SPHY_CNTRL);
+	reg &= ~PHY_RESET;
+	reg_writel(priv, reg, REG_SPHY_CNTRL);
+}
+
 static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
@@ -771,7 +789,6 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	unsigned int port;
-	u32 reg;
 	int ret;
 
 	ret = bcm_sf2_sw_rst(priv);
@@ -780,17 +797,8 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 		return ret;
 	}
 
-	/* Reinitialize the single GPHY */
-	if (priv->hw_params.num_gphy == 1) {
-		reg = reg_readl(priv, REG_SPHY_CNTRL);
-		reg |= PHY_RESET;
-		reg &= ~(EXT_PWR_DOWN | IDDQ_BIAS);
-		reg_writel(priv, reg, REG_SPHY_CNTRL);
-		udelay(21);
-		reg = reg_readl(priv, REG_SPHY_CNTRL);
-		reg &= ~PHY_RESET;
-		reg_writel(priv, reg, REG_SPHY_CNTRL);
-	}
+	if (priv->hw_params.num_gphy == 1)
+		bcm_sf2_gphy_enable_set(ds, true);
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if ((1 << port) & ds->phys_port_mask)
-- 
2.1.0
