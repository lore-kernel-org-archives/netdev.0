From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 1/3] qlcnic: Register device in FAILED state.
Date: Thu, 26 Apr 2012 13:31:29 -0700
Message-ID: <1335472292-24335-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:53474
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757178Ab2DZUrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 16:47:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Without failing probe, register netdevice when device is in FAILED state.
o Device will come up with minimum functionality.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    3 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   50 ++++++++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   51 ++++++++++++++++++--
 4 files changed, 93 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 385a4d5..f419965 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1352,6 +1352,8 @@ enum op_codes {
 #define QLCNIC_ENABLE_FW_DUMP		0xaddfeed
 #define QLCNIC_DISABLE_FW_DUMP		0xbadfeed
 #define QLCNIC_FORCE_FW_RESET		0xdeaddead
+#define QLCNIC_SET_QUIESCENT		0xadd00010
+#define QLCNIC_RESET_QUIESCENT		0xadd00020
 
 struct qlcnic_dump_operations {
 	enum op_codes opcode;
@@ -1559,6 +1561,7 @@ static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 }
 
 extern const struct ethtool_ops qlcnic_ethtool_ops;
+extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
 
 struct qlcnic_nic_template {
 	int (*config_bridged_mode) (struct qlcnic_adapter *, u32);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 89ddf7f..f19e11e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1132,6 +1132,11 @@ qlcnic_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
 
+	if (!fw_dump->tmpl_hdr) {
+		netdev_err(adapter->netdev, "FW Dump not supported\n");
+		return -ENOTSUPP;
+	}
+
 	if (fw_dump->clr)
 		dump->len = fw_dump->tmpl_hdr->size + fw_dump->size;
 	else
@@ -1150,6 +1155,11 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
 
+	if (!fw_dump->tmpl_hdr) {
+		netdev_err(netdev, "FW Dump not supported\n");
+		return -ENOTSUPP;
+	}
+
 	if (!fw_dump->clr) {
 		netdev_info(netdev, "Dump not available\n");
 		return -EINVAL;
@@ -1180,9 +1190,14 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 	int ret = 0;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	u32 state;
 
 	switch (val->flag) {
 	case QLCNIC_FORCE_FW_DUMP_KEY:
+		if (!fw_dump->tmpl_hdr) {
+			netdev_err(netdev, "FW dump not supported\n");
+			return -ENOTSUPP;
+		}
 		if (!fw_dump->enable) {
 			netdev_info(netdev, "FW dump not enabled\n");
 			return ret;
@@ -1196,35 +1211,47 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		qlcnic_dev_request_reset(adapter);
 		break;
 	case QLCNIC_DISABLE_FW_DUMP:
-		if (fw_dump->enable) {
+		if (fw_dump->enable && fw_dump->tmpl_hdr) {
 			netdev_info(netdev, "Disabling FW dump\n");
 			fw_dump->enable = 0;
 		}
-		break;
+		return ret;
 	case QLCNIC_ENABLE_FW_DUMP:
-		if (!fw_dump->enable && fw_dump->tmpl_hdr) {
+		if (!fw_dump->tmpl_hdr) {
+			netdev_err(netdev, "FW dump not supported\n");
+			return -ENOTSUPP;
+		}
+		if (!fw_dump->enable) {
 			netdev_info(netdev, "Enabling FW dump\n");
 			fw_dump->enable = 1;
 		}
-		break;
+		return ret;
 	case QLCNIC_FORCE_FW_RESET:
 		netdev_info(netdev, "Forcing a FW reset\n");
 		qlcnic_dev_request_reset(adapter);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
-		break;
+		return ret;
+	case QLCNIC_SET_QUIESCENT:
+	case QLCNIC_RESET_QUIESCENT:
+		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+		if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
+			netdev_info(netdev, "Device in FAILED state\n");
+		return ret;
 	default:
+		if (!fw_dump->tmpl_hdr) {
+			netdev_err(netdev, "FW dump not supported\n");
+			return -ENOTSUPP;
+		}
 		if (val->flag > QLCNIC_DUMP_MASK_MAX ||
 			val->flag < QLCNIC_DUMP_MASK_MIN) {
 				netdev_info(netdev,
 				"Invalid dump level: 0x%x\n", val->flag);
-				ret = -EINVAL;
-				goto out;
+				return -EINVAL;
 		}
 		fw_dump->tmpl_hdr->drv_cap_mask = val->flag & 0xff;
 		netdev_info(netdev, "Driver mask changed to: 0x%x\n",
 			fw_dump->tmpl_hdr->drv_cap_mask);
 	}
-out:
 	return ret;
 }
 
@@ -1258,3 +1285,10 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_dump_data = qlcnic_get_dump_data,
 	.set_dump = qlcnic_set_dump,
 };
+
+const struct ethtool_ops qlcnic_ethtool_failed_ops = {
+	.get_settings = qlcnic_get_settings,
+	.get_drvinfo = qlcnic_get_drvinfo,
+	.set_msglevel = qlcnic_set_msglevel,
+	.get_msglevel = qlcnic_get_msglevel,
+};
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index a528193..e6a77fe 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -704,6 +704,8 @@ enum {
 #define QLCNIC_DEV_FAILED		0x6
 #define QLCNIC_DEV_QUISCENT		0x7
 
+#define QLCNIC_DEV_BADBAD		0xbad0bad0
+
 #define QLCNIC_DEV_NPAR_NON_OPER	0 /* NON Operational */
 #define QLCNIC_DEV_NPAR_OPER		1 /* NPAR Operational */
 #define QLCNIC_DEV_NPAR_OPER_TIMEO	30 /* Operational time out */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 75c32e8..5c47135 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -338,6 +338,10 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 #endif
 };
 
+static const struct net_device_ops qlcnic_netdev_failed_ops = {
+	.ndo_open	   = qlcnic_open,
+};
+
 static struct qlcnic_nic_template qlcnic_ops = {
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
@@ -1623,8 +1627,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = adapter->nic_ops->start_firmware(adapter);
 	if (err) {
-		dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n");
-		goto err_out_decr_ref;
+		dev_err(&pdev->dev, "Loading fw failed. Please Reboot\n"
+			"\t\tIf reboot doesn't help, try flashing the card\n");
+		goto err_out_maintenance_mode;
 	}
 
 	if (qlcnic_read_mac_addr(adapter))
@@ -1695,6 +1700,18 @@ err_out_disable_pdev:
 	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 	return err;
+
+err_out_maintenance_mode:
+	netdev->netdev_ops = &qlcnic_netdev_failed_ops;
+	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_failed_ops);
+	err = register_netdev(netdev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to register net device\n");
+		goto err_out_decr_ref;
+	}
+	pci_set_drvdata(pdev, adapter);
+	qlcnic_create_diag_entries(adapter);
+	return 0;
 }
 
 static void __devexit qlcnic_remove(struct pci_dev *pdev)
@@ -1831,8 +1848,14 @@ done:
 static int qlcnic_open(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 	int err;
 
+	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
+		netdev_err(netdev, "Device in FAILED state\n");
+		return -EIO;
+	}
+
 	netif_carrier_off(netdev);
 
 	err = qlcnic_attach(adapter);
@@ -3018,6 +3041,12 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 		return;
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
+	if (state  == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD)) {
+		netdev_err(adapter->netdev,
+				"Device is in FAILED state, Please Reboot\n");
+		qlcnic_api_unlock(adapter);
+		return;
+	}
 
 	if (state == QLCNIC_DEV_READY) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
@@ -3061,6 +3090,9 @@ qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter)
 	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
 		msleep(10);
 
+	if (!adapter->fw_work.work.func)
+		return;
+
 	cancel_delayed_work_sync(&adapter->fw_work);
 }
 
@@ -4280,6 +4312,7 @@ static void
 qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
+	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
@@ -4288,14 +4321,19 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
 		dev_info(dev, "failed to create diag_mode sysfs entry\n");
-	if (device_create_file(dev, &dev_attr_beacon))
-		dev_info(dev, "failed to create beacon sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_crb))
 		dev_info(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
 		dev_info(dev, "failed to create mem sysfs entry\n");
+
+	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
+		return;
+
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
 		dev_info(dev, "failed to create pci config sysfs entry");
+	if (device_create_file(dev, &dev_attr_beacon))
+		dev_info(dev, "failed to create beacon sysfs entry");
+
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return;
 	if (device_create_bin_file(dev, &bin_attr_esw_config))
@@ -4314,16 +4352,19 @@ static void
 qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
+	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
 	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	device_remove_file(dev, &dev_attr_diag_mode);
-	device_remove_file(dev, &dev_attr_beacon);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
+	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
+		return;
 	device_remove_bin_file(dev, &bin_attr_pci_config);
+	device_remove_file(dev, &dev_attr_beacon);
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return;
 	device_remove_bin_file(dev, &bin_attr_esw_config);
-- 
1.7.4.1
