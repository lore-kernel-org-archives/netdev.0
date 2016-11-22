From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for downshift/Wirespeed
Date: Tue, 22 Nov 2016 11:40:57 -0800
Message-ID: <20161122194058.29820-5-f.fainelli@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34556 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933861AbcKVTlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:41:13 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so1898891pfb.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:41:13 -0800 (PST)
In-Reply-To: <20161122194058.29820-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for configuring the downshift/Wirespeed enable/disable
toggles and specify a link retry value ranging from 1 to 9. Since the
integrated BCM7xxx have issues when wirespeed is enabled and EEE is also
enabled, we do disable EEE if wirespeed is enabled.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 50 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index b7789e879670..5b3be4c67be8 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -167,6 +167,7 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 {
 	u8 rev = PHY_BRCM_7XXX_REV(phydev->dev_flags);
 	u8 patch = PHY_BRCM_7XXX_PATCH(phydev->dev_flags);
+	u8 count;
 	int ret = 0;
 
 	pr_info_once("%s: %s PHY revision: 0x%02x, patch: %d\n",
@@ -199,7 +200,12 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	if (ret)
 		return ret;
 
-	ret = bcm_phy_set_eee(phydev, true);
+	ret = bcm_phy_downshift_get(phydev, &count);
+	if (ret)
+		return ret;
+
+	/* Only enable EEE if Wirespeed/downshift is disabled */
+	ret = bcm_phy_set_eee(phydev, count == DOWNSHIFT_DEV_DISABLE);
 	if (ret)
 		return ret;
 
@@ -303,6 +309,47 @@ static int bcm7xxx_suspend(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm7xxx_28nm_get_tunable(struct phy_device *phydev,
+				    struct ethtool_tunable *tuna,
+				    void *data)
+{
+	switch (tuna->id) {
+	case ETHTOOL_PHY_DOWNSHIFT:
+		return bcm_phy_downshift_get(phydev, (u8 *)data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int bcm7xxx_28nm_set_tunable(struct phy_device *phydev,
+				    struct ethtool_tunable *tuna,
+				    const void *data)
+{
+	u8 count = *(u8 *)data;
+	int ret;
+
+	switch (tuna->id) {
+	case ETHTOOL_PHY_DOWNSHIFT:
+		ret = bcm_phy_downshift_set(phydev, count);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	if (ret)
+		return ret;
+
+	/* Disable EEE advertisment since this prevents the PHY
+	 * from successfully linking up, trigger auto-negotiation restart
+	 * to let the MAC decide what to do.
+	 */
+	ret = bcm_phy_set_eee(phydev, count == DOWNSHIFT_DEV_DISABLE);
+	if (ret)
+		return ret;
+
+	return genphy_restart_aneg(phydev);
+}
+
 #define BCM7XXX_28NM_GPHY(_oui, _name)					\
 {									\
 	.phy_id		= (_oui),					\
@@ -315,6 +362,8 @@ static int bcm7xxx_suspend(struct phy_device *phydev)
 	.config_aneg	= genphy_config_aneg,				\
 	.read_status	= genphy_read_status,				\
 	.resume		= bcm7xxx_28nm_resume,				\
+	.get_tunable	= bcm7xxx_28nm_get_tunable,			\
+	.set_tunable	= bcm7xxx_28nm_set_tunable,			\
 }
 
 #define BCM7XXX_40NM_EPHY(_oui, _name)					\
-- 
2.9.3
