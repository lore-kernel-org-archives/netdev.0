From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] spectrum: flower: Treat ETH_P_ALL as a special case and translate for HW
Date: Thu,  9 Feb 2017 14:42:03 +0100
Message-ID: <1486647723-14776-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33769 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752190AbdBIOOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:14:19 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so3075405wmv.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:14:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

HW does not understand ETH_P_ALL. So treat this special case differently
and translate to 0/0 key/mask. That will allow HW to match all ethertypes.

Fixes: 7aa0f5aa9030 ("mlxsw: spectrum: Implement TC flower offload")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 35b147a..22ab429 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -197,11 +197,18 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 			skb_flow_dissector_target(f->dissector,
 						  FLOW_DISSECTOR_KEY_BASIC,
 						  f->mask);
-		ip_proto = key->ip_proto;
+		u16 n_proto_key = ntohs(key->n_proto);
+		u16 n_proto_mask = ntohs(mask->n_proto);
+
+		if (n_proto_key == ETH_P_ALL) {
+			n_proto_key = 0;
+			n_proto_mask = 0;
+		}
 		mlxsw_sp_acl_rulei_keymask_u32(rulei,
 					       MLXSW_AFK_ELEMENT_ETHERTYPE,
-					       ntohs(key->n_proto),
-					       ntohs(mask->n_proto));
+					       n_proto_key, n_proto_mask);
+
+		ip_proto = key->ip_proto;
 		mlxsw_sp_acl_rulei_keymask_u32(rulei,
 					       MLXSW_AFK_ELEMENT_IP_PROTO,
 					       key->ip_proto, mask->ip_proto);
-- 
2.7.4
