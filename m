From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_hhf: fix return value of hhf_drop()
Date: Wed,  7 Oct 2015 16:47:32 -0700
Message-ID: <1444261652-3177-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Terry Lam <vtlam@google.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32980 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbbJGXrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 19:47:40 -0400
Received: by pacex6 with SMTP id ex6so35090277pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 16:47:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit c0afd9ce4d6a ("fq_codel: fix return value of fq_codel_drop()")
->drop() is supposed to return the number of bytes it dropped,
but hhf_drop () returns the id of the bucket where it drops
a packet from.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Terry Lam <vtlam@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/sch_hhf.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 9d15cb6..86b04e3 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -368,6 +368,15 @@ static unsigned int hhf_drop(struct Qdisc *sch)
 	return bucket - q->buckets;
 }
 
+static unsigned int hhf_qdisc_drop(struct Qdisc *sch)
+{
+	unsigned int prev_backlog;
+
+	prev_backlog = sch->qstats.backlog;
+	hhf_drop(sch);
+	return prev_backlog - sch->qstats.backlog;
+}
+
 static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct hhf_sched_data *q = qdisc_priv(sch);
@@ -696,7 +705,7 @@ static struct Qdisc_ops hhf_qdisc_ops __read_mostly = {
 	.enqueue	=	hhf_enqueue,
 	.dequeue	=	hhf_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	hhf_drop,
+	.drop		=	hhf_qdisc_drop,
 	.init		=	hhf_init,
 	.reset		=	hhf_reset,
 	.destroy	=	hhf_destroy,
-- 
1.8.3.1
