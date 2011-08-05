From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 3/6] be2net: add be_cmd_get_port_speed to get port
 speed
Date: Fri, 5 Aug 2011 15:00:17 -0500
Message-ID: <20110805200017.GA13562@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2936 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755900Ab1HEUAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:00:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |   35 +++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h |   15 +++++++++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 863ae67..ee6d274 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -2368,6 +2368,41 @@ err:
 	return status;
 }
 
+int be_cmd_get_port_speed(struct be_adapter *adapter,
+		u8 port_num, u16 *dac_cable_len, u16 *port_speed)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_port_speed *req;
+	int status = 0;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = embedded_payload(wrb);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_GET_LINK_SPEED);
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_NTWK_GET_LINK_SPEED,
+			sizeof(*req));
+	req->port_num = port_num;
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_get_port_speed *resp =
+			embedded_payload(wrb);
+		*dac_cable_len = le16_to_cpu(resp->dac_cable_length);
+		*port_speed = le16_to_cpu(resp->mac_speed);
+	}
+
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_cmd_set_port_speed_v1(struct be_adapter *adapter,
 				u8 port_num, u16 mac_speed,
 				u16 dac_cable_len)
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 4a6a959..40ce808 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -190,6 +190,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
+#define OPCODE_COMMON_NTWK_GET_LINK_SPEED               134
 #define OPCODE_COMMON_WRITE_OBJECT			172
 
 #define OPCODE_ETH_RSS_CONFIG				1
@@ -1335,6 +1336,18 @@ struct be_cmd_resp_set_port_speed_v1 {
 	u32 rsvd0;
 };
 
+/************** get port speed *******************/
+struct be_cmd_req_get_port_speed {
+	struct be_cmd_req_hdr hdr;
+	u8 port_num;
+};
+
+struct be_cmd_resp_get_port_speed {
+	struct be_cmd_resp_hdr hdr;
+	u16 mac_speed;
+	u16 dac_cable_length;
+};
+
 /*************** HW Stats Get v1 **********************************/
 #define BE_TXP_SW_SZ			48
 struct be_port_rxf_stats_v1 {
@@ -1535,3 +1548,5 @@ extern int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
 extern void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
 extern int be_cmd_set_port_speed_v1(struct be_adapter *adapter, u8 port_num,
 			u16 mac_speed, u16 dac_cable_len);
+extern int be_cmd_get_port_speed(struct be_adapter *adapter, u8 port_num,
+			u16 *dac_cable_len, u16 *port_speed);
-- 
1.7.4.1

