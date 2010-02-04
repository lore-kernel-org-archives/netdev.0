From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Thu, 04 Feb 2010 14:37:30 +0100
Message-ID: <4B6ACD9A.1090905@trash.net>
References: <1265108690.2861.118.camel@tonnant>	 <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>	 <4B6967BC.600@trash.net> <1265222289.2861.290.camel@tonnant>	 <20100203190948.GA5182@x200> <1265226227.2861.302.camel@tonnant>	 <4B6ABCB8.4080904@trash.net>	 <b6fcc0a1002040427n221da433n755350b4a41bbf9b@mail.gmail.com>	 <4B6ABDEF.8090005@trash.net>	 <b6fcc0a1002040435t150aa7axf2dc0b139ed8f258@mail.gmail.com>	 <4B6AC5DC.60301@trash.net> <1265289486.2861.436.camel@tonnant>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080905050007030700020908"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265289486.2861.436.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080905050007030700020908
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Jon Masters wrote:
> On Thu, 2010-02-04 at 14:04 +0100, Patrick McHardy wrote:
>> In any case, we need a fix for this suitable for 2.6.33. If
>> you don't like using the pointer, please send a patch to add
>> an id to the network namespaces.
> 
> Right. I think the quick solution is fine for 2.6.33. So that makes the
> hashtable non-resize patch, the crash fix, and the cachep bits. I will
> try to get involved and help you out with the per-ns hashtable clean
> rather than just being a whiner :)

This is the patch I'm going to commit unless unless there are further
objections. Its Eric's patch with a change on top to allocate a unique
name for the slab.

> Thanks a bunch! Fedora kernels have already been built with this fix,
> since it will allow us to close a fair number of "KVM goes boom" bugs.

Thanks as well for your help.

--------------080905050007030700020908
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index ba1ba0c..aed23b6 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -11,6 +11,7 @@ struct nf_conntrack_ecache;
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
+	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
 	struct hlist_head	*expect_hash;
 	struct hlist_nulls_head	unconfirmed;
@@ -28,5 +29,6 @@ struct netns_ct {
 #endif
 	int			hash_vmalloc;
 	int			expect_vmalloc;
+	char			*slabname;
 };
 #endif
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 37e2b88..7ac027a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -63,8 +63,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
-static struct kmem_cache *nf_conntrack_cachep __read_mostly;
-
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
 
@@ -572,7 +570,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	 * Do not use kmem_cache_zalloc(), as this cache uses
 	 * SLAB_DESTROY_BY_RCU.
 	 */
-	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
+	ct = kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
 		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
 		atomic_dec(&net->ct.count);
@@ -611,7 +609,7 @@ void nf_conntrack_free(struct nf_conn *ct)
 	nf_ct_ext_destroy(ct);
 	atomic_dec(&net->ct.count);
 	nf_ct_ext_free(ct);
-	kmem_cache_free(nf_conntrack_cachep, ct);
+	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_free);
 
@@ -1119,7 +1117,6 @@ static void nf_conntrack_cleanup_init_net(void)
 
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
-	kmem_cache_destroy(nf_conntrack_cachep);
 }
 
 static void nf_conntrack_cleanup_net(struct net *net)
@@ -1137,6 +1134,8 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
+	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
+	kfree(net->ct.slabname);
 	free_percpu(net->ct.stat);
 }
 
@@ -1272,15 +1271,6 @@ static int nf_conntrack_init_init_net(void)
 	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
 	       nf_conntrack_max);
 
-	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
-						sizeof(struct nf_conn),
-						0, SLAB_DESTROY_BY_RCU, NULL);
-	if (!nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		ret = -ENOMEM;
-		goto err_cache;
-	}
-
 	ret = nf_conntrack_proto_init();
 	if (ret < 0)
 		goto err_proto;
@@ -1302,8 +1292,6 @@ static int nf_conntrack_init_init_net(void)
 err_helper:
 	nf_conntrack_proto_fini();
 err_proto:
-	kmem_cache_destroy(nf_conntrack_cachep);
-err_cache:
 	return ret;
 }
 
@@ -1325,6 +1313,19 @@ static int nf_conntrack_init_net(struct net *net)
 		ret = -ENOMEM;
 		goto err_stat;
 	}
+
+	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
+	if (!net->ct.slabname)
+		goto err_slabname;
+
+	net->ct.nf_conntrack_cachep = kmem_cache_create(net->ct.slabname,
+							sizeof(struct nf_conn), 0,
+							SLAB_DESTROY_BY_RCU, NULL);
+	if (!net->ct.nf_conntrack_cachep) {
+		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
+		ret = -ENOMEM;
+		goto err_cache;
+	}
 	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
@@ -1352,6 +1353,10 @@ err_expect:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 err_hash:
+	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
+err_cache:
+	kfree(net->ct.slabname);
+err_slabname:
 	free_percpu(net->ct.stat);
 err_stat:
 	return ret;

--------------080905050007030700020908--
