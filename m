From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/12] net/mlx5e: Use the full tunnel key info for encapsulation offload house-keeping
Date: Tue, 24 Jan 2017 22:16:44 +0200
Message-ID: <20170124201652.2920-5-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54283 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750921AbdAXURa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:30 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Currently we use subset of the input tunnel key fields (id, ip daddr,
dst port) which are provided by upper layers to indentify flows that should
go through the same encapsulation and maintain the HW encapsulation table.

This is redundant and can get us wrong.

Instead, keep a copy of the ip tunnel info provided by the user
through TC and have the tunnel key part as the key to our internal hash.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 38 +++++++++--------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  9 ++----
 2 files changed, 17 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index a515444d2489..477b2796c12e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -668,15 +668,15 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	return 0;
 }
 
-static inline int cmp_encap_info(struct mlx5_encap_info *a,
-				 struct mlx5_encap_info *b)
+static inline int cmp_encap_info(struct ip_tunnel_key *a,
+				 struct ip_tunnel_key *b)
 {
 	return memcmp(a, b, sizeof(*a));
 }
 
-static inline int hash_encap_info(struct mlx5_encap_info *info)
+static inline int hash_encap_info(struct ip_tunnel_key *key)
 {
-	return jhash(info, sizeof(*info), 0);
+	return jhash(key, sizeof(*key), 0);
 }
 
 static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
@@ -762,6 +762,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 					  struct net_device **out_dev)
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
+	struct ip_tunnel_key *tun_key = &e->tun_info.key;
 	struct neighbour *n = NULL;
 	struct flowi4 fl4 = {};
 	char *encap_header;
@@ -777,13 +778,13 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
 		fl4.flowi4_proto = IPPROTO_UDP;
-		fl4.fl4_dport = e->tun_info.tp_dst;
+		fl4.fl4_dport = tun_key->tp_dst;
 		break;
 	default:
 		err = -EOPNOTSUPP;
 		goto out;
 	}
-	fl4.daddr = e->tun_info.daddr;
+	fl4.daddr = tun_key->u.ipv4.dst;
 
 	err = mlx5e_route_lookup_ipv4(priv, mirred_dev, out_dev,
 				      &fl4, &n, &saddr, &ttl);
@@ -805,9 +806,9 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	case MLX5_HEADER_TYPE_VXLAN:
 		encap_size = gen_vxlan_header_ipv4(*out_dev, encap_header,
 						   e->h_dest, ttl,
-						   e->tun_info.daddr,
-						   saddr, e->tun_info.tp_dst,
-						   e->tun_info.tun_id);
+						   tun_key->u.ipv4.dst,
+						   saddr, tun_key->tp_dst,
+						   tunnel_id_to_key32(tun_key->tun_id));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -831,13 +832,11 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	unsigned short family = ip_tunnel_info_af(tun_info);
 	struct ip_tunnel_key *key = &tun_info->key;
-	struct mlx5_encap_info info;
 	struct mlx5_encap_entry *e;
 	struct net_device *out_dev;
+	int tunnel_type, err;
 	uintptr_t hash_key;
 	bool found = false;
-	int tunnel_type;
-	int err;
 
 	/* udp dst port must be set */
 	if (!memchr_inv(&key->tp_dst, 0, sizeof(key->tp_dst)))
@@ -853,8 +852,6 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 
 	if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->tp_dst)) &&
 	    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap)) {
-		info.tp_dst = key->tp_dst;
-		info.tun_id = tunnel_id_to_key32(key->tun_id);
 		tunnel_type = MLX5_HEADER_TYPE_VXLAN;
 	} else {
 		netdev_warn(priv->netdev,
@@ -862,22 +859,17 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 		return -EOPNOTSUPP;
 	}
 
-	switch (family) {
-	case AF_INET:
-		info.daddr = key->u.ipv4.dst;
-		break;
-	case AF_INET6:
+	if (family == AF_INET6) {
 		netdev_warn(priv->netdev,
 			    "IPv6 tunnel encap offload isn't supported\n");
-	default:
 		return -EOPNOTSUPP;
 	}
 
-	hash_key = hash_encap_info(&info);
+	hash_key = hash_encap_info(key);
 
 	hash_for_each_possible_rcu(esw->offloads.encap_tbl, e,
 				   encap_hlist, hash_key) {
-		if (!cmp_encap_info(&e->tun_info, &info)) {
+		if (!cmp_encap_info(&e->tun_info.key, key)) {
 			found = true;
 			break;
 		}
@@ -892,7 +884,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	if (!e)
 		return -ENOMEM;
 
-	e->tun_info = info;
+	e->tun_info = *tun_info;
 	e->tunnel_type = tunnel_type;
 	INIT_LIST_HEAD(&e->flows);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 8661dd3f542c..cea1660d59ac 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -36,6 +36,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_link.h>
 #include <net/devlink.h>
+#include <net/ip_tunnels.h>
 #include <linux/mlx5/device.h>
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
@@ -274,18 +275,12 @@ enum {
 #define MLX5_FLOW_CONTEXT_ACTION_VLAN_POP  0x40
 #define MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH 0x80
 
-struct mlx5_encap_info {
-	__be32 daddr;
-	__be32 tun_id;
-	__be16 tp_dst;
-};
-
 struct mlx5_encap_entry {
 	struct hlist_node encap_hlist;
 	struct list_head flows;
 	u32 encap_id;
 	struct neighbour *n;
-	struct mlx5_encap_info tun_info;
+	struct ip_tunnel_info tun_info;
 	unsigned char h_dest[ETH_ALEN];	/* destination eth addr	*/
 
 	struct net_device *out_dev;
-- 
2.11.0
