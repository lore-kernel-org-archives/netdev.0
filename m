From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH (regression)] Fragments: fix race between inet_frag_find and
 inet_frag_secret_rebuild
Date: Tue, 24 Jun 2008 14:43:17 +0400
Message-ID: <4860CFC5.90702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44084 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435AbYFXKps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 06:45:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem is that while we work w/o the inet_frags.lock even
read-locked the secret rebuild timer may occur (on another CPU,
since BHs are still disables in the inet_frag_find) and change 
the rnd seed for ipv4/6 fragments.

It was caused by my patch fd9e63544cac30a34c951f0ec958038f0529e244
([INET]: Omit double hash calculations in xxx_frag_intern) late 
in the 2.6.24 kernel, so this should probably be queued to -stable.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 4ed429b..0546a0b 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -192,14 +192,21 @@ EXPORT_SYMBOL(inet_frag_evictor);
 
 static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		struct inet_frag_queue *qp_in, struct inet_frags *f,
-		unsigned int hash, void *arg)
+		void *arg)
 {
 	struct inet_frag_queue *qp;
 #ifdef CONFIG_SMP
 	struct hlist_node *n;
 #endif
+	unsigned int hash;
 
 	write_lock(&f->lock);
+	/*
+	 * While we stayed w/o the lock other CPU could update
+	 * the rnd seed, so we need to re-calculate the hash
+	 * chain. Fortunatelly the qp_in can be used to get one.
+	 */
+	hash = f->hashfn(qp_in);
 #ifdef CONFIG_SMP
 	/* With SMP race we have to recheck hash table, because
 	 * such entry could be created on other cpu, while we
@@ -247,7 +254,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 }
 
 static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
-		struct inet_frags *f, void *arg, unsigned int hash)
+		struct inet_frags *f, void *arg)
 {
 	struct inet_frag_queue *q;
 
@@ -255,7 +262,7 @@ static struct inet_frag_queue *inet_frag_create(struct netns_frags *nf,
 	if (q == NULL)
 		return NULL;
 
-	return inet_frag_intern(nf, q, f, hash, arg);
+	return inet_frag_intern(nf, q, f, arg);
 }
 
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
@@ -264,7 +271,6 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	struct inet_frag_queue *q;
 	struct hlist_node *n;
 
-	read_lock(&f->lock);
 	hlist_for_each_entry(q, n, &f->hash[hash], list) {
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
@@ -274,6 +280,6 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 	}
 	read_unlock(&f->lock);
 
-	return inet_frag_create(nf, f, key, hash);
+	return inet_frag_create(nf, f, key);
 }
 EXPORT_SYMBOL(inet_frag_find);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cd6ce6a..37221f6 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -229,6 +229,8 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 
 	arg.iph = iph;
 	arg.user = user;
+
+	read_lock(&ip4_frags.lock);
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index e65e26e..cf20bc4 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -207,9 +207,10 @@ fq_find(__be32 id, struct in6_addr *src, struct in6_addr *dst)
 	arg.id = id;
 	arg.src = src;
 	arg.dst = dst;
+
+	read_lock_bh(&nf_frags.lock);
 	hash = ip6qhashfn(id, src, dst);
 
-	local_bh_disable();
 	q = inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
 	local_bh_enable();
 	if (q == NULL)
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 798cabc..a60d7d1 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -247,6 +247,8 @@ fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst,
 	arg.id = id;
 	arg.src = src;
 	arg.dst = dst;
+
+	read_lock(&ip6_frags.lock);
 	hash = ip6qhashfn(id, src, dst);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
