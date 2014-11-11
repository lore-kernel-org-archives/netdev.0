From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: phy: bcm7xxx: add workaround for PHY revision E0 and F0
Date: Tue, 11 Nov 2014 14:55:14 -0800
Message-ID: <1415746514-11189-6-git-send-email-f.fainelli@gmail.com>
References: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50347 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbaKKWz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:55:26 -0500
Received: by mail-pa0-f47.google.com with SMTP id kx10so11447524pab.6
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:55:25 -0800 (PST)
In-Reply-To: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY revisions E0 and F0 share the same shorter workaround initialization
sequence. Dedicate a special function for these two PHY revisions to
perform the needed workaround sequence.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 0ce527744513..1b5f3c1a5093 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -162,6 +162,31 @@ static int bcm7xxx_28nm_d0_afe_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm7xxx_28nm_e0_plus_afe_config_init(struct phy_device *phydev)
+{
+	/* AFE_RXCONFIG_1, provide more margin for INL/DNL measurement */
+	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
+
+	/* AFE_VDCA_ICTRL_0, set Iq=1101 instead of 0111 for AB symmetry */
+	phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
+
+	/* AFE_HPF_TRIM_OTHERS, set 100Tx/10BT to -4.5% swing and set rCal
+	 * offset for HT=0 code
+	 */
+	phy_write_misc(phydev, AFE_HPF_TRIM_OTHERS, 0x00e3);
+
+	/* CORE_BASE1E, force trim to overwrite and set I_ext trim to 0000 */
+	phy_write(phydev, MII_BCM7XXX_CORE_BASE1E, 0x0010);
+
+	/* DSP_TAP10, adjust bias current trim (+0% swing, +0 tick) */
+	phy_write_misc(phydev, DSP_TAP10, 0x011b);
+
+	/* Reset R_CAL/RC_CAL engine */
+	r_rc_cal_reset(phydev);
+
+	return 0;
+}
+
 static int bcm7xxx_apd_enable(struct phy_device *phydev)
 {
 	int val;
@@ -225,6 +250,10 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	case 0xd0:
 		ret = bcm7xxx_28nm_d0_afe_config_init(phydev);
 		break;
+	case 0xe0:
+	case 0xf0:
+		ret = bcm7xxx_28nm_e0_plus_afe_config_init(phydev);
+		break;
 	default:
 		break;
 	}
-- 
1.9.1
