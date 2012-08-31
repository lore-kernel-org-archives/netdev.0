From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 09/12] qlcnic: enable 83xx virtual NIC mode
Date: Fri, 31 Aug 2012 02:28:58 -0400
Message-ID: <1346394541-3486-10-git-send-email-sony.chacko@qlogic.com>
References: <1346394541-3486-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47137 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751671Ab2HaGp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 02:45:59 -0400
In-Reply-To: <1346394541-3486-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Enable 83xx virtual NIC  mode

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    3 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |  261 ++++++++++++++++++++
 4 files changed, 270 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index 47ae1f8..8de2dc7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -6,4 +6,5 @@ obj-$(CONFIG_QLCNIC) := qlcnic.o
 
 qlcnic-y := qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
 	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o \
-	qlcnic_83xx_hw.o qlcnic_83xx_init.o
+	qlcnic_83xx_hw.o qlcnic_83xx_init.o \
+	qlcnic_83xx_vnic.o
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 0621698..170e0da 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1664,6 +1664,10 @@ int qlcnic_process_cmd_ring(struct qlcnic_adapter *,
 				struct qlcnic_host_tx_ring *, int);
 void qlcnic_advert_link_change(struct qlcnic_adapter *, int);
 void dump_skb(struct sk_buff *, struct qlcnic_adapter *);
+int qlcnic_init_pci_info(struct qlcnic_adapter *);
+int qlcnic_set_default_offload_settings(struct qlcnic_adapter *);
+int qlcnic_reset_npar_config(struct qlcnic_adapter *);
+
 
 
 extern int qlcnic_config_tso;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index ac3721c..d7031f8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -826,6 +826,8 @@ qlcnic_83xx_idc_need_reset_state_handler(struct qlcnic_adapter *adapter)
 		qlcnic_83xx_idc_update_audit_reg(adapter, 0, 1);
 		set_bit(__QLCNIC_RESETTING, &adapter->state);
 		clear_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status);
+		if (adapter->ahw->nic_mode == QLC_83XX_VIRTUAL_NIC_MODE)
+			qlcnic_83xx_disable_vnic_mode(adapter, 1);
 
 		qlcnic_83xx_idc_detach_driver(adapter);
 	}
