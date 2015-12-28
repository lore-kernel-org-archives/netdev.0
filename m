From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next v2 09/10] be2net: support ethtool get-dump option
Date: Mon, 28 Dec 2015 01:49:23 -0500
Message-ID: <1451285364-9074-10-git-send-email-sathya.perla@avagotech.com>
References: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:54934 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751415AbbL1Gti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 01:49:38 -0500
In-Reply-To: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>

This patch adds support for ethtool's --get-dump option in be2net,
to retrieve FW dump. In the past when this option was not yet available,
this feature was supported via the --register-dump option as a workaround.
This patch removes support for FW-dump via --register-dump option as it is
now available via --get-dump option. Even though the
"ethtool --register-dump" cmd which used to work earlier, will now fail
with ENOTSUPP error, we feel it is not an issue as this is used only
for diagnostics purpose.

Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |  1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 38 ++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  4 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 82 ++++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_main.c    |  3 +
 5 files changed, 71 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 66988f4..8b8212f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -592,6 +592,7 @@ struct be_adapter {
 	struct rss_info rss_info;
 	/* Filters for packets that need to be sent to BMC */
 	u32 bmc_filt_mask;
+	u32 fat_dump_len;
 	u16 serial_num[CNTL_SERIAL_NUM_WORDS];
 };
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 87c3dba..5a5b40d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1712,49 +1712,40 @@ err:
 }
 
 /* Uses synchronous mcc */
-int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size)
+int be_cmd_get_fat_dump_len(struct be_adapter *adapter, u32 *dump_size)
 {
-	struct be_mcc_wrb *wrb;
+	struct be_mcc_wrb wrb = {0};
 	struct be_cmd_req_get_fat *req;
 	int status;
 
-	spin_lock_bh(&adapter->mcc_lock);
-
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
-	req = embedded_payload(wrb);
+	req = embedded_payload(&wrb);
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			       OPCODE_COMMON_MANAGE_FAT, sizeof(*req), wrb,
-			       NULL);
+			       OPCODE_COMMON_MANAGE_FAT, sizeof(*req),
+			       &wrb, NULL);
 	req->fat_operation = cpu_to_le32(QUERY_FAT);
-	status = be_mcc_notify_wait(adapter);
+	status = be_cmd_notify_wait(adapter, &wrb);
 	if (!status) {
-		struct be_cmd_resp_get_fat *resp = embedded_payload(wrb);
+		struct be_cmd_resp_get_fat *resp = embedded_payload(&wrb);
 
-		if (log_size && resp->log_size)
-			*log_size = le32_to_cpu(resp->log_size) -
+		if (dump_size && resp->log_size)
+			*dump_size = le32_to_cpu(resp->log_size) -
 					sizeof(u32);
 	}
