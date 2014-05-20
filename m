From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 08/13] openvswitch: Fix
	ovs_flow_stats_get/clear RCU dereference.
Date: Tue, 20 May 2014 02:00:29 -0700
Message-ID: <1400576429-2406-1-git-send-email-pshelar@nicira.com>
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

For ovs_flow_stats_get() using ovsl_dereference() was wrong, since
flow dumps call this with RCU read lock.

ovs_flow_stats_clear() is always called with ovs_mutex, so can use
ovsl_dereference().

Also, make the ovs_flow_stats_get() 'flow' argument const to make
later patches cleaner.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c | 10 ++++++----
 net/openvswitch/flow.h |  6 +++---
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 1019fc1..334751c 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -122,8 +122,9 @@ unlock:
 	spin_unlock(&stats->lock);
 }
 
-/* Called with ovs_mutex. */
-void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
+/* Must be called with rcu_read_lock or ovs_mutex. */
+void ovs_flow_stats_get(const struct sw_flow *flow,
+			struct ovs_flow_stats *ovs_stats,
 			unsigned long *used, __be16 *tcp_flags)
 {
 	int node;
@@ -133,7 +134,7 @@ void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
 	memset(ovs_stats, 0, sizeof(*ovs_stats));
 
 	for_each_node(node) {
-		struct flow_stats *stats = ovsl_dereference(flow->stats[node]);
+		struct flow_stats *stats = rcu_dereference_ovsl(flow->stats[node]);
 
 		if (stats) {
 			/* Local CPU may write on non-local stats, so we must
@@ -150,12 +151,13 @@ void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
 	}
 }
 
+/* Called with ovs_mutex. */
 void ovs_flow_stats_clear(struct sw_flow *flow)
 {
 	int node;
 
 	for_each_node(node) {
-		struct flow_stats *stats = rcu_dereference(flow->stats[node]);
+		struct flow_stats *stats = ovsl_dereference(flow->stats[node]);
 
 		if (stats) {
 			spin_lock_bh(&stats->lock);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a292bf8..ac395d2 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -180,10 +180,10 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
-void ovs_flow_stats_update(struct sw_flow *flow, struct sk_buff *skb);
-void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *stats,
+void ovs_flow_stats_update(struct sw_flow *, struct sk_buff *);
+void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
 			unsigned long *used, __be16 *tcp_flags);
-void ovs_flow_stats_clear(struct sw_flow *flow);
+void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
 int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
-- 
1.9.0
