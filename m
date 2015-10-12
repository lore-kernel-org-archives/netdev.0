From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/4] sch_htb: update backlog as well
Date: Mon, 12 Oct 2015 11:38:02 -0700
Message-ID: <1444675083-9825-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35084 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbbJLSiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 14:38:18 -0400
Received: by pabve7 with SMTP id ve7so102703888pab.2
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 11:38:18 -0700 (PDT)
In-Reply-To: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is odd to see qlen!=0 but backlog==0, for a real example:

qdisc htb 1: dev eth0 root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17
 Sent 172680457356 bytes 222469449 pkt (dropped 0, overlimits 123575834 requeues 0)
 backlog 0b 72p requeues 0

So we need to update backlog too when we update qlen.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_htb.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 846a7f9..87b02ed3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -600,6 +600,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		htb_activate(q, cl);
 	}
 
+	qdisc_qstats_backlog_inc(sch, skb);
 	sch->q.qlen++;
 	return NET_XMIT_SUCCESS;
 }
@@ -889,6 +890,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 ok:
 		qdisc_bstats_update(sch, skb);
 		qdisc_unthrottled(sch);
+		qdisc_qstats_backlog_dec(sch, skb);
 		sch->q.qlen--;
 		return skb;
 	}
@@ -955,6 +957,7 @@ static unsigned int htb_drop(struct Qdisc *sch)
 			unsigned int len;
 			if (cl->un.leaf.q->ops->drop &&
 			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
+				sch->qstats.backlog -= len;
 				sch->q.qlen--;
 				if (!cl->un.leaf.q->q.qlen)
 					htb_deactivate(q, cl);
@@ -984,12 +987,12 @@ static void htb_reset(struct Qdisc *sch)
 			}
 			cl->prio_activity = 0;
 			cl->cmode = HTB_CAN_SEND;
-
 		}
 	}
 	qdisc_watchdog_cancel(&q->watchdog);
 	__skb_queue_purge(&q->direct_queue);
 	sch->q.qlen = 0;
+	sch->qstats.backlog = 0;
 	memset(q->hlevel, 0, sizeof(q->hlevel));
 	memset(q->row_mask, 0, sizeof(q->row_mask));
 	for (i = 0; i < TC_HTB_NUMPRIO; i++)
-- 
1.8.3.1
