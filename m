From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 3/7] inetpeer: use generic union inet_addr
Date: Mon, 22 Jul 2013 15:05:09 +0800
Message-ID: <1374476713-8838-4-git-send-email-amwang@redhat.com>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34905 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454Ab3GVHFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 03:05:40 -0400
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

struct inetpeer_addr is pretty similar to generic union inet_addr,
therefore can be safely converted to it.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/inetpeer.h |   29 +++++----------
 net/ipv4/inetpeer.c    |   37 ++++++++++++-------
 net/ipv4/tcp_metrics.c |   92 ++++++++++++++++++++----------------------------
 3 files changed, 70 insertions(+), 88 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 53f464d..7ec33fb 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -13,24 +13,13 @@
 #include <linux/spinlock.h>
 #include <linux/rtnetlink.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 #include <linux/atomic.h>
 
-struct inetpeer_addr_base {
-	union {
-		__be32			a4;
-		__be32			a6[4];
-	};
-};
-
-struct inetpeer_addr {
-	struct inetpeer_addr_base	addr;
-	__u16				family;
-};
-
 struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer __rcu	*avl_left, *avl_right;
-	struct inetpeer_addr	daddr;
+	union inet_addr		daddr;
 	__u32			avl_height;
 
 	u32			metrics[RTAX_MAX];
@@ -133,17 +122,17 @@ static inline bool inet_metrics_new(const struct inet_peer *p)
 
 /* can be called with or without local BH being disabled */
 struct inet_peer *inet_getpeer(struct inet_peer_base *base,
-			       const struct inetpeer_addr *daddr,
+			       const union inet_addr *daddr,
 			       int create);
 
 static inline struct inet_peer *inet_getpeer_v4(struct inet_peer_base *base,
 						__be32 v4daddr,
 						int create)
 {
-	struct inetpeer_addr daddr;
+	union inet_addr daddr;
 
-	daddr.addr.a4 = v4daddr;
-	daddr.family = AF_INET;
+	daddr.sin.sin_addr.s_addr = v4daddr;
+	daddr.sa.sa_family = AF_INET;
 	return inet_getpeer(base, &daddr, create);
 }
 
@@ -151,10 +140,10 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 						const struct in6_addr *v6daddr,
 						int create)
 {
-	struct inetpeer_addr daddr;
+	union inet_addr daddr;
 
-	*(struct in6_addr *)daddr.addr.a6 = *v6daddr;
-	daddr.family = AF_INET6;
+	daddr.sin6.sin6_addr = *v6daddr;
+	daddr.sa.sa_family = AF_INET6;
 	return inet_getpeer(base, &daddr, create);
 }
 
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 000e3d2..143516a 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -197,17 +197,26 @@ void __init inet_initpeers(void)
 	INIT_DEFERRABLE_WORK(&gc_work, inetpeer_gc_worker);
 }
 
