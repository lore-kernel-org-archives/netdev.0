From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V4 1/4] net: add a noref bit on skb dst
Date: Mon, 10 May 2010 23:32:42 +0200
Message-ID: <1273527162.10889.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41372 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab0EJVcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 17:32:48 -0400
Received: by wyb32 with SMTP id 32so463791wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 14:32:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use low order bit of skb->_skb_dst to tell dst is not refcounted.

Change _skb_dst to _skb_refdst to make sure all uses are catched.

skb_dst() returns the dst, regardless of noref bit set or not, but
with a lockdep check to make sure a noref dst is not given if current
user is not rcu protected.

New skb_dst_set_noref() helper to set an notrefcounted dst on a skb.
(with lockdep check)

skb_dst_drop() drops a reference only if skb dst was refcounted.

skb_dst_force() helper is used to force a refcount on dst, when skb
is queued and not anymore RCU protected.

Use skb_dst_force() in __sk_add_backlog(), __dev_xmit_skb() if 
!IFF_XMIT_DST_RELEASE or skb enqueued on qdisc queue, in
sock_queue_rcv_skb(), in __nf_queue().

Note: dst_use_noref() still dirties dst, we might transform it
later to do one dirtying per jiffies.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
include/linux/skbuff.h   |   58 ++++++++++++++++++++++++++++++++++---
include/net/dst.h        |   48 ++++++++++++++++++++++++++++--
include/net/sock.h       |   13 +++++---
net/core/dev.c           |    3 +
net/core/skbuff.c        |    2 -
net/core/sock.c          |    6 +++
net/ipv4/icmp.c          |    6 +--
net/ipv4/ip_options.c    |    9 +++--
net/ipv4/netfilter.c     |    6 +--
net/ipv4/route.c         |    2 -
net/netfilter/nf_queue.c |    2 +
net/sched/sch_generic.c  |    2 -
12 files changed, 132 insertions(+), 25 deletions(-) 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c9525bc..7cdfb4d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -264,7 +264,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
- *	@_skb_dst: destination entry
+ *	@_skb_refdst: destination entry (with norefcount bit)
  *	@sp: the security path, used for xfrm
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@len: Length of actual data
@@ -328,7 +328,7 @@ struct sk_buff {
 	 */
 	char			cb[48] __aligned(8);
 
-	unsigned long		_skb_dst;
+	unsigned long		_skb_refdst;
 #ifdef CONFIG_XFRM
 	struct	sec_path	*sp;
 #endif
@@ -419,14 +419,64 @@ struct sk_buff {
 
 #include <asm/system.h>
 
+/*
+ * skb might have a dst pointer attached, refcounted or not.
+ * _skb_refdst low order bit is set if refcount was _not_ taken
+ */
+#define SKB_DST_NOREF	1UL
+#define SKB_DST_PTRMASK	~(SKB_DST_NOREF)
+
+/**
+ * skb_dst - returns skb dst_entry
+ * @skb: buffer
+ *
+ * Returns skb dst_entry, regardless of reference taken or not.
+ */
 static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
 {
-	return (struct dst_entry *)skb->_skb_dst;
+	/* If refdst was not refcounted, check we still are in a 
+	 * rcu_read_lock section
+	 */
+	WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
+		!rcu_read_lock_held() &&
+		!rcu_read_lock_bh_held());
+	return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK);
 }
 
+/**
+ * skb_dst_set - sets skb dst
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was taken on dst and should
+ * be released by skb_dst_drop()
+ */
 static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 {
-	skb->_skb_dst = (unsigned long)dst;
+	skb->_skb_refdst = (unsigned long)dst;
+}
+
+/**
+ * skb_dst_set_noref - sets skb dst, without a reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was not taken on dst
+ * skb_dst_drop() should not dst_release() this dst
+ */
+static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
+{
+	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
+	skb->_skb_refdst = (unsigned long)dst | SKB_DST_NOREF;
+}
+
+/**
+ * skb_dst_is_noref - Test if skb dst isnt refcounted
+ * @skb: buffer
+ */
+static inline bool skb_dst_is_noref(const struct sk_buff *skb)
+{
+	return (skb->_skb_refdst & SKB_DST_NOREF) && skb_dst(skb);
 }
 
 static inline struct rtable *skb_rtable(const struct sk_buff *skb)
