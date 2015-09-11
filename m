From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net 5/5] ipv6: Replace spinlock with seqlock and rcu in ip6_tunnel
Date: Fri, 11 Sep 2015 11:06:21 -0700
Message-ID: <1441994781-2718585-6-git-send-email-kafai@fb.com>
References: <1441994781-2718585-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:22528 "EHLO
	m0041696.ppops.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751540AbbIKSHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 14:07:34 -0400
Received: from pps.filterd (m0041696 [127.0.0.1])
	by m0041696.ppops.net (8.14.5/8.14.5) with SMTP id t8BI7OtD032497
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 11:07:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0041696.ppops.net with ESMTP id 1wv08dgqbr-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 11:07:32 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 f0d9db9258af11e5b3290002c9521c9e-9b7f7240 for <netdev@vger.kernel.org>;	Fri,
 11 Sep 2015 11:07:19 -0700
In-Reply-To: <1441994781-2718585-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses a seqlock to ensure consistency between idst->dst and
idst->cookie.  It also makes dst freeing from fib tree to undergo a
rcu grace period.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/ip6_tunnel.h |  4 ++--
 net/ipv6/ip6_fib.c       |  9 +++++++--
 net/ipv6/ip6_tunnel.c    | 51 +++++++++++++++++++++++++-----------------------
 3 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 60b4f40..65c2a93 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -33,8 +33,8 @@ struct __ip6_tnl_parm {
 };
 
 struct ip6_tnl_dst {
-	spinlock_t lock;
-	struct dst_entry *dst;
+	seqlock_t lock;
+	struct dst_entry __rcu *dst;
 	u32 cookie;
 };
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e68350b..8a9ec01 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -155,6 +155,11 @@ static void node_free(struct fib6_node *fn)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
+static void rt6_rcu_free(struct rt6_info *rt)
+{
+	call_rcu(&rt->dst.rcu_head, dst_rcu_free);
+}
+
 static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 {
 	int cpu;
@@ -169,7 +174,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 		ppcpu_rt = per_cpu_ptr(non_pcpu_rt->rt6i_pcpu, cpu);
 		pcpu_rt = *ppcpu_rt;
 		if (pcpu_rt) {
-			dst_free(&pcpu_rt->dst);
+			rt6_rcu_free(pcpu_rt);
 			*ppcpu_rt = NULL;
 		}
 	}
@@ -181,7 +186,7 @@ static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref)) {
 		rt6_free_pcpu(rt);
-		dst_free(&rt->dst);
+		rt6_rcu_free(rt);
 	}
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 851cf6d..d27312a 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -126,45 +126,48 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
  * Locking : hash tables are protected by RCU and RTNL
  */
 
-static void __ip6_tnl_per_cpu_dst_set(struct ip6_tnl_dst *idst,
-				      struct dst_entry *dst)
+static void ip6_tnl_per_cpu_dst_set(struct ip6_tnl_dst *idst,
+				    struct dst_entry *dst)
 {
-	dst_release(idst->dst);
+	write_seqlock_bh(&idst->lock);
+	dst_release(rcu_dereference_protected(
+			    idst->dst,
+			    lockdep_is_held(&idst->lock->lock)));
 	if (dst) {
 		dst_hold(dst);
 		idst->cookie = rt6_get_cookie((struct rt6_info *)dst);
 	} else {
 		idst->cookie = 0;
 	}
-	idst->dst = dst;
-}
-
-static void ip6_tnl_per_cpu_dst_set(struct ip6_tnl_dst *idst,
-				    struct dst_entry *dst)
-{
-
-	spin_lock_bh(&idst->lock);
-	__ip6_tnl_per_cpu_dst_set(idst, dst);
-	spin_unlock_bh(&idst->lock);
+	rcu_assign_pointer(idst->dst, dst);
+	write_sequnlock_bh(&idst->lock);
 }
 
 struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t)
 {
 	struct ip6_tnl_dst *idst;
 	struct dst_entry *dst;
+	unsigned int seq;
+	u32 cookie;
 
 	idst = raw_cpu_ptr(t->dst_cache);
-	spin_lock_bh(&idst->lock);
-	dst = idst->dst;
-	if (dst) {
-		if (!dst->obsolete || dst->ops->check(dst, idst->cookie)) {
-			dst_hold(idst->dst);
-		} else {
-			__ip6_tnl_per_cpu_dst_set(idst, NULL);
-			dst = NULL;
-		}
+
+	rcu_read_lock();
+	do {
+		seq = read_seqbegin(&idst->lock);
+		dst = rcu_dereference(idst->dst);
+		cookie = idst->cookie;
+	} while (read_seqretry(&idst->lock, seq));
+
+	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
+		dst = NULL;
+	rcu_read_unlock();
+
+	if (dst && dst->obsolete && !dst->ops->check(dst, cookie)) {
+		ip6_tnl_per_cpu_dst_set(idst, NULL);
+		dst_release(dst);
+		dst = NULL;
 	}
-	spin_unlock_bh(&idst->lock);
 	return dst;
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_dst_get);
@@ -204,7 +207,7 @@ int ip6_tnl_dst_init(struct ip6_tnl *t)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i)
-		spin_lock_init(&per_cpu_ptr(t->dst_cache, i)->lock);
+		seqlock_init(&per_cpu_ptr(t->dst_cache, i)->lock);
 
 	return 0;
 }
-- 
2.5.1
