From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 5/9] net: frag, per CPU resource,
	mem limit and LRU list accounting
Date: Thu, 29 Nov 2012 17:13:38 +0100
Message-ID: <20121129161303.17754.47046.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:9836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781Ab2K2QO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:14:56 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The major performance bottleneck on NUMA systems, is the mem limit
counter which is based an atomic counter.  This patch removes the
cache-bouncing of the atomic counter, by moving this accounting to be
bound to each CPU.  The LRU list also need to be done per CPU,
in-order to keep the accounting straight.

If fragments belonging together is "sprayed" across CPUs, performance
will still suffer, but due to NIC rxhashing this is not very common.
Correct accounting in this situation is maintained by recording and
"assigning" a CPU to a frag queue when its allocated (caused by the
first packet associated packet).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Rename struct cpu_resource -> frag_cpu_limit
 - Move init functions from inet_frag.h to inet_fragment.c
 - Cleanup per CPU in inet_frags_exit_net()

 include/net/inet_frag.h                 |   64 +++++++++++++++++++------------
 net/ipv4/inet_fragment.c                |   50 ++++++++++++++++++------
 net/ipv4/ip_fragment.c                  |    3 +
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 -
 net/ipv6/reassembly.c                   |    2 -
 5 files changed, 80 insertions(+), 41 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 9bbef17..8421904 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -1,11 +1,22 @@
 #ifndef __NET_FRAG_H__
 #define __NET_FRAG_H__
 
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+
+/* Need to maintain these resource limits per CPU, else we will kill
+ * performance due to cache-line bouncing
+ */
+struct frag_cpu_limit {
+	atomic_t                mem;
+	struct list_head        lru_list;
+	spinlock_t              lru_lock;
+} ____cacheline_aligned_in_smp;
+
 struct netns_frags {
 	int			nqueues;
-	atomic_t		mem;
-	struct list_head	lru_list;
-	spinlock_t		lru_lock;
+
+	struct frag_cpu_limit	percpu[NR_CPUS];
 
 	/* sysctls */
 	int			timeout;
@@ -26,6 +37,7 @@ struct inet_frag_queue {
 	int			meat;
 	struct netns_frags	*net;
 	u32			creation_ts;/* jiffies when queue was created*/
+	u32			cpu_alloc;  /* used for mem limit accounting */
 	__u8			last_in;    /* first/last segment arrived? */
 
 #define INET_FRAG_COMPLETE	4
@@ -63,7 +75,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
 void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
+int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
+		      bool force, int on_cpu);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
@@ -74,53 +87,54 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
 		inet_frag_destroy(q, f, NULL);
 }
 
+/* LRU (Least Recently Used) resource functions */
+
 static inline void inet_frag_lru_move(struct inet_frag_queue *q)
 {
-	spin_lock(&q->net->lru_lock);
-	list_move_tail(&q->lru_list, &q->net->lru_list);
-	spin_unlock(&q->net->lru_lock);
+	int cpu = q->cpu_alloc;
+	spin_lock(&q->net->percpu[cpu].lru_lock);
+	list_move_tail(&q->lru_list, &q->net->percpu[cpu].lru_list);
+	spin_unlock(&q->net->percpu[cpu].lru_lock);
 }
 
 static inline void inet_frag_lru_del(struct inet_frag_queue *q)
 {
-	spin_lock(&q->net->lru_lock);
+	int cpu = q->cpu_alloc;
+	spin_lock(&q->net->percpu[cpu].lru_lock);
 	list_del(&q->lru_list);
-	spin_unlock(&q->net->lru_lock);
+	spin_unlock(&q->net->percpu[cpu].lru_lock);
 }
 
 static inline void inet_frag_lru_add(struct netns_frags *nf,
 				     struct inet_frag_queue *q)
 {
-	spin_lock(&nf->lru_lock);
-	list_add_tail(&q->lru_list, &nf->lru_list);
-	spin_unlock(&nf->lru_lock);
+	int cpu = q->cpu_alloc;
+	spin_lock(&nf->percpu[cpu].lru_lock);
+	list_add_tail(&q->lru_list, &nf->percpu[cpu].lru_list);
+	spin_unlock(&nf->percpu[cpu].lru_lock);
 }
 
 /* Memory Tracking Functions. */
 
-static inline int frag_mem_limit(struct netns_frags *nf)
-{
-	return atomic_read(&nf->mem);
-}
-
 static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
-	atomic_sub(i, &q->net->mem);
+	int cpu = q->cpu_alloc;
+	atomic_sub(i, &q->net->percpu[cpu].mem);
 }
 
 static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
-	atomic_add(i, &q->net->mem);
-}
-
-static inline void init_frag_mem_limit(struct netns_frags *nf)
-{
-	atomic_set(&nf->mem, 0);
+	int cpu = q->cpu_alloc;
+	atomic_add(i, &q->net->percpu[cpu].mem);
 }
 
 static inline int sum_frag_mem_limit(struct netns_frags *nf)
 {
-	return atomic_read(&nf->mem);
+	unsigned int sum = 0;
+	int cpu;
+	for_each_possible_cpu(cpu)
+		sum += atomic_read(&nf->percpu[cpu].mem);
+	return sum;
 }
 
 #endif
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 0ecacbd..068aabe 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -23,6 +23,17 @@
 
 #include <net/inet_frag.h>
 
