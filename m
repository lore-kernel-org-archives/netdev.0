From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V1 9/9] net: frag remove readers-writer lock
	(hack)
Date: Fri, 23 Nov 2012 14:08:47 +0100
Message-ID: <20121123130847.18764.87682.stgit@dragon>
References: <20121123130749.18764.25962.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab2KWNKm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 08:10:42 -0500
In-Reply-To: <20121123130749.18764.25962.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do NOT APPLY this patch.

After all the other patches, the rw_lock is now the contention point.

This is a quick hack, that remove the readers-writer lock, by
disabling/breaking hash rebuilding.  Just to see how big the
performance gain would be.

  2x10G size(4416) result: 6481+6764 = 13245 Mbit/s (gen: 7652+8077 Mbit/s)

  4x10G size(4416) result:(5610+6283+5735+5238)=22866 Mbit/s
                     (gen: 6530+7860+5967+5238 =25595 Mbit/s)

And the results show, that its a big win. With 4x10G size(4416)
before: 17923 Mbit/s -> now: 22866 Mbit/s increase 4943 Mbit/s.
With 2x10G size(4416) before 10689 Mbit/s -> 13245 Mbit/s
increase 2556 Mbit/s.

I'll work on a real solution for removing the rw_lock while still
supporting hash rebuilding.  Suggestions and ideas are welcome.

NOT-signed-off
---

 include/net/inet_frag.h                 |    2 +-
 net/ipv4/inet_fragment.c                |   23 +++++++++++++----------
 net/ipv4/ip_fragment.c                  |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 net/ipv6/reassembly.c                   |    2 +-
 5 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 5054228..2fb8578 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -58,7 +58,7 @@ struct inet_frag_bucket {
 
 struct inet_frags {
 	struct inet_frag_bucket	hash[INETFRAGS_HASHSZ];
-	rwlock_t		lock; /* Rebuild lock */
+//	rwlock_t		lock; /* Rebuild lock */
 	u32			rnd;
 	int			qsize;
 	int			secret_interval;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 447423f..63227d6 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -35,8 +35,11 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 	unsigned long now = jiffies;
 	int i;
 
+	//HACK don't rebuild
+	return;
+
 	/* Per bucket lock NOT needed here, due to write lock protection */
-	write_lock(&f->lock);
+//	write_lock(&f->lock);
 
 	get_random_bytes(&f->rnd, sizeof(u32));
 	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
@@ -59,7 +62,7 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 			}
 		}
 	}
-	write_unlock(&f->lock);
+//	write_unlock(&f->lock);
 
 	mod_timer(&f->secret_timer, now + f->secret_interval);
 }
@@ -74,7 +77,7 @@ void inet_frags_init(struct inet_frags *f)
 		spin_lock_init(&hb->chain_lock);
 		INIT_HLIST_HEAD(&hb->chain);
 	}
-	rwlock_init(&f->lock);
+//	rwlock_init(&f->lock);
 
 	f->rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
 				   (jiffies ^ (jiffies >> 6)));
@@ -115,14 +118,14 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 	struct inet_frag_bucket *hb;
 	unsigned int hash;
 
-	read_lock(&f->lock);
+	//read_lock(&f->lock);
 	hash = f->hashfn(fq);
 	hb = &f->hash[hash];
 
 	spin_lock_bh(&hb->chain_lock);
 	hlist_del(&fq->list);
 	spin_unlock_bh(&hb->chain_lock);
-	read_unlock(&f->lock);
+	//read_unlock(&f->lock);
 	inet_frag_lru_del(fq);
 }
 
@@ -249,7 +252,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 #endif
 	unsigned int hash;
 
-	read_lock(&f->lock); /* Protects against hash rebuild */
+	//read_lock(&f->lock); /* Protects against hash rebuild */
 	/*
 	 * While we stayed w/o the lock other CPU could update
 	 * the rnd seed, so we need to re-calculate the hash
@@ -268,7 +271,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 		if (qp->net == nf && f->match(qp, arg)) {
 			atomic_inc(&qp->refcnt);
 			spin_unlock_bh(&hb->chain_lock);
-			read_unlock(&f->lock);
+			//read_unlock(&f->lock);
 			qp_in->last_in |= INET_FRAG_COMPLETE;
 			inet_frag_put(qp_in, f);
 			return qp;
@@ -282,7 +285,7 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &hb->chain);
 	spin_unlock_bh(&hb->chain_lock);
-	read_unlock(&f->lock);
+	//read_unlock(&f->lock);
 	inet_frag_lru_add(nf, qp);
 	return qp;
 }
@@ -342,12 +345,12 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		if (q->net == nf && f->match(q, key)) {
 			atomic_inc(&q->refcnt);
 			spin_unlock_bh(&hb->chain_lock);
-			read_unlock(&f->lock);
+			//read_unlock(&f->lock);
 			return q;
 		}
 	}
 	spin_unlock_bh(&hb->chain_lock);
-	read_unlock(&f->lock);
+	//read_unlock(&f->lock);
 
 	return inet_frag_create(nf, f, key);
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 7b1cf51..b2cb05f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -289,7 +289,7 @@ static inline struct ipq *ip_find(struct net *net, struct iphdr *iph, u32 user)
 	arg.iph = iph;
 	arg.user = user;
 
-	read_lock(&ip4_frags.lock);
+	//read_lock(&ip4_frags.lock);
 	hash = ipqhashfn(iph->id, iph->saddr, iph->daddr, iph->protocol);
 
 	q = inet_frag_find(&net->ipv4.frags, &ip4_frags, &arg, hash);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index c088831..5b57e03 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -175,7 +175,7 @@ static inline struct frag_queue *fq_find(struct net *net, __be32 id,
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock_bh(&nf_frags.lock);
+	//read_lock_bh(&nf_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, nf_frags.rnd);
 
 	q = inet_frag_find(&net->nf_frag.frags, &nf_frags, &arg, hash);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 9cfe047..2c74394 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -193,7 +193,7 @@ fq_find(struct net *net, __be32 id, const struct in6_addr *src, const struct in6
 	arg.src = src;
 	arg.dst = dst;
 
-	read_lock(&ip6_frags.lock);
+	//read_lock(&ip6_frags.lock);
 	hash = inet6_hash_frag(id, src, dst, ip6_frags.rnd);
 
 	q = inet_frag_find(&net->ipv6.frags, &ip6_frags, &arg, hash);
