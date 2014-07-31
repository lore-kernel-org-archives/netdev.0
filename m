From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/3] openvswitch: Move table destroy to dp-rcu callback.
Date: Thu, 31 Jul 2014 16:57:43 -0700
Message-ID: <1406851063-1622-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:48611 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752439AbaGaX5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 19:57:44 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so4359125pde.37
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 16:57:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ths simplifies flow-table-destroy API.  This change is required
for following patches.
This patch does not change functionality.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@redhat.com>
---
 net/openvswitch/datapath.c   | 5 ++---
 net/openvswitch/flow_table.c | 9 +++++----
 net/openvswitch/flow_table.h | 2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7ad3f02..e5cc62b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -186,6 +186,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 {
 	struct datapath *dp = container_of(rcu, struct datapath, rcu);
 
+	ovs_flow_tbl_destroy(&dp->table);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
@@ -1417,7 +1418,7 @@ err_destroy_ports_array:
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(&dp->table, false);
+	ovs_flow_tbl_destroy(&dp->table);
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
@@ -1449,8 +1450,6 @@ static void __dp_destroy(struct datapath *dp)
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
 	/* RCU destroy the flow table */
-	ovs_flow_tbl_destroy(&dp->table, true);
-
 	call_rcu(&dp->rcu, destroy_dp_rcu);
 }
 
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index cf2d853..02d15d8 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -250,11 +250,12 @@ skip_flows:
 		__table_instance_destroy(ti);
 }
 
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
+/* No need for locking this function is called from RCU callback or
+ * error path.
+ */
+void ovs_flow_tbl_destroy(struct flow_table *table)
 {
-	struct table_instance *ti = ovsl_dereference(table->ti);
-
-	table_instance_destroy(ti, deferred);
+	table_instance_destroy(rcu_dereference_raw(table->ti), false);
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
