From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v4 15/21] qlcnic: create seperate file for sysfs routines
Date: Mon, 29 Oct 2012 20:14:46 -0400
Message-ID: <1351556092-16417-16-git-send-email-sony.chacko@qlogic.com>
References: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:18034 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755924Ab2J3AeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 20:34:12 -0400
In-Reply-To: <1351556092-16417-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Create a common file for 82xx and 83xx sysfs interface routines

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   26 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   60 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 1066 +-------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  | 1106 ++++++++++++++++++++
 6 files changed, 1207 insertions(+), 1056 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index f5a31ab..2968c57 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -6,4 +6,4 @@ obj-$(CONFIG_QLCNIC) := qlcnic.o
 
 qlcnic-y := qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
 	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o \
-	qlcnic_83xx_hw.o
+	qlcnic_sysfs.o qlcnic_83xx_hw.o
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 1479a26..fe1d28f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1533,6 +1533,11 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 int qlcnic_poll(struct napi_struct *, int);
 int qlcnic_rx_poll(struct napi_struct *, int);
 int qlcnic_enable_msix(struct qlcnic_adapter *, u32);
+void qlcnic_set_vlan_config(struct qlcnic_adapter *,
+			    struct qlcnic_esw_func_cfg *);
+int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *);
+void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *,
+				      struct qlcnic_esw_func_cfg *);
 
 /*  eSwitch management functions */
 int qlcnic_config_switch_port(struct qlcnic_adapter *,
@@ -1554,6 +1559,27 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *, int);
 void qlcnic_free_tx_rings(struct qlcnic_adapter *);
 int qlcnic_alloc_tx_rings(struct qlcnic_adapter *, struct net_device *);
 
+void qlcnic_create_sysfs_entries(struct qlcnic_adapter *);
+void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *);
+void qlcnic_create_diag_entries(struct qlcnic_adapter *);
+void qlcnic_remove_diag_entries(struct qlcnic_adapter *);
+void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *);
+void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *);
+
+void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter);
+void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
+void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
+void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
+
+void __qlcnic_down(struct qlcnic_adapter *, struct net_device *);
+void qlcnic_detach(struct qlcnic_adapter *);
+void qlcnic_teardown_intr(struct qlcnic_adapter *);
+int qlcnic_attach(struct qlcnic_adapter *);
+int __qlcnic_up(struct qlcnic_adapter *, struct net_device *);
+void qlcnic_restore_indev_addr(struct net_device *, unsigned long);
+
+int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
+int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
 /*
  * QLOGIC Board information
  */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 3829849..3f6e2ca 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -146,6 +146,8 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_func_no			= qlcnic_83xx_get_func_no,
 	.api_lock			= qlcnic_83xx_cam_lock,
 	.api_unlock			= qlcnic_83xx_cam_unlock,
+	.add_sysfs			= qlcnic_83xx_add_sysfs,
+	.remove_sysfs			= qlcnic_83xx_remove_sysfs,
 	.process_lb_rcv_ring_diag	= qlcnic_83xx_process_rcv_ring_diag,
 	.create_rx_ctx			= qlcnic_83xx_create_rx_ctx,
 	.create_tx_ctx			= qlcnic_83xx_create_tx_ctx,
@@ -1085,6 +1087,64 @@ out:
 	return err;
 }
 
+int qlcnic_83xx_config_led(struct qlcnic_adapter *adapter, u32 state,
+			   u32 beacon)
+{
+	struct qlcnic_cmd_args cmd;
+	u32 mbx_in;
+	int i, status = 0;
+
+	if (state) {
+		/* Get LED configuration */
+		qlcnic_alloc_mbx_args(&cmd, adapter,
+				      QLCNIC_CMD_GET_LED_CONFIG);
+		status = qlcnic_issue_cmd(adapter, &cmd);
+		if (status) {
+			dev_err(&adapter->pdev->dev,
+				"Get led config failed.\n");
+			goto mbx_err;
+		} else {
+			for (i = 0; i < 4; i++)
+				adapter->ahw->mbox_reg[i] = cmd.rsp.arg[i+1];
+		}
+		qlcnic_free_mbx_args(&cmd);
+		/* Set LED Configuration */
+		mbx_in = (LSW(QLC_83XX_LED_CONFIG) << 16) |
+			  LSW(QLC_83XX_LED_CONFIG);
+		qlcnic_alloc_mbx_args(&cmd, adapter,
+				      QLCNIC_CMD_SET_LED_CONFIG);
+		cmd.req.arg[1] = cpu_to_le32(mbx_in);
+		cmd.req.arg[2] = cpu_to_le32(mbx_in);
+		cmd.req.arg[3] = cpu_to_le32(mbx_in);
+		if (beacon)
+			cmd.req.arg[4] = QLC_83XX_ENABLE_BEACON;
+		status = qlcnic_issue_cmd(adapter, &cmd);
+		if (status) {
+			dev_err(&adapter->pdev->dev,
+				"Set led config failed.\n");
+		}
+mbx_err:
+		qlcnic_free_mbx_args(&cmd);
+		return status;
+
+	} else {
+		/* Restoring default LED configuration */
+		qlcnic_alloc_mbx_args(&cmd, adapter,
+				      QLCNIC_CMD_SET_LED_CONFIG);
+		cmd.req.arg[1] = adapter->ahw->mbox_reg[0];
+		cmd.req.arg[2] = adapter->ahw->mbox_reg[1];
+		cmd.req.arg[3] = adapter->ahw->mbox_reg[2];
+		if (beacon)
+			cmd.req.arg[4] = adapter->ahw->mbox_reg[3];
+		status = qlcnic_issue_cmd(adapter, &cmd);
+		if (status)
+			dev_err(&adapter->pdev->dev,
+				"Restoring led config failed.\n");
+		qlcnic_free_mbx_args(&cmd);
+		return status;
+	}
+}
+
 void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *adapter,
 				       int enable)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 4396903..e29ad3c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -296,6 +296,8 @@ void qlcnic_83xx_get_func_no(struct qlcnic_adapter *);
 int qlcnic_83xx_cam_lock(struct qlcnic_adapter *);
 void qlcnic_83xx_cam_unlock(struct qlcnic_adapter *);
 int qlcnic_send_ctrl_op(struct qlcnic_adapter *, struct qlcnic_cmd_args *, u32);
+void qlcnic_83xx_add_sysfs(struct qlcnic_adapter *);
+void qlcnic_83xx_remove_sysfs(struct qlcnic_adapter *);
 void qlcnic_83xx_write_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 void qlcnic_83xx_read_crb(struct qlcnic_adapter *, char *, loff_t, size_t);
 int qlcnic_83xx_rd_reg_indirect(struct qlcnic_adapter *, ulong);
@@ -317,6 +319,7 @@ int qlcnic_83xx_napi_add(struct qlcnic_adapter *, struct net_device *);
 void qlcnic_83xx_napi_del(struct qlcnic_adapter *);
 void qlcnic_83xx_napi_enable(struct qlcnic_adapter *);
 void qlcnic_83xx_napi_disable(struct qlcnic_adapter *);
+int qlcnic_83xx_config_led(struct qlcnic_adapter *, u32, u32);
 void qlcnic_ind_wr(struct qlcnic_adapter *, u32, u32);
 int qlcnic_ind_rd(struct qlcnic_adapter *, u32);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index f9537ca..ca6d047 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -72,13 +72,6 @@ static void qlcnic_fw_poll_work(struct work_struct *work);
 static void qlcnic_poll_controller(struct net_device *netdev);
 #endif
 
-static void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
-static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
-static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
-
 static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter, u8);
 static int qlcnic_can_start_firmware(struct qlcnic_adapter *adapter);
@@ -90,13 +83,10 @@ static irqreturn_t qlcnic_msix_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
-static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
 static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
 static void qlcnic_free_lb_filters_mem(struct qlcnic_adapter *adapter);
 static void qlcnic_dev_set_npar_ready(struct qlcnic_adapter *);
-static int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
-static int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 static int qlcnicvf_start_firmware(struct qlcnic_adapter *);
 static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 				struct qlcnic_esw_func_cfg *);
@@ -462,8 +452,7 @@ int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 	return 0;
 }
 
-static void
-qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
+void qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 {
 	if (adapter->flags & QLCNIC_MSIX_ENABLED)
 		pci_disable_msix(adapter->pdev);
@@ -816,9 +805,8 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static void
-qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
-		struct qlcnic_esw_func_cfg *esw_cfg)
+void qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
+			    struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	if (esw_cfg->discard_tagged)
 		adapter->flags &= ~QLCNIC_TAGGING_ENABLED;