-static int addr_compare(const struct inetpeer_addr *a,
-			const struct inetpeer_addr *b)
+static int addr_compare(const union inet_addr *a,
+			const union inet_addr *b)
 {
-	int i, n = (a->family == AF_INET ? 1 : 4);
+	int i;
 
-	for (i = 0; i < n; i++) {
-		if (a->addr.a6[i] == b->addr.a6[i])
-			continue;
-		if ((__force u32)a->addr.a6[i] < (__force u32)b->addr.a6[i])
+	if (a->sa.sa_family == AF_INET) {
+		if (a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr)
+			return 0;
+		if ((__force u32)a->sin.sin_addr.s_addr <
+		    (__force u32)b->sin.sin_addr.s_addr)
 			return -1;
-		return 1;
+	} else {
+		for (i = 0; i < 4; i++) {
+			if (a->sin6.sin6_addr.s6_addr32[i] == b->sin6.sin6_addr.s6_addr32[i])
+				continue;
+			if ((__force u32)a->sin6.sin6_addr.s6_addr32[i] <
+			    (__force u32)b->sin6.sin6_addr.s6_addr32[i])
+				return -1;
+			return 1;
+		}
 	}
 
 	return 0;
@@ -248,7 +257,7 @@ static int addr_compare(const struct inetpeer_addr *a,
  * But every pointer we follow is guaranteed to be valid thanks to RCU.
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
-static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
+static struct inet_peer *lookup_rcu(const union inet_addr *daddr,
 				    struct inet_peer_base *base)
 {
 	struct inet_peer *u = rcu_dereference(base->root);
@@ -457,7 +466,7 @@ static int inet_peer_gc(struct inet_peer_base *base,
 }
 
 struct inet_peer *inet_getpeer(struct inet_peer_base *base,
-			       const struct inetpeer_addr *daddr,
+			       const union inet_addr *daddr,
 			       int create)
 {
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
@@ -465,7 +474,7 @@ struct inet_peer *inet_getpeer(struct inet_peer_base *base,
 	unsigned int sequence;
 	int invalidated, gccnt = 0;
 
-	flush_check(base, daddr->family);
+	flush_check(base, daddr->sa.sa_family);
 
 	/* Attempt a lockless lookup first.
 	 * Because of a concurrent writer, we might not find an existing entry.
@@ -505,9 +514,9 @@ relookup:
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
 		atomic_set(&p->ip_id_count,
-				(daddr->family == AF_INET) ?
-					secure_ip_id(daddr->addr.a4) :
-					secure_ipv6_id(daddr->addr.a6));
+				(daddr->sa.sa_family == AF_INET) ?
+					secure_ip_id(daddr->sin.sin_addr.s_addr) :
+					secure_ipv6_id(daddr->sin6.sin6_addr.s6_addr32));
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		/* 60*HZ is arbitrary, but chosen enough high so that the first
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f6a005c..10b3796 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -31,7 +31,7 @@ struct tcp_fastopen_metrics {
 
 struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
-	struct inetpeer_addr		tcpm_addr;
+	union inet_addr			tcpm_addr;
 	unsigned long			tcpm_stamp;
 	u32				tcpm_ts;
 	u32				tcpm_ts_stamp;
@@ -74,22 +74,6 @@ static void tcp_metric_set_msecs(struct tcp_metrics_block *tm,
 	tm->tcpm_vals[idx] = jiffies_to_msecs(val);
 }
 
-static bool addr_same(const struct inetpeer_addr *a,
-		      const struct inetpeer_addr *b)
-{
-	const struct in6_addr *a6, *b6;
-
-	if (a->family != b->family)
-		return false;
-	if (a->family == AF_INET)
-		return a->addr.a4 == b->addr.a4;
-
-	a6 = (const struct in6_addr *) &a->addr.a6[0];
-	b6 = (const struct in6_addr *) &b->addr.a6[0];
-
-	return ipv6_addr_equal(a6, b6);
-}
-
 struct tcpm_hash_bucket {
 	struct tcp_metrics_block __rcu	*chain;
 };
@@ -131,7 +115,7 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
 }
 
 static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
-					  struct inetpeer_addr *addr,
+					  union inet_addr *addr,
 					  unsigned int hash,
 					  bool reclaim)
 {
@@ -189,7 +173,7 @@ static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm, in
 	return NULL;
 }
 
-static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *addr,
+static struct tcp_metrics_block *__tcp_get_metrics(const union inet_addr *addr,
 						   struct net *net, unsigned int hash)
 {
 	struct tcp_metrics_block *tm;
@@ -197,7 +181,7 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *a
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, addr))
+		if (inet_addr_equal(&tm->tcpm_addr, addr))
 			break;
 		depth++;
 	}
@@ -208,18 +192,18 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 						       struct dst_entry *dst)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	union inet_addr addr;
 	unsigned int hash;
 	struct net *net;
 
-	addr.family = req->rsk_ops->family;
-	switch (addr.family) {
+	addr.sa.sa_family = req->rsk_ops->family;
+	switch (addr.sa.sa_family) {
 	case AF_INET:
-		addr.addr.a4 = inet_rsk(req)->rmt_addr;
-		hash = (__force unsigned int) addr.addr.a4;
+		addr.sin.sin_addr.s_addr = inet_rsk(req)->rmt_addr;
+		hash = (__force unsigned int) addr.sin.sin_addr.s_addr;
 		break;
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet6_rsk(req)->rmt_addr;
+		addr.sin6.sin6_addr = inet6_rsk(req)->rmt_addr;
 		hash = ipv6_addr_hash(&inet6_rsk(req)->rmt_addr);
 		break;
 	default:
@@ -231,7 +215,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr))
+		if (inet_addr_equal(&tm->tcpm_addr, &addr))
 			break;
 	}
 	tcpm_check_stamp(tm, dst);
@@ -242,19 +226,19 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 {
 	struct inet6_timewait_sock *tw6;
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	union inet_addr addr;
 	unsigned int hash;
 	struct net *net;
 
-	addr.family = tw->tw_family;
-	switch (addr.family) {
+	addr.sa.sa_family = tw->tw_family;
+	switch (addr.sa.sa_family) {
 	case AF_INET:
-		addr.addr.a4 = tw->tw_daddr;
-		hash = (__force unsigned int) addr.addr.a4;
+		addr.sin.sin_addr.s_addr = tw->tw_daddr;
+		hash = (__force unsigned int) addr.sin.sin_addr.s_addr;
 		break;
 	case AF_INET6:
 		tw6 = inet6_twsk((struct sock *)tw);
-		*(struct in6_addr *)addr.addr.a6 = tw6->tw_v6_daddr;
+		addr.sin6.sin6_addr = tw6->tw_v6_daddr;
 		hash = ipv6_addr_hash(&tw6->tw_v6_daddr);
 		break;
 	default:
@@ -266,7 +250,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr))
+		if (inet_addr_equal(&tm->tcpm_addr, &addr))
 			break;
 	}
 	return tm;
@@ -277,19 +261,19 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 						 bool create)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	union inet_addr addr;
 	unsigned int hash;
 	struct net *net;
 	bool reclaim;
 
-	addr.family = sk->sk_family;
-	switch (addr.family) {
+	addr.sa.sa_family = sk->sk_family;
+	switch (addr.sa.sa_family) {
 	case AF_INET:
-		addr.addr.a4 = inet_sk(sk)->inet_daddr;
-		hash = (__force unsigned int) addr.addr.a4;
+		addr.sin.sin_addr.s_addr = inet_sk(sk)->inet_daddr;
+		hash = (__force unsigned int) addr.sin.sin_addr.s_addr;
 		break;
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet6_sk(sk)->daddr;
+		addr.sin6.sin6_addr = inet6_sk(sk)->daddr;
 		hash = ipv6_addr_hash(&inet6_sk(sk)->daddr);
 		break;
 	default:
@@ -722,15 +706,15 @@ static int tcp_metrics_fill_info(struct sk_buff *msg,
 	struct nlattr *nest;
 	int i;
 
-	switch (tm->tcpm_addr.family) {
+	switch (tm->tcpm_addr.sa.sa_family) {
 	case AF_INET:
 		if (nla_put_be32(msg, TCP_METRICS_ATTR_ADDR_IPV4,
-				tm->tcpm_addr.addr.a4) < 0)
+				tm->tcpm_addr.sin.sin_addr.s_addr) < 0)
 			goto nla_put_failure;
 		break;
 	case AF_INET6:
 		if (nla_put(msg, TCP_METRICS_ATTR_ADDR_IPV6, 16,
-			    tm->tcpm_addr.addr.a6) < 0)
+			    tm->tcpm_addr.sin6.sin6_addr.s6_addr32) < 0)
 			goto nla_put_failure;
 		break;
 	default:
@@ -853,25 +837,25 @@ done:
 	return skb->len;
 }
 
-static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
+static int parse_nl_addr(struct genl_info *info, union inet_addr *addr,
 			 unsigned int *hash, int optional)
 {
 	struct nlattr *a;
 
 	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV4];
 	if (a) {
-		addr->family = AF_INET;
-		addr->addr.a4 = nla_get_be32(a);
-		*hash = (__force unsigned int) addr->addr.a4;
+		addr->sa.sa_family = AF_INET;
+		addr->sin.sin_addr.s_addr = nla_get_be32(a);
+		*hash = (__force unsigned int) addr->sin.sin_addr.s_addr;
 		return 0;
 	}
 	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV6];
 	if (a) {
 		if (nla_len(a) != sizeof(struct in6_addr))
 			return -EINVAL;
-		addr->family = AF_INET6;
-		memcpy(addr->addr.a6, nla_data(a), sizeof(addr->addr.a6));
-		*hash = ipv6_addr_hash((struct in6_addr *) addr->addr.a6);
+		addr->sa.sa_family = AF_INET6;
+		memcpy(&addr->sin6.sin6_addr, nla_data(a), sizeof(addr->sin6.sin6_addr));
+		*hash = ipv6_addr_hash(&addr->sin6.sin6_addr);
 		return 0;
 	}
 	return optional ? 1 : -EAFNOSUPPORT;
@@ -880,7 +864,7 @@ static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	union inet_addr addr;
 	unsigned int hash;
 	struct sk_buff *msg;
 	struct net *net = genl_info_net(info);
@@ -905,7 +889,7 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	rcu_read_lock();
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr)) {
+		if (inet_addr_equal(&tm->tcpm_addr, &addr)) {
 			ret = tcp_metrics_fill_info(msg, tm);
 			break;
 		}
@@ -960,7 +944,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct tcpm_hash_bucket *hb;
 	struct tcp_metrics_block *tm;
 	struct tcp_metrics_block __rcu **pp;
-	struct inetpeer_addr addr;
+	union inet_addr addr;
 	unsigned int hash;
 	struct net *net = genl_info_net(info);
 	int ret;
@@ -977,7 +961,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	spin_lock_bh(&tcp_metrics_lock);
 	for (tm = deref_locked_genl(*pp); tm;
 	     pp = &tm->tcpm_next, tm = deref_locked_genl(*pp)) {
-		if (addr_same(&tm->tcpm_addr, &addr)) {
+		if (inet_addr_equal(&tm->tcpm_addr, &addr)) {
 			*pp = tm->tcpm_next;
 			break;
 		}
-- 
1.7.7.6
