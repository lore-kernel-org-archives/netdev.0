From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/36] netfilter: conntrack: use single slab cache
Date: Mon,  9 May 2016 20:46:54 +0200
Message-ID: <1462819614-5402-37-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

An earlier patch changed lookup side to also net_eq() namespaces after
obtaining a reference on the conntrack, so a single kmemcache can be used.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h     |  2 --
 net/netfilter/nf_conntrack_core.c | 36 ++++++++++++++----------------------
 2 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 1e751bf..38b1a80 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -84,7 +84,6 @@ struct netns_ct {
 	struct ctl_table_header	*event_sysctl_header;
 	struct ctl_table_header	*helper_sysctl_header;
 #endif
-	char			*slabname;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
 	int			sysctl_events;
 	int			sysctl_acct;
@@ -93,7 +92,6 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 
-	struct kmem_cache	*nf_conntrack_cachep;
 	struct ct_pcpu __percpu *pcpu_lists;
 	struct ip_conntrack_stat __percpu *stat;
 	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f58a704..0cd2936 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -72,6 +72,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 struct hlist_nulls_head *nf_conntrack_hash __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_hash);
 
+static __read_mostly struct kmem_cache *nf_conntrack_cachep;
 static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
 static __read_mostly seqcount_t nf_conntrack_generation;
 static __read_mostly bool nf_conntrack_locks_all;
@@ -910,7 +911,7 @@ __nf_conntrack_alloc(struct net *net,
 	 * Do not use kmem_cache_zalloc(), as this cache uses
 	 * SLAB_DESTROY_BY_RCU.
 	 */
-	ct = kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
+	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL)
 		goto out;
 
@@ -937,7 +938,7 @@ __nf_conntrack_alloc(struct net *net,
 	atomic_set(&ct->ct_general.use, 0);
 	return ct;
 out_free:
-	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
+	kmem_cache_free(nf_conntrack_cachep, ct);
 out:
 	atomic_dec(&net->ct.count);
 	return ERR_PTR(-ENOMEM);
@@ -964,7 +965,7 @@ void nf_conntrack_free(struct nf_conn *ct)
 
 	nf_ct_ext_destroy(ct);
 	nf_ct_ext_free(ct);
-	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
+	kmem_cache_free(nf_conntrack_cachep, ct);
 	smp_mb__before_atomic();
 	atomic_dec(&net->ct.count);
 }
@@ -1587,8 +1588,6 @@ i_see_dead_people:
 		nf_conntrack_tstamp_pernet_fini(net);
 		nf_conntrack_acct_pernet_fini(net);
 		nf_conntrack_expect_pernet_fini(net);
-		kmem_cache_destroy(net->ct.nf_conntrack_cachep);
-		kfree(net->ct.slabname);
 		free_percpu(net->ct.stat);
 		free_percpu(net->ct.pcpu_lists);
 	}
@@ -1693,7 +1692,8 @@ EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
 int nf_conntrack_init_start(void)
 {
 	int max_factor = 8;
-	int i, ret, cpu;
+	int ret = -ENOMEM;
+	int i, cpu;
 
 	seqcount_init(&nf_conntrack_generation);
 
@@ -1729,6 +1729,12 @@ int nf_conntrack_init_start(void)
 
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
+	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
+						sizeof(struct nf_conn), 0,
+						SLAB_DESTROY_BY_RCU, NULL);
+	if (!nf_conntrack_cachep)
+		goto err_cachep;
+
 	printk(KERN_INFO "nf_conntrack version %s (%u buckets, %d max)\n",
 	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
 	       nf_conntrack_max);
@@ -1805,6 +1811,8 @@ err_tstamp:
 err_acct:
 	nf_conntrack_expect_fini();
 err_expect:
+	kmem_cache_destroy(nf_conntrack_cachep);
+err_cachep:
 	nf_ct_free_hashtable(nf_conntrack_hash, nf_conntrack_htable_size);
 	return ret;
 }
@@ -1846,18 +1854,6 @@ int nf_conntrack_init_net(struct net *net)
 	if (!net->ct.stat)
 		goto err_pcpu_lists;
 
-	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
-	if (!net->ct.slabname)
-		goto err_slabname;
-
-	net->ct.nf_conntrack_cachep = kmem_cache_create(net->ct.slabname,
-							sizeof(struct nf_conn), 0,
-							SLAB_DESTROY_BY_RCU, NULL);
-	if (!net->ct.nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		goto err_cache;
-	}
-
 	ret = nf_conntrack_expect_pernet_init(net);
 	if (ret < 0)
 		goto err_expect;
@@ -1889,10 +1885,6 @@ err_tstamp:
 err_acct:
 	nf_conntrack_expect_pernet_fini(net);
 err_expect:
-	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
-err_cache:
-	kfree(net->ct.slabname);
-err_slabname:
 	free_percpu(net->ct.stat);
 err_pcpu_lists:
 	free_percpu(net->ct.pcpu_lists);
-- 
2.1.4

