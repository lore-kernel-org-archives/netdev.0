From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx4_core: Add basic support for TCP/IP offloads under tunneling
Date: Wed, 18 Dec 2013 16:05:27 +0200
Message-ID: <1387375528-2337-2-git-send-email-ogerlitz@mellanox.com>
References: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36259 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753861Ab3LROFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 09:05:36 -0500
In-Reply-To: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the low-level device commands and definitions used for TCP/IP HW offloads
of tunneled/vxlan traffic which are supported by the ConnectX3-pro NIC.

This is done through the following elements:

 - read tunneling device caps in QUERY_DEV_CAP
 - add helper function to do SET_PORT for tunneling
 - add DMFS VXLAN steering rule definitions
 - add CQE and WQE checksum offload field definitions

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |   19 ++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c |   14 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/mcg.c  |   14 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/port.c |   41 +++++++++++++++++++++++++++++
 include/linux/mlx4/cmd.h                  |    1 +
 include/linux/mlx4/cq.h                   |    5 +++
 include/linux/mlx4/device.h               |   37 +++++++++++++++++++++++++-
 include/linux/mlx4/qp.h                   |    6 ++++
 8 files changed, 133 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 27a8434..55c4ea7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -134,7 +134,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[5] = "Time stamping support",
 		[6] = "VST (control vlan insertion/stripping) support",
 		[7] = "FSM (MAC anti-spoofing) support",
-		[8] = "Dynamic QP updates support"
+		[8] = "Dynamic QP updates support",
+		[9] = "TCP/IP offloads/flow-steering for VXLAN support"
 	};
 	int i;
 
@@ -536,6 +537,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_RSVD_LKEY_OFFSET		0x98
 #define QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET		0xa0
 #define QUERY_DEV_CAP_FW_REASSIGN_MAC		0x9d
+#define QUERY_DEV_CAP_VXLAN			0x9e
 
 	dev_cap->flags2 = 0;
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
@@ -701,6 +703,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_FW_REASSIGN_MAC);
 	if (field & 1<<6)
 		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_REASSIGN_MAC_EN;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_VXLAN);
+	if (field & 1<<3)
+		dev_cap->flags2 |= MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS;
 	MLX4_GET(dev_cap->max_icm_sz, outbox,
 		 QUERY_DEV_CAP_MAX_ICM_SZ_OFFSET);
 	if (dev_cap->flags & MLX4_DEV_CAP_FLAG_COUNTERS)
@@ -849,6 +854,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	field &= 0x7f;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
 
+	/* For guests, disable vxlan tunneling */
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_VXLAN);
+	field &= 0xf7;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_VXLAN);
+
 	/* For guests, report Blueflame disabled */
 	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_BF_OFFSET);
 	field &= 0x7f;
@@ -1274,6 +1284,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 #define INIT_HCA_IN_SIZE		 0x200
 #define INIT_HCA_VERSION_OFFSET		 0x000
 #define	 INIT_HCA_VERSION		 2
+#define INIT_HCA_VXLAN_OFFSET		 0x0c
 #define INIT_HCA_CACHELINE_SZ_OFFSET	 0x0e
 #define INIT_HCA_FLAGS_OFFSET		 0x014
 #define INIT_HCA_QPC_OFFSET		 0x020
@@ -1432,6 +1443,12 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	MLX4_PUT(inbox, param->uar_page_sz,	INIT_HCA_UAR_PAGE_SZ_OFFSET);
 	MLX4_PUT(inbox, param->log_uar_sz,      INIT_HCA_LOG_UAR_SZ_OFFSET);
 
+	/* set parser VXLAN attributes */
+	if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS) {
+		u8 parser_params = 0;
+		MLX4_PUT(inbox, parser_params,	INIT_HCA_VXLAN_OFFSET);
+	}
+
 	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_INIT_HCA, 10000,
 		       MLX4_CMD_NATIVE);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index fbebfb0..d2b8b39 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1444,6 +1444,19 @@ static void choose_steering_mode(struct mlx4_dev *dev,
 		 mlx4_log_num_mgm_entry_size);
 }
 
+static void choose_tunnel_offload_mode(struct mlx4_dev *dev,
+				       struct mlx4_dev_cap *dev_cap)
+{
+	if (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED &&
+	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS)
+		dev->caps.tunnel_offload_mode = MLX4_TUNNEL_OFFLOAD_MODE_VXLAN;
+	else
+		dev->caps.tunnel_offload_mode = MLX4_TUNNEL_OFFLOAD_MODE_NONE;
+
+	mlx4_dbg(dev, "Tunneling offload mode is: %s\n",  (dev->caps.tunnel_offload_mode
+		 == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) ? "vxlan" : "none");
+}
+
 static int mlx4_init_hca(struct mlx4_dev *dev)
 {
 	struct mlx4_priv	  *priv = mlx4_priv(dev);
@@ -1484,6 +1497,7 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		}
 
 		choose_steering_mode(dev, &dev_cap);
