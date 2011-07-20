From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6] be2net: request native mode each time the card is reset
Date: Wed, 20 Jul 2011 11:22:33 +0530
Message-ID: <1311141153-13272-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:26747 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751538Ab1GTFvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 01:51:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently be3-native mode is requested only in probe(). It must be requested, each time the card is reset either after an EEH error or after
sleep/hibernation.
Also, the be_cmd_check_native_mode() is better named be_cmd_req_native_mode()

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 drivers/net/benet/be_cmds.h |    2 +-
 drivers/net/benet/be_main.c |    6 ++++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index f520a5c..054fa67 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -2390,7 +2390,7 @@ err:
 }
 
 /* Uses mbox */
-int be_cmd_check_native_mode(struct be_adapter *adapter)
+int be_cmd_req_native_mode(struct be_adapter *adapter)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_set_func_cap *req;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 1151df6..8e4d488 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -1545,7 +1545,7 @@ extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
 extern void be_detect_dump_ue(struct be_adapter *adapter);
 extern int be_cmd_get_die_temperature(struct be_adapter *adapter);
 extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
-extern int be_cmd_check_native_mode(struct be_adapter *adapter);
+extern int be_cmd_req_native_mode(struct be_adapter *adapter);
 extern int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
 extern void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ae2d262..c411bb1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2511,6 +2511,8 @@ static int be_setup(struct be_adapter *adapter)
 	int status;
 	u8 mac[ETH_ALEN];
 
+	be_cmd_req_native_mode(adapter);
+
 	cap_flags = en_flags = BE_IF_FLAGS_UNTAGGED |
 				BE_IF_FLAGS_BROADCAST |
 				BE_IF_FLAGS_MULTICAST;
@@ -2618,6 +2620,8 @@ static int be_clear(struct be_adapter *adapter)
 
 	be_cmd_if_destroy(adapter, adapter->if_handle,  0);
 
+	adapter->be3_native = 0;
+
 	/* tell fw we're done with firing cmds */
 	be_cmd_fw_clean(adapter);
 	return 0;
@@ -3215,8 +3219,6 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	be_cmd_check_native_mode(adapter);
-
 	if ((num_vfs && adapter->sriov_enabled) ||
 		(adapter->function_mode & 0x400) ||
 		lancer_chip(adapter) || !be_physfn(adapter)) {
-- 
1.7.4

