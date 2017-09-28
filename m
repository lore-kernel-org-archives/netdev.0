From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 04/11] net/mlx5e: Fix erroneous freeing of encap header buffer
Date: Thu, 28 Sep 2017 07:41:25 +0300
Message-ID: <20170928044132.30940-5-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54384 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751276AbdI1EmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:05 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

In case the neighbour for the tunnel destination isn't valid,
we send a neighbour update request but we free the encap
header buffer. This is wrong, because we still need it for
allocating a HW encap entry once the neighbour is available.

Fix that by skipping freeing it if we wait for neighbour.

Fixes: 232c001398ae ('net/mlx5e: Add support to neighbour update flow')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index da503e6411da..4e2fc016bdd6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1564,7 +1564,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 		break;
 	default:
 		err = -EOPNOTSUPP;
-		goto out;
+		goto free_encap;
 	}
 	fl4.flowi4_tos = tun_key->tos;
 	fl4.daddr = tun_key->u.ipv4.dst;
@@ -1573,7 +1573,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	err = mlx5e_route_lookup_ipv4(priv, mirred_dev, &out_dev,
 				      &fl4, &n, &ttl);
 	if (err)
-		goto out;
+		goto free_encap;
 
 	/* used by mlx5e_detach_encap to lookup a neigh hash table
 	 * entry in the neigh hash table when a user deletes a rule
@@ -1590,7 +1590,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	 */
 	err = mlx5e_rep_encap_entry_attach(netdev_priv(out_dev), e);
 	if (err)
-		goto out;
+		goto free_encap;
 
 	read_lock_bh(&n->lock);
 	nud_state = n->nud_state;
@@ -1630,8 +1630,9 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 
 destroy_neigh_entry:
 	mlx5e_rep_encap_entry_detach(netdev_priv(e->out_dev), e);
-out:
+free_encap:
 	kfree(encap_header);
+out:
 	if (n)
 		neigh_release(n);
 	return err;
@@ -1668,7 +1669,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 		break;
 	default:
 		err = -EOPNOTSUPP;
-		goto out;
+		goto free_encap;
 	}
 
 	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tun_key->tos), tun_key->label);
@@ -1678,7 +1679,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	err = mlx5e_route_lookup_ipv6(priv, mirred_dev, &out_dev,
 				      &fl6, &n, &ttl);
 	if (err)
-		goto out;
+		goto free_encap;
 
 	/* used by mlx5e_detach_encap to lookup a neigh hash table
 	 * entry in the neigh hash table when a user deletes a rule
@@ -1695,7 +1696,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	 */
 	err = mlx5e_rep_encap_entry_attach(netdev_priv(out_dev), e);
 	if (err)
-		goto out;
+		goto free_encap;
 
 	read_lock_bh(&n->lock);
 	nud_state = n->nud_state;
@@ -1736,8 +1737,9 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 
 destroy_neigh_entry:
 	mlx5e_rep_encap_entry_detach(netdev_priv(e->out_dev), e);
-out:
+free_encap:
 	kfree(encap_header);
+out:
 	if (n)
 		neigh_release(n);
 	return err;
-- 
2.13.0
