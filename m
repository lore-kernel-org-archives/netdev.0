From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: phy: bcm7xxx: add PHY revision D0 workaround sequence
Date: Tue, 11 Nov 2014 14:55:13 -0800
Message-ID: <1415746514-11189-5-git-send-email-f.fainelli@gmail.com>
References: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57318 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbaKKWzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:55:25 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so11611224pab.10
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:55:24 -0800 (PST)
In-Reply-To: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY revision D0 requires a specific workaround sequence which needs to
be applied to get the HW to behave properly in all corner cases
conditions. Do this based on the revision we just read out of the HW
using a specific function.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 82824dde7f5f..0ce527744513 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -39,8 +39,11 @@
 
 #define AFE_RXCONFIG_0			MISC_ADDR(0x38, 0)
 #define AFE_RXCONFIG_1			MISC_ADDR(0x38, 1)
+#define AFE_RXCONFIG_2			MISC_ADDR(0x38, 2)
 #define AFE_RX_LP_COUNTER		MISC_ADDR(0x38, 3)
 #define AFE_TX_CONFIG			MISC_ADDR(0x39, 0)
+#define AFE_VDCA_ICTRL_0		MISC_ADDR(0x39, 1)
+#define AFE_VDAC_OTHERS_0		MISC_ADDR(0x39, 3)
 #define AFE_HPF_TRIM_OTHERS		MISC_ADDR(0x3a, 0)
 
 #define CORE_EXPB0			0xb0
@@ -119,6 +122,46 @@ static int bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm7xxx_28nm_d0_afe_config_init(struct phy_device *phydev)
+{
+	/* AFE_RXCONFIG_0 */
+	phy_write_misc(phydev, AFE_RXCONFIG_0, 0xeb15);
+
+	/* AFE_RXCONFIG_1 */
+	phy_write_misc(phydev, AFE_RXCONFIG_1, 0x9b2f);
+
+	/* AFE_RXCONFIG_2, set rCal offset for HT=0 code and LT=-2 code */
+	phy_write_misc(phydev, AFE_RXCONFIG_2, 0x2003);
+
+	/* AFE_RX_LP_COUNTER, set RX bandwidth to maximum */
+	phy_write_misc(phydev, AFE_RX_LP_COUNTER, 0x7fc0);
+
+	/* AFE_TX_CONFIG, set 1000BT Cfeed=110 for all ports */
+	phy_write_misc(phydev, AFE_TX_CONFIG, 0x0061);
+
+	/* AFE_VDCA_ICTRL_0, set Iq=1101 instead of 0111 for AB symmetry */
+	phy_write_misc(phydev, AFE_VDCA_ICTRL_0, 0xa7da);
+
+	/* AFE_VDAC_OTHERS_0, set 1000BT Cidac=010 for all ports */
+	phy_write_misc(phydev, AFE_VDAC_OTHERS_0, 0xa020);
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
@@ -179,6 +222,9 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	case 0xb0:
 		ret = bcm7xxx_28nm_b0_afe_config_init(phydev);
 		break;
+	case 0xd0:
+		ret = bcm7xxx_28nm_d0_afe_config_init(phydev);
+		break;
 	default:
 		break;
 	}
-- 
1.9.1
