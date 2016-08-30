From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/6] net/mlx5: Add handling for port module event
Date: Tue, 30 Aug 2016 14:29:55 +0300
Message-ID: <1472556595-9286-7-git-send-email-saeedm@mellanox.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56723 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758293AbcH3Laf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 07:30:35 -0400
In-Reply-To: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Add dmesg log for asynchronous port module event.

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       | 12 +++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 85 ++++++++++++++++++++++
 include/linux/mlx5/device.h                        | 11 +++
 include/linux/mlx5/mlx5_ifc.h                      |  3 +-
 5 files changed, 111 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index aaca090..d775fea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -139,6 +139,8 @@ static const char *eqe_type_str(u8 type)
 		return "MLX5_EVENT_TYPE_PORT_CHANGE";
 	case MLX5_EVENT_TYPE_GPIO_EVENT:
 		return "MLX5_EVENT_TYPE_GPIO_EVENT";
+	case MLX5_EVENT_TYPE_PORT_MODULE_EVENT:
+		return "MLX5_EVENT_TYPE_PORT_MODULE_EVENT";
 	case MLX5_EVENT_TYPE_REMOTE_CONFIG:
 		return "MLX5_EVENT_TYPE_REMOTE_CONFIG";
 	case MLX5_EVENT_TYPE_DB_BF_CONGESTION:
@@ -285,6 +287,11 @@ static int mlx5_eq_int(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 			mlx5_eswitch_vport_event(dev->priv.eswitch, eqe);
 			break;
 #endif
+
+		case MLX5_EVENT_TYPE_PORT_MODULE_EVENT:
+			mlx5_port_module_event(dev, eqe);
+			break;
+
 		default:
 			mlx5_core_warn(dev, "Unhandled event 0x%x on EQ 0x%x\n",
 				       eqe->type, eq->eqn);
@@ -480,6 +487,11 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 	    mlx5_core_is_pf(dev))
 		async_event_mask |= (1ull << MLX5_EVENT_TYPE_NIC_VPORT_CHANGE);
 
+	if (MLX5_CAP_GEN(dev, port_module_event))
+		async_event_mask |= (1ull << MLX5_EVENT_TYPE_PORT_MODULE_EVENT);
+	else
+		mlx5_core_dbg(dev, "port_module_event is not set\n");
+
 	err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
 				 MLX5_NUM_CMD_EQE, 1ull << MLX5_EVENT_TYPE_CMD,
 				 "mlx5_cmd_eq", &dev->priv.uuari.uars[0]);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 714b71b..d023d05 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -87,6 +87,7 @@ int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
 void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param);
+void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe);
 void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
 int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 8a66595..e5f62bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -36,6 +36,25 @@
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 
+#define PORT_MODULE_EVENT_MODULE_STATUS_MASK 0xF
+#define PORT_MODULE_EVENT_ERROR_TYPE_MASK         0xF
+enum {
+	MLX5_MODULE_STATUS_PLUGGED  = 0x1,
+	MLX5_MODULE_STATUS_UNPLUGGED  = 0x2,
+	MLX5_MODULE_STATUS_ERROR  = 0x3,
+};
+
+enum {
+	MLX5_MODULE_EVENT_ERROR_POWER_BUDGET_EXCEEDED  = 0x0,
+	MLX5_MODULE_EVENT_ERROR_LONG_RANGE_FOR_NON_MLNX_CABLE_MODULE  = 0x1,
+	MLX5_MODULE_EVENT_ERROR_BUS_STUCK  = 0x2,
+	MLX5_MODULE_EVENT_ERROR_NO_EEPROM_RETRY_TIMEOUT  = 0x3,
+	MLX5_MODULE_EVENT_ERROR_ENFORCE_PART_NUMBER_LIST  = 0x4,
+	MLX5_MODULE_EVENT_ERROR_UNKNOWN_IDENTIFIER  = 0x5,
+	MLX5_MODULE_EVENT_ERROR_HIGH_TEMPERATURE  = 0x6,
+	MLX5_MODULE_EVENT_ERROR_BAD_CABLE = 0x7,
+};
+
 int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 			 int size_in, void *data_out, int size_out,
 			 u16 reg_id, int arg, int write)
@@ -811,3 +830,69 @@ void mlx5_query_port_fcs(struct mlx5_core_dev *mdev, bool *supported,
 	*supported = !!(MLX5_GET(pcmr_reg, out, fcs_cap));
 	*enabled = !!(MLX5_GET(pcmr_reg, out, fcs_chk));
 }
