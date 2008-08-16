From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 14:27:31 +0200
Message-ID: <20080816122731.GA7519@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <20080816091332.GA3467@ami.dom.local> <200808161303.55411.denys@visp.net.lb> <200808161305.46768.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:49296 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbYHPMYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 08:24:19 -0400
Received: by nf-out-0910.google.com with SMTP id d3so873139nfc.21
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 05:24:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808161305.46768.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 16, 2008 at 01:05:46PM +0300, Denys Fedoryshchenko wrote:
> Sorry, one more without wrapping

So this patch proved without wrapping that I'm a moron!

Here is take 3, I hope more useful.

Sorry,
Jarek P.

---

 include/linux/skbuff.h  |   44 ++++++++++++++++++++++++++++++++------------
 net/sched/sch_generic.c |    5 ++++-
 2 files changed, 36 insertions(+), 13 deletions(-)

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
index 4685746..065a8b0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -525,6 +525,7 @@ static void __qdisc_destroy(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
 	const struct Qdisc_ops  *ops = qdisc->ops;
+	int p;
 
 #ifdef CONFIG_NET_SCHED
 	qdisc_put_stab(qdisc->stab);
@@ -540,7 +541,9 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 	kfree_skb(qdisc->gso_skb);
 
-	kfree((char *) qdisc - qdisc->padded);
+	p = qdisc->padded;
+	memset(qdisc, 0xf0 , sizeof(*qdisc));
+	kfree((char *) qdisc - p);
 }
 
 /* Under qdisc_lock(qdisc) and BH! */
