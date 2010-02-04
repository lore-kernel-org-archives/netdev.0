From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Thu, 04 Feb 2010 15:00:44 +0100
Message-ID: <4B6AD30C.8050107@trash.net>
References: <1264813832.2793.446.camel@tonnant>	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>	 <1264834704.2919.3.camel@edumazet-laptop>	 <1265016745.7499.144.camel@tonnant>	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>	 <1265019160.2848.14.camel@edumazet-laptop>	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>	 <1265023437.2848.30.camel@edumazet-laptop> <1265035970.2848.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070108060605080906080005"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265035970.2848.50.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070108060605080906080005
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Eric Dumazet wrote:
> [PATCH] netfilter: per netns nf_conntrack_cachep
> 
> nf_conntrack_cachep is currently shared by all netns instances, but
> because of SLAB_DESTROY_BY_RCU special semantics, this is wrong.
> 
> If we use a shared slab cache, one object can instantly flight between
> one hash table (netns ONE) to another one (netns TWO), and concurrent
> reader (doing a lookup in netns ONE, 'finding' an object of netns TWO)
> can be fooled without notice, because no RCU grace period has to be
> observed between object freeing and its reuse.
> 
> We dont have this problem with UDP/TCP slab caches because TCP/UDP
> hashtables are global to the machine (and each object has a pointer to
> its netns).
> 
> If we use per netns conntrack hash tables, we also *must* use per netns
> conntrack slab caches, to guarantee an object can not escape from one
> namespace to another one.

Applied with the discussed change to allocate a unique name (attached
again for reference), thanks Eric.


--------------070108060605080906080005
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit ab59b19be78aac65cdd599fb5002c9019885e061
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Feb 4 14:54:05 2010 +0100

    netfilter: nf_conntrack: per netns nf_conntrack_cachep
    
    nf_conntrack_cachep is currently shared by all netns instances, but
    because of SLAB_DESTROY_BY_RCU special semantics, this is wrong.
    
    If we use a shared slab cache, one object can instantly flight between
    one hash table (netns ONE) to another one (netns TWO), and concurrent
    reader (doing a lookup in netns ONE, 'finding' an object of netns TWO)
    can be fooled without notice, because no RCU grace period has to be
    observed between object freeing and its reuse.
    
    We dont have this problem with UDP/TCP slab caches because TCP/UDP
    hashtables are global to the machine (and each object has a pointer to
    its netns).
    
    If we use per netns conntrack hash tables, we also *must* use per netns
    conntrack slab caches, to guarantee an object can not escape from one
    namespace to another one.
    
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    [Patrick: added unique slab name allocation]
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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
index 37e2b88..9de4bd4 100644
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
 
@@ -1325,6 +1313,21 @@ static int nf_conntrack_init_net(struct net *net)
 		ret = -ENOMEM;
 		goto err_stat;
 	}
+
+	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
+	if (!net->ct.slabname) {
+		ret = -ENOMEM;
+		goto err_slabname;
+	}
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
@@ -1352,6 +1355,10 @@ err_expect:
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

--------------070108060605080906080005--
