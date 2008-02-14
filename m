From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with type/macro safety
Date: Wed, 13 Feb 2008 16:42:53 -0800
Message-ID: <20080214004253.GR12393@linux.vnet.ibm.com>
References: <20080213220024.GA30729@linux.vnet.ibm.com> <20080213143537.1b806790@extreme> <20080213224134.GK12393@linux.vnet.ibm.com> <20080213144233.05e860cb@extreme> <20080213233744.GO12393@linux.vnet.ibm.com> <20080213155158.1b621359@extreme> <20080214001404.GQ12393@linux.vnet.ibm.com> <20080213162700.0a32000d@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger
	<"stephen.hemminger@vyatta.com"@mail.vyatta.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, dipankar@in.ibm.com, ego@in.ibm.com,
	herbert@gondor.apana.org.au, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:53092 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756440AbYBNAm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 19:42:56 -0500
Content-Disposition: inline
In-Reply-To: <20080213162700.0a32000d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2008 at 04:27:00PM -0800, Stephen Hemminger wrote:
> On Wed, 13 Feb 2008 16:14:04 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Feb 13, 2008 at 03:51:58PM -0800, Stephen Hemminger wrote:

[ . . . ]

> > > Maybe cast both sides to void * in this case:
> > >=20
> > > static inline void node_set_parent(struct node *node, struct tnod=
e *ptr)
> > > {
> > >  	rcu_assign_pointer((void *) node->parent, (void *)((unsigned lo=
ng)ptr | NODE_TYPE(node)));
> > > }
> >=20
> > That gets me the following:
> >=20
> > 	net/ipv4/fib_trie.c: In function =E2=80=98node_set_parent=E2=80=99=
:
> > 	net/ipv4/fib_trie.c:182: error: invalid lvalue in assignment
> >=20
> > However, as with much in computing, an extra level of indirection f=
ixes
> > things.  Your call as to whether or not the cure is preferable to t=
he
> > disease.  ;-)
> >=20
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> >=20
> >  fib_trie.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff -urpNa -X dontdiff linux-2.6.25-rc1/net/ipv4/fib_trie.c linux-=
2.6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c
> > --- linux-2.6.25-rc1/net/ipv4/fib_trie.c	2008-02-13 14:38:12.000000=
000 -0800
> > +++ linux-2.6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c	2008=
-02-13 16:10:07.000000000 -0800
> > @@ -179,8 +179,8 @@ static inline struct tnode *node_parent_
> > =20
> >  static inline void node_set_parent(struct node *node, struct tnode=
 *ptr)
> >  {
> > -	rcu_assign_pointer(node->parent,
> > -			   (unsigned long)ptr | NODE_TYPE(node));
> > +	rcu_assign_pointer((*(void **)&node->parent),
> > +			   (void *)((unsigned long)ptr | NODE_TYPE(node)));
> >  }
>=20
> That is heading towards ugly...  Maybe not using the macro at all (fo=
r this case) would be best:
>=20
> static inline void node_set_parent(struct node *node, struct tnode *p=
tr)
> {
> 	smp_wmb();
> 	node->parent =3D (unsigned long)ptr | NODE_TYPE(node);
> }

Or, alternatively, the rcu_assign_index() patch sent earlier to avoid
the bare memory barrier?

							Thanx, Paul
