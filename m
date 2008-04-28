From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] sch_sfq: prevent unnecessary reordering
Date: Mon, 28 Apr 2008 09:04:53 +0000
Message-ID: <20080428090453.GA4936@ff.dom.local>
References: <20080427142216.GB7480@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:35920 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762590AbYD1JBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 05:01:52 -0400
Received: by fg-out-1718.google.com with SMTP id l27so4861228fgb.17
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 02:01:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080427142216.GB7480@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27-04-2008 16:22, Jarek Poplawski wrote:
> [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
> 

David, as Patrick noticed this patch was wrong and I withdraw it.

I still can't see why sfq should have such a low limit, but I think,
there is at least something to improve in the way it's imposed. BTW,
my previous idea to check this before classifying was wrong too. But,
IMHO, this could be done better than now like in this patch.

Regards,
Jarek P.

------------------------->

[NET_SCHED] sch_sfq: prevent unnecessary reordering

Current check of queue limit in sfq_enqueue() isn't optimal: there
is really not much more needed to prevent unnecessary dropping and
possible reordering.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_sfq.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a20e2ef..9afef88 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -298,12 +298,19 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->hash[x] = hash;
 	}
 
-	/* If selected queue has length q->limit, this means that
-	 * all another queues are empty and that we do simple tail drop,
-	 * i.e. drop _this_ packet.
+	/*
+	 * If the queue is full some dropping is necessary. Let's check
+	 * whether this slot is to be selected to avoid reordering at
+	 * least. If max_depth == 1 (very unprobable) another slot could
+	 * be chosen to drop, but there is no reason to do this (and if
+	 * it were this slot yet the reordering would happen.)
 	 */
-	if (q->qs[x].qlen >= q->limit)
-		return qdisc_drop(skb, sch);
+	if (sch->q.qlen >= q->limit) {
+		sfq_index d = q->max_depth;
+
+		if ((d > 1 && x == q->dep[d + SFQ_DEPTH].next) || d == 1)
+			return qdisc_drop(skb, sch);
+	}
 
 	sch->qstats.backlog += skb->len;
 	__skb_queue_tail(&q->qs[x], skb);
