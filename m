From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 6/7] be2net: Fix port name in message during driver load
Date: Thu, 12 Jul 2012 19:27:35 +0530
Message-ID: <4532e799-116a-45de-a007-af13b5115f6d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9055 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161053Ab2GLOBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   38 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |   13 +++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++-
 3 files changed, 57 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 34dfc0c..8730f0e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2716,6 +2716,44 @@ err:
 	return status;
 }
 
+int be_cmd_query_port_name(struct be_adapter *adapter, u8 *port_name)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_port_name *req;
+	int status;
+
+	if (!lancer_chip(adapter)) {
+		*port_name = adapter->hba_port_num + '0';
+		return 0;
+	}
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
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_GET_PORT_NAME, sizeof(*req), wrb,
+			       NULL);
+	req->hdr.version = 1;
+
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_get_port_name *resp = embedded_payload(wrb);
+		*port_name = resp->port_name[adapter->hba_port_num];
+	} else {
+		*port_name = adapter->hba_port_num + '0';
+	}
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
 			int wrb_payload_size, u16 *cmd_status, u16 *ext_status)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index c1324e7..88f7237 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -186,6 +186,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_ENABLE_DISABLE_BEACON		69
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
+#define OPCODE_COMMON_GET_PORT_NAME			77
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
@@ -1506,6 +1507,17 @@ struct be_cmd_resp_get_hsw_config {
 	u32 rsvd;
 };
 
+/******************* get port names ***************/
+struct be_cmd_req_get_port_name {
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd0;
+};
+
+struct be_cmd_resp_get_port_name {
+	struct be_cmd_req_hdr hdr;
+	u8 port_name[4];
+};
+
 /*************** HW Stats Get v1 **********************************/
 #define BE_TXP_SW_SZ			48
 struct be_port_rxf_stats_v1 {
@@ -1772,4 +1784,5 @@ extern int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 					  struct be_fat_conf_params *cfgs);
 extern int lancer_wait_ready(struct be_adapter *adapter);
 extern int lancer_test_and_set_rdy_state(struct be_adapter *adapter);
+extern int be_cmd_query_port_name(struct be_adapter *adapter, u8 *port_name);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index cf6ad1f..7e989d0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3797,6 +3797,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	int status = 0;
 	struct be_adapter *adapter;
 	struct net_device *netdev;
+	char port_name;
 
 	status = pci_enable_device(pdev);
 	if (status)
@@ -3887,8 +3888,11 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 	schedule_delayed_work(&adapter->func_recovery_work,
 			      msecs_to_jiffies(1000));
-	dev_info(&pdev->dev, "%s: %s port %d\n", netdev->name, nic_name(pdev),
-		adapter->port_num);
+
+	be_cmd_query_port_name(adapter, &port_name);
+
+	dev_info(&pdev->dev, "%s: %s port %c\n", netdev->name, nic_name(pdev),
+		 port_name);
 
 	return 0;
 
-- 
1.6.0.2
