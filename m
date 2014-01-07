From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 03/17] openvswitch: Change
	ovs_flow_tbl_lookup_xx() APIs
Date: Mon,  6 Jan 2014 16:16:02 -0800
Message-ID: <1389053776-62865-4-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

API changes only for code readability. No functional chnages.

This patch removes the underscored version. Added a new API
ovs_flow_tbl_lookup_stats() that returns the n_mask_hits.

Reported by: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c   | 16 ++++------------
 net/openvswitch/flow_table.c | 10 +++++++++-
 net/openvswitch/flow_table.h |  4 +++-
 3 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 6f5e1dd..fcaed98 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -234,7 +234,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup(&dp->table, &key, &n_mask_hit);
+	flow = ovs_flow_tbl_lookup_stats(&dp->table, &key, &n_mask_hit);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
@@ -751,14 +751,6 @@ static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
 	return skb;
 }
 
-static struct sw_flow *__ovs_flow_tbl_lookup(struct flow_table *tbl,
-					      const struct sw_flow_key *key)
-{
-	u32 __always_unused n_mask_hit;
-
-	return ovs_flow_tbl_lookup(tbl, key, &n_mask_hit);
-}
-
 static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -809,7 +801,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_ovs;
 
 	/* Check if this is a duplicate flow */
-	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow) {
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
@@ -921,7 +913,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
@@ -969,7 +961,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto unlock;
 
-	flow = __ovs_flow_tbl_lookup(&dp->table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index f96ebd5..261a54e 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -429,7 +429,7 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	return NULL;
 }
 
-struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
+struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
 				    const struct sw_flow_key *key,
 				    u32 *n_mask_hit)
 {
@@ -447,6 +447,14 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 	return NULL;
 }
 
+struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
+				    const struct sw_flow_key *key)
+{
+	u32 __always_unused n_mask_hit;
+
+	return ovs_flow_tbl_lookup_stats(tbl, key, &n_mask_hit);
+}
+
 int ovs_flow_tbl_num_masks(const struct flow_table *table)
 {
 	struct sw_flow_mask *mask;
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index fbe45d5..f54aa82 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -69,9 +69,11 @@ void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
 int  ovs_flow_tbl_num_masks(const struct flow_table *table);
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 				       u32 *bucket, u32 *idx);
-struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
+struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *,
 				    const struct sw_flow_key *,
 				    u32 *n_mask_hit);
+struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
+				    const struct sw_flow_key *);
 
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 			       struct sw_flow_match *match);
-- 
1.8.3.2
