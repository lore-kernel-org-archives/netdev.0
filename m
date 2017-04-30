From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/15] net/mlx5e: Move the encap entry structure from the eswitch header
Date: Sun, 30 Apr 2017 16:20:04 +0300
Message-ID: <20170430132016.27012-4-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46742 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756103AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The encap entry structure isn't manipulated by the eswitch code,
hence it can/needs to be removed from the eswitch header.

Do that, and change it to have mlx5e_ prefix.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  | 13 +++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 11 +++++------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 13 -------------
 3 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
index b6595a699dc1..425cb1b0bf02 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -33,6 +33,7 @@
 #ifndef __MLX5E_REP_H__
 #define __MLX5E_REP_H__
 
+#include <net/ip_tunnels.h>
 #include "eswitch.h"
 #include "en.h"
 
@@ -40,6 +41,18 @@ struct mlx5e_rep_priv {
 	struct mlx5_eswitch_rep *rep;
 };
 
+struct mlx5e_encap_entry {
+	struct hlist_node encap_hlist;
+	struct list_head flows;
+	u32 encap_id;
+	struct neighbour *n;
+	struct ip_tunnel_info tun_info;
+	unsigned char h_dest[ETH_ALEN];	/* destination eth addr	*/
+
+	struct net_device *out_dev;
+	int tunnel_type;
+};
+
 void mlx5e_register_vport_reps(struct mlx5e_priv *priv);
 void mlx5e_unregister_vport_reps(struct mlx5e_priv *priv);
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index c7b034eeb149..3582ebcd4173 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -264,9 +264,9 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 
 	list_del(&flow->encap);
 	if (list_empty(next)) {
-		struct mlx5_encap_entry *e;
+		struct mlx5e_encap_entry *e;
 
-		e = list_entry(next, struct mlx5_encap_entry, flows);
+		e = list_entry(next, struct mlx5e_encap_entry, flows);
 		if (e->n) {
 			mlx5_encap_dealloc(priv->mdev, e->encap_id);
 			neigh_release(e->n);
@@ -1211,7 +1211,7 @@ static void gen_vxlan_header_ipv6(struct net_device *out_dev,
 
 static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 					  struct net_device *mirred_dev,
-					  struct mlx5_encap_entry *e,
+					  struct mlx5e_encap_entry *e,
 					  struct net_device **out_dev)
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
@@ -1285,9 +1285,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 
 static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 					  struct net_device *mirred_dev,
-					  struct mlx5_encap_entry *e,
+					  struct mlx5e_encap_entry *e,
 					  struct net_device **out_dev)
-
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
 	int ipv6_encap_size = ETH_HLEN + sizeof(struct ipv6hdr) + VXLAN_HLEN;
@@ -1371,7 +1370,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	struct mlx5e_priv *up_priv = netdev_priv(up_dev);
 	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 	struct ip_tunnel_key *key = &tun_info->key;
-	struct mlx5_encap_entry *e;
+	struct mlx5e_encap_entry *e;
 	struct net_device *out_dev;
 	int tunnel_type, err = 0;
 	uintptr_t hash_key;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 9056961689fa..751a673de97a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -36,7 +36,6 @@
 #include <linux/if_ether.h>
 #include <linux/if_link.h>
 #include <net/devlink.h>
-#include <net/ip_tunnels.h>
 #include <linux/mlx5/device.h>
 
 #define MLX5_MAX_UC_PER_VPORT(dev) \
@@ -289,18 +288,6 @@ enum {
 #define MLX5_FLOW_CONTEXT_ACTION_VLAN_POP  0x4000
 #define MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH 0x8000
 
-struct mlx5_encap_entry {
-	struct hlist_node encap_hlist;
-	struct list_head flows;
-	u32 encap_id;
-	struct neighbour *n;
-	struct ip_tunnel_info tun_info;
-	unsigned char h_dest[ETH_ALEN];	/* destination eth addr	*/
-
-	struct net_device *out_dev;
-	int tunnel_type;
-};
-
 struct mlx5_esw_flow_attr {
 	struct mlx5_eswitch_rep *in_rep;
 	struct mlx5_eswitch_rep *out_rep;
-- 
2.11.0