+static inline int frag_mem_limit_on_cpu(struct netns_frags *nf, int on_cpu)
+{
+	return atomic_read(&nf->percpu[on_cpu].mem);
+}
+
+static inline int frag_mem_limit(struct netns_frags *nf)
+{
+	int cpu = smp_processor_id();
+	return frag_mem_limit_on_cpu(nf, cpu);
+}
+
 static void inet_frag_secret_rebuild(unsigned long dummy)
 {
 	struct inet_frags *f = (struct inet_frags *)dummy;
@@ -70,12 +81,20 @@ void inet_frags_init(struct inet_frags *f)
 }
 EXPORT_SYMBOL(inet_frags_init);
 
+static void inet_frags_init_percpu_limit(struct netns_frags *nf)
+{
+	int cpu;
+	for_each_possible_cpu(cpu) {
+		INIT_LIST_HEAD(&nf->percpu[cpu].lru_list);
+		spin_lock_init(&nf->percpu[cpu].lru_lock);
+		atomic_set(&nf->percpu[cpu].mem, 0);
+	}
+}
+
 void inet_frags_init_net(struct netns_frags *nf)
 {
 	nf->nqueues = 0;
-	init_frag_mem_limit(nf);
-	INIT_LIST_HEAD(&nf->lru_list);
-	spin_lock_init(&nf->lru_lock);
+	inet_frags_init_percpu_limit(nf);
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
@@ -87,10 +106,12 @@ EXPORT_SYMBOL(inet_frags_fini);
 
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 {
+	int cpu;
 	nf->low_thresh = 0;
 
 	local_bh_disable();
-	inet_frag_evictor(nf, f, true);
+	for_each_possible_cpu(cpu)
+		inet_frag_evictor(nf, f, true, cpu);
 	local_bh_enable();
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
@@ -157,26 +178,28 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
+int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
+		      bool force, int on_cpu)
 {
 	struct inet_frag_queue *q;
 	int work, evicted = 0;
+	int cpu = (likely(on_cpu < 0)) ? smp_processor_id() : on_cpu;
 
 	if (!force) {
-		if (frag_mem_limit(nf) <= nf->high_thresh)
+		if (frag_mem_limit_on_cpu(nf, cpu) <= nf->high_thresh)
 			return 0;
 	}
 
-	work = frag_mem_limit(nf) - nf->low_thresh;
+	work = frag_mem_limit_on_cpu(nf, cpu) - nf->low_thresh;
 	while (work > 0) {
-		spin_lock(&nf->lru_lock);
+		spin_lock(&nf->percpu[cpu].lru_lock);
 
-		if (list_empty(&nf->lru_list)) {
-			spin_unlock(&nf->lru_lock);
+		if (list_empty(&nf->percpu[cpu].lru_list)) {
+			spin_unlock(&nf->percpu[cpu].lru_lock);
 			break;
 		}
 
-		q = list_first_entry(&nf->lru_list,
+		q = list_first_entry(&nf->percpu[cpu].lru_list,
 				struct inet_frag_queue, lru_list);
 
 		/* queue entry is warm, i.e. new frags are arriving
@@ -186,12 +209,12 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
 		 * completes.
 		 */
 		if (!force && q->creation_ts == (u32) jiffies) {
-			spin_unlock(&nf->lru_lock);
+			spin_unlock(&nf->percpu[cpu].lru_lock);
 			break;
 		}
 
 		atomic_inc(&q->refcnt);
-		spin_unlock(&nf->lru_lock);
+		spin_unlock(&nf->percpu[cpu].lru_lock);
 
 		spin_lock(&q->lock);
 		if (!(q->last_in & INET_FRAG_COMPLETE))
@@ -267,6 +290,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 		return NULL;
 
 	q->creation_ts = (u32) jiffies;
+	q->cpu_alloc = (u32) smp_processor_id();
 	q->net = nf;
 	f->constructor(q, arg);
 	add_frag_mem_limit(q, f->qsize);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index abb5551..99944a8 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -18,6 +18,7 @@
  *		John McDonald	:	0 length frag bug.
  *		Alexey Kuznetsov:	SMP races, threading, cleanup.
  *		Patrick McHardy :	LRU queue of frag heads for evictor.
+ *		Jesper Brouer   :	SMP/NUMA scalability
  */
 
 #define pr_fmt(fmt) "IPv4: " fmt
@@ -212,7 +213,7 @@ static void ip_evictor(struct net *net)
 {
 	int evicted;
 
-	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false);
+	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false, -1);
 	if (evicted)
 		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index c088831..8cb1710 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -566,7 +566,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
 	local_bh_disable();
-	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
+	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false, -1);
 	local_bh_enable();
 
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index bab2c27..d1e70dd 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -529,7 +529,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false);
+	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false, -1);
 	if (evicted)
 		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_REASMFAILS, evicted);
