From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/2] net: phy: bcm7xxx: Plug in support for reading PHY error counters
Date: Mon, 28 Nov 2016 17:04:57 -0800
Message-ID: <20161129010457.17438-3-f.fainelli@gmail.com>
References: <20161129010457.17438-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35041 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753696AbcK2BFE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 20:05:04 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so14591588pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 17:05:03 -0800 (PST)
In-Reply-To: <20161129010457.17438-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom BCM7xxx internal PHYs can leverage the Broadcom PHY library
module PHY error counters helper functions, just implement the
appropriate PHY driver function calls to do so. We need to allocate some
storage space for our PHY statistics, and provide it to the Broadcom PHY
library, so do this in a specific probe function, and slightly wrap the
get_stats function call.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 5b3be4c67be8..fb976ab2ab92 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -45,6 +45,10 @@
 #define AFE_VDAC_OTHERS_0		MISC_ADDR(0x39, 3)
 #define AFE_HPF_TRIM_OTHERS		MISC_ADDR(0x3a, 0)
 
+struct bcm7xxx_phy_priv {
+	u64	*stats;
+};
+
 static void r_rc_cal_reset(struct phy_device *phydev)
 {
 	/* Reset R_CAL/RC_CAL Engine */
@@ -350,6 +354,32 @@ static int bcm7xxx_28nm_set_tunable(struct phy_device *phydev,
 	return genphy_restart_aneg(phydev);
 }
 
+static void bcm7xxx_28nm_get_phy_stats(struct phy_device *phydev,
+				       struct ethtool_stats *stats, u64 *data)
+{
+	struct bcm7xxx_phy_priv *priv = phydev->priv;
+
+	bcm_phy_get_stats(phydev, priv->stats, stats, data);
+}
+
+static int bcm7xxx_28nm_probe(struct phy_device *phydev)
+{
+	struct bcm7xxx_phy_priv *priv;
+
+	priv = devm_kzalloc(&phydev->mdio.dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	phydev->priv = priv;
+
+	priv->stats = devm_kzalloc(&phydev->mdio.dev,
+				   bcm_phy_get_sset_count(phydev), GFP_KERNEL);
+	if (!priv->stats)
+		return -ENOMEM;
+
+	return 0;
+}
+
 #define BCM7XXX_28NM_GPHY(_oui, _name)					\
 {									\
 	.phy_id		= (_oui),					\
@@ -364,6 +394,10 @@ static int bcm7xxx_28nm_set_tunable(struct phy_device *phydev,
 	.resume		= bcm7xxx_28nm_resume,				\
 	.get_tunable	= bcm7xxx_28nm_get_tunable,			\
 	.set_tunable	= bcm7xxx_28nm_set_tunable,			\
+	.get_sset_count	= bcm_phy_get_sset_count,			\
+	.get_strings	= bcm_phy_get_strings,				\
+	.get_stats	= bcm7xxx_28nm_get_phy_stats,			\
+	.probe		= bcm7xxx_28nm_probe,				\
 }
 
 #define BCM7XXX_40NM_EPHY(_oui, _name)					\
-- 
2.9.3
