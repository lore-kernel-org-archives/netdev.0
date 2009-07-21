From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 2/10] bnx2x: Fan failure
Date: Tue, 21 Jul 2009 18:47:27 +0300
Message-ID: <1248191247.18195.45.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4396 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbZGUPrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setup fan failure for different PHY types or according to nvram settings

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h  |   15 ++++++
 drivers/net/bnx2x_main.c |  112 +++++++++++++++++++++++++++++++---------------
 2 files changed, 90 insertions(+), 37 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 03c6242..41c6dcb 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -91,6 +91,21 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 
 #define SHARED_HW_CFG_HIDE_PORT1		    0x00002000
 
+	/*  The fan failure mechanism is usually related to the PHY type
+	  since the power consumption of the board is determined by the PHY.
+	  Currently, fan is required for most designs with SFX7101, BCM8727
+	  and BCM8481. If a fan is not required for a board which uses one
+	  of those PHYs, this field should be set to "Disabled". If a fan is
+	  required for a different PHY type, this option should be set to
+	  "Enabled".
+	  The fan failure indication is expected on
+	  SPIO5 */
+#define SHARED_HW_CFG_FAN_FAILURE_MASK			      0x00180000
+#define SHARED_HW_CFG_FAN_FAILURE_SHIFT 		      19
+#define SHARED_HW_CFG_FAN_FAILURE_PHY_TYPE		      0x00000000
+#define SHARED_HW_CFG_FAN_FAILURE_DISABLED		      0x00080000
+#define SHARED_HW_CFG_FAN_FAILURE_ENABLED		      0x00100000
+
 	u32 power_dissipated;					/* 0x11c */
 #define SHARED_HW_CFG_POWER_DIS_CMN_MASK	    0xff000000
 #define SHARED_HW_CFG_POWER_DIS_CMN_SHIFT	    24
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 177cb46..ae8b7b5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2598,6 +2598,22 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 	}
 }
 
+static inline void bnx2x_fan_failure(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+
+	/* mark the failure */
+	bp->link_params.ext_phy_config &= ~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
+	bp->link_params.ext_phy_config |= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE;
+	SHMEM_WR(bp, dev_info.port_hw_config[port].external_phy_config,
+		 bp->link_params.ext_phy_config);
+
+	/* log the failure */
+	printk(KERN_ERR PFX "Fan Failure on Network Controller %s has caused"
+	       " the driver to shutdown the card to prevent permanent"
+	       " damage.  Please contact Dell Support for assistance\n",
+	       bp->dev->name);
+}
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 {
 	int port = BP_PORT(bp);
@@ -2615,36 +2631,21 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 
 		BNX2X_ERR("SPIO5 hw attention\n");
 
+		/* Fan failure attention */
 		switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			/* Fan failure attention */
-
-			/* The PHY reset is controlled by GPIO 1 */
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 			/* Low power mode is controlled by GPIO 2 */
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
-			/* mark the failure */
-			bp->link_params.ext_phy_config &=
-					~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
-			bp->link_params.ext_phy_config |=
-					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE;
-			SHMEM_WR(bp,
-				 dev_info.port_hw_config[port].
-							external_phy_config,
-				 bp->link_params.ext_phy_config);
-			/* log the failure */
-			printk(KERN_ERR PFX "Fan Failure on Network"
-			       " Controller %s has caused the driver to"
-			       " shutdown the card to prevent permanent"
-			       " damage.  Please contact Dell Support for"
-			       " assistance\n", bp->dev->name);
+			/* The PHY reset is controlled by GPIO 1 */
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 			break;
 
 		default:
 			break;
 		}
+		bnx2x_fan_failure(bp);
 	}
 
 	if (attn & (AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0 |
@@ -5509,6 +5510,58 @@ static void bnx2x_reset_common(struct bnx2x *bp)
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR, 0x1403);
 }
 
+
+static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
+{
+	u32 val;
+	u8 port;
+	u8 is_required = 0;
+
+	val = SHMEM_RD(bp, dev_info.shared_hw_config.config2) &
+	      SHARED_HW_CFG_FAN_FAILURE_MASK;
+
+	if (val == SHARED_HW_CFG_FAN_FAILURE_ENABLED)
+		is_required = 1;
+
+	/*
+	 * The fan failure mechanism is usually related to the PHY type since
+	 * the power consumption of the board is affected by the PHY. Currently,
+	 * fan is required for most designs with SFX7101, BCM8727 and BCM8481.
+	 */
+	else if (val == SHARED_HW_CFG_FAN_FAILURE_PHY_TYPE)
+		for (port = PORT_0; port < PORT_MAX; port++) {
+			u32 phy_type =
+				SHMEM_RD(bp, dev_info.port_hw_config[port].
+					 external_phy_config) &
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
+			is_required |=
+				((phy_type ==
+				  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101) ||
+				 (phy_type ==
+				  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481));
+		}
+
+	DP(NETIF_MSG_HW, "fan detection setting: %d\n", is_required);
+
+	if (is_required == 0)
+		return;
+
+	/* Fan failure is indicated by SPIO 5 */
+	bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
+		       MISC_REGISTERS_SPIO_INPUT_HI_Z);
+
+	/* set to active low mode */
+	val = REG_RD(bp, MISC_REG_SPIO_INT);
+	val |= ((1 << MISC_REGISTERS_SPIO_5) <<
+				MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
+	REG_WR(bp, MISC_REG_SPIO_INT, val);
+
+	/* enable interrupt to signal the IGU */
+	val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
+	val |= (1 << MISC_REGISTERS_SPIO_5);
+	REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
+}
+
 static int bnx2x_init_common(struct bnx2x *bp)
 {
 	u32 val, i;
@@ -5738,27 +5791,12 @@ static int bnx2x_init_common(struct bnx2x *bp)
 		bp->port.need_hw_lock = 1;
 		break;
 
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-		/* Fan failure is indicated by SPIO 5 */
-		bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
-			       MISC_REGISTERS_SPIO_INPUT_HI_Z);
-
-		/* set to active low mode */
-		val = REG_RD(bp, MISC_REG_SPIO_INT);
-		val |= ((1 << MISC_REGISTERS_SPIO_5) <<
-					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
-		REG_WR(bp, MISC_REG_SPIO_INT, val);
-
-		/* enable interrupt to signal the IGU */
-		val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
-		val |= (1 << MISC_REGISTERS_SPIO_5);
-		REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
-		break;
-
 	default:
 		break;
 	}
 
+	bnx2x_setup_fan_failure_detection(bp);
+
 	/* clear PXP2 attentions */
 	REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR_0);
 
-- 
1.5.4.3




