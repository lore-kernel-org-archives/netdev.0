From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 3/4] net/mlx5e: Offload TC matching on tcp flags
Date: Thu,  1 Jun 2017 21:37:39 +0300
Message-ID: <1496342260-28199-4-git-send-email-ogerlitz@mellanox.com>
References: <1496342260-28199-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45554 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751225AbdFAShu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 14:37:50 -0400
In-Reply-To: <1496342260-28199-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable offloading of TC matching on tcp flags.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 7914a32..066045b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -581,7 +581,8 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_ENC_PORTS)	|
-	      BIT(FLOW_DISSECTOR_KEY_ENC_CONTROL))) {
+	      BIT(FLOW_DISSECTOR_KEY_ENC_CONTROL) |
+	      BIT(FLOW_DISSECTOR_KEY_TCP))) {
 		netdev_warn(priv->netdev, "Unsupported key used: 0x%x\n",
 			    f->dissector->used_keys);
 		return -EOPNOTSUPP;
@@ -808,6 +809,25 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			*min_inline = MLX5_INLINE_MODE_TCP_UDP;
 	}
 
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_TCP)) {
+		struct flow_dissector_key_tcp *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_TCP,
+						  f->key);
+		struct flow_dissector_key_tcp *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_TCP,
+						  f->mask);
+
+		MLX5_SET(fte_match_set_lyr_2_4, headers_c, tcp_flags,
+			 ntohs(mask->flags));
+		MLX5_SET(fte_match_set_lyr_2_4, headers_v, tcp_flags,
+			 ntohs(key->flags));
+
+		if (mask->flags)
+			*min_inline = MLX5_INLINE_MODE_TCP_UDP;
+	}
+
 	return 0;
 }
 
-- 
2.3.7
