From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net_sched: gred: use correct backlog value in WRED mode
Date: Sat,  9 May 2015 22:01:47 -0400
Message-ID: <1431223307-26669-2-git-send-email-david.ward@ll.mit.edu>
References: <1431223307-26669-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-5.mit.edu ([18.7.68.34]:65215 "EHLO
	dmz-mailsec-scanner-5.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752054AbbEJCG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 22:06:58 -0400
In-Reply-To: <1431223307-26669-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In WRED mode, the backlog for a single virtual queue (VQ) should not be
used to determine queue behavior; instead the backlog is summed across
all VQs. This sum is currently used when calculating the average queue
lengths. It also needs to be used when determining if the queue's hard
limit has been reached, or when reporting each VQ's backlog via netlink.
q->backlog will only be used if the queue switches out of WRED mode.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/sched/sch_gred.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index a4ca451..634529e 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -229,7 +229,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		break;
 	}
 
-	if (q->backlog + qdisc_pkt_len(skb) <= q->limit) {
+	if (gred_backlog(t, q, sch) + qdisc_pkt_len(skb) <= q->limit) {
 		q->backlog += qdisc_pkt_len(skb);
 		return qdisc_enqueue_tail(skb, sch);
 	}
@@ -553,7 +553,7 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 		opt.limit	= q->limit;
 		opt.DP		= q->DP;
-		opt.backlog	= q->backlog;
+		opt.backlog	= gred_backlog(table, q, sch);
 		opt.prio	= q->prio;
 		opt.qth_min	= q->parms.qth_min >> q->parms.Wlog;
 		opt.qth_max	= q->parms.qth_max >> q->parms.Wlog;
-- 
1.7.1
