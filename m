From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 7/9] net: frag,
	move nqueues counter under LRU lock protection
Date: Thu, 29 Nov 2012 17:15:07 +0100
Message-ID: <20121129161447.17754.21568.stgit@dragon>
References: <20121129161019.17754.29670.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:3621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852Ab2K2QQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:16:36 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preparation patch for per hash bucket locking.

This patch just moves the nqueues counter under the LRU lock (and
per CPU), instead of the write lock, to prepare for next patch.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/net/inet_frag.h  |   19 +++++++++++++++++--
 include/net/ipv6.h       |    2 +-
 net/ipv4/inet_fragment.c |    4 +---
 net/ipv4/ip_fragment.c   |    2 +-
 4 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 3eadf42..f58590f 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -12,11 +12,10 @@ struct frag_cpu_limit {
 	atomic_t                mem;
 	struct list_head        lru_list;
 	spinlock_t              lru_lock;
+	int			nqueues;
 } ____cacheline_aligned_in_smp;
 
 struct netns_frags {
-	int			nqueues;
-
 	struct frag_cpu_limit __percpu *percpu;
 
 	/* sysctls */
@@ -107,6 +106,7 @@ static inline void inet_frag_lru_del(struct inet_frag_queue *q)
 
 	spin_lock(&percpu->lru_lock);
 	list_del(&q->lru_list);
+	percpu->nqueues--;
 	spin_unlock(&percpu->lru_lock);
 }
 
@@ -118,6 +118,7 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 
 	spin_lock(&percpu->lru_lock);
 	list_add_tail(&q->lru_list, &percpu->lru_list);
+	percpu->nqueues++;
 	spin_unlock(&percpu->lru_lock);
 }
 
@@ -150,4 +151,18 @@ static inline int sum_frag_mem_limit(struct netns_frags *nf)
 	return sum;
 }
 
+static inline int sum_frag_nqueues(struct netns_frags *nf)
+{
+	unsigned int sum = 0;
+	int cpu;
+	for_each_possible_cpu(cpu) {
+		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+		spin_lock(&percpu->lru_lock);
+		sum += percpu->nqueues;
+		spin_unlock(&percpu->lru_lock);
+	}
+	return sum;
+}
+
 #endif
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a5c1cf1..27edfcf 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -274,7 +274,7 @@ extern bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int ip6_frag_nqueues(struct net *net)
 {
-	return net->ipv6.frags.nqueues;
+	return sum_frag_nqueues(&net->ipv6.frags);
 }
 
 static inline int ip6_frag_mem(struct net *net)
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 0099f0c..9b97f2e 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -96,13 +96,13 @@ static int inet_frags_init_percpu_limit(struct netns_frags *nf)
 		INIT_LIST_HEAD(&percpu->lru_list);
 		spin_lock_init(&percpu->lru_lock);
 		atomic_set(&percpu->mem, 0);
+		percpu->nqueues = 0;
 	}
 	return 1;
 }
 
 void inet_frags_init_net(struct netns_frags *nf)
 {
-	nf->nqueues = 0;
 	inet_frags_init_percpu_limit(nf);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
@@ -131,7 +131,6 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
 {
 	write_lock(&f->lock);
 	hlist_del(&fq->list);
-	fq->net->nqueues--;
 	write_unlock(&f->lock);
 	inet_frag_lru_del(fq);
 }
@@ -280,7 +279,6 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
 
 	atomic_inc(&qp->refcnt);
 	hlist_add_head(&qp->list, &f->hash[hash]);
-	nf->nqueues++;
 	write_unlock(&f->lock);
 	inet_frag_lru_add(nf, qp);
 	return qp;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 99944a8..26fd2b7 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -118,7 +118,7 @@ static struct inet_frags ip4_frags;
 
 int ip_frag_nqueues(struct net *net)
 {
-	return net->ipv4.frags.nqueues;
+	return sum_frag_nqueues(&net->ipv4.frags);
 }
 
 int ip_frag_mem(struct net *net)
