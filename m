From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 1/8] qlcnic: set driver version in firmware
Date: Fri, 25 Jan 2013 15:20:34 -0500
Message-ID: <1359145241-5175-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16663 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751372Ab3AYUlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:22 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |   31 ++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    9 ++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 893cbe8..c1ab34e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -798,6 +798,7 @@ struct qlcnic_mac_list_s {
 #define QLCNIC_FW_CAPABILITY_MORE_CAPS		BIT_31
 
 #define QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG	BIT_2
+#define QLCNIC_FW_CAPABILITY_2_OCBB		BIT_5
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -1421,6 +1422,7 @@ void qlcnic_set_multi(struct net_device *netdev);
 void qlcnic_free_mac_list(struct qlcnic_adapter *adapter);
 
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
+int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 	netdev_features_t features);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index ee68fe3..7372964 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -160,6 +160,37 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 	return cmd->rsp.arg[0];
 }
 
+int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_args cmd;
+	u32 arg1, arg2, arg3;
+	char drv_string[12];
+	int err = 0;
+
+	memset(drv_string, 0, sizeof(drv_string));
+	snprintf(drv_string, sizeof(drv_string), "%d"".""%d"".""%d",
+		 _QLCNIC_LINUX_MAJOR, _QLCNIC_LINUX_MINOR,
+		 _QLCNIC_LINUX_SUBVERSION);
+
+	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_SET_DRV_VER);
+	memcpy(&arg1, drv_string, sizeof(u32));
+	memcpy(&arg2, drv_string + 4, sizeof(u32));
+	memcpy(&arg3, drv_string + 8, sizeof(u32));
+
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = arg2;
+	cmd.req.arg[3] = arg3;
+
+	err = qlcnic_issue_cmd(adapter, &cmd);
+	if (err) {
+		dev_info(&adapter->pdev->dev,
+			 "Failed to set driver version in firmware\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
 int
 qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index fb7ac8e..5f3308a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1724,6 +1724,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_adapter *adapter = NULL;
 	struct qlcnic_hardware_context *ahw;
 	int err, pci_using_dac = -1;
+	u32 capab2;
 	char board_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
@@ -1849,6 +1850,14 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_disable_mbx_intr;
 
+	if (qlcnic_82xx_check(adapter)) {
+		if (ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
+			capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
+			if (capab2 & QLCNIC_FW_CAPABILITY_2_OCBB)
+				qlcnic_fw_cmd_set_drv_version(adapter);
+		}
+	}
+
 	pci_set_drvdata(pdev, adapter);
 
 	if (qlcnic_82xx_check(adapter))
-- 
1.7.1
