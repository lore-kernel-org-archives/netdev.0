From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/10] net_sched: add the ability to defer skb freeing
Date: Mon, 13 Jun 2016 20:21:50 -0700
Message-ID: <1465874519-25494-2-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34783 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423239AbcFNDWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:22:46 -0400
Received: by mail-pa0-f49.google.com with SMTP id bz2so51747114pad.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:22:46 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qdisc are changed under RTNL protection and often
while blocking BH and root qdisc spinlock.

When lots of skbs need to be dropped, we free
them under these locks causing TX/RX freezes,
and more generally latency spikes.

This commit adds rtnl_kfree_skbs(), used to queue
skbs for deferred freeing.

Actual freeing happens right after RTNL is released,
with appropriate scheduling points.

rtnl_qdisc_drop() can also be used in place
of disc_drop() when RTNL is held.

qdisc_reset_queue() and __qdisc_reset_queue() get
the new behavior, so standard qdiscs like pfifo, pfifo_fast...
have their ->reset() method automatically handled.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/rtnetlink.h |  5 +++--
 include/net/sch_generic.h | 16 ++++++++++++----
 net/core/rtnetlink.c      | 22 ++++++++++++++++++++++
 net/sched/sch_generic.c   |  2 +-
 4 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index c006cc900c44..2daece8979f7 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -89,8 +89,9 @@ void net_inc_egress_queue(void);
 void net_dec_egress_queue(void);
 #endif
 
-extern void rtnetlink_init(void);
-extern void __rtnl_unlock(void);
+void rtnetlink_init(void);
+void __rtnl_unlock(void);
+void rtnl_kfree_skbs(struct sk_buff *head, struct sk_buff *tail);
 
 #define ASSERT_RTNL() do { \
 	if (unlikely(!rtnl_is_locked())) { \
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9a0d177884c6..4f7cee8344c4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -683,19 +683,21 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 	return skb;
 }
 
-static inline void __qdisc_reset_queue(struct Qdisc *sch,
-				       struct sk_buff_head *list)
+static inline void __qdisc_reset_queue(struct sk_buff_head *list)
 {
 	/*
 	 * We do not know the backlog in bytes of this list, it
 	 * is up to the caller to correct it
 	 */
-	__skb_queue_purge(list);
+	if (!skb_queue_empty(list)) {
+		rtnl_kfree_skbs(list->next, list->prev);
+		__skb_queue_head_init(list);
+	}
 }
 
 static inline void qdisc_reset_queue(struct Qdisc *sch)
 {
-	__qdisc_reset_queue(sch, &sch->q);
+	__qdisc_reset_queue(&sch->q);
 	sch->qstats.backlog = 0;
 }
 
@@ -716,6 +718,12 @@ static inline struct Qdisc *qdisc_replace(struct Qdisc *sch, struct Qdisc *new,
 	return old;
 }
 
+static inline void rtnl_qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
+{
+	rtnl_kfree_skbs(skb, skb);
+	qdisc_qstats_drop(sch);
+}
+
 static inline int qdisc_drop(struct sk_buff *skb, struct Qdisc *sch)
 {
 	kfree_skb(skb);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d69c4644f8f2..eb49ca24274a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -71,9 +71,31 @@ void rtnl_lock(void)
 }
 EXPORT_SYMBOL(rtnl_lock);
 
+static struct sk_buff *defer_kfree_skb_list;
+void rtnl_kfree_skbs(struct sk_buff *head, struct sk_buff *tail)
+{
+	if (head && tail) {
+		tail->next = defer_kfree_skb_list;
+		defer_kfree_skb_list = head;
+	}
+}
+EXPORT_SYMBOL(rtnl_kfree_skbs);
+
 void __rtnl_unlock(void)
 {
+	struct sk_buff *head = defer_kfree_skb_list;
+
+	defer_kfree_skb_list = NULL;
+
 	mutex_unlock(&rtnl_mutex);
+
+	while (head) {
+		struct sk_buff *next = head->next;
+
+		kfree_skb(head);
+		cond_resched();
+		head = next;
+	}
 }
 
 void rtnl_unlock(void)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0c9cb516f2e3..773b632e1e33 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -493,7 +493,7 @@ static void pfifo_fast_reset(struct Qdisc *qdisc)
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__qdisc_reset_queue(qdisc, band2list(priv, prio));
+		__qdisc_reset_queue(band2list(priv, prio));
 
 	priv->bitmap = 0;
 	qdisc->qstats.backlog = 0;
-- 
2.8.0.rc3.226.g39d4020
