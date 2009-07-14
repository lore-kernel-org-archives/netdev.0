From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root. Now=15
	size=11 bits
Date: Tue, 14 Jul 2009 20:33:08 +0200
Message-ID: <20090714183308.GB3090@ami.dom.local>
References: <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:43641 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755290AbZGNSdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 14:33:24 -0400
Received: by bwz28 with SMTP id 28so957100bwz.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 11:33:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090705213232.GG8943@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 02:32:32PM -0700, Paul E. McKenney wrote:
> On Sun, Jul 05, 2009 at 07:32:08PM +0200, Jarek Poplawski wrote:
> > On Sun, Jul 05, 2009 at 06:20:03PM +0200, Jarek Poplawski wrote:
> > > On Sun, Jul 05, 2009 at 02:30:03AM +0200, Pawe=B3 Staszewski wrot=
e:
> > > > Oh
> > > >
> > > > I forgot - please Jarek give me patch with sync rcu and i will =
make test =20
> > > > on preempt kernel
> > >=20
> > > Probably non-preempt kernel might need something like this more, =
but
> > > comparing is always interesting. This patch is based on Paul's
> > > suggestion (I hope).
> >=20
> > Hold on ;-) Here is something even better... Syncing after 128 page=
s
> > might be still too slow, so here is a higher initial value, 1000, p=
lus
> > you can change this while testing in:
> >=20
> > /sys/module/fib_trie/parameters/sync_pages
> >=20
> > It would be interesting to find the lowest acceptable value.
>=20
> Looks like a promising approach to me!
>=20
> 							Thanx, Paul

Below is a simpler version of this patch, without the sysfs parameter.
(I left the previous version quoted for comparison.) Thanks.

> > Jarek P.
> > ---> (synchronize take 8; apply on top of the 2.6.29.x with the las=
t
> >  	all-in-one patch, or net-2.6)
> >=20
> >  net/ipv4/fib_trie.c |   12 ++++++++++++
> >  1 files changed, 12 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> > index 00a54b2..decc8d0 100644
> > --- a/net/ipv4/fib_trie.c
> > +++ b/net/ipv4/fib_trie.c
> > @@ -71,6 +71,7 @@
> >  #include <linux/netlink.h>
> >  #include <linux/init.h>
> >  #include <linux/list.h>
> > +#include <linux/moduleparam.h>
> >  #include <net/net_namespace.h>
> >  #include <net/ip.h>
> >  #include <net/protocol.h>
> > @@ -164,6 +165,10 @@ static struct tnode *inflate(struct trie *t, s=
truct tnode *tn);
> >  static struct tnode *halve(struct trie *t, struct tnode *tn);
> >  /* tnodes to free after resize(); protected by RTNL */
> >  static struct tnode *tnode_free_head;
> > +static size_t tnode_free_size;
> > +
> > +static int sync_pages __read_mostly =3D 1000;
> > +module_param(sync_pages, int, 0640);
> >=20
> >  static struct kmem_cache *fn_alias_kmem __read_mostly;
> >  static struct kmem_cache *trie_leaf_kmem __read_mostly;
> > @@ -393,6 +398,8 @@ static void tnode_free_safe(struct tnode *tn)
> >  	BUG_ON(IS_LEAF(tn));
> >  	tn->tnode_free =3D tnode_free_head;
> >  	tnode_free_head =3D tn;
> > +	tnode_free_size +=3D sizeof(struct tnode) +
> > +			   (sizeof(struct node *) << tn->bits);
> >  }
> >=20
> >  static void tnode_free_flush(void)
> > @@ -404,6 +411,11 @@ static void tnode_free_flush(void)
> >  		tn->tnode_free =3D NULL;
> >  		tnode_free(tn);
> >  	}
> > +
> > +	if (tnode_free_size >=3D PAGE_SIZE * sync_pages) {
> > +		tnode_free_size =3D 0;
> > +		synchronize_rcu();
> > +	}
> >  }
> >=20
> >  static struct leaf *leaf_new(void)
> > --

------------------------>
ipv4: Use synchronize_rcu() during trie_rebalance()

During trie_rebalance() we free memory after resizing with call_rcu(),
but large updates, especially with PREEMPT_NONE configs, can cause
memory stresses, so this patch calls synchronize_rcu() in
tnode_free_flush() after each sync_pages to guarantee such freeing
(especially before resizing the root node).

The value of sync_pages =3D 128 is based on Pawel Staszewski's tests as
the lowest which doesn't hinder updating times. (For testing purposes
there was a sysfs module parameter to change it on demand, but it's
removed until we're sure it could be really useful.)

The patch is based on suggestions by: Paul E. McKenney
<paulmck@linux.vnet.ibm.com>

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/ipv4/fib_trie.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 63c2fa7..58ba9f4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -164,6 +164,14 @@ static struct tnode *inflate(struct trie *t, struc=
t tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
 /* tnodes to free after resize(); protected by RTNL */
 static struct tnode *tnode_free_head;
+static size_t tnode_free_size;
+
+/*
+ * synchronize_rcu after call_rcu for that many pages; it should be es=
pecially
+ * useful before resizing the root node with PREEMPT_NONE configs; the=
 value was
+ * obtained experimentally, aiming to avoid visible slowdown.
+ */
+static const int sync_pages =3D 128;
=20
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
@@ -393,6 +401,8 @@ static void tnode_free_safe(struct tnode *tn)
 	BUG_ON(IS_LEAF(tn));
 	tn->tnode_free =3D tnode_free_head;
 	tnode_free_head =3D tn;
+	tnode_free_size +=3D sizeof(struct tnode) +
+			   (sizeof(struct node *) << tn->bits);
 }
=20
 static void tnode_free_flush(void)
@@ -404,6 +414,11 @@ static void tnode_free_flush(void)
 		tn->tnode_free =3D NULL;
 		tnode_free(tn);
 	}
+
+	if (tnode_free_size >=3D PAGE_SIZE * sync_pages) {
+		tnode_free_size =3D 0;
+		synchronize_rcu();
+	}
 }
=20
 static struct leaf *leaf_new(void)
