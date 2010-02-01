From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Mon, 01 Feb 2010 15:52:50 +0100
Message-ID: <1265035970.2848.50.camel@edumazet-laptop>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Masters <jonathan@jonmasters.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265023437.2848.30.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 01 f=C3=A9vrier 2010 =C3=A0 12:23 +0100, Eric Dumazet a =C3=A9=
crit :
> Le lundi 01 f=C3=A9vrier 2010 =C3=A0 12:25 +0200, Alexey Dobriyan a =C3=
=A9crit :
>=20
> > > 2) nf_conntrack_cachep is shared, it should be not shared.
> >=20
> > There is no need for it to be shared, unless you measured something=
=2E
> >=20
>=20

Patrick, here is the relevant patch for this specific problem.

Thanks

[PATCH] netfilter: per netns nf_conntrack_cachep

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

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrac=
k.h
index ba1ba0c..d969a50 100644
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
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 0e98c32..1667285 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -63,8 +63,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
=20
-static struct kmem_cache *nf_conntrack_cachep __read_mostly;
-
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
=20
@@ -572,7 +570,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	 * Do not use kmem_cache_zalloc(), as this cache uses
 	 * SLAB_DESTROY_BY_RCU.
 	 */
-	ct =3D kmem_cache_alloc(nf_conntrack_cachep, gfp);
+	ct =3D kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
 	if (ct =3D=3D NULL) {
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
=20
@@ -1115,7 +1113,6 @@ static void nf_conntrack_cleanup_init_net(void)
 {
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
-	kmem_cache_destroy(nf_conntrack_cachep);
 }
=20
 static void nf_conntrack_cleanup_net(struct net *net)
@@ -1136,6 +1133,7 @@ static void nf_conntrack_cleanup_net(struct net *=
net)
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
+	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
 	free_percpu(net->ct.stat);
 }
=20
@@ -1271,15 +1269,6 @@ static int nf_conntrack_init_init_net(void)
 	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
 	       nf_conntrack_max);
=20
-	nf_conntrack_cachep =3D kmem_cache_create("nf_conntrack",
-						sizeof(struct nf_conn),
-						0, SLAB_DESTROY_BY_RCU, NULL);
-	if (!nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
-		ret =3D -ENOMEM;
-		goto err_cache;
-	}
-
 	ret =3D nf_conntrack_proto_init();
 	if (ret < 0)
 		goto err_proto;
@@ -1293,8 +1282,6 @@ static int nf_conntrack_init_init_net(void)
 err_helper:
 	nf_conntrack_proto_fini();
 err_proto:
-	kmem_cache_destroy(nf_conntrack_cachep);
-err_cache:
 	return ret;
 }
=20
@@ -1316,6 +1303,14 @@ static int nf_conntrack_init_net(struct net *net=
)
 		ret =3D -ENOMEM;
 		goto err_stat;
 	}
+	net->ct.nf_conntrack_cachep =3D kmem_cache_create("nf_conntrack",
+							sizeof(struct nf_conn), 0,
+							SLAB_DESTROY_BY_RCU, NULL);
+	if (!net->ct.nf_conntrack_cachep) {
+		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
+		ret =3D -ENOMEM;
+		goto err_cache;
+	}
 	net->ct.hash =3D nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
@@ -1352,6 +1347,8 @@ err_expect:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 err_hash:
+	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
+err_cache:
 	free_percpu(net->ct.stat);
 err_stat:
 	return ret;


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
