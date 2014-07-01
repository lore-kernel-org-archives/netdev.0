From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 4/4] openvswitch: Use exact lookup for flow_get and flow_del.
Date: Mon, 30 Jun 2014 23:34:48 -0700
Message-ID: <1404196488-5217-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Alex Wang <alexw@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:50723 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752003AbaGAGe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 02:34:56 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so9456309pdj.8
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 23:34:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Wang <alexw@nicira.com>

Due to the race condition in userspace, there is chance that two
overlapping megaflows could be installed in datapath.  And this
causes userspace unable to delete the less inclusive megaflow flow
even after it timeout, since the flow_del logic will stop at the
first match of masked flow.

This commit fixes the bug by making the kernel flow_del and flow_get
logic check all masks in that case.

Introduced by 03f0d916a (openvswitch: Mega flow implementation).

Signed-off-by: Alex Wang <alexw@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c   | 23 +++++++++++------------
 net/openvswitch/flow_table.c | 16 ++++++++++++++++
 net/openvswitch/flow_table.h |  3 ++-
 3 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index a863678..9db4bf6 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -889,8 +889,11 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		}
 		/* The unmasked key has to be the same for flow updates. */
 		if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
-			error = -EEXIST;
-			goto err_unlock_ovs;
+			flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+			if (!flow) {
+				error = -ENOENT;
+				goto err_unlock_ovs;
+			}
 		}
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
@@ -981,16 +984,12 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_ovs;
 	}
 	/* Check that the flow exists. */
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
 	if (unlikely(!flow)) {
 		error = -ENOENT;
 		goto err_unlock_ovs;
 	}
-	/* The unmasked key has to be the same for flow updates. */
-	if (unlikely(!ovs_flow_cmp_unmasked_key(flow, &match))) {
-		error = -EEXIST;
-		goto err_unlock_ovs;
-	}
+
 	/* Update actions, if present. */
 	if (likely(acts)) {
 		old_acts = ovsl_dereference(flow->sf_acts);
@@ -1063,8 +1062,8 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
-	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
+	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (!flow) {
 		err = -ENOENT;
 		goto unlock;
 	}
@@ -1113,8 +1112,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = ovs_flow_tbl_lookup(&dp->table, &key);
-	if (unlikely(!flow || !ovs_flow_cmp_unmasked_key(flow, &match))) {
+	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (unlikely(!flow)) {
 		err = -ENOENT;
 		goto unlock;
 	}
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 574c3ab..cf2d853 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -456,6 +456,22 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 	return ovs_flow_tbl_lookup_stats(tbl, key, &n_mask_hit);
 }
 
+struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
+					  struct sw_flow_match *match)
+{
+	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
+	struct sw_flow_mask *mask;
+	struct sw_flow *flow;
+
+	/* Always called under ovs-mutex. */
+	list_for_each_entry(mask, &tbl->mask_list, list) {
+		flow = masked_flow_lookup(ti, match->key, mask);
+		if (flow && ovs_flow_cmp_unmasked_key(flow, match))  /* Found */
+			return flow;
+	}
+	return NULL;
+}
+
 int ovs_flow_tbl_num_masks(const struct flow_table *table)
 {
 	struct sw_flow_mask *mask;
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index ca8a582..5918bff 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -76,7 +76,8 @@ struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *,
 				    u32 *n_mask_hit);
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
-
+struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
+					  struct sw_flow_match *match);
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 			       struct sw_flow_match *match);
 
-- 
1.9.3
