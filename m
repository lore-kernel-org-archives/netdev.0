From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Mon, 29 Jun 2009 10:47:03 +0000
Message-ID: <20090629104703.GC4712@ff.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:47059 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbZF2KrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 06:47:06 -0400
Received: by fg-out-1718.google.com with SMTP id e21so866431fga.17
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 03:47:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A488EB8.4070602@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
> I apply this patch
>
> fib_triestats in attached file :)

Great! But it would be nice to check if this (accidentally ;-) might
fix the previous problem, so I attach below the patch with "manual
RCU", which btw. (or even more important) should verify RCU use here.

It should be applied on top of this last "Fix..., part3". And
again: it's quite probable it can fail, so with caution, no hurry
(it can wait for quiet time)...

Many thanks,
Jarek P.
--------------------> (synchronize_rcu take 4)

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-06-29 10:00:14.000000000 +0000
+++ b/net/ipv4/fib_trie.c	2009-06-29 10:04:22.000000000 +0000
@@ -366,6 +366,17 @@ static void __tnode_vfree(struct work_st
 	vfree(tn);
 }
=20
+static void __tnode_free(struct tnode *tn)
+{
+	size_t size =3D sizeof(struct tnode) +
+		      (sizeof(struct node *) << tn->bits);
+
+	if (size <=3D PAGE_SIZE)
+		kfree(tn);
+	else
+		vfree(tn);
+}
+
 static void __tnode_free_rcu(struct rcu_head *head)
 {
 	struct tnode *tn =3D container_of(head, struct tnode, rcu);
@@ -402,7 +413,7 @@ static void tnode_free_flush(void)
 	while ((tn =3D tnode_free_head)) {
 		tnode_free_head =3D tn->tnode_free;
 		tn->tnode_free =3D NULL;
-		tnode_free(tn);
+		__tnode_free(tn);
 	}
 }
=20
@@ -1021,21 +1032,27 @@ static void trie_rebalance(struct trie *
 				      (struct node *)tn, wasfull);
=20
 		tp =3D node_parent((struct node *) tn);
-		if (!tp)
+		if (!tp) {
 			rcu_assign_pointer(t->trie, (struct node *)tn);
-
-		tnode_free_flush();
-		if (!tp)
 			break;
+		}
 		tn =3D tp;
 	}
=20
+	if (tnode_free_head) {
+		synchronize_rcu();
+		tnode_free_flush();
+	}
+
 	/* Handle last (top) tnode */
-	if (IS_TNODE(tn))
+	if (IS_TNODE(tn)) {
 		tn =3D (struct tnode *)resize(t, (struct tnode *)tn);
-
-	rcu_assign_pointer(t->trie, (struct node *)tn);
-	tnode_free_flush();
+		rcu_assign_pointer(t->trie, (struct node *)tn);
+		synchronize_rcu();
+		tnode_free_flush();
+	} else {
+		rcu_assign_pointer(t->trie, (struct node *)tn);
+	}
=20
 	return;
 }
