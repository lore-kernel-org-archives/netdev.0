From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 09/14] net/mlx5: MTPPS (Pulse-per-second) events and registers support
Date: Tue, 25 Oct 2016 18:00:12 +0300
Message-ID: <1477407617-20745-10-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37485 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757031AbcJYPFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:05:44 -0400
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Add Pulse-per-second events and MTPPS/MTPPSE registers all relevant
hardware data structures.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 include/linux/mlx5/device.h   | 18 +++++++++++++
 include/linux/mlx5/driver.h   |  3 +++
 include/linux/mlx5/mlx5_ifc.h | 60 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 80 insertions(+), 1 deletion(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index a915a15..6be3700 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -278,6 +278,7 @@ enum mlx5_event {
 	MLX5_EVENT_TYPE_PORT_CHANGE	   = 0x09,
 	MLX5_EVENT_TYPE_GPIO_EVENT	   = 0x15,
 	MLX5_EVENT_TYPE_REMOTE_CONFIG	   = 0x19,
+	MLX5_EVENT_TYPE_PPS_EVENT          = 0x25,
 
 	MLX5_EVENT_TYPE_DB_BF_CONGESTION   = 0x1a,
 	MLX5_EVENT_TYPE_STALL_EVENT	   = 0x1b,
@@ -552,6 +553,22 @@ struct mlx5_eqe_vport_change {
 	__be32		rsvd1[6];
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
@@ -565,6 +582,7 @@ union ev_data {
 	struct mlx5_eqe_page_req	req_pages;
 	struct mlx5_eqe_page_fault	page_fault;
 	struct mlx5_eqe_vport_change	vport_change;
+	struct mlx5_eqe_pps		pps;
 } __packed;
 
 struct mlx5_eqe {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 982c1ce..099c94e 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -122,6 +122,8 @@ enum {
 	MLX5_REG_MCIA		 = 0x9014,
 	MLX5_REG_MLCR		 = 0x902b,
 	MLX5_REG_MPCNT		 = 0x9051,
+	MLX5_REG_MTPPS		 = 0x9053,
+	MLX5_REG_MTPPSE		 = 0x9054,
 };
 
 enum {
@@ -164,6 +166,7 @@ enum mlx5_dev_event {
 	MLX5_DEV_EVENT_PKEY_CHANGE,
 	MLX5_DEV_EVENT_GUID_CHANGE,
 	MLX5_DEV_EVENT_CLIENT_REREG,
+	MLX5_DEV_EVENT_PPS,
 };
 
 enum mlx5_port_status {
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 9cfb688..5289b27 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -813,7 +813,9 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         port_type[0x2];
 	u8         num_ports[0x8];
 
-	u8         reserved_at_1c0[0x3];
+	u8         reserved_at_1c0[0x1];
+	u8         pps[0x1];
+	u8         pps_modify[0x1];
 	u8         log_max_msg[0x5];
 	u8         reserved_at_1c8[0x4];
 	u8         max_tc[0x4];
@@ -7736,6 +7738,60 @@ struct mlx5_ifc_initial_seg_bits {
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
@@ -7781,6 +7837,8 @@ union mlx5_ifc_ports_control_registers_document_bits {
 	struct mlx5_ifc_pvlc_reg_bits pvlc_reg;
 	struct mlx5_ifc_slrg_reg_bits slrg_reg;
 	struct mlx5_ifc_sltp_reg_bits sltp_reg;
+	struct mlx5_ifc_mtpps_reg_bits mtpps_reg;
+	struct mlx5_ifc_mtppse_reg_bits mtppse_reg;
 	u8         reserved_at_0[0x60e0];
 };
 
-- 
2.7.4
