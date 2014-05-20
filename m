From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 05/13] openvswitch: Make flow mask
	removal symmetric.
Date: Tue, 20 May 2014 02:00:13 -0700
Message-ID: <1400576413-2319-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Masks are inserted when flows are inserted to the table, so it is
logical to correspondingly remove masks when flows are removed from
the table, in ovs_flow_table_remove().

This allows ovs_flow_free() to be called without locking, which will
be used by later patches.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow_table.c | 44 +++++++++++++++++++++++++-------------------
 1 file changed, 25 insertions(+), 19 deletions(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index d8ef37b..c80df6f 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -159,25 +159,6 @@ void ovs_flow_free(struct sw_flow *flow, bool deferred)
 	if (!flow)
 		return;
 
-	if (flow->mask) {
-		struct sw_flow_mask *mask = flow->mask;
-
-		/* ovs-lock is required to protect mask-refcount and
-		 * mask list.
-		 */
-		ASSERT_OVSL();
-		BUG_ON(!mask->ref_count);
-		mask->ref_count--;
-
-		if (!mask->ref_count) {
-			list_del_rcu(&mask->list);
-			if (deferred)
-				kfree_rcu(mask, rcu);
-			else
-				kfree(mask);
-		}
-	}
-
 	if (deferred)
 		call_rcu(&flow->rcu, rcu_free_flow_callback);
 	else
@@ -491,6 +472,25 @@ static struct table_instance *table_instance_expand(struct table_instance *ti)
 	return table_instance_rehash(ti, ti->n_buckets * 2);
 }
 
+/* Remove 'mask' from the mask list, if it is not needed any more. */
+static void flow_mask_remove(struct flow_table *tbl, struct sw_flow_mask *mask)
+{
+	if (mask) {
+		/* ovs-lock is required to protect mask-refcount and
+		 * mask list.
+		 */
+		ASSERT_OVSL();
+		BUG_ON(!mask->ref_count);
+		mask->ref_count--;
+
+		if (!mask->ref_count) {
+			list_del_rcu(&mask->list);
+			kfree_rcu(mask, rcu);
+		}
+	}
+}
+
+/* Must be called with OVS mutex held. */
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
@@ -498,6 +498,11 @@ void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 	BUG_ON(table->count == 0);
 	hlist_del_rcu(&flow->hash_node[ti->node_ver]);
 	table->count--;
+
+	/* RCU delete the mask. 'flow->mask' is not NULLed, as it should be
+	 * accessible as long as the RCU read lock is held.
+	 */
+	flow_mask_remove(table, flow->mask);
 }
 
 static struct sw_flow_mask *mask_alloc(void)
@@ -560,6 +565,7 @@ static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
 	return 0;
 }
 
+/* Must be called with OVS mutex held. */
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
 			struct sw_flow_mask *mask)
 {
-- 
1.9.0
