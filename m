From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Mon, 17 Mar 2014 23:27:52 -0700
Message-ID: <87fvmgf2c7.fsf_-_@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34159 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaCRG16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 02:27:58 -0400
In-Reply-To: <87iorcgh5d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 17 Mar 2014 23:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add a test skb_irq_freeable to report when it is safe to free a skb
from irq context.

It is not safe to free an skb from irq context when:
- The skb has a destructor as some skb destructors call local_bh_disable
  or spin_lock_bh.
- There is xfrm state as __xfrm_state_destroy calls spin_lock_bh.
- There is netfilter conntrack state as destroy_conntrack calls
  spin_lock_bh.
- If there is a refcounted dst entry on the skb, as __dst_free
  calls spin_lock_bh.
- If there is a frag_list, which could be a list of any skbs.
Otherwise it appears safe to free a skb from interrupt context.

- Update the warning in skb_releae_head_state to warn about freeing
  skb's in the wrong context.

- Update __dev_kfree_skb_irq to free all skbs that it can immediately

- Kill zap_completion_queue because there is no point going through
  a queue of packets that are not safe to free and looking for packets
  that are safe to free.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/skbuff.h |   13 +++++++++++++
 net/core/dev.c         |   14 +++++++++-----
 net/core/netpoll.c     |   32 --------------------------------
 net/core/skbuff.c      |   13 ++++++++++---
 4 files changed, 32 insertions(+), 40 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 03db95ab8a8c..53f72b53fd47 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2833,6 +2833,19 @@ static inline void skb_init_secmark(struct sk_buff *skb)
 { }
 #endif
 
+static inline bool skb_irq_freeable(struct sk_buff *skb)
+{
+	return !skb->destructor &&
+#if IS_ENABLED(CONFIG_XFRM)
+		!skb->sp &&
+#endif
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+		!skb->nfct &&
+#endif
+		(!skb->_skb_refdst || (skb->_skb_refdst & SKB_DST_NOREF)) &&
+		!skb_has_frag_list(skb);
+}
+
 static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
 {
 	skb->queue_mapping = queue_mapping;
diff --git a/net/core/dev.c b/net/core/dev.c
index 8b3ea4058a5e..99fd079488aa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2164,11 +2164,15 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
 		return;
 	}
 	get_kfree_skb_cb(skb)->reason = reason;
-	local_irq_save(flags);
-	skb->next = __this_cpu_read(softnet_data.completion_queue);
-	__this_cpu_write(softnet_data.completion_queue, skb);
-	raise_softirq_irqoff(NET_TX_SOFTIRQ);
-	local_irq_restore(flags);
+	if (unlikely(skb_irq_freeable(skb))) {
+		__kfree_skb(skb);
+	} else {
+		local_irq_save(flags);
+		skb->next = __this_cpu_read(softnet_data.completion_queue);
+		__this_cpu_write(softnet_data.completion_queue, skb);
+		raise_softirq_irqoff(NET_TX_SOFTIRQ);
+		local_irq_restore(flags);
+	}
 }
 EXPORT_SYMBOL(__dev_kfree_skb_irq);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index dec929b71348..0cd492508a88 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -56,7 +56,6 @@ DEFINE_STATIC_SRCU(netpoll_srcu);
 	 sizeof(struct udphdr) +					\
 	 MAX_UDP_CHUNK)
 
-static void zap_completion_queue(void);
 static void netpoll_async_cleanup(struct work_struct *work);
 
 static unsigned int carrier_timeout = 4;
@@ -210,8 +209,6 @@ static void netpoll_poll_dev(struct net_device *dev)
 	poll_napi(dev, budget);
 
 	up(&ni->dev_lock);
-
-	zap_completion_queue();
 }
 
 void netpoll_poll_disable(struct net_device *dev)
@@ -254,40 +251,11 @@ static void refill_skbs(void)
 	spin_unlock_irqrestore(&skb_pool.lock, flags);
 }
 
-static void zap_completion_queue(void)
-{
-	unsigned long flags;
-	struct softnet_data *sd = &get_cpu_var(softnet_data);
-
-	if (sd->completion_queue) {
-		struct sk_buff *clist;
-
-		local_irq_save(flags);
-		clist = sd->completion_queue;
-		sd->completion_queue = NULL;
-		local_irq_restore(flags);
-
-		while (clist != NULL) {
-			struct sk_buff *skb = clist;
-			clist = clist->next;
-			if (skb->destructor) {
-				atomic_inc(&skb->users);
-				dev_kfree_skb_any(skb); /* put this one back */
-			} else {
-				__kfree_skb(skb);
-			}
-		}
-	}
-
-	put_cpu_var(softnet_data);
-}
-
 static struct sk_buff *find_skb(struct netpoll *np, int len, int reserve)
 {
 	int count = 0;
 	struct sk_buff *skb;
 
-	zap_completion_queue();
 	refill_skbs();
 repeat:
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3f14c638c2b1..5654e3eb4066 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -554,14 +554,21 @@ static void kfree_skbmem(struct sk_buff *skb)
 
 static void skb_release_head_state(struct sk_buff *skb)
 {
+	WARN_ONCE(in_irq() && !skb_irq_freeable(skb),
+		  "%s called from irq! sp %d nfct %d frag_list %d %pF dst %lx",
+		  __func__,
+		  IS_ENABLED(CONFIG_XFRM) ? !!skb->sp : 0,
+		  IS_ENABLED(CONFIG_NF_CONNTRACK) ? !!skb->nfct : 0,
+		  !!skb_has_frag_list(skb),
+		  skb->destructor,
+		  skb->_skb_refdst);
+
 	skb_dst_drop(skb);
 #ifdef CONFIG_XFRM
 	secpath_put(skb->sp);
 #endif
-	if (skb->destructor) {
-		WARN_ON(in_irq());
+	if (skb->destructor)
 		skb->destructor(skb);
-	}
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 #endif
-- 
1.7.5.4
