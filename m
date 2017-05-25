From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx5e: Offload TC matching on ip tos / traffic-class
Date: Thu, 25 May 2017 16:24:39 +0300
Message-ID: <1495718679-20693-5-git-send-email-ogerlitz@mellanox.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53784 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750913AbdEYNYp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 09:24:45 -0400
In-Reply-To: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable offloading of TC matching on ipv4 tos or ipv6 traffic-class.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 26 ++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 8e856cd..f8403fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -581,7 +581,8 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_ENC_PORTS)	|
 	      BIT(FLOW_DISSECTOR_KEY_ENC_CONTROL) |
-	      BIT(FLOW_DISSECTOR_KEY_TCP))) {
+	      BIT(FLOW_DISSECTOR_KEY_TCP) |
+	      BIT(FLOW_DISSECTOR_KEY_IP))) {
 		netdev_warn(priv->netdev, "Unsupported key used: 0x%x\n",
 			    f->dissector->used_keys);
 		return -EOPNOTSUPP;
@@ -808,6 +809,29 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			*min_inline = MLX5_INLINE_MODE_TCP_UDP;
 	}
 
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_IP)) {
+		struct flow_dissector_key_ip *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IP,
+						  f->key);
+		struct flow_dissector_key_ip *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IP,
+						  f->mask);
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_ecn, mask->tos & 0x3);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_ecn, key->tos & 0x3);
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, ip_dscp, mask->tos >> 2);
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, ip_dscp, key->tos  >> 2);
+
+		if (mask->tos)
+			*min_inline = MLX5_INLINE_MODE_IP;
+
+		if (mask->ttl) /* currently not supported */
+			return -EOPNOTSUPP;
+	}
+
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_TCP)) {
 		struct flow_dissector_key_tcp *key =
 			skb_flow_dissector_target(f->dissector,
-- 
2.3.7