diff --git a/include/net/dst.h b/include/net/dst.h
index aac5a5f..27207a1 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -168,6 +168,12 @@ static inline void dst_use(struct dst_entry *dst, unsigned long time)
 	dst->lastuse = time;
 }
 
+static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
+{
+	dst->__use++;
+	dst->lastuse = time;
+}
+
 static inline
 struct dst_entry * dst_clone(struct dst_entry * dst)
 {
@@ -177,11 +183,47 @@ struct dst_entry * dst_clone(struct dst_entry * dst)
 }
 
 extern void dst_release(struct dst_entry *dst);
+
+static inline void refdst_drop(unsigned long refdst)
+{
+	if (!(refdst & SKB_DST_NOREF))
+		dst_release((struct dst_entry *)(refdst & SKB_DST_PTRMASK));
+}
+
+/**
+ * skb_dst_drop - drops skb dst
+ * @skb: buffer
+ *
+ * Drops dst reference count if a reference was taken.
+ */
 static inline void skb_dst_drop(struct sk_buff *skb)
 {
-	if (skb->_skb_dst)
-		dst_release(skb_dst(skb));
-	skb->_skb_dst = 0UL;
+	if (skb->_skb_refdst) {
+		refdst_drop(skb->_skb_refdst);
+		skb->_skb_refdst = 0UL;
+	}
+}
+
+static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_buff *oskb)
+{
+	nskb->_skb_refdst = oskb->_skb_refdst;
+	if (!(nskb->_skb_refdst & SKB_DST_NOREF))
+		dst_clone(skb_dst(nskb));
+}
+
+/**
+ * skb_dst_force - makes sure skb dst is refcounted
+ * @skb: buffer
+ *
+ * If dst is not yet refcounted, let's do it
+ */
+static inline void skb_dst_force(struct sk_buff *skb)
+{
+	if (skb_dst_is_noref(skb)) {
+		WARN_ON(!rcu_read_lock_held());
+		skb->_skb_refdst &= ~SKB_DST_NOREF;
+		dst_clone(skb_dst(skb));
+	}
 }
 
 /* Children define the path of the packet through the
diff --git a/include/net/sock.h b/include/net/sock.h
index 328e03f..307affa 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -598,12 +598,15 @@ static inline int sk_stream_memory_free(struct sock *sk)
 /* OOB backlog add */
 static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
 {
-	if (!sk->sk_backlog.tail) {
-		sk->sk_backlog.head = sk->sk_backlog.tail = skb;
-	} else {
+	/* dont let skb dst not refcounted, we are going to leave rcu lock */
+	skb_dst_force(skb);
+
+	if (!sk->sk_backlog.tail)
+		sk->sk_backlog.head = skb;
+	else
 		sk->sk_backlog.tail->next = skb;
-		sk->sk_backlog.tail = skb;
-	}
+
+	sk->sk_backlog.tail = skb;
 	skb->next = NULL;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 32611c8..dfe6ba6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2047,6 +2047,8 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		 * waiting to be sent out; and the qdisc is not running -
 		 * xmit the skb directly.
 		 */
+		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
+			skb_dst_force(skb);
 		__qdisc_update_bstats(q, skb->len);
 		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
 			__qdisc_run(q);
@@ -2055,6 +2057,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		rc = NET_XMIT_SUCCESS;
 	} else {
+		skb_dst_force(skb);
 		rc = qdisc_enqueue_root(skb, q);
 		qdisc_run(q);
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a9b0e1f..c543dd2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -520,7 +520,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->transport_header	= old->transport_header;
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
-	skb_dst_set(new, dst_clone(skb_dst(old)));
+	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
diff --git a/net/core/sock.c b/net/core/sock.c
index 94c4aff..d24b5c1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -307,6 +307,11 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	skb_len = skb->len;
 
+	/* we escape from rcu protected region, make sure we dont leak
+	 * a norefcounted dst
+	 */
+	skb_dst_force(skb);
+
 	spin_lock_irqsave(&list->lock, flags);
 	skb->dropcount = atomic_read(&sk->sk_drops);
 	__skb_queue_tail(list, skb);
@@ -1535,6 +1540,7 @@ static void __release_sock(struct sock *sk)
 		do {
 			struct sk_buff *next = skb->next;
 
+			WARN_ON_ONCE(skb_dst_is_noref(skb));
 			skb->next = NULL;
 			sk_backlog_rcv(sk, skb);
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f3d339f..d65e921 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -587,20 +587,20 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 			err = __ip_route_output_key(net, &rt2, &fl);
 		else {
 			struct flowi fl2 = {};
-			struct dst_entry *odst;
+			unsigned long orefdst;
 
 			fl2.fl4_dst = fl.fl4_src;
 			if (ip_route_output_key(net, &rt2, &fl2))
 				goto relookup_failed;
 
 			/* Ugh! */
-			odst = skb_dst(skb_in);
+			orefdst = skb_in->_skb_refdst; /* save old refdst */
 			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
 					     RT_TOS(tos), rt2->u.dst.dev);
 
 			dst_release(&rt2->u.dst);
 			rt2 = skb_rtable(skb_in);
-			skb_dst_set(skb_in, odst);
+			skb_in->_skb_refdst = orefdst; /* restore old refdst */
 		}
 
 		if (err)
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 4c09a31..3244133 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -601,6 +601,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	unsigned char *optptr = skb_network_header(skb) + opt->srr;
 	struct rtable *rt = skb_rtable(skb);
 	struct rtable *rt2;
+	unsigned long orefdst;
 	int err;
 
 	if (!opt->srr)
@@ -624,16 +625,16 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		}
 		memcpy(&nexthop, &optptr[srrptr-1], 4);
 
