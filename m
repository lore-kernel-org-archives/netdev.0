From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net] net: sch_red: Fix race between timer and red_destroy()
Date: Mon,  4 Nov 2013 18:08:16 -0800
Message-ID: <1383617296-20273-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, shemminger@vyatta.com, eric.dumazet@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:46311 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab3KECMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 21:12:13 -0500
Received: by mail-pd0-f178.google.com with SMTP id x10so7441941pdj.23
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 18:12:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure timer does not fire once qdisc is destroyed.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/sched/sch_red.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 633e32d..380507e 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -39,6 +39,7 @@
 struct red_sched_data {
 	u32			limit;		/* HARD maximal queue length */
 	unsigned char		flags;
+	bool			timeron;	/* to prevent race on destroy*/
 	struct timer_list	adapt_timer;
 	struct red_parms	parms;
 	struct red_vars		vars;
@@ -166,6 +167,7 @@ static void red_destroy(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
+	q->timeron = false;
 	del_timer_sync(&q->adapt_timer);
 	qdisc_destroy(q->qdisc);
 }
@@ -241,7 +243,8 @@ static inline void red_adaptative_timer(unsigned long arg)
 
 	spin_lock(root_lock);
 	red_adaptative_algo(&q->parms, &q->vars);
-	mod_timer(&q->adapt_timer, jiffies + HZ/2);
+	if (q->timeron)
+		mod_timer(&q->adapt_timer, jiffies + HZ/2);
 	spin_unlock(root_lock);
 }
 
@@ -250,6 +253,7 @@ static int red_init(struct Qdisc *sch, struct nlattr *opt)
 	struct red_sched_data *q = qdisc_priv(sch);
 
 	q->qdisc = &noop_qdisc;
+	q->timeron = true;
 	setup_timer(&q->adapt_timer, red_adaptative_timer, (unsigned long)sch);
 	return red_change(sch, opt);
 }
-- 
1.7.9.5
