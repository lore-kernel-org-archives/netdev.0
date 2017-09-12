From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Prevent mirred-related crash on removal
Date: Tue, 12 Sep 2017 08:50:53 +0200
Message-ID: <20170912065053.1392-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yuvalm@mellanox.com, idosch@mellanox.com,
        flokli@flokli.de, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37061 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751089AbdILGu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 02:50:57 -0400
Received: by mail-wr0-f196.google.com with SMTP id u48so5406079wrf.4
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 23:50:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalm@mellanox.com>

When removing the offloading of mirred actions under
matchall classifiers, mlxsw would find the destination port
associated with the offloaded action and utilize it for undoing
the configuration.

Depending on the order by which ports are removed, it's possible that
the destination port would get removed before the source port.
In such a scenario, when actions would be flushed for the source port
mlxsw would perform an illegal dereference as the destination port is
no longer listed.

Since the only item necessary for undoing the configuration on the
destination side is the port-id and that in turn is already maintained
by mlxsw on the source-port, simply stop trying to access the
destination port and use the port-id directly instead.

Fixes: 763b4b70af ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
Signed-off-by: Yuval Mintz <yuvalm@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e080459..696b99e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -575,15 +575,14 @@ static void mlxsw_sp_span_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 }
 
 static struct mlxsw_sp_span_entry *
-mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
+mlxsw_sp_span_entry_find(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
-	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
 	int i;
 
 	for (i = 0; i < mlxsw_sp->span.entries_count; i++) {
 		struct mlxsw_sp_span_entry *curr = &mlxsw_sp->span.entries[i];
 
-		if (curr->used && curr->local_port == port->local_port)
+		if (curr->used && curr->local_port == local_port)
 			return curr;
 	}
 	return NULL;
@@ -594,7 +593,8 @@ static struct mlxsw_sp_span_entry
 {
 	struct mlxsw_sp_span_entry *span_entry;
 
-	span_entry = mlxsw_sp_span_entry_find(port);
+	span_entry = mlxsw_sp_span_entry_find(port->mlxsw_sp,
+					      port->local_port);
 	if (span_entry) {
 		/* Already exists, just take a reference */
 		span_entry->ref_count++;
@@ -783,12 +783,13 @@ static int mlxsw_sp_span_mirror_add(struct mlxsw_sp_port *from,
 }
 
 static void mlxsw_sp_span_mirror_remove(struct mlxsw_sp_port *from,
-					struct mlxsw_sp_port *to,
+					u8 destination_port,
 					enum mlxsw_sp_span_type type)
 {
 	struct mlxsw_sp_span_entry *span_entry;
 
-	span_entry = mlxsw_sp_span_entry_find(to);
+	span_entry = mlxsw_sp_span_entry_find(from->mlxsw_sp,
+					      destination_port);
 	if (!span_entry) {
 		netdev_err(from->dev, "no span entry found\n");
 		return;
@@ -1563,14 +1564,12 @@ static void
 mlxsw_sp_port_del_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
 				      struct mlxsw_sp_port_mall_mirror_tc_entry *mirror)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	enum mlxsw_sp_span_type span_type;
-	struct mlxsw_sp_port *to_port;
 
-	to_port = mlxsw_sp->ports[mirror->to_local_port];
 	span_type = mirror->ingress ?
 			MLXSW_SP_SPAN_INGRESS : MLXSW_SP_SPAN_EGRESS;
-	mlxsw_sp_span_mirror_remove(mlxsw_sp_port, to_port, span_type);
+	mlxsw_sp_span_mirror_remove(mlxsw_sp_port, mirror->to_local_port,
+				    span_type);
 }
 
 static int
-- 
2.9.3
