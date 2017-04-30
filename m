From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/15] net/mlx5: Remove encap entry pointer from the eswitch flow attributes
Date: Sun, 30 Apr 2017 16:20:03 +0300
Message-ID: <20170430132016.27012-3-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46743 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756761AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Encap wise, the tc eswitch flow attribute struct needs to have
only the encap ID which is programmed later to the HW and none
of the higher level encap params, fix that.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 29 ++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  2 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  2 +-
 3 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 7d379a189b63..c7b034eeb149 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1362,16 +1362,18 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 			      struct ip_tunnel_info *tun_info,
 			      struct net_device *mirred_dev,
-			      struct mlx5_esw_flow_attr *attr)
+			      struct net_device **encap_dev,
+			      struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct net_device *up_dev = mlx5_eswitch_get_uplink_netdev(esw);
-	struct mlx5e_priv *up_priv = netdev_priv(up_dev);
 	unsigned short family = ip_tunnel_info_af(tun_info);
+	struct mlx5e_priv *up_priv = netdev_priv(up_dev);
+	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 	struct ip_tunnel_key *key = &tun_info->key;
 	struct mlx5_encap_entry *e;
 	struct net_device *out_dev;
-	int tunnel_type, err = -EOPNOTSUPP;
+	int tunnel_type, err = 0;
 	uintptr_t hash_key;
 	bool found = false;
 
@@ -1406,10 +1408,8 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 		}
 	}
 
-	if (found) {
-		attr->encap = e;
-		return 0;
-	}
+	if (found)
+		goto attach_flow;
 
 	e = kzalloc(sizeof(*e), GFP_KERNEL);
 	if (!e)
@@ -1427,10 +1427,14 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	if (err)
 		goto out_err;
 
-	attr->encap = e;
 	hash_add_rcu(esw->offloads.encap_tbl, &e->encap_hlist, hash_key);
 
-	return err;
+attach_flow:
+	list_add(&flow->encap, &e->flows);
+	*encap_dev = e->out_dev;
+	attr->encap_id = e->encap_id;
+
+	return 0;
 
 out_err:
 	kfree(e);
@@ -1475,7 +1479,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 		if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
-			struct net_device *out_dev;
+			struct net_device *out_dev, *encap_dev = NULL;
 			struct mlx5e_priv *out_priv;
 
 			out_dev = __dev_get_by_index(dev_net(priv->netdev), ifindex);
@@ -1489,14 +1493,13 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				attr->out_rep = rpriv->rep;
 			} else if (encap) {
 				err = mlx5e_attach_encap(priv, info,
-							 out_dev, attr);
+							 out_dev, &encap_dev, flow);
 				if (err)
 					return err;
-				list_add(&flow->encap, &attr->encap->flows);
 				attr->action |= MLX5_FLOW_CONTEXT_ACTION_ENCAP |
 					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
 					MLX5_FLOW_CONTEXT_ACTION_COUNT;
-				out_priv = netdev_priv(attr->encap->out_dev);
+				out_priv = netdev_priv(encap_dev);
 				rpriv = out_priv->ppriv;
 				attr->out_rep = rpriv->rep;
 			} else {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 1e7f21be1233..9056961689fa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -308,7 +308,7 @@ struct mlx5_esw_flow_attr {
 	int	action;
 	u16	vlan;
 	bool	vlan_handled;
-	struct mlx5_encap_entry *encap;
+	u32	encap_id;
 	u32	mod_hdr_id;
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index d297354e8ea9..f991f669047e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -92,7 +92,7 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 		flow_act.modify_id = attr->mod_hdr_id;
 
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
-		flow_act.encap_id = attr->encap->encap_id;
+		flow_act.encap_id = attr->encap_id;
 
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
 				   spec, &flow_act, dest, i);
-- 
2.11.0
