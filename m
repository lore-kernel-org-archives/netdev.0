From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Fix register device in FAILED state for 82xx.
Date: Fri, 27 Sep 2013 02:12:36 -0400
Message-ID: <1380262356-26221-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:48916 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751113Ab3I0Gm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 02:42:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Commit 7e2cf4feba058476324dc545e3d1b316998c91e6
  ("qlcnic: change driver hardware interface mechanism")
  has overwritten
  commit b43e5ee76a4320c070cf0fe65cf4927198fbb4d1
  ("qlcnic: Register device in FAILED state")

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  8 +++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 39 ++++++++++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 12 +++++++
 3 files changed, 57 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 4d7ad00..ebe4c86 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1794,3 +1794,11 @@ const struct ethtool_ops qlcnic_sriov_vf_ethtool_ops = {
 	.set_msglevel		= qlcnic_set_msglevel,
 	.get_msglevel		= qlcnic_get_msglevel,
 };
+
+const struct ethtool_ops qlcnic_ethtool_failed_ops = {
+	.get_settings		= qlcnic_get_settings,
+	.get_drvinfo		= qlcnic_get_drvinfo,
+	.set_msglevel		= qlcnic_set_msglevel,
+	.get_msglevel		= qlcnic_get_msglevel,
+	.set_dump		= qlcnic_set_dump,
+};
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index c4c5023..21d00a0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -431,6 +431,9 @@ static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
 	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 		usleep_range(10000, 11000);
 
+	if (!adapter->fw_work.work.func)
+		return;
+
 	cancel_delayed_work_sync(&adapter->fw_work);
 }
 
@@ -2275,8 +2278,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->portnum = adapter->ahw->pci_func;
 		err = qlcnic_start_firmware(adapter);
 		if (err) {
-			dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n");
-			goto err_out_free_hw;
+			dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n"
+				"\t\tIf reboot doesn't help, try flashing the card\n");
+			goto err_out_maintenance_mode;
 		}
 
 		qlcnic_get_multiq_capability(adapter);
@@ -2408,6 +2412,22 @@ err_out_disable_pdev:
 	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 	return err;
+
+err_out_maintenance_mode:
+	netdev->netdev_ops = &qlcnic_netdev_failed_ops;
+	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_failed_ops);
+	err = register_netdev(netdev);
+
+	if (err) {
+		dev_err(&pdev->dev, "Failed to register net device\n");
+		qlcnic_clr_all_drv_state(adapter, 0);
+		goto err_out_free_hw;
+	}
+
+	pci_set_drvdata(pdev, adapter);
+	qlcnic_add_sysfs(adapter);
+
+	return 0;
 }
 
 static void qlcnic_remove(struct pci_dev *pdev)
@@ -2518,8 +2538,16 @@ static int qlcnic_resume(struct pci_dev *pdev)
 static int qlcnic_open(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	u32 state;
 	int err;
 
+	state = QLC_SHARED_REG_RD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state == QLCNIC_DEV_FAILED || state == QLCNIC_DEV_BADBAD) {
+		netdev_err(netdev, "%s: Device is in FAILED state\n", __func__);
+
+		return -EIO;
+	}
+
 	netif_carrier_off(netdev);
 
 	err = qlcnic_attach(adapter);
@@ -3228,6 +3256,13 @@ void qlcnic_82xx_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
 		return;
 
 	state = QLC_SHARED_REG_RD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state == QLCNIC_DEV_FAILED || state == QLCNIC_DEV_BADBAD) {
+		netdev_err(adapter->netdev, "%s: Device is in FAILED state\n",
+			   __func__);
+		qlcnic_api_unlock(adapter);
+
+		return;
+	}
 
 	if (state == QLCNIC_DEV_READY) {
 		QLC_SHARED_REG_WR32(adapter, QLCNIC_CRB_DEV_STATE,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index c6165d0..019f437 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -1272,6 +1272,7 @@ void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
+	u32 state;
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
@@ -1285,8 +1286,13 @@ void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 	if (device_create_bin_file(dev, &bin_attr_mem))
 		dev_info(dev, "failed to create mem sysfs entry\n");
 
+	state = QLC_SHARED_REG_RD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state == QLCNIC_DEV_FAILED || state == QLCNIC_DEV_BADBAD)
+		return;
+
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
 		dev_info(dev, "failed to create pci config sysfs entry");
+
 	if (device_create_file(dev, &dev_attr_beacon))
 		dev_info(dev, "failed to create beacon sysfs entry");
 
@@ -1307,6 +1313,7 @@ void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
+	u32 state;
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
@@ -1315,6 +1322,11 @@ void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
+
+	state = QLC_SHARED_REG_RD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state == QLCNIC_DEV_FAILED || state == QLCNIC_DEV_BADBAD)
+		return;
+
 	device_remove_bin_file(dev, &bin_attr_pci_config);
 	device_remove_file(dev, &dev_attr_beacon);
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
-- 
1.8.1.4
