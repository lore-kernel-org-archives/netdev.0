From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2x: Support reading I2C EEPROM SFF8472
Date: Wed, 27 Mar 2013 13:05:18 +0200
Message-ID: <1364382319-24952-6-git-send-email-yuvalmin@broadcom.com>
References: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4668 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab3C0MKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:36 -0400
In-Reply-To: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Add full support for "ethtool -m" command.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  98 +++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   | 101 +++++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |  16 +++-
 3 files changed, 155 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 324d691..129d6b2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1393,10 +1393,9 @@ static int bnx2x_get_module_eeprom(struct net_device *dev,
 				   u8 *data)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int rc = 0, phy_idx;
+	int rc = -EINVAL, phy_idx;
 	u8 *user_data = data;
-	int remaining_len = ee->len, xfer_size;
-	unsigned int page_off = ee->offset;
+	unsigned int start_addr = ee->offset, xfer_size = 0;
 
 	if (!netif_running(dev)) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
@@ -1405,21 +1404,52 @@ static int bnx2x_get_module_eeprom(struct net_device *dev,
 	}
 
 	phy_idx = bnx2x_get_cur_phy_idx(bp);
-	bnx2x_acquire_phy_lock(bp);
-	while (!rc && remaining_len > 0) {
-		xfer_size = (remaining_len > SFP_EEPROM_PAGE_SIZE) ?
-			SFP_EEPROM_PAGE_SIZE : remaining_len;
+
+	/* Read A0 section */
+	if (start_addr < ETH_MODULE_SFF_8079_LEN) {
+		/* Limit transfer size to the A0 section boundary */
+		if (start_addr + ee->len > ETH_MODULE_SFF_8079_LEN)
+			xfer_size = ETH_MODULE_SFF_8079_LEN - start_addr;
+		else
+			xfer_size = ee->len;
+		bnx2x_acquire_phy_lock(bp);
 		rc = bnx2x_read_sfp_module_eeprom(&bp->link_params.phy[phy_idx],
 						  &bp->link_params,
-						  page_off,
+						  I2C_DEV_ADDR_A0,
+						  start_addr,
 						  xfer_size,
 						  user_data);
-		remaining_len -= xfer_size;
+		bnx2x_release_phy_lock(bp);
+		if (rc) {
+			DP(BNX2X_MSG_ETHTOOL, "Failed reading A0 section\n");
+
+			return -EINVAL;
+		}
 		user_data += xfer_size;
-		page_off += xfer_size;
+		start_addr += xfer_size;
 	}
 
-	bnx2x_release_phy_lock(bp);
+	/* Read A2 section */
+	if ((start_addr >= ETH_MODULE_SFF_8079_LEN) &&
+	    (start_addr < ETH_MODULE_SFF_8472_LEN)) {
+		xfer_size = ee->len - xfer_size;
+		/* Limit transfer size to the A2 section boundary */
+		if (start_addr + xfer_size > ETH_MODULE_SFF_8472_LEN)
+			xfer_size = ETH_MODULE_SFF_8472_LEN - start_addr;
+		start_addr -= ETH_MODULE_SFF_8079_LEN;
+		bnx2x_acquire_phy_lock(bp);
+		rc = bnx2x_read_sfp_module_eeprom(&bp->link_params.phy[phy_idx],
+						  &bp->link_params,
+						  I2C_DEV_ADDR_A2,
+						  start_addr,
+						  xfer_size,
+						  user_data);
+		bnx2x_release_phy_lock(bp);
+		if (rc) {
+			DP(BNX2X_MSG_ETHTOOL, "Failed reading A2 section\n");
+			return -EINVAL;
+		}
+	}
 	return rc;
 }
 
@@ -1427,24 +1457,50 @@ static int bnx2x_get_module_info(struct net_device *dev,
 				 struct ethtool_modinfo *modinfo)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int phy_idx;
+	int phy_idx, rc;
+	u8 sff8472_comp, diag_type;
+
 	if (!netif_running(dev)) {
-		DP(BNX2X_MSG_ETHTOOL  | BNX2X_MSG_NVM,
+		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 		   "cannot access eeprom when the interface is down\n");
 		return -EAGAIN;
 	}
-
 	phy_idx = bnx2x_get_cur_phy_idx(bp);
