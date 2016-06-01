From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_drr: update backlog as well
Date: Wed,  1 Jun 2016 16:15:17 -0700
Message-ID: <1464822920-14205-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: stasn77@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36832 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbcFAXPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 19:15:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id 62so5586140pfd.3
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 16:15:42 -0700 (PDT)
In-Reply-To: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_drr.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index a63e879..bf8af2c 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -375,6 +375,7 @@ static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		cl->deficit = cl->quantum;
 	}
 
+	qdisc_qstats_backlog_inc(sch, skb);
 	sch->q.qlen++;
 	return err;
 }
@@ -407,6 +408,7 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 
 			bstats_update(&cl->bstats, skb);
 			qdisc_bstats_update(sch, skb);
+			qdisc_qstats_backlog_dec(sch, skb);
 			sch->q.qlen--;
 			return skb;
 		}
@@ -428,6 +430,7 @@ static unsigned int drr_drop(struct Qdisc *sch)
 		if (cl->qdisc->ops->drop) {
 			len = cl->qdisc->ops->drop(cl->qdisc);
 			if (len > 0) {
+				sch->qstats.backlog -= len;
 				sch->q.qlen--;
 				if (cl->qdisc->q.qlen == 0)
 					list_del(&cl->alist);
@@ -463,6 +466,7 @@ static void drr_reset_qdisc(struct Qdisc *sch)
 			qdisc_reset(cl->qdisc);
 		}
 	}
+	sch->qstats.backlog = 0;
 	sch->q.qlen = 0;
 }
 
-- 
2.1.0
