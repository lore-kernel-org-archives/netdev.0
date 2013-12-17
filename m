From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/7] qlcnic: Refactor initialize nic code path.
Date: Tue, 17 Dec 2013 09:01:51 -0500
Message-ID: <1387288915-2981-4-git-send-email-manish.chopra@qlogic.com>
References: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:63153 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752800Ab3LQOev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 09:34:51 -0500
In-Reply-To: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Change function name from qlcnic_83xx_register_nic_idc_func to
  qlcnic_83xx_initialize_nic

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   19 +++++++------------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    4 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    8 +++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    5 ++---
 4 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 9edafa9..406ab1b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1518,8 +1518,7 @@ int  qlcnic_83xx_set_led(struct net_device *netdev,
 	return err;
 }
 
-void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
-				       int enable)
+void qlcnic_83xx_initialize_nic(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_cmd_args cmd;
 	int status;
@@ -1527,21 +1526,17 @@ void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
 	if (qlcnic_sriov_vf_check(adapter))
 		return;
 
-	if (enable) {
+	if (enable)
 		status = qlcnic_alloc_mbx_args(&cmd, adapter,
 					       QLCNIC_CMD_INIT_NIC_FUNC);
-		if (status)
-			return;
-
-		cmd.req.arg[1] = BIT_0 | BIT_31;
-	} else {
+	else
 		status = qlcnic_alloc_mbx_args(&cmd, adapter,
 					       QLCNIC_CMD_STOP_NIC_FUNC);
-		if (status)
-			return;
 
-		cmd.req.arg[1] = BIT_0 | BIT_31;
-	}
+	if (status)
+		return;
+
+	cmd.req.arg[1] = QLC_REGISTER_LB_IDC | QLC_INIT_FW_RESOURCES;
 
 	if (adapter->dcb)
 		cmd.req.arg[1] |= QLC_REGISTER_DCB_AEN;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index ddc3b0a..2a0b06c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -520,6 +520,8 @@ enum qlc_83xx_ext_regs {
 
 /* Initialize/Stop NIC command bit definitions */
 #define QLC_REGISTER_DCB_AEN		BIT_1
+#define QLC_REGISTER_LB_IDC		BIT_0
+#define QLC_INIT_FW_RESOURCES		BIT_31
 
 /* 83xx funcitons */
 int qlcnic_83xx_get_fw_version(struct qlcnic_adapter *);
@@ -545,7 +547,7 @@ int qlcnic_83xx_config_intr_coalesce(struct qlcnic_adapter *);
 void qlcnic_83xx_change_l2_filter(struct qlcnic_adapter *, u64 *, u16);
 int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *, struct qlcnic_pci_info *);
 int qlcnic_83xx_set_nic_info(struct qlcnic_adapter *, struct qlcnic_info *);
-void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *, int);
+void qlcnic_83xx_initialize_nic(struct qlcnic_adapter *, int);
 
 int qlcnic_83xx_napi_add(struct qlcnic_adapter *, struct net_device *);
 void qlcnic_83xx_napi_del(struct qlcnic_adapter *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 8eb1288..70767c1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -614,8 +614,7 @@ int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *adapter)
 	qlcnic_83xx_reinit_mbx_work(adapter->ahw->mailbox);
 	qlcnic_83xx_enable_mbx_interrupt(adapter);
 
-	/* register for NIC IDC AEN Events */
-	qlcnic_83xx_register_nic_idc_func(adapter, 1);
+	qlcnic_83xx_initialize_nic(adapter, 1);
 
 	err = qlcnic_sriov_pf_reinit(adapter);
 	if (err)
@@ -2249,8 +2248,7 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 
 	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
 
-	/* register for NIC IDC AEN Events */
-	qlcnic_83xx_register_nic_idc_func(adapter, 1);
+	qlcnic_83xx_initialize_nic(adapter, 1);
 
 	/* Configure default, SR-IOV or Virtual NIC mode of operation */
 	err = qlcnic_83xx_configure_opmode(adapter);
@@ -2293,7 +2291,7 @@ void qlcnic_83xx_aer_stop_poll_work(struct qlcnic_adapter *adapter)
 		qlcnic_83xx_disable_vnic_mode(adapter, 1);
 
 	qlcnic_83xx_idc_detach_driver(adapter);
-	qlcnic_83xx_register_nic_idc_func(adapter, 0);
+	qlcnic_83xx_initialize_nic(adapter, 0);
 
 	cancel_delayed_work_sync(&adapter->idc_aen_work);
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 484e059..45b1da1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2501,7 +2501,7 @@ static void qlcnic_remove(struct pci_dev *pdev)
 	qlcnic_sriov_cleanup(adapter);
 
 	if (qlcnic_83xx_check(adapter)) {
-		qlcnic_83xx_register_nic_idc_func(adapter, 0);
+		qlcnic_83xx_initialize_nic(adapter, 0);
 		cancel_delayed_work_sync(&adapter->idc_aen_work);
 		qlcnic_83xx_free_mbx_intr(adapter);
 		qlcnic_83xx_detach_mailbox_work(adapter);
@@ -3785,8 +3785,7 @@ int qlcnic_setup_rings(struct qlcnic_adapter *adapter, u8 rx_cnt, u8 tx_cnt)
 	}
 
 	if (qlcnic_83xx_check(adapter)) {
-		/* register for NIC IDC AEN Events */
-		qlcnic_83xx_register_nic_idc_func(adapter, 1);
+		qlcnic_83xx_initialize_nic(adapter, 1);
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
 		qlcnic_83xx_disable_mbx_poll(adapter);
 		if (err) {
-- 
1.5.6
