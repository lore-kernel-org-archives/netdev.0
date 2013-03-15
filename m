From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] inet: limit length of fragment queue hash table bucket lists
Date: Fri, 15 Mar 2013 22:32:30 +0100
Message-ID: <20130315213230.GB24041@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38222 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab3COVcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 17:32:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a constant limit of the fragment queue hash
table bucket list lengths. Currently the limit 128 is choosen somewhat
arbitrary and just ensures that we can fill up the fragment cache with
empty packets up to the default ip_frag_high_thresh limits. It should
just protect from list iteration eating considerable amounts of cpu.

If we reach the maximum length in one hash bucket a warning is printed.
This is implemented on the caller side of inet_frag_find to distinguish
between the different users of inet_fragment.c.

I dropped the out of memory warning in the ipv4 fragment lookup path,
because we already get a warning by the slab allocator.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_frag.h                 |  9 +++++++++
 net/ipv4/inet_fragment.c                | 20 +++++++++++++++++++-
 net/ipv4/ip_fragment.c                  | 11 ++++-------
 net/ipv6/netfilter/nf_conntrack_reasm.c | 12 ++++++------
 net/ipv6/reassembly.c                   |  8 ++++++--
 5 files changed, 44 insertions(+), 16 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 76c3fe5..0a1dcc2 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -43,6 +43,13 @@ struct inet_frag_queue {
 
 #define INETFRAGS_HASHSZ		64
 
+/* averaged:
+ * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
+ *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
+ *	       struct frag_queue))
+ */
+#define INETFRAGS_MAXDEPTH		128
+
 struct inet_frags {
 	struct hlist_head	hash[INETFRAGS_HASHSZ];
 	/* This rwlock is a global lock (seperate per IPv4, IPv6 and
@@ -76,6 +83,8 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
+void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
+				   const char *prefix);
 
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 245ae07..f4fd23d 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -21,6 +21,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
 
+#include <net/sock.h>
 #include <net/inet_frag.h>
 
 static void inet_frag_secret_rebuild(unsigned long dummy)
@@ -277,6 +278,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	__releases(&f->lock)
 {
 	struct inet_frag_queue *q;
+	int depth = 0;
 
 	hlist_for_each_entry(q, &f->hash[hash], list) {
 		if (q->net == nf && f->match(q, key)) {
@@ -284,9 +286,25 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 			read_unlock(&f->lock);
 			return q;
 		}
+		depth++;
 	}
 	read_unlock(&f->lock);
 
-	return inet_frag_create(nf, f, key);
+	if (depth <= INETFRAGS_MAXDEPTH)
+		return inet_frag_create(nf, f, key);
+	else
+		return ERR_PTR(-ENOBUFS);
 }
 EXPORT_SYMBOL(inet_frag_find);
+
+void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
+				   const char *prefix)
+{
+	static const char msg[] = "inet_frag_find: Fragment hash bucket"
+		" list length grew over limit " __stringify(INETFRAGS_MAXDEPTH)
+		". Dropping fragment.\n";
+
+	if (PTR_ERR(q) == -ENOBUFS)
+		LIMIT_NETDEBUG(KERN_WARNING "%s%s", prefix, msg);
+}
+EXPORT_SYMBOL(inet_frag_maybe_warn_overflow);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b6d30ac..a6445b8 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -292,14 +292,11 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
-	if (q == NULL)
-		goto out_nomem;
-
+	if (IS_ERR_OR_NULL(q)) {
+		inet_frag_maybe_warn_overflow(q, pr_fmt());
+		return NULL;
+	}
 	return container_of(q, struct ipq, q);
-
-out_nomem:
-	LIMIT_NETDEBUG(KERN_ERR pr_fmt("ip_frag_create: no memory left !\n"));
-	return NULL;
 }
 
 /* Is the fragment too far ahead to be part of ipq? */
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 54087e9..6700069 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -14,6 +14,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) "IPv6-nf: " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -180,13 +182,11 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
-	if (q == NULL)
-		goto oom;
-
+	if (IS_ERR_OR_NULL(q)) {
+		inet_frag_maybe_warn_overflow(q, pr_fmt());
+		return NULL;
+	}
 	return container_of(q, struct frag_queue, q);
-
-oom:
-	return NULL;
 }
 
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 3c6a772..196ab93 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -26,6 +26,9 @@
  *	YOSHIFUJI,H. @USAGI	Always remove fragment header to
  *				calculate ICV correctly.
  */
+
+#define pr_fmt(fmt) "IPv6: " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -185,9 +188,10 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
-	if (q == NULL)
+	if (IS_ERR_OR_NULL(q)) {
+		inet_frag_maybe_warn_overflow(q, pr_fmt());
 		return NULL;
-
+	}
 	return container_of(q, struct frag_queue, q);
 }
 
-- 
1.8.1.4
