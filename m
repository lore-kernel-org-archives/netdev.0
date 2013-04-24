From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Wed, 24 Apr 2013 17:48:55 +0200
Message-ID: <20130424154848.16883.65833.stgit@dragon>
References: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756641Ab3DXPs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 11:48:59 -0400
In-Reply-To: <20130424154624.16883.40974.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The global LRU list is the major bottleneck in fragmentation handling
(after the recent frag optimization).

Simply change to use a LRU list per CPU, instead of a single shared
LRU list.  This was the simples approach of removing the LRU list, I
could come up with.  The previous "direct hash cleaning" approach was
getting too complicated, and interacted badly with netns.

The /proc/sys/net/ipv4/ipfrag_*_thresh values are now per CPU limits,
and have been reduced to 2 Mbytes (from 4 MB).

Performance compared to net-next (953c96e):

Test-type:  20G64K    20G3F    20G64K+DoS  20G3F+DoS  20G64K+MQ 20G3F+MQ
----------  -------   -------  ----------  ---------  --------  -------
(953c96e)
 net-next:  17417.4   11376.5   3853.43     6170.56     174.8    402.9
LRU-pr-CPU: 19047.0   13503.9  10314.10    12363.20    1528.7   2064.9

I have also tested that a 512 Kbit/s simulated link (with HTB) still
works (with sending 3x UDP fragments) under the DoS test 20G3F+MQ,
which is sending approx 1Mpps on a 10Gbit/s NIC

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/ip-sysctl.txt  |    2 -
 include/net/inet_frag.h                 |  109 +++++++++++++++++++------------
 include/net/ipv6.h                      |    8 +-
 net/ipv4/inet_fragment.c                |   57 ++++++++++++----
 net/ipv4/ip_fragment.c                  |   24 ++++---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 -
 net/ipv6/reassembly.c                   |    2 -
 7 files changed, 133 insertions(+), 71 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f98ca63..dd972d2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -67,7 +67,7 @@ ipfrag_high_thresh - INTEGER
 	Maximum memory used to reassemble IP fragments. When
 	ipfrag_high_thresh bytes of memory is allocated for this purpose,
 	the fragment handler will toss packets until ipfrag_low_thresh
-	is reached.
+	is reached. This max memory usage is per CPU.
 
 ipfrag_low_thresh - INTEGER
 	See ipfrag_high_thresh
diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 4e15856..ca93056 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -1,17 +1,22 @@
 #ifndef __NET_FRAG_H__
 #define __NET_FRAG_H__
 
-#include <linux/percpu_counter.h>
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+#include <linux/percpu.h>
 
-struct netns_frags {
+/* Maintain these resource limits per CPU, else performance will suffer
+ * due to cache-line bouncing
+ */
+struct frag_cpu_limit {
+	atomic_t                mem;
 	int			nqueues;
-	struct list_head	lru_list;
-	spinlock_t		lru_lock;
+	struct list_head        lru_list;
+	spinlock_t              lru_lock;
+};
 
-	/* The percpu_counter "mem" need to be cacheline aligned.
-	 *  mem.count must not share cacheline with other writers
-	 */
-	struct percpu_counter   mem ____cacheline_aligned_in_smp;
+struct netns_frags {
+	struct frag_cpu_limit __percpu *percpu;
 
 	/* sysctls */
 	int			timeout;
@@ -25,6 +30,7 @@ struct inet_frag_queue {
 	struct list_head	lru_list;   /* lru list member */
 	struct hlist_node	list;
 	atomic_t		refcnt;
+	u32			cpu_alloc;  /* for mem limit track per CPU */
 	struct sk_buff		*fragments; /* list of received fragments */
 	struct sk_buff		*fragments_tail;
 	ktime_t			stamp;
@@ -78,7 +84,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
 void inet_frag_destroy(struct inet_frag_queue *q,
 				struct inet_frags *f, int *work);
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
+int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
+		      bool force, int on_cpu);
 struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 		struct inet_frags *f, void *key, unsigned int hash)
 	__releases(&f->lock);
@@ -91,66 +98,86 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
 
 /* Memory Tracking Functions. */
 
-/* The default percpu_counter batch size is not big enough to scale to
- * fragmentation mem acct sizes.
- * The mem size of a 64K fragment is approx:
- *  (44 fragments * 2944 truesize) + frag_queue struct(200) = 129736 bytes
- */
-static unsigned int frag_percpu_counter_batch = 130000;
-
-static inline int frag_mem_limit(struct netns_frags *nf)
-{
-	return percpu_counter_read(&nf->mem);
-}
-
 static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
-	__percpu_counter_add(&q->net->mem, -i, frag_percpu_counter_batch);
+	int cpu = q->cpu_alloc;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+	atomic_sub(i, &percpu->mem);
 }
 
 static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
