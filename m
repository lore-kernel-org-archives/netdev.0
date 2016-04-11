From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Mon, 11 Apr 2016 23:10:22 +0300
Message-ID: <1460405422-8654-3-git-send-email-saeedm@mellanox.com>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1460405422-8654-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding the needed mlx5_ifc hardware bits and structs
for the following feature:

* Add vport to steering commands for SRIOV ACL support
* Add mlcr, pcmr and mcia registers for dump module EEPROM
* Add support for FCS, baeacon led and disable_link bits to
  hca caps
* Add CQE period mode bit in  CQ context for CQE based CQ
  moderation support
* Add umr SQ bit for fragmented memory registration
* Add needed bits and caps for Striding RQ support

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 include/linux/mlx5/mlx5_ifc.h |  146 ++++++++++++++++++++++++++++++++++------
 1 files changed, 124 insertions(+), 22 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index c300e74..4ce4ea4 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -513,7 +513,9 @@ struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         max_lso_cap[0x5];
 	u8         reserved_at_10[0x4];
 	u8         rss_ind_tbl_cap[0x4];
-	u8         reserved_at_18[0x3];
+	u8         reg_umr_sq[0x1];
+	u8         scatter_fcs[0x1];
+	u8         reserved_at_1a[0x1];
 	u8         tunnel_lso_const_out_ip_id[0x1];
 	u8         reserved_at_1c[0x2];
 	u8         tunnel_statless_gre[0x1];
