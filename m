From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 2/2] net/mlx5e: Offload TC matching on packets being IP fragments
Date: Wed,  7 Dec 2016 14:03:11 +0200
Message-ID: <1481112191-14115-3-git-send-email-ogerlitz@mellanox.com>
References: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37733 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752695AbcLGMDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:03:18 -0500
In-Reply-To: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable offloading of matching on packets being fragments.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index f07ef8c..f8829b5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -31,6 +31,7 @@
  */
 
 #include <net/flow_dissector.h>
+#include <net/sch_generic.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_skbedit.h>
@@ -363,7 +364,18 @@ static int __parse_cls_flower(struct mlx5e_priv *priv,
 			skb_flow_dissector_target(f->dissector,
 						  FLOW_DISSECTOR_KEY_CONTROL,
 						  f->key);
+
+		struct flow_dissector_key_control *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_CONTROL,
+						  f->mask);
 		addr_type = key->addr_type;
+
+		if (mask->flags & FLOW_DIS_IS_FRAGMENT) {
+			MLX5_SET(fte_match_set_lyr_2_4, headers_c, frag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, headers_v, frag,
+				 key->flags & FLOW_DIS_IS_FRAGMENT);
+		}
 	}
 
 	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
-- 
2.3.7
