From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with
 type/macro safety
Date: Wed, 13 Feb 2008 16:27:00 -0800
Message-ID: <20080213162700.0a32000d@extreme>
References: <20080213220024.GA30729@linux.vnet.ibm.com>
	<20080213143537.1b806790@extreme>
	<20080213224134.GK12393@linux.vnet.ibm.com>
	<20080213144233.05e860cb@extreme>
	<20080213233744.GO12393@linux.vnet.ibm.com>
	<20080213155158.1b621359@extreme>
	<20080214001404.GQ12393@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger
	<"stephen.hemminger@vyatta.com"@mail.vyatta.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, dipankar@in.ibm.com, ego@in.ibm.com,
	herbert@gondor.apana.org.au, akpm@linux-foundation.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38762 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763992AbYBNA1J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 19:27:09 -0500
In-Reply-To: <20080214001404.GQ12393@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 16:14:04 -0800
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> On Wed, Feb 13, 2008 at 03:51:58PM -0800, Stephen Hemminger wrote:
> > On Wed, 13 Feb 2008 15:37:44 -0800
> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > > On Wed, Feb 13, 2008 at 02:42:33PM -0800, Stephen Hemminger wrote=
:
> > > > On Wed, 13 Feb 2008 14:41:34 -0800
> > > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > > >=20
> > > > > On Wed, Feb 13, 2008 at 02:35:37PM -0800, Stephen Hemminger w=
rote:
> > > > > > On Wed, 13 Feb 2008 14:00:24 -0800
> > > > > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > > > > >=20
> > > > > > > Hello!
> > > > > > >=20
> > > > > > > This is an updated version of the patch posted last Novem=
ber:
> > > > > > >=20
> > > > > > > 	http://archives.free.net.ph/message/20071201.003721.cd6f=
f17c.en.html
> > > > > > >=20
> > > > > > > This new version permits arguments with side effects, for=
 example:
> > > > > > >=20
> > > > > > > 	rcu_assign_pointer(global_p, p++);
> > > > > > >=20
> > > > > > > and also verifies that the arguments are pointers, while =
still avoiding
> > > > > > > the unnecessary memory barrier when assigning NULL to a p=
ointer.
> > > > > > > This memory-barrier avoidance means that rcu_assign_point=
er() is now only
> > > > > > > permitted for pointers (not array indexes), and so this v=
ersion emits a
> > > > > > > compiler warning if the first argument is not a pointer. =
 I built a "make
> > > > > > > allyesconfig" version on an x86 system, and received no s=
uch warnings.
> > > > > > > If RCU is ever applied to array indexes, then the second =
patch in this
> > > > > > > series should be applied, and the resulting rcu_assign_in=
dex() be used.
> > > > > > >=20
> > > > > > > Given the rather surprising history of subtlely broken im=
plementations of
> > > > > > > rcu_assign_pointer(), I took the precaution of generating=
 a full set of
> > > > > > > test cases and verified that memory barriers and compiler=
 warnings were
> > > > > > > emitted when required.  I guess it is the simple things t=
hat get you...
> > > > > > >=20
> > > > > > > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.c=
om>
> > > > > > > ---
> > > > > > >=20
> > > > > > >  rcupdate.h |   16 ++++++++++++----
> > > > > > >  1 file changed, 12 insertions(+), 4 deletions(-)
> > > > > > >=20
> > > > > > > diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupda=
te.h linux-2.6.24-rap/include/linux/rcupdate.h
> > > > > > > --- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:5=
8:37.000000000 -0800
> > > > > > > +++ linux-2.6.24-rap/include/linux/rcupdate.h	2008-02-13 =
13:36:47.000000000 -0800
> > > > > > > @@ -270,12 +270,20 @@ extern struct lockdep_map rcu_lock_=
map;
> > > > > > >   * structure after the pointer assignment.  More importa=
ntly, this
> > > > > > >   * call documents which pointers will be dereferenced by=
 RCU read-side
