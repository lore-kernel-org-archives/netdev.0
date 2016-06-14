From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/10] net_sched: sch_htb: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:56 -0700
Message-ID: <1465874519-25494-8-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34949 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423251AbcFNDYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:24:00 -0400
Received: by mail-pf0-f176.google.com with SMTP id c2so52523140pfa.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:23:59 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both htb_reset() and htb_destroy() can use __qdisc_reset_queue()
instead of __skb_queue_purge() to defer skb freeing of internal
queues.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_htb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 07dcd2933f01..a454605ab5cb 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -957,7 +957,7 @@ static void htb_reset(struct Qdisc *sch)
 		}
 	}
 	qdisc_watchdog_cancel(&q->watchdog);
-	__skb_queue_purge(&q->direct_queue);
+	__qdisc_reset_queue(&q->direct_queue);
 	sch->q.qlen = 0;
 	sch->qstats.backlog = 0;
 	memset(q->hlevel, 0, sizeof(q->hlevel));
@@ -1231,7 +1231,7 @@ static void htb_destroy(struct Qdisc *sch)
 			htb_destroy_class(sch, cl);
 	}
 	qdisc_class_hash_destroy(&q->clhash);
-	__skb_queue_purge(&q->direct_queue);
+	__qdisc_reset_queue(&q->direct_queue);
 }
 
 static int htb_delete(struct Qdisc *sch, unsigned long arg)
-- 
2.8.0.rc3.226.g39d4020
