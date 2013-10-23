From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/3] ipv6: split inet6_hash_frag for netfilter and initialize secrets with net_get_random_once
Date: Wed, 23 Oct 2013 11:06:56 +0200
Message-ID: <1382519217-750-3-git-send-email-hannes@stressinduktion.org>
References: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Cc: netfilter-devel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52245 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab3JWJHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 05:07:15 -0400
In-Reply-To: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defer the fragmentation hash secret initialization for IPv6 like the
previous patch did for IPv4.

Because the netfilter logic reuses the hash secret we have to split it
first. Thus introduce a new nf_hash_frag function which takes care to
seed the hash secret.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h                      |  2 --
 net/ipv6/netfilter/nf_conntrack_reasm.c | 16 ++++++++++++++--
 net/ipv6/reassembly.c                   | 12 ++++++------
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a35055f..dd96638 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -805,8 +805,6 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
 int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 		  struct group_filter __user *optval, int __user *optlen);
-unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
-			     const struct in6_addr *daddr, u32 rnd);
 
 #ifdef CONFIG_PROC_FS
 int ac6_proc_init(struct net *net);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index dffdc1a..4a25826 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -144,12 +144,24 @@ static inline u8 ip6_frag_ecn(const struct ipv6hdr *ipv6h)
 	return 1 << (ipv6_get_dsfield(ipv6h) & INET_ECN_MASK);
 }
 
+static unsigned int nf_hash_frag(__be32 id, const struct in6_addr *saddr,
+				 const struct in6_addr *daddr)
+{
+	u32 c;
+
+	net_get_random_once(&nf_frags.rnd, sizeof(nf_frags.rnd));
+	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
+			 (__force u32)id, nf_frags.rnd);
+	return c & (INETFRAGS_HASHSZ - 1);
+}
+
+
 static unsigned int nf_hashfn(struct inet_frag_queue *q)
 {
 	const struct frag_queue *nq;
 
 	nq = container_of(q, struct frag_queue, q);
-	return inet6_hash_frag(nq->id, &nq->saddr, &nq->daddr, nf_frags.rnd);
+	return nf_hash_frag(nq->id, &nq->saddr, &nq->daddr);
 }
 
 static void nf_skb_free(struct sk_buff *skb)
@@ -185,7 +197,7 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 	arg.ecn = ecn;
 
 	read_lock_bh(&nf_frags.lock);
-	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
+	hash = nf_hash_frag(id, src, dst);
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 1aeb473..cc85a9b 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -82,24 +82,24 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
  * callers should be careful not to use the hash value outside the ipfrag_lock
  * as doing so could race with ipfrag_hash_rnd being recalculated.
  */
-unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
-			     const struct in6_addr *daddr, u32 rnd)
+static unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
+				    const struct in6_addr *daddr)
 {
 	u32 c;
 
+	net_get_random_once(&ip6_frags.rnd, sizeof(ip6_frags.rnd));
 	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
-			 (__force u32)id, rnd);
+			 (__force u32)id, ip6_frags.rnd);
 
 	return c & (INETFRAGS_HASHSZ - 1);
 }
-EXPORT_SYMBOL_GPL(inet6_hash_frag);
 
 static unsigned int ip6_hashfn(struct inet_frag_queue *q)
 {
 	struct frag_queue *fq;
 
 	fq = container_of(q, struct frag_queue, q);
-	return inet6_hash_frag(fq->id, &fq->saddr, &fq->daddr, ip6_frags.rnd);
+	return inet6_hash_frag(fq->id, &fq->saddr, &fq->daddr);
 }
 
 bool ip6_frag_match(struct inet_frag_queue *q, void *a)
@@ -193,7 +193,7 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src,
 	arg.ecn = ecn;
 
 	read_lock(&ip6_frags.lock);
-	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
+	hash = inet6_hash_frag(id, src, dst);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
 	if (IS_ERR_OR_NULL(q)) {
-- 
1.8.3.1
