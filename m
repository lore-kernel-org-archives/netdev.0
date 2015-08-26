From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 4/5] net_sched: forbid setting default qdisc to inappropriate ones
Date: Wed, 26 Aug 2015 15:41:26 -0700
Message-ID: <1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34853 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757222AbbHZWlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 18:41:37 -0400
Received: by pacdd16 with SMTP id dd16so1927816pac.2
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 15:41:37 -0700 (PDT)
In-Reply-To: <1440628887-3504-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no check for if a qdisc is appropriate
to be used as the default qdisc. This causes we get no
error even we set the default qdisc to an inappropriate one
but an error will be shown up later. This is not good.

Also, for qdisc's like HTB, kernel will just crash when
we use it as default qdisc, because some data structures are
not even initialized yet before checking opt == NULL, the cleanup
doing ->reset() or ->destroy() on them will just crash.

Let's fail as early as we can.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
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
index f7ad38a..2e6748e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -182,6 +182,7 @@ struct Qdisc_ops {
 #define QDISC_F_BUILTIN		1
 #define QDISC_F_MQ		2
 #define QDISC_F_FIFO		4
+#define QDISC_F_DEFAULTABLE	8
 	unsigned int		flags;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 90a4cf9..e501e9d 100644
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
+		if (!(ops->flags & QDISC_F_DEFAULTABLE)) {
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
index e51d786..83947f6 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -96,7 +96,7 @@ static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.id		=	"pfifo",
 	.priv_size	=	0,
-	.flags 		=	QDISC_F_FIFO,
+	.flags 		=	QDISC_F_FIFO | QDISC_F_DEFAULTABLE,
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -112,7 +112,7 @@ EXPORT_SYMBOL(pfifo_qdisc_ops);
 struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.id		=	"bfifo",
 	.priv_size	=	0,
-	.flags 		=	QDISC_F_FIFO,
+	.flags 		=	QDISC_F_FIFO | QDISC_F_DEFAULTABLE,
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
@@ -128,7 +128,7 @@ EXPORT_SYMBOL(bfifo_qdisc_ops);
 struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
 	.id		=	"pfifo_head_drop",
 	.priv_size	=	0,
-	.flags 		=	QDISC_F_FIFO,
+	.flags 		=	QDISC_F_FIFO | QDISC_F_DEFAULTABLE,
 	.enqueue	=	pfifo_tail_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
 	.peek		=	qdisc_peek_head,
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index f377702..e543b41 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -831,6 +831,7 @@ static int fq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 
 static struct Qdisc_ops fq_qdisc_ops __read_mostly = {
 	.id		=	"fq",
+	.flags		=	QDISC_F_DEFAULTABLE,
 	.priv_size	=	sizeof(struct fq_sched_data),
 
 	.enqueue	=	fq_enqueue,
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index a9ba030..f8f5e82 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -625,6 +625,7 @@ static const struct Qdisc_class_ops fq_codel_class_ops = {
 static struct Qdisc_ops fq_codel_qdisc_ops __read_mostly = {
 	.cl_ops		=	&fq_codel_class_ops,
 	.id		=	"fq_codel",
+	.flags		=	QDISC_F_DEFAULTABLE,
 	.priv_size	=	sizeof(struct fq_codel_sched_data),
 	.enqueue	=	fq_codel_enqueue,
 	.dequeue	=	fq_codel_dequeue,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 70b7713..051adf9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -567,7 +567,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
-	.flags		=	QDISC_F_FIFO,
+	.flags		=	QDISC_F_FIFO | QDISC_F_DEFAULTABLE,
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index cab9fc2..d1027bb 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -236,7 +236,7 @@ static const struct Qdisc_class_ops mq_class_ops = {
 struct Qdisc_ops mq_qdisc_ops __read_mostly = {
 	.cl_ops		= &mq_class_ops,
 	.id		= "mq",
-	.flags		= QDISC_F_MQ,
+	.flags		= QDISC_F_MQ | QDISC_F_DEFAULTABLE,
 	.priv_size	= sizeof(struct mq_sched),
 	.init		= mq_init,
 	.destroy	= mq_destroy,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 52f75a5..0479d44 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -890,6 +890,7 @@ static const struct Qdisc_class_ops sfq_class_ops = {
 static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.cl_ops		=	&sfq_class_ops,
 	.id		=	"sfq",
+	.flags		=	QDISC_F_DEFAULTABLE,
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
-- 
1.8.3.1
