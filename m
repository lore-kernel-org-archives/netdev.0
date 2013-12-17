From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/7] qlcnic: Disable DCB operations from SR-IOV VFs.
Date: Tue, 17 Dec 2013 09:01:49 -0500
Message-ID: <1387288915-2981-2-git-send-email-manish.chopra@qlogic.com>
References: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40657 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753305Ab3LQOev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 09:34:51 -0500
In-Reply-To: <1387288915-2981-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o These operations will be supported only through PFs (SR-IOV and non-SR-IOV).

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    6 ------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    |    3 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h    |    6 ++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    7 ++-----
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    8 --------
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    2 --
 6 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 89208e5..8eb1288 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2198,7 +2198,6 @@ static void qlcnic_83xx_init_rings(struct qlcnic_adapter *adapter)
 int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
-	struct qlcnic_dcb *dcb;
 	int err = 0;
 
 	ahw->msix_supported = !!qlcnic_use_msi_x;
@@ -2264,11 +2263,6 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	if (err)
 		goto disable_mbx_intr;
 
-	dcb = adapter->dcb;
-
-	if (dcb && qlcnic_dcb_attach(dcb))
-		qlcnic_clear_dcb_ops(dcb);
-
 	/* Periodically monitor device status */
 	qlcnic_83xx_idc_poll_dev_state(&adapter->fw_work.work);
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index 86bca7c..c233084 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -260,6 +260,9 @@ int qlcnic_register_dcb(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_dcb *dcb;
 
+	if (qlcnic_sriov_vf_check(adapter))
+		return 0;
+
 	dcb = kzalloc(sizeof(struct qlcnic_dcb), GFP_ATOMIC);
 	if (!dcb)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
index c04ae0c..6b6144d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
@@ -121,4 +121,10 @@ static inline void qlcnic_dcb_init_dcbnl_ops(struct qlcnic_dcb *dcb)
 	if (dcb && dcb->ops->init_dcbnl_ops)
 		dcb->ops->init_dcbnl_ops(dcb);
 }
+
+static inline void qlcnic_dcb_enable(struct qlcnic_dcb *dcb)
+{
+	if (dcb && qlcnic_dcb_attach(dcb))
+		qlcnic_clear_dcb_ops(dcb);
+}
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 05c1eef..083941c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2212,7 +2212,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_hardware_context *ahw;
 	int err, pci_using_dac = -1;
 	char board_name[QLCNIC_MAX_BOARD_NAME_LEN + 19]; /* MAC + ": " + name */
-	struct qlcnic_dcb *dcb;
 
 	if (pdev->is_virtfn)
 		return -ENODEV;
@@ -2335,10 +2334,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 		adapter->flags |= QLCNIC_NEED_FLR;
 
-		dcb = adapter->dcb;
-
-		if (dcb && qlcnic_dcb_attach(dcb))
-			qlcnic_clear_dcb_ops(dcb);
 	} else if (qlcnic_83xx_check(adapter)) {
 		qlcnic_83xx_check_vf(adapter, ent);
 		adapter->portnum = adapter->ahw->pci_func;
@@ -2367,6 +2362,8 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_hw;
 	}
 
+	qlcnic_dcb_enable(adapter->dcb);
+
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 21a4b27..af5a108 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -500,7 +500,6 @@ static int qlcnic_sriov_vf_init_driver(struct qlcnic_adapter *adapter)
 static int qlcnic_sriov_setup_vf(struct qlcnic_adapter *adapter,
 				 int pci_using_dac)
 {
-	struct qlcnic_dcb *dcb;
 	int err;
 
 	INIT_LIST_HEAD(&adapter->vf_mc_list);
@@ -538,11 +537,6 @@ static int qlcnic_sriov_setup_vf(struct qlcnic_adapter *adapter,
 	if (err)
 		goto err_out_send_channel_term;
 
-	dcb = adapter->dcb;
-
-	if (dcb && qlcnic_dcb_attach(dcb))
-		qlcnic_clear_dcb_ops(dcb);
-
 	err = qlcnic_setup_netdev(adapter, adapter->netdev, pci_using_dac);
 	if (err)
 		goto err_out_send_channel_term;
@@ -1584,8 +1578,6 @@ static int qlcnic_sriov_vf_reinit_driver(struct qlcnic_adapter *adapter)
 	if (err)
 		goto err_out_term_channel;
 
-	qlcnic_dcb_get_info(adapter->dcb);
-
 	return 0;
 
 err_out_term_channel:
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 686f460..b679309 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1299,8 +1299,6 @@ static const int qlcnic_pf_passthru_supp_cmds[] = {
 	QLCNIC_CMD_GET_STATISTICS,
 	QLCNIC_CMD_GET_PORT_CONFIG,
 	QLCNIC_CMD_GET_LINK_STATUS,
-	QLCNIC_CMD_DCB_QUERY_CAP,
-	QLCNIC_CMD_DCB_QUERY_PARAM,
 	QLCNIC_CMD_INIT_NIC_FUNC,
 	QLCNIC_CMD_STOP_NIC_FUNC,
 };
-- 
1.5.6
