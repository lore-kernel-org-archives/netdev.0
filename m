From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 01/10] bnx2x: Unify PHY attributes
Date: Wed, 8 Sep 2010 00:40:50 +0300
Message-ID: <1283895650.5452.61.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1149 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932433Ab0IGSWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:22:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Start building the infrastructure for dual media by adding new component
of PHY which will be used all along the function. Modify function to
work with this component instead of the link_params. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_ethtool.c |   15 +-
 drivers/net/bnx2x/bnx2x_hsi.h     |   17 +
 drivers/net/bnx2x/bnx2x_link.c    | 2181 ++++++++++++++-----------------------
 drivers/net/bnx2x/bnx2x_link.h    |   59 +-
 drivers/net/bnx2x/bnx2x_main.c    |   21 +-
 drivers/net/bnx2x/bnx2x_reg.h     |   10 +-
 6 files changed, 917 insertions(+), 1386 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 8b75b05..2c7e0ab 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -811,7 +811,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	int port = BP_PORT(bp);
 	int rc = 0;
-
+	u32 ext_phy_config;
 	if (!netif_running(dev))
 		return -EAGAIN;
 
@@ -827,6 +827,10 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 	    !bp->port.pmf)
 		return -EINVAL;
 
+	ext_phy_config =
+		SHMEM_RD(bp,
+			 dev_info.port_hw_config[port].external_phy_config);
+
 	if (eeprom->magic == 0x50485950) {
 		/* 'PHYP' (0x50485950): prepare phy for FW upgrade */
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
@@ -834,7 +838,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 		bnx2x_acquire_phy_lock(bp);
 		rc |= bnx2x_link_reset(&bp->link_params,
 				       &bp->link_vars, 0);
-		if (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config) ==
+		if (XGXS_EXT_PHY_TYPE(ext_phy_config) ==
 					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101)
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
 				       MISC_REGISTERS_GPIO_HIGH, port);
@@ -855,10 +859,8 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 		}
 	} else if (eeprom->magic == 0x53985943) {
 		/* 'PHYC' (0x53985943): PHY FW upgrade completed */
-		if (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config) ==
+		if (XGXS_EXT_PHY_TYPE(ext_phy_config) ==
 				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101) {
-			u8 ext_phy_addr =
-			     XGXS_EXT_PHY_ADDR(bp->link_params.ext_phy_config);
 
 			/* DSP Remove Download Mode */
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
@@ -866,7 +868,8 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 
 			bnx2x_acquire_phy_lock(bp);
 
-			bnx2x_sfx7101_sp_sw_reset(bp, port, ext_phy_addr);
+			bnx2x_sfx7101_sp_sw_reset(bp,
+						&bp->link_params.phy[EXT_PHY1]);
 
 			/* wait 0.5 sec to allow it to run */
 			msleep(500);
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index fd1f29e..f494bc3 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -120,6 +120,23 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 #define SHARED_HW_CFG_FAN_FAILURE_DISABLED		      0x00080000
 #define SHARED_HW_CFG_FAN_FAILURE_ENABLED		      0x00100000
 
+	/* Set the MDC/MDIO access for the first external phy */
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK	    0x1C000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_SHIFT	    26
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_PHY_TYPE     0x00000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC0	    0x04000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC1	    0x08000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH	    0x0c000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS1_SWAPPED	    0x10000000
+
+	/* Set the MDC/MDIO access for the second external phy */
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_MASK	    0xE0000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_SHIFT	    29
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_PHY_TYPE     0x00000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_EMAC0	    0x20000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_EMAC1	    0x40000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_BOTH	    0x60000000
+#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_SWAPPED	    0x80000000
 	u32 power_dissipated;					/* 0x11c */
 #define SHARED_HW_CFG_POWER_DIS_CMN_MASK	    0xff000000
 #define SHARED_HW_CFG_POWER_DIS_CMN_SHIFT	    24
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 8fce54c..b89439d 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -168,32 +168,33 @@
 /**********************************************************/
 /*                     INTERFACE                          */
 /**********************************************************/
-#define CL45_WR_OVER_CL22(_bp, _port, _phy_addr, _bank, _addr, _val) \
-	bnx2x_cl45_write(_bp, _port, 0, _phy_addr, \
+
+#define CL45_WR_OVER_CL22(_bp, _phy, _bank, _addr, _val) \
+	bnx2x_cl45_write(_bp, _phy, \
 		DEFAULT_PHY_DEV_ADDR, \
 		(_bank + (_addr & 0xf)), \
 		_val)
 
-#define CL45_RD_OVER_CL22(_bp, _port, _phy_addr, _bank, _addr, _val) \
-	bnx2x_cl45_read(_bp, _port, 0, _phy_addr, \
+#define CL45_RD_OVER_CL22(_bp, _phy, _bank, _addr, _val) \
+	bnx2x_cl45_read(_bp, _phy, \
 		DEFAULT_PHY_DEV_ADDR, \
 		(_bank + (_addr & 0xf)), \
 		_val)
 
-static void bnx2x_set_serdes_access(struct link_params *params)
+static void bnx2x_set_serdes_access(struct bnx2x *bp, u8 port)
 {
-	struct bnx2x *bp = params->bp;
-	u32 emac_base = (params->port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	u32 emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 
 	/* Set Clause 22 */
-	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + params->port*0x10, 1);
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 1);
 	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245f8000);
 	udelay(500);
 	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245d000f);
 	udelay(500);
 	 /* Set Clause 45 */
-	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + params->port*0x10, 0);
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 0);
 }
+
 static void bnx2x_set_phy_mdio(struct link_params *params, u8 phy_flags)
 {
 	struct bnx2x *bp = params->bp;
@@ -204,7 +205,7 @@ static void bnx2x_set_phy_mdio(struct link_params *params, u8 phy_flags)
 		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + params->port*0x18,
 			   DEFAULT_PHY_DEV_ADDR);
 	} else {
-		bnx2x_set_serdes_access(params);
+		bnx2x_set_serdes_access(bp, params->port);
 
 		REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
 			   params->port*0x10,
@@ -825,37 +826,37 @@ static u32 bnx2x_get_emac_base(struct bnx2x *bp, u32 ext_phy_type, u8 port)
 
 }
 
-u8 bnx2x_cl45_write(struct bnx2x *bp, u8 port, u32 ext_phy_type,
-		  u8 phy_addr, u8 devad, u16 reg, u16 val)
+u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
+		    u8 devad, u16 reg, u16 val)
 {
 	u32 tmp, saved_mode;
 	u8 i, rc = 0;
-	u32 mdio_ctrl = bnx2x_get_emac_base(bp, ext_phy_type, port);
 
 	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
 
-	saved_mode = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	saved_mode = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	tmp = saved_mode & ~(EMAC_MDIO_MODE_AUTO_POLL |
 			     EMAC_MDIO_MODE_CLOCK_CNT);
 	tmp |= (EMAC_MDIO_MODE_CLAUSE_45 |
 		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
-	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
+	REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	udelay(40);
 
 	/* address */
 
-	tmp = ((phy_addr << 21) | (devad << 16) | reg |
+	tmp = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
+		tmp = REG_RD(bp, phy->mdio_ctrl +
+				   EMAC_REG_EMAC_MDIO_COMM);
 		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
@@ -866,15 +867,15 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 		rc = -EFAULT;
 	} else {
 		/* data */
-		tmp = ((phy_addr << 21) | (devad << 16) | val |
+		tmp = ((phy->addr << 21) | (devad << 16) | val |
 		       EMAC_MDIO_COMM_COMMAND_WRITE_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
-		REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
+		REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
 
 		for (i = 0; i < 50; i++) {
 			udelay(10);
 
-			tmp = REG_RD(bp, mdio_ctrl +
+			tmp = REG_RD(bp, phy->mdio_ctrl +
 					 EMAC_REG_EMAC_MDIO_COMM);
 			if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 				udelay(5);
@@ -888,42 +889,41 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 	}
 
 	/* Restore the saved mode */
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, saved_mode);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, saved_mode);
 
 	return rc;
 }
 
-u8 bnx2x_cl45_read(struct bnx2x *bp, u8 port, u32 ext_phy_type,
-		 u8 phy_addr, u8 devad, u16 reg, u16 *ret_val)
+u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
+		   u8 devad, u16 reg, u16 *ret_val)
 {
 	u32 val, saved_mode;
 	u16 i;
 	u8 rc = 0;
 
-	u32 mdio_ctrl = bnx2x_get_emac_base(bp, ext_phy_type, port);
 	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
 
-	saved_mode = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	val = saved_mode & ((EMAC_MDIO_MODE_AUTO_POLL |
+	saved_mode = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	val = saved_mode & ~((EMAC_MDIO_MODE_AUTO_POLL |
 			     EMAC_MDIO_MODE_CLOCK_CNT));
 	val |= (EMAC_MDIO_MODE_CLAUSE_45 |
 		(49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
-	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
+	REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	udelay(40);
 
 	/* address */
-	val = ((phy_addr << 21) | (devad << 16) | reg |
+	val = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
+		val = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
 		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
@@ -937,15 +937,15 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 
 	} else {
 		/* data */
-		val = ((phy_addr << 21) | (devad << 16) |
+		val = ((phy->addr << 21) | (devad << 16) |
 		       EMAC_MDIO_COMM_COMMAND_READ_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
-		REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
+		REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
 
 		for (i = 0; i < 50; i++) {
 			udelay(10);
 
-			val = REG_RD(bp, mdio_ctrl +
+			val = REG_RD(bp, phy->mdio_ctrl +
 					  EMAC_REG_EMAC_MDIO_COMM);
 			if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
 				*ret_val = (u16)(val & EMAC_MDIO_COMM_DATA);
@@ -961,13 +961,49 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 	}
 
 	/* Restore the saved mode */
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, saved_mode);
+	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, saved_mode);
 
 	return rc;
 }
 
+u8 bnx2x_phy_read(struct link_params *params, u8 phy_addr,
+		  u8 devad, u16 reg, u16 *ret_val)
+{
+	u8 phy_index;
+	/**
+	 * Probe for the phy according to the given phy_addr, and execute
+	 * the read request on it
+	 */
+	for (phy_index = 0; phy_index < params->num_phys; phy_index++) {
+		if (params->phy[phy_index].addr == phy_addr) {
+			return bnx2x_cl45_read(params->bp,
+					       &params->phy[phy_index], devad,
+					       reg, ret_val);
+		}
+	}
+	return -EINVAL;
+}
+
+u8 bnx2x_phy_write(struct link_params *params, u8 phy_addr,
+		   u8 devad, u16 reg, u16 val)
+{
+	u8 phy_index;
+	/**
+	 * Probe for the phy according to the given phy_addr, and execute
+	 * the write request on it
+	 */
+	for (phy_index = 0; phy_index < params->num_phys; phy_index++) {
+		if (params->phy[phy_index].addr == phy_addr) {
+			return bnx2x_cl45_write(params->bp,
+						&params->phy[phy_index], devad,
+						reg, val);
+		}
+	}
+	return -EINVAL;
+}
+
 static void bnx2x_set_aer_mmd(struct link_params *params,
-			    struct link_vars   *vars)
+			      struct bnx2x_phy *phy)
 {
 	struct bnx2x *bp = params->bp;
 	u32 ser_lane;
@@ -977,16 +1013,16 @@ static void bnx2x_set_aer_mmd(struct link_params *params,
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
-	offset = (vars->phy_flags & PHY_XGXS_FLAG) ?
-		(params->phy_addr + ser_lane) : 0;
+	offset = (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ?
+		(phy->addr + ser_lane) : 0;
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_AER_BLOCK,
 			      MDIO_AER_BLOCK_AER_REG, 0x3800 + offset);
 }
 
-static void bnx2x_set_master_ln(struct link_params *params)
+static void bnx2x_set_master_ln(struct link_params *params,
+				struct bnx2x_phy *phy)
 {
 	struct bnx2x *bp = params->bp;
 	u16 new_master_ln, ser_lane;
@@ -995,47 +1031,44 @@ static void bnx2x_set_master_ln(struct link_params *params)
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
 	/* set the master_ln for AN */
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_XGXS_BLOCK2,
 			      MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
 			      &new_master_ln);
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_XGXS_BLOCK2 ,
 			      MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
 			      (new_master_ln | ser_lane));
 }
 
-static u8 bnx2x_reset_unicore(struct link_params *params)
+static u8 bnx2x_reset_unicore(struct link_params *params,
+			      struct bnx2x_phy *phy,
+			      u8 set_serdes)
 {
 	struct bnx2x *bp = params->bp;
 	u16 mii_control;
 	u16 i;
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
 
 	/* reset the unicore */
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL,
 			      (mii_control |
 			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));
-	if (params->switch_cfg == SWITCH_CFG_1G)
-		bnx2x_set_serdes_access(params);
+	if (set_serdes)
+		bnx2x_set_serdes_access(bp, params->port);
 
 	/* wait for the reset to self clear */
 	for (i = 0; i < MDIO_ACCESS_TIMEOUT; i++) {
 		udelay(5);
 
 		/* the reset erased the previous bank value */
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL,
 			      &mii_control);
@@ -1051,7 +1084,8 @@ static u8 bnx2x_reset_unicore(struct link_params *params)
 
 }
 
-static void bnx2x_set_swap_lanes(struct link_params *params)
+static void bnx2x_set_swap_lanes(struct link_params *params,
+				 struct bnx2x_phy *phy)
 {
 	struct bnx2x *bp = params->bp;
 	/* Each two bits represents a lane number:
@@ -1069,43 +1103,37 @@ static void bnx2x_set_swap_lanes(struct link_params *params)
 			    PORT_HW_CFG_LANE_SWAP_CFG_TX_SHIFT);
 
 	if (rx_lane_swap != 0x1b) {
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				    MDIO_REG_BANK_XGXS_BLOCK2,
 				    MDIO_XGXS_BLOCK2_RX_LN_SWAP,
 				    (rx_lane_swap |
 				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE |
 				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE));
 	} else {
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_XGXS_BLOCK2,
 				      MDIO_XGXS_BLOCK2_RX_LN_SWAP, 0);
 	}
 
 	if (tx_lane_swap != 0x1b) {
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_XGXS_BLOCK2,
 				      MDIO_XGXS_BLOCK2_TX_LN_SWAP,
 				      (tx_lane_swap |
 				       MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE));
 	} else {
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_XGXS_BLOCK2,
 				      MDIO_XGXS_BLOCK2_TX_LN_SWAP, 0);
 	}
 }
 
-static void bnx2x_set_parallel_detection(struct link_params *params,
-				       u8       	 phy_flags)
+static void bnx2x_set_parallel_detection(struct bnx2x_phy *phy,
+					 struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 control2;
-
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
 			      &control2);
@@ -1115,25 +1143,22 @@ static void bnx2x_set_parallel_detection(struct link_params *params,
 		control2 &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
 	DP(NETIF_MSG_LINK, "params->speed_cap_mask = 0x%x, control2 = 0x%x\n",
 		params->speed_cap_mask, control2);
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
 			      control2);
 
-	if ((phy_flags & PHY_XGXS_FLAG) &&
+	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
 	     (params->speed_cap_mask &
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
 		DP(NETIF_MSG_LINK, "XGXS\n");
 
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				MDIO_REG_BANK_10G_PARALLEL_DETECT,
 				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK,
 				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT);
 
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 				MDIO_REG_BANK_10G_PARALLEL_DETECT,
 				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
 				&control2);
@@ -1142,15 +1167,13 @@ static void bnx2x_set_parallel_detection(struct link_params *params,
 		control2 |=
 		    MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN;
 
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				MDIO_REG_BANK_10G_PARALLEL_DETECT,
 				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
 				control2);
 
 		/* Disable parallel detection of HiG */
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				MDIO_REG_BANK_XGXS_BLOCK2,
 				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G,
 				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS |
@@ -1158,7 +1181,8 @@ static void bnx2x_set_parallel_detection(struct link_params *params,
 	}
 }
 
-static void bnx2x_set_autoneg(struct link_params *params,
+static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
+			      struct link_params *params,
 			    struct link_vars *vars,
 			    u8 enable_cl73)
 {
@@ -1166,9 +1190,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 	u16 reg_val;
 
 	/* CL37 Autoneg */
-
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
 
@@ -1179,15 +1201,13 @@ static void bnx2x_set_autoneg(struct link_params *params,
 		reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
 			     MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN);
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
 
 	/* Enable/Disable Autodetection */
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, &reg_val);
 	reg_val &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN |
@@ -1198,14 +1218,12 @@ static void bnx2x_set_autoneg(struct link_params *params,
 	else
 		reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, reg_val);
 
 	/* Enable TetonII and BAM autoneg */
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_BAM_NEXT_PAGE,
 			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
 			  &reg_val);
@@ -1218,23 +1236,20 @@ static void bnx2x_set_autoneg(struct link_params *params,
 		reg_val &= ~(MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE |
 			     MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN);
 	}
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_BAM_NEXT_PAGE,
 			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
 			      reg_val);
 
 	if (enable_cl73) {
 		/* Enable Cl73 FSM status bits */
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_CL73_USERB0,
 				    MDIO_CL73_USERB0_CL73_UCTRL,
 				      0xe);
 
 		/* Enable BAM Station Manager*/
-		CL45_WR_OVER_CL22(bp, params->port,
-			params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 			MDIO_REG_BANK_CL73_USERB0,
 			MDIO_CL73_USERB0_CL73_BAM_CTRL1,
 			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN |
@@ -1242,8 +1257,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN);
 
 		/* Advertise CL73 link speeds */
-			CL45_RD_OVER_CL22(bp, params->port,
-					      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 					      MDIO_REG_BANK_CL73_IEEEB1,
 					      MDIO_CL73_IEEEB1_AN_ADV2,
 					      &reg_val);
@@ -1254,8 +1268,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
 
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_CL73_IEEEB1,
 				      MDIO_CL73_IEEEB1_AN_ADV2,
 			      reg_val);
@@ -1266,22 +1279,21 @@ static void bnx2x_set_autoneg(struct link_params *params,
 	} else /* CL73 Autoneg Disabled */
 		reg_val = 0;
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_CL73_IEEEB0,
 			      MDIO_CL73_IEEEB0_CL73_AN_CONTROL, reg_val);
 }
 
 /* program SerDes, forced speed */
