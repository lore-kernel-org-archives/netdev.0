From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][3.13.y-ckt][PATCH 1/1] openvswitch: Use exact lookup for flow_get and flow_del.
Date: Fri, 27 Feb 2015 15:19:20 -0500
Message-ID: <c08d24df6eed6287a51fd9e103dbbcafd22aa825.1424801574.git.joseph.salisbury__21381.5905074172$1425068391$gmane$org@canonical.com>
References: <cover.1424801573.git.joseph.salisbury@canonical.com>
Cc: alexw@nicira.com, azhou@nicira.com, pshelar@nicira.com,
	davem@davemloft.net, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: kamal@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59892 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbbB0UT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:19:28 -0500
In-Reply-To: <cover.1424801573.git.joseph.salisbury@canonical.com>
In-Reply-To: <cover.1424801573.git.joseph.salisbury@canonical.com>
References: <cover.1424801573.git.joseph.salisbury@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Wang <alexw@nicira.com>

BugLink: http://bugs.launchpad.net/bugs/1408972

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
(backported from commit 4a46b24e147dfa9b858026da02cad0bdd4e149d2)
Signed-off-by: Joseph Salisbury <joseph.salisbury@canonical.com>
---
 net/openvswitch/datapath.c   | 17 ++++++++++-------
 net/openvswitch/flow_table.c | 16 ++++++++++++++++
 net/openvswitch/flow_table.h |  3 ++-
 3 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 1582faf..d9013c1 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -852,10 +852,12 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			goto err_unlock_ovs;
 
 		/* The unmasked key has to be the same for flow updates. */
-		error = -EINVAL;
 		if (!ovs_flow_cmp_unmasked_key(flow, &match)) {
-			OVS_NLERR("Flow modification message rejected, unmasked key does not match.\n");
-			goto err_unlock_ovs;
+			flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+			if (!flow) {
+				error = -ENOENT;
+				goto err_unlock_ovs;
+			}
 		}
 
 		/* Update actions. */
@@ -873,6 +875,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			spin_unlock_bh(&flow->lock);
 		}
 	}
+
 	ovs_unlock();
 
 	if (!IS_ERR(reply))
@@ -920,8 +923,8 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
-	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
+	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (!flow) {
 		err = -ENOENT;
 		goto unlock;
 	}
@@ -968,8 +971,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto unlock;
 
-	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
-	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
+	flow = ovs_flow_tbl_lookup_exact(&dp->table, &match);
+	if (unlikely(!flow)) {
 		err = -ENOENT;
 		goto unlock;
 	}
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 0ddf2bc..dd83154 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -447,6 +447,22 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 	return NULL;
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
index fbe45d5..59c15f7 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -72,7 +72,8 @@ struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *,
 				    u32 *n_mask_hit);
-
+struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
+					  struct sw_flow_match *match);
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 			       struct sw_flow_match *match);
 
-- 
2.1.0
