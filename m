From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/4] be2net: don't create multiple RX/TX rings in multi channel mode
Date: Mon, 24 Oct 2011 18:15:03 +0530
Message-ID: <e74fddef-ba32-4524-8e80-c6746fdac07c@exht2.ad.emulex.com>
References: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Suresh Reddy <suresh.reddy@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:57529 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932284Ab1JXMp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 08:45:26 -0400
In-Reply-To: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the HW is in multi-channel mode based on the skew/IPL, there are 4 functions per port and so not enough resources to create multiple RX/TX rings for each function.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    6 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   16 ++++++++++++----
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 75b7574..a35cd03 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1046,6 +1046,12 @@ struct be_cmd_resp_modify_eq_delay {
 
 /******************** Get FW Config *******************/
 #define BE_FUNCTION_CAPS_RSS			0x2
+/* The HW can come up in either of the following multi-channel modes
+ * based on the skew/IPL.
+ */
+#define FLEX10_MODE				0x400
+#define VNIC_MODE				0x20000
+#define UMC_ENABLED				0x1000000
 struct be_cmd_req_query_fw_cfg {
 	struct be_cmd_req_hdr hdr;
 	u32 rsvd[31];
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 77ce24b..91fe12a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -114,6 +114,13 @@ static const char * const ue_status_hi_desc[] = {
 	"Unknown"
 };
 
+/* Is BE in a multi-channel mode */
+static inline bool be_is_mc(struct be_adapter *adapter) {
+	return (adapter->function_mode & FLEX10_MODE ||
+		adapter->function_mode & VNIC_MODE ||
+		adapter->function_mode & UMC_ENABLED);
+}
+
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
@@ -1289,7 +1296,7 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 	if (rxcp->vlanf) {
 		/* vlanf could be wrongly set in some cards.
 		 * ignore if vtm is not set */
-		if ((adapter->function_mode & 0x400) && !rxcp->vtm)
+		if ((adapter->function_mode & FLEX10_MODE) && !rxcp->vtm)
 			rxcp->vlanf = 0;
 
 		if (!lancer_chip(adapter))
@@ -1636,7 +1643,7 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 static int be_num_txqs_want(struct be_adapter *adapter)
 {
 	if ((num_vfs && adapter->sriov_enabled) ||
-		(adapter->function_mode & 0x400) ||
+		be_is_mc(adapter) ||
 		lancer_chip(adapter) || !be_physfn(adapter) ||
 		adapter->generation == BE_GEN2)
 		return 1;
@@ -1718,7 +1725,8 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 static u32 be_num_rxqs_want(struct be_adapter *adapter)
 {
 	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
-		!adapter->sriov_enabled && !(adapter->function_mode & 0x400)) {
+		!adapter->sriov_enabled && be_physfn(adapter) &&
+		!be_is_mc(adapter)) {
 		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
 	} else {
 		dev_warn(&adapter->pdev->dev,
@@ -3187,7 +3195,7 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	if (adapter->function_mode & 0x400)
+	if (adapter->function_mode & FLEX10_MODE)
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/4;
 	else
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED;
-- 
1.7.4
