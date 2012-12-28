From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 02/19] netfilter: expect: move initial codes out of pernet_operations
Date: Fri, 28 Dec 2012 10:36:28 +0800
Message-ID: <1356662206-2260-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, canqunzhang@gmail.com, kaber@trash.net,
	pablo@netfilter.org, ebiederm@xmission.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36421 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753006Ab2L1Cir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 21:38:47 -0500
In-Reply-To: <1356662206-2260-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the global initial codes to the module_init/exit context.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_expect.h |  7 ++--
 net/netfilter/nf_conntrack_core.c           | 14 ++++++--
 net/netfilter/nf_conntrack_expect.c         | 52 ++++++++++++++---------------
 3 files changed, 41 insertions(+), 32 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index cc13f37..cbbae76 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -69,8 +69,11 @@ struct nf_conntrack_expect_policy {
 
 #define NF_CT_EXPECT_CLASS_DEFAULT	0
 
-int nf_conntrack_expect_init(struct net *net);
-void nf_conntrack_expect_fini(struct net *net);
+int nf_conntrack_expect_pernet_init(struct net *net);
+void nf_conntrack_expect_pernet_fini(struct net *net);
+
+int nf_conntrack_expect_init(void);
+void nf_conntrack_expect_fini(void);
 
 struct nf_conntrack_expect *
 __nf_ct_expect_find(struct net *net, u16 zone,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ffb2463..96b281f 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1363,7 +1363,7 @@ void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_tstamp_fini(net);
 	nf_conntrack_acct_fini(net);
-	nf_conntrack_expect_fini(net);
+	nf_conntrack_expect_pernet_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 	kfree(net->ct.slabname);
 	free_percpu(net->ct.stat);
@@ -1378,6 +1378,7 @@ void nf_conntrack_cleanup_end(void)
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
+	nf_conntrack_expect_fini();
 }
 
 void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls)
@@ -1497,6 +1498,11 @@ int nf_conntrack_init_start(void)
 	printk(KERN_INFO "nf_conntrack version %s (%u buckets, %d max)\n",
 	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
 	       nf_conntrack_max);
+
+	ret = nf_conntrack_expect_init();
+	if (ret < 0)
+		goto err_expect;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1514,7 +1520,9 @@ int nf_conntrack_init_start(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
+	nf_conntrack_expect_fini();
 #endif
+err_expect:
 	return ret;
 }
 
@@ -1559,7 +1567,7 @@ int nf_conntrack_init_net(struct net *net)
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
 		goto err_hash;
 	}
-	ret = nf_conntrack_expect_init(net);
+	ret = nf_conntrack_expect_pernet_init(net);
 	if (ret < 0)
 		goto err_expect;
 	ret = nf_conntrack_acct_init(net);
@@ -1592,7 +1600,7 @@ err_ecache:
 err_tstamp:
 	nf_conntrack_acct_fini(net);
 err_acct:
-	nf_conntrack_expect_fini(net);
+	nf_conntrack_expect_pernet_fini(net);
 err_expect:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 err_hash:
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 527651a..0557acc 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -587,53 +587,51 @@ static void exp_proc_remove(struct net *net)
 
 module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0400);
 
-int nf_conntrack_expect_init(struct net *net)
+int nf_conntrack_expect_pernet_init(struct net *net)
 {
 	int err = -ENOMEM;
 
-	if (net_eq(net, &init_net)) {
-		if (!nf_ct_expect_hsize) {
-			nf_ct_expect_hsize = net->ct.htable_size / 256;
-			if (!nf_ct_expect_hsize)
-				nf_ct_expect_hsize = 1;
-		}
-		nf_ct_expect_max = nf_ct_expect_hsize * 4;
-	}
-
 	net->ct.expect_count = 0;
 	net->ct.expect_hash = nf_ct_alloc_hashtable(&nf_ct_expect_hsize, 0);
 	if (net->ct.expect_hash == NULL)
 		goto err1;
 
-	if (net_eq(net, &init_net)) {
-		nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
-					sizeof(struct nf_conntrack_expect),
-					0, 0, NULL);
-		if (!nf_ct_expect_cachep)
-			goto err2;
-	}
-
 	err = exp_proc_init(net);
 	if (err < 0)
-		goto err3;
+		goto err2;
 
 	return 0;
 
-err3:
-	if (net_eq(net, &init_net))
-		kmem_cache_destroy(nf_ct_expect_cachep);
 err2:
 	nf_ct_free_hashtable(net->ct.expect_hash, nf_ct_expect_hsize);
 err1:
 	return err;
 }
 
-void nf_conntrack_expect_fini(struct net *net)
+void nf_conntrack_expect_pernet_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	if (net_eq(net, &init_net)) {
-		rcu_barrier(); /* Wait for call_rcu() before destroy */
-		kmem_cache_destroy(nf_ct_expect_cachep);
-	}
 	nf_ct_free_hashtable(net->ct.expect_hash, nf_ct_expect_hsize);
 }
+
+int nf_conntrack_expect_init(void)
+{
+	if (!nf_ct_expect_hsize) {
+		nf_ct_expect_hsize = nf_conntrack_htable_size / 256;
+		if (!nf_ct_expect_hsize)
+			nf_ct_expect_hsize = 1;
+	}
+	nf_ct_expect_max = nf_ct_expect_hsize * 4;
+	nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
+				sizeof(struct nf_conntrack_expect),
+				0, 0, NULL);
+	if (!nf_ct_expect_cachep)
+		return -ENOMEM;
+	return 0;
+}
+
+void nf_conntrack_expect_fini(void)
+{
+	rcu_barrier(); /* Wait for call_rcu() before destroy */
+	kmem_cache_destroy(nf_ct_expect_cachep);
+}
-- 
1.7.11.7
