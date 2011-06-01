From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 11/11] bnx2x: Improve cl45 access methods
Date: Wed, 1 Jun 2011 10:29:42 +0300
Message-ID: <1306913382.20872.118.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4842 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153Ab1FAH3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 03:29:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of setting CL45 mode for every CL45 access, apply it once during initialization.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |  136 +++++++++++++++++++---------------------
 1 files changed, 65 insertions(+), 71 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 43e3663..15b5bc1 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -464,6 +464,29 @@ void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 /******************************************************************/
 /*			MAC/PBF section				  */
 /******************************************************************/
+static void bnx2x_set_mdio_clk(struct bnx2x *bp, u32 chip_id, u8 port)
+{
+	u32 mode, emac_base;
+	/**
+	 * Set clause 45 mode, slow down the MDIO clock to 2.5MHz
+	 * (a value of 49==0x31) and make sure that the AUTO poll is off
+	 */
+
+	if (CHIP_IS_E2(bp))
+		emac_base = GRCBASE_EMAC0;
+	else
+		emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	mode = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
+	mode &= ~(EMAC_MDIO_MODE_AUTO_POLL |
+		  EMAC_MDIO_MODE_CLOCK_CNT);
+	mode |= (49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
+
+	mode |= (EMAC_MDIO_MODE_CLAUSE_45);
+	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE, mode);
+
+	udelay(40);
+}
+
 static void bnx2x_emac_init(struct link_params *params,
 			    struct link_vars *vars)
 {
@@ -495,7 +518,7 @@ static void bnx2x_emac_init(struct link_params *params,
 		}
 		timeout--;
 	} while (val & EMAC_MODE_RESET);
-
+	bnx2x_set_mdio_clk(bp, params->chip_id, port);
 	/* Set mac address */
 	val = ((params->mac_addr[0] << 8) |
 		params->mac_addr[1]);
@@ -1352,144 +1375,113 @@ static u32 bnx2x_get_emac_base(struct bnx2x *bp,
 /******************************************************************/
 /*			CL45 access functions			  */
 /******************************************************************/
-static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
-			    u8 devad, u16 reg, u16 val)
+static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
+			   u8 devad, u16 reg, u16 *ret_val)
 {
-	u32 tmp, saved_mode;
-	u8 i;
+	u32 val;
+	u16 i;
 	int rc = 0;
-	/*
-	 * Set clause 45 mode, slow down the MDIO clock to 2.5MHz
-	 * (a value of 49==0x31) and make sure that the AUTO poll is off
-	 */
-
-	saved_mode = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	tmp = saved_mode & ~(EMAC_MDIO_MODE_AUTO_POLL |
-			     EMAC_MDIO_MODE_CLOCK_CNT);
-	tmp |= (EMAC_MDIO_MODE_CLAUSE_45 |
-		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
-	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
-	REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	udelay(40);
 
 	/* address */
-
-	tmp = ((phy->addr << 21) | (devad << 16) | reg |
+	val = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
-	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		tmp = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
-		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
+		val = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
+		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
 		}
 	}
-	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
-		DP(NETIF_MSG_LINK, "write phy register failed\n");
+	if (val & EMAC_MDIO_COMM_START_BUSY) {
+		DP(NETIF_MSG_LINK, "read phy register failed\n");
 		netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
+		*ret_val = 0;
 		rc = -EFAULT;
 	} else {
 		/* data */
-		tmp = ((phy->addr << 21) | (devad << 16) | val |
-		       EMAC_MDIO_COMM_COMMAND_WRITE_45 |
+		val = ((phy->addr << 21) | (devad << 16) |
+		       EMAC_MDIO_COMM_COMMAND_READ_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
-		REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
+		REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
 
 		for (i = 0; i < 50; i++) {
 			udelay(10);
 
-			tmp = REG_RD(bp, phy->mdio_ctrl +
+			val = REG_RD(bp, phy->mdio_ctrl +
 				     EMAC_REG_EMAC_MDIO_COMM);
-			if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
-				udelay(5);
+			if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
+				*ret_val = (u16)(val & EMAC_MDIO_COMM_DATA);
 				break;
 			}
 		}
-		if (tmp & EMAC_MDIO_COMM_START_BUSY) {
-			DP(NETIF_MSG_LINK, "write phy register failed\n");
+		if (val & EMAC_MDIO_COMM_START_BUSY) {
+			DP(NETIF_MSG_LINK, "read phy register failed\n");
 			netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
+			*ret_val = 0;
 			rc = -EFAULT;
 		}
 	}
 
-	/* Restore the saved mode */
-	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, saved_mode);
-
 	return rc;
 }
 
-static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
-			   u8 devad, u16 reg, u16 *ret_val)
+static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
+			    u8 devad, u16 reg, u16 val)
 {
-	u32 val, saved_mode;
-	u16 i;
+	u32 tmp;
+	u8 i;
 	int rc = 0;
-	/*
-	 * Set clause 45 mode, slow down the MDIO clock to 2.5MHz
-	 * (a value of 49==0x31) and make sure that the AUTO poll is off
-	 */
-
-	saved_mode = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	val = saved_mode & ~((EMAC_MDIO_MODE_AUTO_POLL |
-			      EMAC_MDIO_MODE_CLOCK_CNT));
-	val |= (EMAC_MDIO_MODE_CLAUSE_45 |
-		(49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
-	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
-	REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	udelay(40);
 
 	/* address */
-	val = ((phy->addr << 21) | (devad << 16) | reg |
+
+	tmp = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
-	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		val = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
-		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
+		tmp = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
+		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
 		}
 	}
-	if (val & EMAC_MDIO_COMM_START_BUSY) {
-		DP(NETIF_MSG_LINK, "read phy register failed\n");
+	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
+		DP(NETIF_MSG_LINK, "write phy register failed\n");
 		netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
-		*ret_val = 0;
 		rc = -EFAULT;
 
 	} else {
 		/* data */
-		val = ((phy->addr << 21) | (devad << 16) |
-		       EMAC_MDIO_COMM_COMMAND_READ_45 |
+		tmp = ((phy->addr << 21) | (devad << 16) | val |
+		       EMAC_MDIO_COMM_COMMAND_WRITE_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
-		REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
+		REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
 
 		for (i = 0; i < 50; i++) {
 			udelay(10);
 
-			val = REG_RD(bp, phy->mdio_ctrl +
+			tmp = REG_RD(bp, phy->mdio_ctrl +
 				     EMAC_REG_EMAC_MDIO_COMM);
-			if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
-				*ret_val = (u16)(val & EMAC_MDIO_COMM_DATA);
+			if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
+				udelay(5);
 				break;
 			}
 		}
-		if (val & EMAC_MDIO_COMM_START_BUSY) {
-			DP(NETIF_MSG_LINK, "read phy register failed\n");
+		if (tmp & EMAC_MDIO_COMM_START_BUSY) {
+			DP(NETIF_MSG_LINK, "write phy register failed\n");
 			netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
-			*ret_val = 0;
 			rc = -EFAULT;
 		}
 	}
 
-	/* Restore the saved mode */
-	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, saved_mode);
 
 	return rc;
 }
@@ -8425,6 +8417,8 @@ int bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
 	u32 phy_ver;
 	u8 phy_index;
 	u32 ext_phy_type, ext_phy_config;
+	bnx2x_set_mdio_clk(bp, chip_id, PORT_0);
+	bnx2x_set_mdio_clk(bp, chip_id, PORT_1);
 	DP(NETIF_MSG_LINK, "Begin common phy init\n");
 
 	/* Check if common init was already done */
-- 
1.7.1