-	__percpu_counter_add(&q->net->mem, i, frag_percpu_counter_batch);
-}
-
-static inline void init_frag_mem_limit(struct netns_frags *nf)
-{
-	percpu_counter_init(&nf->mem, 0);
+	int cpu = q->cpu_alloc;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+	atomic_add(i, &percpu->mem);
 }
 
 static inline int sum_frag_mem_limit(struct netns_frags *nf)
 {
-	int res;
+	unsigned int sum = 0;
+	int cpu;
 
 	local_bh_disable();
-	res = percpu_counter_sum_positive(&nf->mem);
+	for_each_possible_cpu(cpu) {
+		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+		sum += atomic_read(&percpu->mem);
+	}
 	local_bh_enable();
 
-	return res;
+	return sum;
+}
+
+static inline int sum_frag_nqueues(struct netns_frags *nf)
+{
+	unsigned int sum = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+		spin_lock(&percpu->lru_lock);
+		sum += percpu->nqueues;
+		spin_unlock(&percpu->lru_lock);
+	}
+
+	return sum;
 }
 
+
+/* LRU (Least Recently Used) resource functions */
+
 static inline void inet_frag_lru_move(struct inet_frag_queue *q)
 {
-	spin_lock(&q->net->lru_lock);
-	list_move_tail(&q->lru_list, &q->net->lru_list);
-	spin_unlock(&q->net->lru_lock);
+	int cpu = q->cpu_alloc;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+
+	spin_lock(&percpu->lru_lock);
+	list_move_tail(&q->lru_list, &percpu->lru_list);
+	spin_unlock(&percpu->lru_lock);
 }
 
 static inline void inet_frag_lru_del(struct inet_frag_queue *q)
 {
-	spin_lock(&q->net->lru_lock);
+	int cpu = q->cpu_alloc;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+
+	spin_lock(&percpu->lru_lock);
 	list_del(&q->lru_list);
-	q->net->nqueues--;
-	spin_unlock(&q->net->lru_lock);
+	percpu->nqueues--;
+	spin_unlock(&percpu->lru_lock);
 }
 
 static inline void inet_frag_lru_add(struct netns_frags *nf,
 				     struct inet_frag_queue *q)
 {
-	spin_lock(&nf->lru_lock);
-	list_add_tail(&q->lru_list, &nf->lru_list);
-	q->net->nqueues++;
-	spin_unlock(&nf->lru_lock);
+	int cpu = q->cpu_alloc;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+	spin_lock(&percpu->lru_lock);
+	list_add_tail(&q->lru_list, &percpu->lru_list);
+	percpu->nqueues++;
+	spin_unlock(&percpu->lru_lock);
 }
 
 /* RFC 3168 support :
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 0810aa5..f108b80 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -286,7 +286,7 @@ static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int ip6_frag_nqueues(struct net *net)
 {
-	return net->ipv6.frags.nqueues;
+	return sum_frag_nqueues(&net->ipv6.frags);
 }
 
 static inline int ip6_frag_mem(struct net *net)
@@ -295,8 +295,10 @@ static inline int ip6_frag_mem(struct net *net)
 }
 #endif
 
-#define IPV6_FRAG_HIGH_THRESH	(4 * 1024*1024)	/* 4194304 */
-#define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
+/* Frag mem thresholds are per CPU */
+#define IPV6_FRAG_MAXSZ 	(1 * 128 *1024) /*  131072 */
+#define IPV6_FRAG_HIGH_THRESH	(2 * 1024*1024) /* 2097152 */
+#define IPV6_FRAG_LOW_THRESH	IPV6_FRAG_HIGH_THRESH - IPV6_FRAG_MAXSZ
 #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
 
 extern int __ipv6_addr_type(const struct in6_addr *addr);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index db30a01..94c45c6 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -45,6 +45,18 @@ const u8 ip_frag_ecn_table[16] = {
 };
 EXPORT_SYMBOL(ip_frag_ecn_table);
 
+static inline int frag_mem_limit_on_cpu(struct netns_frags *nf, int on_cpu)
+{
+	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, on_cpu);
+	return atomic_read(&percpu->mem);
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
@@ -104,10 +116,20 @@ EXPORT_SYMBOL(inet_frags_init);
 
 void inet_frags_init_net(struct netns_frags *nf)
 {
-	nf->nqueues = 0;
-	init_frag_mem_limit(nf);
-	INIT_LIST_HEAD(&nf->lru_list);
-	spin_lock_init(&nf->lru_lock);
+	int cpu;
+
+	nf->percpu = alloc_percpu(struct frag_cpu_limit);
+	if (!nf->percpu)
+		return;
+
+	for_each_possible_cpu(cpu) {
+		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+		INIT_LIST_HEAD(&percpu->lru_list);
+		spin_lock_init(&percpu->lru_lock);
+		atomic_set(&percpu->mem, 0);
+		percpu->nqueues = 0;
+	}
 }
 EXPORT_SYMBOL(inet_frags_init_net);
 
@@ -119,13 +141,16 @@ EXPORT_SYMBOL(inet_frags_fini);
 
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 {
+	int cpu;
+
 	nf->low_thresh = 0;
 
 	local_bh_disable();
-	inet_frag_evictor(nf, f, true);
+	for_each_possible_cpu(cpu)
+		inet_frag_evictor(nf, f, true, cpu);
 	local_bh_enable();
 
-	percpu_counter_destroy(&nf->mem);
+	free_percpu(nf->percpu);
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
 
@@ -199,32 +224,35 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
 }
 EXPORT_SYMBOL(inet_frag_destroy);
 
