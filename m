From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 05/12] qlcnic: configure offload setting on eswitch
Date: Thu, 19 Aug 2010 08:08:26 -0700
Message-ID: <1282230513-25286-6-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58193 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753833Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Device is not capable of enabling/disabling offload setting per
port in case of Nic Partition.So offload settings needs to be
enabled/disabled per eswitch and it will affect all the function
on that eswitch.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   18 +++++-
 drivers/net/qlcnic/qlcnic_main.c    |  121 +++++++++++++++++++++++++++++++++--
 2 files changed, 133 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index e38fc3d..2805f88 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -804,6 +804,20 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 	}
 }
 
+static int qlcnic_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return -EOPNOTSUPP;
+	if (data)
+		dev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+	else
+		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+
+	return 0;
+
+}
 static u32 qlcnic_get_tx_csum(struct net_device *dev)
 {
 	return dev->features & NETIF_F_IP_CSUM;
@@ -819,6 +833,8 @@ static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return -EOPNOTSUPP;
 	if (!!data) {
 		adapter->rx_csum = !!data;
 		return 0;
@@ -1070,7 +1086,7 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_pauseparam = qlcnic_get_pauseparam,
 	.set_pauseparam = qlcnic_set_pauseparam,
 	.get_tx_csum = qlcnic_get_tx_csum,
-	.set_tx_csum = ethtool_op_set_tx_csum,
+	.set_tx_csum = qlcnic_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = qlcnic_get_tso,
 	.set_tso = qlcnic_set_tso,
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 7bb3285..aa1f6b3 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -110,6 +110,8 @@ static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
 static int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
 static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
+static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
+				struct qlcnic_esw_func_cfg *);
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
@@ -756,6 +758,98 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	adapter->max_rds_rings = MAX_RDS_RINGS;
 }
 
+static void
+qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
+		struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	qlcnic_set_netdev_features(adapter, esw_cfg);
+}
+
+static int
+qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_esw_func_cfg esw_cfg;
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return 0;
+
+	esw_cfg.pci_func = adapter->ahw.pci_func;
+	if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg))
+			return -EIO;
+	qlcnic_set_eswitch_port_features(adapter, &esw_cfg);
+
+	return 0;
+}
+
+static void
+qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
+		struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	struct net_device *netdev = adapter->netdev;
+	unsigned long features, vlan_features;
+
+	features = (NETIF_F_SG | NETIF_F_IP_CSUM |
+			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
+	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
+			NETIF_F_IPV6_CSUM);
+
+	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+		features |= (NETIF_F_TSO | NETIF_F_TSO6);
+		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	}
+	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+		features |= NETIF_F_LRO;
+
+	if (esw_cfg->offload_flags & BIT_0) {
+		netdev->features |= features;
+		adapter->rx_csum = 1;
+		if (!(esw_cfg->offload_flags & BIT_1))
+			netdev->features &= ~NETIF_F_TSO;
+		if (!(esw_cfg->offload_flags & BIT_2))
+			netdev->features &= ~NETIF_F_TSO6;
+	} else {
+		netdev->features &= ~features;
+		adapter->rx_csum = 0;
+	}
+
+	netdev->vlan_features = (features & vlan_features);
+}
+
+static int
+qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_esw_func_cfg esw_cfg;
+	struct qlcnic_npar_info *npar;
+	u8 i;
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+	    adapter->need_fw_reset ||
+	    adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return 0;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+			continue;
+		memset(&esw_cfg, 0, sizeof(struct qlcnic_esw_func_cfg));
+		esw_cfg.pci_func = i;
+		esw_cfg.offload_flags = BIT_0;
+		esw_cfg.mac_learning = BIT_0;
+		if (adapter->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
+			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		if (qlcnic_config_switch_port(adapter, &esw_cfg))
+			return -EIO;
+		npar = &adapter->npars[i];
+		npar->pvid = esw_cfg.vlan_id;
+		npar->mac_learning = esw_cfg.offload_flags;
+		npar->mac_anti_spoof = esw_cfg.mac_anti_spoof;
+		npar->discard_tagged = esw_cfg.discard_tagged;
+		npar->promisc_mode = esw_cfg.promisc_mode;
+		npar->offload_flags = esw_cfg.offload_flags;
+	}
+
+	return 0;
+}
+
 static int
 qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_npar_info *npar, int pci_func)
@@ -879,6 +973,8 @@ wait_init:
 
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
+	if (qlcnic_set_default_offload_settings(adapter))
+		goto err_out;
 	if (qlcnic_reset_npar_config(adapter))
 		goto err_out;
 	qlcnic_dev_set_npar_ready(adapter);
@@ -974,6 +1070,8 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		return 0;
+	if (qlcnic_set_eswitch_port_config(adapter))
+		return -EIO;
 
 	if (qlcnic_fw_create_ctx(adapter))
 		return -EIO;
@@ -1291,7 +1389,6 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
 		netdev->features |= NETIF_F_LRO;
-
 	netdev->irq = adapter->msix_entries[0].vector;
 
 	if (qlcnic_read_mac_addr(adapter))
@@ -3216,7 +3313,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_func_cfg *esw_cfg;
 	struct qlcnic_npar_info *npar;
 	int count, rem, i, ret;
-	u8 pci_func;
+	u8 pci_func, op_mode = 0;
 
 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
@@ -3229,10 +3326,24 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		return ret;
 
 	for (i = 0; i < count; i++) {
-		if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
-			return QL_STATUS_INVALID_PARAM;
+		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
+				return QL_STATUS_INVALID_PARAM;
+		if (adapter->ahw.pci_func == esw_cfg[i].pci_func)
+			op_mode = esw_cfg[i].op_mode;
+			qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]);
+			esw_cfg[i].op_mode = op_mode;
+			esw_cfg[i].pci_func = adapter->ahw.pci_func;
+			switch (esw_cfg[i].op_mode) {
+			case QLCNIC_PORT_DEFAULTS:
+				qlcnic_set_eswitch_port_features(adapter,
+								&esw_cfg[i]);
+				break;
+		}
 	}
 
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+		goto out;
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
 		npar = &adapter->npars[pci_func];
@@ -3252,7 +3363,7 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 			break;
 		}
 	}
-
+out:
 	return size;
 }
 
-- 
1.6.0.2

