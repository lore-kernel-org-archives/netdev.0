From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/14] bnxt_en: Get firmware package version one time.
Date: Thu, 26 Oct 2017 11:51:23 -0400
Message-ID: <1509033092-1887-6-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:47557 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932428AbdJZPvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:51:51 -0400
Received: by mail-qt0-f193.google.com with SMTP id z50so4879761qtj.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:51:51 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code retrieves the firmware package version from firmware
everytime ethtool -i is run.  There is no reason to do that as the
firmware will not change while the driver is loaded.  Get the version
once at init time.

Also, display the full 4-part firmware version string and remove the
less useful interface spec version.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 +--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 30 ++++++++++++-----------
 2 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d2403f4..ffc6c49 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4892,9 +4892,9 @@ static int bnxt_hwrm_ver_get(struct bnxt *bp)
 			    resp->hwrm_intf_upd);
 		netdev_warn(bp->dev, "Please update firmware with HWRM interface 1.0.0 or newer.\n");
 	}
-	snprintf(bp->fw_ver_str, BC_HWRM_STR_LEN, "%d.%d.%d/%d.%d.%d",
+	snprintf(bp->fw_ver_str, BC_HWRM_STR_LEN, "%d.%d.%d.%d",
 		 resp->hwrm_fw_maj, resp->hwrm_fw_min, resp->hwrm_fw_bld,
-		 resp->hwrm_intf_maj, resp->hwrm_intf_min, resp->hwrm_intf_upd);
+		 resp->hwrm_fw_rsvd);
 
 	bp->hwrm_cmd_timeout = le16_to_cpu(resp->def_req_timeout);
 	if (!bp->hwrm_cmd_timeout)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 85be1cb..fe93625 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -26,8 +26,6 @@
 #define FLASH_PACKAGE_TIMEOUT	((HWRM_CMD_TIMEOUT) * 200)
 #define INSTALL_PACKAGE_TIMEOUT	((HWRM_CMD_TIMEOUT) * 200)
 
-static char *bnxt_get_pkgver(struct net_device *dev, char *buf, size_t buflen);
-
 static u32 bnxt_get_msglevel(struct net_device *dev)
 {
 	struct bnxt *bp = netdev_priv(dev);
@@ -822,20 +820,10 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 			     struct ethtool_drvinfo *info)
 {
 	struct bnxt *bp = netdev_priv(dev);
-	char *pkglog;
-	char *pkgver = NULL;
 
-	pkglog = kmalloc(BNX_PKG_LOG_MAX_LENGTH, GFP_KERNEL);
-	if (pkglog)
-		pkgver = bnxt_get_pkgver(dev, pkglog, BNX_PKG_LOG_MAX_LENGTH);
 	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
-	if (pkgver && *pkgver != 0 && isdigit(*pkgver))
-		snprintf(info->fw_version, sizeof(info->fw_version) - 1,
-			 "%s pkg %s", bp->fw_ver_str, pkgver);
-	else
-		strlcpy(info->fw_version, bp->fw_ver_str,
-			sizeof(info->fw_version));
+	strlcpy(info->fw_version, bp->fw_ver_str, sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
 	info->n_stats = bnxt_get_num_stats(bp);
 	info->testinfo_len = bp->num_tests;
@@ -843,7 +831,6 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 	info->eedump_len = 0;
 	/* TODO CHIMP FW: reg dump details */
 	info->regdump_len = 0;
-	kfree(pkglog);
 }
 
 static void bnxt_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
@@ -2503,8 +2490,23 @@ void bnxt_ethtool_init(struct bnxt *bp)
 	struct hwrm_selftest_qlist_output *resp = bp->hwrm_cmd_resp_addr;
 	struct hwrm_selftest_qlist_input req = {0};
 	struct bnxt_test_info *test_info;
+	struct net_device *dev = bp->dev;
+	char *pkglog;
 	int i, rc;
 
+	pkglog = kzalloc(BNX_PKG_LOG_MAX_LENGTH, GFP_KERNEL);
+	if (pkglog) {
+		char *pkgver;
+		int len;
+
+		pkgver = bnxt_get_pkgver(dev, pkglog, BNX_PKG_LOG_MAX_LENGTH);
+		if (pkgver && *pkgver != 0 && isdigit(*pkgver)) {
+			len = strlen(bp->fw_ver_str);
+			snprintf(bp->fw_ver_str + len, FW_VER_STR_LEN - len - 1,
+				 "/pkg %s", pkgver);
+		}
+		kfree(pkglog);
+	}
 	if (bp->hwrm_spec_code < 0x10704 || !BNXT_SINGLE_PF(bp))
 		return;
 
-- 
1.8.3.1
