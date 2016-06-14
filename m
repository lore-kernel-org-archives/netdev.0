From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/10] net_sched: sch_choke: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:51 -0700
Message-ID: <1465874519-25494-3-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33069 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:22:55 -0400
Received: by mail-pf0-f178.google.com with SMTP id y124so52564452pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:22:54 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

choke_reset() and choke_change() can use rtnl_qdisc_drop()
to defer expensive skb freeing after locks are released.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_choke.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 04e0b0583e00..789b69ee9e51 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -375,11 +375,11 @@ static void choke_reset(struct Qdisc *sch)
 		q->head = (q->head + 1) & q->tab_mask;
 		if (!skb)
 			continue;
-		qdisc_qstats_backlog_dec(sch, skb);
-		--sch->q.qlen;
-		qdisc_drop(skb, sch);
+		rtnl_qdisc_drop(skb, sch);
 	}
 
+	sch->q.qlen = 0;
+	sch->qstats.backlog = 0;
 	memset(q->tab, 0, (q->tab_mask + 1) * sizeof(struct sk_buff *));
 	q->head = q->tail = 0;
 	red_restart(&q->vars);
@@ -455,7 +455,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 				dropped += qdisc_pkt_len(skb);
 				qdisc_qstats_backlog_dec(sch, skb);
 				--sch->q.qlen;
-				qdisc_drop(skb, sch);
+				rtnl_qdisc_drop(skb, sch);
 			}
 			qdisc_tree_reduce_backlog(sch, oqlen - sch->q.qlen, dropped);
 			q->head = 0;
-- 
2.8.0.rc3.226.g39d4020
