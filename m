From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH 1/2] dst: take into account policy update on check()
Date: Fri,  7 Sep 2012 17:57:46 +0200
Message-ID: <1347033467-3757-2-git-send-email-nicolas.dichtel@6wind.com>
References: <5049FAE3.2050403@6wind.com>
 <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: vyasevich@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34143 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266Ab2IGN4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 09:56:01 -0400
In-Reply-To: <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a xfrm policy is inserted or deleted, we must invalidate
all dst and recalculate the route.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/dst.h     | 7 +++++++
 net/core/dst.c        | 1 +
 net/core/sock.c       | 4 ++--
 net/ipv6/ip6_tunnel.c | 3 +--
 4 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 9a78810..478e55a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -101,6 +101,9 @@ struct dst_entry {
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	unsigned long		lastuse;
+#ifdef CONFIG_XFRM
+	u32			flow_cache_genid;
+#endif
 	union {
 		struct dst_entry	*next;
 		struct rtable __rcu	*rt_next;
@@ -457,6 +460,10 @@ static inline int dst_input(struct sk_buff *skb)
 
 static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 {
+#ifdef CONFIG_XFRM
+	if (dst->flow_cache_genid != atomic_read(&flow_cache_genid))
+		return NULL;
+#endif
 	if (dst->obsolete)
 		dst = dst->ops->check(dst, cookie);
 	return dst;
diff --git a/net/core/dst.c b/net/core/dst.c
index f6593d2..19899d3 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -181,6 +181,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->path = dst;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
+	dst->flow_cache_genid = atomic_read(&flow_cache_genid);
 #endif
 	dst->input = dst_discard;
 	dst->output = dst_discard;
diff --git a/net/core/sock.c b/net/core/sock.c
index d765156..1d06d4e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -491,7 +491,7 @@ struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
 
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+	if (dst && dst_check(dst, cookie) == NULL) {
 		sk_tx_queue_clear(sk);
 		RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
 		dst_release(dst);
@@ -506,7 +506,7 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = sk_dst_get(sk);
 
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+	if (dst && dst_check(dst, cookie) == NULL) {
 		sk_dst_reset(sk);
 		dst_release(dst);
 		return NULL;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index cb7e2de..e96431a 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -130,8 +130,7 @@ struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 {
 	struct dst_entry *dst = t->dst_cache;
 
-	if (dst && dst->obsolete &&
-	    dst->ops->check(dst, t->dst_cookie) == NULL) {
+	if (dst && dst_check(dst, t->dst_cookie) == NULL) {
 		t->dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
-- 
1.7.12
