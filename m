From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 01/10] net/mlx5e: Properly handle offloading of source udp port for IP tunnels
Date: Tue, 10 Jan 2017 22:33:30 +0200
Message-ID: <1484080419-24256-2-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52049 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751059AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We can offload the matching on source udp port of ip tunnels for
decapsulation. We can not offload setting source udp port for tunnels
as part of encapsulation. Fix both the code that deals with matching
offload (decap) and the code that deal with encap offload to align with
that.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Fixes: bbd00f7e2349 ('net/mlx5e: Add TC tunnel release action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index f8829b5..b60fece 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -239,10 +239,6 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 		if (memchr_inv(&mask->dst, 0xff, sizeof(mask->dst)))
 			return -EOPNOTSUPP;
 
-		/* udp src port isn't supported */
-		if (memchr_inv(&mask->src, 0, sizeof(mask->src)))
-			return -EOPNOTSUPP;
-
 		if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->dst)) &&
 		    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap))
 			parse_vxlan_attr(spec, f);
@@ -254,6 +250,10 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
 			 udp_dport, ntohs(key->dst));
 
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c,
+			 udp_sport, ntohs(mask->src));
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
+			 udp_sport, ntohs(key->src));
 	} else { /* udp dst port must be given */
 			return -EOPNOTSUPP;
 	}
@@ -796,6 +796,10 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	if (!memchr_inv(&key->tp_dst, 0, sizeof(key->tp_dst)))
 		return -EOPNOTSUPP;
 
+	/* setting udp src port isn't supported */
+	if (memchr_inv(&key->tp_src, 0, sizeof(key->tp_src)))
+		return -EOPNOTSUPP;
+
 	if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->tp_dst)) &&
 	    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap)) {
 		info.tp_dst = key->tp_dst;
-- 
2.7.4
