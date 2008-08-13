From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 18/25] bnx2x: Change GPIO for any port
Date: Wed, 13 Aug 2008 17:15:44 +0300
Message-ID: <1218636944.547.94.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3059 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbYHMOQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change GPIO for any port
The set GPIO function should receive the port index to allow changing
the GPIO of another port. This is needed for the common init phase (one
the first driver is loaded for the chip)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_link.c |   78 +++++++++++++++++++++++++--------------------
 drivers/net/bnx2x_main.c |   14 ++++----
 3 files changed, 51 insertions(+), 43 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 3b09ae6..e15ecfb 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -924,7 +924,7 @@ struct bnx2x {
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32);
-int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
+int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 36fa356..c9cffa6 100755
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1842,15 +1842,15 @@ static u8 bnx2x_emac_program(struct link_params *params,
 }
 
 /*****************************************************************************/
-/*                           External Phy section                            */
+/*      		     External Phy section       		     */
 /*****************************************************************************/
-static void bnx2x_hw_reset(struct bnx2x *bp)
+static void bnx2x_hw_reset(struct bnx2x *bp, u8 port)
 {
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-		       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 	msleep(1);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-		      MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+		      MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
 
 static void bnx2x_ext_phy_reset(struct link_params *params,
@@ -1879,10 +1879,11 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
 
 			/* HW reset */
-			bnx2x_hw_reset(bp);
+			bnx2x_hw_reset(bp, params->port);
 
 			bnx2x_cl45_write(bp, params->port,
 				       ext_phy_type,
@@ -1894,7 +1895,8 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			/* Unset Low Power Mode and SW reset */
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
 
 			DP(NETIF_MSG_LINK, "XGXS 8072\n");
 			bnx2x_cl45_write(bp, params->port,
@@ -1912,19 +1914,14 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
 
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
 
 			DP(NETIF_MSG_LINK, "XGXS 8073\n");
-			bnx2x_cl45_write(bp,
-				       params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL,
-				       1<<15);
 			}
 			break;
 
@@ -1933,10 +1930,11 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
 
 			/* HW reset */
-			bnx2x_hw_reset(bp);
+			bnx2x_hw_reset(bp, params->port);
 
 			break;
 
@@ -1959,7 +1957,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
 			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			bnx2x_hw_reset(bp);
+			bnx2x_hw_reset(bp, params->port);
 			break;
 
 		default:
@@ -3286,12 +3284,14 @@ static void bnx2x_turn_on_ef(struct bnx2x *bp, u8 port, u8 ext_phy_addr,
 
 	/* take ext phy out of reset */
 	bnx2x_set_gpio(bp,
-			MISC_REGISTERS_GPIO_2,
-			MISC_REGISTERS_GPIO_HIGH);
+			  MISC_REGISTERS_GPIO_2,
+			  MISC_REGISTERS_GPIO_HIGH,
+			  port);
 
 	bnx2x_set_gpio(bp,
-			MISC_REGISTERS_GPIO_1,
-			MISC_REGISTERS_GPIO_HIGH);
+			  MISC_REGISTERS_GPIO_1,
+			  MISC_REGISTERS_GPIO_HIGH,
+			  port);
 
 	/* wait for 5ms */
 	msleep(5);
@@ -3311,13 +3311,17 @@ static void bnx2x_turn_on_ef(struct bnx2x *bp, u8 port, u8 ext_phy_addr,
 	}
 }
 
-static void bnx2x_turn_off_sf(struct bnx2x *bp)
+static void bnx2x_turn_off_sf(struct bnx2x *bp, u8 port)
 {
 	/* put sf to reset */
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1, MISC_REGISTERS_GPIO_LOW);
 	bnx2x_set_gpio(bp,
-			MISC_REGISTERS_GPIO_2,
-			MISC_REGISTERS_GPIO_LOW);
+			  MISC_REGISTERS_GPIO_1,
+			  MISC_REGISTERS_GPIO_LOW,
+			  port);
+	bnx2x_set_gpio(bp,
+			  MISC_REGISTERS_GPIO_2,
+			  MISC_REGISTERS_GPIO_LOW,
+			  port);
 }
 
 u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
