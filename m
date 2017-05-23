From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 5/5] mlxsw: spectrum_flower: Add support for tcp flags
Date: Tue, 23 May 2017 18:40:48 +0200
Message-ID: <20170523164048.16514-6-jiri@resnulli.us>
References: <20170523164048.16514-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34966 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764405AbdEWQlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:41:00 -0400
Received: by mail-wm0-f65.google.com with SMTP id g15so21122845wmc.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:40:59 -0700 (PDT)
In-Reply-To: <20170523164048.16514-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Allow to offload rules that contain tcp flags within the mask.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 29 ++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index 3a24289..61a10f1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -983,6 +983,7 @@ static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv4[] = {
 	MLXSW_AFK_ELEMENT_SRC_L4_PORT,
 	MLXSW_AFK_ELEMENT_VID,
 	MLXSW_AFK_ELEMENT_PCP,
+	MLXSW_AFK_ELEMENT_TCP_FLAGS,
 };
 
 static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv6[] = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index f7a8c3c..ed75c6a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -182,6 +182,32 @@ static int mlxsw_sp_flower_parse_ports(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
+static int mlxsw_sp_flower_parse_tcp(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_acl_rule_info *rulei,
+				     struct tc_cls_flower_offload *f,
+				     u8 ip_proto)
+{
+	struct flow_dissector_key_tcp *key, *mask;
+
+	if (!dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_TCP))
+		return 0;
+
+	if (ip_proto != IPPROTO_TCP) {
+		dev_err(mlxsw_sp->bus_info->dev, "TCP keys supported only for TCP\n");
+		return -EINVAL;
+	}
+
+	key = skb_flow_dissector_target(f->dissector,
+					FLOW_DISSECTOR_KEY_TCP,
+					f->key);
+	mask = skb_flow_dissector_target(f->dissector,
+					 FLOW_DISSECTOR_KEY_TCP,
+					 f->mask);
+	mlxsw_sp_acl_rulei_keymask_u32(rulei, MLXSW_AFK_ELEMENT_TCP_FLAGS,
+				       ntohs(key->flags), ntohs(mask->flags));
+	return 0;
+}
+
 static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 				 struct net_device *dev,
 				 struct mlxsw_sp_acl_rule_info *rulei,
@@ -290,6 +316,9 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 	err = mlxsw_sp_flower_parse_ports(mlxsw_sp, rulei, f, ip_proto);
 	if (err)
 		return err;
+	err = mlxsw_sp_flower_parse_tcp(mlxsw_sp, rulei, f, ip_proto);
+	if (err)
+		return err;
 
 	return mlxsw_sp_flower_parse_actions(mlxsw_sp, dev, rulei, f->exts);
 }
-- 
2.9.3
