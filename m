From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 03/10] net/mlx5e: TC ipv4 tunnel encap offload error flow fixes
Date: Tue, 10 Jan 2017 22:33:32 +0200
Message-ID: <1484080419-24256-4-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52044 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751108AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When the route lookup fails we should return the actual error.

When the neigh isn't valid, we should return -EOPNOTSUPP as done
in similar cases along the code.

When the offload can't take place as of invalid neigh etc, we
must release the neigh.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index d2fc055..b62f06f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -656,17 +656,14 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 
 #if IS_ENABLED(CONFIG_INET)
 	rt = ip_route_output_key(dev_net(mirred_dev), fl4);
-	if (IS_ERR(rt)) {
-		pr_warn("%s: no route to %pI4\n", __func__, &fl4->daddr);
-		return -EOPNOTSUPP;
-	}
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
 #else
 	return -EOPNOTSUPP;
 #endif
 
 	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev)) {
-		pr_warn("%s: Can't offload the flow, netdevices aren't on the same HW e-switch\n",
-			__func__);
+		pr_warn("%s: can't offload, devices not on same HW e-switch\n", __func__);
 		ip_rt_put(rt);
 		return -EOPNOTSUPP;
 	}
@@ -727,8 +724,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 					  struct net_device **out_dev)
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
+	struct neighbour *n = NULL;
 	struct flowi4 fl4 = {};
-	struct neighbour *n;
 	char *encap_header;
 	int encap_size;
 	__be32 saddr;
@@ -759,7 +756,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	e->out_dev = *out_dev;
 
 	if (!(n->nud_state & NUD_VALID)) {
-		err = -ENOTSUPP;
+		pr_warn("%s: can't offload, neighbour to %pI4 invalid\n", __func__, &fl4.daddr);
+		err = -EOPNOTSUPP;
 		goto out;
 	}
 
@@ -781,6 +779,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
 			       encap_size, encap_header, &e->encap_id);
 out:
+	if (err && n)
+		neigh_release(n);
 	kfree(encap_header);
 	return err;
 }
-- 
2.7.4
