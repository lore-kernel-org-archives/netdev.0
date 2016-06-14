From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [GIT PULL] Please Pull Mellanox Shared Code
Date: Tue, 14 Jun 2016 09:35:48 +0300
Message-ID: <20160614063548.GN5408@leon.nu>
References: <20160613120301.GF5408@leon.nu>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="K4LMwn8CgX2KMboP"
Cc: RDMA mailing list <linux-rdma@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>, saeedm@mellanox.com
To: Doug Ledford <dledford@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:42816 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbcFNGg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 02:36:26 -0400
Content-Disposition: inline
In-Reply-To: <20160613120301.GF5408@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--K4LMwn8CgX2KMboP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 13, 2016 at 03:03:01PM +0300, Leon Romanovsky wrote:
> Hi Doug and David,
>=20
> This is Mellanox mlx5_core shared code for both net-next and RDMA
> trees for 4.8 kernel cycle.
>=20
> This mlx5_ifc update introduces following ConnectX-4 features.
>=20
> * netdev part:
>  - MLX5_CQ_PERIOD_NUM_MODES for adaptive moderation support
>  - QoS rate limiting
>  - SQ context rate limiting
>  - Auto negotiation fields in PTYS register
>  - Source SQN field in flow table entry match structure
>  - DCBX parameters
>=20
> * RDMA part:
>  - New XRQ opcodes, commands and capabilities layout
>  - Extend Q counters definition to support IB.
>=20
> Thank you,
>   Saeed and Leon.
>=20
> The following changes since commit af8c34ce6ae32addda3788d54a7e340cad2251=
6b:
>=20
>   Linux 4.7-rc2 (2016-06-05 14:31:26 -0700)
>=20
> are available in the git repository at:
>=20
>   git@gitolite.kernel.org:pub/scm/linux/kernel/git/leon/linux-rdma tags/s=
hared
>=20
> for you to fetch changes up to 7486216b3a0bd26375b17b2cc168a311106cea70:
>=20
>   {net,IB}/mlx5: mlx5_ifc updates (2016-06-10 13:29:14 +0300)
>=20
> ----------------------------------------------------------------
> Saeed Mahameed (1):
>       {net,IB}/mlx5: mlx5_ifc updates
>=20
>  include/linux/mlx5/mlx5_ifc.h | 275 ++++++++++++++++++++++++++++++++++++=
++++--
>  1 file changed, 263 insertions(+), 12 deletions(-)

=46rom 7486216b3a0bd26375b17b2cc168a311106cea70 Mon Sep 17 00:00:00 2001
=46rom: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 9 Jun 2016 15:11:34 +0300
Subject: [PATCH] {net,IB}/mlx5: mlx5_ifc updates

Introducing mlx5_ifc updates for upcoming ConnectX-4 features.

Needed bits and hardware structures for mlx5e netdev:
	- MLX5_CQ_PERIOD_NUM_MODES for adaptive moderation
	  support
	- QoS rate limiting
	- SQ context rate limiting
	- Auto negotiation fields in PTYS register
	- Source SQN field in flow table entry match structure
	- DCBX parameters

Needed bits and hardware structures for IB:
	- New XRQ opcodes, commands and capabilities layout
	- Extend q counters definition to support IB.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 include/linux/mlx5/mlx5_ifc.h | 275 ++++++++++++++++++++++++++++++++++++++=
++--
 1 file changed, 263 insertions(+), 12 deletions(-)

diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 9a05cd7..209add9 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -123,6 +123,10 @@ enum {
 	MLX5_CMD_OP_DRAIN_DCT                     =3D 0x712,
 	MLX5_CMD_OP_QUERY_DCT                     =3D 0x713,
 	MLX5_CMD_OP_ARM_DCT_FOR_KEY_VIOLATION     =3D 0x714,
+	MLX5_CMD_OP_CREATE_XRQ                    =3D 0x717,
+	MLX5_CMD_OP_DESTROY_XRQ                   =3D 0x718,
+	MLX5_CMD_OP_QUERY_XRQ                     =3D 0x719,
+	MLX5_CMD_OP_ARM_XRQ                       =3D 0x71a,
 	MLX5_CMD_OP_QUERY_VPORT_STATE             =3D 0x750,
 	MLX5_CMD_OP_MODIFY_VPORT_STATE            =3D 0x751,
 	MLX5_CMD_OP_QUERY_ESW_VPORT_CONTEXT       =3D 0x752,
@@ -139,6 +143,8 @@ enum {
 	MLX5_CMD_OP_ALLOC_Q_COUNTER               =3D 0x771,
 	MLX5_CMD_OP_DEALLOC_Q_COUNTER             =3D 0x772,
 	MLX5_CMD_OP_QUERY_Q_COUNTER               =3D 0x773,
+	MLX5_CMD_OP_SET_RATE_LIMIT                =3D 0x780,
+	MLX5_CMD_OP_QUERY_RATE_LIMIT              =3D 0x781,
 	MLX5_CMD_OP_ALLOC_PD                      =3D 0x800,
 	MLX5_CMD_OP_DEALLOC_PD                    =3D 0x801,
 	MLX5_CMD_OP_ALLOC_UAR                     =3D 0x802,
@@ -361,7 +367,8 @@ struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
 };
=20
 struct mlx5_ifc_fte_match_set_misc_bits {
-	u8         reserved_at_0[0x20];
+	u8         reserved_at_0[0x8];
+	u8         source_sqn[0x18];
=20
 	u8         reserved_at_20[0x10];
 	u8         source_port[0x10];
@@ -505,6 +512,17 @@ struct mlx5_ifc_e_switch_cap_bits {
 	u8         reserved_at_20[0x7e0];
 };
=20
+struct mlx5_ifc_qos_cap_bits {
+	u8         packet_pacing[0x1];
+	u8         reserved_0[0x1f];
+	u8         reserved_1[0x20];
+	u8         packet_pacing_max_rate[0x20];
+	u8         packet_pacing_min_rate[0x20];
+	u8         reserved_2[0x10];
+	u8         packet_pacing_rate_table_size[0x10];
+	u8         reserved_3[0x760];
+};
+
 struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         csum_cap[0x1];
 	u8         vlan_cap[0x1];
@@ -744,7 +762,8 @@ struct mlx5_ifc_cmd_hca_cap_bits {
=20
 	u8         out_of_seq_cnt[0x1];
 	u8         vport_counters[0x1];
-	u8         reserved_at_182[0x4];
+	u8         retransmission_q_counters[0x1];
+	u8         reserved_at_183[0x3];
 	u8         max_qp_cnt[0xa];
 	u8         pkey_table_size[0x10];
=20
@@ -771,7 +790,9 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         log_max_msg[0x5];
 	u8         reserved_at_1c8[0x4];
 	u8         max_tc[0x4];
-	u8         reserved_at_1d0[0x6];
+	u8         reserved_at_1d0[0x1];
+	u8         dcbx[0x1];
+	u8         reserved_at_1d2[0x4];
 	u8         rol_s[0x1];
 	u8         rol_g[0x1];
 	u8         reserved_at_1d8[0x1];
@@ -803,7 +824,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         tph[0x1];
 	u8         rf[0x1];
 	u8         dct[0x1];
-	u8         reserved_at_21b[0x1];
+	u8         qos[0x1];
 	u8         eth_net_offloads[0x1];
 	u8         roce[0x1];
 	u8         atomic[0x1];
@@ -929,7 +950,15 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         cqe_compression_timeout[0x10];
 	u8         cqe_compression_max_num[0x10];
=20
-	u8         reserved_at_5e0[0x220];
+	u8         reserved_at_5e0[0x10];
+	u8         tag_matching[0x1];
+	u8         rndv_offload_rc[0x1];
+	u8         rndv_offload_dc[0x1];
+	u8         log_tag_matching_list_sz[0x5];
+	u8         reserved_at_5e8[0x3];
+	u8         log_max_xrq[0x5];
+
+	u8         reserved_at_5f0[0x200];
 };
=20
 enum mlx5_flow_destination_type {
@@ -1967,7 +1996,7 @@ struct mlx5_ifc_qpc_bits {
=20
 	u8         reserved_at_560[0x5];
 	u8         rq_type[0x3];
-	u8         srqn_rmpn[0x18];
+	u8         srqn_rmpn_xrqn[0x18];
=20
 	u8         reserved_at_580[0x8];
 	u8         rmsn[0x18];
@@ -2018,6 +2047,7 @@ union mlx5_ifc_hca_cap_union_bits {
 	struct mlx5_ifc_flow_table_eswitch_cap_bits flow_table_eswitch_cap;
 	struct mlx5_ifc_e_switch_cap_bits e_switch_cap;
 	struct mlx5_ifc_vector_calc_cap_bits vector_calc_cap;
+	struct mlx5_ifc_qos_cap_bits qos_cap;
 	u8         reserved_at_0[0x8000];
 };
=20
@@ -2244,8 +2274,9 @@ struct mlx5_ifc_sqc_bits {
 	u8         reserved_at_40[0x8];
 	u8         cqn[0x18];
=20
-	u8         reserved_at_60[0xa0];
+	u8         reserved_at_60[0x90];
=20
+	u8         packet_pacing_rate_limit_index[0x10];
 	u8         tis_lst_sz[0x10];
 	u8         reserved_at_110[0x10];
=20
@@ -2593,7 +2624,7 @@ struct mlx5_ifc_dctc_bits {
 	u8         reserved_at_98[0x8];
=20
 	u8         reserved_at_a0[0x8];
-	u8         srqn[0x18];
+	u8         srqn_xrqn[0x18];
=20
 	u8         reserved_at_c0[0x8];
 	u8         pd[0x18];
@@ -2645,6 +2676,7 @@ enum {
 enum {
 	MLX5_CQ_PERIOD_MODE_START_FROM_EQE =3D 0x0,
 	MLX5_CQ_PERIOD_MODE_START_FROM_CQE =3D 0x1,
+	MLX5_CQ_PERIOD_NUM_MODES
 };
=20
 struct mlx5_ifc_cqc_bits {
@@ -2722,6 +2754,54 @@ struct mlx5_ifc_query_adapter_param_block_bits {
 	u8         vsd_contd_psid[16][0x8];
 };
=20
+enum {
+	MLX5_XRQC_STATE_GOOD   =3D 0x0,
+	MLX5_XRQC_STATE_ERROR  =3D 0x1,
+};
+
+enum {
+	MLX5_XRQC_TOPOLOGY_NO_SPECIAL_TOPOLOGY =3D 0x0,
+	MLX5_XRQC_TOPOLOGY_TAG_MATCHING        =3D 0x1,
+};
+
+enum {
+	MLX5_XRQC_OFFLOAD_RNDV =3D 0x1,
+};
+
+struct mlx5_ifc_tag_matching_topology_context_bits {
+	u8         log_matching_list_sz[0x4];
+	u8         reserved_at_4[0xc];
+	u8         append_next_index[0x10];
+
+	u8         sw_phase_cnt[0x10];
+	u8         hw_phase_cnt[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_xrqc_bits {
+	u8         state[0x4];
+	u8         rlkey[0x1];
+	u8         reserved_at_5[0xf];
+	u8         topology[0x4];
+	u8         reserved_at_18[0x4];
+	u8         offload[0x4];
+
+	u8         reserved_at_20[0x8];
+	u8         user_index[0x18];
+
+	u8         reserved_at_40[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_at_60[0xa0];
+
+	struct mlx5_ifc_tag_matching_topology_context_bits tag_matching_topology_=
context;
+
+	u8         reserved_at_180[0x180];
+
+	struct mlx5_ifc_wq_bits wq;
+};
+
 union mlx5_ifc_modify_field_select_resize_field_select_auto_bits {
 	struct mlx5_ifc_modify_field_select_bits modify_field_select;
 	struct mlx5_ifc_resize_field_select_bits resize_field_select;
@@ -3144,6 +3224,30 @@ struct mlx5_ifc_rst2init_qp_in_bits {
 	u8         reserved_at_800[0x80];
 };
=20
+struct mlx5_ifc_query_xrq_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+
+	struct mlx5_ifc_xrqc_bits xrq_context;
+};
+
+struct mlx5_ifc_query_xrq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x8];
+	u8         xrqn[0x18];
+
+	u8         reserved_at_60[0x20];
+};
+
 struct mlx5_ifc_query_xrc_srq_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -3547,7 +3651,27 @@ struct mlx5_ifc_query_q_counter_out_bits {
=20
 	u8         out_of_sequence[0x20];
=20
-	u8         reserved_at_1e0[0x620];
+	u8         reserved_at_1e0[0x20];
+
+	u8         duplicate_request[0x20];
+
+	u8         reserved_at_220[0x20];
+
+	u8         rnr_nak_retry_err[0x20];
+
+	u8         reserved_at_260[0x20];
+
+	u8         packet_seq_err[0x20];
+
+	u8         reserved_at_2a0[0x20];
+
+	u8         implied_nak_seq_err[0x20];
+
+	u8         reserved_at_2e0[0x20];
+
+	u8         local_ack_timeout_err[0x20];
+
+	u8         reserved_at_320[0x4e0];
 };
=20
 struct mlx5_ifc_query_q_counter_in_bits {
@@ -4998,6 +5122,28 @@ struct mlx5_ifc_detach_from_mcg_in_bits {
 	u8         multicast_gid[16][0x8];
 };
=20
+struct mlx5_ifc_destroy_xrq_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_destroy_xrq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x8];
+	u8         xrqn[0x18];
+
+	u8         reserved_at_60[0x20];
+};
+
 struct mlx5_ifc_destroy_xrc_srq_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -5583,6 +5729,30 @@ struct mlx5_ifc_dealloc_flow_counter_in_bits {
 	u8         reserved_at_60[0x20];
 };
=20
+struct mlx5_ifc_create_xrq_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x8];
+	u8         xrqn[0x18];
+
+	u8         reserved_at_60[0x20];
+};
+
+struct mlx5_ifc_create_xrq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+
+	struct mlx5_ifc_xrqc_bits xrq_context;
+};
+
 struct mlx5_ifc_create_xrc_srq_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -6124,6 +6294,29 @@ struct mlx5_ifc_attach_to_mcg_in_bits {
 	u8         multicast_gid[16][0x8];
 };
=20
+struct mlx5_ifc_arm_xrq_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_arm_xrq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x8];
+	u8         xrqn[0x18];
+
+	u8         reserved_at_60[0x10];
+	u8         lwm[0x10];
+};
+
 struct mlx5_ifc_arm_xrc_srq_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -6161,7 +6354,8 @@ struct mlx5_ifc_arm_rq_out_bits {
 };
=20
 enum {
-	MLX5_ARM_RQ_IN_OP_MOD_SRQ_  =3D 0x1,
+	MLX5_ARM_RQ_IN_OP_MOD_SRQ =3D 0x1,
+	MLX5_ARM_RQ_IN_OP_MOD_XRQ =3D 0x2,
 };
=20
 struct mlx5_ifc_arm_rq_in_bits {
@@ -6354,6 +6548,30 @@ struct mlx5_ifc_add_vxlan_udp_dport_in_bits {
 	u8         vxlan_udp_port[0x10];
 };
=20
+struct mlx5_ifc_set_rate_limit_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_set_rate_limit_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x10];
+	u8         rate_limit_index[0x10];
+
+	u8         reserved_at_60[0x20];
+
+	u8         rate_limit[0x20];
+};
+
 struct mlx5_ifc_access_register_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -6478,12 +6696,15 @@ struct mlx5_ifc_pude_reg_bits {
 };
=20
 struct mlx5_ifc_ptys_reg_bits {
-	u8         reserved_at_0[0x8];
+	u8         an_disable_cap[0x1];
+	u8         an_disable_admin[0x1];
+	u8         reserved_at_2[0x6];
 	u8         local_port[0x8];
 	u8         reserved_at_10[0xd];
 	u8         proto_mask[0x3];
=20
-	u8         reserved_at_20[0x40];
+	u8         an_status[0x4];
+	u8         reserved_at_24[0x3c];
=20
 	u8         eth_proto_capability[0x20];
=20
@@ -7444,4 +7665,34 @@ struct mlx5_ifc_mcia_reg_bits {
 	u8         dword_11[0x20];
 };
=20
+struct mlx5_ifc_dcbx_param_bits {
+	u8         dcbx_cee_cap[0x1];
+	u8         dcbx_ieee_cap[0x1];
+	u8         dcbx_standby_cap[0x1];
+	u8         reserved_at_0[0x5];
+	u8         port_number[0x8];
+	u8         reserved_at_10[0xa];
+	u8         max_application_table_size[6];
+	u8         reserved_at_20[0x15];
+	u8         version_oper[0x3];
+	u8         reserved_at_38[5];
+	u8         version_admin[0x3];
+	u8         willing_admin[0x1];
+	u8         reserved_at_41[0x3];
+	u8         pfc_cap_oper[0x4];
+	u8         reserved_at_48[0x4];
+	u8         pfc_cap_admin[0x4];
+	u8         reserved_at_50[0x4];
+	u8         num_of_tc_oper[0x4];
+	u8         reserved_at_58[0x4];
+	u8         num_of_tc_admin[0x4];
+	u8         remote_willing[0x1];
+	u8         reserved_at_61[3];
+	u8         remote_pfc_cap[4];
+	u8         reserved_at_68[0x14];
+	u8         remote_num_of_tc[0x4];
+	u8         reserved_at_80[0x18];
+	u8         error[0x8];
+	u8         reserved_at_a0[0x160];
+};
 #endif /* MLX5_IFC_H */
--=20
2.1.4


--K4LMwn8CgX2KMboP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXX6XEAAoJEORje4g2clinsqEP/0ZHjqycqHq9q2klNHEWdHQP
X2QI6fZjZt1ACVHwn+Xl0LxW0jeZmAU7S6A6aumHun9Y643WUM1Cvm81W2jUrFwk
OtII8uzpDZbC9LvBzPwZU62c98/MEY0IbtKm82PBkqEEtFGraSA4bR94beviiW81
1bnrDImEeLgSCA/cKY/6KL+0/68Vp0hWxHqHwJAV6BudRx6VTb/wRCLmX2krUIYQ
dEKNu10+0XS6vs9injpUhJzQV/28yTIIP/3ScPFzk6Jga9Tb2wq5xBqCpYct8kl5
tIM741TQVhG9Jy3TOGgKWZH2I9Hb/MMMMDhkCk4O6lG8PgQOlou3UuX5hWSL4TGl
dcHyIFIwmHn+oTO1XQ5PDGqjImGzY1Mpe47AV64yQEl7/nhwbzeVzYJdJrU249AB
rRQNjTq5WXw06x5B4D8rG73JZJF88XPqdbY+LJDSKE7nt4FYOkMX6WkYxTYem40x
9aHvBP9moZ3JTJBjQ8QyLCKPC63oXHCuo7uI3VzCbC7VaWfLxuWttRm1ZrsEajP8
6AbpZNQs4pi0c9fQuY392BGJTN6subFkTPMTL8F1x8/7TTOm0W35p03rmAi9/Mmp
/udvv8gMdu3WCXAGMu7oYeRfJ7ePeOmUMUjTf/svDlvN+PwcpK+pjFOcSZQrQKul
ehdnNGqI2pLHjBvK/mrY
=6oWU
-----END PGP SIGNATURE-----

--K4LMwn8CgX2KMboP--
