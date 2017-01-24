From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/12] net/mlx5e: Maximize ip tunnel key usage on the TC offloading path
Date: Tue, 24 Jan 2017 22:16:45 +0200
Message-ID: <20170124201652.2920-6-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54288 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750993AbdAXURa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:30 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Use more fields out of the tunnel key (e.g the tunnel source IP address)
provided by upper layers for the route lookup done on the encap offload path.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 477b2796c12e..3d0dbfb018ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -684,7 +684,6 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 				   struct net_device **out_dev,
 				   struct flowi4 *fl4,
 				   struct neighbour **out_n,
-				   __be32 *saddr,
 				   int *out_ttl)
 {
 	struct rtable *rt;
@@ -714,7 +713,6 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 		return -ENOMEM;
 
 	*out_n = n;
-	*saddr = fl4->saddr;
 	*out_dev = rt->dst.dev;
 
 	return 0;
@@ -763,13 +761,10 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
 	struct ip_tunnel_key *tun_key = &e->tun_info.key;
+	int encap_size, ttl, err;
 	struct neighbour *n = NULL;
 	struct flowi4 fl4 = {};
 	char *encap_header;
-	int encap_size;
-	__be32 saddr;
-	int ttl;
-	int err;
 
 	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
 	if (!encap_header)
@@ -784,10 +779,12 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 		err = -EOPNOTSUPP;
 		goto out;
 	}
+	fl4.flowi4_tos = tun_key->tos;
 	fl4.daddr = tun_key->u.ipv4.dst;
+	fl4.saddr = tun_key->u.ipv4.src;
 
 	err = mlx5e_route_lookup_ipv4(priv, mirred_dev, out_dev,
-				      &fl4, &n, &saddr, &ttl);
+				      &fl4, &n, &ttl);
 	if (err)
 		goto out;
 
@@ -806,8 +803,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	case MLX5_HEADER_TYPE_VXLAN:
 		encap_size = gen_vxlan_header_ipv4(*out_dev, encap_header,
 						   e->h_dest, ttl,
-						   tun_key->u.ipv4.dst,
-						   saddr, tun_key->tp_dst,
+						   fl4.daddr,
+						   fl4.saddr, tun_key->tp_dst,
 						   tunnel_id_to_key32(tun_key->tun_id));
 		break;
 	default:
-- 
2.11.0
