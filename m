From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] fq_codel: fix return value of fq_codel_drop()
Date: Tue, 14 Jul 2015 11:21:58 -0700
Message-ID: <1436898118-30804-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34930 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbbGNSW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 14:22:26 -0400
Received: by pactm7 with SMTP id tm7so9592795pac.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 11:22:25 -0700 (PDT)
In-Reply-To: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ->drop() is supposed to return the number of bytes it dropped,
however fq_codel_drop() returns the index of the flow where it drops
a packet from.

Fix this by introducing a helper to wrap fq_codel_drop().

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/sched/sch_fq_codel.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 06e7c84..21ca33c 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -163,6 +163,15 @@ static unsigned int fq_codel_drop(struct Qdisc *sch)
 	return idx;
 }
 
+static unsigned int fq_codel_qdisc_drop(struct Qdisc *sch)
+{
+	unsigned int prev_backlog;
+
+	prev_backlog = sch->qstats.backlog;
+	fq_codel_drop(sch);
+	return prev_backlog - sch->qstats.backlog;
+}
+
 static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
@@ -604,7 +613,7 @@ static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
 	.enqueue	=	fq_codel_enqueue,
 	.dequeue	=	fq_codel_dequeue,
 	.peek		=	qdisc_peek_dequeued,
-	.drop		=	fq_codel_drop,
+	.drop		=	fq_codel_qdisc_drop,
 	.init		=	fq_codel_init,
 	.reset		=	fq_codel_reset,
 	.destroy	=	fq_codel_destroy,
-- 
1.8.3.1
