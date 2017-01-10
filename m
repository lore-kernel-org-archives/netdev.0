From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 02/10] net/mlx5e: Warn when rejecting offload attempts of IP tunnels
Date: Tue, 10 Jan 2017 22:33:31 +0200
Message-ID: <1484080419-24256-3-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52050 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751097AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

We silently reject offloading of IPv6 tunnels, non vxlan tunnels,
vxlan tunnels where the dst port to match is not provided, etc.

Be a bit more verbose and print a warning so the user better
realizes what went wrong here and can fix it.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Fixes: bbd00f7e2349 ('net/mlx5e: Add TC tunnel release action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 30 ++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index b60fece..d2fc055 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -237,13 +237,16 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 
 		/* Full udp dst port must be given */
 		if (memchr_inv(&mask->dst, 0xff, sizeof(mask->dst)))
-			return -EOPNOTSUPP;
+			goto vxlan_match_offload_err;
 
 		if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->dst)) &&
 		    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap))
 			parse_vxlan_attr(spec, f);
-		else
+		else {
+			netdev_warn(priv->netdev,
+				    "%d isn't an offloaded vxlan udp dport\n", be16_to_cpu(key->dst));
 			return -EOPNOTSUPP;
+		}
 
 		MLX5_SET(fte_match_set_lyr_2_4, headers_c,
 			 udp_dport, ntohs(mask->dst));
@@ -255,7 +258,10 @@ static int parse_tunnel_attr(struct mlx5e_priv *priv,
 		MLX5_SET(fte_match_set_lyr_2_4, headers_v,
 			 udp_sport, ntohs(key->src));
 	} else { /* udp dst port must be given */
-			return -EOPNOTSUPP;
+vxlan_match_offload_err:
+		netdev_warn(priv->netdev,
+			    "IP tunnel decap offload supported only for vxlan, must set UDP dport\n");
+		return -EOPNOTSUPP;
 	}
 
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS)) {
@@ -346,6 +352,9 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			if (parse_tunnel_attr(priv, spec, f))
 				return -EOPNOTSUPP;
 			break;
+		case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
+			netdev_warn(priv->netdev,
+				    "IPv6 tunnel decap offload isn't supported\n");
 		default:
 			return -EOPNOTSUPP;
 		}
@@ -792,13 +801,17 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	int tunnel_type;
 	int err;
 
-	/* udp dst port must be given */
+	/* udp dst port must be set */
 	if (!memchr_inv(&key->tp_dst, 0, sizeof(key->tp_dst)))
-		return -EOPNOTSUPP;
+		goto vxlan_encap_offload_err;
 
 	/* setting udp src port isn't supported */
-	if (memchr_inv(&key->tp_src, 0, sizeof(key->tp_src)))
+	if (memchr_inv(&key->tp_src, 0, sizeof(key->tp_src))) {
+vxlan_encap_offload_err:
+		netdev_warn(priv->netdev,
+			    "must set udp dst port and not set udp src port\n");
 		return -EOPNOTSUPP;
+	}
 
 	if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->tp_dst)) &&
 	    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap)) {
@@ -806,6 +819,8 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 		info.tun_id = tunnel_id_to_key32(key->tun_id);
 		tunnel_type = MLX5_HEADER_TYPE_VXLAN;
 	} else {
+		netdev_warn(priv->netdev,
+			    "%d isn't an offloaded vxlan udp dport\n", be16_to_cpu(key->tp_dst));
 		return -EOPNOTSUPP;
 	}
 
@@ -813,6 +828,9 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	case AF_INET:
 		info.daddr = key->u.ipv4.dst;
 		break;
+	case AF_INET6:
+		netdev_warn(priv->netdev,
+			    "IPv6 tunnel encap offload isn't supported\n");
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.7.4
