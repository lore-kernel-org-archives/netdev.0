From: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] openvswitch: Disable bottom half when grabbing
	stats lock in userspace context
Date: Thu, 27 Feb 2014 22:04:37 +0000
Message-ID: <1393538677-21268-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

The megaflow feature introduced per-CPU stats, and the new code did some
refactoring as well [1]. However the new functions doesn't disable bottom halves
when locking the stat, and as they can be called from userspace context, they
can be interrupted by netif_receive_skb.

[1] e298e50570: openvswitch: Per cpu flow stats.

Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 16f4b46..07a4672 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -90,13 +90,14 @@ static void stats_read(struct flow_stats *stats,
 		       struct ovs_flow_stats *ovs_stats,
 		       unsigned long *used, __be16 *tcp_flags)
 {
-	spin_lock(&stats->lock);
+	unsigned long flags;
+	spin_lock_irqsave(&stats->lock, flags);
 	if (time_after(stats->used, *used))
 		*used = stats->used;
 	*tcp_flags |= stats->tcp_flags;
 	ovs_stats->n_packets += stats->packet_count;
 	ovs_stats->n_bytes += stats->byte_count;
-	spin_unlock(&stats->lock);
+	spin_unlock_irqrestore(&stats->lock, flags);
 }
 
 void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
@@ -130,12 +131,13 @@ void ovs_flow_stats_get(struct sw_flow *flow, struct ovs_flow_stats *ovs_stats,
 
 static void stats_reset(struct flow_stats *stats)
 {
-	spin_lock(&stats->lock);
+	unsigned long flags;
+	spin_lock_irqsave(&stats->lock, flags);
 	stats->used = 0;
 	stats->packet_count = 0;
 	stats->byte_count = 0;
 	stats->tcp_flags = 0;
-	spin_unlock(&stats->lock);
+	spin_unlock_irqrestore(&stats->lock, flags);
 }
 
 void ovs_flow_stats_clear(struct sw_flow *flow)
