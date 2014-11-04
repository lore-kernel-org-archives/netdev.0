From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 10/13] net_sched: forbid setting default qdisc to inappropriate ones
Date: Tue,  4 Nov 2014 09:56:33 -0800
Message-ID: <1415123796-8093-11-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40743 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbaKDR45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:57 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so14062145pde.18
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:57 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of just documentation, we should explicitly prohibit
setting the default qdisc to inappropriate ones. That is,
setting a flag for appropriate ones.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h |  1 +
 net/sched/sch_api.c       | 12 ++++++++++--
 net/sched/sch_fifo.c      |  6 +++---
 net/sched/sch_fq.c        |  1 +
 net/sched/sch_fq_codel.c  |  1 +
 net/sched/sch_generic.c   |  2 +-
 net/sched/sch_mq.c        |  2 +-
 net/sched/sch_sfq.c       |  1 +
 8 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ba3b6bf..89c3f37 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -185,6 +185,7 @@ struct Qdisc_ops {
 #define QDISC_F_BUILTIN		1
 #define QDISC_F_MQ		2
 #define QDISC_F_FIFO		4
+#define QDISC_F_PARAM_LESS	8
 	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 98b315f..f57d3c6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -227,6 +227,7 @@ static struct Qdisc_ops *qdisc_lookup_default(const char *name)
 int qdisc_set_default(const char *name)
 {
 	const struct Qdisc_ops *ops;
+	int err = 0;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -243,13 +244,20 @@ int qdisc_set_default(const char *name)
 	}
 
 	if (ops) {
+		if (!(ops->flags & QDISC_F_PARAM_LESS)) {
+			err = -EINVAL;
+			goto unlock;
+		}
 		/* Set new default */
 		module_put(default_qdisc_ops->owner);
 		default_qdisc_ops = ops;
+	} else {
+		err = -ENOENT;
 	}
-	write_unlock(&qdisc_mod_lock);
 
-	return ops ? 0 : -ENOENT;
+unlock:
+	write_unlock(&qdisc_mod_lock);
+	return err;
 }
 
 /* We know handle. Find qdisc among all qdisc's attached to device
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index c21a037..6bed08b 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -96,7 +96,7 @@ static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.id		=	"pfifo",
 	.priv_size	=	0,
-	.flags 		=	QDISC_F_FIFO,
+	.flags 		=	QDISC_F_FIFO | QDISC_F_PARAM_LESS,
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -112,7 +112,7 @@ EXPORT_SYMBOL(pfifo_qdisc_ops);
 struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.id		=	"bfifo",
 	.priv_size	=	0,
-	.flags 		=	QDISC_F_FIFO,
+	.flags 		=	QDISC_F_FIFO | QDISC_F_PARAM_LESS,
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -128,7 +128,7 @@ EXPORT_SYMBOL(bfifo_qdisc_ops);
 struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
 	.id		=	"pfifo_head_drop",
 	.priv_size	=	0,
-	.flags 		=	QDISC_F_FIFO,
+	.flags 		=	QDISC_F_FIFO | QDISC_F_PARAM_LESS,
 	.enqueue	=	pfifo_tail_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 34ec70c..7c359b2 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -805,6 +805,7 @@ static int fq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 
 static struct Qdisc_ops fq_qdisc_ops __read_mostly = {
 	.id		=	"fq",
+	.flags		=	QDISC_F_PARAM_LESS,
 	.priv_size	=	sizeof(struct fq_sched_data),
 
 	.enqueue	=	fq_enqueue,
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index b9ca32e..acc06bf 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -594,6 +594,7 @@ static const struct Qdisc_class_ops fq_codel_class_ops = {
 static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
 	.cl_ops		=	&fq_codel_class_ops,
 	.id		=	"fq_codel",
+	.flags		=	QDISC_F_PARAM_LESS,
 	.priv_size	=	sizeof(struct fq_codel_sched_data),
 	.enqueue	=	fq_codel_enqueue,
 	.dequeue	=	fq_codel_dequeue,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2b1931d..29db9c8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -567,7 +567,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
-	.flags		=	QDISC_F_FIFO,
+	.flags		=	QDISC_F_FIFO | QDISC_F_PARAM_LESS,
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 03b8069..43f9dc8 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -236,7 +236,7 @@ static const struct Qdisc_class_ops mq_class_ops = {
 struct Qdisc_ops mq_qdisc_ops __read_mostly = {
 	.cl_ops		= &mq_class_ops,
 	.id		= "mq",
-	.flags		= QDISC_F_MQ,
+	.flags		= QDISC_F_MQ | QDISC_F_PARAM_LESS,
 	.priv_size	= sizeof(struct mq_sched),
 	.init		= mq_init,
 	.destroy	= mq_destroy,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6212652..0d88d52 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -913,6 +913,7 @@ static const struct Qdisc_class_ops sfq_class_ops = {
 static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.cl_ops		=	&sfq_class_ops,
 	.id		=	"sfq",
+	.flags		=	QDISC_F_PARAM_LESS,
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
-- 
1.8.3.1
