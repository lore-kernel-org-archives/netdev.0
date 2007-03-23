From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 11/11]: qdisc: avoid dequeue while throttled
Date: Fri, 23 Mar 2007 14:35:53 +0100 (MET)
Message-ID: <20070323133528.10264.68156.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61443 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934286AbXCWNfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:54 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: qdisc: avoid dequeue while throttled

Avoid dequeueing while the device is throttled.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 69f6039ded0bdaf93e3fc954140caae1e7fc9927
tree 9894ce3afc9f7e5cadb26269827ba4d4bca393fc
parent e2459acd7dee06fb4d5e980f26c23d31db0e5de1
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:32 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:32 +0100

 net/sched/sch_generic.c |    4 ++++
 net/sched/sch_netem.c   |    4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 52eb343..39c5312 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -93,6 +93,10 @@ static inline int qdisc_restart(struct net_device *dev)
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
 
+	smp_rmb();
+	if (q->flags & TCQ_F_THROTTLED)
+		return q->q.qlen;
+
 	/* Dequeue packet */
 	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
 		unsigned nolock = (dev->features & NETIF_F_LLTX);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5d9d8bc..4c7a8d8 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -273,10 +273,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	smp_mb();
-	if (sch->flags & TCQ_F_THROTTLED)
-		return NULL;
-
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb
