From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 1/9] inet: frag: constify match, hashfn and constructor arguments
Date: Thu, 24 Jul 2014 16:50:29 +0200
Message-ID: <1406213437-6155-2-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932975AbaGXOv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:51:59 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/inet_frag.h                 | 11 ++++++-----
 include/net/ipv6.h                      |  4 ++--
 net/ieee802154/reassembly.c             | 14 +++++++-------
 net/ipv4/ip_fragment.c                  | 14 +++++++-------
 net/ipv6/netfilter/nf_conntrack_reasm.c |  2 +-
 net/ipv6/reassembly.c                   | 14 +++++++-------
 6 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 6f59de98dabd..15033057d44e 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -71,10 +71,11 @@ struct inet_frags {
 	u32			rnd;
 	int			qsize;
 
-	unsigned int		(*hashfn)(struct inet_frag_queue *);
-	bool			(*match)(struct inet_frag_queue *q, void *arg);
+	unsigned int		(*hashfn)(const struct inet_frag_queue *);
+	bool			(*match)(const struct inet_frag_queue *q,
+					 const void *arg);
 	void			(*constructor)(struct inet_frag_queue *q,
-						void *arg);
+					       const void *arg);
 	void			(*destructor)(struct inet_frag_queue *);
 	void			(*skb_free)(struct sk_buff *);
 	void			(*frag_expire)(unsigned long data);
@@ -131,9 +132,9 @@ static inline void init_frag_mem_limit(struct netns_frags *nf)
 	percpu_counter_init(&nf->mem, 0);
 }
 
