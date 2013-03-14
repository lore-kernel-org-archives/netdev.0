From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Thu, 14 Mar 2013 02:37:02 +0100
Message-ID: <20130314013702.GA4129@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop> <20130313012715.GE14801@order.stressinduktion.org> <1363152568.13690.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34028 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755725Ab3CNBhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 21:37:04 -0400
Content-Disposition: inline
In-Reply-To: <1363152568.13690.35.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 06:29:28AM +0100, Eric Dumazet wrote:
> I would issue a one one time warning in syslog when depth exceeds the
> limit.

I addressed your suggestion to simplify this patch.

I decided against a once message but used net_ratelimit() (as it was
already used by the warning about no memory available). I don't have
a strong opinion on that, just thought it could be a recurring event
which would be worth reporting again because it should only happen on
strange/malicous traffic patterns where admins should act.

I based this patch on the net tree.

Thanks!

[PATCH net] inet: limit length of fragment queue hash table bucket lists

This patch introduces a constant limit of the fragment queue hash
table bucket list lengths. Currently the limit 128 is choosen somewhat
arbitrary and just ensures that we can fill up the fragment cache with
empty packets up to the default ip_frag_high_thresh limits. It should
just protect from list iteration eating considerable amounts of cpu.

If we reach the maximum length in one hash bucket a warning is printed.
This is implemented on the caller side of inet_frag_find to distinguish
between the different users of inet_fragment.c.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_frag.h                 | 30 ++++++++++++++++++++++++++++++
 net/ipv4/inet_fragment.c                |  7 ++++++-
 net/ipv4/ip_fragment.c                  |  9 ++-------
 net/ipv6/netfilter/nf_conntrack_reasm.c | 10 ++++------
 net/ipv6/reassembly.c                   |  6 ++++--
 5 files changed, 46 insertions(+), 16 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 76c3fe5..0350468 100644
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
@@ -77,6 +84,29 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
 
+#define INET_FRAG_FIND_CHECK(val)					\
+	({								\
+		static const char ___mem[] =				\
+			KERN_ERR pr_fmt(				\
+				"inet_frag_find: No memory left."	\
+				" Dropping fragment.\n");		\
+		static const char ___limit[] =				\
+			KERN_WARNING pr_fmt(				\
+				"inet_frag_find: Fragment hash bucket"	\
+				" list length grew above limit "	\
+				__stringify(INETFRAGS_MAXDEPTH)		\
+				". Dropping fragment.\n");		\
+		bool ___b = true;					\
+		if (IS_ERR_OR_NULL(val)) {				\
+			___b = false;					\
+			if (PTR_ERR(val) == -ENOBUFS)			\
+				LIMIT_NETDEBUG(___limit);		\
+			else						\
+				LIMIT_NETDEBUG(___mem);			\
+		}							\
+		___b;							\
+	})
+
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
 	if (atomic_dec_and_test(&q->refcnt))
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 245ae07..0022a3e 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -277,6 +277,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	__releases(&f->lock)
 {
 	struct inet_frag_queue *q;
+	int depth = 0;
 
 	hlist_for_each_entry(q, &f->hash[hash], list) {
 		if (q->net == nf && f->match(q, key)) {
@@ -284,9 +285,13 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
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
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b6d30ac..8533316 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -292,14 +292,9 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
-	if (q == NULL)
-		goto out_nomem;
-
+	if (!INET_FRAG_FIND_CHECK(q))
+		return NULL;
 	return container_of(q, struct ipq, q);
-
-out_nomem:
-	LIMIT_NETDEBUG(KERN_ERR pr_fmt("ip_frag_create: no memory left !\n"));
-	return NULL;
 }
 
 /* Is the fragment too far ahead to be part of ipq? */
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 54087e9..f56468b 100644
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
@@ -180,13 +182,9 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
-	if (q == NULL)
-		goto oom;
-
+	if (!INET_FRAG_FIND_CHECK(q))
+		return NULL;
 	return container_of(q, struct frag_queue, q);
-
-oom:
-	return NULL;
 }
 
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 3c6a772..7dd0841 100644
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
@@ -185,9 +188,8 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
-	if (q == NULL)
+	if (!INET_FRAG_FIND_CHECK(q))
 		return NULL;
-
 	return container_of(q, struct frag_queue, q);
 }
 
-- 
1.8.1.4
