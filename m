From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] mlxsw: spectrum_flower: Add support for ip ttl
Date: Mon, 17 Jul 2017 14:07:28 +0200
Message-ID: <20170717120731.3875-4-jiri@resnulli.us>
References: <20170717120731.3875-1-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34444 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbdGQMHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:07:42 -0400
Received: by mail-wm0-f68.google.com with SMTP id p204so22722725wmg.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:07:41 -0700 (PDT)
In-Reply-To: <20170717120731.3875-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Support offloading rules that match on ip ttl.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 37 ++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 21bb2bf..84fe33c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -212,11 +212,39 @@ static int mlxsw_sp_flower_parse_tcp(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
+static int mlxsw_sp_flower_parse_ip(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_acl_rule_info *rulei,
+				    struct tc_cls_flower_offload *f,
+				    u16 n_proto)
+{
+	struct flow_dissector_key_ip *key, *mask;
+
+	if (!dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_IP))
+		return 0;
+
+	if (n_proto != ETH_P_IP && n_proto != ETH_P_IPV6) {
+		dev_err(mlxsw_sp->bus_info->dev, "IP keys supported only for IPv4/6\n");
+		return -EINVAL;
+	}
+
+	key = skb_flow_dissector_target(f->dissector,
+					FLOW_DISSECTOR_KEY_IP,
+					f->key);
+	mask = skb_flow_dissector_target(f->dissector,
+					 FLOW_DISSECTOR_KEY_IP,
+					 f->mask);
+	mlxsw_sp_acl_rulei_keymask_u32(rulei, MLXSW_AFK_ELEMENT_IP_TTL_,
+				       key->ttl, mask->ttl);
+	return 0;
+}
+
 static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 				 struct net_device *dev,
 				 struct mlxsw_sp_acl_rule_info *rulei,
 				 struct tc_cls_flower_offload *f)
 {
+	u16 n_proto_mask = 0;
+	u16 n_proto_key = 0;
 	u16 addr_type = 0;
 	u8 ip_proto = 0;
 	int err;
@@ -229,6 +257,7 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
 	      BIT(FLOW_DISSECTOR_KEY_TCP) |
+	      BIT(FLOW_DISSECTOR_KEY_IP) |
 	      BIT(FLOW_DISSECTOR_KEY_VLAN))) {
 		dev_err(mlxsw_sp->bus_info->dev, "Unsupported key\n");
 		return -EOPNOTSUPP;
@@ -253,8 +282,8 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 			skb_flow_dissector_target(f->dissector,
 						  FLOW_DISSECTOR_KEY_BASIC,
 						  f->mask);
-		u16 n_proto_key = ntohs(key->n_proto);
-		u16 n_proto_mask = ntohs(mask->n_proto);
+		n_proto_key = ntohs(key->n_proto);
+		n_proto_mask = ntohs(mask->n_proto);
 
 		if (n_proto_key == ETH_P_ALL) {
 			n_proto_key = 0;
@@ -324,6 +353,10 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
+	err = mlxsw_sp_flower_parse_ip(mlxsw_sp, rulei, f, n_proto_key & n_proto_mask);
+	if (err)
+		return err;
+
 	return mlxsw_sp_flower_parse_actions(mlxsw_sp, dev, rulei, f->exts);
 }
 
-- 
2.9.3
