From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/15] net/mlx5: Add MTPPS and MTPPSE registers infrastructure
Date: Fri, 20 Jan 2017 00:38:56 +0200
Message-ID: <20170119223908.15924-4-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59323 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751263AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Implement query and set functionality for MTPPS and MTPPSE registers.
MTPPS (Management Pulse Per Second) provides the device PPS capabilities,
configures the PPS in and out modules and holds the PPS in time stamp.
Query MTPPS is supported only when HCA_CAP.pps is set and modify is supported
when HCA_CAP.pps_modify is set.

MTPPSE (Management Pulse Per Second Event) configures the different event
generation modes for PPS. Supported when HCA_CAP.pps is set.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  9 ++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  5 ++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 48 +++++++++++++++++
 include/linux/mlx5/device.h                        | 18 +++++++
 include/linux/mlx5/driver.h                        |  3 ++
 include/linux/mlx5/mlx5_ifc.h                      | 60 +++++++++++++++++++++-
 6 files changed, 142 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 5130d65dd41a..ea5d8d37a75c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -154,6 +154,8 @@ static const char *eqe_type_str(u8 type)
 		return "MLX5_EVENT_TYPE_PAGE_REQUEST";
 	case MLX5_EVENT_TYPE_PAGE_FAULT:
 		return "MLX5_EVENT_TYPE_PAGE_FAULT";
+	case MLX5_EVENT_TYPE_PPS_EVENT:
+		return "MLX5_EVENT_TYPE_PPS_EVENT";
 	default:
 		return "Unrecognized event";
 	}
@@ -470,6 +472,10 @@ static irqreturn_t mlx5_eq_int(int irq, void *eq_ptr)
 			mlx5_port_module_event(dev, eqe);
 			break;
 
+		case MLX5_EVENT_TYPE_PPS_EVENT:
+			if (dev->event)
+				dev->event(dev, MLX5_DEV_EVENT_PPS, (unsigned long)eqe);
+			break;
 		default:
 			mlx5_core_warn(dev, "Unhandled event 0x%x on EQ 0x%x\n",
 				       eqe->type, eq->eqn);
@@ -684,6 +690,9 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 	else
 		mlx5_core_dbg(dev, "port_module_event is not set\n");
 
+	if (MLX5_CAP_GEN(dev, pps))
+		async_event_mask |= (1ull << MLX5_EVENT_TYPE_PPS_EVENT);
+
 	err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
 				 MLX5_NUM_CMD_EQE, 1ull << MLX5_EVENT_TYPE_CMD,
 				 "mlx5_cmd_eq", MLX5_EQ_TYPE_ASYNC);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 74241e82de63..090e3a1dedc2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -138,6 +138,11 @@ void mlx5_encap_dealloc(struct mlx5_core_dev *dev, u32 encap_id);
 
 bool mlx5_lag_intf_add(struct mlx5_interface *intf, struct mlx5_priv *priv);
 
+int mlx5_query_mtpps(struct mlx5_core_dev *dev, u32 *mtpps, u32 mtpps_size);
+int mlx5_set_mtpps(struct mlx5_core_dev *mdev, u32 *mtpps, u32 mtpps_size);
+int mlx5_query_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 *arm, u8 *mode);
+int mlx5_set_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 arm, u8 mode);
+
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index d2ec9d232a70..5ea85336b2e4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -866,3 +866,51 @@ void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe)
 			       module_num, mlx5_pme_status[module_status - 1],
 			       mlx5_pme_error[error_type]);
 }
