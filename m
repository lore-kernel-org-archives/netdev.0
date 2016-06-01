From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_prio: update backlog as well
Date: Wed,  1 Jun 2016 16:15:16 -0700
Message-ID: <1464822920-14205-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stasn77@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32895 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751595AbcFAXPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:15:42 -0400
Received: by mail-pf0-f194.google.com with SMTP id b124so5620722pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 16:15:41 -0700 (PDT)
In-Reply-To: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to update backlog too when we update qlen.

Joint work with Stas.

Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Tested-by: Stas Nichiporovich <stasn77@gmail.com>
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_prio.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index fee1b15..4b0a821 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -85,6 +85,7 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	ret = qdisc_enqueue(skb, qdisc);
 	if (ret == NET_XMIT_SUCCESS) {
+		qdisc_qstats_backlog_inc(sch, skb);
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -117,6 +118,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc *sch)
 		struct sk_buff *skb = qdisc_dequeue_peeked(qdisc);
 		if (skb) {
 			qdisc_bstats_update(sch, skb);
+			qdisc_qstats_backlog_dec(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
@@ -135,6 +137,7 @@ static unsigned int prio_drop(struct Qdisc *sch)
 	for (prio = q->bands-1; prio >= 0; prio--) {
 		qdisc = q->queues[prio];
 		if (qdisc->ops->drop && (len = qdisc->ops->drop(qdisc)) != 0) {
+			sch->qstats.backlog -= len;
 			sch->q.qlen--;
 			return len;
 		}
@@ -151,6 +154,7 @@ prio_reset(struct Qdisc *sch)
 
 	for (prio = 0; prio < q->bands; prio++)
 		qdisc_reset(q->queues[prio]);
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 }
 
-- 
2.1.0