@@ -3371,7 +3375,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 		version[4] = '\0';
 
 		if (!driver_loaded)
-			bnx2x_turn_off_sf(bp);
+			bnx2x_turn_off_sf(bp, params->port);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
@@ -4013,10 +4017,12 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
 			/* HW reset */
 
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
+					  port);
 
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
+					  port);
 
 			DP(NETIF_MSG_LINK, "reset external PHY\n");
 		} else if (ext_phy_type ==
@@ -4025,7 +4031,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
 					 "low power mode\n",
 					 port);
 				bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-					MISC_REGISTERS_GPIO_OUTPUT_LOW);
+					MISC_REGISTERS_GPIO_OUTPUT_LOW,
+						  port);
 		}
 	}
 	/* reset the SerDes/XGXS */
@@ -4271,7 +4278,7 @@ static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
 	   and issuing a reset.*/
 
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-			  MISC_REGISTERS_GPIO_HIGH);
+			  MISC_REGISTERS_GPIO_HIGH, port);
 
 	bnx2x_sfx7101_sp_sw_reset(bp, port, ext_phy_addr);
 
@@ -4503,7 +4510,8 @@ static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
 	}
 
 	/* DSP Remove Download Mode */
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0, MISC_REGISTERS_GPIO_LOW);
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+			  MISC_REGISTERS_GPIO_LOW, port);
 
 	bnx2x_sfx7101_sp_sw_reset(bp, port, ext_phy_addr);
 
@@ -4511,7 +4519,7 @@ static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
 	for (cnt = 0; cnt < 100; cnt++)
 		msleep(5);
 
-	bnx2x_hw_reset(bp);
+	bnx2x_hw_reset(bp, port);
 
 	for (cnt = 0; cnt < 100; cnt++)
 		msleep(5);
@@ -4586,7 +4594,7 @@ u8 bnx2x_flash_download(struct bnx2x *bp, u8 port, u32 ext_phy_config,
 		rc = bnx2x_sfx7101_flash_download(bp, port, ext_phy_addr,
 						data, size);
 		if (!driver_loaded)
-			bnx2x_turn_off_sf(bp);
+			bnx2x_turn_off_sf(bp, port);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a37549b..85ea799 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1788,11 +1788,11 @@ static void bnx2x_release_phy_lock(struct bnx2x *bp)
 	mutex_unlock(&bp->port.phy_mutex);
 }
 
-int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
+int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port)
 {
 	/* The GPIO should be swapped if swap register is set and active */
 	int gpio_port = (REG_RD(bp, NIG_REG_PORT_SWAP) &&
-			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ BP_PORT(bp);
+			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ port;
 	int gpio_shift = gpio_num +
 			(gpio_port ? MISC_REGISTERS_GPIO_PORT_SHIFT : 0);
 	u32 gpio_mask = (1 << gpio_shift);
@@ -1824,7 +1824,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
 		gpio_reg |=  (gpio_mask << MISC_REGISTERS_GPIO_SET_POS);
 		break;
 
-	case MISC_REGISTERS_GPIO_INPUT_HI_Z :
+	case MISC_REGISTERS_GPIO_INPUT_HI_Z:
 		DP(NETIF_MSG_LINK, "Set GPIO %d (shift %d) -> input\n",
 		   gpio_num, gpio_shift);
 		/* set FLOAT */
@@ -2553,12 +2553,12 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 			/* Fan failure attention */
 
-			/* The PHY reset is controled by GPIO 1 */
+			/* The PHY reset is controlled by GPIO 1 */
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
-			/* Low power mode is controled by GPIO 2 */
+				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
+			/* Low power mode is controlled by GPIO 2 */
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 			/* mark the failure */
 			bp->link_params.ext_phy_config &=
 					~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
-- 
1.5.3.2