-static void bnx2x_program_serdes(struct link_params *params,
+static void bnx2x_program_serdes(struct bnx2x_phy *phy,
+				 struct link_params *params,
 			       struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
 
 	/* program duplex, disable autoneg and sgmii*/
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
 	reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX |
@@ -1289,15 +1301,13 @@ static void bnx2x_program_serdes(struct link_params *params,
 		     MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK);
 	if (params->req_duplex == DUPLEX_FULL)
 		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
 
 	/* program speed
 	   - needed only if the speed is greater than 1G (2.5G or 10G) */
-	CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_SERDES_DIGITAL,
 				      MDIO_SERDES_DIGITAL_MISC1, &reg_val);
 	/* clearing the speed value before setting the right speed */
@@ -1320,14 +1330,14 @@ static void bnx2x_program_serdes(struct link_params *params,
 				MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_13G;
 	}
 
-	CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_SERDES_DIGITAL,
 				      MDIO_SERDES_DIGITAL_MISC1, reg_val);
 
 }
 
-static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
+static void bnx2x_set_brcm_cl37_advertisment(struct bnx2x_phy *phy,
+					     struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
@@ -1339,18 +1349,17 @@ static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
 		val |= MDIO_OVER_1G_UP1_2_5G;
 	if (params->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
 		val |= MDIO_OVER_1G_UP1_10G;
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_OVER_1G,
 			      MDIO_OVER_1G_UP1, val);
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_OVER_1G,
 			      MDIO_OVER_1G_UP3, 0x400);
 }
 
-static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u16 *ieee_fc)
+static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
+				     struct link_params *params, u16 *ieee_fc)
 {
 	struct bnx2x *bp = params->bp;
 	*ieee_fc = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
@@ -1385,30 +1394,30 @@ static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u16 *ieee_fc)
 	DP(NETIF_MSG_LINK, "ieee_fc = 0x%x\n", *ieee_fc);
 }
 
-static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
+static void bnx2x_set_ieee_aneg_advertisment(struct bnx2x_phy *phy,
+					     struct link_params *params,
 					   u16 ieee_fc)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val;
 	/* for AN, we are always publishing full duplex */
 
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, ieee_fc);
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_CL73_IEEEB1,
 			      MDIO_CL73_IEEEB1_AN_ADV1, &val);
 	val &= ~MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_BOTH;
 	val |= ((ieee_fc<<3) & MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_MASK);
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_CL73_IEEEB1,
 			      MDIO_CL73_IEEEB1_AN_ADV1, val);
 }
 
-static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
+static void bnx2x_restart_autoneg(struct bnx2x_phy *phy,
+				  struct link_params *params,
+				  u8 enable_cl73)
 {
 	struct bnx2x *bp = params->bp;
 	u16 mii_control;
@@ -1417,14 +1426,12 @@ static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
 	/* Enable and restart BAM/CL37 aneg */
 
 	if (enable_cl73) {
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_CL73_IEEEB0,
 				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
 				      &mii_control);
 
-		CL45_WR_OVER_CL22(bp, params->port,
-				params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				MDIO_REG_BANK_CL73_IEEEB0,
 				MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
 				(mii_control |
@@ -1432,16 +1439,14 @@ static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
 				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN));
 	} else {
 
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_COMBO_IEEE0,
 				      MDIO_COMBO_IEEE0_MII_CONTROL,
 				      &mii_control);
 		DP(NETIF_MSG_LINK,
 			 "bnx2x_restart_autoneg mii_control before = 0x%x\n",
 			 mii_control);
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_COMBO_IEEE0,
 				      MDIO_COMBO_IEEE0_MII_CONTROL,
 				      (mii_control |
@@ -1450,7 +1455,8 @@ static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
 	}
 }
 
-static void bnx2x_initialize_sgmii_process(struct link_params *params,
+static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
+					   struct link_params *params,
 					 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
@@ -1458,8 +1464,7 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params,
 
 	/* in SGMII mode, the unicore is always slave */
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
 		      &control1);
@@ -1468,8 +1473,7 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params,
 	control1 &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE |
 		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET |
 		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_MSTR_MODE);
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
 			      control1);
@@ -1479,8 +1483,7 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params,
 		/* set speed, disable autoneg */
 		u16 mii_control;
 
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_COMBO_IEEE0,
 				      MDIO_COMBO_IEEE0_MII_CONTROL,
 				      &mii_control);
@@ -1511,15 +1514,14 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params,
 		if (params->req_duplex == DUPLEX_FULL)
 			mii_control |=
 				MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_COMBO_IEEE0,
 				      MDIO_COMBO_IEEE0_MII_CONTROL,
 				      mii_control);
 
 	} else { /* AN mode */
 		/* enable and restart AN */
-		bnx2x_restart_autoneg(params, 0);
+		bnx2x_restart_autoneg(phy, params, 0);
 	}
 }
 
@@ -1551,43 +1553,31 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 	}
 }
 
-static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
-				  struct link_vars *vars)
+static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
+				   struct link_params *params,
+				   struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_addr;
 	u16 ld_pause;		/* local */
 	u16 lp_pause;		/* link partner */
 	u16 an_complete;	/* AN complete */
 	u16 pause_result;
 	u8 ret = 0;
-	u32 ext_phy_type;
-	u8 port = params->port;
-	ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	/* read twice */
 
-	bnx2x_cl45_read(bp, port,
-		      ext_phy_type,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_AN_DEVAD,
 		      MDIO_AN_REG_STATUS, &an_complete);
-	bnx2x_cl45_read(bp, port,
-		      ext_phy_type,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_AN_DEVAD,
 		      MDIO_AN_REG_STATUS, &an_complete);
 
 	if (an_complete & MDIO_AN_REG_STATUS_AN_COMPLETE) {
 		ret = 1;
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_AN_DEVAD,
 			      MDIO_AN_REG_ADV_PAUSE, &ld_pause);
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_AN_DEVAD,
 			      MDIO_AN_REG_LP_AUTO_NEG, &lp_pause);
 		pause_result = (ld_pause &
@@ -1598,16 +1588,12 @@ static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
 		   pause_result);
 		bnx2x_pause_resolve(vars, pause_result);
 		if (vars->flow_ctrl == BNX2X_FLOW_CTRL_NONE &&
-		     ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-			bnx2x_cl45_read(bp, port,
-				      ext_phy_type,
-				      ext_phy_addr,
+		     phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_AN_DEVAD,
 				      MDIO_AN_REG_CL37_FC_LD, &ld_pause);
 
-			bnx2x_cl45_read(bp, port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_AN_DEVAD,
 				      MDIO_AN_REG_CL37_FC_LP, &lp_pause);
 			pause_result = (ld_pause &
@@ -1623,17 +1609,16 @@ static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
 	return ret;
 }
 
-static u8 bnx2x_direct_parallel_detect_used(struct link_params *params)
+static u8 bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
+					    struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 pd_10g, status2_1000x;
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
 			      &status2_1000x);
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
 			      &status2_1000x);
@@ -1643,8 +1628,7 @@ static u8 bnx2x_direct_parallel_detect_used(struct link_params *params)
 		return 1;
 	}
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_10G_PARALLEL_DETECT,
 			      MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS,
 			      &pd_10g);
@@ -1657,9 +1641,10 @@ static u8 bnx2x_direct_parallel_detect_used(struct link_params *params)
 	return 0;
 }
 
-static void bnx2x_flow_ctrl_resolve(struct link_params *params,
-				  struct link_vars *vars,
-				  u32 gp_status)
+static void bnx2x_flow_ctrl_resolve(struct bnx2x_phy *phy,
+				    struct link_params *params,
+				    struct link_vars *vars,
+				    u32 gp_status)
 {
 	struct bnx2x *bp = params->bp;
 	u16 ld_pause;   /* local driver */
@@ -1672,9 +1657,8 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 	if ((params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
 	    (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) &&
 	    (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
-	    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-	     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)) {
-		if (bnx2x_direct_parallel_detect_used(params)) {
+	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)) {
+		if (bnx2x_direct_parallel_detect_used(phy, params)) {
 			vars->flow_ctrl = params->req_fc_auto_adv;
 			return;
 		}
@@ -1684,13 +1668,11 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 		    (MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE |
 		     MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE)) {
 
-			CL45_RD_OVER_CL22(bp, params->port,
-					      params->phy_addr,
+			CL45_RD_OVER_CL22(bp, phy,
 					      MDIO_REG_BANK_CL73_IEEEB1,
 					      MDIO_CL73_IEEEB1_AN_ADV1,
 					      &ld_pause);
-			CL45_RD_OVER_CL22(bp, params->port,
-					     params->phy_addr,
+			CL45_RD_OVER_CL22(bp, phy,
 					     MDIO_REG_BANK_CL73_IEEEB1,
 					     MDIO_CL73_IEEEB1_AN_LP_ADV1,
 					     &lp_pause);
@@ -1703,14 +1685,11 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 			DP(NETIF_MSG_LINK, "pause_result CL73 0x%x\n",
 				 pause_result);
 		} else {
-
-			CL45_RD_OVER_CL22(bp, params->port,
-					      params->phy_addr,
+			CL45_RD_OVER_CL22(bp, phy,
 					      MDIO_REG_BANK_COMBO_IEEE0,
 					      MDIO_COMBO_IEEE0_AUTO_NEG_ADV,
 					      &ld_pause);
-			CL45_RD_OVER_CL22(bp, params->port,
-			       params->phy_addr,
+			CL45_RD_OVER_CL22(bp, phy,
 			       MDIO_REG_BANK_COMBO_IEEE0,
 			       MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1,
 			       &lp_pause);
@@ -1723,7 +1702,7 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 		}
 		bnx2x_pause_resolve(vars, pause_result);
 	} else if ((params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
-		   (bnx2x_ext_phy_resolve_fc(params, vars))) {
+		   (bnx2x_ext_phy_resolve_fc(phy, params, vars))) {
 		return;
 	} else {
 		if (params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO)
@@ -1734,14 +1713,14 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 	DP(NETIF_MSG_LINK, "flow_ctrl 0x%x\n", vars->flow_ctrl);
 }
 
-static void bnx2x_check_fallback_to_cl37(struct link_params *params)
+static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
+					 struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 rx_status, ustat_val, cl37_fsm_recieved;
 	DP(NETIF_MSG_LINK, "bnx2x_check_fallback_to_cl37\n");
 	/* Step 1: Make sure signal is detected */
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_RX0,
 			      MDIO_RX0_RX_STATUS,
 			      &rx_status);
@@ -1749,16 +1728,14 @@ static void bnx2x_check_fallback_to_cl37(struct link_params *params)
 	    (MDIO_RX0_RX_STATUS_SIGDET)) {
 		DP(NETIF_MSG_LINK, "Signal is not detected. Restoring CL73."
 			     "rx_status(0x80b0) = 0x%x\n", rx_status);
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_WR_OVER_CL22(bp, phy,
 				      MDIO_REG_BANK_CL73_IEEEB0,
 				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
 				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN);
 		return;
 	}
 	/* Step 2: Check CL73 state machine */
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_CL73_USERB0,
 			      MDIO_CL73_USERB0_CL73_USTAT1,
 			      &ustat_val);
@@ -1773,8 +1750,7 @@ static void bnx2x_check_fallback_to_cl37(struct link_params *params)
 	}
 	/* Step 3: Check CL37 Message Pages received to indicate LP
 	supports only CL37 */
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_REMOTE_PHY,
 			      MDIO_REMOTE_PHY_MISC_RX_STATUS,
 			      &cl37_fsm_recieved);
@@ -1792,13 +1768,12 @@ static void bnx2x_check_fallback_to_cl37(struct link_params *params)
 	connected to a device which does not support cl73, but does support
 	cl37 BAM. In this case we disable cl73 and restart cl37 auto-neg */
 	/* Disable CL73 */
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_CL73_IEEEB0,
 			      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
 			      0);
 	/* Restart CL37 autoneg */
-	bnx2x_restart_autoneg(params, 0);
+	bnx2x_restart_autoneg(phy, params, 0);
 	DP(NETIF_MSG_LINK, "Disabling CL73, and restarting CL37 autoneg\n");
 }
 static u8 bnx2x_link_settings_status(struct link_params *params,
@@ -1809,8 +1784,8 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u16 new_line_speed;
 	u8 rc = 0;
+	u32 ext_phy_type;
 	vars->link_status = 0;
-
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
 		DP(NETIF_MSG_LINK, "phy link up gp_status=0x%x\n",
 			 gp_status);
@@ -1823,7 +1798,8 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		else
 			vars->duplex = DUPLEX_HALF;
 
-		bnx2x_flow_ctrl_resolve(params, vars, gp_status);
+		bnx2x_flow_ctrl_resolve(&params->phy[INT_PHY],
+					params, vars, gp_status);
 
 		switch (gp_status & GP_STATUS_SPEED_MASK) {
 		case GP_STATUS_10M:
@@ -1909,8 +1885,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		Comes to deals with possible FIFO glitch due to clk change
 		when speed is decreased without link down indicator */
 		if (new_line_speed != vars->line_speed) {
-			if (XGXS_EXT_PHY_TYPE(params->ext_phy_config) !=
-			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT &&
+			if (!SINGLE_MEDIA_DIRECT(params) &&
 			    ext_phy_link_up) {
 				DP(NETIF_MSG_LINK, "Internal link speed %d is"
 					    " different than the external"
@@ -1925,15 +1900,15 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		}
 		vars->line_speed = new_line_speed;
 		vars->link_status |= LINK_STATUS_SERDES_LINK;
-
+		ext_phy_type = params->phy[EXT_PHY1].type;
 		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
-		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		    ((ext_phy_type ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
-		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		    (ext_phy_type ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		    (ext_phy_type ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
-		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		    (ext_phy_type ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726))) {
 			vars->autoneg = AUTO_NEG_ENABLED;
 
@@ -1956,6 +1931,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 			vars->link_status |=
 				LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
 
+
 	} else { /* link_down */
 		DP(NETIF_MSG_LINK, "phy link down\n");
 
@@ -1967,10 +1943,10 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		vars->mac_type = MAC_TYPE_NONE;
 
 		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
-		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT))) {
+		    (SINGLE_MEDIA_DIRECT(params))) {
 			/* Check signal is detected */
-			bnx2x_check_fallback_to_cl37(params);
+			bnx2x_check_fallback_to_cl37(&params->phy[INT_PHY],
+						     params);
 		}
 	}
 
@@ -1988,13 +1964,13 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
+	struct bnx2x_phy *phy = &params->phy[INT_PHY];
 	u16 lp_up2;
 	u16 tx_driver;
 	u16 bank;
 
 	/* read precomp */
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_OVER_1G,
 			      MDIO_OVER_1G_LP_UP2, &lp_up2);
 
@@ -2008,8 +1984,7 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 
 	for (bank = MDIO_REG_BANK_TX0; bank <= MDIO_REG_BANK_TX3;
 	      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0)) {
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
+		CL45_RD_OVER_CL22(bp, phy,
 				      bank,
 				      MDIO_TX0_TX_DRIVER, &tx_driver);
 
@@ -2018,8 +1993,7 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 		    (tx_driver & MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK)) {
 			tx_driver &= ~MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK;
 			tx_driver |= lp_up2;
-			CL45_WR_OVER_CL22(bp, params->port,
-					      params->phy_addr,
+			CL45_WR_OVER_CL22(bp, phy,
 					      bank,
 					      MDIO_TX0_TX_DRIVER, tx_driver);
 		}
@@ -2072,6 +2046,7 @@ static u8 bnx2x_emac_program(struct link_params *params,
 	return 0;
 }
 
+
 /*****************************************************************************/
 /*      		     External Phy section       		     */
 /*****************************************************************************/
@@ -2084,21 +2059,16 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 		      MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
 
-static void bnx2x_ext_phy_reset(struct link_params *params,
-			      struct link_vars   *vars)
+static void bnx2x_ext_phy_reset(struct bnx2x_phy   *phy,
+				struct link_params *params,
+				struct link_vars   *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u32 ext_phy_type;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-
 	DP(NETIF_MSG_LINK, "Port %x: bnx2x_ext_phy_reset\n", params->port);
-	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	/* The PHY reset is controled by GPIO 1
 	 * Give it 1ms of reset pulse
 	 */
-	if (vars->phy_flags & PHY_XGXS_FLAG) {
-
-		switch (ext_phy_type) {
+		switch (phy->type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 			DP(NETIF_MSG_LINK, "XGXS Direct\n");
 			break;
@@ -2115,9 +2085,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			/* HW reset */
 			bnx2x_ext_phy_hw_reset(bp, params->port);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL, 0xa040);
 			break;
@@ -2136,9 +2104,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 					  MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 					  params->port);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL,
 				       1<<15);
@@ -2153,9 +2119,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 					  params->port);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL,
 				       1<<15);
@@ -2195,9 +2159,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			/* HW reset */
 			bnx2x_ext_phy_hw_reset(bp, params->port);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL,
 				       1<<15);
@@ -2211,31 +2173,11 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK, "XGXS PHY Failure detected\n");
 			break;
