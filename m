From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 9/9] net/mlx5e: Add TC vlan match parsing
Date: Thu, 22 Sep 2016 20:01:49 +0300
Message-ID: <1474563709-17943-10-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49011 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964977AbcIVRCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:16 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Enhance the parsing of offloaded TC rules matches to handle vlans.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index e61bd52..a350b71 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -164,6 +164,7 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 	    ~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
 	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
 	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_VLAN) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_PORTS))) {
@@ -227,6 +228,24 @@ static int parse_cls_flower(struct mlx5e_priv *priv, struct mlx5_flow_spec *spec
 				key->src);
 	}
 
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_VLAN)) {
+		struct flow_dissector_key_vlan *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_VLAN,
+						  f->key);
+		struct flow_dissector_key_vlan *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_VLAN,
+						  f->mask);
+		if (mask->vlan_id) {
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, vlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, vlan_tag, 1);
+
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, first_vid, mask->vlan_id);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, first_vid, key->vlan_id);
+		}
+	}
+
 	if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
 		struct flow_dissector_key_ipv4_addrs *key =
 			skb_flow_dissector_target(f->dissector,
-- 
2.7.4
