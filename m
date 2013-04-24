From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/4] Revert "inet: limit length of fragment queue
	hash table bucket lists"
Date: Wed, 24 Apr 2013 17:48:17 +0200
Message-ID: <20130424154800.16883.4797.stgit@dragon>
References: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641Ab3DXPsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 11:48:21 -0400
In-Reply-To: <20130424154624.16883.40974.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 5a3da1fe9561828d0ca7eca664b16ec2b9bf0055.

The problem with commit 5a3da1fe (inet: limit length of fragment queue
hash table bucket lists) is that, once we hit the hash depth limit (of
128), the we *keep* the existing frag queues, not allowing new frag
queues to be created.  Thus, an attacker can effectivly block handling
of fragments for 30 sec (as each frag queue have a timeout of 30 sec)

For this situation to occur the mem limit need to increase (from
default 4MB per netns). This can either happen by 1) creating more
netns (network namespaces) or 2) by manually increasing the mem limits
via proc files:

 /proc/sys/net/ipv4/ipfrag_high_thresh
 /proc/sys/net/ipv4/ipfrag_low_thresh

To be exact, situation occurs when, increasing the thresh to something
allowing 128 elements in each bucket, which is not that high given the
hash array size of 64 (64*128=8192), e.g.
   big MTU frags (2944(truesize)+208(ipq))*8192(max elems)=25755648
   small frags   ( 896(truesize)+208(ipq))*8192(max elems)=9043968

Thus, with small frags we only need to start >=3 netns instances, for
the situation to be possible.

The reason this is inevitable, is the attackers invalid fragments will
never finish (timeout 30 sec), while valid fragments will complete and
"exit" the queue, thus the end result is hash bucket is filled with
attackers invalid/incomplete fragments.

Fixed conflicts in:
    include/net/inet_frag.h

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h                 |    9 ---------
 net/ipv4/inet_fragment.c                |   20 +-------------------
 net/ipv4/ip_fragment.c                  |   11 +++++++----
 net/ipv6/netfilter/nf_conntrack_reasm.c |   12 ++++++------
 net/ipv6/reassembly.c                   |    8 ++------
 5 files changed, 16 insertions(+), 44 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 6f41b45..eb1d6ee 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -43,13 +43,6 @@ struct inet_frag_queue {
 
 #define INETFRAGS_HASHSZ		64
 
-/* averaged:
- * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
- *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
- *	       struct frag_queue))
- */
-#define INETFRAGS_MAXDEPTH		128
-
 struct inet_frag_bucket {
 	struct hlist_head	chain;
 	spinlock_t		chain_lock;
@@ -89,8 +82,6 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
-void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
-				   const char *prefix);
 
 static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f)
 {
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e97d66a..cabe3d7 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -21,7 +21,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
 
-#include <net/sock.h>
 #include <net/inet_frag.h>
 #include <net/inet_ecn.h>
 
@@ -327,7 +326,6 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 {
 	struct inet_frag_bucket *hb;
 	struct inet_frag_queue *q;
-	int depth = 0;
 
 	hb = &f->hash[hash];
 
@@ -339,26 +337,10 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 			read_unlock(&f->lock);
 			return q;
 		}
-		depth++;
 	}
 	spin_unlock(&hb->chain_lock);
 	read_unlock(&f->lock);
 
-	if (depth <= INETFRAGS_MAXDEPTH)
-		return inet_frag_create(nf, f, key);
-	else
-		return ERR_PTR(-ENOBUFS);
+	return inet_frag_create(nf, f, key);
 }
 EXPORT_SYMBOL(inet_frag_find);
-
-void inet_frag_maybe_warn_overflow(struct inet_frag_queue *q,
-				   const char *prefix)
-{
-	static const char msg[] = "inet_frag_find: Fragment hash bucket"
-		" list length grew over limit " __stringify(INETFRAGS_MAXDEPTH)
-		". Dropping fragment.\n";
-
-	if (PTR_ERR(q) == -ENOBUFS)
-		LIMIT_NETDEBUG(KERN_WARNING "%s%s", prefix, msg);
-}
-EXPORT_SYMBOL(inet_frag_maybe_warn_overflow);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9385206..cda5514 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -263,11 +263,14 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
-	if (IS_ERR_OR_NULL(q)) {
-		inet_frag_maybe_warn_overflow(q, pr_fmt());
-		return NULL;
-	}
+	if (q == NULL)
+		goto out_nomem;
+
 	return container_of(q, struct ipq, q);
+
+out_nomem:
+	LIMIT_NETDEBUG(KERN_ERR pr_fmt("ip_frag_create: no memory left !\n"));
+	return NULL;
 }
 
 /* Is the fragment too far ahead to be part of ipq? */
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index dffdc1a..7cfa829 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -14,8 +14,6 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#define pr_fmt(fmt) "IPv6-nf: " fmt
-
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -189,11 +187,13 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
-	if (IS_ERR_OR_NULL(q)) {
-		inet_frag_maybe_warn_overflow(q, pr_fmt());
-		return NULL;
-	}
+	if (q == NULL)
+		goto oom;
+
 	return container_of(q, struct frag_queue, q);
+
+oom:
+	return NULL;
 }
 
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e6e44ce..74505c5 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -26,9 +26,6 @@
  *	YOSHIFUJI,H. @USAGI	Always remove fragment header to
  *				calculate ICV correctly.
  */
-
-#define pr_fmt(fmt) "IPv6: " fmt
-
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/string.h>
@@ -196,10 +193,9 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src,
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
-	if (IS_ERR_OR_NULL(q)) {
-		inet_frag_maybe_warn_overflow(q, pr_fmt());
+	if (q == NULL)
 		return NULL;
-	}
+
 	return container_of(q, struct frag_queue, q);
 }
 
