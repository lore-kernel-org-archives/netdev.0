From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 08/10] bnxt_en: Add installed-package firmware version reporting via Ethtool GDRVINFO
Date: Fri, 26 Feb 2016 04:00:06 -0500
Message-ID: <1456477208-30692-9-git-send-email-michael.chan@broadcom.com>
References: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:16605
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbcBZJAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:00:49 -0500
In-Reply-To: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <swindell@broadcom.com>

For everything to fit, we remove the PHY microcode version and replace it
with the firmware package version in the fw_version string.

Signed-off-by: Rob Swindell <swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  | 95 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h | 14 ++++
 3 files changed, 109 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9ff498e..6e45a00 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3805,7 +3805,7 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 			    resp->hwrm_intf_upd);
 		netdev_warn(bp->dev, "Please update firmware with HWRM interface 1.0.0 or newer.\n");
 	}
-	snprintf(bp->fw_ver_str, BC_HWRM_STR_LEN, "bc %d.%d.%d rm %d.%d.%d",
+	snprintf(bp->fw_ver_str, BC_HWRM_STR_LEN, "%d.%d.%d/%d.%d.%d",
 		 resp->hwrm_fw_maj, resp->hwrm_fw_min, resp->hwrm_fw_bld,
 		 resp->hwrm_intf_maj, resp->hwrm_intf_min, resp->hwrm_intf_upd);
 
@@ -5725,7 +5725,6 @@ static int bnxt_probe_phy(struct bnxt *bp)
 {
 	int rc = 0;
 	struct bnxt_link_info *link_info = &bp->link_info;
-	char phy_ver[PHY_VER_STR_LEN];
 
 	rc = bnxt_update_link(bp, false);
 	if (rc) {
@@ -5745,11 +5744,6 @@ static int bnxt_probe_phy(struct bnxt *bp)
 		link_info->req_duplex = link_info->duplex_setting;
 		link_info->req_flow_ctrl = link_info->force_pause_setting;
 	}
-	snprintf(phy_ver, PHY_VER_STR_LEN, " ph %d.%d.%d",
-		 link_info->phy_ver[0],
-		 link_info->phy_ver[1],
-		 link_info->phy_ver[2]);
-	strcat(bp->fw_ver_str, phy_ver);
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index a2d2549..bfda92e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -7,6 +7,7 @@
  * the Free Software Foundation.
  */
 
+#include <linux/ctype.h>
 #include <linux/ethtool.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
@@ -20,6 +21,8 @@
 #include "bnxt_fw_hdr.h"	/* Firmware hdr constant and structure defs */
 #define FLASH_NVRAM_TIMEOUT	((HWRM_CMD_TIMEOUT) * 100)
 
+static char *bnxt_get_pkgver(struct net_device *dev, char *buf, size_t buflen);
+
 static u32 bnxt_get_msglevel(struct net_device *dev)
 {
 	struct bnxt *bp = netdev_priv(dev);
@@ -469,10 +472,20 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 			     struct ethtool_drvinfo *info)
 {
 	struct bnxt *bp = netdev_priv(dev);
+	char *pkglog;
+	char *pkgver = NULL;
 
+	pkglog = kmalloc(BNX_PKG_LOG_MAX_LENGTH, GFP_KERNEL);
+	if (pkglog)
+		pkgver = bnxt_get_pkgver(dev, pkglog, BNX_PKG_LOG_MAX_LENGTH);
 	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, bp->fw_ver_str, sizeof(info->fw_version));
+	if (pkgver && *pkgver != 0 && isdigit(*pkgver))
+		snprintf(info->fw_version, sizeof(info->fw_version) - 1,
+			 "%s pkg %s", bp->fw_ver_str, pkgver);
+	else
+		strlcpy(info->fw_version, bp->fw_ver_str,
+			sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
 	info->n_stats = BNXT_NUM_STATS * bp->cp_nr_rings;
 	info->testinfo_len = BNXT_NUM_TESTS(bp);
@@ -480,6 +493,7 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 	info->eedump_len = 0;
 	/* TODO CHIMP FW: reg dump details */
 	info->regdump_len = 0;
+	kfree(pkglog);
 }
 
 static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
@@ -1111,6 +1125,85 @@ static int bnxt_get_nvram_item(struct net_device *dev, u32 index, u32 offset,
 	return rc;
 }
 
+static int bnxt_find_nvram_item(struct net_device *dev, u16 type, u16 ordinal,
+				u16 ext, u16 *index, u32 *item_length,
+				u32 *data_length)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	int rc;
+	struct hwrm_nvm_find_dir_entry_input req = {0};
+	struct hwrm_nvm_find_dir_entry_output *output = bp->hwrm_cmd_resp_addr;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_NVM_FIND_DIR_ENTRY, -1, -1);
+	req.enables = 0;
+	req.dir_idx = 0;
+	req.dir_type = cpu_to_le16(type);
+	req.dir_ordinal = cpu_to_le16(ordinal);
+	req.dir_ext = cpu_to_le16(ext);
+	req.opt_ordinal = NVM_FIND_DIR_ENTRY_REQ_OPT_ORDINAL_EQ;
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc == 0) {
+		if (index)
+			*index = le16_to_cpu(output->dir_idx);
+		if (item_length)
+			*item_length = le32_to_cpu(output->dir_item_length);
+		if (data_length)
+			*data_length = le32_to_cpu(output->dir_data_length);
+	}
+	return rc;
+}
+
+static char *bnxt_parse_pkglog(int desired_field, u8 *data, size_t datalen)
+{
+	char	*retval = NULL;
+	char	*p;
+	char	*value;
+	int	field = 0;
+
+	if (datalen < 1)
+		return NULL;
+	/* null-terminate the log data (removing last '\n'): */
+	data[datalen - 1] = 0;
+	for (p = data; *p != 0; p++) {
+		field = 0;
+		retval = NULL;
+		while (*p != 0 && *p != '\n') {
+			value = p;
+			while (*p != 0 && *p != '\t' && *p != '\n')
+				p++;
+			if (field == desired_field)
+				retval = value;
+			if (*p != '\t')
+				break;
+			*p = 0;
+			field++;
+			p++;
+		}
+		if (*p == 0)
+			break;
+		*p = 0;
+	}
+	return retval;
+}
+
+static char *bnxt_get_pkgver(struct net_device *dev, char *buf, size_t buflen)
+{
+	u16 index = 0;
+	u32 datalen;
+
+	if (bnxt_find_nvram_item(dev, BNX_DIR_TYPE_PKG_LOG,
+				 BNX_DIR_ORDINAL_FIRST, BNX_DIR_EXT_NONE,
+				 &index, NULL, &datalen) != 0)
+		return NULL;
+
+	memset(buf, 0, buflen);
+	if (bnxt_get_nvram_item(dev, index, 0, datalen, buf) != 0)
+		return NULL;
+
+	return bnxt_parse_pkglog(BNX_PKG_LOG_FIELD_IDX_PKG_VERSION, buf,
+		datalen);
+}
+
 static int bnxt_get_eeprom(struct net_device *dev,
 			   struct ethtool_eeprom *eeprom,
 			   u8 *data)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