+
+static const char *mlx5_port_event_error_type_to_string(u8 error_type)
+{
+	switch (error_type) {
+	case MLX5_MODULE_EVENT_ERROR_POWER_BUDGET_EXCEEDED:
+		return "Power Budget Exceeded";
+
+	case MLX5_MODULE_EVENT_ERROR_LONG_RANGE_FOR_NON_MLNX_CABLE_MODULE:
+		return "Long Range for non MLNX cable/module";
+
+	case MLX5_MODULE_EVENT_ERROR_BUS_STUCK:
+		return "Bus stuck(I2C or data shorted)";
+
+	case MLX5_MODULE_EVENT_ERROR_NO_EEPROM_RETRY_TIMEOUT:
+		return "No EEPROM/retry timeout";
+
+	case MLX5_MODULE_EVENT_ERROR_ENFORCE_PART_NUMBER_LIST:
+		return "Enforce part number list";
+
+	case MLX5_MODULE_EVENT_ERROR_UNKNOWN_IDENTIFIER:
+		return "Unknown identifier";
+
+	case MLX5_MODULE_EVENT_ERROR_HIGH_TEMPERATURE:
+		return "High Temperature";
+
+	case MLX5_MODULE_EVENT_ERROR_BAD_CABLE:
+		return "Bad cable (module/cable is shorted)";
+
+	default:
+		return "Unknown error type";
+	}
+}
+
+void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe)
+{
+	struct mlx5_eqe_port_module *module_event_eqe;
+	u8 module_status;
+	u8 module_num;
+	u8 error_type;
+
+	module_event_eqe = &eqe->data.port_module;
+	module_num = module_event_eqe->module;
+	module_status = module_event_eqe->module_status &
+			PORT_MODULE_EVENT_MODULE_STATUS_MASK;
+	error_type = module_event_eqe->error_type &
+		     PORT_MODULE_EVENT_ERROR_TYPE_MASK;
+
+	switch (module_status) {
+	case MLX5_MODULE_STATUS_PLUGGED:
+		mlx5_core_info(dev, "Module %u, status: plugged", module_num);
+		break;
+
+	case MLX5_MODULE_STATUS_UNPLUGGED:
+		mlx5_core_info(dev, "Module %u, status: unplugged", module_num);
+		break;
+
+	case MLX5_MODULE_STATUS_ERROR:
+		mlx5_core_info(dev, "Module %u, status: error, %s", module_num,
+			       mlx5_port_event_error_type_to_string(error_type));
+		break;
+
+	default:
+		mlx5_core_info(dev, "Module %u, unknown module status %x",
+			       module_num, module_status);
+	}
+}
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 77c1417..3020b7f 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -268,6 +268,7 @@ enum mlx5_event {
 	MLX5_EVENT_TYPE_INTERNAL_ERROR	   = 0x08,
 	MLX5_EVENT_TYPE_PORT_CHANGE	   = 0x09,
 	MLX5_EVENT_TYPE_GPIO_EVENT	   = 0x15,
+	MLX5_EVENT_TYPE_PORT_MODULE_EVENT  = 0x16,
 	MLX5_EVENT_TYPE_REMOTE_CONFIG	   = 0x19,
 
 	MLX5_EVENT_TYPE_DB_BF_CONGESTION   = 0x1a,
@@ -543,6 +544,15 @@ struct mlx5_eqe_vport_change {
 	__be32		rsvd1[6];
 } __packed;
 
+struct mlx5_eqe_port_module {
+	u8        rsvd0[1];
+	u8        module;
+	u8        rsvd1[1];
+	u8        module_status;
+	u8        rsvd2[2];
+	u8        error_type;
+};
+
 union ev_data {
 	__be32				raw[7];
 	struct mlx5_eqe_cmd		cmd;
@@ -556,6 +566,7 @@ union ev_data {
 	struct mlx5_eqe_page_req	req_pages;
 	struct mlx5_eqe_page_fault	page_fault;
 	struct mlx5_eqe_vport_change	vport_change;
+	struct mlx5_eqe_port_module	port_module;
 } __packed;
 
 struct mlx5_eqe {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 73a720f..57eaee3 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -804,7 +804,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8	   early_vf_enable[0x1];
 	u8         reserved_at_1a9[0x2];
 	u8         local_ca_ack_delay[0x5];
-	u8         reserved_at_1af[0x2];
+	u8         port_module_event[0x1];
+	u8         reserved_at_1b0[0x1];
 	u8         ports_check[0x1];
 	u8         reserved_at_1b2[0x1];
 	u8         disable_link_up[0x1];
-- 
2.7.4
