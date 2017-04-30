From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/15] net/mlx5e: Remove output device parameter from create encap header helpers definition
Date: Sun, 30 Apr 2017 16:20:05 +0300
Message-ID: <20170430132016.27012-5-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46718 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754994AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Passing output device parameter to the helper functions that deal with
creation of encapsulation headers is redundant. Output device parameter
can be defined inside those helpers, no need to pass it. Refactor the code by
removing the parameter from the function signature.

This patch doesn't change any functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 29 ++++++++++++-------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3582ebcd4173..25ecffa1a3df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1211,12 +1211,12 @@ static void gen_vxlan_header_ipv6(struct net_device *out_dev,
 
 static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 					  struct net_device *mirred_dev,
-					  struct mlx5e_encap_entry *e,
-					  struct net_device **out_dev)
+					  struct mlx5e_encap_entry *e)
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
 	int ipv4_encap_size = ETH_HLEN + sizeof(struct iphdr) + VXLAN_HLEN;
 	struct ip_tunnel_key *tun_key = &e->tun_info.key;
+	struct net_device *out_dev;
 	struct neighbour *n = NULL;
 	struct flowi4 fl4 = {};
 	char *encap_header;
@@ -1245,7 +1245,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	fl4.daddr = tun_key->u.ipv4.dst;
 	fl4.saddr = tun_key->u.ipv4.src;
 
-	err = mlx5e_route_lookup_ipv4(priv, mirred_dev, out_dev,
+	err = mlx5e_route_lookup_ipv4(priv, mirred_dev, &out_dev,
 				      &fl4, &n, &ttl);
 	if (err)
 		goto out;
@@ -1257,13 +1257,13 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	}
 
 	e->n = n;
-	e->out_dev = *out_dev;
+	e->out_dev = out_dev;
 
-	neigh_ha_snapshot(e->h_dest, n, *out_dev);
+	neigh_ha_snapshot(e->h_dest, n, out_dev);
 
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
-		gen_vxlan_header_ipv4(*out_dev, encap_header,
+		gen_vxlan_header_ipv4(out_dev, encap_header,
 				      ipv4_encap_size, e->h_dest, ttl,
 				      fl4.daddr,
 				      fl4.saddr, tun_key->tp_dst,
@@ -1285,12 +1285,12 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 
 static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 					  struct net_device *mirred_dev,
-					  struct mlx5e_encap_entry *e,
-					  struct net_device **out_dev)
+					  struct mlx5e_encap_entry *e)
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
 	int ipv6_encap_size = ETH_HLEN + sizeof(struct ipv6hdr) + VXLAN_HLEN;
 	struct ip_tunnel_key *tun_key = &e->tun_info.key;
+	struct net_device *out_dev;
 	struct neighbour *n = NULL;
 	struct flowi6 fl6 = {};
 	char *encap_header;
@@ -1320,7 +1320,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	fl6.daddr = tun_key->u.ipv6.dst;
 	fl6.saddr = tun_key->u.ipv6.src;
 
-	err = mlx5e_route_lookup_ipv6(priv, mirred_dev, out_dev,
+	err = mlx5e_route_lookup_ipv6(priv, mirred_dev, &out_dev,
 				      &fl6, &n, &ttl);
 	if (err)
 		goto out;
@@ -1332,13 +1332,13 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	}
 
 	e->n = n;
-	e->out_dev = *out_dev;
+	e->out_dev = out_dev;
 
-	neigh_ha_snapshot(e->h_dest, n, *out_dev);
+	neigh_ha_snapshot(e->h_dest, n, out_dev);
 
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
-		gen_vxlan_header_ipv6(*out_dev, encap_header,
+		gen_vxlan_header_ipv6(out_dev, encap_header,
 				      ipv6_encap_size, e->h_dest, ttl,
 				      &fl6.daddr,
 				      &fl6.saddr, tun_key->tp_dst,
@@ -1371,7 +1371,6 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 	struct ip_tunnel_key *key = &tun_info->key;
 	struct mlx5e_encap_entry *e;
-	struct net_device *out_dev;
 	int tunnel_type, err = 0;
 	uintptr_t hash_key;
 	bool found = false;
@@ -1419,9 +1418,9 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	INIT_LIST_HEAD(&e->flows);
 
 	if (family == AF_INET)
-		err = mlx5e_create_encap_header_ipv4(priv, mirred_dev, e, &out_dev);
+		err = mlx5e_create_encap_header_ipv4(priv, mirred_dev, e);
 	else if (family == AF_INET6)
-		err = mlx5e_create_encap_header_ipv6(priv, mirred_dev, e, &out_dev);
+		err = mlx5e_create_encap_header_ipv6(priv, mirred_dev, e);
 
 	if (err)
 		goto out_err;
-- 
2.11.0
