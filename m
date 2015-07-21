From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] sch_choke: drop all packets in queue during reset
Date: Tue, 21 Jul 2015 16:52:43 -0700
Message-ID: <1437522763-23765-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34328 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933284AbbGUXwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:52:55 -0400
Received: by pacan13 with SMTP id an13so129307615pac.1
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 16:52:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/sch_choke.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 93d5742..6a783af 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -385,6 +385,19 @@ static void choke_reset(struct Qdisc *sch)
 {
 	struct choke_sched_data *q = qdisc_priv(sch);
 
+	while (q->head != q->tail) {
+		struct sk_buff *skb = q->tab[q->head];
+
+		q->head = (q->head + 1) & q->tab_mask;
+		if (!skb)
+			continue;
+		qdisc_qstats_backlog_dec(sch, skb);
+		--sch->q.qlen;
+		qdisc_drop(skb, sch);
+	}
+
+	memset(q->tab, 0, (q->tab_mask + 1) * sizeof(struct sk_buff *));
+	q->head = q->tail = 0;
 	red_restart(&q->vars);
 }
 
-- 
1.8.3.1
