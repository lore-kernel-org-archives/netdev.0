From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Wed, 1 Jul 2009 06:36:52 +0000
Message-ID: <20090701063651.GA4876@ff.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:48147 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbZGAGg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 02:36:57 -0400
Received: by bwz25 with SMTP id 25so300230bwz.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 23:36:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4AA03D.5090808@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 01:31:09AM +0200, Pawe=B3 Staszewski wrote:
=2E..
> Yes i can make tests like this.
> My network is splited to test clients and other normal clients
> so it's really no problem to make testing. - if testing clients worki=
ng =20
> then traffic from normal clients is also switched to this router (but=
 if =20
> traffic is not forwarded "like in this case" for testing clients then=
 =20
> failover switching them to working router )
>
> and other point to make this tests - is that - it is good to have all=
 in =20
> linux kernel networking working well :)

It's extremely nice of you! On the other hand, this type of change
was planned to the net-next to fix possible memory problems, which
might have happened to you as well. So you'd probably experience this
problem in the future (2.6.32) anyway.

So here is the first of 2 patches (the second in a separate message),
which should be tested separately, each one applied on top of the
2.6.29.x (vanilla - at least fib_trie.c), after reverting the previous
one. So, they are again all-in-one, to eclude any misunderstanding.

Btw., I assume there were no oopses, warnings or lockups after those
previous non-working patches - only no routing/forwarding.

Thanks,
Jarek P.
----------> (synchronize take 6 all-in-one for 2.6.29x, .28, or .27)

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-06-29 05:30:50.000000000 +0000
+++ b/net/ipv4/fib_trie.c	2009-07-01 05:15:37.000000000 +0000
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
+static void trie_rebalance(struct trie *t, struct tnode *tn, bool sync=
)
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
+		//tnode_free_flush();
+		if (!tp)
 			break;
 		tn =3D tp;
 	}
@@ -1007,7 +1034,12 @@ static struct node *trie_rebalance(struc
 	if (IS_TNODE(tn))
 		tn =3D (struct tnode *)resize(t, (struct tnode *)tn);
=20
-	return (struct node *)tn;
+	rcu_assign_pointer(t->trie, (struct node *)tn);
+	if (sync)
+		synchronize_rcu();
+	tnode_free_flush();
+
+	return;
 }
=20
 /* only used from updater-side */
@@ -1155,7 +1187,7 @@ static struct list_head *fib_insert_node
=20
 	/* Rebalance the trie */
=20
-	rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+	trie_rebalance(t, tp, true);
 done:
 	return fa_head;
 }
@@ -1575,7 +1607,7 @@ static void trie_leaf_remove(struct trie
 	if (tp) {
 		t_key cindex =3D tkey_extract_bits(l->key, tp->pos, tp->bits);
 		put_child(t, (struct tnode *)tp, cindex, NULL);
-		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
+		trie_rebalance(t, tp, false);
 	} else
 		rcu_assign_pointer(t->trie, NULL);
=20
