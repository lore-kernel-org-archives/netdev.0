From: Nick Piggin <npiggin@suse.de>
Subject: Re: rt hash table / rt hash locks question
Date: Wed, 16 Jun 2010 22:49:22 +1000
Message-ID: <20100616124921.GX6138@laptop>
References: <20100616104633.GW6138@laptop>
 <1276691258.2632.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55138 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab0FPMt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 08:49:26 -0400
Content-Disposition: inline
In-Reply-To: <1276691258.2632.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 02:27:38PM +0200, Eric Dumazet wrote:
> Le mercredi 16 juin 2010 =E0 20:46 +1000, Nick Piggin a =E9crit :
> > I'm just converting this scalable dentry/inode hash table to a more
> > compact form. I was previously using a dumb spinlock per bucket,
> > but this doubles the size of the tables so isn't production quality=
=2E
> >=20
>=20
> Yes, we had this in the past (one rwlock or spinlock per hash chain),
> and it was not very good with LOCKDEP on.

Sure :) And it halves the size of your hash even with lockdep off.

=20
> > What I've done at the moment is to use a bit_spinlock in bit 0 of e=
ach
> > list pointer of the table. Bit spinlocks are now pretty nice becaus=
e
> > we can do __bit_spin_unlock() which gives non-atomic store with rel=
ease
> > ordering, so it should be almost as fast as spinlock.
> >=20
> > But I look at rt hash and it seems you use a small hash on the side
> > for spinlocks. So I wonder, pros for each:
> >=20
> > - bitlocks have effectively zero storage
>     yes but a mask is needed to get head pointer. Special care also m=
ust
> be taken when insert/delete a node in chain, keeping this bit set.

That is true. Overall, I don't know what would be better for straight
line cycles, all in L1 cache. Probably the spinlocks, although there
is some small overhead from loading the 2nd hash.

=20
> > - bitlocks hit the same cacheline that the hash walk hits.
>     yes
> > - in RCU list, locked hash walks usually followed by hash modificat=
ion,
> >   bitlock should have brought in the line for exclusive.
>     But we usually perform a read only lookup, _then_ take the lock, =
to
> perform a new lookup before insert. So at time we would take the
> bitlock, cache line is in shared state. With spinlocks, we always use
> the exclusive mode, but on a separate cache line...

Hmm, OK. This is usually true of the dcache and icache as well
actually. But you still have the same problem with spinlocks (with I
presume the common case of 0 or 1 entry in the hash) when inserting
into the table.

So we're still often avoiding one cacheline transition, and avoiding
hitting one cacheline.

> > - bitlock number of locks scales with hash size
>     Yes, but concurrency is more a function of online cpus, given we =
use
> jhash.=20

Oh yeah but it has a maximum upper bound on the number of buckets in
the hash, and just having it scale nicely avoids the ifdef heuristics
in the existing code.

=20
> > - spinlocks may be slightly better at the cacheline level (bitops
> >   sometimes require explicit load which may not acquire exclusive
> >   line on some archs). On x86 ll/sc architectures, this shouldn't
> >   be a problem.
>     Yes, you can add fairness (if ticket spinlocks variant used), but=
 on
> route cache I really doubt it can make a difference.

Yes if the critical sections are very short and uncontended, I don't
think it's a large factor.

=20
> > - spinlocks better debugging (could be overcome with a LOCKDEP
> >   option to revert to spinlocks, but a bit ugly).
> 	Definitely a good thing.
>=20
> > - in practice, contention due to aliasing in buckets to lock mappin=
g
> >   is probably fairly minor.
>      Agreed
> >=20
> > Net code is obviously tested and tuned well, but instinctively I wo=
uld
> > have tought bitlocks are the better way to go. Any comments on this=
?
>=20
> Well, to be honest, this code is rather old, and at time I wrote it,
> bitlocks were probably not available.
>=20
> You can add :
>=20
> - One downside of the hashed spinlocks is the X86_INTERNODE_CACHE_SHI=
=46T
> being 12 on X86_VSMP : All locks are probably in same internode block=
 :(

Oh yeah that's true, very special case though.

=20
> - Another downside is all locks are currently on a single NUMA node,
> since we kmalloc() them in one contiguous chunk.
>=20
> So I guess it would be worth to try :)

