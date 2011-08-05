From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/6] be2net: add be_cmd_set_port_speed_v1 to set
 port speed
Date: Fri, 5 Aug 2011 14:59:58 -0500
Message-ID: <20110805195958.GA13539@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2936 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753173Ab1HEUAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:00:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |   35 +++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h |   37 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 71 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 8d178d2..863ae67 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -2367,3 +2367,38 @@ err:
 	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
+
+int be_cmd_set_port_speed_v1(struct be_adapter *adapter,
+				u8 port_num, u16 mac_speed,
+				u16 dac_cable_len)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_port_speed_v1 *req;
+	int status = 0;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = embedded_payload(wrb);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_NTWK_SET_LINK_SPEED);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_NTWK_SET_LINK_SPEED,
+			sizeof(*req));
+	req->hdr.version = 1;
+
+	req->port_num = port_num;
+	req->virt_port = port_num;
+	req->mac_speed = cpu_to_le16(mac_speed);
+	req->dac_cable_length = cpu_to_le16(dac_cable_len);
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index b61eac7..4a6a959 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -178,6 +178,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_MCC_DESTROY        		53
 #define OPCODE_COMMON_CQ_DESTROY        		54
 #define OPCODE_COMMON_EQ_DESTROY        		55
+#define OPCODE_COMMON_NTWK_SET_LINK_SPEED		57
 #define OPCODE_COMMON_QUERY_FIRMWARE_CONFIG		58
 #define OPCODE_COMMON_NTWK_PMAC_ADD			59
 #define OPCODE_COMMON_NTWK_PMAC_DEL			60
@@ -1237,6 +1238,8 @@ enum {
 	PHY_TYPE_KX4_10GB,
 	PHY_TYPE_BASET_10GB,
 	PHY_TYPE_BASET_1GB,
+	PHY_TYPE_BASEX_1GB,
+	PHY_TYPE_SGMII,
 	PHY_TYPE_DISABLED = 255
 };
 
@@ -1301,6 +1304,37 @@ struct be_cmd_resp_set_func_cap {
 	u8 rsvd[212];
 };
 
+/* MAC speed valid values */
+#define SPEED_DEFAULT  0x0
+#define SPEED_FORCED_10GB  0x1
+#define SPEED_FORCED_1GB  0x2
+#define SPEED_AUTONEG_10GB  0x3
+#define SPEED_AUTONEG_1GB  0x4
+#define SPEED_AUTONEG_100MB  0x5
+#define SPEED_AUTONEG_10GB_1GB 0x6
+#define SPEED_AUTONEG_10GB_1GB_100MB 0x7
+#define SPEED_AUTONEG_1GB_100MB  0x8
+#define SPEED_AUTONEG_10MB  0x9
+#define SPEED_AUTONEG_1GB_100MB_10MB 0xa
+#define SPEED_AUTONEG_100MB_10MB 0xb
+#define SPEED_FORCED_100MB  0xc
+#define SPEED_FORCED_10MB  0xd
+
+/*************** Set speed ********************/
+struct be_cmd_req_set_port_speed_v1 {
+	struct be_cmd_req_hdr hdr;
+	u8 port_num;
+	u8 virt_port;
+	u16 mac_speed;
+	u16 dac_cable_length;
+	u16 rsvd0;
+};
+
+struct be_cmd_resp_set_port_speed_v1 {
+	struct be_cmd_resp_hdr hdr;
+	u32 rsvd0;
+};
+
 /*************** HW Stats Get v1 **********************************/
 #define BE_TXP_SW_SZ			48
 struct be_port_rxf_stats_v1 {
@@ -1499,4 +1533,5 @@ extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
 extern int be_cmd_req_native_mode(struct be_adapter *adapter);
 extern int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
 extern void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
-
+extern int be_cmd_set_port_speed_v1(struct be_adapter *adapter, u8 port_num,
+			u16 mac_speed, u16 dac_cable_len);
-- 
1.7.4.1

