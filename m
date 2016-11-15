From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx5: Add handling for port module event
Date: Tue, 15 Nov 2016 23:30:02 +0200
Message-ID: <1479245407-6884-4-git-send-email-saeedm@mellanox.com>
References: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54811 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752194AbcKOVae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:30:34 -0500
In-Reply-To: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

For each asynchronous port module event:
  1. print with ratelimit to the dmesg log
  2. increment the corresponding event counter

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       | 12 +++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 57 ++++++++++++++++++++++
 include/linux/mlx5/driver.h                        | 27 ++++++++++
 4 files changed, 97 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index e74a73b..8ffcc88 100644
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
index 4762bb9..7e635eb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -81,6 +81,7 @@ int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
 void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param);
+void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe);
 void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
 void mlx5_recover_device(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 34e7184..b77928f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -746,3 +746,60 @@ void mlx5_query_port_fcs(struct mlx5_core_dev *mdev, bool *supported,
 	*supported = !!(MLX5_GET(pcmr_reg, out, fcs_cap));
 	*enabled = !!(MLX5_GET(pcmr_reg, out, fcs_chk));
 }
+
+static const char *mlx5_pme_status[MLX5_MODULE_STATUS_NUM] = {
+	"Cable plugged",   /* MLX5_MODULE_STATUS_PLUGGED    = 0x1 */
+	"Cable unplugged", /* MLX5_MODULE_STATUS_UNPLUGGED  = 0x2 */
+	"Cable error",     /* MLX5_MODULE_STATUS_ERROR      = 0x3 */
+};
+
+static const char *mlx5_pme_error[MLX5_MODULE_EVENT_ERROR_NUM] = {
+	"Power budget exceeded",
+	"Long Range for non MLNX cable",
+	"Bus stuck(I2C or data shorted)",
+	"No EEPROM/retry timeout",
+	"Enforce part number list",
+	"Unknown identifier",
+	"High Temperature",
+	"Bad or shorted cable/module",
+	"Unknown status",
+};
+
+void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe)
+{
+	enum port_module_event_status_type module_status;
+	enum port_module_event_error_type error_type;
+	struct mlx5_eqe_port_module *module_event_eqe;
+	struct mlx5_priv *priv = &dev->priv;
+	u8 module_num;
+
+	module_event_eqe = &eqe->data.port_module;
+	module_num = module_event_eqe->module;
+	module_status = module_event_eqe->module_status &
+			PORT_MODULE_EVENT_MODULE_STATUS_MASK;
+	error_type = module_event_eqe->error_type &
+		     PORT_MODULE_EVENT_ERROR_TYPE_MASK;
+
+	if (module_status < MLX5_MODULE_STATUS_ERROR) {
+		priv->pme_stats.status_counters[module_status - 1]++;
+	} else if (module_status == MLX5_MODULE_STATUS_ERROR) {
+		if (error_type >= MLX5_MODULE_EVENT_ERROR_UNKNOWN)
+			/* Unknown error type */
+			error_type = MLX5_MODULE_EVENT_ERROR_UNKNOWN;
+		priv->pme_stats.error_counters[error_type]++;
+	}
+
+	if (!printk_ratelimit())
+		return;
+
+	if (module_status < MLX5_MODULE_STATUS_ERROR)
+		mlx5_core_info(dev,
+			       "Port module event: module %u, %s\n",
+			       module_num, mlx5_pme_status[module_status - 1]);
+
+	else if (module_status == MLX5_MODULE_STATUS_ERROR)
+		mlx5_core_info(dev,
+			       "Port module event[error]: module %u, %s, %s\n",
+			       module_num, mlx5_pme_status[module_status - 1],
+			       mlx5_pme_error[error_type]);
+}
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 1eb08d3..243b538 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -498,6 +498,31 @@ struct mlx5_rl_table {
 	struct mlx5_rl_entry   *rl_entry;
 };
 
+enum port_module_event_status_type {
+	MLX5_MODULE_STATUS_PLUGGED   = 0x1,
+	MLX5_MODULE_STATUS_UNPLUGGED = 0x2,
+	MLX5_MODULE_STATUS_ERROR     = 0x3,
+	MLX5_MODULE_STATUS_NUM       = 0x3,
+};
+
+enum  port_module_event_error_type {
+	MLX5_MODULE_EVENT_ERROR_POWER_BUDGET_EXCEEDED,
+	MLX5_MODULE_EVENT_ERROR_LONG_RANGE_FOR_NON_MLNX_CABLE_MODULE,
+	MLX5_MODULE_EVENT_ERROR_BUS_STUCK,
+	MLX5_MODULE_EVENT_ERROR_NO_EEPROM_RETRY_TIMEOUT,
+	MLX5_MODULE_EVENT_ERROR_ENFORCE_PART_NUMBER_LIST,
+	MLX5_MODULE_EVENT_ERROR_UNKNOWN_IDENTIFIER,
+	MLX5_MODULE_EVENT_ERROR_HIGH_TEMPERATURE,
+	MLX5_MODULE_EVENT_ERROR_BAD_CABLE,
+	MLX5_MODULE_EVENT_ERROR_UNKNOWN,
+	MLX5_MODULE_EVENT_ERROR_NUM,
+};
+
+struct mlx5_port_module_event_stats {
+	u64 status_counters[MLX5_MODULE_STATUS_NUM];
+	u64 error_counters[MLX5_MODULE_EVENT_ERROR_NUM];
+};
+
 struct mlx5_priv {
 	char			name[MLX5_MAX_NAME_LEN];
 	struct mlx5_eq_table	eq_table;
@@ -559,6 +584,8 @@ struct mlx5_priv {
 	unsigned long		pci_dev_data;
 	struct mlx5_fc_stats		fc_stats;
 	struct mlx5_rl_table            rl_table;
+
+	struct mlx5_port_module_event_stats  pme_stats;
 };
 
 enum mlx5_device_state {
-- 
2.7.4
