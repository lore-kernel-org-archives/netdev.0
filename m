From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: spectrum: Make the add_matchall_tc_entry symmetric
Date: Mon,  9 Jan 2017 11:25:46 +0100
Message-ID: <1483957548-3531-4-git-send-email-jiri@resnulli.us>
References: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34931 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758608AbdAIKZz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:25:55 -0500
Received: by mail-wm0-f65.google.com with SMTP id l2so21006933wml.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 02:25:54 -0800 (PST)
In-Reply-To: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Currently, the mlxsw spectrum driver only supports offloading the matchall
classifier together with the mirred action. To allow more matchall tc
offloads, make the code symmetric so that it can be easily extended later
on for other actions.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 91 ++++++++++++++------------
 1 file changed, 48 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 46c53a0..f4b8ba2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1161,8 +1161,8 @@ static int mlxsw_sp_port_get_phys_port_name(struct net_device *dev, char *name,
 }
 
 static struct mlxsw_sp_port_mall_tc_entry *
-mlxsw_sp_port_mirror_entry_find(struct mlxsw_sp_port *port,
-				unsigned long cookie) {
+mlxsw_sp_port_mall_tc_entry_find(struct mlxsw_sp_port *port,
+				 unsigned long cookie) {
 	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
 
 	list_for_each_entry(mall_tc_entry, &port->mall_tc_list, list)
@@ -1174,17 +1174,15 @@ mlxsw_sp_port_mirror_entry_find(struct mlxsw_sp_port *port,
 
 static int
 mlxsw_sp_port_add_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
-				      struct tc_cls_matchall_offload *cls,
+				      struct mlxsw_sp_port_mall_mirror_tc_entry *mirror,
 				      const struct tc_action *a,
 				      bool ingress)
 {
-	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
 	struct net *net = dev_net(mlxsw_sp_port->dev);
 	enum mlxsw_sp_span_type span_type;
 	struct mlxsw_sp_port *to_port;
 	struct net_device *to_dev;
 	int ifindex;
-	int err;
 
 	ifindex = tcf_mirred_ifindex(a);
 	to_dev = __dev_get_by_index(net, ifindex);
@@ -1199,26 +1197,24 @@ mlxsw_sp_port_add_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 	to_port = netdev_priv(to_dev);
 
-	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
-	if (!mall_tc_entry)
-		return -ENOMEM;
-
-	mall_tc_entry->cookie = cls->cookie;
-	mall_tc_entry->type = MLXSW_SP_PORT_MALL_MIRROR;
-	mall_tc_entry->mirror.to_local_port = to_port->local_port;
-	mall_tc_entry->mirror.ingress = ingress;
-	list_add_tail(&mall_tc_entry->list, &mlxsw_sp_port->mall_tc_list);
-
+	mirror->to_local_port = to_port->local_port;
+	mirror->ingress = ingress;
 	span_type = ingress ? MLXSW_SP_SPAN_INGRESS : MLXSW_SP_SPAN_EGRESS;
-	err = mlxsw_sp_span_mirror_add(mlxsw_sp_port, to_port, span_type);
-	if (err)
-		goto err_mirror_add;
-	return 0;
+	return mlxsw_sp_span_mirror_add(mlxsw_sp_port, to_port, span_type);
+}
 
-err_mirror_add:
-	list_del(&mall_tc_entry->list);
-	kfree(mall_tc_entry);
-	return err;
+static void
+mlxsw_sp_port_del_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct mlxsw_sp_port_mall_mirror_tc_entry *mirror)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	enum mlxsw_sp_span_type span_type;
+	struct mlxsw_sp_port *to_port;
+
+	to_port = mlxsw_sp->ports[mirror->to_local_port];
+	span_type = mirror->ingress ?
+			MLXSW_SP_SPAN_INGRESS : MLXSW_SP_SPAN_EGRESS;
+	mlxsw_sp_span_mirror_remove(mlxsw_sp_port, to_port, span_type);
 }
 
 static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -1226,6 +1222,7 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  struct tc_cls_matchall_offload *cls,
 					  bool ingress)
 {
+	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
 	int err;
@@ -1235,50 +1232,58 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -ENOTSUPP;
 	}
 
+	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
+	if (!mall_tc_entry)
+		return -ENOMEM;
+	mall_tc_entry->cookie = cls->cookie;
+
 	tcf_exts_to_list(cls->exts, &actions);
-	list_for_each_entry(a, &actions, list) {
-		if (!is_tcf_mirred_egress_mirror(a) ||
-		    protocol != htons(ETH_P_ALL)) {
-			return -ENOTSUPP;
-		}
+	a = list_first_entry(&actions, struct tc_action, list);
 
-		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port, cls,
-							    a, ingress);
-		if (err)
-			return err;
+	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL)) {
+		struct mlxsw_sp_port_mall_mirror_tc_entry *mirror;
+
+		mall_tc_entry->type = MLXSW_SP_PORT_MALL_MIRROR;
+		mirror = &mall_tc_entry->mirror;
+		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port,
+							    mirror, a, ingress);
+	} else {
+		err = -EOPNOTSUPP;
 	}
 
+	if (err)
+		goto err_add_action;
+
+	list_add_tail(&mall_tc_entry->list, &mlxsw_sp_port->mall_tc_list);
 	return 0;
+
+err_add_action:
+	kfree(mall_tc_entry);
+	return err;
 }
 
 static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					   struct tc_cls_matchall_offload *cls)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
-	enum mlxsw_sp_span_type span_type;
-	struct mlxsw_sp_port *to_port;
 
-	mall_tc_entry = mlxsw_sp_port_mirror_entry_find(mlxsw_sp_port,
-							cls->cookie);
+	mall_tc_entry = mlxsw_sp_port_mall_tc_entry_find(mlxsw_sp_port,
+							 cls->cookie);
 	if (!mall_tc_entry) {
 		netdev_dbg(mlxsw_sp_port->dev, "tc entry not found on port\n");
 		return;
 	}
+	list_del(&mall_tc_entry->list);
 
 	switch (mall_tc_entry->type) {
 	case MLXSW_SP_PORT_MALL_MIRROR:
-		to_port = mlxsw_sp->ports[mall_tc_entry->mirror.to_local_port];
-		span_type = mall_tc_entry->mirror.ingress ?
-				MLXSW_SP_SPAN_INGRESS : MLXSW_SP_SPAN_EGRESS;
-
-		mlxsw_sp_span_mirror_remove(mlxsw_sp_port, to_port, span_type);
+		mlxsw_sp_port_del_cls_matchall_mirror(mlxsw_sp_port,
+						      &mall_tc_entry->mirror);
 		break;
 	default:
 		WARN_ON(1);
 	}
 
-	list_del(&mall_tc_entry->list);
 	kfree(mall_tc_entry);
 }
 
-- 
2.7.4