-	switch (bp->link_params.phy[phy_idx].media_type) {
-	case ETH_PHY_SFPP_10G_FIBER:
-	case ETH_PHY_SFP_1G_FIBER:
-	case ETH_PHY_DA_TWINAX:
+	bnx2x_acquire_phy_lock(bp);
+	rc = bnx2x_read_sfp_module_eeprom(&bp->link_params.phy[phy_idx],
+					  &bp->link_params,
+					  I2C_DEV_ADDR_A0,
+					  SFP_EEPROM_SFF_8472_COMP_ADDR,
+					  SFP_EEPROM_SFF_8472_COMP_SIZE,
+					  &sff8472_comp);
+	bnx2x_release_phy_lock(bp);
+	if (rc) {
+		DP(BNX2X_MSG_ETHTOOL, "Failed reading SFF-8472 comp field\n");
+		return -EINVAL;
+	}
+
+	bnx2x_acquire_phy_lock(bp);
+	rc = bnx2x_read_sfp_module_eeprom(&bp->link_params.phy[phy_idx],
+					  &bp->link_params,
+					  I2C_DEV_ADDR_A0,
+					  SFP_EEPROM_DIAG_TYPE_ADDR,
+					  SFP_EEPROM_DIAG_TYPE_SIZE,
+					  &diag_type);
+	bnx2x_release_phy_lock(bp);
+	if (rc) {
+		DP(BNX2X_MSG_ETHTOOL, "Failed reading Diag Type field\n");
+		return -EINVAL;
+	}
+
+	if (!sff8472_comp ||
+	    (diag_type & SFP_EEPROM_DIAG_ADDR_CHANGE_REQ)) {
 		modinfo->type = ETH_MODULE_SFF_8079;
 		modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
-		return 0;
-	default:
-		return -EOPNOTSUPP;
+	} else {
+		modinfo->type = ETH_MODULE_SFF_8472;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
 	}
+	return 0;
 }
 
 static int bnx2x_nvram_write_dword(struct bnx2x *bp, u32 offset, u32 val,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e3fa808..b1b034d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -27,6 +27,10 @@
 #include "bnx2x.h"
 #include "bnx2x_cmn.h"
 
+typedef int (*read_sfp_module_eeprom_func_p)(struct bnx2x_phy *phy,
+					     struct link_params *params,
+					     u8 dev_addr, u16 addr, u8 byte_cnt,
+					     u8 *o_buf, u8);
 /********************************************************/
 #define ETH_HLEN			14
 /* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
@@ -3128,11 +3132,6 @@ static int bnx2x_bsc_read(struct link_params *params,
 	int rc = 0;
 	struct bnx2x *bp = params->bp;
 
-	if ((sl_devid != 0xa0) && (sl_devid != 0xa2)) {
-		DP(NETIF_MSG_LINK, "invalid sl_devid 0x%x\n", sl_devid);
-		return -EINVAL;
-	}
-
 	if (xfer_cnt > 16) {
 		DP(NETIF_MSG_LINK, "invalid xfer_cnt %d. Max is 16 bytes\n",
 					xfer_cnt);
@@ -7770,7 +7769,8 @@ static void bnx2x_sfp_set_transmitter(struct link_params *params,
 
 static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 					     struct link_params *params,
-					     u16 addr, u8 byte_cnt, u8 *o_buf)
+					     u8 dev_addr, u16 addr, u8 byte_cnt,
+					     u8 *o_buf, u8 is_init)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
@@ -7783,7 +7783,7 @@ static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* Set the read command byte count */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
-			 (byte_cnt | 0xa000));
+			 (byte_cnt | (dev_addr << 8)));
 
 	/* Set the read command address */
 	bnx2x_cl45_write(bp, phy,
@@ -7857,6 +7857,7 @@ static void bnx2x_warpcore_power_module(struct link_params *params,
 }
 static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 						 struct link_params *params,
+						 u8 dev_addr,
 						 u16 addr, u8 byte_cnt,
 						 u8 *o_buf, u8 is_init)
 {
@@ -7881,7 +7882,7 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 			usleep_range(1000, 2000);
 			bnx2x_warpcore_power_module(params, 1);
 		}
