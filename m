From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 08/14] be2net: reduce arguments passed to FW-cmd routines
Date: Thu, 17 Jul 2014 16:20:26 +0530
Message-ID: <1405594232-30818-9-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22735 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756786AbaGQKsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:36 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

A pointer to adapter struct is passed anyway to all of the FW-cmd routines
in be_cmds.c. For routines which query data from FW, the adapter pointer
is enough to return the queried fields.
There is no need to separately pass pointers to individual members of
the adapter structure. This patch fixes this for be_cmd_get_fw_ver()
and be_cmd_get_fw_cfg() routines.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   19 ++++++++-----------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    6 ++----
 drivers/net/ethernet/emulex/benet/be_main.c |   10 +++-------
 3 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index e632bd2..791094c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1749,8 +1749,7 @@ err:
 }
 
 /* Uses synchronous mcc */
-int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
-		      char *fw_on_flash)
+int be_cmd_get_fw_ver(struct be_adapter *adapter)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_fw_version *req;
@@ -1772,9 +1771,8 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
-		strcpy(fw_ver, resp->firmware_version_string);
-		if (fw_on_flash)
-			strcpy(fw_on_flash, resp->fw_on_flash_version_string);
+		strcpy(adapter->fw_ver, resp->firmware_version_string);
+		strcpy(adapter->fw_on_flash, resp->fw_on_flash_version_string);
 	}
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
@@ -1997,8 +1995,7 @@ err:
 }
 
 /* Uses mbox */
-int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
-			u32 *mode, u32 *caps, u16 *asic_rev)
+int be_cmd_query_fw_cfg(struct be_adapter *adapter)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_query_fw_cfg *req;
@@ -2017,10 +2014,10 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
 	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
-		*port_num = le32_to_cpu(resp->phys_port);
-		*mode = le32_to_cpu(resp->function_mode);
-		*caps = le32_to_cpu(resp->function_caps);
-		*asic_rev = le32_to_cpu(resp->asic_revision) & 0xFF;
+		adapter->port_num = le32_to_cpu(resp->phys_port);
+		adapter->function_mode = le32_to_cpu(resp->function_mode);
+		adapter->function_caps = le32_to_cpu(resp->function_caps);
+		adapter->asic_rev = le32_to_cpu(resp->asic_revision) & 0xFF;
 	}
 
 	mutex_unlock(&adapter->mbox_lock);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index c0f7167..a9219a9 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2071,16 +2071,14 @@ int be_cmd_reset(struct be_adapter *adapter);
 int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd);
 int lancer_cmd_get_pport_stats(struct be_adapter *adapter,
 			       struct be_dma_mem *nonemb_cmd);
-int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver,
-		      char *fw_on_flash);
+int be_cmd_get_fw_ver(struct be_adapter *adapter);
 int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *, int num);
 int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id, u16 *vtag_array,
 		       u32 num);
 int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 status);
 int be_cmd_set_flow_control(struct be_adapter *adapter, u32 tx_fc, u32 rx_fc);
 int be_cmd_get_flow_control(struct be_adapter *adapter, u32 *tx_fc, u32 *rx_fc);
-int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num,
-			u32 *function_mode, u32 *function_caps, u16 *asic_rev);
+int be_cmd_query_fw_cfg(struct be_adapter *adapter);
 int be_cmd_reset_function(struct be_adapter *adapter);
 int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 		      u32 rss_hash_opts, u16 table_size, const u8 *rss_hkey);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e50cf03..1abca8b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3425,10 +3425,7 @@ static int be_get_config(struct be_adapter *adapter)
 	u16 profile_id;
 	int status;
 
-	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num,
-				     &adapter->function_mode,
-				     &adapter->function_caps,
-				     &adapter->asic_rev);
+	status = be_cmd_query_fw_cfg(adapter);
 	if (status)
 		return status;
 
@@ -3617,7 +3614,7 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
+	be_cmd_get_fw_ver(adapter);
 
 	if (BE2_chip(adapter) && fw_major_num(adapter->fw_ver) < 4) {
 		dev_err(dev, "Firmware on card is old(%s), IRQs may not work.",
@@ -4247,8 +4244,7 @@ int be_load_fw(struct be_adapter *adapter, u8 *fw_file)
 		status = be_fw_download(adapter, fw);
 
 	if (!status)
-		be_cmd_get_fw_ver(adapter, adapter->fw_ver,
-				  adapter->fw_on_flash);
+		be_cmd_get_fw_ver(adapter);
 
 fw_exit:
 	release_firmware(fw);
-- 
1.7.1
