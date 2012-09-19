From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 11/19] qlcnic: sysfs interface routine updates
Date: Wed, 19 Sep 2012 15:29:49 -0400
Message-ID: <1348082997-12333-12-git-send-email-sony.chacko@qlogic.com>
References: <1348082997-12333-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43124 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753496Ab2ITBMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 21:12:42 -0400
In-Reply-To: <1348082997-12333-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  205 +++++++++++-----------
 2 files changed, 107 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index d046628..151b43f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -494,6 +494,7 @@ struct qlcnic_hardware_context {
 	struct qlcnic_nic_intr_coalesce coal;
 	struct qlcnic_fw_dump fw_dump;
 	u32 *reg_tbl;
+	u32 *ext_reg_tbl;
 };
 
 struct qlcnic_adapter_stats {
@@ -1103,6 +1104,7 @@ struct qlcnic_eswitch {
 
 /* Return codes for Error handling */
 #define QL_STATUS_INVALID_PARAM	-1
+#define QL_STATUS_UNSUPPORTED_CMD	-2
 
 #define MAX_BW			100	/* % of link speed */
 #define MAX_VLAN_ID		4095
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 438824e..1dadeb4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2937,10 +2937,10 @@ qlcnic_store_bridged_mode(struct device *dev,
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto err_out;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		goto err_out;
 
-	if (!adapter->nic_ops->config_bridged_mode(adapter, !!new))
+	if (!qlcnic_config_bridged_mode(adapter, !!new))
 		ret = len;
 
 err_out:
@@ -2961,9 +2961,9 @@ qlcnic_show_bridged_mode(struct device *dev,
 }
 
 static struct device_attribute dev_attr_bridged_mode = {
-       .attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
-       .show = qlcnic_show_bridged_mode,
-       .store = qlcnic_store_bridged_mode,
+	.attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
+	.show = qlcnic_show_bridged_mode,
+	.store = qlcnic_store_bridged_mode,
 };
 
 static ssize_t
@@ -2973,7 +2973,7 @@ qlcnic_store_diag_mode(struct device *dev,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	unsigned long new;
 
-	if (strict_strtoul(buf, 2, &new))
+	if (kstrtoul(buf, 2, &new))
 		return -EINVAL;
 
 	if (!!new != !!(adapter->flags & QLCNIC_DIAG_ENABLED))
@@ -3028,10 +3028,9 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
 
-	if (qlcnic_enable_msix(adapter, data)) {
+	err = qlcnic_setup_intr(adapter, data);
+	if (err)
 		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
-		qlcnic_enable_msi_legacy(adapter);
-	}
 
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
@@ -3075,16 +3074,11 @@ qlcnic_store_beacon(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int max_sds_rings = adapter->max_sds_rings;
+	int dev_down = 0;
 	u16 beacon;
 	u8 b_state, b_rate;
 	int err;
 
-	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		dev_warn(dev, "LED test not supported for non "
-				"privilege function\n");
-		return -EOPNOTSUPP;
-	}
-
 	if (len != sizeof(u16))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3096,40 +3090,36 @@ qlcnic_store_beacon(struct device *dev,
 	if (adapter->ahw->beacon_state == b_state)
 		return len;
 
-	rtnl_lock();
-
 	if (!adapter->ahw->beacon_state)
-		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state)) {
-			rtnl_unlock();
+		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state))
 			return -EBUSY;
-		}
-
-	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
-		err = -EIO;
-		goto out;
-	}
 
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+		if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+			return -EIO;
 		err = qlcnic_diag_alloc_res(adapter->netdev, QLCNIC_LED_TEST);
-		if (err)
-			goto out;
-		set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
+		if (err) {
+			clear_bit(__QLCNIC_RESETTING, &adapter->state);
+			clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+			return err;
+		}
+		dev_down = 1;
 	}
 
 	err = qlcnic_config_led(adapter, b_state, b_rate);
 
 	if (!err) {
-		err = len;
 		adapter->ahw->beacon_state = b_state;
+		err = len;
 	}
 
-	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
+	if (dev_down) {
 		qlcnic_diag_free_res(adapter->netdev, max_sds_rings);
+		clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	}
 
- out:
-	if (!adapter->ahw->beacon_state)
+	if (!b_state)
 		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
-	rtnl_unlock();
 
 	return err;
 }
@@ -3179,21 +3169,13 @@ qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
 {
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
-	int err, ret;
+	int ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
-		memcpy(buf, &qmdata, size);
-	} else {
-		data = QLCRD32(adapter, offset, &err);
-		memcpy(buf, &data, size);
-	}
+	qlcnic_read_crb(adapter, buf, offset, size);
 	return size;
 }
 
