From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with
 type/macro safety
Date: Wed, 13 Feb 2008 15:51:58 -0800
Message-ID: <20080213155158.1b621359@extreme>
References: <20080213220024.GA30729@linux.vnet.ibm.com>
	<20080213143537.1b806790@extreme>
	<20080213224134.GK12393@linux.vnet.ibm.com>
	<20080213144233.05e860cb@extreme>
	<20080213233744.GO12393@linux.vnet.ibm.com>
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
Received: from mail.vyatta.com ([216.93.170.194]:37830 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137AbYBMXwI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 18:52:08 -0500
In-Reply-To: <20080213233744.GO12393@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Feb 2008 15:37:44 -0800
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> On Wed, Feb 13, 2008 at 02:42:33PM -0800, Stephen Hemminger wrote:
> > On Wed, 13 Feb 2008 14:41:34 -0800
> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> >=20
> > > On Wed, Feb 13, 2008 at 02:35:37PM -0800, Stephen Hemminger wrote=
:
> > > > On Wed, 13 Feb 2008 14:00:24 -0800
> > > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > > >=20
> > > > > Hello!
> > > > >=20
> > > > > This is an updated version of the patch posted last November:
> > > > >=20
> > > > > 	http://archives.free.net.ph/message/20071201.003721.cd6ff17c=
=2Een.html
> > > > >=20
> > > > > This new version permits arguments with side effects, for exa=
mple:
> > > > >=20
> > > > > 	rcu_assign_pointer(global_p, p++);
> > > > >=20
> > > > > and also verifies that the arguments are pointers, while stil=
l avoiding
> > > > > the unnecessary memory barrier when assigning NULL to a point=
er.
> > > > > This memory-barrier avoidance means that rcu_assign_pointer()=
 is now only
> > > > > permitted for pointers (not array indexes), and so this versi=
on emits a
> > > > > compiler warning if the first argument is not a pointer.  I b=
uilt a "make
> > > > > allyesconfig" version on an x86 system, and received no such =
warnings.
> > > > > If RCU is ever applied to array indexes, then the second patc=
h in this
> > > > > series should be applied, and the resulting rcu_assign_index(=
) be used.
> > > > >=20
> > > > > Given the rather surprising history of subtlely broken implem=
entations of
> > > > > rcu_assign_pointer(), I took the precaution of generating a f=
ull set of
> > > > > test cases and verified that memory barriers and compiler war=
nings were
> > > > > emitted when required.  I guess it is the simple things that =
get you...
> > > > >=20
> > > > > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > > > ---
> > > > >=20
> > > > >  rcupdate.h |   16 ++++++++++++----
> > > > >  1 file changed, 12 insertions(+), 4 deletions(-)
> > > > >=20
> > > > > diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupdate.h=
 linux-2.6.24-rap/include/linux/rcupdate.h
> > > > > --- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:58:37=
=2E000000000 -0800
> > > > > +++ linux-2.6.24-rap/include/linux/rcupdate.h	2008-02-13 13:3=
6:47.000000000 -0800
> > > > > @@ -270,12 +270,20 @@ extern struct lockdep_map rcu_lock_map;
> > > > >   * structure after the pointer assignment.  More importantly=
, this
> > > > >   * call documents which pointers will be dereferenced by RCU=
 read-side
> > > > >   * code.
> > > > > + *
> > > > > + * Throws a compiler warning for non-pointer arguments.
> > > > > + *
> > > > > + * Does not insert a memory barrier for a NULL pointer.
> > > > >   */
> > > > > =20
> > > > > -#define rcu_assign_pointer(p, v)	({ \
> > > > > -						smp_wmb(); \
> > > > > -						(p) =3D (v); \
> > > > > -					})
> > > > > +#define rcu_assign_pointer(p, v)	\
> > > > > +	({ \
> > > > > +		typeof(*p) *_________p1 =3D (v); \
> > > > > +		\
> > > > > +		if (!__builtin_constant_p(v) || (_________p1 !=3D NULL)) \
> > > > > +			smp_wmb(); \
> > > > > +		(p) =3D _________p1; \
> > > > > +	})
> > > > > =20
> > > > >  /**
> > > > >   * synchronize_sched - block until all CPUs have exited any =
non-preemptive
> > > >=20
> > > > Will this still work if p is unsigned long?
> > >=20
> > > Hello, Steve,
> > >=20
> > > If p is unsigned long, then use rcu_assign_index() from the next =
patch in
> > > the set.  Looks like Andrew has applied it to -mm -- so please ma=
ke sure
> > > that he is aware if you do use it.
> >=20
> > Make sure fib_trie still works and doesn't get warnings.
>=20
> Ah.  It does take a bit to get fib_trie into one's build -- allyescon=
fig
> doesn't cut it.  Please accept my apologies for my confusion!!!
>=20
> Once fib_trie is configured, I do indeed get:
>=20
>     net/ipv4/fib_trie.c: In function =E2=80=98node_set_parent=E2=80=99=
:
>     net/ipv4/fib_trie.c:182: warning: comparison between pointer and =
integer
>=20
> So, given that node->parent is an unsigned long, I changed node_set_p=
arent()
> to the following:
>=20
> static inline void node_set_parent(struct node *node, struct tnode *p=
tr)
> {
> 	rcu_assign_index(node->parent, (unsigned long)ptr | NODE_TYPE(node))=
;
> }
>=20
> This removes the warnings.  I am a little ambivalent about this, as
> this is really a pointer in disguise rather than an array index, but
> patch below.  I suppose that another option would be to make node->pa=
rent
> be a void* and provide appropriate accessor functions/macros.
>=20
> Thoughts?
>=20
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Maybe cast both sides to void * in this case:

static inline void node_set_parent(struct node *node, struct tnode *ptr=
)
{
 	rcu_assign_pointer((void *) node->parent, (void *)((unsigned long)ptr=
 | NODE_TYPE(node)));
}

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
