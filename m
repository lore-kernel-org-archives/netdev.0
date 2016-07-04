From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx5e: Support l3/l4 flow type specs in ethtool flow steering
Date: Mon,  4 Jul 2016 17:23:09 +0300
Message-ID: <1467642192-28259-6-git-send-email-saeedm@mellanox.com>
References: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54693 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752025AbcGDOXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 10:23:53 -0400
In-Reply-To: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add support to add flow steering rules with ethtool
of L3/L4 flow types (ip4/tcp4/udp4).
Those rules will be in higher priority than l2 flow rules, in order
to prefer more specific rules.

Mask is not supported for l3/l4 flow types.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   2 +
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    | 161 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |   2 +-
 3 files changed, 163 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 357320e..9842594 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -549,9 +549,11 @@ struct mlx5e_ethtool_table {
 	int                    num_rules;
 };
 
+#define ETHTOOL_NUM_L3_L4_FTS 7
 #define ETHTOOL_NUM_L2_FTS 4
 
 struct mlx5e_ethtool_steering {
+	struct mlx5e_ethtool_table      l3_l4_ft[ETHTOOL_NUM_L3_L4_FTS];
 	struct mlx5e_ethtool_table      l2_ft[ETHTOOL_NUM_L2_FTS];
 	struct list_head                rules;
 	int                             tot_num_rules;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index ee28a9f..830106e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -48,7 +48,8 @@ static void put_flow_table(struct mlx5e_ethtool_table *eth_ft)
 	}
 }
 
-#define MLX5E_ETHTOOL_L2_PRIO 0
+#define MLX5E_ETHTOOL_L3_L4_PRIO 0
+#define MLX5E_ETHTOOL_L2_PRIO (MLX5E_ETHTOOL_L3_L4_PRIO + ETHTOOL_NUM_L3_L4_FTS)
 #define MLX5E_ETHTOOL_NUM_ENTRIES 64000
 #define MLX5E_ETHTOOL_NUM_GROUPS  10
 static struct mlx5e_ethtool_table *get_flow_table(struct mlx5e_priv *priv,
@@ -63,6 +64,17 @@ static struct mlx5e_ethtool_table *get_flow_table(struct mlx5e_priv *priv,
 	int prio;
 
 	switch (fs->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		max_tuples = ETHTOOL_NUM_L3_L4_FTS;
+		prio = MLX5E_ETHTOOL_L3_L4_PRIO + (max_tuples - num_tuples);
+		eth_ft = &priv->fs.ethtool.l3_l4_ft[prio];
+		break;
+	case IP_USER_FLOW:
+		max_tuples = ETHTOOL_NUM_L3_L4_FTS;
+		prio = MLX5E_ETHTOOL_L3_L4_PRIO + (max_tuples - num_tuples);
+		eth_ft = &priv->fs.ethtool.l3_l4_ft[prio];
+		break;
 	case ETHER_FLOW:
 		max_tuples = ETHTOOL_NUM_L2_FTS;
 		prio = max_tuples - num_tuples;
@@ -103,6 +115,31 @@ static void mask_spec(u8 *mask, u8 *val, size_t size)
 		*((u8 *)val) = *((u8 *)mask) & *((u8 *)val);
 }
 
+static void set_ips(void *outer_headers_v, void *outer_headers_c, __be32 ip4src_m,
+		    __be32 ip4src_v, __be32 ip4dst_m, __be32 ip4dst_v)
+{
+	if (ip4src_m) {
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &ip4src_v, sizeof(ip4src_v));
+		memset(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       0xff, sizeof(ip4src_m));
+	}
+	if (ip4dst_m) {
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &ip4dst_v, sizeof(ip4dst_v));
+		memset(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       0xff, sizeof(ip4dst_m));
+	}
+	MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+		 ethertype, ETH_P_IP);
+	MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+		 ethertype, 0xffff);
+}
+
 static int set_flow_attrs(u32 *match_c, u32 *match_v,
 			  struct ethtool_rx_flow_spec *fs)
 {
@@ -111,10 +148,66 @@ static int set_flow_attrs(u32 *match_c, u32 *match_v,
 	void *outer_headers_v = MLX5_ADDR_OF(fte_match_param, match_v,
 					     outer_headers);
 	u32 flow_type = fs->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT);
+	struct ethtool_tcpip4_spec *l4_mask;
+	struct ethtool_tcpip4_spec *l4_val;
+	struct ethtool_usrip4_spec *l3_mask;
+	struct ethtool_usrip4_spec *l3_val;
 	struct ethhdr *eth_val;
 	struct ethhdr *eth_mask;
 
 	switch (flow_type) {
+	case TCP_V4_FLOW:
+		l4_mask = &fs->m_u.tcp_ip4_spec;
+		l4_val = &fs->h_u.tcp_ip4_spec;
+		set_ips(outer_headers_v, outer_headers_c, l4_mask->ip4src,
+			l4_val->ip4src, l4_mask->ip4dst, l4_val->ip4dst);
+
+		if (l4_mask->psrc) {
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, tcp_sport,
+				 0xffff);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, tcp_sport,
+				 ntohs(l4_val->psrc));
+		}
+		if (l4_mask->pdst) {
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, tcp_dport,
+				 0xffff);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, tcp_dport,
+				 ntohs(l4_val->pdst));
+		}
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 0xffff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 IPPROTO_TCP);
+		break;
+	case UDP_V4_FLOW:
+		l4_mask = &fs->m_u.tcp_ip4_spec;
+		l4_val = &fs->h_u.tcp_ip4_spec;
+		set_ips(outer_headers_v, outer_headers_c, l4_mask->ip4src,
+			l4_val->ip4src, l4_mask->ip4dst, l4_val->ip4dst);
+
+		if (l4_mask->psrc) {
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, udp_sport,
+				 0xffff);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, udp_sport,
+				 ntohs(l4_val->psrc));
+		}
+		if (l4_mask->pdst) {
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, udp_dport,
+				 0xffff);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, udp_dport,
+				 ntohs(l4_val->pdst));
+		}
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 0xffff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 IPPROTO_UDP);
+		break;
+	case IP_USER_FLOW:
+		l3_mask = &fs->m_u.usr_ip4_spec;
+		l3_val = &fs->h_u.usr_ip4_spec;
+		set_ips(outer_headers_v, outer_headers_c, l3_mask->ip4src,
+			l3_val->ip4src, l3_mask->ip4dst, l3_val->ip4dst);
+		break;
 	case ETHER_FLOW:
 		eth_mask = &fs->m_u.ether_spec;
 		eth_val = &fs->h_u.ether_spec;
