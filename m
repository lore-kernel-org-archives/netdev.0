From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 11/12] IB/mlx5: Add flow steering utilities
Date: Sun, 10 Jan 2016 10:39:48 +0200
Message-ID: <1452415189-27950-12-git-send-email-ogerlitz@mellanox.com>
References: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51437 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753955AbcAJIlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jan 2016 03:41:19 -0500
In-Reply-To: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add three utility functions for support flow steering:

1. Parsing verbs flow attributes hardware steering specs.

2. Check if flow is multicast - this is required in order to decide to
which flow table will we add the steering rule.

3. Set outer headers in flow match criteria to zeros.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c    | 178 +++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h |   5 +
 include/linux/mlx5/fs.h              |  10 ++
 3 files changed, 193 insertions(+)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 7e97cb5..7799361 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -43,6 +43,8 @@
 #include <linux/mlx5/vport.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_umem.h>
+#include <linux/in.h>
+#include <linux/etherdevice.h>
 #include "user.h"
 #include "mlx5_ib.h"
 
@@ -835,6 +837,182 @@ static int mlx5_ib_dealloc_pd(struct ib_pd *pd)
 	return 0;
 }
 
+bool outer_header_zero(u32 *match_criteria)
+{
+	int size = MLX5_ST_SZ_BYTES(fte_match_param);
+	char *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_criteria,
+					     outer_headers);
+
+	return outer_headers_c[0] == 0 && !memcmp(outer_headers_c,
+						  outer_headers_c + 1,
+						  size - 1);
+}
+
+int parse_flow_attr(u32 *match_c, u32 *match_v,
+		    union ib_flow_spec *ib_spec)
+{
+	void *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_c,
+					     outer_headers);
+	void *outer_headers_v = MLX5_ADDR_OF(fte_match_param, match_v,
+					     outer_headers);
+	switch (ib_spec->type) {
+	case IB_FLOW_SPEC_ETH:
+		if (ib_spec->size != sizeof(ib_spec->eth))
+			return -EINVAL;
+
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+					     dmac_47_16),
+				ib_spec->eth.mask.dst_mac);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+					     dmac_47_16),
+				ib_spec->eth.val.dst_mac);
+
+		if (ib_spec->eth.mask.vlan_tag) {
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 vlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 vlan_tag, 1);
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 first_vid, ntohs(ib_spec->eth.mask.vlan_tag));
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 first_vid, ntohs(ib_spec->eth.val.vlan_tag));
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 first_cfi,
+				 ntohs(ib_spec->eth.mask.vlan_tag) >> 12);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 first_cfi,
+				 ntohs(ib_spec->eth.val.vlan_tag) >> 12);
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 first_prio,
+				 ntohs(ib_spec->eth.mask.vlan_tag) >> 13);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 first_prio,
+				 ntohs(ib_spec->eth.val.vlan_tag) >> 13);
+		}
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+			 ethertype, ntohs(ib_spec->eth.mask.ether_type));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+			 ethertype, ntohs(ib_spec->eth.val.ether_type));
+		break;
+	case IB_FLOW_SPEC_IPV4:
+		if (ib_spec->size != sizeof(ib_spec->ipv4))
+			return -EINVAL;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+			 ethertype, 0xffff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+			 ethertype, ETH_P_IP);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.mask.src_ip,
+		       sizeof(ib_spec->ipv4.mask.src_ip));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.val.src_ip,
+		       sizeof(ib_spec->ipv4.val.src_ip));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.mask.dst_ip,
+		       sizeof(ib_spec->ipv4.mask.dst_ip));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.val.dst_ip,
+		       sizeof(ib_spec->ipv4.val.dst_ip));
+		break;
+	case IB_FLOW_SPEC_TCP:
+		if (ib_spec->size != sizeof(ib_spec->tcp_udp))
+			return -EINVAL;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 0xff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 IPPROTO_TCP);
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, tcp_sport,
+			 ntohs(ib_spec->tcp_udp.mask.src_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, tcp_sport,
+			 ntohs(ib_spec->tcp_udp.val.src_port));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, tcp_dport,
+			 ntohs(ib_spec->tcp_udp.mask.dst_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, tcp_dport,
+			 ntohs(ib_spec->tcp_udp.val.dst_port));
+		break;
+	case IB_FLOW_SPEC_UDP:
+		if (ib_spec->size != sizeof(ib_spec->tcp_udp))
+			return -EINVAL;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 0xff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 IPPROTO_UDP);
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, udp_sport,
+			 ntohs(ib_spec->tcp_udp.mask.src_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, udp_sport,
+			 ntohs(ib_spec->tcp_udp.val.src_port));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, udp_dport,
+			 ntohs(ib_spec->tcp_udp.mask.dst_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, udp_dport,
+			 ntohs(ib_spec->tcp_udp.val.dst_port));
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* If a flow could catch both multicast and unicast packets,
+ * it won't fall into the multicast flow steering table and this rule
+ * could steal other multicast packets.
+ */
+bool flow_is_multicast_only(struct ib_flow_attr *ib_attr)
+{
+	struct ib_flow_spec_eth *eth_spec;
+
+	if (ib_attr->type != IB_FLOW_ATTR_NORMAL ||
+	    ib_attr->size < sizeof(struct ib_flow_attr) +
+	    sizeof(struct ib_flow_spec_eth) ||
+	    ib_attr->num_of_specs < 1)
+		return false;
+
+	eth_spec = (struct ib_flow_spec_eth *)(ib_attr + 1);
+	if (eth_spec->type != IB_FLOW_SPEC_ETH ||
+	    eth_spec->size != sizeof(*eth_spec))
+		return false;
+
+	return is_multicast_ether_addr(eth_spec->mask.dst_mac) &&
+	       is_multicast_ether_addr(eth_spec->val.dst_mac);
+}
+
+bool is_valid_attr(struct ib_flow_attr *flow_attr)
+{
+	union ib_flow_spec *ib_spec = (union ib_flow_spec *)(flow_attr + 1);
+	bool has_ipv4_spec = false;
+	bool eth_type_ipv4 = true;
+	unsigned int spec_index;
+
+	/* Validate that ethertype is correct */
+	for (spec_index = 0; spec_index < flow_attr->num_of_specs; spec_index++) {
+		if (ib_spec->type == IB_FLOW_SPEC_ETH &&
+		    ib_spec->eth.mask.ether_type) {
+			if (!((ib_spec->eth.mask.ether_type == htons(0xffff)) &&
+			      ib_spec->eth.val.ether_type == htons(ETH_P_IP)))
+				eth_type_ipv4 = false;
+		} else if (ib_spec->type == IB_FLOW_SPEC_IPV4) {
+			has_ipv4_spec = true;
+		}
+		ib_spec = (void *)ib_spec + ib_spec->size;
+	}
+	return !has_ipv4_spec || eth_type_ipv4;
+}
+
 static int mlx5_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibqp->device);
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 6333472..1e9dcbe 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -662,4 +662,9 @@ static inline int is_qp1(enum ib_qp_type qp_type)
 #define MLX5_MAX_UMR_SHIFT 16
 #define MLX5_MAX_UMR_PAGES (1 << MLX5_MAX_UMR_SHIFT)
 
+bool outer_header_zero(u32 *match_criteria);
+int parse_flow_attr(u32 *match_c, u32 *match_v,
+		    union ib_flow_spec *ib_spec);
+bool flow_is_multicast_only(struct ib_flow_attr *ib_attr);
+bool is_valid_attr(struct ib_flow_attr *flow_attr);
 #endif /* MLX5_IB_H */
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index a943412..8230caa 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -38,6 +38,16 @@
 
 #define MLX5_FS_DEFAULT_FLOW_TAG 0x0
 
+#define LEFTOVERS_RULE_NUM	 2
+static inline void build_leftovers_ft_param(int *priority,
+					    int *n_ent,
+					    int *n_grp)
+{
+	*priority = 0; /* Priority of leftovers_prio-0 */
+	*n_ent = LEFTOVERS_RULE_NUM;
+	*n_grp = LEFTOVERS_RULE_NUM;
+}
+
 enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_BYPASS,
 	MLX5_FLOW_NAMESPACE_KERNEL,
-- 
2.3.7