-int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
+int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
+		      bool force, int on_cpu)
 {
 	struct inet_frag_queue *q;
 	int work, evicted = 0;
+	int cpu = (likely(on_cpu < 0)) ? smp_processor_id() : on_cpu;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
 
 	if (!force) {
-		if (frag_mem_limit(nf) <= nf->high_thresh)
+		if (frag_mem_limit_on_cpu(nf, cpu) <= nf->high_thresh)
 			return 0;
 	}
 
-	work = frag_mem_limit(nf) - nf->low_thresh;
+	work = frag_mem_limit_on_cpu(nf, cpu) - nf->low_thresh;
 	while (work > 0) {
-		spin_lock(&nf->lru_lock);
+		spin_lock(&percpu->lru_lock);
 
-		if (list_empty(&nf->lru_list)) {
-			spin_unlock(&nf->lru_lock);
+		if (list_empty(&percpu->lru_list)) {
+			spin_unlock(&percpu->lru_lock);
 			break;
 		}
 
-		q = list_first_entry(&nf->lru_list,
+		q = list_first_entry(&percpu->lru_list,
 				struct inet_frag_queue, lru_list);
 		atomic_inc(&q->refcnt);
 		/* Remove q from list to avoid several CPUs grabbing it */
 		list_del_init(&q->lru_list);
 
-		spin_unlock(&nf->lru_lock);
+		spin_unlock(&percpu->lru_lock);
 
 		spin_lock(&q->lock);
 		if (!(q->last_in & INET_FRAG_COMPLETE))
@@ -298,6 +326,7 @@ static inline struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 		return NULL;
 
 	q->net = nf;
+	q->cpu_alloc = (u32) smp_processor_id();
 	f->constructor(q, arg);
 	add_frag_mem_limit(q, f->qsize);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cda5514..7bbe7cd 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -18,6 +18,7 @@
  *		John McDonald	:	0 length frag bug.
  *		Alexey Kuznetsov:	SMP races, threading, cleanup.
  *		Patrick McHardy :	LRU queue of frag heads for evictor.
+ *		Jesper D. Brouer:	SMP/NUMA scalability
  */
 
 #define pr_fmt(fmt) "IPv4: " fmt
@@ -88,7 +89,7 @@ static struct inet_frags ip4_frags;
 
 int ip_frag_nqueues(struct net *net)
 {
-	return net->ipv4.frags.nqueues;
+	return sum_frag_nqueues(&net->ipv4.frags);
 }
 
 int ip_frag_mem(struct net *net)
@@ -183,7 +184,7 @@ static void ip_evictor(struct net *net)
 {
 	int evicted;
 
-	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false);
+	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false, -1);
 	if (evicted)
 		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
 }
@@ -816,6 +817,12 @@ static inline void ip4_frags_ctl_register(void)
 }
 #endif
 
+/* A 64K fragment consumes 129736 bytes (44*2944)+200
+ * (1500 truesize == 2944, sizeof(struct ipq) == 200)
+ */
+#define IPV4_FRAG_MAXSZ 	(1 * 128 * 1024)  /*  131072 */
+#define IPV4_FRAG_HIGH_THRESH	(2 * 1024 * 1024) /* 2097152 */
+
 static int __net_init ipv4_frags_init_net(struct net *net)
 {
 	/* Fragment cache limits.
@@ -825,15 +832,12 @@ static int __net_init ipv4_frags_init_net(struct net *net)
 	 * queue struct (inet_frag_queue (ipv4:ipq/ipv6:frag_queue))
 	 * and the SKB's truesize.
 	 *
-	 * A 64K fragment consumes 129736 bytes (44*2944)+200
-	 * (1500 truesize == 2944, sizeof(struct ipq) == 200)
-	 *
-	 * We will commit 4MB at one time. Should we cross that limit
-	 * we will prune down to 3MB, making room for approx 8 big 64K
-	 * fragments 8x128k.
+	 * These mem limits are per CPU (scalability reasons), for each CPU
+	 * we will commit 2MB at one time. Should we cross that limit
+	 * we will prune down making room for one big 64K fragment 128k.
 	 */
-	net->ipv4.frags.high_thresh = 4 * 1024 * 1024;
-	net->ipv4.frags.low_thresh  = 3 * 1024 * 1024;
+	net->ipv4.frags.high_thresh = IPV4_FRAG_HIGH_THRESH;
+	net->ipv4.frags.low_thresh  = IPV4_FRAG_HIGH_THRESH - IPV4_FRAG_MAXSZ;
 	/*
 	 * Important NOTE! Fragment queue must be destroyed before MSL expires.
 	 * RFC791 is wrong proposing to prolongate timer each fragment arrival
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 7cfa829..291d1d8 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -586,7 +586,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 	fhdr = (struct frag_hdr *)skb_transport_header(clone);
 
 	local_bh_disable();
-	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
+	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false, -1);
 	local_bh_enable();
 
 	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr,
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 74505c5..399321d 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -535,7 +535,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false);
+	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false, -1);
 	if (evicted)
 		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 				 IPSTATS_MIB_REASMFAILS, evicted);