-
 		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   params->ext_phy_config);
+			DP(NETIF_MSG_LINK, "BAD phy type 0x%x\n",
+				 phy->type);
 			break;
 		}
-
-	} else { /* SerDes */
-		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			bnx2x_ext_phy_hw_reset(bp, params->port);
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
-				 params->ext_phy_config);
-			break;
-		}
-	}
 }
 
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
@@ -2250,59 +2192,49 @@ static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
 }
 
 static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp, u8 port,
-				    u32 ext_phy_type, u8 ext_phy_addr,
-				    u32 shmem_base)
+				      struct bnx2x_phy *phy,
+				      u32 shmem_base)
 {
 	u16 fw_ver1, fw_ver2;
 
-	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr, MDIO_PMA_DEVAD,
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
-	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr, MDIO_PMA_DEVAD,
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER2, &fw_ver2);
 	bnx2x_save_spirom_version(bp, port, shmem_base,
 				(u32)(fw_ver1<<16 | fw_ver2));
 }
 
-
-static void bnx2x_save_8481_spirom_version(struct bnx2x *bp, u8 port,
-					 u8 ext_phy_addr, u32 shmem_base)
+static void bnx2x_save_8481_spirom_version(struct bnx2x_phy *phy,
+					   struct link_params *params,
+					   u32 shmem_base)
 {
 	u16 val, fw_ver1, fw_ver2, cnt;
-	/* For the 32 bits registers in 8481, access via MDIO2ARM interface.*/
+	struct bnx2x *bp = params->bp;
+
+	/* For the 32 bits registers in 848xx, access via MDIO2ARM interface.*/
 	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr, MDIO_PMA_DEVAD,
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 		       0xA819, 0x0014);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       0xA81A,
 		       0xc200);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       0xA81B,
 		       0x0000);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       0xA81C,
 		       0x0300);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       0xA817,
 		       0x0009);
 
 	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      0xA818,
 			      &val);
@@ -2312,29 +2244,21 @@ static void bnx2x_save_8481_spirom_version(struct bnx2x *bp, u8 port,
 	}
 	if (cnt == 100) {
 		DP(NETIF_MSG_LINK, "Unable to read 8481 phy fw version(1)\n");
-		bnx2x_save_spirom_version(bp, port,
+		bnx2x_save_spirom_version(bp, params->port,
 					shmem_base, 0);
 		return;
 	}
 

 	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr, MDIO_PMA_DEVAD,
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 		       0xA819, 0x0000);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr, MDIO_PMA_DEVAD,
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 		       0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		       ext_phy_addr, MDIO_PMA_DEVAD,
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 		       0xA817, 0x000A);
 	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      0xA818,
 			      &val);
@@ -2344,58 +2268,53 @@ static void bnx2x_save_8481_spirom_version(struct bnx2x *bp, u8 port,
 	}
 	if (cnt == 100) {
 		DP(NETIF_MSG_LINK, "Unable to read 8481 phy fw version(2)\n");
-		bnx2x_save_spirom_version(bp, port,
+		bnx2x_save_spirom_version(bp, params->port,
 					shmem_base, 0);
 		return;
 	}
 
 	/* lower 16 bits of the register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      0xA81B,
 		      &fw_ver1);
 	/* upper 16 bits of register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      0xA81C,
 		      &fw_ver2);
 
-	bnx2x_save_spirom_version(bp, port,
+	bnx2x_save_spirom_version(bp, params->port,
 				shmem_base, (fw_ver2<<16) | fw_ver1);
 }
 
-static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
+static void bnx2x_bcm8072_external_rom_boot(struct bnx2x_phy *phy,
+					    struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* Need to wait 200ms after reset */
 	msleep(200);
 	/* Boot port from external ROM
 	 * Set ser_boot_ctl bit in the MISC_CTRL1 register
 	 */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			    MDIO_PMA_DEVAD,
 			    MDIO_PMA_REG_MISC_CTRL1, 0x0001);
 
 	/* Reset internal microprocessor */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			  MDIO_PMA_DEVAD,
 			  MDIO_PMA_REG_GEN_CTRL,
 			  MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 	/* set micro reset = 0 */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			    MDIO_PMA_DEVAD,
 			    MDIO_PMA_REG_GEN_CTRL,
 			    MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 	/* Reset internal microprocessor */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			  MDIO_PMA_DEVAD,
 			  MDIO_PMA_REG_GEN_CTRL,
 			  MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
@@ -2403,30 +2322,24 @@ static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
 	msleep(100);
 
 	/* Clear ser_boot_ctl bit */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			    MDIO_PMA_DEVAD,
 			    MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 	/* Wait 100ms */
 	msleep(100);
 
 	bnx2x_save_bcm_spirom_ver(bp, port,
-				ext_phy_type,
-				ext_phy_addr,
+				phy,
 				params->shmem_base);
 }
 
-static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
+static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
 	/* This is only required for 8073A1, version 102 only */
-
-	struct bnx2x *bp = params->bp;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u16 val;
 
 	/* Read 8073 HW revision*/
-	bnx2x_cl45_read(bp, params->port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_8073_CHIP_REV, &val);
 
@@ -2435,9 +2348,7 @@ static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
 		return 0;
 	}
 
-	bnx2x_cl45_read(bp, params->port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER2, &val);
 
@@ -2447,16 +2358,11 @@ static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
 
 	return 1;
 }
-
-static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
+static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u16 val, cnt, cnt1 ;
 
-	bnx2x_cl45_read(bp, params->port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_8073_CHIP_REV, &val);
 
@@ -2470,9 +2376,7 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 	poll Dev1, Reg $C820: */
 
 	for (cnt = 0; cnt < 1000; cnt++) {
-		bnx2x_cl45_read(bp, params->port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
 			      &val);
@@ -2489,9 +2393,7 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 			  XAUI workaround has completed),
 			  then continue on with system initialization.*/
 			for (cnt1 = 0; cnt1 < 1000; cnt1++) {
-				bnx2x_cl45_read(bp, params->port,
-					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-					ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					MDIO_PMA_DEVAD,
 					MDIO_PMA_REG_8073_XAUI_WA, &val);
 				if (val & (1<<15)) {
@@ -2509,46 +2411,35 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 	return -EINVAL;
 }
 
-static void bnx2x_bcm8073_bcm8727_external_rom_boot(struct bnx2x *bp, u8 port,
-						  u8 ext_phy_addr,
-						  u32 ext_phy_type,
-						  u32 shmem_base)
+static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
+					      struct bnx2x_phy *phy,
+					      u8 port, u32 shmem_base)
 {
 	/* Boot port from external ROM  */
 	/* EDC grst */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       0x0001);
 
 	/* ucode reboot and rst */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       0x008c);
 
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
 
 	/* Reset internal microprocessor */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 
 	/* Release srst bit */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
@@ -2557,64 +2448,36 @@ static void bnx2x_bcm8073_bcm8727_external_rom_boot(struct bnx2x *bp, u8 port,
 	msleep(120);
 
 	/* Clear ser_boot_ctl bit */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
-
-	bnx2x_save_bcm_spirom_ver(bp, port,
-				ext_phy_type,
-				ext_phy_addr,
-				shmem_base);
-}
-
-static void bnx2x_bcm8073_external_rom_boot(struct bnx2x *bp, u8 port,
-					  u8 ext_phy_addr,
-					  u32 shmem_base)
-{
-	bnx2x_bcm8073_bcm8727_external_rom_boot(bp, port, ext_phy_addr,
-					 PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-					 shmem_base);
-}
-
-static void bnx2x_bcm8727_external_rom_boot(struct bnx2x *bp, u8 port,
-					  u8 ext_phy_addr,
-					  u32 shmem_base)
-{
-	bnx2x_bcm8073_bcm8727_external_rom_boot(bp, port, ext_phy_addr,
-					 PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-					 shmem_base);
-
+	bnx2x_save_bcm_spirom_ver(bp, port, phy, shmem_base);
 }
 
-static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
+static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
+					 struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
 	/* Need to wait 100ms after reset */
 	msleep(100);
 
 	/* Micro controller re-boot */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       0x018B);
 
 	/* Set soft reset */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
 
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
@@ -2623,29 +2486,25 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 	msleep(150);
 
 	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 
 	msleep(200);
-	bnx2x_save_bcm_spirom_ver(bp, port,
-				ext_phy_type,
-				ext_phy_addr,
+	bnx2x_save_bcm_spirom_ver(bp, params->port,
+				phy,
 				params->shmem_base);
 }
 
-static void bnx2x_sfp_set_transmitter(struct bnx2x *bp, u8 port,
-				    u32 ext_phy_type, u8 ext_phy_addr,
-				    u8 tx_en)
+static void bnx2x_sfp_set_transmitter(struct bnx2x *bp,
+				      struct bnx2x_phy *phy,
+				      u8 tx_en)
 {
 	u16 val;
 
-	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x for port %x\n",
-		 tx_en, port);
+	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x\n", tx_en);
 	/* Disable/Enable transmitter ( TX laser of the SFP+ module.)*/
-	bnx2x_cl45_read(bp, port,
-		      ext_phy_type,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_PHY_IDENTIFIER,
 		      &val);
@@ -2655,58 +2514,42 @@ static void bnx2x_sfp_set_transmitter(struct bnx2x *bp, u8 port,
 	else
 		val |= (1<<15);
 
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_PHY_IDENTIFIER,
 		       val);
 }
 
-static u8 bnx2x_8726_read_sfp_module_eeprom(struct link_params *params,
+static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+					    struct link_params *params,
 					  u16 addr, u8 byte_cnt, u8 *o_buf)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
 	u16 i;
-	u8 port = params->port;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
 	if (byte_cnt > 16) {
 		DP(NETIF_MSG_LINK, "Reading from eeprom is"
 			    " is limited to 0xf\n");
 		return -EINVAL;
 	}
 	/* Set the read command byte count */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
 		       (byte_cnt | 0xa000));
 
 	/* Set the read command address */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_SFP_TWO_WIRE_MEM_ADDR,
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_MEM_ADDR,
 		       addr);
 
 	/* Activate read command */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
 		       0x2c0f);
 
 	/* Wait up to 500us for command complete status */
 	for (i = 0; i < 100; i++) {
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
@@ -2725,36 +2568,30 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct link_params *params,
 
 	/* Read the buffer */
 	for (i = 0; i < byte_cnt; i++) {
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_8726_TWO_WIRE_DATA_BUF + i, &val);
 		o_buf[i] = (u8)(val & MDIO_PMA_REG_8726_TWO_WIRE_DATA_MASK);
 	}
 
 	for (i = 0; i < 100; i++) {
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_IDLE)
-			return 0;;
+			return 0;
 		msleep(1);
 	}
 	return -EINVAL;
 }
 
-static u8 bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
+static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+					    struct link_params *params,
 					  u16 addr, u8 byte_cnt, u8 *o_buf)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val, i;
-	u8 port = params->port;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	if (byte_cnt > 16) {
 		DP(NETIF_MSG_LINK, "Reading from eeprom is"
@@ -2763,40 +2600,30 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
 	}
 
 	/* Need to read from 1.8000 to clear it */
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
 		      &val);
 
 	/* Set the read command byte count */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
 		       ((byte_cnt < 2) ? 2 : byte_cnt));
 
 	/* Set the read command address */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_SFP_TWO_WIRE_MEM_ADDR,
 		       addr);
 	/* Set the destination address */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       0x8004,
 		       MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF);
 
 	/* Activate read command */
-	bnx2x_cl45_write(bp, port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
 		       0x8002);
