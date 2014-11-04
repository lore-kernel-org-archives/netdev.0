From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 03/14] openvswitch: Move table destroy to dp-rcu callback.
Date: Mon,  3 Nov 2014 22:01:01 -0800
Message-ID: <1415080861-1721-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog030.obsmtp.com ([74.125.150.104]:36322 "HELO
	na6sys009bog030.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751983AbaKEUBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:15 -0500
Received: by mail-pd0-f172.google.com with SMTP id r10so1383915pdi.17
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ths simplifies flow-table-destroy API. No need to pass explicit
parameter about context.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@redhat.com>
---
 net/openvswitch/datapath.c   |  5 ++---
 net/openvswitch/flow_table.c | 11 +++++++----
 net/openvswitch/flow_table.h |  2 +-
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 688cb9b..a532a9c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -187,6 +187,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 {
 	struct datapath *dp = container_of(rcu, struct datapath, rcu);
 
+	ovs_flow_tbl_destroy(&dp->table);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
@@ -1444,7 +1445,7 @@ err_destroy_ports_array:
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(&dp->table, false);
+	ovs_flow_tbl_destroy(&dp->table);
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
@@ -1476,8 +1477,6 @@ static void __dp_destroy(struct datapath *dp)
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
 	/* RCU destroy the flow table */
-	ovs_flow_tbl_destroy(&dp->table, true);
-
 	call_rcu(&dp->rcu, destroy_dp_rcu);
 }
 
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index cf2d853..90f8b40 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2013 Nicira, Inc.
+ * Copyright (c) 2007-2014 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -250,11 +250,14 @@ skip_flows:
 		__table_instance_destroy(ti);
 }
 
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
+/* No need for locking this function is called from RCU callback or
+ * error path.
+ */
+void ovs_flow_tbl_destroy(struct flow_table *table)
 {
-	struct table_instance *ti = ovsl_dereference(table->ti);
+	struct table_instance *ti = rcu_dereference_raw(table->ti);
 
-	table_instance_destroy(ti, deferred);
+	table_instance_destroy(ti, false);
 }
 
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index 5918bff..f682c8c 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -62,7 +62,7 @@ void ovs_flow_free(struct sw_flow *, bool deferred);
 
 int ovs_flow_tbl_init(struct flow_table *);
 int ovs_flow_tbl_count(struct flow_table *table);
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
+void ovs_flow_tbl_destroy(struct flow_table *table);
 int ovs_flow_tbl_flush(struct flow_table *flow_table);
 
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
-- 
1.9.3
