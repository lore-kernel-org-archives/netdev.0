From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] gen_estimator: deadlock fix
Date: Wed, 31 Mar 2010 19:06:04 +0200
Message-ID: <1270055164.2103.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63697 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757867Ab0CaRGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 13:06:09 -0400
Received: by bwz1 with SMTP id 1so243261bwz.21
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 10:06:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, feel free to apply following to net-next, as I believe
probability to get this deadlock is close to 0.

Deadlock occurred once with a test machine running latest net-next-2.6,
I was not able to reproduce it a second time, so cannot confirm this fix
is correct.

Thanks

[PATCH] gen_estimator: deadlock fix

One of my test machine got a deadlock during "tc" sessions,
adding/deleting classes & filters, using traffic estimators.

After some analysis, I believe we have a potential use after free case
in est_timer() :

spin_lock(e->stats_lock); << HERE >>
read_lock(&est_lock);
if (e->bstats == NULL)   << TEST >>
	goto skip;

Test is done a bit late, because after estimator is killed, and before
rcu grace period elapsed, we might already have freed/reuse memory where
e->stats_locks points to (some qdisc->q.lock)

A possible fix is to respect a rcu grace period at Qdisc dismantle time.

On 64bit, sizeof(struct Qdisc) is exactly 192 bytes. Adding 16 bytes to
it (for struct rcu_head) is a problem because it might change
performance, given QDISC_ALIGNTO is 32 bytes. 

This is why I also change QDISC_ALIGNTO to 64 bytes, to satisfy most
current alignment requirements.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/pkt_sched.h   |    2 +-
 include/net/sch_generic.h |    1 +
 net/sched/sch_generic.c   |   15 +++++++++++++--
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b6cdc33..9d4d87c 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -12,7 +12,7 @@ struct qdisc_walker {
 	int	(*fn)(struct Qdisc *, unsigned long cl, struct qdisc_walker *);
 };
 
-#define QDISC_ALIGNTO		32
+#define QDISC_ALIGNTO		64
 #define QDISC_ALIGN(len)	(((len) + QDISC_ALIGNTO-1) & ~(QDISC_ALIGNTO-1))
 
 static inline void *qdisc_priv(struct Qdisc *q)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 67dc08e..03ca5d8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -73,6 +73,7 @@ struct Qdisc {
 	struct sk_buff_head	q;
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue	qstats;
+	struct rcu_head     rcu_head;
 };
 
 struct Qdisc_class_ops {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5173c1e..1751325 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -528,7 +528,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	unsigned int size;
 	int err = -ENOBUFS;
 
-	/* ensure that the Qdisc and the private data are 32-byte aligned */
+	/* ensure that the Qdisc and the private data are 64-byte aligned */
 	size = QDISC_ALIGN(sizeof(*sch));
 	size += ops->priv_size + (QDISC_ALIGNTO - 1);
 
@@ -590,6 +590,13 @@ void qdisc_reset(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_reset);
 
+static void qdisc_rcu_free(struct rcu_head *head)
+{
+	struct Qdisc *qdisc = container_of(head, struct Qdisc, rcu_head);
+
+	kfree((char *) qdisc - qdisc->padded);
+}
+
 void qdisc_destroy(struct Qdisc *qdisc)
 {
 	const struct Qdisc_ops  *ops = qdisc->ops;
@@ -613,7 +620,11 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	dev_put(qdisc_dev(qdisc));
 
 	kfree_skb(qdisc->gso_skb);
-	kfree((char *) qdisc - qdisc->padded);
+	/*
+	 * gen_estimator est_timer() might access qdisc->q.lock,
+	 * wait a RCU grace period before freeing qdisc.
+	 */
+	call_rcu(&qdisc->rcu_head, qdisc_rcu_free);
 }
 EXPORT_SYMBOL(qdisc_destroy);
 


