From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: phy: broadcom: Allow enabling or disabling of EEE
Date: Tue, 22 Nov 2016 11:40:56 -0800
Message-ID: <20161122194058.29820-4-f.fainelli@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35046 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933859AbcKVTlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:41:12 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so2899063pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:41:12 -0800 (PST)
In-Reply-To: <20161122194058.29820-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for adding support for Wirespeed/downshift, we need to
change bcm_phy_eee_enable() to allow enabling or disabling EEE, so make
the function take an extra enable/disable boolean parameter and rename
it to illustrate it sets EEE, not necessarily just enables it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm-cygnus.c  |  2 +-
 drivers/net/phy/bcm-phy-lib.c | 14 ++++++++++----
 drivers/net/phy/bcm-phy-lib.h |  2 +-
 drivers/net/phy/bcm7xxx.c     |  2 +-
 4 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/bcm-cygnus.c b/drivers/net/phy/bcm-cygnus.c
index 49bbc6826883..196400cddf68 100644
--- a/drivers/net/phy/bcm-cygnus.c
+++ b/drivers/net/phy/bcm-cygnus.c
@@ -104,7 +104,7 @@ static int bcm_cygnus_config_init(struct phy_device *phydev)
 		return rc;
 
 	/* Advertise EEE */
-	rc = bcm_phy_enable_eee(phydev);
+	rc = bcm_phy_set_eee(phydev, true);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index d742894816f6..3156ce6d5861 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -195,7 +195,7 @@ int bcm_phy_enable_apd(struct phy_device *phydev, bool dll_pwr_down)
 }
 EXPORT_SYMBOL_GPL(bcm_phy_enable_apd);
 
-int bcm_phy_enable_eee(struct phy_device *phydev)
+int bcm_phy_set_eee(struct phy_device *phydev, bool enable)
 {
 	int val;
 
@@ -205,7 +205,10 @@ int bcm_phy_enable_eee(struct phy_device *phydev)
 	if (val < 0)
 		return val;
 
-	val |= LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X;
+	if (enable)
+		val |= LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X;
+	else
+		val &= ~(LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X);
 
 	phy_write_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
 			       MDIO_MMD_AN, (u32)val);
@@ -216,14 +219,17 @@ int bcm_phy_enable_eee(struct phy_device *phydev)
 	if (val < 0)
 		return val;
 
-	val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
+	if (enable)
+		val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
+	else
+		val &= ~(MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
 
 	phy_write_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
 			       MDIO_MMD_AN, (u32)val);
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(bcm_phy_enable_eee);
+EXPORT_SYMBOL_GPL(bcm_phy_set_eee);
 
 int bcm_phy_downshift_get(struct phy_device *phydev, u8 *count)
 {
diff --git a/drivers/net/phy/bcm-phy-lib.h b/drivers/net/phy/bcm-phy-lib.h
index 3f492e629094..a117f657c6d7 100644
--- a/drivers/net/phy/bcm-phy-lib.h
+++ b/drivers/net/phy/bcm-phy-lib.h
@@ -36,7 +36,7 @@ int bcm_phy_config_intr(struct phy_device *phydev);
 
 int bcm_phy_enable_apd(struct phy_device *phydev, bool dll_pwr_down);
 
-int bcm_phy_enable_eee(struct phy_device *phydev);
+int bcm_phy_set_eee(struct phy_device *phydev, bool enable);
 
 int bcm_phy_downshift_get(struct phy_device *phydev, u8 *count);
 
diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 9636da0b6efc..b7789e879670 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -199,7 +199,7 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	if (ret)
 		return ret;
 
-	ret = bcm_phy_enable_eee(phydev);
+	ret = bcm_phy_set_eee(phydev, true);
 	if (ret)
 		return ret;
 
-- 
2.9.3