+
+int mlx5_query_mtpps(struct mlx5_core_dev *mdev, u32 *mtpps, u32 mtpps_size)
+{
+	u32 in[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+
+	return mlx5_core_access_reg(mdev, in, sizeof(in), mtpps,
+				    mtpps_size, MLX5_REG_MTPPS, 0, 0);
+}
+
+int mlx5_set_mtpps(struct mlx5_core_dev *mdev, u32 *mtpps, u32 mtpps_size)
+{
+	u32 out[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+
+	return mlx5_core_access_reg(mdev, mtpps, mtpps_size, out,
+				    sizeof(out), MLX5_REG_MTPPS, 0, 1);
+}
+
+int mlx5_query_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 *arm, u8 *mode)
+{
+	u32 out[MLX5_ST_SZ_DW(mtppse_reg)] = {0};
+	u32 in[MLX5_ST_SZ_DW(mtppse_reg)] = {0};
+	int err = 0;
+
+	MLX5_SET(mtppse_reg, in, pin, pin);
+
+	err = mlx5_core_access_reg(mdev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_MTPPSE, 0, 0);
+	if (err)
+		return err;
+
+	*arm = MLX5_GET(mtppse_reg, in, event_arm);
+	*mode = MLX5_GET(mtppse_reg, in, event_generation_mode);
+
+	return err;
+}
+
+int mlx5_set_mtppse(struct mlx5_core_dev *mdev, u8 pin, u8 arm, u8 mode)
+{
+	u32 out[MLX5_ST_SZ_DW(mtppse_reg)] = {0};
+	u32 in[MLX5_ST_SZ_DW(mtppse_reg)] = {0};
+
+	MLX5_SET(mtppse_reg, in, pin, pin);
+	MLX5_SET(mtppse_reg, in, event_arm, arm);
+	MLX5_SET(mtppse_reg, in, event_generation_mode, mode);
+
+	return mlx5_core_access_reg(mdev, in, sizeof(in), out,
+				    sizeof(out), MLX5_REG_MTPPSE, 0, 1);
+}
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 7c5265db02a9..6ac8eb5a89ca 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -289,6 +289,7 @@ enum mlx5_event {
 	MLX5_EVENT_TYPE_GPIO_EVENT	   = 0x15,
 	MLX5_EVENT_TYPE_PORT_MODULE_EVENT  = 0x16,
 	MLX5_EVENT_TYPE_REMOTE_CONFIG	   = 0x19,
+	MLX5_EVENT_TYPE_PPS_EVENT          = 0x25,
 
 	MLX5_EVENT_TYPE_DB_BF_CONGESTION   = 0x1a,
 	MLX5_EVENT_TYPE_STALL_EVENT	   = 0x1b,
@@ -569,6 +570,22 @@ struct mlx5_eqe_port_module {
 	u8        error_type;
 } __packed;
 
+struct mlx5_eqe_pps {
+	u8		rsvd0[3];
+	u8		pin;
+	u8		rsvd1[4];
+	union {
+		struct {
+			__be32		time_sec;
+			__be32		time_nsec;
+		};
+		struct {
+			__be64		time_stamp;
+		};
+	};
+	u8		rsvd2[12];
+} __packed;
+
 union ev_data {
 	__be32				raw[7];
 	struct mlx5_eqe_cmd		cmd;
@@ -583,6 +600,7 @@ union ev_data {
 	struct mlx5_eqe_page_fault	page_fault;
 	struct mlx5_eqe_vport_change	vport_change;
 	struct mlx5_eqe_port_module	port_module;
+	struct mlx5_eqe_pps		pps;
 } __packed;
 
 struct mlx5_eqe {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 3a309f6a4a15..ebbc8834063b 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -125,6 +125,8 @@ enum {
 	MLX5_REG_HOST_ENDIANNESS = 0x7004,
 	MLX5_REG_MCIA		 = 0x9014,
 	MLX5_REG_MLCR		 = 0x902b,
+	MLX5_REG_MTPPS		 = 0x9053,
+	MLX5_REG_MTPPSE		 = 0x9054,
 };
 
 enum mlx5_dcbx_oper_mode {
@@ -172,6 +174,7 @@ enum mlx5_dev_event {
 	MLX5_DEV_EVENT_PKEY_CHANGE,
 	MLX5_DEV_EVENT_GUID_CHANGE,
 	MLX5_DEV_EVENT_CLIENT_REREG,
+	MLX5_DEV_EVENT_PPS,
 };
 
 enum mlx5_port_status {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 37327f6ba9cb..f5292f3b0301 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -835,7 +835,9 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         port_type[0x2];
 	u8         num_ports[0x8];
 
-	u8         reserved_at_1c0[0x3];
+	u8         reserved_at_1c0[0x1];
+	u8         pps[0x1];
+	u8         pps_modify[0x1];
 	u8         log_max_msg[0x5];
 	u8         reserved_at_1c8[0x4];
 	u8         max_tc[0x4];
@@ -7821,6 +7823,60 @@ struct mlx5_ifc_initial_seg_bits {
 	u8         reserved_at_80a0[0x17fc0];
 };
 
+struct mlx5_ifc_mtpps_reg_bits {
+	u8         reserved_at_0[0xc];
+	u8         cap_number_of_pps_pins[0x4];
+	u8         reserved_at_10[0x4];
+	u8         cap_max_num_of_pps_in_pins[0x4];
+	u8         reserved_at_18[0x4];
+	u8         cap_max_num_of_pps_out_pins[0x4];
+
+	u8         reserved_at_20[0x24];
+	u8         cap_pin_3_mode[0x4];
+	u8         reserved_at_48[0x4];
+	u8         cap_pin_2_mode[0x4];
+	u8         reserved_at_50[0x4];
+	u8         cap_pin_1_mode[0x4];
+	u8         reserved_at_58[0x4];
+	u8         cap_pin_0_mode[0x4];
+
+	u8         reserved_at_60[0x4];
+	u8         cap_pin_7_mode[0x4];
+	u8         reserved_at_68[0x4];
+	u8         cap_pin_6_mode[0x4];
+	u8         reserved_at_70[0x4];
+	u8         cap_pin_5_mode[0x4];
+	u8         reserved_at_78[0x4];
+	u8         cap_pin_4_mode[0x4];
+
+	u8         reserved_at_80[0x80];
+
+	u8         enable[0x1];
+	u8         reserved_at_101[0xb];
+	u8         pattern[0x4];
+	u8         reserved_at_110[0x4];
+	u8         pin_mode[0x4];
+	u8         pin[0x8];
+
+	u8         reserved_at_120[0x20];
+
+	u8         time_stamp[0x40];
+
+	u8         out_pulse_duration[0x10];
+	u8         out_periodic_adjustment[0x10];
+
+	u8         reserved_at_1a0[0x60];
+};
+
+struct mlx5_ifc_mtppse_reg_bits {
+	u8         reserved_at_0[0x18];
+	u8         pin[0x8];
+	u8         event_arm[0x1];
+	u8         reserved_at_21[0x1b];
+	u8         event_generation_mode[0x4];
+	u8         reserved_at_40[0x40];
+};
+
 union mlx5_ifc_ports_control_registers_document_bits {
 	struct mlx5_ifc_bufferx_reg_bits bufferx_reg;
 	struct mlx5_ifc_eth_2819_cntrs_grp_data_layout_bits eth_2819_cntrs_grp_data_layout;
@@ -7865,6 +7921,8 @@ union mlx5_ifc_ports_control_registers_document_bits {
 	struct mlx5_ifc_pvlc_reg_bits pvlc_reg;
 	struct mlx5_ifc_slrg_reg_bits slrg_reg;
 	struct mlx5_ifc_sltp_reg_bits sltp_reg;
+	struct mlx5_ifc_mtpps_reg_bits mtpps_reg;
+	struct mlx5_ifc_mtppse_reg_bits mtppse_reg;
 	u8         reserved_at_0[0x60e0];
 };
 
-- 
2.11.0
