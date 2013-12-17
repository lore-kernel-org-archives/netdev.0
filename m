From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/7] qlcnic: Issue INIT_NIC command only once.
Date: Tue, 17 Dec 2013 09:01:50 -0500
Message-ID: <1387288915-2981-3-git-send-email-manish.chopra@qlogic.com>
References: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:6035 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753327Ab3LQOew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 09:34:52 -0500
In-Reply-To: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o DCB AEN registration was reissuing INIT_NIC command. Instead, club
  all options of INIT NIC command and issue this command only once.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    6 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    3 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    |   28 --------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h    |    8 -----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 +-
 5 files changed, 10 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index b1cb0ff..9edafa9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -68,7 +68,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{QLCNIC_CMD_CONFIG_VPORT, 4, 4},
 	{QLCNIC_CMD_BC_EVENT_SETUP, 2, 1},
 	{QLCNIC_CMD_DCB_QUERY_CAP, 1, 2},
-	{QLCNIC_CMD_DCB_QUERY_PARAM, 2, 50},
+	{QLCNIC_CMD_DCB_QUERY_PARAM, 1, 50},
 };
 
 const u32 qlcnic_83xx_ext_reg_tbl[] = {
@@ -1542,6 +1542,10 @@ void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
 
 		cmd.req.arg[1] = BIT_0 | BIT_31;
 	}
+
+	if (adapter->dcb)
+		cmd.req.arg[1] |= QLC_REGISTER_DCB_AEN;
+
 	status = qlcnic_issue_cmd(adapter, &cmd);
 	if (status)
 		dev_err(&adapter->pdev->dev,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 4cae6ca..ddc3b0a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -518,6 +518,9 @@ enum qlc_83xx_ext_regs {
 	QLC_83XX_ASIC_TEMP,
 };
 
+/* Initialize/Stop NIC command bit definitions */
+#define QLC_REGISTER_DCB_AEN		BIT_1
+
 /* 83xx funcitons */
 int qlcnic_83xx_get_fw_version(struct qlcnic_adapter *);
 int qlcnic_83xx_issue_cmd(struct qlcnic_adapter *, struct qlcnic_cmd_args *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index c233084..77f1bce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -15,7 +15,6 @@
 
 #define QLC_DCB_GET_MAP(V)		(1 << V)
 
-#define QLC_DCB_AEN_BIT			0x2
 #define QLC_DCB_FW_VER			0x2
 #define QLC_DCB_MAX_TC			0x8
 #define QLC_DCB_MAX_APP			0x8
@@ -71,7 +70,6 @@ static void qlcnic_82xx_dcb_aen_handler(struct qlcnic_dcb *, void *);
 static int qlcnic_83xx_dcb_get_hw_capability(struct qlcnic_dcb *);
 static int qlcnic_83xx_dcb_query_cee_param(struct qlcnic_dcb *, char *, u8);
 static int qlcnic_83xx_dcb_get_cee_cfg(struct qlcnic_dcb *);
-static int qlcnic_83xx_dcb_register_aen(struct qlcnic_dcb *, bool);
 static void qlcnic_83xx_dcb_aen_handler(struct qlcnic_dcb *, void *);
 
 struct qlcnic_dcb_capability {
@@ -179,7 +177,6 @@ static struct qlcnic_dcb_ops qlcnic_83xx_dcb_ops = {
 	.get_hw_capability	= qlcnic_83xx_dcb_get_hw_capability,
 	.query_cee_param	= qlcnic_83xx_dcb_query_cee_param,
 	.get_cee_cfg		= qlcnic_83xx_dcb_get_cee_cfg,
-	.register_aen		= qlcnic_83xx_dcb_register_aen,
 	.aen_handler		= qlcnic_83xx_dcb_aen_handler,
 };
 
@@ -283,7 +280,6 @@ static void __qlcnic_dcb_free(struct qlcnic_dcb *dcb)
 		return;
 
 	adapter = dcb->adapter;
-	qlcnic_dcb_register_aen(dcb, 0);
 
 	while (test_bit(QLCNIC_DCB_AEN_MODE, &dcb->state))
 		usleep_range(10000, 11000);
@@ -307,7 +303,6 @@ static void __qlcnic_dcb_get_info(struct qlcnic_dcb *dcb)
 {
 	qlcnic_dcb_get_hw_capability(dcb);
 	qlcnic_dcb_get_cee_cfg(dcb);
-	qlcnic_dcb_register_aen(dcb, 1);
 }
 
 static int __qlcnic_dcb_attach(struct qlcnic_dcb *dcb)
@@ -645,29 +640,6 @@ static int qlcnic_83xx_dcb_get_cee_cfg(struct qlcnic_dcb *dcb)
 	return err;
 }
 
-static int qlcnic_83xx_dcb_register_aen(struct qlcnic_dcb *dcb, bool flag)
-{
-	u8 val = (flag ? QLCNIC_CMD_INIT_NIC_FUNC : QLCNIC_CMD_STOP_NIC_FUNC);
-	struct qlcnic_adapter *adapter = dcb->adapter;
-	struct qlcnic_cmd_args cmd;
-	int err;
-
-	err = qlcnic_alloc_mbx_args(&cmd, adapter, val);
-	if (err)
-		return err;
-
-	cmd.req.arg[1] = QLC_DCB_AEN_BIT;
-
-	err = qlcnic_issue_cmd(adapter, &cmd);
-	if (err)
-		dev_err(&adapter->pdev->dev, "Failed to %s DCBX AEN, err %d\n",
-			(flag ? "register" : "unregister"), err);
-
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
 static void qlcnic_83xx_dcb_aen_handler(struct qlcnic_dcb *dcb, void *data)
 {
 	u32 *val = data;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
index 6b6144d..3cf4a10 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
@@ -25,7 +25,6 @@ struct qlcnic_dcb_ops {
 	int (*get_hw_capability) (struct qlcnic_dcb *);
 	int (*query_cee_param) (struct qlcnic_dcb *, char *, u8);
 	void (*init_dcbnl_ops) (struct qlcnic_dcb *);
-	int (*register_aen) (struct qlcnic_dcb *, bool);
 	void (*aen_handler) (struct qlcnic_dcb *, void *);
 	int (*get_cee_cfg) (struct qlcnic_dcb *);
 	void (*get_info) (struct qlcnic_dcb *);
@@ -103,13 +102,6 @@ static inline int qlcnic_dcb_get_cee_cfg(struct qlcnic_dcb *dcb)
 	return 0;
 }
 
-static inline void
-qlcnic_dcb_register_aen(struct qlcnic_dcb *dcb, u8 flag)
-{
-	if (dcb && dcb->ops->register_aen)
-		dcb->ops->register_aen(dcb, flag);
-}
-
 static inline void qlcnic_dcb_aen_handler(struct qlcnic_dcb *dcb, void *msg)
 {
 	if (dcb && dcb->ops->aen_handler)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 083941c..484e059 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2497,8 +2497,6 @@ static void qlcnic_remove(struct pci_dev *pdev)
 	qlcnic_cancel_idc_work(adapter);
 	ahw = adapter->ahw;
 
-	qlcnic_dcb_free(adapter->dcb);
-
 	unregister_netdev(netdev);
 	qlcnic_sriov_cleanup(adapter);
 
@@ -2511,6 +2509,8 @@ static void qlcnic_remove(struct pci_dev *pdev)
 		kfree(ahw->fw_info);
 	}
 
+	qlcnic_dcb_free(adapter->dcb);
+
 	qlcnic_detach(adapter);
 
 	if (adapter->npars != NULL)
-- 
1.5.6
