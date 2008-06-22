From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 12/25] netns ct: actualy enable in netns
Date: Sun, 22 Jun 2008 05:11:08 +0400
Message-ID: <20080622011108.GM5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Known to not work/broken:
1) event cache -- double free if netns flushes event cache, not netns-ready,
   haven't looked into this.
2) NOTRACK -- amazing circular dependencies and compile breakages if nf_conn
   is embedded into netns_ct.

   This is easy excuse, real excuse is from where to grab netns that early.
   and since we wait until untracked refcount drops to zero it should be per-netns
   otherwise one netns which uses NOTRACK can prevent other from stopping.
3) conntrack statistics -- counted as a whole.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_core.c   |  117 ++++++++++++++++++++----------------
 net/netfilter/nf_conntrack_expect.c |   35 ++++++----
 2 files changed, 86 insertions(+), 66 deletions(-)

--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1006,16 +1006,16 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
    supposed to kill the mall. */
 void nf_conntrack_cleanup(struct net *net)
 {
-	if (net != &init_net)
-		return;
-	rcu_assign_pointer(ip_ct_attach, NULL);
+	if (net == &init_net)
+		rcu_assign_pointer(ip_ct_attach, NULL);
 
 	/* This makes sure all current packets have passed through
 	   netfilter framework.  Roll on, two-stage module
 	   delete... */
 	synchronize_net();
 
-	nf_ct_event_cache_flush();
+	if (net == &init_net)
+		nf_ct_event_cache_flush();
  i_see_dead_people:
 	nf_conntrack_flush(net);
 	if (atomic_read(&net->ct.count) != 0) {
@@ -1026,14 +1026,18 @@ void nf_conntrack_cleanup(struct net *net)
 	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
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
 
@@ -1124,25 +1128,28 @@ int nf_conntrack_init(struct net *net)
 	int max_factor = 8;
 	int ret;
 
-	if (net != &init_net)
-		return 0;
-
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
 	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
@@ -1153,50 +1160,56 @@ int nf_conntrack_init(struct net *net)
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
 
-	/* Set up fake conntrack:
-	    - to never be deleted, not in any hashes */
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
-	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+		/* Set up fake conntrack:
+		   - to never be deleted, not in any hashes */
+		atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
+		/*  - and look it like as a confirmed connection */
+		set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+	}
 
 	return ret;
 
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
@@ -560,12 +560,14 @@ int nf_conntrack_expect_init(struct net *net)
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
@@ -573,20 +575,23 @@ int nf_conntrack_expect_init(struct net *net)
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
 
-	err = exp_proc_init();
-	if (err < 0)
-		goto err3;
+		err = exp_proc_init();
+		if (err < 0)
+			goto err3;
+	}
 
 	return 0;
 
 err3:
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net == &init_net)
+		kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
@@ -596,8 +601,10 @@ err1:
 
 void nf_conntrack_expect_fini(struct net *net)
 {
-	exp_proc_remove();
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net == &init_net) {
+		exp_proc_remove();
+		kmem_cache_destroy(nf_ct_expect_cachep);
+	}
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
-- 
1.5.4.5