+		choose_tunnel_offload_mode(dev, &dev_cap);
 
 		err = mlx4_get_phys_port_id(dev);
 		if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 7c83e6c..bfe65f7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -697,7 +697,8 @@ const u16 __sw_id_hw[] = {
 	[MLX4_NET_TRANS_RULE_ID_IPV6]    = 0xE003,
 	[MLX4_NET_TRANS_RULE_ID_IPV4]    = 0xE002,
 	[MLX4_NET_TRANS_RULE_ID_TCP]     = 0xE004,
-	[MLX4_NET_TRANS_RULE_ID_UDP]     = 0xE006
+	[MLX4_NET_TRANS_RULE_ID_UDP]     = 0xE006,
+	[MLX4_NET_TRANS_RULE_ID_VXLAN]	 = 0xE008
 };
 
 int mlx4_map_sw_to_hw_steering_id(struct mlx4_dev *dev,
@@ -722,7 +723,9 @@ static const int __rule_hw_sz[] = {
 	[MLX4_NET_TRANS_RULE_ID_TCP] =
 		sizeof(struct mlx4_net_trans_rule_hw_tcp_udp),
 	[MLX4_NET_TRANS_RULE_ID_UDP] =
-		sizeof(struct mlx4_net_trans_rule_hw_tcp_udp)
+		sizeof(struct mlx4_net_trans_rule_hw_tcp_udp),
+	[MLX4_NET_TRANS_RULE_ID_VXLAN] =
+		sizeof(struct mlx4_net_trans_rule_hw_vxlan)
 };
 
 int mlx4_hw_rule_sz(struct mlx4_dev *dev,
@@ -787,6 +790,13 @@ static int parse_trans_rule(struct mlx4_dev *dev, struct mlx4_spec_list *spec,
 		rule_hw->tcp_udp.src_port_msk = spec->tcp_udp.src_port_msk;
 		break;
 
+	case MLX4_NET_TRANS_RULE_ID_VXLAN:
+		rule_hw->vxlan.vni =
+			cpu_to_be32(be32_to_cpu(spec->vxlan.vni) << 8);
+		rule_hw->vxlan.vni_mask =
+			cpu_to_be32(be32_to_cpu(spec->vxlan.vni_mask) << 8);
+		break;
+
 	default:
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 97d342f..93f75ec 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -800,6 +800,47 @@ int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_SCHEDULER);
 
+enum {
+	VXLAN_ENABLE_MODIFY	= 1 << 7,
+	VXLAN_STEERING_MODIFY	= 1 << 6,
+
+	VXLAN_ENABLE		= 1 << 7,
+};
+
+struct mlx4_set_port_vxlan_context {
+	u32	reserved1;
+	u8	modify_flags;
+	u8	reserved2;
+	u8	enable_flags;
+	u8	steering;
+};
+
+int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering)
+{
+	int err;
+	u32 in_mod;
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_vxlan_context  *context;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof(*context));
+
+	context->modify_flags = VXLAN_ENABLE_MODIFY | VXLAN_STEERING_MODIFY;
+	context->enable_flags = VXLAN_ENABLE;
+	context->steering  = steering;
+
+	in_mod = MLX4_SET_PORT_VXLAN << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_VXLAN);
+
 int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 8df61bc..b0ec0fe 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -180,6 +180,7 @@ enum {
 	MLX4_SET_PORT_GID_TABLE = 0x5,
 	MLX4_SET_PORT_PRIO2TC	= 0x8,
 	MLX4_SET_PORT_SCHEDULER = 0x9,
+	MLX4_SET_PORT_VXLAN	= 0xB
 };
 
 enum {
diff --git a/include/linux/mlx4/cq.h b/include/linux/mlx4/cq.h
index 98fa492..5dd0d70 100644
--- a/include/linux/mlx4/cq.h
+++ b/include/linux/mlx4/cq.h
@@ -81,7 +81,12 @@ struct mlx4_ts_cqe {
 } __packed;
 
 enum {
+	MLX4_CQE_L2_TUNNEL_IPOK		= 1 << 31,
 	MLX4_CQE_VLAN_PRESENT_MASK	= 1 << 29,
+	MLX4_CQE_L2_TUNNEL		= 1 << 27,
+	MLX4_CQE_L2_TUNNEL_CSUM		= 1 << 26,
+	MLX4_CQE_L2_TUNNEL_IPV4		= 1 << 25,
+
 	MLX4_CQE_QPN_MASK		= 0xffffff,
 };
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 294b7c5..c99ecf6 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -119,6 +119,11 @@ static inline const char *mlx4_steering_mode_str(int steering_mode)
 }
 
 enum {
+	MLX4_TUNNEL_OFFLOAD_MODE_NONE,
+	MLX4_TUNNEL_OFFLOAD_MODE_VXLAN
+};
+
+enum {
 	MLX4_DEV_CAP_FLAG_RC		= 1LL <<  0,
 	MLX4_DEV_CAP_FLAG_UC		= 1LL <<  1,
 	MLX4_DEV_CAP_FLAG_UD		= 1LL <<  2,
@@ -160,7 +165,8 @@ enum {
 	MLX4_DEV_CAP_FLAG2_TS			= 1LL <<  5,
 	MLX4_DEV_CAP_FLAG2_VLAN_CONTROL		= 1LL <<  6,
 	MLX4_DEV_CAP_FLAG2_FSM			= 1LL <<  7,
-	MLX4_DEV_CAP_FLAG2_UPDATE_QP		= 1LL <<  8
+	MLX4_DEV_CAP_FLAG2_UPDATE_QP		= 1LL <<  8,
+	MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS	= 1LL <<  9
 };
 
 enum {
@@ -455,6 +461,7 @@ struct mlx4_caps {
 	u32			function_caps;  /* VFs must be aware of these */
 	u16			hca_core_clock;
 	u64			phys_port_id[MLX4_MAX_PORTS + 1];
+	int			tunnel_offload_mode;
 };
 
 struct mlx4_buf_list {
@@ -909,6 +916,7 @@ enum mlx4_net_trans_rule_id {
 	MLX4_NET_TRANS_RULE_ID_IPV4,
 	MLX4_NET_TRANS_RULE_ID_TCP,
 	MLX4_NET_TRANS_RULE_ID_UDP,
+	MLX4_NET_TRANS_RULE_ID_VXLAN,
 	MLX4_NET_TRANS_RULE_NUM, /* should be last */
 };
 
@@ -966,6 +974,12 @@ struct mlx4_spec_ib {
 	u8	dst_gid_msk[16];
 };
 
+struct mlx4_spec_vxlan {
+	__be32 vni;
+	__be32 vni_mask;
+
+};
+
 struct mlx4_spec_list {
 	struct	list_head list;
 	enum	mlx4_net_trans_rule_id id;
@@ -974,6 +988,7 @@ struct mlx4_spec_list {
 		struct mlx4_spec_ib ib;
 		struct mlx4_spec_ipv4 ipv4;
 		struct mlx4_spec_tcp_udp tcp_udp;
+		struct mlx4_spec_vxlan vxlan;
 	};
 };
 
@@ -1060,6 +1075,15 @@ struct mlx4_net_trans_rule_hw_ipv4 {
 	__be32	src_ip_msk;
 } __packed;
 
+struct mlx4_net_trans_rule_hw_vxlan {
+	u8	size;
+	u8	rsvd;
+	__be16	id;
+	__be32	rsvd1;
+	__be32	vni;
+	__be32	vni_mask;
+} __packed;
+
 struct _rule_hw {
 	union {
 		struct {
@@ -1071,9 +1095,19 @@ struct _rule_hw {
 		struct mlx4_net_trans_rule_hw_ib ib;
 		struct mlx4_net_trans_rule_hw_ipv4 ipv4;
 		struct mlx4_net_trans_rule_hw_tcp_udp tcp_udp;
+		struct mlx4_net_trans_rule_hw_vxlan vxlan;
 	};
 };
 
+enum {
+	VXLAN_STEER_BY_OUTER_MAC	= 1 << 0,
+	VXLAN_STEER_BY_OUTER_VLAN	= 1 << 1,
+	VXLAN_STEER_BY_VSID_VNI		= 1 << 2,
+	VXLAN_STEER_BY_INNER_MAC	= 1 << 3,
+	VXLAN_STEER_BY_INNER_VLAN	= 1 << 4,
+};
+
+
 int mlx4_flow_steer_promisc_add(struct mlx4_dev *dev, u8 port, u32 qpn,
 				enum mlx4_net_trans_promisc_mode mode);
 int mlx4_flow_steer_promisc_remove(struct mlx4_dev *dev, u8 port,
@@ -1096,6 +1130,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
 int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 		u8 *pg, u16 *ratelimit);
+int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
 void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 6d35147..59f8ba8 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -109,6 +109,10 @@ enum {
 	MLX4_RSS_TCP_IPV4			= 1 << 4,
 	MLX4_RSS_IPV4				= 1 << 5,
 
+	MLX4_RSS_BY_OUTER_HEADERS		= 0 << 6,
+	MLX4_RSS_BY_INNER_HEADERS		= 2 << 6,
+	MLX4_RSS_BY_INNER_HEADERS_IPONLY	= 3 << 6,
+
 	/* offset of mlx4_rss_context within mlx4_qp_context.pri_path */
 	MLX4_RSS_OFFSET_IN_QPC_PRI_PATH		= 0x24,
 	/* offset of being RSS indirection QP within mlx4_qp_context.flags */
@@ -252,6 +256,8 @@ enum { /* param3 */
 
 enum {
 	MLX4_WQE_CTRL_NEC		= 1 << 29,
+	MLX4_WQE_CTRL_IIP		= 1 << 28,
+	MLX4_WQE_CTRL_ILP		= 1 << 27,
 	MLX4_WQE_CTRL_FENCE		= 1 << 6,
 	MLX4_WQE_CTRL_CQ_UPDATE		= 3 << 2,
 	MLX4_WQE_CTRL_SOLICITED		= 1 << 1,
-- 
1.7.1