@@ -2806,9 +2633,7 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
 
 	/* Wait up to 500us for command complete status */
 	for (i = 0; i < 100; i++) {
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
@@ -2827,18 +2652,14 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
 
 	/* Read the buffer */
 	for (i = 0; i < byte_cnt; i++) {
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF + i, &val);
 		o_buf[i] = (u8)(val & MDIO_PMA_REG_8727_TWO_WIRE_DATA_MASK);
 	}
 
 	for (i = 0; i < 100; i++) {
-		bnx2x_cl45_read(bp, port,
-			      ext_phy_type,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
@@ -2850,21 +2671,21 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
 	return -EINVAL;
 }
 
-u8 bnx2x_read_sfp_module_eeprom(struct link_params *params, u16 addr,
+u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+				struct link_params *params, u16 addr,
 				     u8 byte_cnt, u8 *o_buf)
 {
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
-	if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
-		return bnx2x_8726_read_sfp_module_eeprom(params, addr,
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
+		return bnx2x_8726_read_sfp_module_eeprom(phy, params, addr,
 						       byte_cnt, o_buf);
-	else if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
-		return bnx2x_8727_read_sfp_module_eeprom(params, addr,
+	else if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
+		return bnx2x_8727_read_sfp_module_eeprom(phy, params, addr,
 						       byte_cnt, o_buf);
 	return -EINVAL;
 }
 
-static u8 bnx2x_get_edc_mode(struct link_params *params,
+static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
+			     struct link_params *params,
 				  u16 *edc_mode)
 {
 	struct bnx2x *bp = params->bp;
@@ -2872,7 +2693,7 @@ static u8 bnx2x_get_edc_mode(struct link_params *params,
 	*edc_mode = EDC_MODE_LIMITING;
 
 	/* First check for copper cable */
-	if (bnx2x_read_sfp_module_eeprom(params,
+	if (bnx2x_read_sfp_module_eeprom(phy, params,
 				       SFP_EEPROM_CON_TYPE_ADDR,
 				       1,
 				       &val) != 0) {
@@ -2887,7 +2708,7 @@ static u8 bnx2x_get_edc_mode(struct link_params *params,
 
 		/* Check if its active cable( includes SFP+ module)
 		of passive cable*/
-		if (bnx2x_read_sfp_module_eeprom(params,
+		if (bnx2x_read_sfp_module_eeprom(phy, params,
 					       SFP_EEPROM_FC_TX_TECH_ADDR,
 					       1,
 					       &copper_module_type) !=
@@ -2927,7 +2748,7 @@ static u8 bnx2x_get_edc_mode(struct link_params *params,
 
 	if (check_limiting_mode) {
 		u8 options[SFP_EEPROM_OPTIONS_SIZE];
-		if (bnx2x_read_sfp_module_eeprom(params,
+		if (bnx2x_read_sfp_module_eeprom(phy, params,
 					       SFP_EEPROM_OPTIONS_ADDR,
 					       SFP_EEPROM_OPTIONS_SIZE,
 					       options) != 0) {
@@ -2943,10 +2764,10 @@ static u8 bnx2x_get_edc_mode(struct link_params *params,
 	DP(NETIF_MSG_LINK, "EDC mode is set to 0x%x\n", *edc_mode);
 	return 0;
 }
-
 /* This function read the relevant field from the module ( SFP+ ),
 	and verify it is compliant with this board */
-static u8 bnx2x_verify_sfp_module(struct link_params *params)
+static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
+				  struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u32 val;
@@ -2978,14 +2799,14 @@ static u8 bnx2x_verify_sfp_module(struct link_params *params)
 	}
 
 	/* format the warning message */
-	if (bnx2x_read_sfp_module_eeprom(params,
+	if (bnx2x_read_sfp_module_eeprom(phy, params,
 				       SFP_EEPROM_VENDOR_NAME_ADDR,
 				       SFP_EEPROM_VENDOR_NAME_SIZE,
 				       (u8 *)vendor_name))
 		vendor_name[0] = '\0';
 	else
 		vendor_name[SFP_EEPROM_VENDOR_NAME_SIZE] = '\0';
-	if (bnx2x_read_sfp_module_eeprom(params,
+	if (bnx2x_read_sfp_module_eeprom(phy, params,
 				       SFP_EEPROM_PART_NO_ADDR,
 				       SFP_EEPROM_PART_NO_SIZE,
 				       (u8 *)vendor_pn))
@@ -2993,22 +2814,19 @@ static u8 bnx2x_verify_sfp_module(struct link_params *params)
 	else
 		vendor_pn[SFP_EEPROM_PART_NO_SIZE] = '\0';
 
-	netdev_info(bp->dev, "Warning: Unqualified SFP+ module detected, Port %d from %s part number %s\n",
+	netdev_info(bp->dev, "Warning: Unqualified SFP+ module detected,"
+			     " Port %d from %s part number %s\n",
 		    params->port, vendor_name, vendor_pn);
 	return -EINVAL;
 }
 
-static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
+static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
+				       struct bnx2x_phy *phy,
 					u16 edc_mode)
 {
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u16 cur_limiting_mode;
 
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER2,
 		      &cur_limiting_mode);
@@ -3018,9 +2836,7 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 	if (edc_mode == EDC_MODE_LIMITING) {
 		DP(NETIF_MSG_LINK,
 			 "Setting LIMITING MODE\n");
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-			       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_ROM_VER2,
 			       EDC_MODE_LIMITING);
@@ -3034,27 +2850,19 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 		if (cur_limiting_mode != EDC_MODE_LIMITING)
 			return 0;
 
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-			       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_LRM_MODE,
 			       0);
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-			       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_ROM_VER2,
 			       0x128);
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-			       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_MISC_CTRL0,
 			       0x4008);
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-			       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_LRM_MODE,
 			       0xaaaa);
@@ -3062,46 +2870,33 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 	return 0;
 }
 
-static u8 bnx2x_bcm8727_set_limiting_mode(struct link_params *params,
+static u8 bnx2x_8727_set_limiting_mode(struct bnx2x *bp,
+				       struct bnx2x_phy *phy,
 					u16 edc_mode)
 {
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
 	u16 phy_identifier;
 	u16 rom_ver2_val;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-
-	bnx2x_cl45_read(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		       ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_PHY_IDENTIFIER,
 		       &phy_identifier);
 
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_PHY_IDENTIFIER,
 		       (phy_identifier & ~(1<<9)));
 
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER2,
 		      &rom_ver2_val);
 	/* Keep the MSB 8-bits, and set the LSB 8-bits with the edc_mode */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_ROM_VER2,
 		       (rom_ver2_val & 0xff00) | (edc_mode & 0x00ff));
 
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_PHY_IDENTIFIER,
 		       (phy_identifier | (1<<9)));
@@ -3110,7 +2905,9 @@ static u8 bnx2x_bcm8727_set_limiting_mode(struct link_params *params,
 }
 

-static u8 bnx2x_wait_for_sfp_module_initialized(struct link_params *params)
+static u8 bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
+						struct link_params *params)
+
 {
 	u8 val;
 	struct bnx2x *bp = params->bp;
@@ -3118,7 +2915,7 @@ static u8 bnx2x_wait_for_sfp_module_initialized(struct link_params *params)
 	/* Initialization time after hot-plug may take up to 300ms for some
 	phys type ( e.g. JDSU ) */
 	for (timeout = 0; timeout < 60; timeout++) {
-		if (bnx2x_read_sfp_module_eeprom(params, 1, 1, &val)
+		if (bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val)
 		    == 0) {
 			DP(NETIF_MSG_LINK, "SFP+ module initialization "
 				     "took %d ms\n", timeout * 5);
@@ -3131,10 +2928,10 @@ static u8 bnx2x_wait_for_sfp_module_initialized(struct link_params *params)
 
 static void bnx2x_8727_power_module(struct bnx2x *bp,
 				  struct link_params *params,
-				  u8 ext_phy_addr, u8 is_power_up) {
+				    struct bnx2x_phy *phy,
+				    u8 is_power_up) {
 	/* Make sure GPIOs are not using for LED mode */
 	u16 val;
-	u8 port = params->port;
 	/*
 	 * In the GPIO register, bit 4 is use to detemine if the GPIOs are
 	 * operating as INPUT or as OUTPUT. Bit 1 is for input, and 0 for
@@ -3160,21 +2957,19 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 		 */
 		val = ((!(is_power_up)) << 1);
 
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_8727_GPIO_CTRL,
 		       val);
 }
 
-static u8 bnx2x_sfp_module_detection(struct link_params *params)
+static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
+				     struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 edc_mode;
 	u8 rc = 0;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+
 	u32 val = REG_RD(bp, params->shmem_base +
 			     offsetof(struct shmem_region, dev_info.
 				     port_feature_config[params->port].config));
@@ -3182,10 +2977,10 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 	DP(NETIF_MSG_LINK, "SFP+ module plugged in/out detected on port %d\n",
 		 params->port);
 
-	if (bnx2x_get_edc_mode(params, &edc_mode) != 0) {
+	if (bnx2x_get_edc_mode(phy, params, &edc_mode) != 0) {
 		DP(NETIF_MSG_LINK, "Failed to get valid module type\n");
 		return -EINVAL;
-	} else if (bnx2x_verify_sfp_module(params) !=
+	} else if (bnx2x_verify_sfp_module(phy, params) !=
 		   0) {
 		/* check SFP+ module compatibility */
 		DP(NETIF_MSG_LINK, "Module verification failed!!\n");
@@ -3194,13 +2989,12 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
 				  MISC_REGISTERS_GPIO_HIGH,
 				  params->port);
-		if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727) &&
+		if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727) &&
 		    ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		     PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_POWER_DOWN)) {
 			/* Shutdown SFP+ module */
 			DP(NETIF_MSG_LINK, "Shutdown SFP+ module!!\n");
-			bnx2x_8727_power_module(bp, params,
-					      ext_phy_addr, 0);
+			bnx2x_8727_power_module(bp, params, phy, 0);
 			return rc;
 		}
 	} else {
@@ -3212,15 +3006,15 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 	}
 
 	/* power up the SFP module */
-	if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
-		bnx2x_8727_power_module(bp, params, ext_phy_addr, 1);
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
+		bnx2x_8727_power_module(bp, params, phy, 1);
 
 	/* Check and set limiting mode / LRM mode on 8726.
 	On 8727 it is done automatically */
-	if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
-		bnx2x_bcm8726_set_limiting_mode(params, edc_mode);
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
+		bnx2x_8726_set_limiting_mode(bp, phy, edc_mode);
 	else
-		bnx2x_bcm8727_set_limiting_mode(params, edc_mode);
+		bnx2x_8727_set_limiting_mode(bp, phy, edc_mode);
 	/*
 	 * Enable transmit for this module if the module is approved, or
 	 * if unapproved modules should also enable the Tx laser
@@ -3228,11 +3022,9 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 	if (rc == 0 ||
 	    (val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) !=
 	    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-		bnx2x_sfp_set_transmitter(bp, params->port,
-					ext_phy_type, ext_phy_addr, 1);
+		bnx2x_sfp_set_transmitter(bp, phy, 1);
 	else
-		bnx2x_sfp_set_transmitter(bp, params->port,
-					ext_phy_type, ext_phy_addr, 0);
+		bnx2x_sfp_set_transmitter(bp, phy, 0);
 
 	return rc;
 }
@@ -3240,6 +3032,7 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 void bnx2x_handle_module_detect_int(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
+	struct bnx2x_phy *phy = &params->phy[EXT_PHY1];
 	u32 gpio_val;
 	u8 port = params->port;
 
@@ -3249,25 +3042,20 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 			  params->port);
 
 	/* Get current gpio val refelecting module plugged in / out*/
-	gpio_val = bnx2x_get_gpio(bp,  MISC_REGISTERS_GPIO_3, port);
+	gpio_val = bnx2x_get_gpio(bp, MISC_REGISTERS_GPIO_3, port);
 
 	/* Call the handling function in case module is detected */
 	if (gpio_val == 0) {
 
 		bnx2x_set_gpio_int(bp, MISC_REGISTERS_GPIO_3,
-				      MISC_REGISTERS_GPIO_INT_OUTPUT_CLR,
-				      port);
+				   MISC_REGISTERS_GPIO_INT_OUTPUT_CLR,
+				   port);
 
-		if (bnx2x_wait_for_sfp_module_initialized(params) ==
-		    0)
-			bnx2x_sfp_module_detection(params);
+		if (bnx2x_wait_for_sfp_module_initialized(phy, params) == 0)
+			bnx2x_sfp_module_detection(phy, params);
 		else
 			DP(NETIF_MSG_LINK, "SFP+ module is not initialized\n");
 	} else {
-		u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-
-		u32 ext_phy_type =
-			XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 		u32 val = REG_RD(bp, params->shmem_base +
 				     offsetof(struct shmem_region, dev_info.
 					      port_feature_config[params->port].
@@ -3280,48 +3068,36 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		/* Disable transmit for this module */
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-			bnx2x_sfp_set_transmitter(bp, params->port,
-						ext_phy_type, ext_phy_addr, 0);
+			bnx2x_sfp_set_transmitter(bp, phy, 0);
 	}
 }
 
-static void bnx2x_bcm807x_force_10G(struct link_params *params)
+static void bnx2x_807x_force_10G(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
 	/* Force KR or KX */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_CTRL,
 		       0x2040);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_10G_CTRL2,
 		       0x000b);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_BCM_CTRL,
 		       0x0000);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_AN_DEVAD,
 		       MDIO_AN_REG_CTRL,
 		       0x0000);
 }
 
-static void bnx2x_bcm8073_set_xaui_low_power_mode(struct link_params *params)
+static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
+					       struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
 	u16 val;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
-	bnx2x_cl45_read(bp, params->port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_8073_CHIP_REV, &val);
 
@@ -3331,67 +3107,63 @@ static void bnx2x_bcm8073_set_xaui_low_power_mode(struct link_params *params)
 	}
 
 	/* Disable PLL sequencer (use read-modify-write to clear bit 13) */
-	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		       MDIO_XS_DEVAD,
 		       MDIO_XS_PLL_SEQUENCER, &val);
 	val &= ~(1<<13);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
 
 	/* PLL controls */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x805E, 0x1077);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x805D, 0x0000);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x805C, 0x030B);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x805B, 0x1240);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x805A, 0x2490);
 
 	/* Tx Controls */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x80A7, 0x0C74);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x80A6, 0x9041);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x80A5, 0x4640);
 
 	/* Rx Controls */
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x80FE, 0x01C4);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x80FD, 0x9249);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, 0x80FC, 0x2015);
 
 	/* Enable PLL sequencer  (use read-modify-write to set bit 13) */
-	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		       MDIO_XS_DEVAD,
 		       MDIO_XS_PLL_SEQUENCER, &val);
 	val |= (1<<13);
-	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
 }
 
 static void bnx2x_8073_set_pause_cl37(struct link_params *params,
-				  struct link_vars *vars)
+				      struct bnx2x_phy *phy,
+				      struct link_vars *vars)
 {
-	struct bnx2x *bp = params->bp;
 	u16 cl37_val;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
-	bnx2x_cl45_read(bp, params->port,
-		      ext_phy_type,
-		      ext_phy_addr,
+	struct bnx2x *bp = params->bp;
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_AN_DEVAD,
 		      MDIO_AN_REG_CL37_FC_LD, &cl37_val);
 
 	cl37_val &= ~MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
 	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
-
+	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
 	if ((vars->ieee_fc &
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC) ==
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC) {
@@ -3410,26 +3182,20 @@ static void bnx2x_8073_set_pause_cl37(struct link_params *params,
 	DP(NETIF_MSG_LINK,
 		 "Ext phy AN advertize cl37 0x%x\n", cl37_val);
 
-	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_AN_DEVAD,
 		       MDIO_AN_REG_CL37_FC_LD, cl37_val);
 	msleep(500);
 }
 
 static void bnx2x_ext_phy_set_pause(struct link_params *params,
-				  struct link_vars *vars)
+				    struct bnx2x_phy *phy,
+				    struct link_vars *vars)
 {
-	struct bnx2x *bp = params->bp;
 	u16 val;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
+	struct bnx2x *bp = params->bp;
 	/* read modify write pause advertizing */
-	bnx2x_cl45_read(bp, params->port,
-		      ext_phy_type,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_AN_DEVAD,
 		      MDIO_AN_REG_ADV_PAUSE, &val);
 
@@ -3450,21 +3216,21 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 	}
 	DP(NETIF_MSG_LINK,
 		 "Ext phy AN advertize 0x%x\n", val);
-	bnx2x_cl45_write(bp, params->port,
-		       ext_phy_type,
-		       ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_AN_DEVAD,
 		       MDIO_AN_REG_ADV_PAUSE, val);
 }
-static void bnx2x_set_preemphasis(struct link_params *params)
+
+static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
+				  struct link_params *params)
 {
+
 	u16 bank, i = 0;
 	struct bnx2x *bp = params->bp;
 
 	for (bank = MDIO_REG_BANK_RX0, i = 0; bank <= MDIO_REG_BANK_RX3;
 	      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0), i++) {
-			CL45_WR_OVER_CL22(bp, params->port,
-					      params->phy_addr,
+			CL45_WR_OVER_CL22(bp, phy,
 					      bank,
 					      MDIO_RX0_RX_EQ_BOOST,
 					      params->xgxs_config_rx[i]);
@@ -3472,141 +3238,120 @@ static void bnx2x_set_preemphasis(struct link_params *params)
 
 	for (bank = MDIO_REG_BANK_TX0, i = 0; bank <= MDIO_REG_BANK_TX3;
 		      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0), i++) {
-			CL45_WR_OVER_CL22(bp, params->port,
-					      params->phy_addr,
+			CL45_WR_OVER_CL22(bp, phy,
 					      bank,
 					      MDIO_TX0_TX_DRIVER,
 					      params->xgxs_config_tx[i]);
 	}
 }
 
-
-static void bnx2x_8481_set_led(struct link_params *params,
-			       u32 ext_phy_type, u8 ext_phy_addr)
+static void bnx2x_8481_set_led(struct bnx2x *bp,
+				struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
 	u16 val;
-	bnx2x_cl45_read(bp, params->port,
-			ext_phy_type,
-			ext_phy_addr,
+
+	/* PHYC_CTL_LED_CTL */
+	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD,
 			MDIO_PMA_REG_8481_LINK_SIGNAL, &val);
 	val &= 0xFE00;
 	val |= 0x0092;
 
-	bnx2x_cl45_write(bp, params->port,
-			 ext_phy_type,
-			 ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
 
-	bnx2x_cl45_write(bp, params->port,
-			 ext_phy_type,
-			 ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LED1_MASK,
 			 0x80);
 
-	bnx2x_cl45_write(bp, params->port,
-			 ext_phy_type,
-			 ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LED2_MASK,
 			 0x18);
 
-	bnx2x_cl45_write(bp, params->port,
-			 ext_phy_type,
-			 ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_8481_LED3_MASK,
 			 0x0040);
 
 	/* 'Interrupt Mask' */
-	bnx2x_cl45_write(bp, params->port,
-			 ext_phy_type,
-			 ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 			 MDIO_AN_DEVAD,
 			 0xFFFB, 0xFFFD);
 }
 
-static void bnx2x_init_internal_phy(struct link_params *params,
-				  struct link_vars *vars,
-				  u8 enable_cl73)
+static void bnx2x_init_internal_phy(struct bnx2x_phy *phy,
+				    struct link_params *params,
+				    struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-
+	u8 enable_cl73 = (SINGLE_MEDIA_DIRECT(params) ||
+			  (params->loopback_mode == LOOPBACK_XGXS_10));
 	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
-		if ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		if (SINGLE_MEDIA_DIRECT(params) &&
 		    (params->feature_config_flags &
 		     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED))
-			bnx2x_set_preemphasis(params);
+			bnx2x_set_preemphasis(phy, params);
 
 		/* forced speed requested? */
 		if (vars->line_speed != SPEED_AUTO_NEG ||
-		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		    (SINGLE_MEDIA_DIRECT(params) &&
 			  params->loopback_mode == LOOPBACK_EXT)) {
 			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
 
 			/* disable autoneg */
-			bnx2x_set_autoneg(params, vars, 0);
+			bnx2x_set_autoneg(phy, params, vars, 0);
 
 			/* program speed and duplex */
-			bnx2x_program_serdes(params, vars);
+			bnx2x_program_serdes(phy, params, vars);
 
 		} else { /* AN_mode */
 			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
 
 			/* AN enabled */
-			bnx2x_set_brcm_cl37_advertisment(params);
+			bnx2x_set_brcm_cl37_advertisment(phy, params);
 
 			/* program duplex & pause advertisement (for aneg) */
-			bnx2x_set_ieee_aneg_advertisment(params,
+			bnx2x_set_ieee_aneg_advertisment(phy, params,
 						       vars->ieee_fc);
 
 			/* enable autoneg */
-			bnx2x_set_autoneg(params, vars, enable_cl73);
+			bnx2x_set_autoneg(phy, params, vars, enable_cl73);
 
 			/* enable and restart AN */
-			bnx2x_restart_autoneg(params, enable_cl73);
+			bnx2x_restart_autoneg(phy, params, enable_cl73);
 		}
 
 	} else { /* SGMII mode */
 		DP(NETIF_MSG_LINK, "SGMII\n");
 
-		bnx2x_initialize_sgmii_process(params, vars);
+		bnx2x_initialize_sgmii_process(phy, params, vars);
 	}
 }
 
 static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u32 ext_phy_type;
-	u8 ext_phy_addr;
 	u16 cnt;
 	u16 ctrl = 0;
 	u16 val = 0;
 	u8 rc = 0;
-
+	struct bnx2x_phy *phy = &params->phy[EXT_PHY1];
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-
-		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 		/* Make sure that the soft reset is off (expect for the 8072:
 		 * due to the lock, it will be done inside the specific
 		 * handling)
 		 */
-		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
-		   (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073)) {
+		if ((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
+		   (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN) &&
+		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) &&
+		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073)) {
 			/* Wait for soft reset to get cleared upto 1 sec */
 			for (cnt = 0; cnt < 1000; cnt++) {
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_CTRL, &ctrl);
 				if (!(ctrl & (1<<15)))
@@ -3617,34 +3362,26 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				 ctrl, cnt);
 		}
 
