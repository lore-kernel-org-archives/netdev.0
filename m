From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 6/8] bnx2x: Change BCM848xx LED configuration
Date: Wed, 1 Sep 2010 22:51:33 +0300
Message-ID: <1283370693.4403.137.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3988 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545Ab0IAQdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change 848xx LED configuration according to the new microcode (Boards
were shipped with only with the new microcode) 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |  171 ++++++++++++----------------------------
 1 files changed, 49 insertions(+), 122 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index e2945b4..8fce54c 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -2203,6 +2203,10 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 				       1<<15);
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
+			msleep(1);
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
+				       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+				       params->port);
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK, "XGXS PHY Failure detected\n");
@@ -3477,112 +3481,54 @@ static void bnx2x_set_preemphasis(struct link_params *params)
 }
 

-static void bnx2x_8481_set_led4(struct link_params *params,
-			      u32 ext_phy_type, u8 ext_phy_addr)
-{
-	struct bnx2x *bp = params->bp;
-
-	/* PHYC_CTL_LED_CTL */
-	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_LINK_SIGNAL, 0xa482);
-
-	/* Unmask LED4 for 10G link */
-	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_SIGNAL_MASK, (1<<6));
-	/* 'Interrupt Mask' */
-	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_AN_DEVAD,
-		       0xFFFB, 0xFFFD);
-}
-static void bnx2x_8481_set_legacy_led_mode(struct link_params *params,
-					 u32 ext_phy_type, u8 ext_phy_addr)
-{
-	struct bnx2x *bp = params->bp;
-
-	/* LED1 (10G Link): Disable LED1 when 10/100/1000 link */
-	/* LED2 (1G/100/10 Link): Enable LED2 when 10/100/1000 link) */
-	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_AN_DEVAD,
-		       MDIO_AN_REG_8481_LEGACY_SHADOW,
-		       (1<<15) | (0xd << 10) | (0xc<<4) | 0xe);
-}
-
-static void bnx2x_8481_set_10G_led_mode(struct link_params *params,
-				      u32 ext_phy_type, u8 ext_phy_addr)
+static void bnx2x_8481_set_led(struct link_params *params,
+			       u32 ext_phy_type, u8 ext_phy_addr)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val1;
-
-	/* LED1 (10G Link) */
-	/* Enable continuse based on source 7(10G-link) */
+	u16 val;
 	bnx2x_cl45_read(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_LINK_SIGNAL,
-		       &val1);
-	/* Set bit 2 to 0, and bits [1:0] to 10 */
-	val1 &= ~((1<<0) | (1<<2) | (1<<7)); /* Clear bits 0,2,7*/
-	val1 |= ((1<<1) | (1<<6)); /* Set bit 1, 6 */
+			ext_phy_type,
+			ext_phy_addr,
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8481_LINK_SIGNAL, &val);
+	val &= 0xFE00;
+	val |= 0x0092;
 
 	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_LINK_SIGNAL,
-		       val1);
+			 ext_phy_type,
+			 ext_phy_addr,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
 
-	/* Unmask LED1 for 10G link */
-	bnx2x_cl45_read(bp, params->port,
-		      ext_phy_type,
-		      ext_phy_addr,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_8481_LED1_MASK,
-		      &val1);
-	/* Set bit 2 to 0, and bits [1:0] to 10 */
-	val1 |= (1<<7);
 	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_LED1_MASK,
-		       val1);
+			 ext_phy_type,
+			 ext_phy_addr,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED1_MASK,
+			 0x80);
 
-	/* LED2 (1G/100/10G Link) */
-	/* Mask LED2 for 10G link */
 	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_LED2_MASK,
-		       0);
+			 ext_phy_type,
+			 ext_phy_addr,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED2_MASK,
+			 0x18);
 
-	/* Unmask LED3 for 10G link */
 	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_8481_LED3_MASK,
-		       0x6);
+			 ext_phy_type,
+			 ext_phy_addr,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED3_MASK,
+			 0x0040);
+
+	/* 'Interrupt Mask' */
 	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8481_LED3_BLINK,
-		       0);
+			 ext_phy_type,
+			 ext_phy_addr,
+			 MDIO_AN_DEVAD,
+			 0xFFFB, 0xFFFD);
 }
 
-
 static void bnx2x_init_internal_phy(struct link_params *params,
 				  struct link_vars *vars,
 				  u8 enable_cl73)
@@ -4358,7 +4304,13 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				indication arrives through its LED4 and not via
 				its LASI signal, so we get steady signal
 				instead of clear on read */
-			u16 autoneg_val, an_1000_val, an_10_100_val;
+			u16 autoneg_val, an_1000_val, an_10_100_val, temp;
+			temp = vars->line_speed;
+			vars->line_speed = SPEED_10000;
+			bnx2x_set_autoneg(params, vars, 0);
+			bnx2x_program_serdes(params, vars);
+			vars->line_speed = temp;
+
 			bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
 				      1 << NIG_LATCH_BC_ENABLE_MI_INT);
 
@@ -4368,7 +4320,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_CTRL, 0x0000);
 
-			bnx2x_8481_set_led4(params, ext_phy_type, ext_phy_addr);
+			bnx2x_8481_set_led(params, ext_phy_type, ext_phy_addr);
 
 			bnx2x_cl45_read(bp, params->port,
 					ext_phy_type,
@@ -5184,9 +5136,6 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			if (val2 & (1<<11)) {
 				vars->line_speed = SPEED_10000;
 				ext_phy_link_up = 1;
-				bnx2x_8481_set_10G_led_mode(params,
-							  ext_phy_type,
-							  ext_phy_addr);
 			} else { /* Check Legacy speed link */
 				u16 legacy_status, legacy_speed;
 
@@ -5234,9 +5183,6 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 						     "= %d\n",
 						vars->line_speed,
 						(vars->duplex == DUPLEX_FULL));
-					bnx2x_8481_set_legacy_led_mode(params,
-								 ext_phy_type,
-								 ext_phy_addr);
 				}
 			}
 			break;
@@ -6191,18 +6137,9 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
 		{
-			u8 ext_phy_addr =
-				XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-			bnx2x_cl45_write(bp, port,
-				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-				       ext_phy_addr,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CTRL, 0x0000);
-			bnx2x_cl45_write(bp, port,
-				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-				       ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL, 1);
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
+				       MISC_REGISTERS_GPIO_OUTPUT_LOW,
+				       params->port);
 			break;
 		}
 		default:
@@ -6617,13 +6554,6 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return 0;
 }
 
-
-static u8 bnx2x_84823_common_init_phy(struct bnx2x *bp, u32 shmem_base)
-{
-	/* HW reset */
-	bnx2x_ext_phy_hw_reset(bp, 1);
-	return 0;
-}
 u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	u8 rc = 0;
@@ -6654,9 +6584,6 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		it for single port alone */
 		rc = bnx2x_8726_common_init_phy(bp, shmem_base);
 		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
-		rc = bnx2x_84823_common_init_phy(bp, shmem_base);
-		break;
 	default:
 		DP(NETIF_MSG_LINK,
 			 "bnx2x_common_init_phy: ext_phy 0x%x not required\n",
-- 
1.7.1