@@ -3204,21 +3186,13 @@ qlcnic_sysfs_write_crb(struct file *filp, struct kobject *kobj,
 {
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
 	int ret;
 
 	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
 	if (ret != 0)
 		return ret;
 
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		memcpy(&qmdata, buf, size);
-		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
-	} else {
-		memcpy(&data, buf, size);
-		QLCWR32(adapter, offset, data);
-	}
+	qlcnic_write_crb(adapter, buf, offset, size);
 	return size;
 }
 
@@ -3305,14 +3279,11 @@ validate_pm_config(struct qlcnic_adapter *adapter,
 	for (i = 0; i < count; i++) {
 		src_pci_func = pm_cfg[i].pci_func;
 		dest_pci_func = pm_cfg[i].dest_npar;
-		if (src_pci_func >= QLCNIC_MAX_PCI_FUNC
-				|| dest_pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->npars[src_pci_func].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, src_pci_func) < 0)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->npars[dest_pci_func].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, dest_pci_func) < 0)
 			return QL_STATUS_INVALID_PARAM;
 
 		s_esw_id = adapter->npars[src_pci_func].phy_port;
@@ -3334,7 +3305,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pm_func_cfg *pm_cfg;
 	u32 id, action, pci_func;
-	int count, rem, i, ret;
+	int count, rem, i, ret, index;
 
 	count	= size / sizeof(struct qlcnic_pm_func_cfg);
 	rem	= size % sizeof(struct qlcnic_pm_func_cfg);
@@ -3348,6 +3319,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 		return ret;
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
+
 		action = !!pm_cfg[i].action;
 		id = adapter->npars[pci_func].phy_port;
 		ret = qlcnic_config_port_mirroring(adapter, id,
@@ -3358,9 +3330,10 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
 		id = adapter->npars[pci_func].phy_port;
-		adapter->npars[pci_func].enable_pm = !!pm_cfg[i].action;
-		adapter->npars[pci_func].dest_npar = id;
+		adapter->npars[index].enable_pm = !!pm_cfg[i].action;
+		adapter->npars[index].dest_npar = id;
 	}
 	return size;
 }
@@ -3373,16 +3346,19 @@ qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_pm_func_cfg pm_cfg[QLCNIC_MAX_PCI_FUNC];
 	int i;
