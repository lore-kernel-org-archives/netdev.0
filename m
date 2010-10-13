From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] via-velocity: forced 1000 Mbps mode support.
Date: Wed, 13 Oct 2010 21:26:05 +0200
Message-ID: <20101013192605.GA5157@electric-eye.fr.zoreil.com>
References: <AANLkTinn8UQfOoPgf=13jfvD5Ld6p4GhT7jpyYmXKT9X@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn,
	ShirleyHu@viatech.com.cn, AndersMa@viatech.com.cn,
	"David S. Miller" <davem@davemloft.net>,
	Seguier Regis <rseguier@e-teleport.net>
To: David Lv <davidlv.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-139-115-126.adslgp.cegetel.net ([88.139.115.126]:33706 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752309Ab0JMT0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 15:26:46 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinn8UQfOoPgf=13jfvD5Ld6p4GhT7jpyYmXKT9X@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Full duplex only. Half duplex 1000 Mbps is not supported.

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Seguier Regis <rseguier@e-teleport.net>

---
 David (Lv), your mail agent apparently wrapped some more-than-80-columns lines
 in the patch, thus making it unusable. I fixed it.

 drivers/net/via-velocity.c |   82 ++++++++++++++++++++++++++++++++++++++++---
 drivers/net/via-velocity.h |    5 ++-
 2 files changed, 79 insertions(+), 8 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index f534123..b21a3d9 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -312,13 +312,14 @@ VELOCITY_PARAM(flow_control, "Enable flow control ability");

 #define MED_LNK_DEF 0
 #define MED_LNK_MIN 0
-#define MED_LNK_MAX 4
+#define MED_LNK_MAX 5
 /* speed_duplex[] is used for setting the speed and duplex mode of NIC.
    0: indicate autonegotiation for both speed and duplex mode
    1: indicate 100Mbps half duplex mode
    2: indicate 100Mbps full duplex mode
    3: indicate 10Mbps half duplex mode
    4: indicate 10Mbps full duplex mode
+   5: indicate 1000Mbps full duplex mode

    Note:
    if EEPROM have been set to the force mode, this option is ignored
@@ -617,6 +618,9 @@ static u32 velocity_get_opt_media_mode(struct velocity_info *vptr)
 	case SPD_DPX_10_HALF:
 		status = VELOCITY_SPEED_10;
 		break;
+	case SPD_DPX_1000_FULL:
+		status = VELOCITY_SPEED_1000 | VELOCITY_DUPLEX_FULL;
+		break;
 	}
 	vptr->mii_status = status;
 	return status;
@@ -922,6 +926,7 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 		/* enable AUTO-NEGO mode */
 		mii_set_auto_on(vptr);
 	} else {
+		u16 CTRL1000;
 		u16 ANAR;
 		u8 CHIPGCR;

@@ -936,7 +941,11 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 		BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);

 		CHIPGCR = readb(&regs->CHIPGCR);
-		CHIPGCR &= ~CHIPGCR_FCGMII;
+
+		if (mii_status & VELOCITY_SPEED_1000)
+			CHIPGCR |= CHIPGCR_FCGMII;
+		else
+			CHIPGCR &= ~CHIPGCR_FCGMII;

 		if (mii_status & VELOCITY_DUPLEX_FULL) {
 			CHIPGCR |= CHIPGCR_FCFDX;
@@ -952,7 +961,13 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 				BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
 		}

-		MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
+		velocity_mii_read(vptr->mac_regs, MII_CTRL1000, &CTRL1000);
+		CTRL1000 &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+		if ((mii_status & VELOCITY_SPEED_1000) &&
+		    (mii_status & VELOCITY_DUPLEX_FULL)) {
+			CTRL1000 |= ADVERTISE_1000FULL;
+		}
+		velocity_mii_write(vptr->mac_regs, MII_CTRL1000, CTRL1000);

 		if (!(mii_status & VELOCITY_DUPLEX_FULL) && (mii_status & VELOCITY_SPEED_10))
 			BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
@@ -967,7 +982,7 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 				ANAR |= ADVERTISE_100FULL;
 			else
 				ANAR |= ADVERTISE_100HALF;