@@ -849,9 +837,8 @@ qlcnic_vlan_rx_del(struct net_device *netdev, u16 vid)
 	return 0;
 }
 
-static void
-qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
-		struct qlcnic_esw_func_cfg *esw_cfg)
+void qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
+				      struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	adapter->flags &= ~(QLCNIC_MACSPOOF | QLCNIC_MAC_OVERRIDE_DISABLED |
 				QLCNIC_PROMISC_DISABLED);
@@ -868,8 +855,7 @@ qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
-static int
-qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
+int qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
 
@@ -1261,8 +1247,7 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 	}
 }
 
-static int
-__qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
+int __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int ring;
 	u32 capab2;
@@ -1327,8 +1312,7 @@ int qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	return err;
 }
 
-static void
-__qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
+void __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return;
@@ -1370,7 +1354,7 @@ qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 }
 
-static int
+int
 qlcnic_attach(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1416,8 +1400,7 @@ err_out_napi_del:
 	return err;
 }
 
-static void
-qlcnic_detach(struct qlcnic_adapter *adapter)
+void qlcnic_detach(struct qlcnic_adapter *adapter)
 {
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return;
@@ -1738,18 +1721,6 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
-{
-	int i;
-
-	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
-		if (adapter->npars[i].pci_func == pci_func)
-			return i;
-	}
-
-	return -1;
-}
-
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -3098,1020 +3069,6 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
-qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
-{
-	return -EOPNOTSUPP;
-}
-
-static int
-qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
-{
-	return -EOPNOTSUPP;
-}
-
-static ssize_t
-qlcnic_store_bridged_mode(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	unsigned long new;
-	int ret = -EINVAL;
-
-	if (!(adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG))
-		goto err_out;
-
-	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
-		goto err_out;
-
-	if (strict_strtoul(buf, 2, &new))
-		goto err_out;
-
-	if (!adapter->nic_ops->config_bridged_mode(adapter, !!new))
-		ret = len;
-
-err_out:
-	return ret;
-}
-
-static ssize_t
-qlcnic_show_bridged_mode(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	int bridged_mode = 0;
-
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
-		bridged_mode = !!(adapter->flags & QLCNIC_BRIDGE_ENABLED);
-
-	return sprintf(buf, "%d\n", bridged_mode);
-}
-
-static struct device_attribute dev_attr_bridged_mode = {
-       .attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
-       .show = qlcnic_show_bridged_mode,
-       .store = qlcnic_store_bridged_mode,
-};
-
-static ssize_t
-qlcnic_store_diag_mode(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	unsigned long new;
-
-	if (strict_strtoul(buf, 2, &new))
-		return -EINVAL;
-
-	if (!!new != !!(adapter->flags & QLCNIC_DIAG_ENABLED))
-		adapter->flags ^= QLCNIC_DIAG_ENABLED;
-
-	return len;
-}
-
-static ssize_t
-qlcnic_show_diag_mode(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-
-	return sprintf(buf, "%d\n",
-			!!(adapter->flags & QLCNIC_DIAG_ENABLED));
-}
-
-static struct device_attribute dev_attr_diag_mode = {
-	.attr = {.name = "diag_mode", .mode = (S_IRUGO | S_IWUSR)},
-	.show = qlcnic_show_diag_mode,
-	.store = qlcnic_store_diag_mode,
-};
-
-int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
-{
-	if (!qlcnic_use_msi_x && !qlcnic_use_msi) {
-		netdev_info(netdev, "no msix or msi support, hence no rss\n");
-		return -EINVAL;
-	}
-
-	if ((val > max_hw) || (val <  2) || !is_power_of_2(val)) {
-		netdev_info(netdev, "rss_ring valid range [2 - %x] in "
-			" powers of 2\n", max_hw);
-		return -EINVAL;
-	}
-	return 0;
-
-}
-
-int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
-{
-	int err;
-	struct net_device *netdev = adapter->netdev;
-
-	rtnl_lock();
-	netif_device_detach(netdev);
-	if (netif_running(netdev))
-		__qlcnic_down(adapter, netdev);
-
-	if (qlcnic_83xx_check(adapter)) {
-		if (adapter->flags & QLCNIC_MSIX_ENABLED)
-			qlcnic_83xx_config_intrpt(adapter, 0);
-		qlcnic_83xx_free_mbx_intr(adapter);
-	}
-
-	qlcnic_detach(adapter);
-	qlcnic_teardown_intr(adapter);
-	err = adapter->ahw->hw_ops->setup_intr(adapter, data);
-	if (err)
-		dev_err(&adapter->pdev->dev,
-			"failed setting max_rss; rss disabled\n");
-
-	if (qlcnic_83xx_check(adapter)) {
-		err = qlcnic_83xx_setup_mbx_intr(adapter);
-		if (err) {
-			dev_err(&adapter->pdev->dev,
-				"failed to setup mbx interrupt\n");
-			goto done;
-		}
-	}
-
-	if (netif_running(netdev)) {
-		err = qlcnic_attach(adapter);
-		if (err)
-			goto done;
-		err = __qlcnic_up(adapter, netdev);
-		if (err)
-			goto done;
-		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
-	}
- done:
-	netif_device_attach(netdev);
-	rtnl_unlock();
-	return err;
-
-}
-
-static int
-qlcnic_validate_beacon(struct qlcnic_adapter *adapter, u16 beacon, u8 *state,
-			u8 *rate)
-{
-	*rate = LSB(beacon);
-	*state = MSB(beacon);
-
-	QLCDB(adapter, DRV, "rate %x state %x\n", *rate, *state);
-
-	if (!*state) {
-		*rate = __QLCNIC_MAX_LED_RATE;
-		return 0;
-	} else if (*state > __QLCNIC_MAX_LED_STATE)
-		return -EINVAL;
-
-	if ((!*rate) || (*rate > __QLCNIC_MAX_LED_RATE))
-		return -EINVAL;
-
-	return 0;
-}
-
-static ssize_t
-qlcnic_store_beacon(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t len)
-{
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	int max_sds_rings = adapter->max_sds_rings;
-	u16 beacon;
-	u8 b_state, b_rate;
-	int err;
-
-	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		dev_warn(dev, "LED test not supported for non "
-				"privilege function\n");
-		return -EOPNOTSUPP;
-	}
-
-	if (len != sizeof(u16))
-		return QL_STATUS_INVALID_PARAM;
-
-	memcpy(&beacon, buf, sizeof(u16));
-	err = qlcnic_validate_beacon(adapter, beacon, &b_state, &b_rate);
-	if (err)
-		return err;
-
-	if (adapter->ahw->beacon_state == b_state)
-		return len;
-
-	rtnl_lock();
-
-	if (!adapter->ahw->beacon_state)
-		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state)) {
-			rtnl_unlock();
-			return -EBUSY;
-		}
-
-	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
-		err = -EIO;
-		goto out;
-	}
-
-	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-		err = qlcnic_diag_alloc_res(adapter->netdev, QLCNIC_LED_TEST);
-		if (err)
-			goto out;
-		set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
-	}
-
-	err = qlcnic_config_led(adapter, b_state, b_rate);
-
-	if (!err) {
-		err = len;
-		adapter->ahw->beacon_state = b_state;
-	}
-
-	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
-		qlcnic_diag_free_res(adapter->netdev, max_sds_rings);
-
- out:
-	if (!adapter->ahw->beacon_state)
-		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
-	rtnl_unlock();
-
-	return err;
-}
-
-static ssize_t
-qlcnic_show_beacon(struct device *dev,
-		struct device_attribute *attr, char *buf)
-{
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-
-	return sprintf(buf, "%d\n", adapter->ahw->beacon_state);
-}
-
-static struct device_attribute dev_attr_beacon = {
-	.attr = {.name = "beacon", .mode = (S_IRUGO | S_IWUSR)},
-	.show = qlcnic_show_beacon,
-	.store = qlcnic_store_beacon,
-};
-
-static int
-qlcnic_sysfs_validate_crb(struct qlcnic_adapter *adapter,
-		loff_t offset, size_t size)
-{
-	size_t crb_size = 4;
-
-	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
-		return -EIO;
-
-	if (offset < QLCNIC_PCI_CRBSPACE) {
-		if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM,
-					QLCNIC_PCI_CAMQM_END))
-			crb_size = 8;
-		else
-			return -EINVAL;
-	}
-
-	if ((size != crb_size) || (offset & (crb_size-1)))
-		return  -EINVAL;
-
-	return 0;
-}
-
-static ssize_t
-qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
-		struct bin_attribute *attr,
-		char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
-	int ret;
-
-	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
-	if (ret != 0)
-		return ret;
-
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
-		memcpy(buf, &qmdata, size);
-	} else {
-		data = QLCRD32(adapter, offset);
-		memcpy(buf, &data, size);
-	}
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_write_crb(struct file *filp, struct kobject *kobj,
-		struct bin_attribute *attr,
-		char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u32 data;
-	u64 qmdata;
-	int ret;
-
-	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
-	if (ret != 0)
-		return ret;
-
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		memcpy(&qmdata, buf, size);
-		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
-	} else {
-		memcpy(&data, buf, size);
-		QLCWR32(adapter, offset, data);
-	}
-	return size;
-}
-
-static int
-qlcnic_sysfs_validate_mem(struct qlcnic_adapter *adapter,
-		loff_t offset, size_t size)
-{
-	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
-		return -EIO;
-
-	if ((size != 8) || (offset & 0x7))
-		return  -EIO;
-
-	return 0;
-}
-
-static ssize_t
-qlcnic_sysfs_read_mem(struct file *filp, struct kobject *kobj,
-		struct bin_attribute *attr,
-		char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u64 data;
-	int ret;
-
-	ret = qlcnic_sysfs_validate_mem(adapter, offset, size);
-	if (ret != 0)
-		return ret;
-
-	if (qlcnic_pci_mem_read_2M(adapter, offset, &data))
-		return -EIO;
-
-	memcpy(buf, &data, size);
-
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_write_mem(struct file *filp, struct kobject *kobj,
-		struct bin_attribute *attr,
-		char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	u64 data;
-	int ret;
-
-	ret = qlcnic_sysfs_validate_mem(adapter, offset, size);
-	if (ret != 0)
-		return ret;
-
-	memcpy(&data, buf, size);
-
-	if (qlcnic_pci_mem_write_2M(adapter, offset, data))
-		return -EIO;
-
-	return size;
-}
-
-static struct bin_attribute bin_attr_crb = {
-	.attr = {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_crb,
-	.write = qlcnic_sysfs_write_crb,
-};
-
-static struct bin_attribute bin_attr_mem = {
-	.attr = {.name = "mem", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_mem,
-	.write = qlcnic_sysfs_write_mem,
-};
-
-static int
-validate_pm_config(struct qlcnic_adapter *adapter,
-			struct qlcnic_pm_func_cfg *pm_cfg, int count)
-{
-
-	u8 src_pci_func, s_esw_id, d_esw_id;
-	u8 dest_pci_func;
-	int i;
-
-	for (i = 0; i < count; i++) {
-		src_pci_func = pm_cfg[i].pci_func;
-		dest_pci_func = pm_cfg[i].dest_npar;
-		if (src_pci_func >= QLCNIC_MAX_PCI_FUNC
-				|| dest_pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->npars[src_pci_func].type != QLCNIC_TYPE_NIC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->npars[dest_pci_func].type != QLCNIC_TYPE_NIC)
-			return QL_STATUS_INVALID_PARAM;
-
-		s_esw_id = adapter->npars[src_pci_func].phy_port;
-		d_esw_id = adapter->npars[dest_pci_func].phy_port;
-
-		if (s_esw_id != d_esw_id)
-			return QL_STATUS_INVALID_PARAM;
-
-	}
-	return 0;
-
-}
-
-static ssize_t
-qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_pm_func_cfg *pm_cfg;
-	u32 id, action, pci_func;
-	int count, rem, i, ret;
-
-	count	= size / sizeof(struct qlcnic_pm_func_cfg);
-	rem	= size % sizeof(struct qlcnic_pm_func_cfg);
-	if (rem)
-		return QL_STATUS_INVALID_PARAM;
-
-	pm_cfg = (struct qlcnic_pm_func_cfg *) buf;
-
-	ret = validate_pm_config(adapter, pm_cfg, count);
-	if (ret)
-		return ret;
-	for (i = 0; i < count; i++) {
-		pci_func = pm_cfg[i].pci_func;
-		action = !!pm_cfg[i].action;
-		id = adapter->npars[pci_func].phy_port;
-		ret = qlcnic_config_port_mirroring(adapter, id,
-						action, pci_func);
-		if (ret)
-			return ret;
-	}
-
-	for (i = 0; i < count; i++) {
-		pci_func = pm_cfg[i].pci_func;
-		id = adapter->npars[pci_func].phy_port;
-		adapter->npars[pci_func].enable_pm = !!pm_cfg[i].action;
-		adapter->npars[pci_func].dest_npar = id;
-	}
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_pm_func_cfg pm_cfg[QLCNIC_MAX_PCI_FUNC];
-	int i;
-
-	if (size != sizeof(pm_cfg))
-		return QL_STATUS_INVALID_PARAM;
-
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		pm_cfg[i].action = adapter->npars[i].enable_pm;
-		pm_cfg[i].dest_npar = 0;
-		pm_cfg[i].pci_func = i;
-	}
-	memcpy(buf, &pm_cfg, size);
-
-	return size;
-}
-
-static int
-validate_esw_config(struct qlcnic_adapter *adapter,
-	struct qlcnic_esw_func_cfg *esw_cfg, int count)
-{
-	u32 op_mode;
-	u8 pci_func;
-	int i;
-
-	op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
-
-	for (i = 0; i < count; i++) {
-		pci_func = esw_cfg[i].pci_func;
-		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
-			if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
-				return QL_STATUS_INVALID_PARAM;
-
-		switch (esw_cfg[i].op_mode) {
-		case QLCNIC_PORT_DEFAULTS:
-			if (QLC_DEV_GET_DRV(op_mode, pci_func) !=
-						QLCNIC_NON_PRIV_FUNC) {
-				if (esw_cfg[i].mac_anti_spoof != 0)
-					return QL_STATUS_INVALID_PARAM;
-				if (esw_cfg[i].mac_override != 1)
-					return QL_STATUS_INVALID_PARAM;
-				if (esw_cfg[i].promisc_mode != 1)
-					return QL_STATUS_INVALID_PARAM;
-			}
-			break;
-		case QLCNIC_ADD_VLAN:
-			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
-				return QL_STATUS_INVALID_PARAM;
-			if (!esw_cfg[i].op_type)
-				return QL_STATUS_INVALID_PARAM;
-			break;
-		case QLCNIC_DEL_VLAN:
-			if (!esw_cfg[i].op_type)
-				return QL_STATUS_INVALID_PARAM;
-			break;
-		default:
-			return QL_STATUS_INVALID_PARAM;
-		}
-	}
-	return 0;
-}
-
-static ssize_t
-qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_esw_func_cfg *esw_cfg;
-	struct qlcnic_npar_info *npar;
-	int count, rem, i, ret;
-	u8 pci_func, op_mode = 0;
-
-	count	= size / sizeof(struct qlcnic_esw_func_cfg);
-	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
-	if (rem)
-		return QL_STATUS_INVALID_PARAM;
-
-	esw_cfg = (struct qlcnic_esw_func_cfg *) buf;
-	ret = validate_esw_config(adapter, esw_cfg, count);
-	if (ret)
-		return ret;
-
-	for (i = 0; i < count; i++) {
-		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
-			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
-				return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->ahw->pci_func != esw_cfg[i].pci_func)
-			continue;
-
-		op_mode = esw_cfg[i].op_mode;
-		qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]);
-		esw_cfg[i].op_mode = op_mode;
-		esw_cfg[i].pci_func = adapter->ahw->pci_func;
-
-		switch (esw_cfg[i].op_mode) {
-		case QLCNIC_PORT_DEFAULTS:
-			qlcnic_set_eswitch_port_features(adapter, &esw_cfg[i]);
-			break;
-		case QLCNIC_ADD_VLAN:
-			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
-			break;
-		case QLCNIC_DEL_VLAN:
-			esw_cfg[i].vlan_id = 0;
-			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
-			break;
-		}
-	}
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		goto out;
-
-	for (i = 0; i < count; i++) {
-		pci_func = esw_cfg[i].pci_func;
-		npar = &adapter->npars[pci_func];
-		switch (esw_cfg[i].op_mode) {
-		case QLCNIC_PORT_DEFAULTS:
-			npar->promisc_mode = esw_cfg[i].promisc_mode;
-			npar->mac_override = esw_cfg[i].mac_override;
-			npar->offload_flags = esw_cfg[i].offload_flags;
-			npar->mac_anti_spoof = esw_cfg[i].mac_anti_spoof;
-			npar->discard_tagged = esw_cfg[i].discard_tagged;
-			break;
-		case QLCNIC_ADD_VLAN:
-			npar->pvid = esw_cfg[i].vlan_id;
-			break;
-		case QLCNIC_DEL_VLAN:
-			npar->pvid = 0;
-			break;
-		}
-	}
-out:
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_esw_func_cfg esw_cfg[QLCNIC_MAX_PCI_FUNC];
-	u8 i;
-
-	if (size != sizeof(esw_cfg))
-		return QL_STATUS_INVALID_PARAM;
-
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		esw_cfg[i].pci_func = i;
-		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]))
-			return QL_STATUS_INVALID_PARAM;
-	}
-	memcpy(buf, &esw_cfg, size);
-
-	return size;
-}
-
-static int
-validate_npar_config(struct qlcnic_adapter *adapter,
-				struct qlcnic_npar_func_cfg *np_cfg, int count)
-{
-	u8 pci_func, i;
-
-	for (i = 0; i < count; i++) {
-		pci_func = np_cfg[i].pci_func;
-		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
-			return QL_STATUS_INVALID_PARAM;
-
-		if (!IS_VALID_BW(np_cfg[i].min_bw) ||
-		    !IS_VALID_BW(np_cfg[i].max_bw))
-			return QL_STATUS_INVALID_PARAM;
-	}
-	return 0;
-}
-
-static ssize_t
-qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_info nic_info;
-	struct qlcnic_npar_func_cfg *np_cfg;
-	int i, count, rem, ret;
-	u8 pci_func;
-
-	count	= size / sizeof(struct qlcnic_npar_func_cfg);
-	rem	= size % sizeof(struct qlcnic_npar_func_cfg);
-	if (rem)
-		return QL_STATUS_INVALID_PARAM;
-
-	np_cfg = (struct qlcnic_npar_func_cfg *) buf;
-	ret = validate_npar_config(adapter, np_cfg, count);
-	if (ret)
-		return ret;
-
-	for (i = 0; i < count ; i++) {
-		pci_func = np_cfg[i].pci_func;
-		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
-		if (ret)
-			return ret;
-		nic_info.pci_func = pci_func;
-		nic_info.min_tx_bw = np_cfg[i].min_bw;
-		nic_info.max_tx_bw = np_cfg[i].max_bw;
-		ret = qlcnic_set_nic_info(adapter, &nic_info);
-		if (ret)
-			return ret;
-		adapter->npars[i].min_bw = nic_info.min_tx_bw;
-		adapter->npars[i].max_bw = nic_info.max_tx_bw;
-	}
-
-	return size;
-
-}
-static ssize_t
-qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_info nic_info;
-	struct qlcnic_npar_func_cfg np_cfg[QLCNIC_MAX_PCI_FUNC];
-	int i, ret;
-
-	if (size != sizeof(np_cfg))
-		return QL_STATUS_INVALID_PARAM;
-
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
-		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
-		if (ret)
-			return ret;
-
-		np_cfg[i].pci_func = i;
-		np_cfg[i].op_mode = (u8)nic_info.op_mode;
-		np_cfg[i].port_num = nic_info.phys_port;
-		np_cfg[i].fw_capab = nic_info.capabilities;
-		np_cfg[i].min_bw = nic_info.min_tx_bw ;
-		np_cfg[i].max_bw = nic_info.max_tx_bw;
-		np_cfg[i].max_tx_queues = nic_info.max_tx_ques;
-		np_cfg[i].max_rx_queues = nic_info.max_rx_ques;
-	}
-	memcpy(buf, &np_cfg, size);
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_get_port_stats(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_esw_statistics port_stats;
-	int ret;
-
-	if (size != sizeof(struct qlcnic_esw_statistics))
-		return QL_STATUS_INVALID_PARAM;
-
-	if (offset >= QLCNIC_MAX_PCI_FUNC)
-		return QL_STATUS_INVALID_PARAM;
-
-	memset(&port_stats, 0, size);
-	ret = qlcnic_get_port_stats(adapter, offset, QLCNIC_QUERY_RX_COUNTER,
-								&port_stats.rx);
-	if (ret)
-		return ret;
-
-	ret = qlcnic_get_port_stats(adapter, offset, QLCNIC_QUERY_TX_COUNTER,
-								&port_stats.tx);
-	if (ret)
-		return ret;
-
-	memcpy(buf, &port_stats, size);
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_get_esw_stats(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_esw_statistics esw_stats;
-	int ret;
-
-	if (size != sizeof(struct qlcnic_esw_statistics))
-		return QL_STATUS_INVALID_PARAM;
-
-	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
-		return QL_STATUS_INVALID_PARAM;
-
-	memset(&esw_stats, 0, size);
-	ret = qlcnic_get_eswitch_stats(adapter, offset, QLCNIC_QUERY_RX_COUNTER,
-								&esw_stats.rx);
-	if (ret)
-		return ret;
-
-	ret = qlcnic_get_eswitch_stats(adapter, offset, QLCNIC_QUERY_TX_COUNTER,
-								&esw_stats.tx);
-	if (ret)
-		return ret;
-
-	memcpy(buf, &esw_stats, size);
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_clear_esw_stats(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	int ret;
-
-	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
-		return QL_STATUS_INVALID_PARAM;
-
-	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH, offset,
-						QLCNIC_QUERY_RX_COUNTER);
-	if (ret)
-		return ret;
-
-	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH, offset,
-						QLCNIC_QUERY_TX_COUNTER);
-	if (ret)
-		return ret;
-
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_clear_port_stats(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	int ret;
-
-	if (offset >= QLCNIC_MAX_PCI_FUNC)
-		return QL_STATUS_INVALID_PARAM;
-
-	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
-						QLCNIC_QUERY_RX_COUNTER);
-	if (ret)
-		return ret;
-
-	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
-						QLCNIC_QUERY_TX_COUNTER);
-	if (ret)
-		return ret;
-
-	return size;
-}
-
-static ssize_t
-qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
-	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
-{
-	struct device *dev = container_of(kobj, struct device, kobj);
-	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
-	struct qlcnic_pci_func_cfg pci_cfg[QLCNIC_MAX_PCI_FUNC];
-	struct qlcnic_pci_info *pci_info;
-	int i, ret;
-
-	if (size != sizeof(pci_cfg))
-		return QL_STATUS_INVALID_PARAM;
-
-	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
-	if (!pci_info)
-		return -ENOMEM;
-
-	ret = qlcnic_get_pci_info(adapter, pci_info);
-	if (ret) {
-		kfree(pci_info);
-		return ret;
-	}
-
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
-		pci_cfg[i].pci_func = pci_info[i].id;
-		pci_cfg[i].func_type = pci_info[i].type;
-		pci_cfg[i].port_num = pci_info[i].default_port;
-		pci_cfg[i].min_bw = pci_info[i].tx_min_bw;
-		pci_cfg[i].max_bw = pci_info[i].tx_max_bw;
-		memcpy(&pci_cfg[i].def_mac_addr, &pci_info[i].mac, ETH_ALEN);
-	}
-	memcpy(buf, &pci_cfg, size);
-	kfree(pci_info);
-	return size;
-}
-static struct bin_attribute bin_attr_npar_config = {
-	.attr = {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_npar_config,
-	.write = qlcnic_sysfs_write_npar_config,
-};
-
-static struct bin_attribute bin_attr_pci_config = {
-	.attr = {.name = "pci_config", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_pci_config,
-	.write = NULL,
-};
-
-static struct bin_attribute bin_attr_port_stats = {
-	.attr = {.name = "port_stats", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_get_port_stats,
-	.write = qlcnic_sysfs_clear_port_stats,
-};
-
-static struct bin_attribute bin_attr_esw_stats = {
-	.attr = {.name = "esw_stats", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_get_esw_stats,
-	.write = qlcnic_sysfs_clear_esw_stats,
-};
-
-static struct bin_attribute bin_attr_esw_config = {
-	.attr = {.name = "esw_config", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_esw_config,
-	.write = qlcnic_sysfs_write_esw_config,
-};
-
-static struct bin_attribute bin_attr_pm_config = {
-	.attr = {.name = "pm_config", .mode = (S_IRUGO | S_IWUSR)},
-	.size = 0,
-	.read = qlcnic_sysfs_read_pm_config,
-	.write = qlcnic_sysfs_write_pm_config,
-};
-
-static void
-qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
-{
-	struct device *dev = &adapter->pdev->dev;
-
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
-		if (device_create_file(dev, &dev_attr_bridged_mode))
-			dev_warn(dev,
-				"failed to create bridged_mode sysfs entry\n");
-}
-
-static void
-qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
-{
-	struct device *dev = &adapter->pdev->dev;
-
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
-		device_remove_file(dev, &dev_attr_bridged_mode);
-}
-
-static void
-qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
-{
-	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-
-	if (device_create_bin_file(dev, &bin_attr_port_stats))
-		dev_info(dev, "failed to create port stats sysfs entry");
-
-	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
-		return;
-	if (device_create_file(dev, &dev_attr_diag_mode))
-		dev_info(dev, "failed to create diag_mode sysfs entry\n");
-	if (device_create_bin_file(dev, &bin_attr_crb))
-		dev_info(dev, "failed to create crb sysfs entry\n");
-	if (device_create_bin_file(dev, &bin_attr_mem))
-		dev_info(dev, "failed to create mem sysfs entry\n");
-
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
-		return;
-
-	if (device_create_bin_file(dev, &bin_attr_pci_config))
-		dev_info(dev, "failed to create pci config sysfs entry");
-	if (device_create_file(dev, &dev_attr_beacon))
-		dev_info(dev, "failed to create beacon sysfs entry");
-
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
-		return;
-	if (device_create_bin_file(dev, &bin_attr_esw_config))
-		dev_info(dev, "failed to create esw config sysfs entry");
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		return;
-	if (device_create_bin_file(dev, &bin_attr_npar_config))
-		dev_info(dev, "failed to create npar config sysfs entry");
-	if (device_create_bin_file(dev, &bin_attr_pm_config))
-		dev_info(dev, "failed to create pm config sysfs entry");
-	if (device_create_bin_file(dev, &bin_attr_esw_stats))
-		dev_info(dev, "failed to create eswitch stats sysfs entry");
-}
-
-static void
-qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
-{
-	struct device *dev = &adapter->pdev->dev;
-	u32 state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-
-	device_remove_bin_file(dev, &bin_attr_port_stats);
-
-	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
-		return;
-	device_remove_file(dev, &dev_attr_diag_mode);
-	device_remove_bin_file(dev, &bin_attr_crb);
-	device_remove_bin_file(dev, &bin_attr_mem);
-	if (state == QLCNIC_DEV_FAILED || (state == QLCNIC_DEV_BADBAD))
-		return;
-	device_remove_bin_file(dev, &bin_attr_pci_config);
-	device_remove_file(dev, &dev_attr_beacon);
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
-		return;
-	device_remove_bin_file(dev, &bin_attr_esw_config);
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		return;
-	device_remove_bin_file(dev, &bin_attr_npar_config);
-	device_remove_bin_file(dev, &bin_attr_pm_config);
-	device_remove_bin_file(dev, &bin_attr_esw_stats);
-}
-
-static void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter)
-{
-	qlcnic_create_diag_entries(adapter);
-}
-
-static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
-{
-	qlcnic_remove_diag_entries(adapter);
-}
-
 #ifdef CONFIG_INET
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
@@ -4144,8 +3101,7 @@ static void qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 	in_dev_put(indev);
 }
 
-static void qlcnic_restore_indev_addr(struct net_device *netdev,
-				      unsigned long event)
+void qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
new file mode 100644
index 0000000..024f12d
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -0,0 +1,1106 @@
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/interrupt.h>
+
+#include "qlcnic.h"
+#include "qlcnic_hw.h"
+
+#include <linux/swab.h>
+#include <linux/dma-mapping.h>
+#include <net/ip.h>
+#include <linux/ipv6.h>
+#include <linux/inetdevice.h>
+#include <linux/sysfs.h>
+#include <linux/aer.h>
+#include <linux/log2.h>
+
+#include <linux/sysfs.h>
+
+#define QLC_STATUS_UNSUPPORTED_CMD	-2
+
+int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+{
+	return -EOPNOTSUPP;
+}
+
+int qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+{
+	return -EOPNOTSUPP;
+}
+
+static ssize_t qlcnic_store_bridged_mode(struct device *dev,
+					 struct device_attribute *attr,
+					 const char *buf, size_t len)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	unsigned long new;
+	int ret = -EINVAL;
+
+	if (!(adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG))
+		goto err_out;
+
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
+		goto err_out;
+
+	if (kstrtoul(buf, 2, &new))
+		goto err_out;
+
+	if (!qlcnic_config_bridged_mode(adapter, !!new))
+		ret = len;
+
+err_out:
+	return ret;
+}
+
+static ssize_t qlcnic_show_bridged_mode(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int bridged_mode = 0;
+
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+		bridged_mode = !!(adapter->flags & QLCNIC_BRIDGE_ENABLED);
+
+	return sprintf(buf, "%d\n", bridged_mode);
+}
+
+static ssize_t qlcnic_store_diag_mode(struct device *dev,
+				      struct device_attribute *attr,
+				      const char *buf, size_t len)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	unsigned long new;
+
+	if (kstrtoul(buf, 2, &new))
+		return -EINVAL;
+
+	if (!!new != !!(adapter->flags & QLCNIC_DIAG_ENABLED))
+		adapter->flags ^= QLCNIC_DIAG_ENABLED;
+
+	return len;
+}
+
+static ssize_t qlcnic_show_diag_mode(struct device *dev,
+				     struct device_attribute *attr, char *buf)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	return sprintf(buf, "%d\n", !!(adapter->flags & QLCNIC_DIAG_ENABLED));
+}
+
+int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
+{
+	if (!qlcnic_use_msi_x && !qlcnic_use_msi) {
+		netdev_err(netdev, "no msix or msi support, hence no rss\n");
+		return -EINVAL;
+	}
+
+	if ((val > max_hw) || (val <  2) || !is_power_of_2(val)) {
+		netdev_err(netdev,
+			   "rss_ring valid range [2 - %x] in powers of 2\n",
+			   max_hw);
+		return -EINVAL;
+	}
+	return 0;
+
+}
+
+int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
+{
+	struct net_device *netdev = adapter->netdev;
+	int err = 0;
+
+	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EBUSY;
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev))
+		__qlcnic_down(adapter, netdev);
+	qlcnic_detach(adapter);
+	qlcnic_teardown_intr(adapter);
+
+	err = qlcnic_setup_intr(adapter, data);
+	if (err)
+		netdev_err(netdev, "failed setting max_rss; rss disabled\n");
+
+	if (netif_running(netdev)) {
+		err = qlcnic_attach(adapter);
+		if (err)
+			goto done;
+		err = __qlcnic_up(adapter, netdev);
+		if (err)
+			goto done;
+		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
+	}
+ done:
+	netif_device_attach(netdev);
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return err;
+}
+
+static int qlcnic_validate_beacon(struct qlcnic_adapter *adapter, u16 beacon,
+				  u8 *state, u8 *rate)
+{
+	struct net_device *netdev = adapter->netdev;
+	*rate = LSB(beacon);
+	*state = MSB(beacon);
+
+	netdev_err(netdev, "rate %x state %x\n", *rate, *state);
+
+	if (!*state) {
+		*rate = __QLCNIC_MAX_LED_RATE;
+		return 0;
+	} else if (*state > __QLCNIC_MAX_LED_STATE) {
+		return -EINVAL;
+	}
+
+	if ((!*rate) || (*rate > __QLCNIC_MAX_LED_RATE))
+		return -EINVAL;
+
+	return 0;
+}
+
+static ssize_t qlcnic_store_beacon(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t len)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int err, max_sds_rings = adapter->max_sds_rings;
+	u16 beacon;
+	u8 b_state, b_rate;
+	unsigned long h_beacon;
+
+	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
+		netdev_warn(netdev,
+			    "LED test not supported in non privileged mode\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (qlcnic_83xx_check(adapter) &&
+	    !test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+		if (kstrtoul(buf, 2, &h_beacon))
+			return -EINVAL;
+
+		if (ahw->beacon_state == h_beacon)
+			return len;
+
+		rtnl_lock();
+		if (!ahw->beacon_state) {
+			if (test_and_set_bit(__QLCNIC_LED_ENABLE,
+					     &adapter->state)) {
+				rtnl_unlock();
+				return -EBUSY;
+			}
+		}
+		if (h_beacon) {
+			err = qlcnic_83xx_config_led(adapter, 1, h_beacon);
+			if (err)
+				goto beacon_err;
+		} else {
+			err = qlcnic_83xx_config_led(adapter, 0, !h_beacon);
+			if (err)
+				goto beacon_err;
+		}
+		/* set the current beacon state */
+		ahw->beacon_state = h_beacon;
+beacon_err:
+		if (!ahw->beacon_state)
+			clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+
+		rtnl_unlock();
+		return len;
+	}
+
+	if (len != sizeof(u16))
+		return QL_STATUS_INVALID_PARAM;
+
+	memcpy(&beacon, buf, sizeof(u16));
+	err = qlcnic_validate_beacon(adapter, beacon, &b_state, &b_rate);
+	if (err)
+		return err;
+
+	if (ahw->beacon_state == b_state)
+		return len;
+
+	rtnl_lock();
+
+	if (!ahw->beacon_state)
+		if (test_and_set_bit(__QLCNIC_LED_ENABLE, &adapter->state)) {
+			rtnl_unlock();
+			return -EBUSY;
+		}
+
+	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+		err = -EIO;
+		goto out;
+	}
+
+	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+		err = qlcnic_diag_alloc_res(adapter->netdev, QLCNIC_LED_TEST);
+		if (err)
+			goto out;
+		set_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state);
+	}
+
+	err = qlcnic_config_led(adapter, b_state, b_rate);
+	if (!err)
+		err = len;
+	else
+		ahw->beacon_state = b_state;
+
+	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
+		qlcnic_diag_free_res(adapter->netdev, max_sds_rings);
+
+ out:
+	if (!ahw->beacon_state)
+		clear_bit(__QLCNIC_LED_ENABLE, &adapter->state);
+	rtnl_unlock();
+
+	return err;
+}
+
+static ssize_t qlcnic_show_beacon(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+
+	return snprintf(buf, sizeof(u8) + 2, "%d\n",
+			adapter->ahw->beacon_state);
+}
+
+static int qlcnic_sysfs_validate_crb(struct qlcnic_adapter *adapter,
+				     loff_t offset, size_t size)
+{
+	size_t crb_size = 4;
+
+	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
+		return -EIO;
+
+	if (offset < QLCNIC_PCI_CRBSPACE) {
+		if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM,
+				  QLCNIC_PCI_CAMQM_END))
+			crb_size = 8;
+		else
+			return -EINVAL;
+	}
+
+	if ((size != crb_size) || (offset & (crb_size - 1)))
+		return  -EINVAL;
+
+	return 0;
+}
+
+static ssize_t qlcnic_sysfs_read_crb(struct file *filp, struct kobject *kobj,
+				     struct bin_attribute *attr, char *buf,
+				     loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int ret;
+
+	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+	qlcnic_read_crb(adapter, buf, offset, size);
+
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_write_crb(struct file *filp, struct kobject *kobj,
+				      struct bin_attribute *attr,
+				      char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int ret;
+
+	ret = qlcnic_sysfs_validate_crb(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	qlcnic_write_crb(adapter, buf, offset, size);
+	return size;
+}
+
+static int qlcnic_sysfs_validate_mem(struct qlcnic_adapter *adapter,
+				     loff_t offset, size_t size)
+{
+	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
+		return -EIO;
+
+	if ((size != 8) || (offset & 0x7))
+		return -EIO;
+
+	return 0;
+}
+
+static ssize_t qlcnic_sysfs_read_mem(struct file *filp, struct kobject *kobj,
+				     struct bin_attribute *attr, char *buf,
+				     loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	u64 data;
+	int ret;
+
+	ret = qlcnic_sysfs_validate_mem(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	if (qlcnic_pci_mem_read_2M(adapter, offset, &data))
+		return -EIO;
+
+	memcpy(buf, &data, size);
+
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_write_mem(struct file *filp, struct kobject *kobj,
+				      struct bin_attribute *attr, char *buf,
+				      loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	u64 data;
+	int ret;
+
+	ret = qlcnic_sysfs_validate_mem(adapter, offset, size);
+	if (ret != 0)
+		return ret;
+
+	memcpy(&data, buf, size);
+
+	if (qlcnic_pci_mem_write_2M(adapter, offset, data))
+		return -EIO;
+
+	return size;
+}
+
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
+{
+	int i;
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		if (adapter->npars[i].pci_func == pci_func)
+			return i;
+	}
+
+	return -1;
+}
+
+static int validate_pm_config(struct qlcnic_adapter *adapter,
+			      struct qlcnic_pm_func_cfg *pm_cfg, int count)
+{
+	u8 src_pci_func, s_esw_id, d_esw_id;
+	u8 dest_pci_func;
+	int i, src_index, dest_index;
+
+	for (i = 0; i < count; i++) {
+		src_pci_func = pm_cfg[i].pci_func;
+		dest_pci_func = pm_cfg[i].dest_npar;
+		src_index = qlcnic_is_valid_nic_func(adapter, src_pci_func);
+
+		if (src_index < 0)
+			return QL_STATUS_INVALID_PARAM;
+
+		dest_index = qlcnic_is_valid_nic_func(adapter, dest_pci_func);
+		if (dest_index < 0)
+			return QL_STATUS_INVALID_PARAM;
+
+		s_esw_id = adapter->npars[src_index].phy_port;
+		d_esw_id = adapter->npars[dest_index].phy_port;
+
+		if (s_esw_id != d_esw_id)
+			return QL_STATUS_INVALID_PARAM;
+	}
+
+	return 0;
+}
+
+static ssize_t qlcnic_sysfs_write_pm_config(struct file *filp,
+					    struct kobject *kobj,
+					    struct bin_attribute *attr,
+					    char *buf, loff_t offset,
+					    size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_pm_func_cfg *pm_cfg;
+	u32 id, action, pci_func;
+	int count, rem, i, ret, index;
+
+	count = size / sizeof(struct qlcnic_pm_func_cfg);
+	rem = size % sizeof(struct qlcnic_pm_func_cfg);
+	if (rem)
+		return QL_STATUS_INVALID_PARAM;
+
+	pm_cfg = (struct qlcnic_pm_func_cfg *)buf;
+	ret = validate_pm_config(adapter, pm_cfg, count);
+
+	if (ret)
+		return ret;
+	for (i = 0; i < count; i++) {
+		pci_func = pm_cfg[i].pci_func;
+		action = !!pm_cfg[i].action;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		if (index < 0)
+			return QL_STATUS_INVALID_PARAM;
+
+		id = adapter->npars[index].phy_port;
+		ret = qlcnic_config_port_mirroring(adapter, id,
+						   action, pci_func);
+		if (ret)
+			return ret;
+	}
+
+	for (i = 0; i < count; i++) {
+		pci_func = pm_cfg[i].pci_func;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		id = adapter->npars[index].phy_port;
+		adapter->npars[index].enable_pm = !!pm_cfg[i].action;
+		adapter->npars[index].dest_npar = id;
+	}
+
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_read_pm_config(struct file *filp,
+					   struct kobject *kobj,
+					   struct bin_attribute *attr,
+					   char *buf, loff_t offset,
+					   size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_pm_func_cfg pm_cfg[QLCNIC_MAX_PCI_FUNC];
+	int i;
+	u8 pci_func;
+
+	if (size != sizeof(pm_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&pm_cfg, 0,
+	       sizeof(struct qlcnic_pm_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		pm_cfg[pci_func].action = adapter->npars[i].enable_pm;
+		pm_cfg[pci_func].dest_npar = 0;
+		pm_cfg[pci_func].pci_func = i;
+	}
+
+	memcpy(buf, &pm_cfg, size);
+	return size;
+}
+
+static int validate_esw_config(struct qlcnic_adapter *adapter,
+			       struct qlcnic_esw_func_cfg *esw_cfg, int count)
+{
+	u32 op_mode;
+	u8 pci_func;
+	int i, ret;
+
+	if (qlcnic_82xx_check(adapter))
+		op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
+	else
+		op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
+
+	for (i = 0; i < count; i++) {
+		pci_func = esw_cfg[i].pci_func;
+		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
+			return QL_STATUS_INVALID_PARAM;
+
+		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
+			if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
+				return QL_STATUS_INVALID_PARAM;
+
+		switch (esw_cfg[i].op_mode) {
+		case QLCNIC_PORT_DEFAULTS:
+			if (qlcnic_82xx_check(adapter)) {
+				ret = QLC_DEV_GET_DRV(op_mode, pci_func);
+			} else {
+				ret = QLC_83XX_GET_FUNC_PRIVILEGE(op_mode,
+								  pci_func);
+				esw_cfg[i].offload_flags = 0;
+			}
+
+			if (ret != QLCNIC_NON_PRIV_FUNC) {
+				if (esw_cfg[i].mac_anti_spoof != 0)
+					return QL_STATUS_INVALID_PARAM;
+				if (esw_cfg[i].mac_override != 1)
+					return QL_STATUS_INVALID_PARAM;
+				if (esw_cfg[i].promisc_mode != 1)
+					return QL_STATUS_INVALID_PARAM;
+			}
+			break;
+		case QLCNIC_ADD_VLAN:
+			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
+				return QL_STATUS_INVALID_PARAM;
+			if (!esw_cfg[i].op_type)
+				return QL_STATUS_INVALID_PARAM;
+			break;
+		case QLCNIC_DEL_VLAN:
+			if (!esw_cfg[i].op_type)
+				return QL_STATUS_INVALID_PARAM;
+			break;
+		default:
+			return QL_STATUS_INVALID_PARAM;
+		}
+	}
+
+	return 0;
+}
+
+static ssize_t qlcnic_sysfs_write_esw_config(struct file *filp,
+					     struct kobject *kobj,
+					     struct bin_attribute *attr,
+					     char *buf, loff_t offset,
+					     size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_func_cfg *esw_cfg;
+	struct qlcnic_npar_info *npar;
+	int count, rem, i, ret;
+	int index;
+	u8 op_mode = 0, pci_func;
+
+	count	= size / sizeof(struct qlcnic_esw_func_cfg);
+	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
+	if (rem)
+		return QL_STATUS_INVALID_PARAM;
+
+	esw_cfg = (struct qlcnic_esw_func_cfg *)buf;
+	ret = validate_esw_config(adapter, esw_cfg, count);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < count; i++) {
+		if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
+			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
+				return QL_STATUS_INVALID_PARAM;
+
+		if (adapter->ahw->pci_func != esw_cfg[i].pci_func)
+			continue;
+
+		op_mode = esw_cfg[i].op_mode;
+		qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]);
+		esw_cfg[i].op_mode = op_mode;
+		esw_cfg[i].pci_func = adapter->ahw->pci_func;
+
+		switch (esw_cfg[i].op_mode) {
+		case QLCNIC_PORT_DEFAULTS:
+			qlcnic_set_eswitch_port_features(adapter, &esw_cfg[i]);
+			break;
+		case QLCNIC_ADD_VLAN:
+			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
+			break;
+		case QLCNIC_DEL_VLAN:
+			esw_cfg[i].vlan_id = 0;
+			qlcnic_set_vlan_config(adapter, &esw_cfg[i]);
+			break;
+		}
+	}
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		goto out;
+
+	for (i = 0; i < count; i++) {
+		pci_func = esw_cfg[i].pci_func;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		npar = &adapter->npars[index];
+		switch (esw_cfg[i].op_mode) {
+		case QLCNIC_PORT_DEFAULTS:
+			npar->promisc_mode = esw_cfg[i].promisc_mode;
+			npar->mac_override = esw_cfg[i].mac_override;
+			npar->offload_flags = esw_cfg[i].offload_flags;
+			npar->mac_anti_spoof = esw_cfg[i].mac_anti_spoof;
+			npar->discard_tagged = esw_cfg[i].discard_tagged;
+			break;
+		case QLCNIC_ADD_VLAN:
+			npar->pvid = esw_cfg[i].vlan_id;
+			break;
+		case QLCNIC_DEL_VLAN:
+			npar->pvid = 0;
+			break;
+		}
+	}
+out:
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_read_esw_config(struct file *filp,
+					    struct kobject *kobj,
+					    struct bin_attribute *attr,
+					    char *buf, loff_t offset,
+					    size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_func_cfg esw_cfg[QLCNIC_MAX_PCI_FUNC];
+	u8 i, pci_func;
+
+	if (size != sizeof(esw_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&esw_cfg, 0,
+	       sizeof(struct qlcnic_esw_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		pci_func = adapter->npars[i].pci_func;
+		esw_cfg[pci_func].pci_func = pci_func;
+		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[pci_func]))
+			return QL_STATUS_INVALID_PARAM;
+	}
+
+	memcpy(buf, &esw_cfg, size);
+
+	return size;
+}
+
+static int validate_npar_config(struct qlcnic_adapter *adapter,
+				struct qlcnic_npar_func_cfg *np_cfg,
+				int count)
+{
+	u8 pci_func, i;
+
+	for (i = 0; i < count; i++) {
+		pci_func = np_cfg[i].pci_func;
+		if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
+				return QL_STATUS_INVALID_PARAM;
+
+		if (!IS_VALID_BW(np_cfg[i].min_bw) ||
+		    !IS_VALID_BW(np_cfg[i].max_bw))
+			return QL_STATUS_INVALID_PARAM;
+	}
+	return 0;
+}
+
+static ssize_t qlcnic_sysfs_write_npar_config(struct file *filp,
+					      struct kobject *kobj,
+					      struct bin_attribute *attr,
+					      char *buf, loff_t offset,
+					      size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_info nic_info;
+	struct qlcnic_npar_func_cfg *np_cfg;
+	int i, count, rem, ret, index;
+	u8 pci_func;
+
+	count = size / sizeof(struct qlcnic_npar_func_cfg);
+	rem = size % sizeof(struct qlcnic_npar_func_cfg);
+	if (rem)
+		return QL_STATUS_INVALID_PARAM;
+
+	np_cfg = (struct qlcnic_npar_func_cfg *)buf;
+	ret = validate_npar_config(adapter, np_cfg, count);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < count; i++) {
+		pci_func = np_cfg[i].pci_func;
+
+		memset(&nic_info, 0, sizeof(struct qlcnic_info));
+		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
+		if (ret)
+			return ret;
+		nic_info.pci_func = pci_func;
+		nic_info.min_tx_bw = np_cfg[i].min_bw;
+		nic_info.max_tx_bw = np_cfg[i].max_bw;
+		ret = qlcnic_set_nic_info(adapter, &nic_info);
+		if (ret)
+			return ret;
+		index = qlcnic_is_valid_nic_func(adapter, pci_func);
+		adapter->npars[index].min_bw = nic_info.min_tx_bw;
+		adapter->npars[index].max_bw = nic_info.max_tx_bw;
+	}
+
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_read_npar_config(struct file *filp,
+					     struct kobject *kobj,
+					     struct bin_attribute *attr,
+					     char *buf, loff_t offset,
+					     size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_info nic_info;
+	struct qlcnic_npar_func_cfg np_cfg[QLCNIC_MAX_PCI_FUNC];
+	int i, ret;
+
+	if (size != sizeof(np_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
+	memset(&np_cfg, 0,
+	       sizeof(struct qlcnic_npar_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		if (qlcnic_is_valid_nic_func(adapter, i) < 0)
+			continue;
+		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
+		if (ret)
+			return ret;
+
+		np_cfg[i].pci_func = i;
+		np_cfg[i].op_mode = (u8)nic_info.op_mode;
+		np_cfg[i].port_num = nic_info.phys_port;
+		np_cfg[i].fw_capab = nic_info.capabilities;
+		np_cfg[i].min_bw = nic_info.min_tx_bw;
+		np_cfg[i].max_bw = nic_info.max_tx_bw;
+		np_cfg[i].max_tx_queues = nic_info.max_tx_ques;
+		np_cfg[i].max_rx_queues = nic_info.max_rx_ques;
+	}
+
+	memcpy(buf, &np_cfg, size);
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_get_port_stats(struct file *file,
+					   struct kobject *kobj,
+					   struct bin_attribute *attr,
+					   char *buf, loff_t offset,
+					   size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_statistics port_stats;
+	int ret;
+
+	if (qlcnic_83xx_check(adapter))
+		return QLC_STATUS_UNSUPPORTED_CMD;
+
+	if (size != sizeof(struct qlcnic_esw_statistics))
+		return QL_STATUS_INVALID_PARAM;
+
+	if (offset >= QLCNIC_MAX_PCI_FUNC)
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&port_stats, 0, size);
+	ret = qlcnic_get_port_stats(adapter, offset, QLCNIC_QUERY_RX_COUNTER,
+				    &port_stats.rx);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_get_port_stats(adapter, offset, QLCNIC_QUERY_TX_COUNTER,
+				    &port_stats.tx);
+	if (ret)
+		return ret;
+
+	memcpy(buf, &port_stats, size);
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_get_esw_stats(struct file *file,
+					  struct kobject *kobj,
+					  struct bin_attribute *attr,
+					  char *buf, loff_t offset,
+					  size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_statistics esw_stats;
+	int ret;
+
+	if (qlcnic_83xx_check(adapter))
+		return QLC_STATUS_UNSUPPORTED_CMD;
+
+	if (size != sizeof(struct qlcnic_esw_statistics))
+		return QL_STATUS_INVALID_PARAM;
+
+	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&esw_stats, 0, size);
+	ret = qlcnic_get_eswitch_stats(adapter, offset, QLCNIC_QUERY_RX_COUNTER,
+				       &esw_stats.rx);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_get_eswitch_stats(adapter, offset, QLCNIC_QUERY_TX_COUNTER,
+				       &esw_stats.tx);
+	if (ret)
+		return ret;
+
+	memcpy(buf, &esw_stats, size);
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_clear_esw_stats(struct file *file,
+					    struct kobject *kobj,
+					    struct bin_attribute *attr,
+					    char *buf, loff_t offset,
+					    size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int ret;
+
+	if (qlcnic_83xx_check(adapter))
+		return QLC_STATUS_UNSUPPORTED_CMD;
+
+	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
+		return QL_STATUS_INVALID_PARAM;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH, offset,
+				     QLCNIC_QUERY_RX_COUNTER);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH, offset,
+				     QLCNIC_QUERY_TX_COUNTER);
+	if (ret)
+		return ret;
+
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_clear_port_stats(struct file *file,
+					     struct kobject *kobj,
+					     struct bin_attribute *attr,
+					     char *buf, loff_t offset,
+					     size_t size)
+{
+
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int ret;
+
+	if (qlcnic_83xx_check(adapter))
+		return QLC_STATUS_UNSUPPORTED_CMD;
+
+	if (offset >= QLCNIC_MAX_PCI_FUNC)
+		return QL_STATUS_INVALID_PARAM;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
+				     QLCNIC_QUERY_RX_COUNTER);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
+				     QLCNIC_QUERY_TX_COUNTER);
+	if (ret)
+		return ret;
+
+	return size;
+}
+
+static ssize_t qlcnic_sysfs_read_pci_config(struct file *filp,
+					    struct kobject *kobj,
+					    struct bin_attribute *attr,
+					    char *buf, loff_t offset,
+					    size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_pci_func_cfg pci_cfg[QLCNIC_MAX_PCI_FUNC];
+	struct qlcnic_pci_info *pci_info;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int i, ret;
+
+	if (size != sizeof(pci_cfg))
+		return QL_STATUS_INVALID_PARAM;
+
+	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
+	if (!pci_info)
+		return -ENOMEM;
+
+	ret = ahw->hw_ops->get_pci_info(adapter, pci_info);
+	if (ret) {
+		kfree(pci_info);
+		return ret;
+	}
+
+	memset(&pci_cfg, 0,
+	       sizeof(struct qlcnic_pci_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		pci_cfg[i].pci_func = pci_info[i].id;
+		pci_cfg[i].func_type = pci_info[i].type;
+		pci_cfg[i].port_num = pci_info[i].default_port;
+		pci_cfg[i].min_bw = pci_info[i].tx_min_bw;
+		pci_cfg[i].max_bw = pci_info[i].tx_max_bw;
+		memcpy(&pci_cfg[i].def_mac_addr, &pci_info[i].mac, ETH_ALEN);
+	}
+
+	memcpy(buf, &pci_cfg, size);
+	kfree(pci_info);
+	return size;
+}
+
+void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
+
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
+static struct device_attribute dev_attr_bridged_mode = {
+	.attr	= {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
+	.show	= qlcnic_show_bridged_mode,
+	.store	= qlcnic_store_bridged_mode,
+};
+
+static struct device_attribute dev_attr_diag_mode = {
+	.attr	= {.name = "diag_mode", .mode = (S_IRUGO | S_IWUSR)},
+	.show	= qlcnic_show_diag_mode,
+	.store	= qlcnic_store_diag_mode,
+};
+
+static struct device_attribute dev_attr_beacon = {
+	.attr	= {.name = "beacon", .mode = (S_IRUGO | S_IWUSR)},
+	.show	= qlcnic_show_beacon,
+	.store	= qlcnic_store_beacon,
+};
+
+static struct bin_attribute bin_attr_crb = {
+	.attr	= {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_read_crb,
+	.write	= qlcnic_sysfs_write_crb,
+};
+
+static struct bin_attribute bin_attr_mem = {
+	.attr	= {.name = "mem", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_read_mem,
+	.write	= qlcnic_sysfs_write_mem,
+};
+
+static struct bin_attribute bin_attr_npar_config = {
+	.attr	= {.name = "npar_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_read_npar_config,
+	.write	= qlcnic_sysfs_write_npar_config,
+};
+
+static struct bin_attribute bin_attr_pci_config = {
+	.attr	= {.name = "pci_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_read_pci_config,
+	.write	= NULL,
+};
+
+static struct bin_attribute bin_attr_port_stats = {
+	.attr	= {.name = "port_stats", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_get_port_stats,
+	.write	= qlcnic_sysfs_clear_port_stats,
+};
+
+static struct bin_attribute bin_attr_esw_stats = {
+	.attr	= {.name = "esw_stats", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_get_esw_stats,
+	.write	= qlcnic_sysfs_clear_esw_stats,
+};
+
+static struct bin_attribute bin_attr_esw_config = {
+	.attr	= {.name = "esw_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_read_esw_config,
+	.write	= qlcnic_sysfs_write_esw_config,
+};
+
+static struct bin_attribute bin_attr_pm_config = {
+	.attr	= {.name = "pm_config", .mode = (S_IRUGO | S_IWUSR)},
+	.size	= 0,
+	.read	= qlcnic_sysfs_read_pm_config,
+	.write	= qlcnic_sysfs_write_pm_config,
+};
+
+void qlcnic_create_sysfs_entries(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	struct net_device *netdev = adapter->netdev;
+
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+		if (device_create_file(dev, &dev_attr_bridged_mode))
+			netdev_err(netdev,
+				   "create bridged_mode sysfs entry err\n");
+}
+
+void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
+		device_remove_file(dev, &dev_attr_bridged_mode);
+}
+
+void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	struct net_device *netdev = adapter->netdev;
+
+	if (device_create_bin_file(dev, &bin_attr_port_stats))
+		netdev_err(netdev, "failed to create port stats sysfs entry");
+
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
+		return;
+	if (device_create_file(dev, &dev_attr_diag_mode))
+		netdev_err(netdev, "failed to create diag_mode sysfs entry\n");
+	if (device_create_bin_file(dev, &bin_attr_crb))
+		netdev_err(netdev, "failed to create crb sysfs entry\n");
+	if (device_create_bin_file(dev, &bin_attr_mem))
+		netdev_err(netdev, "failed to create mem sysfs entry\n");
+
+	if (device_create_bin_file(dev, &bin_attr_pci_config))
+		netdev_err(netdev, "failed to create pci config sysfs entry");
+	if (device_create_file(dev, &dev_attr_beacon))
+		netdev_err(netdev, "failed to create beacon sysfs entry");
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return;
+	if (device_create_bin_file(dev, &bin_attr_esw_config))
+		netdev_err(netdev, "failed to create esw config sysfs entry");
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		return;
+	if (device_create_bin_file(dev, &bin_attr_npar_config))
+		netdev_err(netdev, "failed to create npar config sysfs entry");
+	if (device_create_bin_file(dev, &bin_attr_pm_config))
+		netdev_err(netdev, "failed to create pm config sysfs entry");
+	if (device_create_bin_file(dev, &bin_attr_esw_stats))
+		netdev_err(netdev, "failed to create eswitch stats sysfs entry");
+}
+
+void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+
+	device_remove_bin_file(dev, &bin_attr_port_stats);
+
+	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
+		return;
+	device_remove_file(dev, &dev_attr_diag_mode);
+	device_remove_bin_file(dev, &bin_attr_crb);
+	device_remove_bin_file(dev, &bin_attr_mem);
+	device_remove_bin_file(dev, &bin_attr_pci_config);
+	device_remove_file(dev, &dev_attr_beacon);
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return;
+	device_remove_bin_file(dev, &bin_attr_esw_config);
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		return;
+	device_remove_bin_file(dev, &bin_attr_npar_config);
+	device_remove_bin_file(dev, &bin_attr_pm_config);
+	device_remove_bin_file(dev, &bin_attr_esw_stats);
+}
-- 
1.7.1
