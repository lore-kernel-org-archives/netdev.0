From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/36] netfilter: conntrack: move generation seqcnt out of netns_ct
Date: Mon,  9 May 2016 20:46:22 +0200
Message-ID: <1462819614-5402-5-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We only allow rehash in init namespace, so we only use
init_ns.generation.  And even if we would allow it, it makes no sense
as the conntrack locks are global; any ongoing rehash prevents insert/
delete.

So make this private to nf_conntrack_core instead.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h     |  1 -
 net/netfilter/nf_conntrack_core.c | 20 +++++++++++---------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 723b61c..b052785 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -94,7 +94,6 @@ struct netns_ct {
 	int			sysctl_checksum;
 
 	unsigned int		htable_size;
-	seqcount_t		generation;
 	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2fd6074..a53c009 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -69,6 +69,7 @@ __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 
 static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
+static __read_mostly seqcount_t nf_conntrack_generation;
 static __read_mostly bool nf_conntrack_locks_all;
 
 void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
@@ -107,7 +108,7 @@ static bool nf_conntrack_double_lock(struct net *net, unsigned int h1,
 		spin_lock_nested(&nf_conntrack_locks[h1],
 				 SINGLE_DEPTH_NESTING);
 	}
-	if (read_seqcount_retry(&net->ct.generation, sequence)) {
+	if (read_seqcount_retry(&nf_conntrack_generation, sequence)) {
 		nf_conntrack_double_unlock(h1, h2);
 		return true;
 	}
@@ -393,7 +394,7 @@ static void nf_ct_delete_from_lists(struct nf_conn *ct)
 
 	local_bh_disable();
 	do {
-		sequence = read_seqcount_begin(&net->ct.generation);
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
 		hash = hash_conntrack(net,
 				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 		reply_hash = hash_conntrack(net,
@@ -560,7 +561,7 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 
 	local_bh_disable();
 	do {
-		sequence = read_seqcount_begin(&net->ct.generation);
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
 		hash = hash_conntrack(net,
 				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 		reply_hash = hash_conntrack(net,
@@ -628,7 +629,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	local_bh_disable();
 
 	do {
-		sequence = read_seqcount_begin(&net->ct.generation);
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
 		/* reuse the hash saved before */
 		hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
 		hash = hash_bucket(hash, net);
@@ -771,12 +772,12 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 
 	local_bh_disable();
 restart:
-	sequence = read_seqcount_begin(&net->ct.generation);
+	sequence = read_seqcount_begin(&nf_conntrack_generation);
 	hash = hash_bucket(_hash, net);
 	for (; i < net->ct.htable_size; i++) {
 		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
 		nf_conntrack_lock(lockp);
-		if (read_seqcount_retry(&net->ct.generation, sequence)) {
+		if (read_seqcount_retry(&nf_conntrack_generation, sequence)) {
 			spin_unlock(lockp);
 			goto restart;
 		}
@@ -1607,7 +1608,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 
 	local_bh_disable();
 	nf_conntrack_all_lock();
-	write_seqcount_begin(&init_net.ct.generation);
+	write_seqcount_begin(&nf_conntrack_generation);
 
 	/* Lookups in the old hash might happen in parallel, which means we
 	 * might get false negatives during connection lookup. New connections
@@ -1631,7 +1632,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
 	init_net.ct.hash = hash;
 
-	write_seqcount_end(&init_net.ct.generation);
+	write_seqcount_end(&nf_conntrack_generation);
 	nf_conntrack_all_unlock();
 	local_bh_enable();
 
@@ -1657,6 +1658,8 @@ int nf_conntrack_init_start(void)
 	int max_factor = 8;
 	int i, ret, cpu;
 
+	seqcount_init(&nf_conntrack_generation);
+
 	for (i = 0; i < CONNTRACK_LOCKS; i++)
 		spin_lock_init(&nf_conntrack_locks[i]);
 
@@ -1783,7 +1786,6 @@ int nf_conntrack_init_net(struct net *net)
 	int cpu;
 
 	atomic_set(&net->ct.count, 0);
-	seqcount_init(&net->ct.generation);
 
 	net->ct.pcpu_lists = alloc_percpu(struct ct_pcpu);
 	if (!net->ct.pcpu_lists)
-- 
2.1.4

