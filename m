From: Tonghao Zhang <xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 1/2] openvswitch: Optimize updating for OvS
	flow_stats.
Date: Mon, 17 Jul 2017 23:28:05 -0700
Message-ID: <1500359286-36597-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Tonghao Zhang <xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

In the ovs_flow_stats_update(), we only use the node
var to alloc flow_stats struct. But this is not a
common case, it is unnecessary to call the numa_node_id()
everytime. This patch is not a bugfix, but there maybe
a small increase.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/flow.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 3f76cb7..89aeb32 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -72,7 +72,6 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 			   const struct sk_buff *skb)
 {
 	struct flow_stats *stats;
-	int node = numa_node_id();
 	int cpu = smp_processor_id();
 	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
@@ -108,7 +107,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 							      __GFP_THISNODE |
 							      __GFP_NOWARN |
 							      __GFP_NOMEMALLOC,
-							      node);
+							      numa_node_id());
 				if (likely(new_stats)) {
 					new_stats->used = jiffies;
 					new_stats->packet_count = 1;
-- 
1.8.3.1
