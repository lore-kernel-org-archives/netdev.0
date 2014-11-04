From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 08/13] net_sched: use a flag to indicate fifo qdiscs instead of the name
Date: Tue,  4 Nov 2014 09:56:31 -0800
Message-ID: <1415123796-8093-9-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:41292 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbaKDR4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:55 -0500
Received: by mail-pd0-f172.google.com with SMTP id r10so14094427pdi.17
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:54 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 1 +
 net/sched/sch_fifo.c      | 6 ++++--
 net/sched/sch_generic.c   | 1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 852f0c5..e02d250 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -184,6 +184,7 @@ struct Qdisc_ops {
 	int			priv_size;
 #define QDISC_F_BUILTIN		1
 #define QDISC_F_MQ		2
+#define QDISC_F_FIFO		4
 	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 2e2398c..55f5212 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -96,6 +96,7 @@ static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.id		=	"pfifo",
 	.priv_size	=	0,
+	.flags 		=	QDISC_F_FIFO,
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -111,6 +112,7 @@ EXPORT_SYMBOL(pfifo_qdisc_ops);
 struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.id		=	"bfifo",
 	.priv_size	=	0,
+	.flags 		=	QDISC_F_FIFO,
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -126,6 +128,7 @@ EXPORT_SYMBOL(bfifo_qdisc_ops);
 struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
 	.id		=	"pfifo_head_drop",
 	.priv_size	=	0,
+	.flags 		=	QDISC_F_FIFO,
 	.enqueue	=	pfifo_tail_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -143,8 +146,7 @@ int fifo_set_limit(struct Qdisc *q, unsigned int limit)
 	struct nlattr *nla;
 	int ret = -ENOMEM;
 
-	/* Hack to avoid sending change message to non-FIFO */
-	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
+	if (!(q->ops->flags & QDISC_F_FIFO))
 		return 0;
 
 	nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3ab44a2..4550a46 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -567,6 +567,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
+	.flags		=	QDISC_F_FIFO,
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
-- 
1.8.3.1
