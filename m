From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 10:55:37 +0200
Message-ID: <20080816085536.GA1737@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <48A5E42B.8060903@gmail.com> <200808152336.05424.denys@visp.net.lb> <200808152354.24486.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:26823 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbYHPIyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 04:54:01 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1373527ika.5
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 01:53:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808152354.24486.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 11:54:24PM +0300, Denys Fedoryshchenko wrote:
> Btw, it can happen on deletion also. At that moment there was 600 sessions 
> established(and non-stop logging in/off), and it is difficult to tell, what 
> was happening at that moment...

Alas I can't find the reason, so here is some debugging patch (not tested!).

Jarek P. 

---

 include/linux/skbuff.h  |   43 +++++++++++++++++++++++++++++++------------
 net/sched/sch_generic.c |    1 +
 2 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 358661c..c46b1bd 100644
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
@@ -679,10 +681,15 @@ static inline void __skb_insert(struct sk_buff *newsk,
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
+		WARN_ON(1);
+	}
 }
 
 /**
@@ -775,10 +782,16 @@ static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
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
@@ -792,10 +805,16 @@ static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
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
 
