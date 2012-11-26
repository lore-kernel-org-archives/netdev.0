From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v2] net: clean up locking in inet_frag_find()
Date: Mon, 26 Nov 2012 15:26:26 +0800
Message-ID: <1353914786-10426-1-git-send-email-amwang@redhat.com>
References: <1353909184.11282.3.camel@cr0>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940Ab2KZH1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 02:27:32 -0500
In-Reply-To: <1353909184.11282.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is weird to take the read lock outside of inet_frag_find()
but release it inside...  This can be improved by refactoring
the code, that is, introducing inet{4,6}_frag_find() which call
the their own hash function, inet{4,6}_hash_frag(), hiding the
details from their callers.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 include/net/inet_frag.h                 |   17 +++++-
 include/net/ipv6.h                      |    3 -
 net/ipv4/inet_fragment.c                |   82 +++++++++++++++++++++++++++++--
 net/ipv4/ip_fragment.c                  |   16 +-----
 net/ipv6/netfilter/nf_conntrack_reasm.c |    7 +--
 net/ipv6/reassembly.c                   |   34 +------------
 6 files changed, 97 insertions(+), 62 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 32786a0..7314ec5 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -1,6 +1,8 @@
 #ifndef __NET_FRAG_H__
 #define __NET_FRAG_H__
 
+#include <linux/in6.h>
+
 struct netns_frags {
 	int			nqueues;
 	atomic_t		mem;
@@ -62,9 +64,18 @@ void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
 void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
 int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
-struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
-		struct inet_frags *f, void *key, unsigned int hash)
-	__releases(&f->lock);
+
+extern unsigned int inet4_hash_frag(__be16 id, __be32 saddr, __be32 daddr,
+				    u8 prot, u32 rnd);
+struct inet_frag_queue *inet4_frag_find(struct netns_frags *nf,
+		struct inet_frags *f, void *key);
+
+#if IS_ENABLED(CONFIG_IPV6)
+extern unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
+				    const struct in6_addr *daddr, u32 rnd);
+struct inet_frag_queue *inet6_frag_find(struct netns_frags *nf,
+		struct inet_frags *f, void *key);
+#endif
 
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 979bf6c..ba19ebc 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -695,9 +695,6 @@ extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
 extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 			 struct group_filter __user *optval,
 			 int __user *optlen);
-extern unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
-				    const struct in6_addr *daddr, u32 rnd);
-
 #ifdef CONFIG_PROC_FS
 extern int  ac6_proc_init(struct net *net);
 extern void ac6_proc_exit(struct net *net);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 4750d2b..7290238 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -20,7 +20,10 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
+#include <linux/jhash.h>
+#include <linux/ip.h>
 
+#include <net/ipv6.h>
 #include <net/inet_frag.h>
 
 static void inet_frag_secret_rebuild(unsigned long dummy)
@@ -270,9 +273,8 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 	return inet_frag_intern(nf, q, f, arg);
 }
 
-struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
+static struct inet_frag_queue *__inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
-	__releases(&f->lock)
 {
 	struct inet_frag_queue *q;
 	struct hlist_node *n;
@@ -280,12 +282,84 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	hlist_for_each_entry(q, n, &f->hash[hash], list) {
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
-			read_unlock(&f->lock);
 			return q;
 		}
 	}
+
+	return NULL;
+}
+
+unsigned int inet4_hash_frag(__be16 id, __be32 saddr, __be32 daddr, u8 prot, u32 rnd)
+{
+	return jhash_3words((__force u32)id << 16 | prot,
+			    (__force u32)saddr, (__force u32)daddr,
+			    rnd) & (INETFRAGS_HASHSZ - 1);
+}
+EXPORT_SYMBOL_GPL(inet4_hash_frag);
+
+struct inet_frag_queue *inet4_frag_find(struct netns_frags *nf,
+		struct inet_frags *f, void *key)
+{
+	struct inet_frag_queue *q;
+	struct iphdr *iph;
+	unsigned int hash;
+
+	iph = *(struct iphdr **)key;
+
+	read_lock(&f->lock);
+	hash = inet4_hash_frag(iph->id, iph->saddr, iph->daddr, iph->protocol, f->rnd);
+	q = __inet_frag_find(nf, f, key, hash);
 	read_unlock(&f->lock);
+	if (q)
+		return q;
+	return inet_frag_create(nf, f, key);
+}
+EXPORT_SYMBOL(inet4_frag_find);
+
+#if IS_ENABLED(CONFIG_IPV6)
+/*
+ * callers should be careful not to use the hash value outside the ipfrag_lock
+ * as doing so could race with ipfrag_hash_rnd being recalculated.
+ */
+unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
+			     const struct in6_addr *daddr, u32 rnd)
+{
+	u32 c;
+
+	c = jhash_3words((__force u32)saddr->s6_addr32[0],
+			 (__force u32)saddr->s6_addr32[1],
+			 (__force u32)saddr->s6_addr32[2],
+			 rnd);
+
+	c = jhash_3words((__force u32)saddr->s6_addr32[3],
+			 (__force u32)daddr->s6_addr32[0],
+			 (__force u32)daddr->s6_addr32[1],
+			 c);
+
+	c =  jhash_3words((__force u32)daddr->s6_addr32[2],
+			  (__force u32)daddr->s6_addr32[3],
+			  (__force u32)id,
+			  c);
+
+	return c & (INETFRAGS_HASHSZ - 1);
+}
+EXPORT_SYMBOL_GPL(inet6_hash_frag);
 