-		} else {
+		} else if (mii_status & VELOCITY_SPEED_10) {
 			if (mii_status & VELOCITY_DUPLEX_FULL)
 				ANAR |= ADVERTISE_10FULL;
 			else
@@ -1013,6 +1028,9 @@ static void velocity_print_link_status(struct velocity_info *vptr)
 	} else {
 		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link forced", vptr->dev->name);
 		switch (vptr->options.spd_dpx) {
+		case SPD_DPX_1000_FULL:
+			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps full duplex\n");
+			break;
 		case SPD_DPX_100_HALF:
 			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 100M bps half duplex\n");
 			break;
@@ -3170,6 +3188,37 @@ static int velocity_get_settings(struct net_device *dev, struct ethtool_cmd *cmd
 			SUPPORTED_100baseT_Full |
 			SUPPORTED_1000baseT_Half |
 			SUPPORTED_1000baseT_Full;
+
+	cmd->advertising = ADVERTISED_TP | ADVERTISED_Autoneg;
+	if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
+		cmd->advertising |=
+			ADVERTISED_10baseT_Half |
+			ADVERTISED_10baseT_Full |
+			ADVERTISED_100baseT_Half |
+			ADVERTISED_100baseT_Full |
+			ADVERTISED_1000baseT_Half |
+			ADVERTISED_1000baseT_Full;
+	} else {
+		switch (vptr->options.spd_dpx) {
+		case SPD_DPX_1000_FULL:
+			cmd->advertising |= ADVERTISED_1000baseT_Full;
+			break;
+		case SPD_DPX_100_HALF:
+			cmd->advertising |= ADVERTISED_100baseT_Half;
+			break;
+		case SPD_DPX_100_FULL:
+			cmd->advertising |= ADVERTISED_100baseT_Full;
+			break;
+		case SPD_DPX_10_HALF:
+			cmd->advertising |= ADVERTISED_10baseT_Half;
+			break;
+		case SPD_DPX_10_FULL:
+			cmd->advertising |= ADVERTISED_10baseT_Full;
+			break;
+		default:
+			break;
+		}
+	}
 	if (status & VELOCITY_SPEED_1000)
 		cmd->speed = SPEED_1000;
 	else if (status & VELOCITY_SPEED_100)
@@ -3200,14 +3249,35 @@ static int velocity_set_settings(struct net_device *dev, struct ethtool_cmd *cmd
 	curr_status &= (~VELOCITY_LINK_FAIL);

 	new_status |= ((cmd->autoneg) ? VELOCITY_AUTONEG_ENABLE : 0);
+	new_status |= ((cmd->speed == SPEED_1000) ? VELOCITY_SPEED_1000 : 0);
 	new_status |= ((cmd->speed == SPEED_100) ? VELOCITY_SPEED_100 : 0);
 	new_status |= ((cmd->speed == SPEED_10) ? VELOCITY_SPEED_10 : 0);
 	new_status |= ((cmd->duplex == DUPLEX_FULL) ? VELOCITY_DUPLEX_FULL : 0);

-	if ((new_status & VELOCITY_AUTONEG_ENABLE) && (new_status != (curr_status | VELOCITY_AUTONEG_ENABLE)))
+	if ((new_status & VELOCITY_AUTONEG_ENABLE) &&
+	    (new_status != (curr_status | VELOCITY_AUTONEG_ENABLE))) {
 		ret = -EINVAL;
-	else
+	} else {
+		enum speed_opt spd_dpx;
+
+		if (new_status & VELOCITY_AUTONEG_ENABLE)
+			spd_dpx = SPD_DPX_AUTO;
+		else if ((new_status & VELOCITY_SPEED_1000) &&
+			 (new_status & VELOCITY_DUPLEX_FULL)) {
+			spd_dpx = SPD_DPX_1000_FULL;
+		} else if (new_status & VELOCITY_SPEED_100)
+			spd_dpx = (new_status & VELOCITY_DUPLEX_FULL) ?
+				SPD_DPX_100_FULL : SPD_DPX_100_HALF;
+		else if (new_status & VELOCITY_SPEED_10)
+			spd_dpx = (new_status & VELOCITY_DUPLEX_FULL) ?
+				SPD_DPX_10_FULL : SPD_DPX_10_HALF;
+		else
+			return -EOPNOTSUPP;
+
+		vptr->options.spd_dpx = spd_dpx;
+
 		velocity_set_media_mode(vptr, new_status);
+	}

 	return ret;
 }
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index f7b33ae..df55f6c 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -848,7 +848,7 @@ enum  velocity_owner {
  *	Bits in CHIPGCR register
  */

-#define CHIPGCR_FCGMII      0x80
+#define CHIPGCR_FCGMII      0x80	/* enable GMII mode */
 #define CHIPGCR_FCFDX       0x40
 #define CHIPGCR_FCRESV      0x20
 #define CHIPGCR_FCMODE      0x10
@@ -1390,7 +1390,8 @@ enum speed_opt {
 	SPD_DPX_100_HALF = 1,
 	SPD_DPX_100_FULL = 2,
 	SPD_DPX_10_HALF = 3,
-	SPD_DPX_10_FULL = 4
+	SPD_DPX_10_FULL = 4,
+	SPD_DPX_1000_FULL = 5
 };

 enum velocity_init_type {
--
1.7.2.3
