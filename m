From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: rfs: fix crash in get_rps_cpus()
Date: Sat, 25 Apr 2015 09:35:24 -0700
Message-ID: <1429979724.22254.172.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34031 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbbDYQf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 12:35:26 -0400
Received: by iedfl3 with SMTP id fl3so115736761ied.1
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 09:35:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 567e4b79731c ("net: rfs: add hash collision detection") had one
mistake :

RPS_NO_CPU is no longer the marker for invalid cpu in set_rps_cpu()
and get_rps_cpu(), as @next_cpu was the result of an AND with
rps_cpu_mask

This bug showed up on a host with 72 cpus :
next_cpu was 0x7f, and the code was trying to access percpu data of an
non existent cpu.

In a follow up patch, we might get rid of compares against nr_cpu_ids,
if we init the tables with 0. This is silly to test for a very unlikely
condition that exists only shortly after table initialization, as
we got rid of rps_reset_sock_flow() and similar functions that were
writing this RPS_NO_CPU magic value at flow dismantle : When table is
old enough, it never contains this value anymore.

Fixes: 567e4b79731c ("net: rfs: add hash collision detection")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <tom@herbertland.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
---
I chose an obvious patch for stable kernel (4.0 +), but I'll submit a
nicer patch when net-next reopens, as we can simply remove RPS_NO_CPU
and these tests against nr_cpu_ids as I explained in this changelog.

Note to Ben: It seems set_rps_cpu() lacks RCU protection reading 
dev->rx_cpu_rmap. Its value can change under us and we might crash.

 Documentation/networking/scaling.txt |    2 +-
 net/core/dev.c                       |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index cbfac0949635..59f4db2a0c85 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -282,7 +282,7 @@ following is true:
 
 - The current CPU's queue head counter >= the recorded tail counter
   value in rps_dev_flow[i]
-- The current CPU is unset (equal to RPS_NO_CPU)
+- The current CPU is unset (>= nr_cpu_ids)
 - The current CPU is offline
 
 After this check, the packet is sent to the (possibly updated) current
diff --git a/net/core/dev.c b/net/core/dev.c
index 1796cef55ab5..c7ba0388f1be 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3079,7 +3079,7 @@ static struct rps_dev_flow *
 set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	    struct rps_dev_flow *rflow, u16 next_cpu)
 {
-	if (next_cpu != RPS_NO_CPU) {
+	if (next_cpu < nr_cpu_ids) {
 #ifdef CONFIG_RFS_ACCEL
 		struct netdev_rx_queue *rxqueue;
 		struct rps_dev_flow_table *flow_table;
@@ -3184,7 +3184,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		 * If the desired CPU (where last recvmsg was done) is
 		 * different from current CPU (one in the rx-queue flow
 		 * table entry), switch if one of the following holds:
-		 *   - Current CPU is unset (equal to RPS_NO_CPU).
+		 *   - Current CPU is unset (>= nr_cpu_ids).
 		 *   - Current CPU is offline.
 		 *   - The current CPU's queue tail has advanced beyond the
 		 *     last packet that was enqueued using this table entry.
@@ -3192,14 +3192,14 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		 *     have been dequeued, thus preserving in order delivery.
 		 */
 		if (unlikely(tcpu != next_cpu) &&
-		    (tcpu == RPS_NO_CPU || !cpu_online(tcpu) ||
+		    (tcpu >= nr_cpu_ids || !cpu_online(tcpu) ||
 		     ((int)(per_cpu(softnet_data, tcpu).input_queue_head -
 		      rflow->last_qtail)) >= 0)) {
 			tcpu = next_cpu;
 			rflow = set_rps_cpu(dev, skb, rflow, next_cpu);
 		}
 
-		if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
+		if (tcpu < nr_cpu_ids && cpu_online(tcpu)) {
 			*rflowp = rflow;
 			cpu = tcpu;
 			goto done;
@@ -3240,14 +3240,14 @@ bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
 	struct rps_dev_flow_table *flow_table;
 	struct rps_dev_flow *rflow;
 	bool expire = true;
-	int cpu;
+	unsigned int cpu;
 
 	rcu_read_lock();
 	flow_table = rcu_dereference(rxqueue->rps_flow_table);
 	if (flow_table && flow_id <= flow_table->mask) {
 		rflow = &flow_table->flows[flow_id];
 		cpu = ACCESS_ONCE(rflow->cpu);
-		if (rflow->filter == filter_id && cpu != RPS_NO_CPU &&
+		if (rflow->filter == filter_id && cpu < nr_cpu_ids &&
 		    ((int)(per_cpu(softnet_data, cpu).input_queue_head -
 			   rflow->last_qtail) <
 		     (int)(10 * flow_table->mask)))