index 3cf3e1b..43ef392 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h
@@ -50,10 +50,24 @@ enum bnxt_nvm_directory_type {
 
 #define BNX_DIR_ORDINAL_FIRST			0
 
+#define BNX_DIR_EXT_NONE			0
 #define BNX_DIR_EXT_INACTIVE			(1 << 0)
 #define BNX_DIR_EXT_UPDATE			(1 << 1)
 
+#define BNX_DIR_ATTR_NONE			0
 #define BNX_DIR_ATTR_NO_CHKSUM			(1 << 0)
 #define BNX_DIR_ATTR_PROP_STREAM		(1 << 1)
 
+#define BNX_PKG_LOG_MAX_LENGTH			4096
+
+enum bnxnvm_pkglog_field_index {
+	BNX_PKG_LOG_FIELD_IDX_INSTALLED_TIMESTAMP	= 0,
+	BNX_PKG_LOG_FIELD_IDX_PKG_DESCRIPTION		= 1,
+	BNX_PKG_LOG_FIELD_IDX_PKG_VERSION		= 2,
+	BNX_PKG_LOG_FIELD_IDX_PKG_TIMESTAMP		= 3,
+	BNX_PKG_LOG_FIELD_IDX_PKG_CHECKSUM		= 4,
+	BNX_PKG_LOG_FIELD_IDX_INSTALLED_ITEMS		= 5,
+	BNX_PKG_LOG_FIELD_IDX_INSTALLED_MASK		= 6
+};
+
 #endif				/* Don't add anything after this line */
-- 
1.8.3.1
