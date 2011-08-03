From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 04/10] bnx2x: Fix BCM578xx-B0 MDIO access
Date: Wed, 3 Aug 2011 11:59:32 +0300
Message-ID: <1312361972.21665.94.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2501 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201Ab1HCI7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 04:59:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix MDIO access to Warpcore on new chip version of 578xx.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   16 ++++++++++++++--
 drivers/net/bnx2x/bnx2x_link.h |    1 +
 drivers/net/bnx2x/bnx2x_reg.h  |    4 +++-
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 8e68e15..45255bd 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -2953,7 +2953,9 @@ static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 	u32 val;
 	u16 i;
 	int rc = 0;
-
+	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
+		bnx2x_bits_en(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
+			      EMAC_MDIO_STATUS_10MB);
 	/* address */
 	val = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
@@ -3007,6 +3009,9 @@ static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 		}
 	}
 
+	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
+		bnx2x_bits_dis(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
+			       EMAC_MDIO_STATUS_10MB);
 	return rc;
 }
 
@@ -3016,6 +3021,9 @@ static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 	u32 tmp;
 	u8 i;
 	int rc = 0;
+	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
+		bnx2x_bits_en(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
+			      EMAC_MDIO_STATUS_10MB);
 
 	/* address */
 
@@ -3069,7 +3077,9 @@ static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 			bnx2x_cl45_read(bp, phy, devad, 0xf, &temp_val);
 		}
 	}
-
+	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
+		bnx2x_bits_dis(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
+			       EMAC_MDIO_STATUS_10MB);
 	return rc;
 }
 
@@ -11118,6 +11128,8 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 		 */
 		if (CHIP_REV(bp) == CHIP_REV_Ax)
 			phy->flags |= FLAGS_MDC_MDIO_WA;
+		else
+			phy->flags |= FLAGS_MDC_MDIO_WA_B0;
 	} else {
 		switch (switch_cfg) {
 		case SWITCH_CFG_1G:
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 7ee6b51..c12db6d 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -145,6 +145,7 @@ struct bnx2x_phy {
 #define FLAGS_SFP_NOT_APPROVED		(1<<7)
 #define FLAGS_MDC_MDIO_WA		(1<<8)
 #define FLAGS_DUMMY_READ		(1<<9)
+#define FLAGS_MDC_MDIO_WA_B0		(1<<10)
 #define FLAGS_TX_ERROR_CHECK		(1<<12)
 
 	/* preemphasis values for the rx side */
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index d84642a..27b5ecb 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -5624,8 +5624,9 @@
 #define EMAC_MDIO_COMM_START_BUSY				 (1L<<29)
 #define EMAC_MDIO_MODE_AUTO_POLL				 (1L<<4)
 #define EMAC_MDIO_MODE_CLAUSE_45				 (1L<<31)
-#define EMAC_MDIO_MODE_CLOCK_CNT				 (0x3fL<<16)
+#define EMAC_MDIO_MODE_CLOCK_CNT				 (0x3ffL<<16)
 #define EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT			 16
+#define EMAC_MDIO_STATUS_10MB					 (1L<<1)
 #define EMAC_MODE_25G_MODE					 (1L<<5)
 #define EMAC_MODE_HALF_DUPLEX					 (1L<<1)
 #define EMAC_MODE_PORT_GMII					 (2L<<2)
@@ -5636,6 +5637,7 @@
 #define EMAC_REG_EMAC_MAC_MATCH 				 0x10
 #define EMAC_REG_EMAC_MDIO_COMM 				 0xac
 #define EMAC_REG_EMAC_MDIO_MODE 				 0xb4
+#define EMAC_REG_EMAC_MDIO_STATUS				 0xb0
 #define EMAC_REG_EMAC_MODE					 0x0
 #define EMAC_REG_EMAC_RX_MODE					 0xc8
 #define EMAC_REG_EMAC_RX_MTU_SIZE				 0x9c
-- 
1.7.1








