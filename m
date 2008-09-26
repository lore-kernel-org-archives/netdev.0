From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2 7/6] netns ct: final netns tweaks
Date: Sat, 27 Sep 2008 03:59:01 +0400
Message-ID: <20080926235901.GA10489@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net> <20080913105509.GG7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080913105509.GG7440@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add init_net checks to not remove kmem_caches twice and so on.

Refactor functions to split code which should be executed only for
init_net into one place.

ip_ct_attach and ip_ct_destroy assignments remain separate, because
they're separate stages in setup and teardown.

NOTE: NOTRACK code is in for-every-net part. It will be made per-netns
after we decidce how to do it correctly.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_core.c   |  151 +++++++++++++++++++++++-------------
 net/netfilter/nf_conntrack_expect.c |   26 +++---
 2 files changed, 114 insertions(+), 63 deletions(-)

--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1010,17 +1010,15 @@ void nf_conntrack_flush(struct net *net)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush);
 
-/* Mishearing the voices in his head, our hero wonders how he's
-   supposed to kill the mall. */
-void nf_conntrack_cleanup(struct net *net)
+static void nf_conntrack_cleanup_init_net(void)
 {
-	rcu_assign_pointer(ip_ct_attach, NULL);
-
-	/* This makes sure all current packets have passed through
-	   netfilter framework.  Roll on, two-stage module
-	   delete... */
-	synchronize_net();
+	nf_conntrack_helper_fini();
+	nf_conntrack_proto_fini();
+	kmem_cache_destroy(nf_conntrack_cachep);
+}
 
+static void nf_conntrack_cleanup_net(struct net *net)
+{
 	nf_ct_event_cache_flush(net);
 	nf_conntrack_ecache_fini(net);
  i_see_dead_people:
@@ -1033,17 +1031,31 @@ void nf_conntrack_cleanup(struct net *net)
 	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
 		schedule();
 
-	rcu_assign_pointer(nf_ct_destroy, NULL);
-
-	kmem_cache_destroy(nf_conntrack_cachep);
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
-
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
 	free_percpu(net->ct.stat);
-	nf_conntrack_helper_fini();
-	nf_conntrack_proto_fini();
+}
+
+/* Mishearing the voices in his head, our hero wonders how he's
+   supposed to kill the mall. */
+void nf_conntrack_cleanup(struct net *net)
+{
+	if (net_eq(net, &init_net))
+		rcu_assign_pointer(ip_ct_attach, NULL);
+
+	/* This makes sure all current packets have passed through
+	   netfilter framework.  Roll on, two-stage module
+	   delete... */
+	synchronize_net();
+
+	nf_conntrack_cleanup_net(net);
+
+	if (net_eq(net, &init_net)) {
+		rcu_assign_pointer(nf_ct_destroy, NULL);
+		nf_conntrack_cleanup_init_net();
+	}
 }
 
 struct hlist_head *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced)
@@ -1128,7 +1140,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
 
-int nf_conntrack_init(struct net *net)
+static int nf_conntrack_init_init_net(void)
 {
 	int max_factor = 8;
 	int ret;
@@ -1150,21 +1162,6 @@ int nf_conntrack_init(struct net *net)
 		 * entries. */
 		max_factor = 4;
 	}
-	atomic_set(&net->ct.count, 0);
-	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
-	if (!net->ct.stat)
-		goto err_stat;
-	ret = nf_conntrack_ecache_init(net);
-	if (ret < 0)
-		goto err_ecache;
-	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
-						  &net->ct.hash_vmalloc);
-	if (!net->ct.hash) {
-		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
-		goto err_hash;
-	}
-	INIT_HLIST_HEAD(&net->ct.unconfirmed);
-
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
 	printk("nf_conntrack version %s (%u buckets, %d max)\n",
@@ -1176,28 +1173,55 @@ int nf_conntrack_init(struct net *net)
 						0, 0, NULL);
 	if (!nf_conntrack_cachep) {
 		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		goto err_free_hash;
+		ret = -ENOMEM;
+		goto err_cache;
 	}
 
 	ret = nf_conntrack_proto_init();
 	if (ret < 0)