@@ -152,6 +245,15 @@ static int set_flow_attrs(u32 *match_c, u32 *match_v,
 		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
 			 first_vid, ntohs(fs->h_ext.vlan_tci));
 	}
+	if (fs->flow_type & FLOW_MAC_EXT &&
+	    !is_zero_ether_addr(fs->m_ext.h_dest)) {
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
+					     outer_headers_c, dmac_47_16),
+				fs->m_ext.h_dest);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
+					     outer_headers_v, dmac_47_16),
+				fs->h_ext.h_dest);
+	}
 
 	return 0;
 }
@@ -270,9 +372,16 @@ static struct mlx5e_ethtool_rule *get_ethtool_rule(struct mlx5e_priv *priv,
 }
 
 #define MAX_NUM_OF_ETHTOOL_RULES BIT(10)
+
+#define all_ones(field) (field == (__force typeof(field))-1)
+#define all_zeros_or_all_ones(field)		\
+	((field) == 0 || (field) == (__force typeof(field))-1)
+
 static int validate_flow(struct mlx5e_priv *priv,
 			 struct ethtool_rx_flow_spec *fs)
 {
+	struct ethtool_tcpip4_spec *l4_mask;
+	struct ethtool_usrip4_spec *l3_mask;
 	struct ethhdr *eth_mask;
 	int num_tuples = 0;
 
@@ -293,6 +402,52 @@ static int validate_flow(struct mlx5e_priv *priv,
 		if (eth_mask->h_proto)
 			num_tuples++;
 		break;
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		if (fs->m_u.tcp_ip4_spec.tos)
+			return -EINVAL;
+		l4_mask = &fs->m_u.tcp_ip4_spec;
+		if (l4_mask->ip4src) {
+			if (!all_ones(l4_mask->ip4src))
+				return -EINVAL;
+			num_tuples++;
+		}
+		if (l4_mask->ip4dst) {
+			if (!all_ones(l4_mask->ip4dst))
+				return -EINVAL;
+			num_tuples++;
+		}
+		if (l4_mask->psrc) {
+			if (!all_ones(l4_mask->psrc))
+				return -EINVAL;
+			num_tuples++;
+		}
+		if (l4_mask->pdst) {
+			if (!all_ones(l4_mask->pdst))
+				return -EINVAL;
+			num_tuples++;
+		}
+		/* Flow is TCP/UDP */
+		num_tuples++;
+		break;
+	case IP_USER_FLOW:
+		l3_mask = &fs->m_u.usr_ip4_spec;
+		if (l3_mask->l4_4_bytes || l3_mask->tos || l3_mask->proto ||
+		    fs->h_u.usr_ip4_spec.ip_ver != ETH_RX_NFC_IP4)
+			return -EINVAL;
+		if (l3_mask->ip4src) {
+			if (!all_ones(l3_mask->ip4src))
+				return -EINVAL;
+			num_tuples++;
+		}
+		if (l3_mask->ip4dst) {
+			if (!all_ones(l3_mask->ip4dst))
+				return -EINVAL;
+			num_tuples++;
+		}
+		/* Flow is IPv4 */
+		num_tuples++;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -308,6 +463,10 @@ static int validate_flow(struct mlx5e_priv *priv,
 		num_tuples++;
 	}
 
+	if (fs->flow_type & FLOW_MAC_EXT &&
+	    !is_zero_ether_addr(fs->m_ext.h_dest))
+		num_tuples++;
+
 	return num_tuples;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 83fa98f..b0a1304 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -80,7 +80,7 @@
 			   LEFTOVERS_NUM_PRIOS)
 
 #define ETHTOOL_PRIO_NUM_LEVELS 1
-#define ETHTOOL_NUM_PRIOS 4
+#define ETHTOOL_NUM_PRIOS 10
 #define ETHTOOL_MIN_LEVEL (KERNEL_MIN_LEVEL + ETHTOOL_NUM_PRIOS)
 /* Vlan, mac, ttc, aRFS */
 #define KERNEL_NIC_PRIO_NUM_LEVELS 4
-- 
2.8.0