OK, this is what I'm working with for the icache/dcache to hide the
details of masking out the low bit. But it looks like rt hash is a bit
more highly tuned (eg without pprev pointer as you don't delete items
without walking the hash). So it might not be appropriate for you.

You might be able to derive some macros to hide some of the pain though=
=2E

Index: linux-2.6/include/linux/list_bl.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ linux-2.6/include/linux/list_bl.h
@@ -0,0 +1,97 @@
+#ifndef _LINUX_LIST_BL_H
+#define _LINUX_LIST_BL_H
+
+#include <linux/list.h>
+
+/*
+ * Special version of lists, where head of the list has a bit spinlock
+ * in the lowest bit. This is useful for scalable hash tables without
+ * increasing memory footprint overhead.
+ */
+
+struct hlist_bl_head {
+	struct hlist_bl_node *first;
+};
+
+struct hlist_bl_node {
+	struct hlist_bl_node *next, **pprev;
+};
+#define INIT_HLIST_BL_HEAD(ptr) \
+	((ptr)->first =3D NULL)
+
+static inline void INIT_HLIST_BL_NODE(struct hlist_bl_node *h)
+{
+	h->next =3D NULL;
+	h->pprev =3D NULL;
+}
+
+#define hlist_bl_entry(ptr, type, member) container_of(ptr,type,member=
)
+
+static inline int hlist_bl_unhashed(const struct hlist_bl_node *h)
+{
+	return !h->pprev;
+}
+
+static inline struct hlist_bl_node *hlist_bl_first(struct hlist_bl_hea=
d *h)
+{
+	return (struct hlist_bl_node *)((unsigned long)h->first & ~1UL);
+}
+
+static inline void hlist_bl_set_first(struct hlist_bl_head *h, struct =
hlist_bl_node *n)
+{
+#ifdef CONFIG_DEBUG_LIST
+	BUG_ON(!((unsigned long)&h->first & 1UL));
+#endif
+	h->first =3D (struct hlist_bl_node *)((unsigned long)n | 1UL);
+}
+
+static inline int hlist_bl_empty(const struct hlist_bl_head *ptr)
+{
+	return !((unsigned long)ptr & ~1UL);
+}
+
+static inline void hlist_bl_add_head(struct hlist_bl_node *n,
+					struct hlist_bl_head *h)
+{
+	struct hlist_bl_node *first =3D hlist_bl_first(h);
+
+#ifdef CONFIG_DEBUG_LIST
+	BUG_ON(!((unsigned long)&h->first & 1UL));
+#endif
+	n->next =3D first;
+	if (first)
+		first->pprev =3D &n->next;
+	n->pprev =3D &h->first;
+	hlist_bl_set_first(h, n);
+}
+
+static inline void __hlist_bl_del(struct hlist_bl_node *n)
+{
+	struct hlist_bl_node *next =3D n->next;
+	struct hlist_bl_node **pprev =3D n->pprev;
+	*pprev =3D (struct hlist_bl_node *)((unsigned long)next | ((unsigned =
long)*pprev & 1UL));
+	if (next)
+		next->pprev =3D pprev;
+}
+
+static inline void hlist_bl_del(struct hlist_bl_node *n)
+{
+	__hlist_bl_del(n);
+	n->pprev =3D LIST_POISON2;
+}
+
+/**
+ * hlist_bl_for_each_entry	- iterate over list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ */
+#define hlist_bl_for_each_entry(tpos, pos, head, member)			\
+	for (pos =3D hlist_bl_first(head);					\
+	     pos &&								\
+		({ tpos =3D hlist_bl_entry(pos, typeof(*tpos), member); 1;});	\
+	     pos =3D pos->next)
+
+#endif
Index: linux-2.6/include/linux/rculist_bl.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ linux-2.6/include/linux/rculist_bl.h
@@ -0,0 +1,123 @@
+#ifndef _LINUX_RCULIST_BL_H
+#define _LINUX_RCULIST_BL_H
+
+#ifdef __KERNEL__
+
+/*
+ * RCU-protected list version
+ */
+#include <linux/list_bl.h>
+#include <linux/rcupdate.h>
+
+static inline void hlist_bl_set_first_rcu(struct hlist_bl_head *h, str=
uct hlist_bl_node *n)
+{
+#ifdef CONFIG_DEBUG_LIST
+	BUG_ON(!((unsigned long)h->first & 1UL));
+#endif
+	rcu_assign_pointer(h->first, (struct hlist_bl_node *)((unsigned long)=
n | 1UL));
+}
+
+static inline struct hlist_bl_node *hlist_bl_first_rcu(struct hlist_bl=
_head *h)
+{
+	return (struct hlist_bl_node *)((unsigned long)rcu_dereference(h->fir=
st) & ~1UL);
+}
+
+/**
+ * hlist_bl_del_init_rcu - deletes entry from hash list with re-initia=
lization
+ * @n: the element to delete from the hash list.
+ *
+ * Note: hlist_bl_unhashed() on the node return true after this. It is
+ * useful for RCU based read lockfree traversal if the writer side
+ * must know if the list entry is still hashed or already unhashed.
+ *
+ * In particular, it means that we can not poison the forward pointers
+ * that may still be used for walking the hash list and we can only
+ * zero the pprev pointer so list_unhashed() will return true after
+ * this.
+ *
+ * The caller must take whatever precautions are necessary (such as
+ * holding appropriate locks) to avoid racing with another
+ * list-mutation primitive, such as hlist_bl_add_head_rcu() or
+ * hlist_bl_del_rcu(), running on this same list.  However, it is
+ * perfectly legal to run concurrently with the _rcu list-traversal
+ * primitives, such as hlist_bl_for_each_entry_rcu().
+ */
+static inline void hlist_bl_del_init_rcu(struct hlist_bl_node *n)
+{
+	if (!hlist_bl_unhashed(n)) {
+		__hlist_bl_del(n);
+		n->pprev =3D NULL;
+	}
+}
+
+/**
+ * hlist_bl_del_rcu - deletes entry from hash list without re-initiali=
zation
+ * @n: the element to delete from the hash list.
+ *
+ * Note: hlist_bl_unhashed() on entry does not return true after this,
+ * the entry is in an undefined state. It is useful for RCU based
+ * lockfree traversal.
+ *
+ * In particular, it means that we can not poison the forward
+ * pointers that may still be used for walking the hash list.
+ *
+ * The caller must take whatever precautions are necessary
+ * (such as holding appropriate locks) to avoid racing
+ * with another list-mutation primitive, such as hlist_bl_add_head_rcu=
()
+ * or hlist_bl_del_rcu(), running on this same list.
+ * However, it is perfectly legal to run concurrently with
+ * the _rcu list-traversal primitives, such as
+ * hlist_bl_for_each_entry().
+ */
+static inline void hlist_bl_del_rcu(struct hlist_bl_node *n)
+{
+	__hlist_bl_del(n);
+	n->pprev =3D LIST_POISON2;
+}
+
+/**
+ * hlist_bl_add_head_rcu
+ * @n: the element to add to the hash list.
+ * @h: the list to add to.
+ *
+ * Description:
+ * Adds the specified element to the specified hlist_bl,
+ * while permitting racing traversals.
+ *
+ * The caller must take whatever precautions are necessary
+ * (such as holding appropriate locks) to avoid racing
+ * with another list-mutation primitive, such as hlist_bl_add_head_rcu=
()
+ * or hlist_bl_del_rcu(), running on this same list.
+ * However, it is perfectly legal to run concurrently with
+ * the _rcu list-traversal primitives, such as
+ * hlist_bl_for_each_entry_rcu(), used to prevent memory-consistency
+ * problems on Alpha CPUs.  Regardless of the type of CPU, the
+ * list-traversal primitive must be guarded by rcu_read_lock().
+ */
+static inline void hlist_bl_add_head_rcu(struct hlist_bl_node *n,
+					struct hlist_bl_head *h)
+{
+	struct hlist_bl_node *first =3D hlist_bl_first(h);
+
+	n->next =3D first;
+	if (first)
+		first->pprev =3D &n->next;
+	n->pprev =3D &h->first;
+	hlist_bl_set_first_rcu(h, n);
+}
+/**
+ * hlist_bl_for_each_entry_rcu - iterate over rcu list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_bl_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_bl_node within the struct.
+ *
+ */
+#define hlist_bl_for_each_entry_rcu(tpos, pos, head, member)			\
+	for (pos =3D hlist_bl_first_rcu(head);					\
+		pos &&								\
+		({ tpos =3D hlist_bl_entry(pos, typeof(*tpos), member); 1; });	\
+		pos =3D rcu_dereference_raw(pos->next))
+
+#endif
+#endif