-		goto err_free_conntrack_slab;
-
-	ret = nf_conntrack_expect_init(net);
-	if (ret < 0)
-		goto out_fini_proto;
+		goto err_proto;
 
 	ret = nf_conntrack_helper_init();
 	if (ret < 0)
-		goto out_fini_expect;
+		goto err_helper;
+
+	return 0;
+
+err_helper:
+	nf_conntrack_proto_fini();
+err_proto:
+	kmem_cache_destroy(nf_conntrack_cachep);
+err_cache:
+	return ret;
+}
+
+static int nf_conntrack_init_net(struct net *net)
+{
+	int ret;
 
+	atomic_set(&net->ct.count, 0);
+	INIT_HLIST_HEAD(&net->ct.unconfirmed);
+	net->ct.stat = alloc_percpu(struct ip_conntrack_stat);
+	if (!net->ct.stat) {
+		ret = -ENOMEM;
+		goto err_stat;
+	}
+	ret = nf_conntrack_ecache_init(net);
+	if (ret < 0)
+		goto err_ecache;
+	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
+						  &net->ct.hash_vmalloc);
+	if (!net->ct.hash) {
+		ret = -ENOMEM;
+		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
+		goto err_hash;
+	}
+	ret = nf_conntrack_expect_init(net);
+	if (ret < 0)
+		goto err_expect;
 	ret = nf_conntrack_acct_init(net);
 	if (ret < 0)
-		goto out_fini_helper;
-
-	/* For use by REJECT target */
-	rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
-	rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
+		goto err_acct;
 
 	/* Set up fake conntrack:
 	    - to never be deleted, not in any hashes */
@@ -1208,17 +1232,11 @@ int nf_conntrack_init(struct net *net)
 	/*  - and look it like as a confirmed connection */
 	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
 
-	return ret;
+	return 0;
 
-out_fini_helper:
-	nf_conntrack_helper_fini();
-out_fini_expect:
+err_acct:
 	nf_conntrack_expect_fini(net);
-out_fini_proto:
-	nf_conntrack_proto_fini();
-err_free_conntrack_slab:
-	kmem_cache_destroy(nf_conntrack_cachep);
-err_free_hash:
+err_expect:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 err_hash:
@@ -1226,5 +1244,32 @@ err_hash:
 err_ecache:
 	free_percpu(net->ct.stat);
 err_stat:
-	return -ENOMEM;
+	return ret;
+}
+
+int nf_conntrack_init(struct net *net)
+{
+	int ret;
+
+	if (net_eq(net, &init_net)) {
+		ret = nf_conntrack_init_init_net();
+		if (ret < 0)
+			goto out_init_net;
+	}
+	ret = nf_conntrack_init_net(net);
+	if (ret < 0)
+		goto out_net;
+
+	if (net_eq(net, &init_net)) {
+		/* For use by REJECT target */
+		rcu_assign_pointer(ip_ct_attach, nf_conntrack_attach);
+		rcu_assign_pointer(nf_ct_destroy, destroy_conntrack);
+	}
+	return 0;
+
+out_net:
+	if (net_eq(net, &init_net))
+		nf_conntrack_cleanup_init_net();
+out_init_net:
+	return ret;
 }
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -563,12 +563,14 @@ int nf_conntrack_expect_init(struct net *net)
 {
 	int err = -ENOMEM;
 
-	if (!nf_ct_expect_hsize) {
-		nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
-		if (!nf_ct_expect_hsize)
-			nf_ct_expect_hsize = 1;
+	if (net_eq(net, &init_net)) {
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
+	if (net_eq(net, &init_net)) {
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
+	if (net_eq(net, &init_net))
+		kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
@@ -600,7 +605,8 @@ err1:
 void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	kmem_cache_destroy(nf_ct_expect_cachep);
+	if (net_eq(net, &init_net))
+		kmem_cache_destroy(nf_ct_expect_cachep);
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