+	u8 pci_func;
 
 	if (size != sizeof(pm_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		pm_cfg[i].action = adapter->npars[i].enable_pm;
-		pm_cfg[i].dest_npar = 0;
-		pm_cfg[i].pci_func = i;
+	memset(&pm_cfg, 0,
+	       sizeof(struct qlcnic_pm_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		pm_cfg[pci_func].action = adapter->npars[i].enable_pm;
+		pm_cfg[pci_func].dest_npar = 0;
+		pm_cfg[pci_func].pci_func = i;
 	}
 	memcpy(buf, &pm_cfg, size);
 
@@ -3395,9 +3371,10 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 {
 	u32 op_mode;
 	u8 pci_func;
-	int i;
+	int i, ret;
 
-	op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
+	if (QLCNIC_IS_82XX(adapter))
+		op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
@@ -3405,13 +3382,16 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 			return QL_STATUS_INVALID_PARAM;
 
 		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
-			if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
+			if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
 				return QL_STATUS_INVALID_PARAM;
 
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
-			if (QLC_DEV_GET_DRV(op_mode, pci_func) !=
-						QLCNIC_NON_PRIV_FUNC) {
+			if (QLCNIC_IS_82XX(adapter)) {
+				ret = QLC_DEV_GET_DRV(op_mode, pci_func);
+			}
+
+			if (ret !=  QLCNIC_NON_PRIV_FUNC) {
 				if (esw_cfg[i].mac_anti_spoof != 0)
 					return QL_STATUS_INVALID_PARAM;
 				if (esw_cfg[i].mac_override != 1)
@@ -3446,7 +3426,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_func_cfg *esw_cfg;
 	struct qlcnic_npar_info *npar;
 	int count, rem, i, ret;
-	u8 pci_func, op_mode = 0;
+	int index;
+	u8 op_mode = 0, pci_func;
 
 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
@@ -3490,7 +3471,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
-		npar = &adapter->npars[pci_func];
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		npar = &adapter->npars[index];
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
 			npar->promisc_mode = esw_cfg[i].promisc_mode;
@@ -3518,16 +3500,18 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_esw_func_cfg esw_cfg[QLCNIC_MAX_PCI_FUNC];
-	u8 i;
+	u8 i, pci_func;
 
 	if (size != sizeof(esw_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		esw_cfg[i].pci_func = i;
-		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]))
+	memset(&esw_cfg, 0,
+	       sizeof(struct qlcnic_esw_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		esw_cfg[pci_func].pci_func = pci_func;
+		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[pci_func]))
 			return QL_STATUS_INVALID_PARAM;
 	}
 	memcpy(buf, &esw_cfg, size);
@@ -3543,11 +3527,8 @@ validate_npar_config(struct qlcnic_adapter *adapter,
 
 	for (i = 0; i < count; i++) {
 		pci_func = np_cfg[i].pci_func;
-		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
-			return QL_STATUS_INVALID_PARAM;
+		if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
+				return QL_STATUS_INVALID_PARAM;
 
 		if (!IS_VALID_BW(np_cfg[i].min_bw) ||
 		    !IS_VALID_BW(np_cfg[i].max_bw))
@@ -3564,7 +3545,7 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_info nic_info;
 	struct qlcnic_npar_func_cfg *np_cfg;
-	int i, count, rem, ret;
+	int i, count, rem, ret, index;
 	u8 pci_func;
 
 	count	= size / sizeof(struct qlcnic_npar_func_cfg);
@@ -3579,6 +3560,7 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count ; i++) {
 		pci_func = np_cfg[i].pci_func;
+		memset(&nic_info, 0, sizeof(struct qlcnic_info));
 		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
 		if (ret)
 			return ret;
@@ -3588,13 +3570,15 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 		ret = qlcnic_set_nic_info(adapter, &nic_info);
 		if (ret)
 			return ret;
-		adapter->npars[i].min_bw = nic_info.min_tx_bw;
-		adapter->npars[i].max_bw = nic_info.max_tx_bw;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		adapter->npars[index].min_bw = nic_info.min_tx_bw;
+		adapter->npars[index].max_bw = nic_info.max_tx_bw;
 	}
 
 	return size;
 
 }
+
 static ssize_t
 qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
@@ -3608,8 +3592,12 @@ qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(np_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
+	memset(&np_cfg, 0, sizeof(struct qlcnic_npar_func_cfg) *
+	       QLCNIC_MAX_PCI_FUNC);
+
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
+		if (qlcnic_is_valid_nic_func(adapter, i) < 0)
 			continue;
 		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
 		if (ret)
@@ -3637,6 +3625,9 @@ qlcnic_sysfs_get_port_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_statistics port_stats;
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (size != sizeof(struct qlcnic_esw_statistics))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3667,6 +3658,9 @@ qlcnic_sysfs_get_esw_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_esw_statistics esw_stats;
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (size != sizeof(struct qlcnic_esw_statistics))
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3696,6 +3690,9 @@ qlcnic_sysfs_clear_esw_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3721,6 +3718,9 @@ qlcnic_sysfs_clear_port_stats(struct file *file, struct kobject *kobj,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	int ret;
 
+	if (QLCNIC_IS_83XX(adapter))
+		return QL_STATUS_UNSUPPORTED_CMD;
+
 	if (offset >= QLCNIC_MAX_PCI_FUNC)
 		return QL_STATUS_INVALID_PARAM;
 
@@ -3750,6 +3750,9 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(pci_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&pci_cfg, 0,
+	       sizeof(struct qlcnic_pci_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
@@ -3772,6 +3775,7 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	kfree(pci_info);
 	return size;
 }
+
 static struct bin_attribute bin_attr_npar_config = {
 	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
@@ -3814,7 +3818,7 @@ static struct bin_attribute bin_attr_pm_config = {
 	.write = qlcnic_sysfs_write_pm_config,
 };
 
-static void
+void
 qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
@@ -3825,7 +3829,7 @@ qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
 				"failed to create bridged_mode sysfs entry\n");
 }
 
-static void
+void
 qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
@@ -3837,9 +3841,7 @@ qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
 static void
 qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
-	int err;
 	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
 		dev_info(dev, "failed to create port stats sysfs entry");
@@ -3851,10 +3853,7 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 	if (device_create_bin_file(dev, &bin_attr_crb))
 		dev_info(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
-		dev_info(dev, "failed to create mem sysfs entry\n");
-
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
-		return;
+		dev_err(dev, "failed to create mem sysfs entry\n");
 
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
 		dev_info(dev, "failed to create pci config sysfs entry");
@@ -3878,9 +3877,7 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 static void
 qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
-	int err;
 	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE, &err);
 
 	device_remove_bin_file(dev, &bin_attr_port_stats);
 
@@ -3889,8 +3886,6 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
-		return;
 	device_remove_bin_file(dev, &bin_attr_pci_config);
 	device_remove_file(dev, &dev_attr_beacon);
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
@@ -3915,6 +3910,16 @@ qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
 	qlcnic_remove_diag_entries(adapter);
 }
 
+void qlcnic_83xx_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+void qlcnic_83xx_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
+
 #ifdef CONFIG_INET
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
-- 
1.7.1
