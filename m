From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/7] net: phy: bcm7xxx: Implement EGPHY workaround for 7278
Date: Fri, 20 Jan 2017 12:36:34 -0800
Message-ID: <20170120203634.2773-8-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34362 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbdATUgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:50 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so6039387pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:50 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the HW design team recommended workaround in for 7278. Since
the GPHY now returns its revision information in MII_PHYS_ID[23] we need
to check whether the revision provided in flags is 0 or not.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index fb11927de0ff..aa01020ab1b9 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -167,6 +167,31 @@ static int bcm7xxx_28nm_e0_plus_afe_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm7xxx_28nm_a0_patch_afe_config_init(struct phy_device *phydev)
+{
+	/* +1 RC_CAL codes for RL centering for both LT and HT conditions */
+	bcm_phy_write_misc(phydev, AFE_RXCONFIG_2, 0xd003);
+
+	/* Cut master bias current by 2% to compensate for RC_CAL offset */
+	bcm_phy_write_misc(phydev, DSP_TAP10, 0x791b);
+
+	/* Improve hybrid leakage */
+	bcm_phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x10e3);
+
+	/* Change rx_on_tune 8 to 0xf */
+	bcm_phy_write_misc(phydev, 0x21, 0x2, 0x87f6);
+
+	/* Change 100Tx EEE bandwidth */
+	bcm_phy_write_misc(phydev, 0x22, 0x2, 0x017d);
+
+	/* Enable ffe zero detection for Vitesse interoperability */
+	bcm_phy_write_misc(phydev, 0x26, 0x2, 0x0015);
+
+	r_rc_cal_reset(phydev);
+
+	return 0;
+}
+
 static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 {
 	u8 rev = PHY_BRCM_7XXX_REV(phydev->dev_flags);
@@ -174,6 +199,12 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	u8 count;
 	int ret = 0;
 
+	/* Newer devices have moved the revision information back into a
+	 * standard location in MII_PHYS_ID[23]
+	 */
+	if (rev == 0)
+		rev = phydev->phy_id & ~phydev->drv->phy_id_mask;
+
 	pr_info_once("%s: %s PHY revision: 0x%02x, patch: %d\n",
 		     phydev_name(phydev), phydev->drv->name, rev, patch);
 
@@ -197,6 +228,9 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	case 0x10:
 		ret = bcm7xxx_28nm_e0_plus_afe_config_init(phydev);
 		break;
+	case 0x01:
+		ret = bcm7xxx_28nm_a0_patch_afe_config_init(phydev);
+		break;
 	default:
 		break;
 	}
-- 
2.9.3