-		rc = bnx2x_bsc_read(params, phy, 0xa0, addr32, 0, byte_cnt,
+		rc = bnx2x_bsc_read(params, phy, dev_addr, addr32, 0, byte_cnt,
 				    data_array);
 	} while ((rc != 0) && (++cnt < I2C_WA_RETRY_CNT));
 
@@ -7897,7 +7898,8 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 
 static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 					     struct link_params *params,
-					     u16 addr, u8 byte_cnt, u8 *o_buf)
+					     u8 dev_addr, u16 addr, u8 byte_cnt,
+					     u8 *o_buf, u8 is_init)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val, i;
@@ -7908,6 +7910,15 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 		return -EINVAL;
 	}
 
+	/* Set 2-wire transfer rate of SFP+ module EEPROM
+	 * to 100Khz since some DACs(direct attached cables) do
+	 * not work at 400Khz.
+	 */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
+			 ((dev_addr << 8) | 1));
+
 	/* Need to read from 1.8000 to clear it */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD,
@@ -7980,26 +7991,44 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 
 	return -EINVAL;
 }
-
 int bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
-				 struct link_params *params, u16 addr,
-				 u8 byte_cnt, u8 *o_buf)
+				 struct link_params *params, u8 dev_addr,
+				 u16 addr, u16 byte_cnt, u8 *o_buf)
 {
-	int rc = -EOPNOTSUPP;
+	int rc = 0;
+	struct bnx2x *bp = params->bp;
+	u8 xfer_size;
+	u8 *user_data = o_buf;
+	read_sfp_module_eeprom_func_p read_func;
+
+	if ((dev_addr != 0xa0) && (dev_addr != 0xa2)) {
+		DP(NETIF_MSG_LINK, "invalid dev_addr 0x%x\n", dev_addr);
+		return -EINVAL;
+	}
+
 	switch (phy->type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		rc = bnx2x_8726_read_sfp_module_eeprom(phy, params, addr,
-						       byte_cnt, o_buf);
-	break;
+		read_func = bnx2x_8726_read_sfp_module_eeprom;
+		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8722:
-		rc = bnx2x_8727_read_sfp_module_eeprom(phy, params, addr,
-						       byte_cnt, o_buf);
-	break;
+		read_func = bnx2x_8727_read_sfp_module_eeprom;
+		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-		rc = bnx2x_warpcore_read_sfp_module_eeprom(phy, params, addr,
-							   byte_cnt, o_buf, 0);
-	break;
+		read_func = bnx2x_warpcore_read_sfp_module_eeprom;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	while (!rc && (byte_cnt > 0)) {
+		xfer_size = (byte_cnt > SFP_EEPROM_PAGE_SIZE) ?
+			SFP_EEPROM_PAGE_SIZE : byte_cnt;
+		rc = read_func(phy, params, dev_addr, addr, xfer_size,
+			       user_data, 0);
+		byte_cnt -= xfer_size;
+		user_data += xfer_size;
+		addr += xfer_size;
 	}
 	return rc;
 }
@@ -8016,6 +8045,7 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	/* First check for copper cable */
 	if (bnx2x_read_sfp_module_eeprom(phy,
 					 params,
+					 I2C_DEV_ADDR_A0,
 					 SFP_EEPROM_CON_TYPE_ADDR,
 					 2,
 					 (u8 *)val) != 0) {
@@ -8033,6 +8063,7 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 		 */
 		if (bnx2x_read_sfp_module_eeprom(phy,
 					       params,
+					       I2C_DEV_ADDR_A0,
 					       SFP_EEPROM_FC_TX_TECH_ADDR,
 					       1,
 					       &copper_module_type) != 0) {
@@ -8117,6 +8148,7 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 		u8 options[SFP_EEPROM_OPTIONS_SIZE];
 		if (bnx2x_read_sfp_module_eeprom(phy,
 						 params,
+						 I2C_DEV_ADDR_A0,
 						 SFP_EEPROM_OPTIONS_ADDR,
 						 SFP_EEPROM_OPTIONS_SIZE,
 						 options) != 0) {
@@ -8183,6 +8215,7 @@ static int bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	/* Format the warning message */
 	if (bnx2x_read_sfp_module_eeprom(phy,
 					 params,
+					 I2C_DEV_ADDR_A0,
 					 SFP_EEPROM_VENDOR_NAME_ADDR,
 					 SFP_EEPROM_VENDOR_NAME_SIZE,
 					 (u8 *)vendor_name))
@@ -8191,6 +8224,7 @@ static int bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 		vendor_name[SFP_EEPROM_VENDOR_NAME_SIZE] = '\0';
 	if (bnx2x_read_sfp_module_eeprom(phy,
 					 params,
+					 I2C_DEV_ADDR_A0,
 					 SFP_EEPROM_PART_NO_ADDR,
 					 SFP_EEPROM_PART_NO_SIZE,
 					 (u8 *)vendor_pn))
@@ -8221,12 +8255,13 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 
 	for (timeout = 0; timeout < 60; timeout++) {
 		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)
-			rc = bnx2x_warpcore_read_sfp_module_eeprom(phy,
-								   params, 1,
-								   1, &val, 1);
+			rc = bnx2x_warpcore_read_sfp_module_eeprom(
+				phy, params, I2C_DEV_ADDR_A0, 1, 1, &val,
+				1);
 		else
-			rc = bnx2x_read_sfp_module_eeprom(phy, params, 1, 1,
-							  &val);
+			rc = bnx2x_read_sfp_module_eeprom(phy, params,
+							  I2C_DEV_ADDR_A0,
+							  1, 1, &val);
 		if (rc == 0) {
 			DP(NETIF_MSG_LINK,
 			   "SFP+ module initialization took %d ms\n",
@@ -8235,7 +8270,8 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 		}
 		usleep_range(5000, 10000);
 	}
-	rc = bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val);
+	rc = bnx2x_read_sfp_module_eeprom(phy, params, I2C_DEV_ADDR_A0,
+					  1, 1, &val);
 	return rc;
 }
 
@@ -8392,15 +8428,6 @@ static void bnx2x_8727_specific_func(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 				 val);
-
-		/* Set 2-wire transfer rate of SFP+ module EEPROM
-		 * to 100Khz since some DACs(direct attached cables) do
-		 * not work at 400Khz.
-		 */
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_PMA_DEVAD,
-				 MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
-				 0xa001);
 		break;
 	default:
 		DP(NETIF_MSG_LINK, "Function 0x%x not supported by 8727\n",
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 56c2aae..4df4523 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -41,6 +41,9 @@
 #define SPEED_AUTO_NEG		0
 #define SPEED_20000		20000
 
+#define I2C_DEV_ADDR_A0			0xa0
+#define I2C_DEV_ADDR_A2			0xa2
+
 #define SFP_EEPROM_PAGE_SIZE			16
 #define SFP_EEPROM_VENDOR_NAME_ADDR		0x14
 #define SFP_EEPROM_VENDOR_NAME_SIZE		16
@@ -54,6 +57,15 @@
 #define SFP_EEPROM_SERIAL_SIZE			16
 #define SFP_EEPROM_DATE_ADDR			0x54 /* ASCII YYMMDD */
 #define SFP_EEPROM_DATE_SIZE			6
+#define SFP_EEPROM_DIAG_TYPE_ADDR		0x5c
+#define SFP_EEPROM_DIAG_TYPE_SIZE		1
+#define SFP_EEPROM_DIAG_ADDR_CHANGE_REQ		(1<<2)
+#define SFP_EEPROM_SFF_8472_COMP_ADDR		0x5e
+#define SFP_EEPROM_SFF_8472_COMP_SIZE		1
+
+#define SFP_EEPROM_A2_CHECKSUM_RANGE		0x5e
+#define SFP_EEPROM_A2_CC_DMI_ADDR		0x5f
+
 #define PWR_FLT_ERR_MSG_LEN			250
 
 #define XGXS_EXT_PHY_TYPE(ext_phy_config) \
@@ -420,8 +432,8 @@ void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy);
 
 /* Read "byte_cnt" bytes from address "addr" from the SFP+ EEPROM */
 int bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
-				 struct link_params *params, u16 addr,
-				 u8 byte_cnt, u8 *o_buf);
+				 struct link_params *params, u8 dev_addr,
+				 u16 addr, u16 byte_cnt, u8 *o_buf);
 
 void bnx2x_hw_reset_phy(struct link_params *params);
 
-- 
1.8.1.227.g44fe835
