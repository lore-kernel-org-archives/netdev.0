From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 07/12] qlcnic: fix npar state
Date: Thu, 19 Aug 2010 08:08:28 -0700
Message-ID: <1282230513-25286-8-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60260 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753917Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Privilege functions should wait for npar state to be operational.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   43 +++++++++++++++++++++++++------------
 1 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index de4be00..6a8e970 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -916,6 +916,27 @@ qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
+{
+	u8 npar_opt_timeo = QLCNIC_DEV_NPAR_OPER_TIMEO;
+	u32 npar_state;
+
+	if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+		return 0;
+
+	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	while (npar_state != QLCNIC_DEV_NPAR_OPER && --npar_opt_timeo) {
+		msleep(1000);
+		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
+	}
+	if (!npar_opt_timeo) {
+		dev_err(&adapter->pdev->dev,
+			"Waiting for NPAR state to opertional timeout\n");
+		return -EIO;
+	}
+	return 0;
+}
+
 static int
 qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
@@ -978,6 +999,11 @@ wait_init:
 
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
+	err = qlcnic_check_npar_opertional(adapter);
+	if (err) {
+		qlcnic_release_firmware(adapter);
+		return err;
+	}
 	if (qlcnic_set_default_offload_settings(adapter))
 		goto err_out;
 	if (qlcnic_reset_npar_config(adapter))
@@ -2919,29 +2945,18 @@ static void qlcnic_io_resume(struct pci_dev *pdev)
 						FW_POLL_DELAY);
 }
 
-
 static int
 qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
-	u8 npar_opt_timeo = QLCNIC_DEV_NPAR_OPER_TIMEO;
-	u32 npar_state;
 
 	err = qlcnic_can_start_firmware(adapter);
 	if (err)
 		return err;
 
-	npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
-	while (npar_state != QLCNIC_DEV_NPAR_OPER && --npar_opt_timeo) {
-		msleep(1000);
-		npar_state = QLCRD32(adapter, QLCNIC_CRB_DEV_NPAR_STATE);
-	}
-
-	if (!npar_opt_timeo) {
-		dev_err(&adapter->pdev->dev,
-			"Waiting for NPAR state to opertional timeout\n");
-		return -EIO;
-	}
+	err = qlcnic_check_npar_opertional(adapter);
+	if (err)
+		return err;
 
 	qlcnic_check_options(adapter);
 
-- 
1.6.0.2

