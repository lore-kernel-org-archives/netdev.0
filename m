From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net:patch to implement ethtool get_phys_id
	function.
Date: Fri, 9 Oct 2009 18:43:16 +0530
Message-ID: <20091009131306.GA32311@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:46924 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754561AbZJINOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:14:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

please accept patch, implements port beacon functionality for be2net driver.

Signed-off-by: sarveshwarb <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c    |   59 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   37 +++++++++++++++++++++++++
 drivers/net/benet/be_ethtool.c |   30 ++++++++++++++++++++
 3 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 89876ad..25b6602 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1118,6 +1118,65 @@ int be_cmd_reset_function(struct be_adap
 	return status;
 }
 
+/* Uses sync mcc */
+int be_cmd_set_beacon_state(struct be_adapter *adapter, u8 port_num,
+			u8 bcn, u8 sts, u8 state)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_enable_disable_beacon *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_ENABLE_DISABLE_BEACON, sizeof(*req));
+
+	req->port_num = port_num;
+	req->beacon_state = state;
+	req->beacon_duration = bcn;
+	req->status_duration = sts;
+
+	status = be_mcc_notify_wait(adapter);
+
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
+/* Uses sync mcc */
+int be_cmd_get_beacon_state(struct be_adapter *adapter, u8 port_num, u32 *state)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_beacon_state *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_GET_BEACON_STATE, sizeof(*req));
+
+	req->port_num = port_num;
+
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_get_beacon_state *resp =
+						embedded_payload(wrb);
+		*state = resp->beacon_state;
+	}
+
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			u32 flash_type, u32 flash_opcode, u32 buf_size)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index a86f917..a1e78cc 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -138,6 +138,8 @@ #define OPCODE_COMMON_QUERY_FIRMWARE_CON
 #define OPCODE_COMMON_NTWK_PMAC_ADD			59
 #define OPCODE_COMMON_NTWK_PMAC_DEL			60
 #define OPCODE_COMMON_FUNCTION_RESET			61
+#define OPCODE_COMMON_ENABLE_DISABLE_BEACON		69
+#define OPCODE_COMMON_GET_BEACON_STATE			70
 
 #define OPCODE_ETH_ACPI_CONFIG				2
 #define OPCODE_ETH_PROMISCUOUS				3
@@ -699,6 +701,37 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 rsvd[26];
 };
 
+/******************** Port Beacon ***************************/
+
+#define BEACON_STATE_ENABLED		0x1
+#define BEACON_STATE_DISABLED		0x0
+
+struct be_cmd_req_enable_disable_beacon {
+	struct be_cmd_req_hdr hdr;
+	u8  port_num;
+	u8  beacon_state;
+	u8  beacon_duration;
+	u8  status_duration;
+} __packed;
+
+struct be_cmd_resp_enable_disable_beacon {
+	struct be_cmd_resp_hdr resp_hdr;
+	u32 rsvd0;
+} __packed;
+
+struct be_cmd_req_get_beacon_state {
+	struct be_cmd_req_hdr hdr;
+	u8  port_num;
+	u8  rsvd0;
+	u16 rsvd1;
+} __packed;
+
+struct be_cmd_resp_get_beacon_state {
+	struct be_cmd_resp_hdr resp_hdr;
+	u8 beacon_state;
+	u8 rsvd0[3];
+} __packed;
+
 /****************** Firmware Flash ******************/
 struct flashrom_params {
 	u32 op_code;
@@ -764,6 +797,10 @@ extern int be_cmd_query_fw_cfg(struct be
 			u32 *port_num, u32 *cap);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
 extern int be_process_mcc(struct be_adapter *adapter);
+extern int be_cmd_set_beacon_state(struct be_adapter *adapter,
+			u8 port_num, u8 beacon, u8 status, u8 state);
+extern int be_cmd_get_beacon_state(struct be_adapter *adapter,
+			u8 port_num, u32 *state);
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 333729b..280471e 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -338,6 +338,35 @@ be_set_pauseparam(struct net_device *net
 }
 
 static int
+be_phys_id(struct net_device *netdev, u32 data)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	int status;
+	u32 cur;
+
+	if (!netif_running(netdev))
+		return 0;
+
+	be_cmd_get_beacon_state(adapter, adapter->port_num, &cur);
+
+	if (cur == BEACON_STATE_ENABLED)
+		return 0;
+
+	if (data < 2)
+		data = 2;
+
+	status = be_cmd_set_beacon_state(adapter, adapter->port_num, 0, 0,
+			BEACON_STATE_ENABLED);
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule_timeout(data*HZ);
+
+	status = be_cmd_set_beacon_state(adapter, adapter->port_num, 0, 0,
+			BEACON_STATE_DISABLED);
+
+	return status;
+}
+
+static int
 be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -369,6 +398,7 @@ const struct ethtool_ops be_ethtool_ops 
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
 	.get_strings = be_get_stat_strings,
+	.phys_id = be_phys_id,
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
 	.flash_device = be_do_flash,
-- 
1.4.0

