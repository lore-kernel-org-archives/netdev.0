From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 4/5] bnx2x: Fix led setting for 84858 phy.
Date: Sun, 21 Feb 2016 15:07:28 +0200
Message-ID: <1456060049-10678-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:3215 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751942AbcBURqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:46:24 -0500
In-Reply-To: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 94 ++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |  2 +
 2 files changed, 91 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 0c7b1c7..8779f15 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9787,16 +9787,32 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 static void bnx2x_848xx_set_led(struct bnx2x *bp,
 				struct bnx2x_phy *phy)
 {
-	u16 val, offset, i;
+	u16 val, led3_blink_rate, offset, i;
 	static struct bnx2x_reg_set reg_set[] = {
 		{MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_LED1_MASK, 0x0080},
 		{MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_LED2_MASK, 0x0018},
 		{MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_LED3_MASK, 0x0006},
-		{MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_LED3_BLINK, 0x0000},
 		{MDIO_PMA_DEVAD, MDIO_PMA_REG_84823_CTL_SLOW_CLK_CNT_HIGH,
 			MDIO_PMA_REG_84823_BLINK_RATE_VAL_15P9HZ},
 		{MDIO_AN_DEVAD, 0xFFFB, 0xFFFD}
 	};
+
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) {
+		/* Set LED5 source */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_8481_LED5_MASK,
+				 0x90);
+		led3_blink_rate = 0x000f;
+	} else {
+		led3_blink_rate = 0x0000;
+	}
+	/* Set LED3 BLINK */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED3_BLINK,
+			 led3_blink_rate);
+
 	/* PHYC_CTL_LED_CTL */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD,
@@ -9804,6 +9820,9 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 	val &= 0xFE00;
 	val |= 0x0092;
 
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858)
+		val |= 2 << 12; /* LED5 ON based on source */
+
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
@@ -9817,10 +9836,17 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 	else
 		offset = MDIO_PMA_REG_84823_CTL_LED_CTL_1;
 
-	/* stretch_en for LED3*/
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858)
+		val = MDIO_PMA_REG_84858_ALLOW_GPHY_ACT |
+		      MDIO_PMA_REG_84823_LED3_STRETCH_EN;
+	else
+		val = MDIO_PMA_REG_84823_LED3_STRETCH_EN;
+
+	/* stretch_en for LEDs */
 	bnx2x_cl45_read_or_write(bp, phy,
-				 MDIO_PMA_DEVAD, offset,
-				 MDIO_PMA_REG_84823_LED3_STRETCH_EN);
+				 MDIO_PMA_DEVAD,
+				 offset,
+				 val);
 }
 
 static void bnx2x_848xx_specific_func(struct bnx2x_phy *phy,
@@ -10743,10 +10769,25 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					0x0);
 
 		} else {
+			/* LED 1 OFF */
 			bnx2x_cl45_write(bp, phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8481_LED1_MASK,
 					 0x0);
+
+			if (phy->type ==
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) {
+				/* LED 2 OFF */
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED2_MASK,
+						 0x0);
+				/* LED 3 OFF */
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED3_MASK,
+						 0x0);
+			}
 		}
 		break;
 	case LED_MODE_FRONT_PANEL_OFF:
@@ -10805,6 +10846,19 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 						 MDIO_PMA_REG_8481_SIGNAL_MASK,
 						 0x0);
 			}
+			if (phy->type ==
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) {
+				/* LED 2 OFF */
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED2_MASK,
+						 0x0);
+				/* LED 3 OFF */
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED3_MASK,
+						 0x0);
+			}
 		}
 		break;
 	case LED_MODE_ON:
@@ -10868,6 +10922,25 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 						params->port*4,
 						NIG_MASK_MI_INT);
 				}
+			}
+			if (phy->type ==
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) {
+				/* Tell LED3 to constant on */
+				bnx2x_cl45_read(bp, phy,
+						MDIO_PMA_DEVAD,
+						MDIO_PMA_REG_8481_LINK_SIGNAL,
+						&val);
+				val &= ~(7<<6);
+				val |= (2<<6);  /* A83B[8:6]= 2 */
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LINK_SIGNAL,
+						 val);
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED3_MASK,
+						 0x20);
+			} else {
 				bnx2x_cl45_write(bp, phy,
 						 MDIO_PMA_DEVAD,
 						 MDIO_PMA_REG_8481_SIGNAL_MASK,
@@ -10946,6 +11019,17 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					 MDIO_PMA_REG_8481_LINK_SIGNAL,
 					 val);
 			if (phy->type ==
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84858) {
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED2_MASK,
+						 0x18);
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LED3_MASK,
+						 0x06);
+			}
+			if (phy->type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834) {
 				/* Restore LED4 source to external link,
 				 * and re-enable interrupts.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 4dead49..d27d40e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7296,6 +7296,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_84823_CTL_LED_CTL_1			0xa8e3
 #define MDIO_PMA_REG_84833_CTL_LED_CTL_1			0xa8ec
 #define MDIO_PMA_REG_84823_LED3_STRETCH_EN			0x0080
+/* BCM84858 only */
+#define MDIO_PMA_REG_84858_ALLOW_GPHY_ACT			0x8000
 
 /* BCM84833 only */
 #define MDIO_84833_TOP_CFG_FW_REV			0x400f
-- 
1.9.3