-		switch (ext_phy_type) {
+		switch (phy->type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 			DP(NETIF_MSG_LINK, "XGXS 8705\n");
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_MISC_CTRL,
 				       0x8288);
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_PHY_IDENTIFIER,
 				       0x7fbf);
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CMU_PLL_BYPASS,
 				       0x0100);
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_WIS_DEVAD,
 				       MDIO_WIS_REG_LASI_CNTL, 0x1);
 
@@ -3656,8 +3393,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 			/* Wait until fw is loaded */
 			for (cnt = 0; cnt < 100; cnt++) {
-				bnx2x_cl45_read(bp, params->port, ext_phy_type,
-					      ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_ROM_VER1, &val);
 				if (val)
 					break;
@@ -3673,9 +3409,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					reg = MDIO_XS_8706_REG_BANK_RX0 +
 						i*(MDIO_XS_8706_REG_BANK_RX1 -
 						   MDIO_XS_8706_REG_BANK_RX0);
-					bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
+					bnx2x_cl45_read(bp, phy,
 						      MDIO_XS_DEVAD,
 						      reg, &val);
 					/* Clear first 3 bits of the control */
@@ -3687,9 +3421,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					DP(NETIF_MSG_LINK, "Setting RX"
 						 "Equalizer to BCM8706 reg 0x%x"
 						 " <-- val 0x%x\n", reg, val);
-					bnx2x_cl45_write(bp, params->port,
-						       ext_phy_type,
-						       ext_phy_addr,
+					bnx2x_cl45_write(bp, phy,
 						       MDIO_XS_DEVAD,
 						       reg, val);
 				}
@@ -3698,14 +3430,11 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			if (params->req_line_speed == SPEED_10000) {
 				DP(NETIF_MSG_LINK, "XGXS 8706 force 10Gbps\n");
 
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_DIGITAL_CTRL,
 					       0x400);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_LASI_CTRL, 1);
 			} else {
 				/* Force 1Gbps using autoneg with 1G
@@ -3713,85 +3442,66 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 
 				/* Allow CL37 through CL73 */
 				DP(NETIF_MSG_LINK, "XGXS 8706 AutoNeg\n");
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_CL73,
 					       0x040c);
 
 				/* Enable Full-Duplex advertisment on CL37 */
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_FC_LP,
 					       0x0020);
 				/* Enable CL37 AN */
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_AN,
 					       0x1000);
 				/* 1G support */
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_ADV, (1<<5));
 
 				/* Enable clause 73 AN */
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CTRL,
 					       0x1200);
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_RX_ALARM_CTRL,
 					       0x0400);
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_LASI_CTRL, 0x0004);
 
 			}
 			bnx2x_save_bcm_spirom_ver(bp, params->port,
-						ext_phy_type,
-						ext_phy_addr,
+						phy,
 						params->shmem_base);
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 			DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
-			bnx2x_bcm8726_external_rom_boot(params);
+			bnx2x_8726_external_rom_boot(phy, params);
 
 			/* Need to call module detected on initialization since
 			the module detection triggered by actual module
 			insertion might occur before driver is loaded, and when
 			driver is loaded, it reset all registers, including the
 			transmitter */
-			bnx2x_sfp_module_detection(params);
+			bnx2x_sfp_module_detection(phy, params);
 
 			/* Set Flow control */
-			bnx2x_ext_phy_set_pause(params, vars);
+			bnx2x_ext_phy_set_pause(params, phy, vars);
 			if (params->req_line_speed == SPEED_1000) {
 				DP(NETIF_MSG_LINK, "Setting 1G force\n");
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_CTRL, 0x40);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_10G_CTRL2, 0xD);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_LASI_CTRL, 0x5);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_RX_ALARM_CTRL,
 					       0x400);
 			} else if ((params->req_line_speed ==
@@ -3799,35 +3509,27 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				   ((params->speed_cap_mask &
 				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))) {
 				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_ADV, 0x20);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_CL73, 0x040c);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_FC_LD, 0x0020);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_AN, 0x1000);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CTRL, 0x1200);
 
 				/* Enable RX-ALARM control to receive
 				interrupt for 1G speed change */
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_LASI_CTRL, 0x4);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_RX_ALARM_CTRL,
 					       0x400);
 
 			} else { /* Default 10G. Set only LASI control */
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_LASI_CTRL, 1);
 			}
 
@@ -3838,16 +3540,12 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					 "TX_CTRL2 0x%x\n",
 					 params->xgxs_config_tx[0],
 					 params->xgxs_config_tx[1]);
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8726_TX_CTRL1,
 					       params->xgxs_config_tx[0]);
 
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8726_TX_CTRL2,
 					       params->xgxs_config_tx[1]);
@@ -3859,7 +3557,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			u16 tmp1;
 			u16 rx_alarm_ctrl_val;
 			u16 lasi_ctrl_val;
-			if (ext_phy_type ==
+			if (phy->type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) {
 				rx_alarm_ctrl_val = 0x400;
 				lasi_ctrl_val = 0x0004;
@@ -3869,40 +3567,32 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			}
 
 			/* enable LASI */
-			bnx2x_cl45_write(bp, params->port,
-				   ext_phy_type,
-				   ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				   MDIO_PMA_DEVAD,
 				   MDIO_PMA_REG_RX_ALARM_CTRL,
 				   rx_alarm_ctrl_val);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_LASI_CTRL,
 				       lasi_ctrl_val);
 
-			bnx2x_8073_set_pause_cl37(params, vars);
+			bnx2x_8073_set_pause_cl37(params, phy, vars);
 
-			if (ext_phy_type ==
+			if (phy->type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072)
-				bnx2x_bcm8072_external_rom_boot(params);
+				bnx2x_bcm8072_external_rom_boot(phy, params);
 			else
 				/* In case of 8073 with long xaui lines,
 				don't set the 8073 xaui low power*/
-				bnx2x_bcm8073_set_xaui_low_power_mode(params);
+				bnx2x_8073_set_xaui_low_power_mode(bp, phy);
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_M8051_MSGOUT_REG,
 				      &tmp1);
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_RX_ALARM, &tmp1);
 
@@ -3913,13 +3603,12 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			 * (all other are not supported)
 			 */
 			if (params->loopback_mode == LOOPBACK_EXT) {
-				bnx2x_bcm807x_force_10G(params);
+				bnx2x_807x_force_10G(bp, phy);
 				DP(NETIF_MSG_LINK,
 					"Forced speed 10G on 807X\n");
 				break;
 			} else {
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type, ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_BCM_CTRL,
 					       0x0002);
@@ -3951,16 +3640,11 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					 "807x autoneg val = 0x%x\n", val);
 			}
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_ADV, val);
-			if (ext_phy_type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_8073_2_5G, &tmp1);
 
@@ -3972,9 +3656,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				     SPEED_2500)) {
 					u16 phy_ver;
 					/* Allow 2.5G for A1 and above */
-					bnx2x_cl45_read(bp, params->port,
-					 PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-					 ext_phy_addr,
+					bnx2x_cl45_read(bp, phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_8073_CHIP_REV, &phy_ver);
 					DP(NETIF_MSG_LINK, "Add 2.5G\n");
@@ -3987,76 +3669,59 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					tmp1 &= 0xfffe;
 				}
 
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_8073_2_5G, tmp1);
-			}
 
 			/* Add support for CL37 (passive mode) II */
 
-			bnx2x_cl45_read(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CL37_FC_LD,
 				       &tmp1);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CL37_FC_LD, (tmp1 |
 				       ((params->req_duplex == DUPLEX_FULL) ?
 				       0x20 : 0x40)));
 
 			/* Add support for CL37 (passive mode) III */
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CL37_AN, 0x1000);
 
-			if (ext_phy_type ==
+			if (phy->type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
 				/* The SNR will improve about 2db by changing
 				BW and FEE main tap. Rest commands are executed
 				after link is up*/
 				/*Change FFE main cursor to 5 in EDC register*/
-				if (bnx2x_8073_is_snr_needed(params))
-					bnx2x_cl45_write(bp, params->port,
-						    ext_phy_type,
-						    ext_phy_addr,
+				if (bnx2x_8073_is_snr_needed(bp, phy))
+					bnx2x_cl45_write(bp, phy,
 						    MDIO_PMA_DEVAD,
 						    MDIO_PMA_REG_EDC_FFE_MAIN,
 						    0xFB0C);
 
 				/* Enable FEC (Forware Error Correction)
 				Request in the AN */
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_ADV2, &tmp1);
 
 				tmp1 |= (1<<15);
 
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_ADV2, tmp1);
 
 			}
 
-			bnx2x_ext_phy_set_pause(params, vars);
+			bnx2x_ext_phy_set_pause(params, phy, vars);
 
 			/* Restart autoneg */
 			msleep(500);
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CTRL, 0x1200);
 			DP(NETIF_MSG_LINK, "807x Autoneg Restart: "
@@ -4080,25 +3745,19 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 
 			DP(NETIF_MSG_LINK, "Initializing BCM8727\n");
 			/* enable LASI */
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_RX_ALARM_CTRL,
 				       rx_alarm_ctrl_val);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_LASI_CTRL,
 				       lasi_ctrl_val);
 
 			/* Initially configure  MOD_ABS to interrupt when
 			module is presence( bit 8) */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
 			/* Set EDC off by setting OPTXLOS signal input to low
@@ -4106,23 +3765,17 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			When the EDC is off it locks onto a reference clock and
 			avoids becoming 'lost'.*/
 			mod_abs &= ~((1<<8) | (1<<9));
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
 			/* Make MOD_ABS give interrupt on change */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 				      &val);
 			val |= (1<<12);
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 				       val);
@@ -4131,32 +3784,24 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			8727 GPIO0 status which reflect SFP+ module
 			over-current */
 
-			bnx2x_cl45_read(bp, params->port,
-				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-				       ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 				       &val);
 			val &= 0xff8f; /* Reset bits 4-6 */
-			bnx2x_cl45_write(bp, params->port,
-				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 				       val);
 
-			bnx2x_8727_power_module(bp, params, ext_phy_addr, 1);
+			bnx2x_8727_power_module(bp, params, phy, 1);
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_M8051_MSGOUT_REG,
 				      &tmp1);
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_RX_ALARM, &tmp1);
 
@@ -4164,19 +3809,13 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			if (params->req_line_speed == SPEED_1000) {
 
 				DP(NETIF_MSG_LINK, "Setting 1G force\n");
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_CTRL, 0x40);
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_10G_CTRL2, 0xD);
-				bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_10G_CTRL2, &tmp1);
 				DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
@@ -4189,28 +3828,22 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				     PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) !=
 				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
 				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
-					       MDIO_PMA_REG_8727_MISC_CTRL, 0);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+					       MDIO_AN_REG_8727_MISC_CTRL, 0);
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CL37_AN, 0x1300);
 			} else {
 				/* Since the 8727 has only single reset pin,
 				need to set the 10G registers although it is
 				default */
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					      ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					      MDIO_AN_REG_8727_MISC_CTRL,
 					      0x0020);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					      ext_phy_addr, MDIO_AN_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					      MDIO_AN_REG_CL37_AN, 0x0100);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					      ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_CTRL, 0x2040);
-				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					      ext_phy_addr, MDIO_PMA_DEVAD,
+				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_10G_CTRL2, 0x0008);
 			}
 
@@ -4218,9 +3851,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			 * to 100Khz since some DACs(direct attached cables) do
 			 * not work at 400Khz.
 			 */
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
 				       0xa001);
@@ -4232,16 +3863,12 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					 "TX_CTRL2 0x%x\n",
 					 params->xgxs_config_tx[0],
 					 params->xgxs_config_tx[1]);
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8727_TX_CTRL1,
 					       params->xgxs_config_tx[0]);
 
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8727_TX_CTRL2,
 					       params->xgxs_config_tx[1]);
@@ -4256,40 +3883,30 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			DP(NETIF_MSG_LINK,
 				"Setting the SFX7101 LASI indication\n");
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_LASI_CTRL, 0x1);
 			DP(NETIF_MSG_LINK,
 			  "Setting the SFX7101 LED to blink on traffic\n");
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_7107_LED_CNTL, (1<<3));
 
-			bnx2x_ext_phy_set_pause(params, vars);
+			bnx2x_ext_phy_set_pause(params, phy, vars);
 			/* Restart autoneg */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_AN_DEVAD,
 				      MDIO_AN_REG_CTRL, &val);
 			val |= 0x200;
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CTRL, val);
 
 			/* Save spirom version */
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr, MDIO_PMA_DEVAD,
+			bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_7101_VER1, &fw_ver1);
 
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr, MDIO_PMA_DEVAD,
+			bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_7101_VER2, &fw_ver2);
 
 			bnx2x_save_spirom_version(params->bp, params->port,
@@ -4307,34 +3924,28 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			u16 autoneg_val, an_1000_val, an_10_100_val, temp;
 			temp = vars->line_speed;
 			vars->line_speed = SPEED_10000;
-			bnx2x_set_autoneg(params, vars, 0);
-			bnx2x_program_serdes(params, vars);
+			bnx2x_set_autoneg(phy, params, vars, 0);
+			bnx2x_program_serdes(phy, params, vars);
 			vars->line_speed = temp;
 
 			bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
 				      1 << NIG_LATCH_BC_ENABLE_MI_INT);
 
-			bnx2x_cl45_write(bp, params->port,
-					 ext_phy_type,
-					 ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 					 MDIO_PMA_DEVAD,
 					 MDIO_PMA_REG_CTRL, 0x0000);
 
-			bnx2x_8481_set_led(params, ext_phy_type, ext_phy_addr);
+			bnx2x_8481_set_led(bp, phy);
 
-			bnx2x_cl45_read(bp, params->port,
-					ext_phy_type,
-					ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 					MDIO_AN_DEVAD,
 					MDIO_AN_REG_8481_1000T_CTRL,
 					&an_1000_val);
-			bnx2x_ext_phy_set_pause(params, vars);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-					ext_phy_addr, MDIO_AN_DEVAD,
+			bnx2x_ext_phy_set_pause(params, phy, vars);
+			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
 					MDIO_AN_REG_8481_LEGACY_AN_ADV,
 					&an_10_100_val);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-					ext_phy_addr, MDIO_AN_DEVAD,
+			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
 					MDIO_AN_REG_8481_LEGACY_MII_CTRL,
 					&autoneg_val);
 			/* Disable forced speed */
@@ -4354,9 +3965,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			} else
 				an_1000_val &= ~((1<<8) | (1<<9));
 
-			bnx2x_cl45_write(bp, params->port,
-					 ext_phy_type,
-					 ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 					 MDIO_AN_DEVAD,
 					 MDIO_AN_REG_8481_1000T_CTRL,
 					 an_1000_val);
@@ -4393,9 +4002,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			if (params->req_line_speed == SPEED_100) {
 				autoneg_val |= (1<<13);
 				/* Enabled AUTO-MDIX when autoneg is disabled */
-				bnx2x_cl45_write(bp, params->port,
-						 ext_phy_type,
-						 ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 						 MDIO_AN_DEVAD,
 						 MDIO_AN_REG_8481_AUX_CTRL,
 						 (1<<15 | 1<<9 | 7<<0));
@@ -4403,18 +4010,14 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			}
 			if (params->req_line_speed == SPEED_10) {
 				/* Enabled AUTO-MDIX when autoneg is disabled */
-				bnx2x_cl45_write(bp, params->port,
-						 ext_phy_type,
-						 ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 						 MDIO_AN_DEVAD,
 						 MDIO_AN_REG_8481_AUX_CTRL,
 						 (1<<15 | 1<<9 | 7<<0));
 				DP(NETIF_MSG_LINK, "Setting 10M force\n");
 			}
 
-			bnx2x_cl45_write(bp, params->port,
-					 ext_phy_type,
-					 ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 					 MDIO_AN_DEVAD,
 					 MDIO_AN_REG_8481_LEGACY_AN_ADV,
 					 an_10_100_val);
@@ -4422,9 +4025,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			if (params->req_duplex == DUPLEX_FULL)
 				autoneg_val |= (1<<8);
 
