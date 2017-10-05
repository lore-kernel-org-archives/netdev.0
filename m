From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] inet: frags: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:52:33 -0700
Message-ID: <20171005005233.GA23612@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Alexander Aring <alex.aring@gmail.com>
Cc: Stefan Schmidt <stefan@osg.samsung.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Florian Westphal <fw@strlen.de>
Cc: linux-wpan@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: coreteam@netfilter.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 include/net/inet_frag.h                 | 2 +-
 net/ieee802154/6lowpan/reassembly.c     | 5 +++--
 net/ipv4/inet_fragment.c                | 4 ++--
 net/ipv4/ip_fragment.c                  | 5 +++--
 net/ipv6/netfilter/nf_conntrack_reasm.c | 5 +++--
 net/ipv6/reassembly.c                   | 5 +++--
 6 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index fc59e0775e00..c695807ca707 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -95,7 +95,7 @@ struct inet_frags {
 	void			(*constructor)(struct inet_frag_queue *q,
 					       const void *arg);
 	void			(*destructor)(struct inet_frag_queue *);
-	void			(*frag_expire)(unsigned long data);
+	void			(*frag_expire)(struct timer_list *t);
 	struct kmem_cache	*frags_cachep;
 	const char		*frags_cache_name;
 };
diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lowpan/reassembly.c
index f85b08baff16..85bf86ad6b18 100644
--- a/net/ieee802154/6lowpan/reassembly.c
+++ b/net/ieee802154/6lowpan/reassembly.c
@@ -80,12 +80,13 @@ static void lowpan_frag_init(struct inet_frag_queue *q, const void *a)
 	fq->daddr = *arg->dst;
 }
 
-static void lowpan_frag_expire(unsigned long data)
+static void lowpan_frag_expire(struct timer_list *t)
 {
+	struct inet_frag_queue *frag = from_timer(frag, t, timer);
 	struct frag_queue *fq;
 	struct net *net;
 
-	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
+	fq = container_of(frag, struct frag_queue, q);
 	net = container_of(fq->q.net, struct net, ieee802154_lowpan.frags);
 
 	spin_lock(&fq->q.lock);
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index af74d0433453..7f3ef5c287a1 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -147,7 +147,7 @@ inet_evict_bucket(struct inet_frags *f, struct inet_frag_bucket *hb)
 	spin_unlock(&hb->chain_lock);
 
 	hlist_for_each_entry_safe(fq, n, &expired, list_evictor)
-		f->frag_expire((unsigned long) fq);
+		f->frag_expire(&fq->timer);
 
 	return evicted;
 }
@@ -366,7 +366,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	f->constructor(q, arg);
 	add_frag_mem_limit(nf, f->qsize);
 
-	setup_timer(&q->timer, f->frag_expire, (unsigned long)q);
+	timer_setup(&q->timer, f->frag_expire, 0);
 	spin_lock_init(&q->lock);
 	refcount_set(&q->refcnt, 1);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 46408c220d9d..9215654a401f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -190,12 +190,13 @@ static bool frag_expire_skip_icmp(u32 user)
 /*
  * Oops, a fragment queue timed out.  Kill it and send an ICMP reply.
  */
-static void ip_expire(unsigned long arg)
+static void ip_expire(struct timer_list *t)
 {
+	struct inet_frag_queue *frag = from_timer(frag, t, timer);
 	struct ipq *qp;
 	struct net *net;
 
-	qp = container_of((struct inet_frag_queue *) arg, struct ipq, q);
+	qp = container_of(frag, struct ipq, q);
 	net = container_of(qp->q.net, struct net, ipv4.frags);
 
 	rcu_read_lock();
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index b263bf3a19f7..977d8900cfd1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -169,12 +169,13 @@ static unsigned int nf_hashfn(const struct inet_frag_queue *q)
 	return nf_hash_frag(nq->id, &nq->saddr, &nq->daddr);
 }
 
-static void nf_ct_frag6_expire(unsigned long data)
+static void nf_ct_frag6_expire(struct timer_list *t)
 {
+	struct inet_frag_queue *frag = from_timer(frag, t, timer);
 	struct frag_queue *fq;
 	struct net *net;
 
-	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
+	fq = container_of(frag, struct frag_queue, q);
 	net = container_of(fq->q.net, struct net, nf_frag.frags);
 
 	ip6_expire_frag_queue(net, fq, &nf_frags);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 846012eae526..afbc000ad4f2 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -170,12 +170,13 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 }
 EXPORT_SYMBOL(ip6_expire_frag_queue);
 
-static void ip6_frag_expire(unsigned long data)
+static void ip6_frag_expire(struct timer_list *t)
 {
+	struct inet_frag_queue *frag = from_timer(frag, t, timer);
 	struct frag_queue *fq;
 	struct net *net;
 
-	fq = container_of((struct inet_frag_queue *)data, struct frag_queue, q);
+	fq = container_of(frag, struct frag_queue, q);
 	net = container_of(fq->q.net, struct net, ipv6.frags);
 
 	ip6_expire_frag_queue(net, fq, &ip6_frags);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
