From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 22/31] netns ct: final netns tweaks
Date: Mon, 21 Jul 2008 20:51:57 +0400
Message-ID: <20080721165157.GH13390@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sprinkle init_net checks to create kmem_caches once and so on.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_core.c   |   99 +++++++++++++++++++++---------------
 net/netfilter/nf_conntrack_expect.c |   26 +++++----
 2 files changed, 74 insertions(+), 51 deletions(-)

--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1002,7 +1002,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
    supposed to kill the mall. */
 void nf_conntrack_cleanup(struct net *net)
 {
-	rcu_assign_pointer(ip_ct_attach, NULL);
+	if (net == &init_net)
+		rcu_assign_pointer(ip_ct_attach, NULL);
 
 	/* This makes sure all current packets have passed through
 	   netfilter framework.  Roll on, two-stage module
@@ -1021,14 +1022,18 @@ void nf_conntrack_cleanup(struct net *net)
 	while (atomic_read(&net->ct.untracked.ct_general.use) > 1)
 		schedule();
 
-	rcu_assign_pointer(nf_ct_destroy, NULL);
+	if (net == &init_net) {
+		rcu_assign_pointer(nf_ct_destroy, NULL);
 
-	kmem_cache_destroy(nf_conntrack_cachep);
+		kmem_cache_destroy(nf_conntrack_cachep);
+	}
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 
-	nf_conntrack_proto_fini();
-	nf_conntrack_helper_fini();
+	if (net == &init_net) {
+		nf_conntrack_proto_fini();
+		nf_conntrack_helper_fini();
+	}
 	nf_conntrack_expect_fini(net);
 }
 
@@ -1119,22 +1124,28 @@ int nf_conntrack_init(struct net *net)
 	int max_factor = 8;
 	int ret;
 
-	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
-	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
-	if (!nf_conntrack_htable_size) {
-		nf_conntrack_htable_size
-			= (((num_physpages << PAGE_SHIFT) / 16384)
-			   / sizeof(struct hlist_head));
-		if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
-			nf_conntrack_htable_size = 16384;
-		if (nf_conntrack_htable_size < 32)
-			nf_conntrack_htable_size = 32;
-
-		/* Use a max. factor of four by default to get the same max as
-		 * with the old struct list_heads. When a table size is given
-		 * we use the old value of 8 to avoid reducing the max.
-		 * entries. */
-		max_factor = 4;
+	if (net == &init_net) {
+		/*
+		 * Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
+		 * machine has 512 buckets. >= 1GB machines have 16384 buckets.
+		 */
+		if (!nf_conntrack_htable_size) {
+			nf_conntrack_htable_size
+				= (((num_physpages << PAGE_SHIFT) / 16384)
+						/ sizeof(struct hlist_head));
+			if (num_physpages > (1024 * 1024 * 1024 / PAGE_SIZE))
+				nf_conntrack_htable_size = 16384;
+			if (nf_conntrack_htable_size < 32)
+				nf_conntrack_htable_size = 32;
+
+			/*
+			 * Use a max. factor of four by default to get the same
+			 * max as with the old struct list_heads. When a table
+			 * size is given we use the old value of 8 to avoid
+			 * reducing the max. entries.
+			 */
+			max_factor = 4;
+		}
 	}
 	atomic_set(&net->ct.count, 0);
 	ret = nf_conntrack_ecache_init(net);
@@ -1148,35 +1159,39 @@ int nf_conntrack_init(struct net *net)
 	}
 	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
-	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
+	if (net == &init_net) {
+		nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
-	printk("nf_conntrack version %s (%u buckets, %d max)\n",
-	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
-	       nf_conntrack_max);
+		printk("nf_conntrack version %s (%u buckets, %d max)\n",
+			NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
+			nf_conntrack_max);
 
-	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
+		nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
 						0, 0, NULL);
-	if (!nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		goto err_free_hash;
-	}
+		if (!nf_conntrack_cachep) {
+			printk(KERN_ERR "Unable to create nf_conn slab cache\n");
+			goto err_free_hash;
+		}
 
-	ret = nf_conntrack_proto_init();
-	if (ret < 0)
-		goto err_free_conntrack_slab;
+		ret = nf_conntrack_proto_init();
+		if (ret < 0)
+			goto err_free_conntrack_slab;
+	}
 
 	ret = nf_conntrack_expect_init(net);
 	if (ret < 0)
 		goto out_fini_proto;
 
-	ret = nf_conntrack_helper_init();
-	if (ret < 0)
-		goto out_fini_expect;
+	if (net == &init_net) {
+		ret = nf_conntrack_helper_init();
+		if (ret < 0)
+			goto out_fini_expect;
 
-	/* For use by REJECT target */
-	rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
-	rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
+		/* For use by REJECT target */
+		rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
+		rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
+	}
 
 	/* Set up fake conntrack:
 	    - to never be deleted, not in any hashes */
@@ -1192,9 +1207,11 @@ int nf_conntrack_init(struct net *net)
 out_fini_expect:
 	nf_conntrack_expect_fini(net);
 out_fini_proto:
-	nf_conntrack_proto_fini();
+	if (net == &init_net)
+		nf_conntrack_proto_fini();
 err_free_conntrack_slab:
-	kmem_cache_destroy(nf_conntrack_cachep);
+	if (net == &init_net)
+		kmem_cache_destroy(nf_conntrack_cachep);
 err_free_hash:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -563,12 +563,14 @@ int nf_conntrack_expect_init(struct net *net)
 {
 	int err = -ENOMEM;
 
-	if (!nf_ct_expect_hsize) {
-		nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
-		if (!nf_ct_expect_hsize)
-			nf_ct_expect_hsize = 1;
+	if (net == &init_net) {
+		if (!nf_ct_expect_hsize) {
+			nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
+			if (!nf_ct_expect_hsize)
+				nf_ct_expect_hsize = 1;
+		}
+		nf_ct_expect_max = nf_ct_expect_hsize * 4;
 	}
-	nf_ct_expect_max = nf_ct_expect_hsize * 4;
 
 	net->ct.expect_count = 0;
 	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize,
@@ -576,11 +578,13 @@ int nf_conntrack_expect_init(struct net *net)
 	if (net->ct.expect_hash == NULL)
 		goto err1;
 
-	nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
+	if (net == &init_net) {
+		nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
 					sizeof(struct nf_conntrack_expect),
 					0, 0, NULL);
-	if (!nf_ct_expect_cachep)
-		goto err2;
+		if (!nf_ct_expect_cachep)
+			goto err2;
+	}
 
 	err = exp_proc_init(net);
 	if (err < 0)
@@ -589,7 +593,8 @@ int nf_conntrack_expect_init(struct net *net)
 	return 0;
 
 err3:
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net == &init_net)
+		kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
@@ -600,7 +605,8 @@ err1:
 void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net == &init_net)
+		kmem_cache_destroy(nf_ct_expect_cachep);
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
-- 
1.5.4.5