-static inline int sum_frag_mem_limit(struct netns_frags *nf)
+static inline unsigned int sum_frag_mem_limit(struct netns_frags *nf)
 {
-	int res;
+	unsigned int res;
 
 	local_bh_disable();
 	res = percpu_counter_sum_positive(&nf->mem);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a25017247457..25c2170e1298 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -496,8 +496,8 @@ struct ip6_create_arg {
 	u8 ecn;
 };
 
-void ip6_frag_init(struct inet_frag_queue *q, void *a);
-bool ip6_frag_match(struct inet_frag_queue *q, void *a);
+void ip6_frag_init(struct inet_frag_queue *q, const void *a);
+bool ip6_frag_match(const struct inet_frag_queue *q, const void *a);
 
 /*
  *	Equivalent of ipv4 struct ip
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index b85bd3f7048e..a5588be18024 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -61,18 +61,18 @@ static unsigned int lowpan_hash_frag(__be16 tag, u16 d_size,
 	return c & (INETFRAGS_HASHSZ - 1);
 }
 
-static unsigned int lowpan_hashfn(struct inet_frag_queue *q)
+static unsigned int lowpan_hashfn(const struct inet_frag_queue *q)
 {
-	struct lowpan_frag_queue *fq;
+	const struct lowpan_frag_queue *fq;
 
 	fq = container_of(q, struct lowpan_frag_queue, q);
 	return lowpan_hash_frag(fq->tag, fq->d_size, &fq->saddr, &fq->daddr);
 }
 
-static bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
+static bool lowpan_frag_match(const struct inet_frag_queue *q, const void *a)
 {
-	struct lowpan_frag_queue *fq;
-	struct lowpan_create_arg *arg = a;
+	const struct lowpan_frag_queue *fq;
+	const struct lowpan_create_arg *arg = a;
 
 	fq = container_of(q, struct lowpan_frag_queue, q);
 	return	fq->tag == arg->tag && fq->d_size == arg->d_size &&
@@ -80,10 +80,10 @@ static bool lowpan_frag_match(struct inet_frag_queue *q, void *a)
 		ieee802154_addr_equal(&fq->daddr, arg->dst);
 }
 
-static void lowpan_frag_init(struct inet_frag_queue *q, void *a)
+static void lowpan_frag_init(struct inet_frag_queue *q, const void *a)
 {
+	const struct lowpan_create_arg *arg = a;
 	struct lowpan_frag_queue *fq;
-	struct lowpan_create_arg *arg = a;
 
 	fq = container_of(q, struct lowpan_frag_queue, q);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index ed32313e307c..586e6aaf9e6e 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -112,18 +112,18 @@ static unsigned int ipqhashfn(__be16 id, __be32 saddr, __be32 daddr, u8 prot)
 			    ip4_frags.rnd) & (INETFRAGS_HASHSZ - 1);
 }
 
-static unsigned int ip4_hashfn(struct inet_frag_queue *q)
+static unsigned int ip4_hashfn(const struct inet_frag_queue *q)
 {
-	struct ipq *ipq;
+	const struct ipq *ipq;
 
 	ipq = container_of(q, struct ipq, q);
 	return ipqhashfn(ipq->id, ipq->saddr, ipq->daddr, ipq->protocol);
 }
 
-static bool ip4_frag_match(struct inet_frag_queue *q, void *a)
+static bool ip4_frag_match(const struct inet_frag_queue *q, const void *a)
 {
-	struct ipq *qp;
-	struct ip4_create_arg *arg = a;
+	const struct ipq *qp;
+	const struct ip4_create_arg *arg = a;
 
 	qp = container_of(q, struct ipq, q);
 	return	qp->id == arg->iph->id &&
@@ -133,14 +133,14 @@ static bool ip4_frag_match(struct inet_frag_queue *q, void *a)
 		qp->user == arg->user;
 }
 
-static void ip4_frag_init(struct inet_frag_queue *q, void *a)
+static void ip4_frag_init(struct inet_frag_queue *q, const void *a)
 {
 	struct ipq *qp = container_of(q, struct ipq, q);
 	struct netns_ipv4 *ipv4 = container_of(q->net, struct netns_ipv4,
 					       frags);
 	struct net *net = container_of(ipv4, struct net, ipv4);
 
-	struct ip4_create_arg *arg = a;
+	const struct ip4_create_arg *arg = a;
 
 	qp->protocol = arg->iph->protocol;
 	qp->id = arg->iph->id;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 0d5279fd852a..c2c3f2116bc5 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -156,7 +156,7 @@ static unsigned int nf_hash_frag(__be32 id, const struct in6_addr *saddr,
 }
 
 
-static unsigned int nf_hashfn(struct inet_frag_queue *q)
+static unsigned int nf_hashfn(const struct inet_frag_queue *q)
 {
 	const struct frag_queue *nq;
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index cc85a9ba5010..0c6932cc08cb 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -94,18 +94,18 @@ static unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
 	return c & (INETFRAGS_HASHSZ - 1);
 }
 
-static unsigned int ip6_hashfn(struct inet_frag_queue *q)
+static unsigned int ip6_hashfn(const struct inet_frag_queue *q)
 {
-	struct frag_queue *fq;
+	const struct frag_queue *fq;
 
 	fq = container_of(q, struct frag_queue, q);
 	return inet6_hash_frag(fq->id, &fq->saddr, &fq->daddr);
 }
 
-bool ip6_frag_match(struct inet_frag_queue *q, void *a)
+bool ip6_frag_match(const struct inet_frag_queue *q, const void *a)
 {
-	struct frag_queue *fq;
-	struct ip6_create_arg *arg = a;
+	const struct frag_queue *fq;
+	const struct ip6_create_arg *arg = a;
 
 	fq = container_of(q, struct frag_queue, q);
 	return	fq->id == arg->id &&
@@ -115,10 +115,10 @@ bool ip6_frag_match(struct inet_frag_queue *q, void *a)
 }
 EXPORT_SYMBOL(ip6_frag_match);
 
-void ip6_frag_init(struct inet_frag_queue *q, void *a)
+void ip6_frag_init(struct inet_frag_queue *q, const void *a)
 {
 	struct frag_queue *fq = container_of(q, struct frag_queue, q);
-	struct ip6_create_arg *arg = a;
+	const struct ip6_create_arg *arg = a;
 
 	fq->id = arg->id;
 	fq->user = arg->user;
-- 
1.9.3