-		rt = skb_rtable(skb);
+		orefdst = skb->_skb_refdst;
 		skb_dst_set(skb, NULL);
 		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev);
 		rt2 = skb_rtable(skb);
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
-			ip_rt_put(rt2);
-			skb_dst_set(skb, &rt->u.dst);
+			skb_dst_drop(skb);
+			skb->_skb_refdst = orefdst;
 			return -EINVAL;
 		}
-		ip_rt_put(rt);
+		refdst_drop(orefdst);
 		if (rt2->rt_type != RTN_LOCAL)
 			break;
 		/* Superfast 8) loopback forward */
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 82fb43c..07de855 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -17,7 +17,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl = {};
-	struct dst_entry *odst;
+	unsigned long orefdst;
 	unsigned int hh_len;
 	unsigned int type;
 
@@ -51,14 +51,14 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
-		odst = skb_dst(skb);
+		orefdst = skb->_skb_refdst;
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
 				   RT_TOS(iph->tos), rt->u.dst.dev) != 0) {
 			dst_release(&rt->u.dst);
 			return -1;
 		}
 		dst_release(&rt->u.dst);
-		dst_release(odst);
+		refdst_drop(orefdst);
 	}
 
 	if (skb_dst(skb)->error)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dea3f92..705eccf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3033,7 +3033,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 				continue;
 			if (rt_is_expired(rt))
 				continue;
-			skb_dst_set(skb, dst_clone(&rt->u.dst));
+			skb_dst_set_noref(skb, &rt->u.dst);
 			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <= 0) {
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index c49ef21..cb3cde4 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -9,6 +9,7 @@
 #include <linux/rcupdate.h>
 #include <net/protocol.h>
 #include <net/netfilter/nf_queue.h>
+#include <net/dst.h>
 
 #include "nf_internals.h"
 
@@ -170,6 +171,7 @@ static int __nf_queue(struct sk_buff *skb,
 			dev_hold(physoutdev);
 	}
 #endif
+	skb_dst_force(skb);
 	afinfo->saveroute(skb, entry);
 	status = qh->outfn(entry, queuenum);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a969b11..418bc2e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -179,7 +179,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	skb = dequeue_skb(q);
 	if (unlikely(!skb))
 		return 0;
-
+	WARN_ON_ONCE(skb_dst_is_noref(skb));
 	root_lock = qdisc_lock(q);
 	dev = qdisc_dev(q);
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));




