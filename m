From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 2/2] be2net: Use new F/W mailbox cmd to manipulate interrupts.
Date: Mon, 18 Mar 2013 12:34:27 +0530
Message-ID: <3c0b4f25-0d7c-4a98-898e-d0befb8afdb1@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:54111 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3CRHFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 03:05:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed as the earlier method of manipulating this register via PCI
Config space is disallowed by certain Hypervisors.


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   25 +++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    8 ++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   25 +++++++++++++++++--------
 3 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 6ed4639..9916364 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3202,6 +3202,31 @@ err:
 	return status;
 }
 
+int be_cmd_intr_set(struct be_adapter *adapter, bool intr_enable)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_intr_set *req;
+	int status;
+
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
+	wrb = wrb_from_mbox(adapter);
+
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_SET_INTERRUPT_ENABLE, sizeof(*req),
+			       wrb, NULL);
+
+	req->intr_enabled = intr_enable;
+
+	status = be_mbox_notify_wait(adapter);
+
+	mutex_unlock(&adapter->mbox_lock);
+	return status;
+}
+
 int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 			int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 6ef4575..f2af855 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -188,6 +188,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
 #define OPCODE_COMMON_GET_PORT_NAME			77
+#define OPCODE_COMMON_SET_INTERRUPT_ENABLE		89
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
@@ -1791,6 +1792,12 @@ struct be_cmd_enable_disable_vf {
 	u8 rsvd[3];
 };
 
+struct be_cmd_req_intr_set {
+	struct be_cmd_req_hdr hdr;
+	u8 intr_enabled;
+	u8 rsvd[3];
+};
+
 static inline bool check_privilege(struct be_adapter *adapter, u32 flags)
 {
 	return flags & adapter->cmd_privileges ? true : false;
@@ -1938,3 +1945,4 @@ extern int be_cmd_set_profile_config(struct be_adapter *adapter, u32 bps,
 extern int be_cmd_get_if_id(struct be_adapter *adapter,
 			    struct be_vf_cfg *vf_cfg, int vf_num);
 extern int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain);
+extern int be_cmd_intr_set(struct be_adapter *adapter, bool intr_enable);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index dae7172..c71b180 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -153,17 +153,10 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	return 0;
 }
 
-static void be_intr_set(struct be_adapter *adapter, bool enable)
+static void be_reg_intr_set(struct be_adapter *adapter, bool enable)
 {
 	u32 reg, enabled;
 
-	/* On lancer interrupts can't be controlled via this register */
-	if (lancer_chip(adapter))
-		return;
-
-	if (adapter->eeh_error)
-		return;
-
 	pci_read_config_dword(adapter->pdev, PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET,
 				&reg);
 	enabled = reg & MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
@@ -179,6 +172,22 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 			PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET, reg);
 }
 
+static void be_intr_set(struct be_adapter *adapter, bool enable)
+{
+	int status = 0;
+
+	/* On lancer interrupts can't be controlled via this register */
+	if (lancer_chip(adapter))
+		return;
+
+	if (adapter->eeh_error)
+		return;
+
+	status = be_cmd_intr_set(adapter, enable);
+	if (status)
+		be_reg_intr_set(adapter, enable);
+}
+
 static void be_rxq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
 {
 	u32 val = 0;
-- 
1.5.6.1