-			bnx2x_cl45_write(bp, params->port,
-					 ext_phy_type,
-					 ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 					 MDIO_AN_DEVAD,
 					 MDIO_AN_REG_8481_LEGACY_MII_CTRL,
 					 autoneg_val);
@@ -4436,74 +4037,49 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				DP(NETIF_MSG_LINK, "Advertising 10G\n");
 				/* Restart autoneg for 10G*/
 
-				bnx2x_cl45_write(bp, params->port,
-						 ext_phy_type,
-						 ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 						 MDIO_AN_DEVAD,
 						 MDIO_AN_REG_CTRL,
 						 0x3200);
 
 			} else if (params->req_line_speed != SPEED_10 &&
 				   params->req_line_speed != SPEED_100)
-				bnx2x_cl45_write(bp, params->port,
-					     ext_phy_type,
-					     ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					     MDIO_AN_DEVAD,
 					     MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
 					     1);
 
 			/* Save spirom version */
-			bnx2x_save_8481_spirom_version(bp, params->port,
-						     ext_phy_addr,
-						     params->shmem_base);
+			bnx2x_save_8481_spirom_version(phy, params,
+						       params->shmem_base);
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK,
 				 "XGXS PHY Failure detected 0x%x\n",
-				 params->ext_phy_config);
+				 phy->type);
 			rc = -EINVAL;
 			break;
-		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-				  params->ext_phy_config);
-			rc = -EINVAL;
-			break;
-		}
-
-	} else { /* SerDes */
-
-		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			break;
 
 		default:
 			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
-			   params->ext_phy_config);
+			   phy->type);
 			break;
 		}
 	}
 	return rc;
 }
 
-static void bnx2x_8727_handle_mod_abs(struct link_params *params)
+static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
+				      struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 mod_abs, rx_alarm_status;
-	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 val = REG_RD(bp, params->shmem_base +
 			     offsetof(struct shmem_region, dev_info.
 				      port_feature_config[params->port].
 				      config));
-	bnx2x_cl45_read(bp, params->port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		      ext_phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
 	if (mod_abs & (1<<8)) {
@@ -4519,17 +4095,13 @@ static void bnx2x_8727_handle_mod_abs(struct link_params *params)
 			When the EDC is off it locks onto a reference clock and
 			avoids becoming 'lost'.*/
 		mod_abs &= ~((1<<8)|(1<<9));
-		bnx2x_cl45_write(bp, params->port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-			       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
 		/* Clear RX alarm since it stays up as long as
 		the mod_abs wasn't changed */
-		bnx2x_cl45_read(bp, params->port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
 
@@ -4547,9 +4119,7 @@ static void bnx2x_8727_handle_mod_abs(struct link_params *params)
 		this signal will then correctly indicate the presence or
 		absence of the Rx signal. (bit 9) */
 		mod_abs |= ((1<<8)|(1<<9));
-		bnx2x_cl45_write(bp, params->port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-		       ext_phy_addr,
+		bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
@@ -4557,22 +4127,17 @@ static void bnx2x_8727_handle_mod_abs(struct link_params *params)
 		the mod_abs wasn't changed. This is need to be done
 		before calling the module detection, otherwise it will clear
 		the link update alarm */
-		bnx2x_cl45_read(bp, params->port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-			      ext_phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
 

 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-			bnx2x_sfp_set_transmitter(bp, params->port,
-					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-					ext_phy_addr, 0);
+			bnx2x_sfp_set_transmitter(bp, phy, 0);
 
-		if (bnx2x_wait_for_sfp_module_initialized(params)
-		    == 0)
-			bnx2x_sfp_module_detection(params);
+		if (bnx2x_wait_for_sfp_module_initialized(phy, params) == 0)
+			bnx2x_sfp_module_detection(phy, params);
 		else
 			DP(NETIF_MSG_LINK, "SFP+ module is not initialized\n");
 	}
@@ -4584,22 +4149,18 @@ static void bnx2x_8727_handle_mod_abs(struct link_params *params)
 }
 

-static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
+static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
+				 struct link_params *params,
 				 struct link_vars *vars,
 				 u8 is_mi_int)
 {
 	struct bnx2x *bp = params->bp;
-	u32 ext_phy_type;
-	u8 ext_phy_addr;
 	u16 val1 = 0, val2;
 	u16 rx_sd, pcs_status;
 	u8 ext_phy_link_up = 0;
-	u8 port = params->port;
 
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-		switch (ext_phy_type) {
+		switch (phy->type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 			DP(NETIF_MSG_LINK, "XGXS Direct\n");
 			ext_phy_link_up = 1;
@@ -4607,29 +4168,24 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_WIS_DEVAD,
 				      MDIO_WIS_REG_LASI_STATUS, &val1);
 			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
 
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_WIS_DEVAD,
 				      MDIO_WIS_REG_LASI_STATUS, &val1);
 			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
 
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_RX_SD, &rx_sd);
 
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      1,
 				      0xc809, &val1);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      1,
 				      0xc809, &val1);
 
@@ -4644,36 +4200,29 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 			DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
 			/* Clear RX Alarm*/
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM,
 				      &val2);
 			/* clear LASI indication*/
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS,
 				      &val1);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS,
 				      &val2);
 			DP(NETIF_MSG_LINK, "8706/8726 LASI status 0x%x-->"
 				     "0x%x\n", val1, val2);
 
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD,
 				      &rx_sd);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS,
 				      &pcs_status);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS,
 				      &val2);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS,
 				      &val2);
 
@@ -4687,13 +4236,11 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			ext_phy_link_up = ((rx_sd & pcs_status & 0x1) ||
 					   (val2 & (1<<1)));
 			if (ext_phy_link_up) {
-				if (ext_phy_type ==
+				if (phy->type ==
 				     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) {
 					/* If transmitter is disabled,
 					ignore false link up indication */
-					bnx2x_cl45_read(bp, params->port,
-						   ext_phy_type,
-						   ext_phy_addr,
+					bnx2x_cl45_read(bp, phy,
 						   MDIO_PMA_DEVAD,
 						   MDIO_PMA_REG_PHY_IDENTIFIER,
 						   &val1);
@@ -4716,18 +4263,14 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			u16 link_status = 0;
 			u16 rx_alarm_status;
 			/* Check the LASI */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
 
 			DP(NETIF_MSG_LINK, "8727 RX_ALARM_STATUS 0x%x\n",
 				 rx_alarm_status);
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_LASI_STATUS, &val1);
 
@@ -4736,9 +4279,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				 val1);
 
 			/* Clear MSG-OUT */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_M8051_MSGOUT_REG,
 				      &val1);
@@ -4751,9 +4292,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			      FEATURE_CONFIG_BCM8727_NOC) &&
 			    !(rx_alarm_status & (1<<5))) {
 				/* Check over-current using 8727 GPIO0 input*/
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_8727_GPIO_CTRL,
 					      &val1);
@@ -4769,31 +4308,23 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 					 * Disable all RX_ALARMs except for
 					 * mod_abs
 					 */
-					bnx2x_cl45_write(bp, params->port,
-						     ext_phy_type,
-						     ext_phy_addr,
+					bnx2x_cl45_write(bp, phy,
 						     MDIO_PMA_DEVAD,
 						     MDIO_PMA_REG_RX_ALARM_CTRL,
 						     (1<<5));
 
-					bnx2x_cl45_read(bp, params->port,
-						    ext_phy_type,
-						    ext_phy_addr,
+					bnx2x_cl45_read(bp, phy,
 						    MDIO_PMA_DEVAD,
 						    MDIO_PMA_REG_PHY_IDENTIFIER,
 						    &val1);
 					/* Wait for module_absent_event */
 					val1 |= (1<<8);
-					bnx2x_cl45_write(bp, params->port,
-						    ext_phy_type,
-						    ext_phy_addr,
+					bnx2x_cl45_write(bp, phy,
 						    MDIO_PMA_DEVAD,
 						    MDIO_PMA_REG_PHY_IDENTIFIER,
 						    val1);
 					/* Clear RX alarm */
-					bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
+					bnx2x_cl45_read(bp, phy,
 						      MDIO_PMA_DEVAD,
 						      MDIO_PMA_REG_RX_ALARM,
 						      &rx_alarm_status);
@@ -4803,11 +4334,9 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 
 			/* When module absent bit is set, check module */
 			if (rx_alarm_status & (1<<5)) {
-				bnx2x_8727_handle_mod_abs(params);
+				bnx2x_8727_handle_mod_abs(phy, params);
 				/* Enable all mod_abs and link detection bits */
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_RX_ALARM_CTRL,
 					       ((1<<5) | (1<<2)));
@@ -4815,9 +4344,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 
 			/* If transmitter is disabled,
 			ignore false link up indication */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_PHY_IDENTIFIER,
 				      &val1);
@@ -4827,9 +4354,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				break;
 			}
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
 				      &link_status);
@@ -4862,16 +4387,12 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			u16 link_status = 0;
 			u16 an1000_status = 0;
 
-			if (ext_phy_type ==
+			if (phy->type ==
 			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) {
-				bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 				      MDIO_PCS_DEVAD,
 				      MDIO_PCS_REG_LASI_STATUS, &val1);
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PCS_DEVAD,
 				      MDIO_PCS_REG_LASI_STATUS, &val2);
 			DP(NETIF_MSG_LINK,
@@ -4881,101 +4402,77 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				/* In 8073, port1 is directed through emac0 and
 				 * port0 is directed through emac1
 				 */
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_LASI_STATUS, &val1);
 
 				DP(NETIF_MSG_LINK,
 					 "8703 LASI status 0x%x\n",
 					  val1);
-			}
 
+			}
 			/* clear the interrupt LASI status register */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PCS_DEVAD,
 				      MDIO_PCS_REG_STATUS, &val2);
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PCS_DEVAD,
 				      MDIO_PCS_REG_STATUS, &val1);
 			DP(NETIF_MSG_LINK, "807x PCS status 0x%x->0x%x\n",
 			   val2, val1);
 			/* Clear MSG-OUT */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_M8051_MSGOUT_REG,
 				      &val1);
 
 			/* Check the LASI */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_RX_ALARM, &val2);
 
 			DP(NETIF_MSG_LINK, "KR 0x9003 0x%x\n", val2);
 
 			/* Check the link status */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PCS_DEVAD,
 				      MDIO_PCS_REG_STATUS, &val2);
 			DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
 
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_STATUS, &val2);
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_STATUS, &val1);
 			ext_phy_link_up = ((val1 & 4) == 4);
 			DP(NETIF_MSG_LINK, "PMA_REG_STATUS=0x%x\n", val1);
-			if (ext_phy_type ==
+			if (phy->type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
 
 				if (ext_phy_link_up &&
 				    ((params->req_line_speed !=
 					SPEED_10000))) {
-					if (bnx2x_bcm8073_xaui_wa(params)
+					if (bnx2x_8073_xaui_wa(bp, phy)
 					     != 0) {
 						ext_phy_link_up = 0;
 						break;
 					}
 				}
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_LINK_STATUS,
 					      &an1000_status);
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_LINK_STATUS,
 					      &an1000_status);
 
 				/* Check the link status on 1.1.2 */
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_STATUS, &val2);
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_PMA_DEVAD,
 					      MDIO_PMA_REG_STATUS, &val1);
 				DP(NETIF_MSG_LINK, "KR PMA status 0x%x->0x%x,"
@@ -4985,7 +4482,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				ext_phy_link_up = (((val1 & 4) == 4) ||
 						(an1000_status & (1<<1)));
 				if (ext_phy_link_up &&
-				    bnx2x_8073_is_snr_needed(params)) {
+				    bnx2x_8073_is_snr_needed(bp, phy)) {
 					/* The SNR will improve about 2dbby
 					changing the BW and FEE main tap.*/
 
@@ -4993,23 +4490,19 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 					tap is set before restart AN */
 					/* Change PLL Bandwidth in EDC
 					register */
-					bnx2x_cl45_write(bp, port, ext_phy_type,
-						    ext_phy_addr,
+					bnx2x_cl45_write(bp, phy,
 						    MDIO_PMA_DEVAD,
 						    MDIO_PMA_REG_PLL_BANDWIDTH,
 						    0x26BC);
 
 					/* Change CDR Bandwidth in EDC
 					register */
-					bnx2x_cl45_write(bp, port, ext_phy_type,
-						    ext_phy_addr,
+					bnx2x_cl45_write(bp, phy,
 						    MDIO_PMA_DEVAD,
 						    MDIO_PMA_REG_CDR_BANDWIDTH,
 						    0x0333);
 				}
-				bnx2x_cl45_read(bp, params->port,
-					   ext_phy_type,
-					   ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					   MDIO_PMA_DEVAD,
 					   MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
 					   &link_status);
@@ -5045,15 +4538,11 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				}
 			} else {
 				/* See if 1G link is up for the 8072 */
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_LINK_STATUS,
 					      &an1000_status);
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_LINK_STATUS,
 					      &an1000_status);
@@ -5072,27 +4561,22 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				}
 			}
 
-
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_LASI_STATUS, &val2);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_LASI_STATUS, &val1);
 			DP(NETIF_MSG_LINK,
 				 "10G-base-T LASI status 0x%x->0x%x\n",
 				  val2, val1);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_STATUS, &val2);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_STATUS, &val1);
 			DP(NETIF_MSG_LINK,
@@ -5103,9 +4587,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			 * print the AN outcome of the SFX7101 PHY
 			 */
 			if (ext_phy_link_up) {
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_MASTER_STATUS,
 					      &val2);
@@ -5120,13 +4602,11 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
 			/* Check 10G-BaseT link status */
 			/* Check PMD signal ok */
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-						      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 						      MDIO_AN_DEVAD,
 						      0xFFFA,
 						      &val1);
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
+			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_8481_PMD_SIGNAL,
 				      &val2);
@@ -5141,17 +4621,13 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 
 				/* Enable expansion register 0x42
 				(Operation mode status) */
-				bnx2x_cl45_write(bp, params->port,
-					 ext_phy_type,
-					 ext_phy_addr,
+				bnx2x_cl45_write(bp, phy,
 					 MDIO_AN_DEVAD,
 					 MDIO_AN_REG_8481_EXPANSION_REG_ACCESS,
 					 0xf42);
 
 				/* Get legacy speed operation status */
-				bnx2x_cl45_read(bp, params->port,
-					  ext_phy_type,
-					  ext_phy_addr,
+				bnx2x_cl45_read(bp, phy,
 					  MDIO_AN_DEVAD,
 					  MDIO_AN_REG_8481_EXPANSION_REG_RD_RW,
 					  &legacy_status);
@@ -5187,48 +4663,27 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			}
 			break;
 		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   params->ext_phy_config);
+			DP(NETIF_MSG_LINK,
+				 "BAD SerDes ext_phy_config 0x%x\n",
+				 phy->type);
 			ext_phy_link_up = 0;
 			break;
 		}
+	}
+
 		/* Set SGMII mode for external phy */
-		if (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
+		if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
 			if (vars->line_speed < SPEED_1000)
 				vars->phy_flags |= PHY_SGMII_FLAG;
 			else
 				vars->phy_flags &= ~PHY_SGMII_FLAG;
 		}
 
-	} else { /* SerDes */
-		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			ext_phy_link_up = 1;
-			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			ext_phy_link_up = 1;
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK,
-				 "BAD SerDes ext_phy_config 0x%x\n",
-				 params->ext_phy_config);
-			ext_phy_link_up = 0;
-			break;
-		}
-	}
-
 	return ext_phy_link_up;
 }
