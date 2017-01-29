From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 5/8] net/mlx5e: Support TC encapsulation offloads with upper devices
Date: Sun, 29 Jan 2017 23:46:23 +0200
Message-ID: <20170129214626.21977-6-saeedm@mellanox.com>
References: <20170129214626.21977-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41595 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750834AbdA2Vqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 16:46:43 -0500
In-Reply-To: <20170129214626.21977-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

When tunneling is used, some virtualizations systems set the (mlx5e) uplink
device to be stacked under upper devices such as bridge or ovs internal
port, where the VTEP IP address used for the encapsulation is set on
that upper device.

In order to support such use-cases, we also deal with a setup where the
egress mirred device isn't representing a port on the HW e-switch to where
the ingress device belongs. We use eswitch service function which returns
the uplink and set it as the egress device of the tc encap rule.

Fixes: a54e20b4fcae ("net/mlx5e: Add basic TC tunnel set action for SRIOV offloads")
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 46bef6a26a8c..c5282b6aba8b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -663,6 +663,7 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 				   __be32 *saddr,
 				   int *out_ttl)
 {
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct rtable *rt;
 	struct neighbour *n = NULL;
 	int ttl;
@@ -677,12 +678,11 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 #else
 	return -EOPNOTSUPP;
 #endif
-
-	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev)) {
-		pr_warn("%s: can't offload, devices not on same HW e-switch\n", __func__);
-		ip_rt_put(rt);
-		return -EOPNOTSUPP;
-	}
+	/* if the egress device isn't on the same HW e-switch, we use the uplink */
+	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev))
+		*out_dev = mlx5_eswitch_get_uplink_netdev(esw);
+	else
+		*out_dev = rt->dst.dev;
 
 	ttl = ip4_dst_hoplimit(&rt->dst);
 	n = dst_neigh_lookup(&rt->dst, &fl4->daddr);
@@ -693,7 +693,6 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 	*out_n = n;
 	*saddr = fl4->saddr;
 	*out_ttl = ttl;
-	*out_dev = rt->dst.dev;
 
 	return 0;
 }
-- 
2.11.0