-err:
-	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
-int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
+int be_cmd_get_fat_dump(struct be_adapter *adapter, u32 buf_len, void *buf)
 {
 	struct be_dma_mem get_fat_cmd;
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_fat *req;
 	u32 offset = 0, total_size, buf_size,
 				log_offset = sizeof(u32), payload_len;
-	int status = 0;
+	int status;
 
 	if (buf_len == 0)
-		return -EIO;
+		return 0;
 
 	total_size = buf_len;
 
@@ -1762,11 +1753,8 @@ int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 	get_fat_cmd.va = dma_zalloc_coherent(&adapter->pdev->dev,
 					     get_fat_cmd.size,
 					     &get_fat_cmd.dma, GFP_ATOMIC);
-	if (!get_fat_cmd.va) {
-		dev_err(&adapter->pdev->dev,
-			"Memory allocation failure while reading FAT data\n");
+	if (!get_fat_cmd.va)
 		return -ENOMEM;
-	}
 
 	spin_lock_bh(&adapter->mcc_lock);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 5098170..241819b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2365,9 +2365,9 @@ int be_cmd_config_qos(struct be_adapter *adapter, u32 max_rate,
 void be_detect_error(struct be_adapter *adapter);
 int be_cmd_get_die_temperature(struct be_adapter *adapter);
 int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
+int be_cmd_get_fat_dump_len(struct be_adapter *adapter, u32 *dump_size);
+int be_cmd_get_fat_dump(struct be_adapter *adapter, u32 buf_len, void *buf);
 int be_cmd_req_native_mode(struct be_adapter *adapter);
-int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
-int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
 int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
 			     u32 domain);
 int be_cmd_set_fn_privileges(struct be_adapter *adapter, u32 privileges,
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index d2a5baf..a19ac44 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -250,6 +250,19 @@ static u32 lancer_cmd_get_file_len(struct be_adapter *adapter, u8 *file_name)
 	return data_read;
 }
 
+static int be_get_dump_len(struct be_adapter *adapter)
+{
+	u32 dump_size = 0;
+
+	if (lancer_chip(adapter))
+		dump_size = lancer_cmd_get_file_len(adapter,
+						    LANCER_FW_DUMP_FILE);
+	else
+		dump_size = adapter->fat_dump_len;
+
+	return dump_size;
+}
+
 static int lancer_cmd_read_file(struct be_adapter *adapter, u8 *file_name,
 				u32 buf_len, void *buf)
 {
@@ -291,37 +304,18 @@ static int lancer_cmd_read_file(struct be_adapter *adapter, u8 *file_name,
 	return status;
 }
 
-static int be_get_reg_len(struct net_device *netdev)
+static int be_read_dump_data(struct be_adapter *adapter, u32 dump_len,
+			     void *buf)
 {
-	struct be_adapter *adapter = netdev_priv(netdev);
-	u32 log_size = 0;
-
-	if (!check_privilege(adapter, MAX_PRIVILEGES))
-		return 0;
-
-	if (be_physfn(adapter)) {
-		if (lancer_chip(adapter))
-			log_size = lancer_cmd_get_file_len(adapter,
-							   LANCER_FW_DUMP_FILE);
-		else
-			be_cmd_get_reg_len(adapter, &log_size);
-	}
-	return log_size;
-}
+	int status = 0;
 
-static void
-be_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *buf)
-{
-	struct be_adapter *adapter = netdev_priv(netdev);
+	if (lancer_chip(adapter))
+		status = lancer_cmd_read_file(adapter, LANCER_FW_DUMP_FILE,
+					      dump_len, buf);
+	else
+		status = be_cmd_get_fat_dump(adapter, dump_len, buf);
 
-	if (be_physfn(adapter)) {
-		memset(buf, 0, regs->len);
-		if (lancer_chip(adapter))
-			lancer_cmd_read_file(adapter, LANCER_FW_DUMP_FILE,
-					     regs->len, buf);
-		else
-			be_cmd_get_regs(adapter, regs->len, buf);
-	}
+	return status;
 }
 
 static int be_get_coalesce(struct net_device *netdev,
@@ -914,6 +908,34 @@ static int be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 	return be_load_fw(adapter, efl->data);
 }
 
+static int
+be_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (!check_privilege(adapter, MAX_PRIVILEGES))
+		return -EOPNOTSUPP;
+
+	dump->len = be_get_dump_len(adapter);
+	dump->version = 1;
+	dump->flag = 0x1;	/* FW dump is enabled */
+	return 0;
+}
+
+static int
+be_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
+		 void *buf)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status;
+
+	if (!check_privilege(adapter, MAX_PRIVILEGES))
+		return -EOPNOTSUPP;
+
+	status = be_read_dump_data(adapter, dump->len, buf);
+	return be_cmd_status(status);
+}
+
 static int be_get_eeprom_len(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -1311,8 +1333,6 @@ const struct ethtool_ops be_ethtool_ops = {
 	.set_msglevel = be_set_msg_level,
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
-	.get_regs_len = be_get_reg_len,
-	.get_regs = be_get_regs,
 	.flash_device = be_do_flash,
 	.self_test = be_self_test,
 	.get_rxnfc = be_get_rxnfc,
@@ -1321,6 +1341,8 @@ const struct ethtool_ops be_ethtool_ops = {
 	.get_rxfh_key_size = be_get_rxfh_key_size,
 	.get_rxfh = be_get_rxfh,
 	.set_rxfh = be_set_rxfh,
+	.get_dump_flag = be_get_dump_flag,
+	.get_dump_data = be_get_dump_data,
 	.get_channels = be_get_channels,
 	.set_channels = be_set_channels,
 	.get_module_info = be_get_module_info,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7039870..00059af 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4212,6 +4212,9 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
+	if (!lancer_chip(adapter) && be_physfn(adapter))
+		be_cmd_get_fat_dump_len(adapter, &adapter->fat_dump_len);
+
 	if (BEx_chip(adapter)) {
 		level = be_cmd_get_fw_log_level(adapter);
 		adapter->msg_enable =
-- 
2.4.1
