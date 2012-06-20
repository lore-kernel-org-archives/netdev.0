From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2x: link module eeprom
Date: Wed, 20 Jun 2012 11:49:35 +0300
Message-ID: <1340182175-916-7-git-send-email-yuvalmin@broadcom.com>
References: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1933 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755688Ab2FTIwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:52:01 -0400
In-Reply-To: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool functionality of accessing optic modules'
information and eeprom to the bnx2x driver.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   63 +++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    9 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    1 +
 3 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 819170e..0f158b6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1160,6 +1160,65 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 	return rc;
 }
 
+static int bnx2x_get_module_eeprom(struct net_device *dev,
+				   struct ethtool_eeprom *ee,
+				   u8 *data)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int rc = 0, phy_idx;
+	u8 *user_data = data;
+	int remaining_len = ee->len, xfer_size;
+	unsigned int page_off = ee->offset;
+
+	if (!netif_running(dev)) {
+		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+		   "cannot access eeprom when the interface is down\n");
+		return -EAGAIN;
+	}
+
+	phy_idx = bnx2x_get_cur_phy_idx(bp);
+	bnx2x_acquire_phy_lock(bp);
+	while (!rc && remaining_len > 0) {
+		xfer_size = (remaining_len > SFP_EEPROM_PAGE_SIZE) ?
+			SFP_EEPROM_PAGE_SIZE : remaining_len;
+		rc = bnx2x_read_sfp_module_eeprom(&bp->link_params.phy[phy_idx],
+						  &bp->link_params,
+						  page_off,
+						  xfer_size,
+						  user_data);
+		remaining_len -= xfer_size;
+		user_data += xfer_size;
+		page_off += xfer_size;
+	}
+
+	bnx2x_release_phy_lock(bp);
+	return rc;
+}
+
+static int bnx2x_get_module_info(struct net_device *dev,
+				 struct ethtool_modinfo *modinfo)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int phy_idx;
+	if (!netif_running(dev)) {
+		DP(BNX2X_MSG_ETHTOOL  | BNX2X_MSG_NVM,
+		   "cannot access eeprom when the interface is down\n");
+		return -EAGAIN;
+	}
+
+	phy_idx = bnx2x_get_cur_phy_idx(bp);
+	switch (bp->link_params.phy[phy_idx].media_type) {
+	case ETH_PHY_SFPP_10G_FIBER:
+	case ETH_PHY_SFP_1G_FIBER:
+	case ETH_PHY_DA_TWINAX:
+		modinfo->type = ETH_MODULE_SFF_8079;
+		modinfo->eeprom_len = ETH_MODULE_SFF_8079_LEN;
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int bnx2x_nvram_write_dword(struct bnx2x *bp, u32 offset, u32 val,
 				   u32 cmd_flags)
 {
@@ -2915,7 +2974,9 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
 	.get_channels		= bnx2x_get_channels,
 	.set_channels		= bnx2x_set_channels,
-	.get_eee		= bnx2x_get_eee,
+	.get_module_info	= bnx2x_get_module_info,
+	.get_module_eeprom	= bnx2x_get_module_eeprom,
+	.get_eee		= bnx2x_get_eee,
 	.set_eee		= bnx2x_set_eee,
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 36845f7..8803f77 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -7696,7 +7696,7 @@ static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
 	u16 i;
-	if (byte_cnt > 16) {
+	if (byte_cnt > SFP_EEPROM_PAGE_SIZE) {
 		DP(NETIF_MSG_LINK,
 		   "Reading from eeprom is limited to 0xf\n");
 		return -EINVAL;
@@ -7765,7 +7765,8 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	u32 data_array[4];
 	u16 addr32;
 	struct bnx2x *bp = params->bp;
-	if (byte_cnt > 16) {
+
+	if (byte_cnt > SFP_EEPROM_PAGE_SIZE) {
 		DP(NETIF_MSG_LINK,
 		   "Reading from eeprom is limited to 16 bytes\n");
 		return -EINVAL;
@@ -7795,7 +7796,7 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 val, i;
 
-	if (byte_cnt > 16) {
+	if (byte_cnt > SFP_EEPROM_PAGE_SIZE) {
 		DP(NETIF_MSG_LINK,
 		   "Reading from eeprom is limited to 0xf\n");
 		return -EINVAL;
@@ -7878,7 +7879,7 @@ int bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 				 struct link_params *params, u16 addr,
 				 u8 byte_cnt, u8 *o_buf)
 {
-	int rc = -EINVAL;
+	int rc = -EOPNOTSUPP;
 	switch (phy->type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		rc = bnx2x_8726_read_sfp_module_eeprom(phy, params, addr,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 017236b..c05f9d9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -41,6 +41,7 @@
 #define SPEED_AUTO_NEG		0
 #define SPEED_20000		20000
 
+#define SFP_EEPROM_PAGE_SIZE			16
 #define SFP_EEPROM_VENDOR_NAME_ADDR		0x14
 #define SFP_EEPROM_VENDOR_NAME_SIZE		16
 #define SFP_EEPROM_VENDOR_OUI_ADDR		0x25
-- 
1.7.9.rc2
