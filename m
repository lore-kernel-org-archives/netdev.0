From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_red: update backlog as well
Date: Wed,  1 Jun 2016 16:15:18 -0700
Message-ID: <1464822920-14205-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stasn77@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33259 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcFAXPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:15:38 -0400
Received: by mail-pa0-f68.google.com with SMTP id di3so1593861pab.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 16:15:38 -0700 (PDT)
In-Reply-To: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_red.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 8c0508c..91578bd 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -97,6 +97,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	ret = qdisc_enqueue(skb, child);
 	if (likely(ret == NET_XMIT_SUCCESS)) {
+		qdisc_qstats_backlog_inc(sch, skb);
 		sch->q.qlen++;
 	} else if (net_xmit_drop_count(ret)) {
 		q->stats.pdrop++;
@@ -118,6 +119,7 @@ static struct sk_buff *red_dequeue(struct Qdisc *sch)
 	skb = child->dequeue(child);
 	if (skb) {
 		qdisc_bstats_update(sch, skb);
+		qdisc_qstats_backlog_dec(sch, skb);
 		sch->q.qlen--;
 	} else {
 		if (!red_is_idling(&q->vars))
@@ -143,6 +145,7 @@ static unsigned int red_drop(struct Qdisc *sch)
 	if (child->ops->drop && (len = child->ops->drop(child)) > 0) {
 		q->stats.other++;
 		qdisc_qstats_drop(sch);
+		sch->qstats.backlog -= len;
 		sch->q.qlen--;
 		return len;
 	}
@@ -158,6 +161,7 @@ static void red_reset(struct Qdisc *sch)
 	struct red_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 	red_restart(&q->vars);
 }
-- 
2.1.0
