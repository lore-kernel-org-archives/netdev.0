From: kaber@trash.net
Subject: [PATCH 61/79] netfilter: nf_conntrack: use is_vmalloc_addr()
Date: Wed, 19 Jan 2011 20:15:01 +0100
Message-ID: <1295464519-21763-62-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Use is_vmalloc_addr() in nf_ct_free_hashtable() and get rid of
the vmalloc flags to indicate that a hash table has been allocated
using vmalloc().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack.h |    4 ++--
 include/net/netns/conntrack.h        |    2 --
 include/net/netns/ipv4.h             |    1 -
 net/ipv4/netfilter/nf_nat_core.c     |    6 ++----
 net/netfilter/nf_conntrack_core.c    |   26 +++++++++-----------------
 net/netfilter/nf_conntrack_expect.c  |    9 +++------
 net/netfilter/nf_conntrack_helper.c  |   10 +++-------
 7 files changed, 19 insertions(+), 39 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 2bc344c..d0d1337 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -202,9 +202,9 @@ extern void nf_ct_l3proto_module_put(unsigned short l3proto);
  * Allocate a hashtable of hlist_head (if nulls == 0),
  * or hlist_nulls_head (if nulls == 1)
  */
-extern void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls);
+extern void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls);
 
-extern void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size);
+extern void nf_ct_free_hashtable(void *hash, unsigned int size);
 
 extern struct nf_conntrack_tuple_hash *
 __nf_conntrack_find(struct net *net, u16 zone,
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index d4958d4..5cf8a8c 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -28,8 +28,6 @@ struct netns_ct {
 	struct ctl_table_header	*acct_sysctl_header;
 	struct ctl_table_header	*event_sysctl_header;
 #endif
-	int			hash_vmalloc;
-	int			expect_vmalloc;
 	char			*slabname;
 };
 #endif
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d68c3f1..e2e2ef5 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -43,7 +43,6 @@ struct netns_ipv4 {
 	struct xt_table		*nat_table;
 	struct hlist_head	*nat_bysource;
 	unsigned int		nat_htable_size;
-	int			nat_vmalloced;
 #endif
 
 	int sysctl_icmp_echo_ignore_all;
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index eb55835..6972cee 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -682,8 +682,7 @@ static int __net_init nf_nat_net_init(struct net *net)
 {
 	/* Leave them the same for the moment. */
 	net->ipv4.nat_htable_size = net->ct.htable_size;
-	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&net->ipv4.nat_htable_size,
-						       &net->ipv4.nat_vmalloced, 0);
+	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&net->ipv4.nat_htable_size, 0);
 	if (!net->ipv4.nat_bysource)
 		return -ENOMEM;
 	return 0;
@@ -705,8 +704,7 @@ static void __net_exit nf_nat_net_exit(struct net *net)
 {
 	nf_ct_iterate_cleanup(net, &clean_nat, NULL);
 	synchronize_rcu();
-	nf_ct_free_hashtable(net->ipv4.nat_bysource, net->ipv4.nat_vmalloced,
-			     net->ipv4.nat_htable_size);
+	nf_ct_free_hashtable(net->ipv4.nat_bysource, net->ipv4.nat_htable_size);
 }
 
 static struct pernet_operations nf_nat_net_ops = {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e95ac42..dc2ff2c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1202,9 +1202,9 @@ static int kill_all(struct nf_conn *i, void *data)
 	return 1;
 }
 
-void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size)
+void nf_ct_free_hashtable(void *hash, unsigned int size)
 {
-	if (vmalloced)
+	if (is_vmalloc_addr(hash))
 		vfree(hash);
 	else
 		free_pages((unsigned long)hash,
@@ -1271,8 +1271,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 		goto i_see_dead_people;
 	}
 
-	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
-			     net->ct.htable_size);
+	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
@@ -1301,21 +1300,18 @@ void nf_conntrack_cleanup(struct net *net)
 	}
 }
 
