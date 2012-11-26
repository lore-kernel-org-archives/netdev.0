From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] net: clean up locking in inet_frag_find()
Date: Mon, 26 Nov 2012 13:18:05 +0800
Message-ID: <1353907085-30824-1-git-send-email-amwang@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab2KZFTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 00:19:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is weird to take the read lock outside of inet_frag_find()
but release it inside... Also, the hash function doesn't
need this lock.

Cc: Patrick McHardy <kaber@trash.net>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 4750d2b..caf1807 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -272,11 +272,11 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
-	__releases(&f->lock)
 {
 	struct inet_frag_queue *q;
 	struct hlist_node *n;
 
+	read_lock(&f->lock);
 	hlist_for_each_entry(q, n, &f->hash[hash], list) {
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1cf6a76..d9541f4 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -295,9 +295,7 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	arg.iph = iph;
 	arg.user = user;
 
-	read_lock(&ip4_frags.lock);
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
-
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
 	if (q == NULL)
 		goto out_nomem;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 22c8ea9..b778423 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -175,9 +175,8 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock_bh(&nf_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
-
+	local_bh_disable();
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
 	local_bh_enable();
 	if (q == NULL)
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e5253ec..15e09a6 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -193,9 +193,7 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock(&ip6_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
-
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
 	if (q == NULL)
 		return NULL;