-
 static void bnx2x_link_int_enable(struct link_params *params)
 {
 	u8 port = params->port;
-	u32 ext_phy_type;
 	u32 mask;
 	struct bnx2x *bp = params->bp;
 
@@ -5239,11 +4694,9 @@ static void bnx2x_link_int_enable(struct link_params *params)
 		mask = (NIG_MASK_XGXS0_LINK10G |
 			NIG_MASK_XGXS0_LINK_STATUS);
 		DP(NETIF_MSG_LINK, "enabled XGXS interrupt\n");
-		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
-		    (ext_phy_type !=
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN)) {
+		if (!(SINGLE_MEDIA_DIRECT(params)) &&
+			params->phy[INT_PHY].type !=
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) {
 			mask |= NIG_MASK_MI_INT;
 			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 		}
@@ -5251,11 +4704,9 @@ static void bnx2x_link_int_enable(struct link_params *params)
 	} else { /* SerDes */
 		mask = NIG_MASK_SERDES0_LINK_STATUS;
 		DP(NETIF_MSG_LINK, "enabled SerDes interrupt\n");
-		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
-		if ((ext_phy_type !=
-				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
-		    (ext_phy_type !=
-				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_NOT_CONN)) {
+		if (!(SINGLE_MEDIA_DIRECT(params)) &&
+			params->phy[INT_PHY].type !=
+				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_NOT_CONN) {
 			mask |= NIG_MASK_MI_INT;
 			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 		}
@@ -5311,6 +4762,7 @@ static void bnx2x_8481_rearm_latch_signal(struct bnx2x *bp, u8 port,
 			   (latch_status & 0xfffe) | (latch_status & 1));
 	}
 }
+
 /*
  * link management
  */
@@ -5327,9 +4779,9 @@ static void bnx2x_link_int_ack(struct link_params *params,
 		     (NIG_STATUS_XGXS0_LINK10G |
 		      NIG_STATUS_XGXS0_LINK_STATUS |
 		      NIG_STATUS_SERDES0_LINK_STATUS));
-	if ((XGXS_EXT_PHY_TYPE(params->ext_phy_config)
+	if ((params->phy[EXT_PHY1].type
 		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) ||
-	(XGXS_EXT_PHY_TYPE(params->ext_phy_config)
+	(params->phy[EXT_PHY1].type
 		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823)) {
 		bnx2x_8481_rearm_latch_signal(bp, port, is_mi_int);
 	}
@@ -5421,7 +4873,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 
 	status = 0;
 	/* reset the returned value to zero */
-	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+	ext_phy_type = params->phy[EXT_PHY1].type;
 	switch (ext_phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 
@@ -5465,8 +4917,8 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	return status;
 }
 
-static void bnx2x_set_xgxs_loopback(struct link_params *params,
-				  struct link_vars *vars,
+static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
+				  struct link_params *params,
 				  u8 is_10g)
 {
 	u8 port = params->port;
@@ -5483,59 +4935,49 @@ static void bnx2x_set_xgxs_loopback(struct link_params *params,
 
 		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, 0x5);
 
-		bnx2x_cl45_write(bp, port, 0,
-			       params->phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       5,
 			       (MDIO_REG_BANK_AER_BLOCK +
 				(MDIO_AER_BLOCK_AER_REG & 0xf)),
 			       0x2800);
 
-		bnx2x_cl45_write(bp, port, 0,
-			       params->phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       5,
 			       (MDIO_REG_BANK_CL73_IEEEB0 +
 				(MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
 			       0x6041);
 		msleep(200);
 		/* set aer mmd back */
-		bnx2x_set_aer_mmd(params, vars);
+		bnx2x_set_aer_mmd(params, phy);
 
 		/* and md_devad */
 		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
 			    md_devad);
 
 	} else {
-		u16 mii_control;
-
+		u16 mii_ctrl;
 		DP(NETIF_MSG_LINK, "XGXS 1G loopback enable\n");
-
-		CL45_RD_OVER_CL22(bp, port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      &mii_control);
-
-		CL45_WR_OVER_CL22(bp, port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      (mii_control |
-				       MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK));
+		bnx2x_cl45_read(bp, phy, 5,
+				(MDIO_REG_BANK_COMBO_IEEE0 +
+				(MDIO_COMBO_IEEE0_MII_CONTROL & 0xf)),
+				&mii_ctrl);
+		bnx2x_cl45_write(bp, phy, 5,
+				 (MDIO_REG_BANK_COMBO_IEEE0 +
+				 (MDIO_COMBO_IEEE0_MII_CONTROL & 0xf)),
+				 mii_ctrl |
+				 MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK);
 	}
 }
 
-
-static void bnx2x_ext_phy_loopback(struct link_params *params)
+static void bnx2x_ext_phy_loopback(struct bnx2x_phy *phy,
+				   struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_addr;
-	u32 ext_phy_type;
 
 	if (params->switch_cfg == SWITCH_CFG_10G) {
-		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
+
 		/* CL37 Autoneg Enabled */
-		switch (ext_phy_type) {
+		switch (phy->type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN:
 			DP(NETIF_MSG_LINK,
@@ -5549,16 +4991,14 @@ static void bnx2x_ext_phy_loopback(struct link_params *params)
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 			DP(NETIF_MSG_LINK, "PMA/PMD ext_phy_loopback: 8726\n");
-			bnx2x_cl45_write(bp, params->port, ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL,
 				       0x0001);
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			/* SFX7101_XGXS_TEST1 */
-			bnx2x_cl45_write(bp, params->port, ext_phy_type,
-				       ext_phy_addr,
+			bnx2x_cl45_write(bp, phy,
 				       MDIO_XS_DEVAD,
 				       MDIO_XS_SFX7101_XGXS_TEST1,
 				       0x100);
@@ -5569,21 +5009,13 @@ static void bnx2x_ext_phy_loopback(struct link_params *params)
 
 			break;
 		} /* switch external PHY type */
-	} else {
-		/* serdes */
-		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
-		ext_phy_addr = (params->ext_phy_config  &
-		PORT_HW_CFG_SERDES_EXT_PHY_ADDR_MASK)
-		>> PORT_HW_CFG_SERDES_EXT_PHY_ADDR_SHIFT;
 	}
 }
-
-
 /*
  *------------------------------------------------------------------------
  * bnx2x_override_led_value -
  *
- * Override the led value of the requsted led
+ * Override the led value of the requested led
  *
  *------------------------------------------------------------------------
  */
@@ -5702,7 +5134,6 @@ u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
 	u8 rc = 0;
 	u32 tmp;
 	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
 	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
@@ -5718,7 +5149,7 @@ u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
 		break;
 
 	case LED_MODE_OPER:
-		if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
+		if (SINGLE_MEDIA_DIRECT(params)) {
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
 		} else {
@@ -5768,14 +5199,13 @@ u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
 	struct bnx2x *bp = params->bp;
 	u16 gp_status = 0;
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
+	CL45_RD_OVER_CL22(bp, &params->phy[INT_PHY],
 			      MDIO_REG_BANK_GP_STATUS,
 			      MDIO_GP_STATUS_TOP_AN_STATUS1,
 			      &gp_status);
 	/* link is up only if both local phy and external phy are up */
 	if ((gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) &&
-	    bnx2x_ext_phy_is_link_up(params, vars, 1))
+	    bnx2x_ext_phy_is_link_up(&params->phy[EXT_PHY1], params, vars, 1))
 		return 0;
 
 	return -ESRCH;
@@ -5788,27 +5218,29 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	u8 port = params->port;
 	u8 rc = 0;
 	u8 non_ext_phy;
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
+	struct bnx2x_phy *ext_phy = &params->phy[EXT_PHY1];
+	struct bnx2x_phy *int_phy = &params->phy[INT_PHY];
 	/* Activate the external PHY */
-	bnx2x_ext_phy_reset(params, vars);
+	bnx2x_ext_phy_reset(ext_phy, params, vars);
 
-	bnx2x_set_aer_mmd(params, vars);
+	bnx2x_set_aer_mmd(params, int_phy);
 
 	if (vars->phy_flags & PHY_XGXS_FLAG)
-		bnx2x_set_master_ln(params);
+		bnx2x_set_master_ln(params, int_phy);
 
-	rc = bnx2x_reset_unicore(params);
+	rc = bnx2x_reset_unicore(params, int_phy,
+				 int_phy->type ==
+				 PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT);
 	/* reset the SerDes and wait for reset bit return low */
 	if (rc != 0)
 		return rc;
 
-	bnx2x_set_aer_mmd(params, vars);
+	bnx2x_set_aer_mmd(params, int_phy);
 
 	/* setting the masterLn_def again after the reset */
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		bnx2x_set_master_ln(params);
-		bnx2x_set_swap_lanes(params);
+		bnx2x_set_master_ln(params, int_phy);
+		bnx2x_set_swap_lanes(params, int_phy);
 	}
 
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
@@ -5832,20 +5264,21 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	   req_line_speed*/
 	vars->line_speed = params->req_line_speed;
 
-	bnx2x_calc_ieee_aneg_adv(params, &vars->ieee_fc);
+	bnx2x_calc_ieee_aneg_adv(int_phy, params, &vars->ieee_fc);
 
 	/* init ext phy and enable link state int */
-	non_ext_phy = ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
+	non_ext_phy = ((ext_phy->type ==
+			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
 		       (params->loopback_mode == LOOPBACK_XGXS_10));
 
 	if (non_ext_phy ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
+	    (ext_phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
+	    (ext_phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
+	    (ext_phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
 	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
-		if (params->req_line_speed == SPEED_AUTO_NEG)
-			bnx2x_set_parallel_detection(params, vars->phy_flags);
-		bnx2x_init_internal_phy(params, vars, non_ext_phy);
+		if (vars->line_speed == SPEED_AUTO_NEG)
+			bnx2x_set_parallel_detection(int_phy, params);
+		bnx2x_init_internal_phy(int_phy, params, vars);
 	}
 
 	if (!non_ext_phy)
@@ -5857,10 +5290,8 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 		      NIG_STATUS_SERDES0_LINK_STATUS));
 
 	return rc;
-
 }
 
-
 u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
@@ -5877,10 +5308,28 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 	vars->mac_type = MAC_TYPE_NONE;
 
-	if (params->switch_cfg ==  SWITCH_CFG_1G)
+	if (params->switch_cfg ==  SWITCH_CFG_1G) {
+		params->phy[INT_PHY].type =
+				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT;
 		vars->phy_flags = PHY_SERDES_FLAG;
-	else
+	} else {
+		params->phy[INT_PHY].type =
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT;
 		vars->phy_flags = PHY_XGXS_FLAG;
+	}
+	params->phy[INT_PHY].mdio_ctrl =
+		bnx2x_get_emac_base(bp,
+				    params->phy[INT_PHY].type, params->port);
+	if (XGXS_EXT_PHY_TYPE(params->ext_phy_config) !=
+	     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
+		params->phy[EXT_PHY1].type =
+			XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+		params->phy[EXT_PHY1].addr =
+			XGXS_EXT_PHY_ADDR(params->ext_phy_config);
+		params->phy[EXT_PHY1].mdio_ctrl =
+			bnx2x_get_emac_base(bp, params->phy[EXT_PHY1].type,
+					    params->port);
+	}
 
 	/* disable attentions */
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
@@ -5951,6 +5400,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		vars->phy_flags = PHY_XGXS_FLAG;
 
 		bnx2x_phy_deassert(params, vars->phy_flags);
+
 		/* set bmac loopback */
 		bnx2x_bmac_enable(params, vars, 1);
 
@@ -5989,7 +5439,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
 				 params->port*0x18);
 		params->phy_addr = (u8)val;
-
+		params->phy[INT_PHY].addr = (u8)val;
 		bnx2x_phy_deassert(params, vars->phy_flags);
 		bnx2x_link_initialize(params, vars);
 
@@ -5999,11 +5449,14 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 		if (params->loopback_mode == LOOPBACK_XGXS_10) {
 			/* set 10G XGXS loopback */
-			bnx2x_set_xgxs_loopback(params, vars, 1);
+			bnx2x_set_xgxs_loopback(&params->phy[INT_PHY],
+						params, 1);
 		} else {
 			/* set external phy loopback */
-			bnx2x_ext_phy_loopback(params);
+			bnx2x_ext_phy_loopback(&params->phy[INT_PHY],
+					       params);
 		}
+
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 			    params->port*4, 0);
 
@@ -6041,7 +5494,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 			return -EINVAL;
 		}
 		DP(NETIF_MSG_LINK, "Phy address = 0x%x\n", params->phy_addr);
-
+		params->phy[INT_PHY].addr = params->phy_addr;
 		bnx2x_link_initialize(params, vars);
 		msleep(30);
 		bnx2x_link_int_enable(params);
@@ -6049,13 +5502,13 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	return 0;
 }
 
-static void bnx2x_8726_reset_phy(struct bnx2x *bp, u8 port, u8 ext_phy_addr)
-{
-	DP(NETIF_MSG_LINK, "bnx2x_8726_reset_phy port %d\n", port);
 
+static void bnx2x_8726_reset_phy(struct bnx2x *bp,
+				 struct bnx2x_phy *phy)
+{
+	DP(NETIF_MSG_LINK, "bnx2x_8726_reset_phy\n");
 	/* Set serial boot control for external load */
-	bnx2x_cl45_write(bp, port,
-		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726, ext_phy_addr,
+	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_GEN_CTRL, 0x0001);
 }
@@ -6064,9 +5517,9 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		  u8 reset_ext_phy)
 {
 	struct bnx2x *bp = params->bp;
-	u32 ext_phy_config = params->ext_phy_config;
+
 	u8 port = params->port;
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
+
 	u32 val = REG_RD(bp, params->shmem_base +
 			     offsetof(struct shmem_region, dev_info.
 				      port_feature_config[params->port].
@@ -6101,7 +5554,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	 /* clear link led */
 	bnx2x_set_led(params, LED_MODE_OFF, 0);
 	if (reset_ext_phy) {
-		switch (ext_phy_type) {
+		struct bnx2x_phy *phy = &params->phy[EXT_PHY1];
+		switch (phy->type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 			break;
@@ -6110,13 +5564,9 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		{
 
 			/* Disable Transmitter */
-			u8 ext_phy_addr =
-				XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 			if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 			    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-				bnx2x_sfp_set_transmitter(bp, port,
-					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-					ext_phy_addr, 0);
+				bnx2x_sfp_set_transmitter(bp, phy, 0);
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
@@ -6129,10 +5579,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		{
-			u8 ext_phy_addr =
-				XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 			/* Set soft reset */
-			bnx2x_8726_reset_phy(bp, params->port, ext_phy_addr);
+			bnx2x_8726_reset_phy(bp, phy);
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
@@ -6170,6 +5618,7 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	return 0;
 }
 
+
 static u8 bnx2x_update_link_down(struct link_params *params,
 			       struct link_vars *vars)
 {
@@ -6222,11 +5671,10 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 		bnx2x_emac_enable(params, vars, 0);
 
 		/* AN complete? */
-		if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
-			if (!(vars->phy_flags &
-			      PHY_SGMII_FLAG))
-				bnx2x_set_gmii_tx_driver(params);
-		}
+		if ((vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE)
+		    && (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
+		    SINGLE_MEDIA_DIRECT(params))
+			bnx2x_set_gmii_tx_driver(params);
 	}
 
 	/* PBF - link up */
@@ -6261,7 +5709,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	u16 gp_status;
 	u8 link_10g;
 	u8 ext_phy_link_up, rc = 0;
-	u32 ext_phy_type;
+	struct bnx2x_phy *int_phy = &params->phy[INT_PHY];
 	u8 is_mi_int = 0;
 
 	DP(NETIF_MSG_LINK, "port %x, XGXS?%x, int_status 0x%x\n",
@@ -6283,13 +5731,13 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	/* disable emac */
 	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
-	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-
 	/* Check external link change only for non-direct */
-	ext_phy_link_up = bnx2x_ext_phy_is_link_up(params, vars, is_mi_int);
+	ext_phy_link_up = bnx2x_ext_phy_is_link_up(&params->phy[EXT_PHY1],
+						   params, vars,
+						   is_mi_int);
 
 	/* Read gp_status */
-	CL45_RD_OVER_CL22(bp, port, params->phy_addr,
+	CL45_RD_OVER_CL22(bp, int_phy,
 			      MDIO_REG_BANK_GP_STATUS,
 			      MDIO_GP_STATUS_TOP_AN_STATUS1,
 			      &gp_status);
@@ -6316,12 +5764,12 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	the xgxs link would probably become up again without the need to
 	initialize it*/
 
-	if ((ext_phy_type != PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
-	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
-	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) &&
-	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) &&
-	    (ext_phy_link_up && !vars->phy_link_up))
-		bnx2x_init_internal_phy(params, vars, 0);
+	if ((int_phy->type != PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
+	    (int_phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
+	    (int_phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) &&
+	    (int_phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) &&
+	    (int_phy->type && !vars->phy_link_up))
+		bnx2x_init_internal_phy(int_phy, params, vars);
 
 	/* link is up only if both local phy and external phy are up */
 	vars->link_up = (ext_phy_link_up && vars->phy_link_up);
@@ -6334,19 +5782,65 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	return rc;
 }
 
+static u32 bnx2x_get_ext_phy_config(struct bnx2x *bp, u32 shmem_base,
+				    u8 phy_index, u8 port)
+{
+	u32 ext_phy_config = 0;
+	switch (phy_index) {
+	case EXT_PHY1:
+		ext_phy_config = REG_RD(bp, shmem_base +
+					      offsetof(struct shmem_region,
+			dev_info.port_hw_config[port].external_phy_config));
+		break;
+	default:
+		DP(NETIF_MSG_LINK, "Invalid phy_index %d\n", phy_index);
+		return -EINVAL;
+	}
+
+	return ext_phy_config;
+}
+
+static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
+				 u8 phy_index,
+				 u32 shmem_base,
+				 u8 port,
+				 struct bnx2x_phy *phy)
+{
+	u32 ext_phy_config;
+
+	ext_phy_config = bnx2x_get_ext_phy_config(bp, shmem_base,
+						  phy_index, port);
+	phy->type = XGXS_EXT_PHY_TYPE(ext_phy_config);
+	phy->addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
+	phy->mdio_ctrl = bnx2x_get_emac_base(bp, phy->type, port);
+	return 0;
+}
+
+static u8 bnx2x_populate_phy(struct bnx2x *bp, u8 phy_index, u32 shmem_base,
+			     u8 port, struct bnx2x_phy *phy)
+{
+	u8 status = 0;
+	status = bnx2x_populate_ext_phy(bp, phy_index, shmem_base,
+					port, phy);
+	return status;
+}
+
 static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
-	u8 ext_phy_addr[PORT_MAX];
+	struct bnx2x_phy phy[PORT_MAX];
+	struct bnx2x_phy *phy_blk[PORT_MAX];
 	u16 val;
 	s8 port;
 
 	/* PART1 - Reset both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		/* Extract the ext phy address for the port */
-		u32 ext_phy_config = REG_RD(bp, shmem_base +
-					offsetof(struct shmem_region,
-		   dev_info.port_hw_config[port].external_phy_config));
-
+		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+				       port, &phy[port]) !=
+		    0) {
+			DP(NETIF_MSG_LINK, "populate_phy failed\n");
+			return -EINVAL;
+		}
 		/* disable attentions */
 		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 			     (NIG_MASK_XGXS0_LINK_STATUS |
@@ -6354,17 +5848,13 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 			      NIG_MASK_SERDES0_LINK_STATUS |
 			      NIG_MASK_MI_INT));
 
-		ext_phy_addr[port] = XGXS_EXT_PHY_ADDR(ext_phy_config);
-
 		/* Need to take the phy out of low power mode in order
 			to write to access its registers */
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 				  MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 
 		/* Reset the phy */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			       ext_phy_addr[port],
+		bnx2x_cl45_write(bp, &phy[port],
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_CTRL,
 			       1<<15);
@@ -6373,15 +5863,22 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	/* Add delay of 150ms after reset */
 	msleep(150);
 
+	if (phy[PORT_0].addr & 0x1) {
+		phy_blk[PORT_0] = &(phy[PORT_1]);
+		phy_blk[PORT_1] = &(phy[PORT_0]);
+	} else {
+		phy_blk[PORT_0] = &(phy[PORT_0]);
+		phy_blk[PORT_1] = &(phy[PORT_1]);
+	}
+
 	/* PART2 - Download firmware to both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		u16 fw_ver1;
 
-		bnx2x_bcm8073_external_rom_boot(bp, port,
-					      ext_phy_addr[port], shmem_base);
+		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
+						  port, shmem_base);
 
-		bnx2x_cl45_read(bp, port, PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			      ext_phy_addr[port],
+		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
 		if (fw_ver1 == 0 || fw_ver1 == 0x4321) {
@@ -6393,16 +5890,12 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		}
 
 		/* Only set bit 10 = 1 (Tx power down) */
-		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			      ext_phy_addr[port],
+		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_TX_POWER_DOWN, &val);
 
 		/* Phase1 of TX_POWER_DOWN reset */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			       ext_phy_addr[port],
+		bnx2x_cl45_write(bp, phy_blk[port],
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_TX_POWER_DOWN,
 			       (val | 1<<10));
@@ -6416,28 +5909,20 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		/* Phase2 of POWER_DOWN_RESET */
 		/* Release bit 10 (Release Tx power down) */
-		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			      ext_phy_addr[port],
+		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_TX_POWER_DOWN, &val);
 
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			       ext_phy_addr[port],
+		bnx2x_cl45_write(bp, phy_blk[port],
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_TX_POWER_DOWN, (val & (~(1<<10))));
 		msleep(15);
 
 		/* Read modify write the SPI-ROM version select register */
-		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			      ext_phy_addr[port],
+		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_EDC_FFE_MAIN, &val);
-		bnx2x_cl45_write(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-			      ext_phy_addr[port],
+		bnx2x_cl45_write(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_EDC_FFE_MAIN, (val | (1<<12)));
 
@@ -6446,14 +5931,14 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 				  MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 	}
 	return 0;
-
 }
 
 static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
-	u8 ext_phy_addr[PORT_MAX];
 	s8 port, first_port, i;
 	u32 swap_val, swap_override;
+	struct bnx2x_phy phy[PORT_MAX];
+	struct bnx2x_phy *phy_blk[PORT_MAX];
 	DP(NETIF_MSG_LINK, "Executing BCM8727 common init\n");
 	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
 	swap_override = REG_RD(bp,  NIG_REG_STRAP_OVERRIDE);
@@ -6469,10 +5954,12 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	/* PART1 - Reset both phys */
 	for (i = 0, port = first_port; i < PORT_MAX; i++, port = !port) {
 		/* Extract the ext phy address for the port */
-		u32 ext_phy_config = REG_RD(bp, shmem_base +
-					offsetof(struct shmem_region,
-		   dev_info.port_hw_config[port].external_phy_config));
-
+		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+				       port, &phy[port]) !=
+				       0) {
+			DP(NETIF_MSG_LINK, "populate phy failed\n");
+			return -EINVAL;
+		}
 		/* disable attentions */
 		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 			     (NIG_MASK_XGXS0_LINK_STATUS |
@@ -6480,12 +5967,9 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 			      NIG_MASK_SERDES0_LINK_STATUS |
 			      NIG_MASK_MI_INT));
 
-		ext_phy_addr[port] = XGXS_EXT_PHY_ADDR(ext_phy_config);
 
 		/* Reset the phy */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-			       ext_phy_addr[port],
+		bnx2x_cl45_write(bp, &phy[port],
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_CTRL,
 			       1<<15);
@@ -6493,16 +5977,20 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 
 	/* Add delay of 150ms after reset */
 	msleep(150);
-
+	if (phy[PORT_0].addr & 0x1) {
+		phy_blk[PORT_0] = &(phy[PORT_1]);
+		phy_blk[PORT_1] = &(phy[PORT_0]);
+	} else {
+		phy_blk[PORT_0] = &(phy[PORT_0]);
+		phy_blk[PORT_1] = &(phy[PORT_1]);
+	}
 	/* PART2 - Download firmware to both phys */
-	for (i = 0, port = first_port; i < PORT_MAX; i++, port = !port) {
+	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		u16 fw_ver1;
 
-		bnx2x_bcm8727_external_rom_boot(bp, port,
-					      ext_phy_addr[port], shmem_base);
-
-		bnx2x_cl45_read(bp, port, PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
-			      ext_phy_addr[port],
+		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
+						  port, shmem_base);
+		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
 		if (fw_ver1 == 0 || fw_ver1 == 0x4321) {
@@ -6517,13 +6005,11 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return 0;
 }
 
-
 static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
-	u8 ext_phy_addr;
 	u32 val;
 	s8 port;
-
+	struct bnx2x_phy phy;
 	/* Use port1 because of the static port-swap */
 	/* Enable the module detection interrupt */
 	val = REG_RD(bp, MISC_REG_GPIO_EVENT_EN);
@@ -6535,15 +6021,17 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	msleep(5);
 	for (port = 0; port < PORT_MAX; port++) {
 		/* Extract the ext phy address for the port */
-		u32 ext_phy_config = REG_RD(bp, shmem_base +
-					offsetof(struct shmem_region,
-			dev_info.port_hw_config[port].external_phy_config));
+		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+				       port, &phy) !=
+		    0) {
+			DP(NETIF_MSG_LINK, "populate phy failed\n");
+			return -EINVAL;
+		}
 
-		ext_phy_addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
-		DP(NETIF_MSG_LINK, "8726_common_init : ext_phy_addr = 0x%x\n",
-			 ext_phy_addr);
+		/* Reset phy*/
+		bnx2x_cl45_write(bp, &phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_GEN_CTRL, 0x0001);
 
-		bnx2x_8726_reset_phy(bp, port, ext_phy_addr);
 
 		/* Set fault module detected LED on */
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
@@ -6594,29 +6082,23 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return rc;
 }
 
-void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr)
+void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
 	u16 val, cnt;
 
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-		      phy_addr,
+	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_7101_RESET, &val);
 
 	for (cnt = 0; cnt < 10; cnt++) {
 		msleep(50);
 		/* Writes a self-clearing reset */
-		bnx2x_cl45_write(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			       phy_addr,
+		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_7101_RESET,
 			       (val | (1<<15)));
 		/* Wait for clear */
-		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
-			      phy_addr,
+		bnx2x_cl45_read(bp, phy,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_7101_RESET, &val);
 
@@ -6624,3 +6106,4 @@ void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr)
 			break;
 	}
 }
