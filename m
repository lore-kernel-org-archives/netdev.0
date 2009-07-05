From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Sun, 5 Jul 2009 14:32:32 -0700
Message-ID: <20090705213232.GG8943@linux.vnet.ibm.com>
References: <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:52080 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753583AbZGEVcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2009 17:32:18 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n65LLTns009405
	for <netdev@vger.kernel.org>; Sun, 5 Jul 2009 17:21:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n65LWJoR213338
	for <netdev@vger.kernel.org>; Sun, 5 Jul 2009 17:32:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n65LWIfM002397
	for <netdev@vger.kernel.org>; Sun, 5 Jul 2009 17:32:18 -0400
Content-Disposition: inline
In-Reply-To: <20090705173208.GB19477@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 07:32:08PM +0200, Jarek Poplawski wrote:
> On Sun, Jul 05, 2009 at 06:20:03PM +0200, Jarek Poplawski wrote:
> > On Sun, Jul 05, 2009 at 02:30:03AM +0200, Pawe=C5=82 Staszewski wro=
te:
> > > Oh
> > >
> > > I forgot - please Jarek give me patch with sync rcu and i will ma=
ke test =20
> > > on preempt kernel
> >=20
> > Probably non-preempt kernel might need something like this more, bu=
t
> > comparing is always interesting. This patch is based on Paul's
> > suggestion (I hope).
>=20
> Hold on ;-) Here is something even better... Syncing after 128 pages
> might be still too slow, so here is a higher initial value, 1000, plu=
s
> you can change this while testing in:
>=20
> /sys/module/fib_trie/parameters/sync_pages
>=20
> It would be interesting to find the lowest acceptable value.

Looks like a promising approach to me!

							Thanx, Paul

> Jarek P.
> ---> (synchronize take 8; apply on top of the 2.6.29.x with the last
>  	all-in-one patch, or net-2.6)
>=20
>  net/ipv4/fib_trie.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 00a54b2..decc8d0 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -71,6 +71,7 @@
>  #include <linux/netlink.h>
>  #include <linux/init.h>
>  #include <linux/list.h>
> +#include <linux/moduleparam.h>
>  #include <net/net_namespace.h>
>  #include <net/ip.h>
>  #include <net/protocol.h>
> @@ -164,6 +165,10 @@ static struct tnode *inflate(struct trie *t, str=
uct tnode *tn);
>  static struct tnode *halve(struct trie *t, struct tnode *tn);
>  /* tnodes to free after resize(); protected by RTNL */
>  static struct tnode *tnode_free_head;
> +static size_t tnode_free_size;
> +
> +static int sync_pages __read_mostly =3D 1000;
> +module_param(sync_pages, int, 0640);
>=20
>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
> @@ -393,6 +398,8 @@ static void tnode_free_safe(struct tnode *tn)
>  	BUG_ON(IS_LEAF(tn));
>  	tn->tnode_free =3D tnode_free_head;
>  	tnode_free_head =3D tn;
> +	tnode_free_size +=3D sizeof(struct tnode) +
> +			   (sizeof(struct node *) << tn->bits);
>  }
>=20
>  static void tnode_free_flush(void)
> @@ -404,6 +411,11 @@ static void tnode_free_flush(void)
>  		tn->tnode_free =3D NULL;
>  		tnode_free(tn);
>  	}
> +
> +	if (tnode_free_size >=3D PAGE_SIZE * sync_pages) {
> +		tnode_free_size =3D 0;
> +		synchronize_rcu();
> +	}
>  }
>=20
>  static struct leaf *leaf_new(void)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
