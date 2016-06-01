From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_tbf: update backlog as well
Date: Wed,  1 Jun 2016 16:15:19 -0700
Message-ID: <1464822920-14205-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stasn77@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36846 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbcFAXPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:15:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id 62so5586217pfd.3
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 16:15:39 -0700 (PDT)
In-Reply-To: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_tbf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 83b90b5..3161e49 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -207,6 +207,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return ret;
 	}
 
+	qdisc_qstats_backlog_inc(sch, skb);
 	sch->q.qlen++;
 	return NET_XMIT_SUCCESS;
 }
@@ -217,6 +218,7 @@ static unsigned int tbf_drop(struct Qdisc *sch)
 	unsigned int len = 0;
 
 	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+		sch->qstats.backlog -= len;
 		sch->q.qlen--;
 		qdisc_qstats_drop(sch);
 	}
@@ -263,6 +265,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 			q->t_c = now;
 			q->tokens = toks;
 			q->ptokens = ptoks;
+			qdisc_qstats_backlog_dec(sch, skb);
 			sch->q.qlen--;
 			qdisc_unthrottled(sch);
 			qdisc_bstats_update(sch, skb);
@@ -294,6 +297,7 @@ static void tbf_reset(struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 	q->t_c = ktime_get_ns();
 	q->tokens = q->buffer;
-- 
2.1.0
