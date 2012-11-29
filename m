From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 6/9] net: frag,
	implement dynamic percpu alloc of frag_cpu_limit
Date: Thu, 29 Nov 2012 17:14:42 +0100
Message-ID: <20121129161343.17754.96847.stgit@dragon>
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
Received: from mx1.redhat.com ([209.132.183.28]:57866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754765Ab2K2QQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 11:16:59 -0500
In-Reply-To: <20121129161019.17754.29670.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the percpu API to implement dynamic per CPU allocation
of the frag_cpu_limit in struct netns_frags.  This replaces
the static array percpu[NR_CPUS].

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
Its the first time I use the percpu API, please let me know
if I'm using it correctly.

 include/net/inet_frag.h  |   39 ++++++++++++++++++++++++++-------------
 net/ipv4/inet_fragment.c |   34 +++++++++++++++++++++++-----------
 2 files changed, 49 insertions(+), 24 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 8421904..3eadf42 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -3,6 +3,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/atomic.h>
+#include <linux/percpu.h>
 
 /* Need to maintain these resource limits per CPU, else we will kill
  * performance due to cache-line bouncing
@@ -16,7 +17,7 @@ struct frag_cpu_limit {
 struct netns_frags {
 	int			nqueues;
 
-	struct frag_cpu_limit	percpu[NR_CPUS];
+	struct frag_cpu_limit __percpu *percpu;
 
 	/* sysctls */
 	int			timeout;
@@ -92,26 +93,32 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
 static inline void inet_frag_lru_move(struct inet_frag_queue *q)
 {
 	int cpu = q->cpu_alloc;
-	spin_lock(&q->net->percpu[cpu].lru_lock);
-	list_move_tail(&q->lru_list, &q->net->percpu[cpu].lru_list);
-	spin_unlock(&q->net->percpu[cpu].lru_lock);
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+
+	spin_lock(&percpu->lru_lock);
+	list_move_tail(&q->lru_list, &percpu->lru_list);
+	spin_unlock(&percpu->lru_lock);
 }
 
 static inline void inet_frag_lru_del(struct inet_frag_queue *q)
 {
 	int cpu = q->cpu_alloc;
-	spin_lock(&q->net->percpu[cpu].lru_lock);
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+
+	spin_lock(&percpu->lru_lock);
 	list_del(&q->lru_list);
-	spin_unlock(&q->net->percpu[cpu].lru_lock);
+	spin_unlock(&percpu->lru_lock);
 }
 
 static inline void inet_frag_lru_add(struct netns_frags *nf,
 				     struct inet_frag_queue *q)
 {
 	int cpu = q->cpu_alloc;
-	spin_lock(&nf->percpu[cpu].lru_lock);
-	list_add_tail(&q->lru_list, &nf->percpu[cpu].lru_list);
-	spin_unlock(&nf->percpu[cpu].lru_lock);
+	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+	spin_lock(&percpu->lru_lock);
+	list_add_tail(&q->lru_list, &percpu->lru_list);
+	spin_unlock(&percpu->lru_lock);
 }
 
 /* Memory Tracking Functions. */
@@ -119,21 +126,27 @@ static inline void inet_frag_lru_add(struct netns_frags *nf,
 static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
 	int cpu = q->cpu_alloc;
-	atomic_sub(i, &q->net->percpu[cpu].mem);
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+	atomic_sub(i, &percpu->mem);
 }
 
 static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
 	int cpu = q->cpu_alloc;
-	atomic_add(i, &q->net->percpu[cpu].mem);
+	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
+	atomic_add(i, &percpu->mem);
 }
 
 static inline int sum_frag_mem_limit(struct netns_frags *nf)
 {
 	unsigned int sum = 0;
 	int cpu;
-	for_each_possible_cpu(cpu)
-		sum += atomic_read(&nf->percpu[cpu].mem);
+
+	for_each_possible_cpu(cpu) {
+		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+		sum += atomic_read(&percpu->mem);
+	}
 	return sum;
 }
 
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 068aabe..0099f0c 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -25,7 +25,8 @@
 
 static inline int frag_mem_limit_on_cpu(struct netns_frags *nf, int on_cpu)
 {
-	return atomic_read(&nf->percpu[on_cpu].mem);
+	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, on_cpu);
+	return atomic_read(&percpu->mem);
 }
 
 static inline int frag_mem_limit(struct netns_frags *nf)
@@ -81,14 +82,22 @@ void inet_frags_init(struct inet_frags *f)
 }
 EXPORT_SYMBOL(inet_frags_init);
 
-static void inet_frags_init_percpu_limit(struct netns_frags *nf)
+static int inet_frags_init_percpu_limit(struct netns_frags *nf)
 {
 	int cpu;
+
+	nf->percpu = alloc_percpu(struct frag_cpu_limit);
+	if (!nf->percpu)
+		return -ENOMEM;
+
 	for_each_possible_cpu(cpu) {
-		INIT_LIST_HEAD(&nf->percpu[cpu].lru_list);
-		spin_lock_init(&nf->percpu[cpu].lru_lock);
-		atomic_set(&nf->percpu[cpu].mem, 0);
+		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
+
+		INIT_LIST_HEAD(&percpu->lru_list);
+		spin_lock_init(&percpu->lru_lock);
+		atomic_set(&percpu->mem, 0);
 	}
+	return 1;
 }
 
 void inet_frags_init_net(struct netns_frags *nf)
@@ -113,6 +122,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 	for_each_possible_cpu(cpu)
 		inet_frag_evictor(nf, f, true, cpu);
 	local_bh_enable();
+
+	free_percpu(nf->percpu);
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
 
@@ -184,6 +195,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
 	struct inet_frag_queue *q;
 	int work, evicted = 0;
 	int cpu = (likely(on_cpu < 0)) ? smp_processor_id() : on_cpu;
+	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
 
 	if (!force) {
 		if (frag_mem_limit_on_cpu(nf, cpu) <= nf->high_thresh)
@@ -192,14 +204,14 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
 
 	work = frag_mem_limit_on_cpu(nf, cpu) - nf->low_thresh;
 	while (work > 0) {
-		spin_lock(&nf->percpu[cpu].lru_lock);
+		spin_lock(&percpu->lru_lock);
 
-		if (list_empty(&nf->percpu[cpu].lru_list)) {
-			spin_unlock(&nf->percpu[cpu].lru_lock);
+		if (list_empty(&percpu->lru_list)) {
+			spin_unlock(&percpu->lru_lock);
 			break;
 		}
 
-		q = list_first_entry(&nf->percpu[cpu].lru_list,
+		q = list_first_entry(&percpu->lru_list,
 				struct inet_frag_queue, lru_list);
 
 		/* queue entry is warm, i.e. new frags are arriving
@@ -209,12 +221,12 @@ int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
 		 * completes.
 		 */
 		if (!force && q->creation_ts == (u32) jiffies) {
-			spin_unlock(&nf->percpu[cpu].lru_lock);
+			spin_unlock(&percpu->lru_lock);
 			break;
 		}
 
 		atomic_inc(&q->refcnt);
-		spin_unlock(&nf->percpu[cpu].lru_lock);
+		spin_unlock(&percpu->lru_lock);
 
 		spin_lock(&q->lock);
 		if (!(q->last_in & INET_FRAG_COMPLETE))
