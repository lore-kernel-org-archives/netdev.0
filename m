From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 3/5] net_sched: use a flag to indicate fifo qdiscs instead of the name
Date: Wed, 26 Aug 2015 15:41:25 -0700
Message-ID: <1440628887-3504-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33408 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041AbbHZWlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:41:36 -0400
Received: by pacti10 with SMTP id ti10so2002317pac.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:41:36 -0700 (PDT)
In-Reply-To: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relying on its name is a bad practice.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 1 +
 net/sched/sch_fifo.c      | 6 ++++--
 net/sched/sch_generic.c   | 1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 943736a..f7ad38a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -181,6 +181,7 @@ struct Qdisc_ops {
 	int			priv_size;
 #define QDISC_F_BUILTIN		1
 #define QDISC_F_MQ		2
+#define QDISC_F_FIFO		4
 	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 2177eac..e51d786 100644
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
index 460388a..70b7713 100644
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
