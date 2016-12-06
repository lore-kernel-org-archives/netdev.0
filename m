From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx5e: Offload TC matching on packets being IP fragments
Date: Tue,  6 Dec 2016 14:32:59 +0200
Message-ID: <1481027579-23195-4-git-send-email-ogerlitz@mellanox.com>
References: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41020 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752597AbcLFMdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:33:10 -0500
In-Reply-To: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable offloading of matching on packets being fragments.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
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
