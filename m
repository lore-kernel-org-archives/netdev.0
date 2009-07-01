From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Wed, 1 Jul 2009 11:04:07 +0000
Message-ID: <20090701110407.GC12715@ff.dom.local>
References: <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53485 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbZGALEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 07:04:11 -0400
Received: by bwz25 with SMTP id 25so430855bwz.37
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2009 04:04:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090701101333.GB12715@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 10:13:33AM +0000, Jarek Poplawski wrote:
> On Wed, Jul 01, 2009 at 11:43:04AM +0200, Pawe=B3 Staszewski wrote:
> ...
> > Yes on on previous patches there was / no warnings / no oopses or l=
ockups
> >
> > But now i apply this patch and i make more testing.
> > First boot with start of bgpd and - traffic is not forwarded
> > So i start to search and make only some routes (static without bgpd=
) =20
> > thru this host
> > And all is working for this host when i make all by static routes.
> >
> > So i change a little my bgp configuration and make default route to=
 only =20
> > one of my iBGP peers and start bgpd process
> > All is working and what is weird is number of routes in kernel tabl=
e.
> > Kernel is learning routes from bgpd but very slowly - really very s=
lowly.
>=20
> Pawel, this is really very helpful! So, this is (probably) only about
> timing, not wrong memory freeing. On the other hand this test was onl=
y
> for inserts. Btw., if you didn't start the second test, you can skip
> it. I have to rethink this.

So, after your findings I'm about to recommend sending to -stable
3 patches from net-2.6, with additional lowering of threshold_root
settings, but it would be nice if you could give it a try with
CONFIG_PREEMPT instead of CONFIG_PREEMPT_NONE (if it doesn't break
your other apps!) It is expected to work this time...;-) Maybe a
bit slower.

Thanks,
Jarek P.
--------> (all-in-one preempt fixes to apply with vanilla 2.6.29.x)

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-07-01 06:17:08.000000000 +0000
+++ b/net/ipv4/fib_trie.c	2009-07-01 10:43:44.000000000 +0000
@@ -123,6 +123,7 @@ struct tnode {
 	union {
 		struct rcu_head rcu;
 		struct work_struct work;
+		struct tnode *tnode_free;
 	};
 	struct node *child[0];
 };
@@ -161,6 +162,8 @@ static void tnode_put_child_reorg(struct
 static struct node *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
+/* tnodes to free after resize(); protected by RTNL */
+static struct tnode *tnode_free_head;
=20
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
@@ -313,8 +316,8 @@ static inline void check_tnode(const str
=20
 static const int halve_threshold =3D 25;
 static const int inflate_threshold =3D 50;
-static const int halve_threshold_root =3D 8;
-static const int inflate_threshold_root =3D 15;
+static const int halve_threshold_root =3D 15;
+static const int inflate_threshold_root =3D 25;
=20
=20
 static void __alias_free_mem(struct rcu_head *head)
@@ -385,6 +388,24 @@ static inline void tnode_free(struct tno
 		call_rcu(&tn->rcu, __tnode_free_rcu);
 }
=20
+static void tnode_free_safe(struct tnode *tn)
+{
+	BUG_ON(IS_LEAF(tn));
+	tn->tnode_free =3D tnode_free_head;
+	tnode_free_head =3D tn;
+}
+
+static void tnode_free_flush(void)
+{
+	struct tnode *tn;
+
+	while ((tn =3D tnode_free_head)) {
+		tnode_free_head =3D tn->tnode_free;
+		tn->tnode_free =3D NULL;
+		tnode_free(tn);
+	}
+}
+
 static struct leaf *leaf_new(void)
 {
 	struct leaf *l =3D kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
@@ -495,7 +516,7 @@ static struct node *resize(struct trie *
=20
 	/* No children */
 	if (tn->empty_children =3D=3D tnode_child_length(tn)) {
-		tnode_free(tn);
+		tnode_free_safe(tn);
 		return NULL;
 	}
 	/* One child */
@@ -509,7 +530,7 @@ static struct node *resize(struct trie *
=20
 			/* compress one level */
 			node_set_parent(n, NULL);
-			tnode_free(tn);
+			tnode_free_safe(tn);
 			return n;
 		}
 	/*
@@ -670,7 +691,7 @@ static struct node *resize(struct trie *
 			/* compress one level */
=20
 			node_set_parent(n, NULL);
-			tnode_free(tn);
+			tnode_free_safe(tn);
 			return n;
 		}
=20
@@ -756,7 +777,7 @@ static struct tnode *inflate(struct trie
 			put_child(t, tn, 2*i, inode->child[0]);
 			put_child(t, tn, 2*i+1, inode->child[1]);
=20
-			tnode_free(inode);
+			tnode_free_safe(inode);
 			continue;
 		}
=20
@@ -801,9 +822,9 @@ static struct tnode *inflate(struct trie
 		put_child(t, tn, 2*i, resize(t, left));
 		put_child(t, tn, 2*i+1, resize(t, right));
=20
-		tnode_free(inode);
+		tnode_free_safe(inode);
 	}
-	tnode_free(oldtnode);
+	tnode_free_safe(oldtnode);
 	return tn;
 nomem:
 	{
@@ -885,7 +906,7 @@ static struct tnode *halve(struct trie *
 		put_child(t, newBinNode, 1, right);
 		put_child(t, tn, i/2, resize(t, newBinNode));
 	}
-	tnode_free(oldtnode);
+	tnode_free_safe(oldtnode);
 	return tn;
 nomem:
 	{
@@ -983,12 +1004,14 @@ fib_find_node(struct trie *t, u32 key)
 	return NULL;
 }
=20
-static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
+static void trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	int wasfull;
-	t_key cindex, key =3D tn->key;
+	t_key cindex, key;
 	struct tnode *tp;
=20
+	key =3D tn->key;
+
 	while (tn !=3D NULL && (tp =3D node_parent((struct node *)tn)) !=3D N=
ULL) {
 		cindex =3D tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull =3D tnode_full(tp, tnode_get_child(tp, cindex));
@@ -999,6 +1022,10 @@ static struct node *trie_rebalance(struc
=20
 		tp =3D node_parent((struct node *) tn);
 		if (!tp)
+			rcu_assign_pointer(t->trie, (struct node *)tn);
+
+		tnode_free_flush();
+		if (!tp)
 			break;
 		tn =3D tp;
 	}
@@ -1007,7 +1034,10 @@ static struct node *trie_rebalance(struc
 	if (IS_TNODE(tn))
 		tn =3D (struct tnode *)resize(t, (struct tnode *)tn);
=20
-	return (struct node *)tn;
+	rcu_assign_pointer(t->trie, (struct node *)tn);
+	tnode_free_flush();
+
+	return;
 }
=20
 /* only used from updater-side */
@@ -1155,7 +1185,7 @@ static struct list_head *fib_insert_node
=20
 	/* Rebalance the trie */
=20
-	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+	trie_rebalance(t, tp);
 done:
 	return fa_head;
 }
@@ -1575,7 +1605,7 @@ static void trie_leaf_remove(struct trie
 	if (tp) {
 		t_key cindex =3D tkey_extract_bits(l->key, tp->pos, tp->bits);
 		put_child(t, (struct tnode *)tp, cindex, NULL);
-		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+		trie_rebalance(t, tp);
 	} else
 		rcu_assign_pointer(t->trie, NULL);
=20
