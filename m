From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 1/8] qlcnic: fix initialize NIC mailbox command
Date: Sat,  9 Feb 2013 14:29:48 -0500
Message-ID: <1360438195-12667-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21156 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932485Ab3BITvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2013 14:51:16 -0500
In-Reply-To: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Register for firmware based Inter Driver Communication (IDC) using initialize
NIC as the first mailbox command

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    4 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    9 ++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    6 ++++--
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index cdcbbb0..d23372e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1239,10 +1239,10 @@ void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
 
 	if (enable) {
 		qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_INIT_NIC_FUNC);
-		cmd.req.arg[1] = 1 | BIT_0;
+		cmd.req.arg[1] = BIT_0 | BIT_31;
 	} else {
 		qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_STOP_NIC_FUNC);
-		cmd.req.arg[1] = 0 | BIT_0;
+		cmd.req.arg[1] = BIT_0 | BIT_31;
 	}
 	status = qlcnic_issue_cmd(adapter, &cmd);
 	if (status)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index f647002..c53832b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -585,6 +585,9 @@ static int qlcnic_83xx_idc_check_fan_failure(struct qlcnic_adapter *adapter)
 
 static int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *adapter)
 {
+	/* register for NIC IDC AEN Events */
+	qlcnic_83xx_register_nic_idc_func(adapter, 1);
+
 	qlcnic_83xx_enable_mbx_intrpt(adapter);
 	if ((adapter->flags & QLCNIC_MSIX_ENABLED)) {
 		if (qlcnic_83xx_config_intrpt(adapter, 1)) {
@@ -2025,6 +2028,9 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter)
 	set_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status);
 	qlcnic_83xx_clear_function_resources(adapter);
 
+	/* register for NIC IDC AEN Events */
+	qlcnic_83xx_register_nic_idc_func(adapter, 1);
+
 	if (!qlcnic_83xx_read_flash_descriptor_table(adapter))
 		qlcnic_83xx_read_flash_mfg_id(adapter);
 
@@ -2041,9 +2047,6 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter)
 
 	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
 
-	/* register for NIC IDC AEN Events */
-	qlcnic_83xx_register_nic_idc_func(adapter, 1);
-
 	/* Periodically monitor device status */
 	qlcnic_83xx_idc_poll_dev_state(&adapter->fw_work.work);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d0aef32..714124a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1174,8 +1174,6 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 
 	qlcnic_dev_set_npar_ready(adapter);
 
-	if (qlcnic_83xx_check(adapter))
-		qlcnic_83xx_register_nic_idc_func(adapter, 1);
 	return err;
 }
 
@@ -3063,6 +3061,8 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	}
 
 	if (qlcnic_83xx_check(adapter)) {
+		/* register for NIC IDC AEN Events */
+		qlcnic_83xx_register_nic_idc_func(adapter, 1);
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
 		if (err) {
 			dev_err(&adapter->pdev->dev,
@@ -3224,6 +3224,8 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 	}
 
 	if (qlcnic_83xx_check(adapter)) {
+		/* register for NIC IDC AEN Events */
+		qlcnic_83xx_register_nic_idc_func(adapter, 1);
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
 		if (err) {
 			dev_err(&adapter->pdev->dev,
-- 
1.7.1