> > > > > > >   * code.
> > > > > > > + *
> > > > > > > + * Throws a compiler warning for non-pointer arguments.
> > > > > > > + *
> > > > > > > + * Does not insert a memory barrier for a NULL pointer.
> > > > > > >   */
> > > > > > > =20
> > > > > > > -#define rcu_assign_pointer(p, v)	({ \
> > > > > > > -						smp_wmb(); \
> > > > > > > -						(p) =3D (v); \
> > > > > > > -					})
> > > > > > > +#define rcu_assign_pointer(p, v)	\
> > > > > > > +	({ \
> > > > > > > +		typeof(*p) *_________p1 =3D (v); \
> > > > > > > +		\
> > > > > > > +		if (!__builtin_constant_p(v) || (_________p1 !=3D NULL=
)) \
> > > > > > > +			smp_wmb(); \
> > > > > > > +		(p) =3D _________p1; \
> > > > > > > +	})
> > > > > > > =20
> > > > > > >  /**
> > > > > > >   * synchronize_sched - block until all CPUs have exited =
any non-preemptive
> > > > > >=20
> > > > > > Will this still work if p is unsigned long?
> > > > >=20
> > > > > Hello, Steve,
> > > > >=20
> > > > > If p is unsigned long, then use rcu_assign_index() from the n=
ext patch in
> > > > > the set.  Looks like Andrew has applied it to -mm -- so pleas=
e make sure
> > > > > that he is aware if you do use it.
> > > >=20
> > > > Make sure fib_trie still works and doesn't get warnings.
> > >=20
> > > Ah.  It does take a bit to get fib_trie into one's build -- allye=
sconfig
> > > doesn't cut it.  Please accept my apologies for my confusion!!!
> > >=20
> > > Once fib_trie is configured, I do indeed get:
> > >=20
> > >     net/ipv4/fib_trie.c: In function =E2=80=98node_set_parent=E2=80=
=99:
> > >     net/ipv4/fib_trie.c:182: warning: comparison between pointer =
and integer
> > >=20
> > > So, given that node->parent is an unsigned long, I changed node_s=
et_parent()
> > > to the following:
> > >=20
> > > static inline void node_set_parent(struct node *node, struct tnod=
e *ptr)
> > > {
> > > 	rcu_assign_index(node->parent, (unsigned long)ptr | NODE_TYPE(no=
de));
> > > }
> > >=20
> > > This removes the warnings.  I am a little ambivalent about this, =
as
> > > this is really a pointer in disguise rather than an array index, =
but
> > > patch below.  I suppose that another option would be to make node=
->parent
> > > be a void* and provide appropriate accessor functions/macros.
> > >=20
> > > Thoughts?
> > >=20
> > > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >=20
> > Maybe cast both sides to void * in this case:
> >=20
> > static inline void node_set_parent(struct node *node, struct tnode =
*ptr)
> > {
> >  	rcu_assign_pointer((void *) node->parent, (void *)((unsigned long=
)ptr | NODE_TYPE(node)));
> > }
>=20
> That gets me the following:
>=20
> 	net/ipv4/fib_trie.c: In function =E2=80=98node_set_parent=E2=80=99:
> 	net/ipv4/fib_trie.c:182: error: invalid lvalue in assignment
>=20
> However, as with much in computing, an extra level of indirection fix=
es
> things.  Your call as to whether or not the cure is preferable to the
> disease.  ;-)
>=20
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>=20
>  fib_trie.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff -urpNa -X dontdiff linux-2.6.25-rc1/net/ipv4/fib_trie.c linux-2.=
6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c
> --- linux-2.6.25-rc1/net/ipv4/fib_trie.c	2008-02-13 14:38:12.00000000=
0 -0800
> +++ linux-2.6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c	2008-0=
2-13 16:10:07.000000000 -0800
> @@ -179,8 +179,8 @@ static inline struct tnode *node_parent_
> =20
>  static inline void node_set_parent(struct node *node, struct tnode *=
ptr)
>  {
> -	rcu_assign_pointer(node->parent,
> -			   (unsigned long)ptr | NODE_TYPE(node));
> +	rcu_assign_pointer((*(void **)&node->parent),
> +			   (void *)((unsigned long)ptr | NODE_TYPE(node)));
>  }

That is heading towards ugly...  Maybe not using the macro at all (for =
this case) would be best:

static inline void node_set_parent(struct node *node, struct tnode *ptr=
)
{
	smp_wmb();
	node->parent =3D (unsigned long)ptr | NODE_TYPE(node);
}
