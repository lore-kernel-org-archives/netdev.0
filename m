From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 02/11] openvswitch: Use RCU lock for dp dump operation.
Date: Tue, 27 Aug 2013 13:20:39 -0700
Message-ID: <1377634848-34327-3-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:41380 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752591Ab3H0UVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:00 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so5336267pdj.32
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:20:59 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

RCUfy dp-dump operation which is already read-only. This
makes all ovs dump operations lockless.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e6fb866..9d97ef3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -951,9 +951,10 @@ static struct genl_ops dp_packet_genl_ops[] = {
 
 static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats)
 {
+	struct flow_table *table;
 	int i;
-	struct flow_table *table = ovsl_dereference(dp->table);
 
+	table = rcu_dereference_check(dp->table, lockdep_ovsl_is_held());
 	stats->n_flows = ovs_flow_tbl_count(table);
 
 	stats->n_hit = stats->n_missed = stats->n_lost = 0;
@@ -1665,7 +1666,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_local_port;
 
 	ovs_net = net_generic(ovs_dp_get_net(dp), ovs_net_id);
-	list_add_tail(&dp->list_node, &ovs_net->dps);
+	list_add_tail_rcu(&dp->list_node, &ovs_net->dps);
 
 	ovs_unlock();
 
@@ -1703,7 +1704,7 @@ static void __dp_destroy(struct datapath *dp)
 				ovs_dp_detach_port(vport);
 	}
 
-	list_del(&dp->list_node);
+	list_del_rcu(&dp->list_node);
 
 	/* OVSP_LOCAL is datapath internal port. We need to make sure that
 	 * all port in datapath are destroyed first before freeing datapath.
@@ -1808,8 +1809,8 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int skip = cb->args[0];
 	int i = 0;
 
-	ovs_lock();
-	list_for_each_entry(dp, &ovs_net->dps, list_node) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(dp, &ovs_net->dps, list_node) {
 		if (i >= skip &&
 		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
@@ -1817,7 +1818,7 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 		i++;
 	}
-	ovs_unlock();
+	rcu_read_unlock();
 
 	cb->args[0] = i;
 
-- 
1.8.1.2