@@ -648,7 +650,7 @@ struct mlx5_ifc_vector_calc_cap_bits {
 enum {
 	MLX5_WQ_TYPE_LINKED_LIST  = 0x0,
 	MLX5_WQ_TYPE_CYCLIC       = 0x1,
-	MLX5_WQ_TYPE_STRQ         = 0x2,
+	MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ = 0x2,
 };
 
 enum {
@@ -753,7 +755,11 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8	   early_vf_enable[0x1];
 	u8         reserved_at_1a9[0x2];
 	u8         local_ca_ack_delay[0x5];
-	u8         reserved_at_1af[0x6];
+	u8         reserved_at_1af[0x2];
+	u8         ports_check[0x1];
+	u8         reserved_at_1b2[0x1];
+	u8         disable_link_up[0x1];
+	u8         beacon_led[0x1];
 	u8         port_type[0x2];
 	u8         num_ports[0x8];
 
@@ -778,7 +784,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         cqe_version[0x4];
 
 	u8         compact_address_vector[0x1];
-	u8         reserved_at_200[0x3];
+	u8         striding_rq[0x1];
+	u8         reserved_at_201[0x2];
 	u8         ipoib_basic_offloads[0x1];
 	u8         reserved_at_205[0xa];
 	u8         drain_sigerr[0x1];
@@ -807,12 +814,12 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         block_lb_mc[0x1];
 	u8         reserved_at_229[0x1];
 	u8         scqe_break_moderation[0x1];
-	u8         reserved_at_22a[0x1];
+	u8         cq_period_start_from_cqe[0x1];
 	u8         cd[0x1];
 	u8         reserved_at_22d[0x1];
 	u8         apm[0x1];
 	u8         vector_calc[0x1];
-	u8         reserved_at_22f[0x1];
+	u8         umr_ptr_rlky[0x1];
 	u8	   imaicl[0x1];
 	u8         reserved_at_232[0x4];
 	u8         qkv[0x1];
@@ -913,10 +920,10 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_at_500[0x80];
 
 	u8         reserved_at_580[0x3f];
-	u8         cqe_zip[0x1];
+	u8         cqe_compression[0x1];
 
-	u8         cqe_zip_timeout[0x10];
-	u8         cqe_zip_max_num[0x10];
+	u8         cqe_compression_timeout[0x10];
+	u8         cqe_compression_max_num[0x10];
 
 	u8         reserved_at_5e0[0x220];
 };
@@ -1000,7 +1007,13 @@ struct mlx5_ifc_wq_bits {
 	u8         reserved_at_118[0x3];
 	u8         log_wq_sz[0x5];
 
-	u8         reserved_at_120[0x4e0];
+	u8         reserved_at_120[0x15];
+	u8         log_wqe_num_of_strides[0x3];
+	u8         two_byte_shift_en[0x1];
+	u8         reserved_at_139[0x4];
+	u8         log_wqe_stride_size[0x3];
+
+	u8         reserved_at_140[0x4c0];
 
 	struct mlx5_ifc_cmd_pas_bits pas[0];
 };
@@ -2199,7 +2212,8 @@ struct mlx5_ifc_sqc_bits {
 	u8         flush_in_error_en[0x1];
 	u8         reserved_at_4[0x4];
 	u8         state[0x4];
-	u8         reserved_at_c[0x14];
+	u8         reg_umr[0x1];
+	u8         reserved_at_d[0x13];
 
 	u8         reserved_at_20[0x8];
 	u8         user_index[0x18];
@@ -2247,7 +2261,8 @@ enum {
 
 struct mlx5_ifc_rqc_bits {
 	u8         rlky[0x1];
-	u8         reserved_at_1[0x2];
+	u8         reserved_at_1[0x1];
+	u8         scatter_fcs[0x1];
 	u8         vsd[0x1];
 	u8         mem_rq_type[0x4];
 	u8         state[0x4];
@@ -2604,6 +2619,11 @@ enum {
 	MLX5_CQC_ST_FIRED                                 = 0xa,
 };
 
+enum {
+	MLX5_CQ_PERIOD_MODE_START_FROM_EQE = 0x0,
+	MLX5_CQ_PERIOD_MODE_START_FROM_CQE = 0x1,
+};
+
 struct mlx5_ifc_cqc_bits {
 	u8         status[0x4];
 	u8         reserved_at_4[0x4];
@@ -2612,8 +2632,8 @@ struct mlx5_ifc_cqc_bits {
 	u8         reserved_at_c[0x1];
 	u8         scqe_break_moderation_en[0x1];
 	u8         oi[0x1];
-	u8         reserved_at_f[0x2];
-	u8         cqe_zip_en[0x1];
+	u8         cq_period_mode[0x2];
+	u8         cqe_comp_en[0x1];
 	u8         mini_cqe_res_format[0x2];
 	u8         st[0x4];
 	u8         reserved_at_18[0x8];
@@ -2987,7 +3007,11 @@ struct mlx5_ifc_set_fte_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -5181,7 +5205,11 @@ struct mlx5_ifc_destroy_flow_table_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -5208,7 +5236,11 @@ struct mlx5_ifc_destroy_flow_group_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -5349,7 +5381,11 @@ struct mlx5_ifc_delete_fte_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -5795,7 +5831,11 @@ struct mlx5_ifc_create_flow_table_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -5839,7 +5879,11 @@ struct mlx5_ifc_create_flow_group_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -6372,6 +6416,17 @@ struct mlx5_ifc_ptys_reg_bits {
 	u8         reserved_at_1a0[0x60];
 };
 
+struct mlx5_ifc_mlcr_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         local_port[0x8];
+	u8         reserved_at_10[0x20];
+
+	u8         beacon_duration[0x10];
+	u8         reserved_at_40[0x10];
+
+	u8         beacon_remain[0x10];
+};
+
 struct mlx5_ifc_ptas_reg_bits {
 	u8         reserved_at_0[0x20];
 
@@ -6781,6 +6836,16 @@ struct mlx5_ifc_pamp_reg_bits {
 	u8         index_data[18][0x10];
 };
 
+struct mlx5_ifc_pcmr_reg_bits {
+	u8         reserved_at_0[0x8];
+	u8         local_port[0x8];
+	u8         reserved_at_10[0x2e];
+	u8         fcs_cap[0x1];
+	u8         reserved_at_3f[0x1f];
+	u8         fcs_chk[0x1];
+	u8         reserved_at_5f[0x1];
+};
+
 struct mlx5_ifc_lane_2_module_mapping_bits {
 	u8         reserved_at_0[0x6];
 	u8         rx_lane[0x2];
@@ -7117,6 +7182,7 @@ union mlx5_ifc_ports_control_registers_document_bits {
 	struct mlx5_ifc_pspa_reg_bits pspa_reg;
 	struct mlx5_ifc_ptas_reg_bits ptas_reg;
 	struct mlx5_ifc_ptys_reg_bits ptys_reg;
+	struct mlx5_ifc_mlcr_reg_bits mlcr_reg;
 	struct mlx5_ifc_pude_reg_bits pude_reg;
 	struct mlx5_ifc_pvlc_reg_bits pvlc_reg;
 	struct mlx5_ifc_slrg_reg_bits slrg_reg;
@@ -7150,7 +7216,11 @@ struct mlx5_ifc_set_flow_table_root_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x40];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_at_60[0x20];
 
 	u8         table_type[0x8];
 	u8         reserved_at_88[0x18];
@@ -7181,7 +7251,9 @@ struct mlx5_ifc_modify_flow_table_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x20];
+	u8         other_vport[0x1];
+	u8         reserved_at_41[0xf];
+	u8         vport_number[0x10];
 
 	u8         reserved_at_60[0x10];
 	u8         modify_field_select[0x10];
@@ -7247,4 +7319,34 @@ struct mlx5_ifc_qtct_reg_bits {
 	u8         tclass[0x3];
 };
 
+struct mlx5_ifc_mcia_reg_bits {
+	u8         l[0x1];
+	u8         reserved_at_1[0x7];
+	u8         module[0x8];
+	u8         reserved_at_10[0x8];
+	u8         status[0x8];
+
+	u8         i2c_device_address[0x8];
+	u8         page_number[0x8];
+	u8         device_address[0x10];
+
+	u8         reserved_at_40[0x10];
+	u8         size[0x10];
+
+	u8         reserved_at_60[0x20];
+
+	u8         dword_0[0x20];
+	u8         dword_1[0x20];
+	u8         dword_2[0x20];
+	u8         dword_3[0x20];
+	u8         dword_4[0x20];
+	u8         dword_5[0x20];
+	u8         dword_6[0x20];
+	u8         dword_7[0x20];
+	u8         dword_8[0x20];
+	u8         dword_9[0x20];
+	u8         dword_10[0x20];
+	u8         dword_11[0x20];
+};
+
 #endif /* MLX5_IFC_H */
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
