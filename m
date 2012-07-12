From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 2/7] be2net : Fix die temperature stat for Lancer
Date: Thu, 12 Jul 2012 19:26:46 +0530
Message-ID: <e48e1c11-ddcd-4e18-b4bd-694d044980fc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9040 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932522Ab2GLOAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:00:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Query die temperature stat for Lancer to report it correctly
in ethtool.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |    8 +-------
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 0490a04..748e870 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -435,6 +435,7 @@ struct be_adapter {
 	u32 max_pmac_cnt;	/* Max secondary UC MACs programmable */
 	u32 uc_macs;		/* Count of secondary UC MAC programmed */
 	u32 msg_enable;
+	int be_get_temp_freq;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 5eab791..d75c9fb 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -19,9 +19,6 @@
 #include "be.h"
 #include "be_cmds.h"
 
-/* Must be a power of 2 or else MODULO will BUG_ON */
-static int be_get_temp_freq = 64;
-
 static inline void *embedded_payload(struct be_mcc_wrb *wrb)
 {
 	return wrb->payload.embedded_payload;
@@ -115,7 +112,7 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 		}
 	} else {
 		if (opcode == OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES)
-			be_get_temp_freq = 0;
+			adapter->be_get_temp_freq = 0;
 
 		if (compl_status == MCC_STATUS_NOT_SUPPORTED ||
 			compl_status == MCC_STATUS_ILLEGAL_REQUEST)
@@ -1206,9 +1203,6 @@ int be_cmd_get_stats(struct be_adapter *adapter, struct be_dma_mem *nonemb_cmd)
 	struct be_cmd_req_hdr *hdr;
 	int status = 0;
 
-	if (MODULO(adapter->work_counter, be_get_temp_freq) == 0)
-		be_cmd_get_die_temperature(adapter);
-
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2141bd7..2436c3a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3567,6 +3567,9 @@ static int be_get_initial_config(struct be_adapter *adapter)
 	if (be_is_wol_supported(adapter))
 		adapter->wol = true;
 
+	/* Must be a power of 2 or else MODULO will BUG_ON */
+	adapter->be_get_temp_freq = 64;
+
 	level = be_get_fw_log_level(adapter);
 	adapter->msg_enable = level <= FW_LOG_LEVEL_DEFAULT ? NETIF_MSG_HW : 0;
 
@@ -3747,6 +3750,9 @@ static void be_worker(struct work_struct *work)
 			be_cmd_get_stats(adapter, &adapter->stats_cmd);
 	}
 
+	if (MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
+		be_cmd_get_die_temperature(adapter);
+
 	for_all_rx_queues(adapter, rxo, i) {
 		if (rxo->rx_post_starved) {
 			rxo->rx_post_starved = false;
-- 
1.6.0.2