+
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 40c2981..9bfe7fa 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -1,4 +1,4 @@
-/* Copyright 2008-2009 Broadcom Corporation
+/* Copyright 2008-2010 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
@@ -46,9 +46,35 @@
 #define SFP_EEPROM_PART_NO_ADDR 		0x28
 #define SFP_EEPROM_PART_NO_SIZE		16
 #define PWR_FLT_ERR_MSG_LEN			250
+/* Single Media Direct board is the plain 577xx board with CX4/RJ45 jacks */
+#define SINGLE_MEDIA_DIRECT(params)	(params->num_phys == 1)
+/* Single Media board contains single external phy */
+#define SINGLE_MEDIA(params)		(params->num_phys == 2)
 /***********************************************************/
 /*                         Structs                         */
 /***********************************************************/
+#define INT_PHY		0
+#define EXT_PHY1	1
+
+#define MAX_PHYS	2
+
+/***********************************************************/
+/*                      bnx2x_phy struct                     */
+/*  Defines the required arguments and function per phy    */
+/***********************************************************/
+struct link_vars;
+struct link_params;
+struct bnx2x_phy;
+
+struct bnx2x_phy {
+	u32 type;
+
+	/* Loaded during init */
+	u8 addr;
+
+	u32 mdio_ctrl;
+};
+
 /* Inputs parameters to the CLC */
 struct link_params {
 
@@ -106,6 +132,11 @@ struct link_params {
 #define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY	(1<<2)
 #define FEATURE_CONFIG_BCM8727_NOC			(1<<3)
+	/* Will be populated during common init */
+	struct bnx2x_phy phy[MAX_PHYS];
+
+	/* Will be populated during common init */
+	u8 num_phys;
 
 	/* Device pointer passed to all callback functions */
 	struct bnx2x *bp;
@@ -155,17 +186,20 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 /* bnx2x_link_update should be called upon link interrupt */
 u8 bnx2x_link_update(struct link_params *input, struct link_vars *output);
 
-/* use the following cl45 functions to read/write from external_phy
+/* use the following phy functions to read/write from external_phy
   In order to use it to read/write internal phy registers, use
   DEFAULT_PHY_DEV_ADDR as devad, and (_bank + (_addr & 0xf)) as
-  Use ext_phy_type of 0 in case of cl22 over cl45
   the register */
-u8 bnx2x_cl45_read(struct bnx2x *bp, u8 port, u32 ext_phy_type,
-		 u8 phy_addr, u8 devad, u16 reg, u16 *ret_val);
+u8 bnx2x_phy_read(struct link_params *params, u8 phy_addr,
+		  u8 devad, u16 reg, u16 *ret_val);
 
-u8 bnx2x_cl45_write(struct bnx2x *bp, u8 port, u32 ext_phy_type,
-		  u8 phy_addr, u8 devad, u16 reg, u16 val);
+u8 bnx2x_phy_write(struct link_params *params, u8 phy_addr,
+		   u8 devad, u16 reg, u16 val);
+u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
+		   u8 devad, u16 reg, u16 *ret_val);
 
+u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
+		    u8 devad, u16 reg, u16 val);
 /* Reads the link_status from the shmem,
    and update the link vars accordingly */
 void bnx2x_link_status_update(struct link_params *input,
@@ -198,9 +232,14 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base);
 /* Reset the external PHY using GPIO */
 void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port);
 
-void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr);
+/* Reset the external of SFX7101 */
+void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy);
 
-u8 bnx2x_read_sfp_module_eeprom(struct link_params *params, u16 addr,
+u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+				struct link_params *params, u16 addr,
 			      u8 byte_cnt, u8 *o_buf);
-
+/* Returns the aggregative supported attributes of the phys on board */
+u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx);
+/* Probe the phys on board, and populate them in "params" */
+u8 bnx2x_phy_probe(struct link_params *params);
 #endif /* BNX2X_LINK_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 993d7e8..174ed8b 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4351,7 +4351,6 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	default:
 		break;
 	}
-
 	bnx2x__link_reset(bp);
 
 	return 0;
@@ -6984,23 +6983,15 @@ static int bnx2x_mdio_read(struct net_device *netdev, int prtad,
 	struct bnx2x *bp = netdev_priv(netdev);
 	u16 value;
 	int rc;
-	u32 phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 
 	DP(NETIF_MSG_LINK, "mdio_read: prtad 0x%x, devad 0x%x, addr 0x%x\n",
 	   prtad, devad, addr);
 
-	if (prtad != bp->mdio.prtad) {
-		DP(NETIF_MSG_LINK, "prtad missmatch (cmd:0x%x != bp:0x%x)\n",
-		   prtad, bp->mdio.prtad);
-		return -EINVAL;
-	}
-
 	/* The HW expects different devad if CL22 is used */
 	devad = (devad == MDIO_DEVAD_NONE) ? DEFAULT_PHY_DEV_ADDR : devad;
 
 	bnx2x_acquire_phy_lock(bp);
-	rc = bnx2x_cl45_read(bp, BP_PORT(bp), phy_type, prtad,
-			     devad, addr, &value);
+	rc = bnx2x_phy_read(&bp->link_params, prtad, devad, addr, &value);
 	bnx2x_release_phy_lock(bp);
 	DP(NETIF_MSG_LINK, "mdio_read_val 0x%x rc = 0x%x\n", value, rc);
 
@@ -7014,24 +7005,16 @@ static int bnx2x_mdio_write(struct net_device *netdev, int prtad, int devad,
 			    u16 addr, u16 value)
 {
 	struct bnx2x *bp = netdev_priv(netdev);
-	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 	int rc;
 
 	DP(NETIF_MSG_LINK, "mdio_write: prtad 0x%x, devad 0x%x, addr 0x%x,"
 			   " value 0x%x\n", prtad, devad, addr, value);
 
-	if (prtad != bp->mdio.prtad) {
-		DP(NETIF_MSG_LINK, "prtad missmatch (cmd:0x%x != bp:0x%x)\n",
-		   prtad, bp->mdio.prtad);
-		return -EINVAL;
-	}
-
 	/* The HW expects different devad if CL22 is used */
 	devad = (devad == MDIO_DEVAD_NONE) ? DEFAULT_PHY_DEV_ADDR : devad;
 
 	bnx2x_acquire_phy_lock(bp);
-	rc = bnx2x_cl45_write(bp, BP_PORT(bp), ext_phy_type, prtad,
-			      devad, addr, value);
+	rc = bnx2x_phy_write(&bp->link_params, prtad, devad, addr, value);
 	bnx2x_release_phy_lock(bp);
 	return rc;
 }
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 3989617..398cf55 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -5135,18 +5135,22 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR	0x8005
 #define MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF	0x8007
 #define MDIO_PMA_REG_8727_TWO_WIRE_DATA_MASK 0xff
-#define MDIO_PMA_REG_8727_MISC_CTRL		0x8309
 #define MDIO_PMA_REG_8727_TX_CTRL1		0xca02
 #define MDIO_PMA_REG_8727_TX_CTRL2		0xca05
 #define MDIO_PMA_REG_8727_PCS_OPT_CTRL		0xc808
 #define MDIO_PMA_REG_8727_GPIO_CTRL		0xc80e
+#define MDIO_PMA_REG_8727_PCS_GP		0xc842
+
+#define MDIO_AN_REG_8727_MISC_CTRL		0x8309
 
 #define MDIO_PMA_REG_8073_CHIP_REV			0xc801
 #define MDIO_PMA_REG_8073_SPEED_LINK_STATUS		0xc820
 #define MDIO_PMA_REG_8073_XAUI_WA			0xc841
+#define MDIO_PMA_REG_8073_OPT_DIGITAL_CTRL		0xcd08
 
 #define MDIO_PMA_REG_7101_RESET 	0xc000
 #define MDIO_PMA_REG_7107_LED_CNTL	0xc007
+#define MDIO_PMA_REG_7107_LINK_LED_CNTL 0xc009
 #define MDIO_PMA_REG_7101_VER1		0xc026
 #define MDIO_PMA_REG_7101_VER2		0xc027
 
@@ -5210,11 +5214,13 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_AN_REG_CL37_FC_LP		0xffe5
 
 #define MDIO_AN_REG_8073_2_5G		0x8329
+#define MDIO_AN_REG_8073_BAM		0x8350
 
-#define MDIO_AN_REG_8727_MISC_CTRL	0x8309
 #define MDIO_AN_REG_8481_10GBASE_T_AN_CTRL	0x0020
 #define MDIO_AN_REG_8481_LEGACY_MII_CTRL	0xffe0
+#define MDIO_AN_REG_8481_LEGACY_MII_STATUS	0xffe1
 #define MDIO_AN_REG_8481_LEGACY_AN_ADV		0xffe4
+#define MDIO_AN_REG_8481_LEGACY_AN_EXPANSION	0xffe6
 #define MDIO_AN_REG_8481_1000T_CTRL		0xffe9
 #define MDIO_AN_REG_8481_EXPANSION_REG_RD_RW	0xfff5
 #define MDIO_AN_REG_8481_EXPANSION_REG_ACCESS	0xfff7
-- 
1.7.1