+
+struct inet_frag_queue *inet6_frag_find(struct netns_frags *nf,
+		struct inet_frags *f, void *key)
+{
+	struct inet_frag_queue *q;
+	struct ip6_create_arg *arg = key;
+	unsigned int hash;
+
+	read_lock(&f->lock);
+	hash = inet6_hash_frag(arg->id, arg->src, arg->dst, f->rnd);
+	q = __inet_frag_find(nf, f, key, hash);
+	read_unlock(&f->lock);
+	if (q)
+		return q;
 	return inet_frag_create(nf, f, key);
 }
-EXPORT_SYMBOL(inet_frag_find);
+EXPORT_SYMBOL(inet6_frag_find);
+#endif
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1cf6a76..0a02037 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -32,7 +32,6 @@
 #include <linux/ip.h>
 #include <linux/icmp.h>
 #include <linux/netdevice.h>
-#include <linux/jhash.h>
 #include <linux/random.h>
 #include <linux/slab.h>
 #include <net/route.h>
@@ -133,19 +132,12 @@ struct ip4_create_arg {
 	u32 user;
 };
 
-static unsigned int ipqhashfn(__be16 id, __be32 saddr, __be32 daddr, u8 prot)
-{
-	return jhash_3words((__force u32)id << 16 | prot,
-			    (__force u32)saddr, (__force u32)daddr,
-			    ip4_frags.rnd) & (INETFRAGS_HASHSZ - 1);
-}
-
 static unsigned int ip4_hashfn(struct inet_frag_queue *q)
 {
 	struct ipq *ipq;
 
 	ipq = container_of(q, struct ipq, q);
-	return ipqhashfn(ipq->id, ipq->saddr, ipq->daddr, ipq->protocol);
+	return inet4_hash_frag(ipq->id, ipq->saddr, ipq->daddr, ipq->protocol, ip4_frags.rnd);
 }
 
 static bool ip4_frag_match(struct inet_frag_queue *q, void *a)
@@ -290,15 +282,11 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 {
 	struct inet_frag_queue *q;
 	struct ip4_create_arg arg;
-	unsigned int hash;
 
 	arg.iph = iph;
 	arg.user = user;
 
-	read_lock(&ip4_frags.lock);
-	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
-
-	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
+	q = inet4_frag_find(&net->ipv4.frags, &ip4_frags, &arg);
 	if (q == NULL)
 		goto out_nomem;
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 22c8ea9..2d51584 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -168,17 +168,14 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
-	unsigned int hash;
 
 	arg.id = id;
 	arg.user = user;
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock_bh(&nf_frags.lock);
-	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
-
-	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
+	local_bh_disable();
+	q = inet6_frag_find(&net->nf_frag.frags, &nf_frags, &arg);
 	local_bh_enable();
 	if (q == NULL)
 		goto oom;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e5253ec..08c5063 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -70,34 +70,6 @@ static struct inet_frags ip6_frags;
 static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 			  struct net_device *dev);
 
-/*
- * callers should be careful not to use the hash value outside the ipfrag_lock
- * as doing so could race with ipfrag_hash_rnd being recalculated.
- */
-unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
-			     const struct in6_addr *daddr, u32 rnd)
-{
-	u32 c;
-
-	c = jhash_3words((__force u32)saddr->s6_addr32[0],
-			 (__force u32)saddr->s6_addr32[1],
-			 (__force u32)saddr->s6_addr32[2],
-			 rnd);
-
-	c = jhash_3words((__force u32)saddr->s6_addr32[3],
-			 (__force u32)daddr->s6_addr32[0],
-			 (__force u32)daddr->s6_addr32[1],
-			 c);
-
-	c =  jhash_3words((__force u32)daddr->s6_addr32[2],
-			  (__force u32)daddr->s6_addr32[3],
-			  (__force u32)id,
-			  c);
-
-	return c & (INETFRAGS_HASHSZ - 1);
-}
-EXPORT_SYMBOL_GPL(inet6_hash_frag);
-
 static unsigned int ip6_hashfn(struct inet_frag_queue *q)
 {
 	struct frag_queue *fq;
@@ -186,17 +158,13 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6
 {
 	struct inet_frag_queue *q;
 	struct ip6_create_arg arg;
-	unsigned int hash;
 
 	arg.id = id;
 	arg.user = IP6_DEFRAG_LOCAL_DELIVER;
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock(&ip6_frags.lock);
-	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
-
-	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
+	q = inet6_frag_find(&net->ipv6.frags, &ip6_frags, &arg);
 	if (q == NULL)
 		return NULL;
 
