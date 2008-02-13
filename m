From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] remove rcu_assign_pointer(NULL) penalty with type/macro safety
Date: Wed, 13 Feb 2008 15:37:44 -0800
Message-ID: <20080213233744.GO12393@linux.vnet.ibm.com>
References: <20080213220024.GA30729@linux.vnet.ibm.com> <20080213143537.1b806790@extreme> <20080213224134.GK12393@linux.vnet.ibm.com> <20080213144233.05e860cb@extreme>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org, dipankar@in.ibm.com,
	ego@in.ibm.com, herbert@gondor.apana.org.au,
	akpm@linux-foundation.org
To: Stephen Hemminger <"stephen.hemminger@vyatta.com"@mail.vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:56795 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756175AbYBMXh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 18:37:56 -0500
Content-Disposition: inline
In-Reply-To: <20080213144233.05e860cb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2008 at 02:42:33PM -0800, Stephen Hemminger wrote:
> On Wed, 13 Feb 2008 14:41:34 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
>=20
> > On Wed, Feb 13, 2008 at 02:35:37PM -0800, Stephen Hemminger wrote:
> > > On Wed, 13 Feb 2008 14:00:24 -0800
> > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > >=20
> > > > Hello!
> > > >=20
> > > > This is an updated version of the patch posted last November:
> > > >=20
> > > > 	http://archives.free.net.ph/message/20071201.003721.cd6ff17c.e=
n.html
> > > >=20
> > > > This new version permits arguments with side effects, for examp=
le:
> > > >=20
> > > > 	rcu_assign_pointer(global_p, p++);
> > > >=20
> > > > and also verifies that the arguments are pointers, while still =
avoiding
> > > > the unnecessary memory barrier when assigning NULL to a pointer=
=2E
> > > > This memory-barrier avoidance means that rcu_assign_pointer() i=
s now only
> > > > permitted for pointers (not array indexes), and so this version=
 emits a
> > > > compiler warning if the first argument is not a pointer.  I bui=
lt a "make
> > > > allyesconfig" version on an x86 system, and received no such wa=
rnings.
> > > > If RCU is ever applied to array indexes, then the second patch =
in this
> > > > series should be applied, and the resulting rcu_assign_index() =
be used.
> > > >=20
> > > > Given the rather surprising history of subtlely broken implemen=
tations of
> > > > rcu_assign_pointer(), I took the precaution of generating a ful=
l set of
> > > > test cases and verified that memory barriers and compiler warni=
ngs were
> > > > emitted when required.  I guess it is the simple things that ge=
t you...
> > > >=20
> > > > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > > ---
> > > >=20
> > > >  rcupdate.h |   16 ++++++++++++----
> > > >  1 file changed, 12 insertions(+), 4 deletions(-)
> > > >=20
> > > > diff -urpNa -X dontdiff linux-2.6.24/include/linux/rcupdate.h l=
inux-2.6.24-rap/include/linux/rcupdate.h
> > > > --- linux-2.6.24/include/linux/rcupdate.h	2008-01-24 14:58:37.0=
00000000 -0800
> > > > +++ linux-2.6.24-rap/include/linux/rcupdate.h	2008-02-13 13:36:=
47.000000000 -0800
> > > > @@ -270,12 +270,20 @@ extern struct lockdep_map rcu_lock_map;
> > > >   * structure after the pointer assignment.  More importantly, =
this
> > > >   * call documents which pointers will be dereferenced by RCU r=
ead-side
> > > >   * code.
> > > > + *
> > > > + * Throws a compiler warning for non-pointer arguments.
> > > > + *
> > > > + * Does not insert a memory barrier for a NULL pointer.
> > > >   */
> > > > =20
> > > > -#define rcu_assign_pointer(p, v)	({ \
> > > > -						smp_wmb(); \
> > > > -						(p) =3D (v); \
> > > > -					})
> > > > +#define rcu_assign_pointer(p, v)	\
> > > > +	({ \
> > > > +		typeof(*p) *_________p1 =3D (v); \
> > > > +		\
> > > > +		if (!__builtin_constant_p(v) || (_________p1 !=3D NULL)) \
> > > > +			smp_wmb(); \
> > > > +		(p) =3D _________p1; \
> > > > +	})
> > > > =20
> > > >  /**
> > > >   * synchronize_sched - block until all CPUs have exited any no=
n-preemptive
> > >=20
> > > Will this still work if p is unsigned long?
> >=20
> > Hello, Steve,
> >=20
> > If p is unsigned long, then use rcu_assign_index() from the next pa=
tch in
> > the set.  Looks like Andrew has applied it to -mm -- so please make=
 sure
> > that he is aware if you do use it.
>=20
> Make sure fib_trie still works and doesn't get warnings.

Ah.  It does take a bit to get fib_trie into one's build -- allyesconfi=
g
doesn't cut it.  Please accept my apologies for my confusion!!!

Once fib_trie is configured, I do indeed get:

    net/ipv4/fib_trie.c: In function =E2=80=98node_set_parent=E2=80=99:
    net/ipv4/fib_trie.c:182: warning: comparison between pointer and in=
teger

So, given that node->parent is an unsigned long, I changed node_set_par=
ent()
to the following:

static inline void node_set_parent(struct node *node, struct tnode *ptr=
)
{
	rcu_assign_index(node->parent, (unsigned long)ptr | NODE_TYPE(node));
}

This removes the warnings.  I am a little ambivalent about this, as
this is really a pointer in disguise rather than an array index, but
patch below.  I suppose that another option would be to make node->pare=
nt
be a void* and provide appropriate accessor functions/macros.

Thoughts?

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 fib_trie.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -urpNa -X dontdiff linux-2.6.25-rc1/net/ipv4/fib_trie.c linux-2.6.=
25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c
--- linux-2.6.25-rc1/net/ipv4/fib_trie.c	2008-02-13 14:38:12.000000000 =
-0800
+++ linux-2.6.25-rc1-fib_trie-warn.compile/net/ipv4/fib_trie.c	2008-02-=
13 15:22:02.000000000 -0800
@@ -179,8 +179,7 @@ static inline struct tnode *node_parent_
=20
 static inline void node_set_parent(struct node *node, struct tnode *pt=
r)
 {
-	rcu_assign_pointer(node->parent,
-			   (unsigned long)ptr | NODE_TYPE(node));
+	rcu_assign_index(node->parent, (unsigned long)ptr | NODE_TYPE(node));
 }
=20
 static inline struct node *tnode_get_child(struct tnode *tn, unsigned =
int i)