@@ -1871,6 +1873,7 @@ qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter)
 		return -EIO;
 
 	if (ret == QLC_83XX_VIRTUAL_NIC_MODE) {
+		if (qlcnic_83xx_config_vnic_opmode(adapter))
 			return -EIO;
 	} else if (ret == QLC_83XX_DEFAULT_MODE) {
 		if (qlcnic_83xx_config_default_opmode(adapter))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
new file mode 100644
index 0000000..ab843d8
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -0,0 +1,261 @@
+#include "qlcnic.h"
+#include "qlcnic_hw.h"
+
+int
+qlcnic_83xx_enable_vnic_mode(struct qlcnic_adapter *adapter, int lock)
+{
+	if (lock) {
+		if (qlcnic_83xx_lock_driver(adapter))
+			return -EBUSY;
+	}
+	QLCWRX(adapter->ahw, QLC_83XX_VNIC_STATE, QLCNIC_DEV_NPAR_OPER);
+	if (lock)
+		qlcnic_83xx_unlock_driver(adapter);
+
+	return 0;
+}
+
+int
+qlcnic_83xx_disable_vnic_mode(struct qlcnic_adapter *adapter, int lock)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	if (lock) {
+		if (qlcnic_83xx_lock_driver(adapter))
+			return -EBUSY;
+	}
+
+	QLCWRX(adapter->ahw, QLC_83XX_VNIC_STATE, QLCNIC_DEV_NPAR_NON_OPER);
+	ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
+
+	if (lock)
+		qlcnic_83xx_unlock_driver(adapter);
+
+	return 0;
+}
+
+/**
+ * qlcnic_83xx_set_vnic_opmode
+ *
+ * @adapter: adapter structure
+ *
+ * Returns:
+ *
+ **/
+static int
+qlcnic_83xx_set_vnic_opmode(struct qlcnic_adapter *adapter)
+{
+	u8 id;
+	int i, ret = -EBUSY;
+	u32 data = QLCNIC_MGMT_FUNC;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	if (qlcnic_83xx_lock_driver(adapter))
+		return ret;
+
+	if (qlcnic_config_npars) {
+		for (i = 0; i < ahw->act_pci_func; i++) {
+			id = adapter->npars[i].pci_func;
+			if (id == ahw->pci_func)
+				continue;
+			data |= (qlcnic_config_npars &
+					QLC_83XX_SET_FUNC_OPMODE(0x3, id));
+		}
+	} else {
+		data = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
+		data = (data & ~QLC_83XX_SET_FUNC_OPMODE(0x3, ahw->pci_func)) |
+			(QLC_83XX_SET_FUNC_OPMODE(QLCNIC_MGMT_FUNC,
+			ahw->pci_func));
+	}
+	QLCWRX(adapter->ahw, QLC_83XX_DRV_OP_MODE, data);
+
+	qlcnic_83xx_unlock_driver(adapter);
+
+	return 0;
+}
+
+/**
+ * qlcnic_83xx_config_vnic_buff_descriptors
+ *
+ * @adapter: adapter structure
+ *
+ * Returns:
+ *
+ **/
+static inline void
+qlcnic_83xx_config_vnic_buff_descriptors(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	if (ahw->port_type == QLCNIC_XGBE) {
+		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_VF;
+		adapter->max_rxd = MAX_RCV_DESCRIPTORS_VF;
+		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+
+	} else if (ahw->port_type == QLCNIC_GBE) {
+		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_1G;
+		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+		adapter->max_rxd = MAX_RCV_DESCRIPTORS_1G;
+	}
+	adapter->num_txd = MAX_CMD_DESCRIPTORS;
+	adapter->max_rds_rings = MAX_RDS_RINGS;
+}
+
+
+/**
+ * qlcnic_83xx_init_mgmt_vnic
+ *
+ * @adapter: adapter structure
+ * Management vNIC sets the operational mode of other vNIC's and
+ * configures embedded switch (ESWITCH).
+ * Returns:
+ *
+ **/
+static int
+qlcnic_83xx_init_mgmt_vnic(struct qlcnic_adapter *adapter)
+{
+	int err = -EIO;
+
+	if (!(adapter->flags & QLCNIC_ADAPTER_INITIALIZED)) {
+		if (qlcnic_init_pci_info(adapter))
+			return err;
+
+		if (qlcnic_83xx_set_vnic_opmode(adapter))
+			return err;
+
+		if (qlcnic_set_default_offload_settings(adapter))
+			return err;
+	} else {
+		if (qlcnic_reset_npar_config(adapter))
+			return err;
+	}
+
+	if (qlcnic_83xx_get_port_info(adapter))
+		return err;
+
+	qlcnic_83xx_config_vnic_buff_descriptors(adapter);
+	adapter->ahw->msix_supported = !!use_msi_x;
+	adapter->flags |= QLCNIC_ADAPTER_INITIALIZED;
+	qlcnic_83xx_enable_vnic_mode(adapter, 1);
+
+	dev_info(&adapter->pdev->dev, "HAL Version: %d, Management function\n",
+			adapter->ahw->fw_hal_version);
+
+	return 0;
+}
+
+/**
+ * qlcnic_83xx_init_privileged_vnic
+ *
+ * @adapter: adapter structure
+ *
+ * Returns:
+ *
+ **/
+static int
+qlcnic_83xx_init_privileged_vnic(struct qlcnic_adapter *adapter)
+{
+	int err = -EIO;
+
+	if (qlcnic_83xx_get_port_info(adapter))
+		return err;
+
+	qlcnic_83xx_config_vnic_buff_descriptors(adapter);
+	adapter->ahw->msix_supported = !!use_msi_x;
+	adapter->flags |= QLCNIC_ADAPTER_INITIALIZED;
+
+	dev_info(&adapter->pdev->dev,
+			"HAL Version: %d, Privileged function\n",
+			adapter->ahw->fw_hal_version);
+	return 0;
+}
+
+/**
+ * qlcnic_83xx_init_non_privileged_vnic
+ *
+ * @adapter: adapter structure
+ *
+ * Returns:
+ *
+ **/
+static int
+qlcnic_83xx_init_non_privileged_vnic(struct qlcnic_adapter *adapter)
+{
+	int err = -EIO;
+
+	qlcnic_83xx_get_fw_version(adapter);
+	if (qlcnic_set_eswitch_port_config(adapter))
+		return err;
+
+	if (qlcnic_83xx_get_port_info(adapter))
+		return err;
+
+	qlcnic_83xx_config_vnic_buff_descriptors(adapter);
+	adapter->ahw->msix_supported = !!use_msi_x;
+	adapter->flags |= QLCNIC_ADAPTER_INITIALIZED;
+
+	dev_info(&adapter->pdev->dev, "HAL Version: %d, Virtual function\n",
+				adapter->ahw->fw_hal_version);
+
+	return 0;
+}
+
+/**
+ * qlcnic_83xx_vnic_opmode
+ *
+ * @adapter: adapter structure
+ * Identify virtual NIC operational modes.
+ *
+ * Returns:
+ *
+ **/
+int
+qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *adapter)
+{
+	u32 op_mode, priv_level;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	ahw->hw_ops->get_func_no(adapter);
+
+	op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
+
+	if (op_mode == QLC_83XX_DEFAULT_OPMODE)
+		priv_level = QLCNIC_MGMT_FUNC;
+	else
+		priv_level = QLC_83XX_GET_FUNC_PRIVILEGE_LEVEL(op_mode,
+							ahw->pci_func);
+
+	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
+		ahw->op_mode = QLCNIC_NON_PRIV_FUNC;
+		adapter->ahw->idc.ready_state_entry_action =
+			qlcnic_83xx_idc_ready_state_entry_action;
+		adapter->nic_ops->init_driver =
+				qlcnic_83xx_init_non_privileged_vnic;
+	} else if (priv_level == QLCNIC_PRIV_FUNC) {
+		ahw->op_mode = QLCNIC_PRIV_FUNC;
+		adapter->ahw->idc.ready_state_entry_action =
+			qlcnic_83xx_idc_vnic_pf_ready_state_entry_action;
+		adapter->nic_ops->init_driver =
+				qlcnic_83xx_init_privileged_vnic;
+	} else if (priv_level == QLCNIC_MGMT_FUNC) {
+		ahw->op_mode = QLCNIC_MGMT_FUNC;
+		adapter->ahw->idc.ready_state_entry_action =
+			qlcnic_83xx_idc_ready_state_entry_action;
+		adapter->nic_ops->init_driver =
+				qlcnic_83xx_init_mgmt_vnic;
+	} else {
+		return -EIO;
+	}
+
+	if (ahw->capabilities & BIT_23)
+		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
+	else
+		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+
+	adapter->ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
+	adapter->ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
+
+	return 0;
+}
-- 
1.7.1
