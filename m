From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 18:08:36 +0200
Message-ID: <1336752516.31653.196.camel@edumazet-glaptop>
References: <1336744796.31653.164.camel@edumazet-glaptop>
	 <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
	 <1336749810.31653.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33422 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab2EKQIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 12:08:41 -0400
Received: by bkcji2 with SMTP id ji2so2375052bkc.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 09:08:40 -0700 (PDT)
In-Reply-To: <1336749810.31653.176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 17:23 +0200, Eric Dumazet wrote:

> Its possible I missed something, because in my first coding I had 3
> lists.
> 
> Anyway I'll send a V2 because I left .change method to NULL, while the
> intent was to permit a change on fq_codel.

Before sending v2, here is the diff against v1 :

 net/sched/sch_fq_codel.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 8675ff8..f29a967 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -231,18 +231,16 @@ static struct sk_buff *fq_codel_dequeue(struct Qdisc *sch)
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	struct fq_codel_flow *flow;
+	struct list_head *head;
 
 begin:
-	if (!list_empty(&q->new_flows))
-		flow = list_first_entry(&q->new_flows,
-					struct fq_codel_flow,
-					flowchain);
-	else if (!list_empty(&q->old_flows))
-		flow = list_first_entry(&q->old_flows,
-					struct fq_codel_flow,
-					flowchain);
-	else
-		return NULL;
+	head = &q->new_flows;
+	if (list_empty(head)) {
+		head = &q->old_flows;
+		if (list_empty(head))
+			return NULL;
+	}
+	flow = list_first_entry(head, struct fq_codel_flow, flowchain);
 
 	if (flow->deficit <= 0) {
 		flow->deficit += q->quantum;
@@ -252,7 +250,11 @@ begin:
 	skb = codel_dequeue(sch, &q->cparams, &flow->cvars, &q->cstats,
 			    dequeue, &q->backlogs[flow - q->flows]);
 	if (!skb) {
-		list_del_init(&flow->flowchain);
+		/* force a pass through old_flows to prevent starvation */
+		if ((head == &q->new_flows) && !list_empty(&q->old_flows))
+			list_move_tail(&flow->flowchain, &q->old_flows);
+		else
+			list_del_init(&flow->flowchain);
 		goto begin;
 	}
 	qdisc_bstats_update(sch, skb);
@@ -573,7 +575,7 @@ static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
 	.init		=	fq_codel_init,
 	.reset		=	fq_codel_reset,
 	.destroy	=	fq_codel_destroy,
-	.change		=	NULL,
+	.change		=	fq_codel_change,
 	.dump		=	fq_codel_dump,
 	.dump_stats =	fq_codel_dump_stats,
 	.owner		=	THIS_MODULE,
