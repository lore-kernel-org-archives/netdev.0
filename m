From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 11:13:32 +0200
Message-ID: <20080816091332.GA3467@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <48A5E42B.8060903@gmail.com> <200808152336.05424.denys@visp.net.lb> <200808152354.24486.denys@visp.net.lb> <20080816085536.GA1737@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:63707 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbYHPJLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 05:11:49 -0400
Received: by ug-out-1314.google.com with SMTP id c2so22081ugf.37
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 02:11:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080816085536.GA1737@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 16, 2008 at 10:55:37AM +0200, Jarek Poplawski wrote:
> On Fri, Aug 15, 2008 at 11:54:24PM +0300, Denys Fedoryshchenko wrote:
> > Btw, it can happen on deletion also. At that moment there was 600 sessions 
> > established(and non-stop logging in/off), and it is difficult to tell, what 
> > was happening at that moment...
> 
> Alas I can't find the reason, so here is some debugging patch (not tested!).

Hold on a minute! Forget the previous patch - here is a take #2.

Jarek P. 

---

 include/linux/skbuff.h  |   44 ++++++++++++++++++++++++++++++++------------
 net/sched/sch_generic.c |    1 +
 2 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 358661c..506142e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -120,6 +120,7 @@ struct sk_buff_head {
 
 	__u32		qlen;
 	spinlock_t	lock;
+	spinlock_t	lock_debug;
 };
 
 struct sk_buff;
@@ -657,6 +658,7 @@ static inline __u32 skb_queue_len(const struct sk_buff_head *list_)
 static inline void skb_queue_head_init(struct sk_buff_head *list)
 {
 	spin_lock_init(&list->lock);
+	spin_lock_init(&list->lock_debug);
 	list->prev = list->next = (struct sk_buff *)list;
 	list->qlen = 0;
 }
@@ -679,10 +681,16 @@ static inline void __skb_insert(struct sk_buff *newsk,
 				struct sk_buff *prev, struct sk_buff *next,
 				struct sk_buff_head *list)
 {
-	newsk->next = next;
-	newsk->prev = prev;
-	next->prev  = prev->next = newsk;
-	list->qlen++;
+	if (spin_trylock(&list->lock_debug)) {
+		newsk->next = next;
+		newsk->prev = prev;
+		next->prev  = prev->next = newsk;
+		list->qlen++;
+		spin_unlock(&list->lock_debug);
+	} else {
+		kfree_skb(newsk);
+		WARN_ON(1);
+	}
 }
 
 /**
@@ -775,10 +783,16 @@ static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
 extern struct sk_buff *skb_dequeue(struct sk_buff_head *list);
 static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
 {
-	struct sk_buff *skb = skb_peek(list);
-	if (skb)
-		__skb_unlink(skb, list);
-	return skb;
+	if (spin_trylock(&list->lock_debug)) {
+		struct sk_buff *skb = skb_peek(list);
+		if (skb)
+			__skb_unlink(skb, list);
+		spin_unlock(&list->lock_debug);
+		return skb;
+	} else {
+		WARN_ON(1);
+		return NULL;
+	}
 }
 
 /**
@@ -792,10 +806,16 @@ static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
 extern struct sk_buff *skb_dequeue_tail(struct sk_buff_head *list);
 static inline struct sk_buff *__skb_dequeue_tail(struct sk_buff_head *list)
 {
-	struct sk_buff *skb = skb_peek_tail(list);
-	if (skb)
-		__skb_unlink(skb, list);
-	return skb;
+	if (spin_trylock(&list->lock_debug)) {
+		struct sk_buff *skb = skb_peek_tail(list);
+		if (skb)
+			__skb_unlink(skb, list);
+		spin_unlock(&list->lock_debug);
+		return skb;
+	} else {
+		WARN_ON(1);
+		return NULL;
+	}
 }
 
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4685746..bffe6cb 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -540,6 +540,7 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 	kfree_skb(qdisc->gso_skb);
 
+	memset(qdisc, 0xf0 , sizeof(*qdisc));
 	kfree((char *) qdisc - qdisc->padded);
 }
 