-void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls)
+void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
 {
 	struct hlist_nulls_head *hash;
 	unsigned int nr_slots, i;
 	size_t sz;
 
-	*vmalloced = 0;
-
 	BUILD_BUG_ON(sizeof(struct hlist_nulls_head) != sizeof(struct hlist_head));
 	nr_slots = *sizep = roundup(*sizep, PAGE_SIZE / sizeof(struct hlist_nulls_head));
 	sz = nr_slots * sizeof(struct hlist_nulls_head);
 	hash = (void *)__get_free_pages(GFP_KERNEL | __GFP_NOWARN | __GFP_ZERO,
 					get_order(sz));
 	if (!hash) {
-		*vmalloced = 1;
 		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
 		hash = __vmalloc(sz, GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
 				 PAGE_KERNEL);
@@ -1331,7 +1327,7 @@ EXPORT_SYMBOL_GPL(nf_ct_alloc_hashtable);
 
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 {
-	int i, bucket, vmalloced, old_vmalloced;
+	int i, bucket;
 	unsigned int hashsize, old_size;
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
@@ -1348,7 +1344,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!hashsize)
 		return -EINVAL;
 
-	hash = nf_ct_alloc_hashtable(&hashsize, &vmalloced, 1);
+	hash = nf_ct_alloc_hashtable(&hashsize, 1);
 	if (!hash)
 		return -ENOMEM;
 
@@ -1370,15 +1366,13 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 		}
 	}
 	old_size = init_net.ct.htable_size;
-	old_vmalloced = init_net.ct.hash_vmalloc;
 	old_hash = init_net.ct.hash;
 
 	init_net.ct.htable_size = nf_conntrack_htable_size = hashsize;
-	init_net.ct.hash_vmalloc = vmalloced;
 	init_net.ct.hash = hash;
 	spin_unlock_bh(&nf_conntrack_lock);
 
-	nf_ct_free_hashtable(old_hash, old_vmalloced, old_size);
+	nf_ct_free_hashtable(old_hash, old_size);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
@@ -1491,8 +1485,7 @@ static int nf_conntrack_init_net(struct net *net)
 	}
 
 	net->ct.htable_size = nf_conntrack_htable_size;
-	net->ct.hash = nf_ct_alloc_hashtable(&net->ct.htable_size,
-					     &net->ct.hash_vmalloc, 1);
+	net->ct.hash = nf_ct_alloc_hashtable(&net->ct.htable_size, 1);
 	if (!net->ct.hash) {
 		ret = -ENOMEM;
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
@@ -1515,8 +1508,7 @@ err_ecache:
 err_acct:
 	nf_conntrack_expect_fini(net);
 err_expect:
-	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
-			     net->ct.htable_size);
+	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 err_hash:
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 err_cache:
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4a9ed23..cd1e8e0 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -639,8 +639,7 @@ int nf_conntrack_expect_init(struct net *net)
 	}
 
 	net->ct.expect_count = 0;
-	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
-						  &net->ct.expect_vmalloc, 0);
+	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize, 0);
 	if (net->ct.expect_hash == NULL)
 		goto err1;
 
@@ -662,8 +661,7 @@ err3:
 	if (net_eq(net, &init_net))
 		kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
-	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
-			     nf_ct_expect_hsize);
+	nf_ct_free_hashtable(net->ct.expect_hash, nf_ct_expect_hsize);
 err1:
 	return err;
 }
@@ -675,6 +673,5 @@ void nf_conntrack_expect_fini(struct net *net)
 		rcu_barrier(); /* Wait for call_rcu() before destroy */
 		kmem_cache_destroy(nf_ct_expect_cachep);
 	}
-	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
-			     nf_ct_expect_hsize);
+	nf_ct_free_hashtable(net->ct.expect_hash, nf_ct_expect_hsize);
 }
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 767bbe9..1bdfea3 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -33,7 +33,6 @@ static DEFINE_MUTEX(nf_ct_helper_mutex);
 static struct hlist_head *nf_ct_helper_hash __read_mostly;
 static unsigned int nf_ct_helper_hsize __read_mostly;
 static unsigned int nf_ct_helper_count __read_mostly;
-static int nf_ct_helper_vmalloc;
 
 
 /* Stupid hash, but collision free for the default registrations of the
@@ -267,8 +266,7 @@ int nf_conntrack_helper_init(void)
 	int err;
 
 	nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
-	nf_ct_helper_hash = nf_ct_alloc_hashtable(&nf_ct_helper_hsize,
-						  &nf_ct_helper_vmalloc, 0);
+	nf_ct_helper_hash = nf_ct_alloc_hashtable(&nf_ct_helper_hsize, 0);
 	if (!nf_ct_helper_hash)
 		return -ENOMEM;
 
@@ -279,14 +277,12 @@ int nf_conntrack_helper_init(void)
 	return 0;
 
 err1:
-	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_vmalloc,
-			     nf_ct_helper_hsize);
+	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
 	return err;
 }
 
 void nf_conntrack_helper_fini(void)
 {
 	nf_ct_extend_unregister(&helper_extend);
-	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_vmalloc,
-			     nf_ct_helper_hsize);
+	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
 }
-- 
1.7.2.3

