From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 5/6] net: use lib/percpu_counter API for
	fragmentation mem accounting
Date: Tue, 29 Jan 2013 10:45:33 +0100
Message-ID: <20130129094517.13513.12103.stgit@dragon>
References: <20130129094331.13513.28377.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129Ab3A2JmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 04:42:05 -0500
In-Reply-To: <20130129094331.13513.28377.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the per network namespace shared atomic "mem" accounting
variable, in the fragmentation code, with a lib/percpu_counter.

Getting percpu_counter to scale to the fragmentation code usage
requires some tweaks.

At first view, percpu_counter looks superfast, but it does not
scale on multi-CPU/NUMA machines, because the default batch size
is too small, for frag code usage.  Thus, I have adjusted the
batch size by using __percpu_counter_add() directly, instead of
percpu_counter_sub() and percpu_counter_add().

The batch size is increased to 130.000, based on the largest 64K
fragment memory usage.  This does introduce some imprecise
memory accounting, but its does not need to be strict for this
use-case.

It is also essential, that the percpu_counter, does not
share cacheline with other writers, to make this scale.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Remove unrelated change/comment in include/linux/percpu_counter.h

 include/net/inet_frag.h  |   26 ++++++++++++++++++--------
 net/ipv4/inet_fragment.c |    2 ++
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index f2fabc2..e0eec74 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -1,14 +1,17 @@
 #ifndef __NET_FRAG_H__
 #define __NET_FRAG_H__
 
+#include <linux/percpu_counter.h>
+
 struct netns_frags {
 	int			nqueues;
 	struct list_head	lru_list;
 
-	/* Its important for performance to keep lru_list and mem on
-	 * separate cachelines
+	/* The percpu_counter "mem" need to be cacheline aligned.
+	 *  mem.count must not share cacheline with other writers
 	 */
-	atomic_t		mem ____cacheline_aligned_in_smp;
+	struct percpu_counter   mem ____cacheline_aligned_in_smp;
+
 	/* sysctls */
 	int			timeout;
 	int			high_thresh;
@@ -81,29 +84,36 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
 
 /* Memory Tracking Functions. */
 
+/* The default percpu_counter batch size is not big enough to scale to
+ * fragmentation mem acct sizes.
+ * The mem size of a 64K fragment is approx:
+ *  (44 fragments * 2944 truesize) + frag_queue struct(200) = 129736 bytes
+ */
+static unsigned int frag_percpu_counter_batch = 130000;
+
 static inline int frag_mem_limit(struct netns_frags *nf)
 {
-	return atomic_read(&nf->mem);
+	return percpu_counter_read(&nf->mem);
 }
 
 static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
-	atomic_sub(i, &q->net->mem);
+	__percpu_counter_add(&q->net->mem, -i, frag_percpu_counter_batch);
 }
 
 static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
 {
-	atomic_add(i, &q->net->mem);
+	__percpu_counter_add(&q->net->mem, i, frag_percpu_counter_batch);
 }
 
 static inline void init_frag_mem_limit(struct netns_frags *nf)
 {
-	atomic_set(&nf->mem, 0);
+	percpu_counter_init(&nf->mem, 0);
 }
 
 static inline int sum_frag_mem_limit(struct netns_frags *nf)
 {
-	return atomic_read(&nf->mem);
+	return percpu_counter_sum_positive(&nf->mem);
 }
 
 #endif
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index e348c84..b825205 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -91,6 +91,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
 	local_bh_disable();
 	inet_frag_evictor(nf, f, true);
 	local_bh_enable();
+
+	percpu_counter_destroy(&nf->mem);
 }
 EXPORT_SYMBOL(inet_frags_exit_net);
 
