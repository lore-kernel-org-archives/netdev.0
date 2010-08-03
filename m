From: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH -mmotm 05/30] mm: sl[au]b: add knowledge of reserve
 pages
Date: Tue, 3 Aug 2010 11:44:10 +1000
Message-ID: <20100803114410.420ae7ba@notabene>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
	<20100713101747.2835.45722.sendpatchset@danny.redhat>
	<AANLkTilj5GrhbRJZfSsfXP1v9cQSRlARFmxpys1vUelr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTilj5GrhbRJZfSsfXP1v9cQSRlARFmxpys1vUelr-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jul 2010 23:33:14 +0300
Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org> wrote:

> Hi Xiaotian!
>=20
> I would actually prefer that the SLAB, SLOB, and SLUB changes were in
> separate patches to make reviewing easier.
>=20
> Looking at SLUB:
>=20
> On Tue, Jul 13, 2010 at 1:17 PM, Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wro=
te:
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 7bb7940..7a5d6dc 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -27,6 +27,8 @@
> > =C2=A0#include <linux/memory.h>
> > =C2=A0#include <linux/math64.h>
> > =C2=A0#include <linux/fault-inject.h>
> > +#include "internal.h"
> > +
> >
> > =C2=A0/*
> > =C2=A0* Lock order:
> > @@ -1139,7 +1141,8 @@ static void setup_object(struct kmem_cache *s=
, struct page *page,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->ctor(obje=
ct);
> > =C2=A0}
> >
> > -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, in=
t node)
> > +static
> > +struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node,=
 int *reserve)
> > =C2=A0{
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0void *start;
> > @@ -1153,6 +1156,8 @@ static struct page *new_slab(struct kmem_cach=
e *s, gfp_t flags, int node)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
> >
> > + =C2=A0 =C2=A0 =C2=A0 *reserve =3D page->reserve;
> > +
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0inc_slabs_node(s, page_to_nid(page), pag=
e->objects);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0page->slab =3D s;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0page->flags |=3D 1 << PG_slab;
> > @@ -1606,10 +1611,20 @@ static void *__slab_alloc(struct kmem_cache=
 *s, gfp_t gfpflags, int node,
> > =C2=A0{
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0void **object;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *new;
> > + =C2=A0 =C2=A0 =C2=A0 int reserve;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We handle __GFP_ZERO in the caller */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0gfpflags &=3D ~__GFP_ZERO;
> >
> > + =C2=A0 =C2=A0 =C2=A0 if (unlikely(c->reserve)) {
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the c=
urrent slab is a reserve slab and the current
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* allocati=
on context does not allow access to the reserves we
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* must for=
ce an allocation to test the current levels.
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(gfp_to_all=
oc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto grow_slab;
>=20
> OK, so assume that:
>=20
>   (1) c->reserve is set to one
>=20
>   (2) GFP flags don't allow dipping into the reserves
>=20
>   (3) we've managed to free enough pages so normal
>        allocations are fine
>=20
>   (4) the page from reserves is not yet empty
>=20
> we will call flush_slab() and put the "emergency page" on partial lis=
t
> and clear c->reserve. This effectively means that now some other
> allocation can fetch the partial page and start to use it. Is this OK=
?
> Who makes sure the emergency reserves are large enough for the next
> out-of-memory condition where we swap over NFS?

Yes, this is OK.  The emergency reserves are maintained at a lower leve=
l -
within alloc_page.
The fact that (3) normal allocations are fine means that there are enou=
gh
free pages to satisfy any swap-out allocation - so any pages that were
previously allocated as 'emergency' pages can have their emergency stat=
us
forgotten (the emergency has passed).

This is a subtle but important aspect of the emergency reservation sche=
me in
swap-over-NFS.  It is the act-of-allocating that is emergency-or-not.  =
The
memory itself, once allocated, is not special.

c->reserve means "the last page allocated required an emergency allocat=
ion".
This means that parts of that page, or any other page, can only be give=
n as
emergency allocations.  Once the slab succeeds at a non-emergency alloc=
ation,
the flag should obviously be cleared.

Similarly the page->reserve flag does not mean "this is a reserve page"=
, but
simply "when this page was allocated, it was an emergency allocation". =
 The
flag is often soon lost as it is in a union with e.g. freelist.  But th=
at
doesn't matter as it is only really meaningful at the moment of allocat=
ion.

I hope that clarifies the situation,

NeilBrown

>=20
> > + =C2=A0 =C2=A0 =C2=A0 }
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!c->page)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto new_sla=
b;
> >
> > @@ -1623,8 +1638,8 @@ load_freelist:
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0object =3D c->page->freelist;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!object))
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto another=
_slab;
> > - =C2=A0 =C2=A0 =C2=A0 if (unlikely(SLABDEBUG && PageSlubDebug(c->p=
age)))
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto debug;
> > + =C2=A0 =C2=A0 =C2=A0 if (unlikely(SLABDEBUG && PageSlubDebug(c->p=
age) || c->reserve))
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto slow_path;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0c->freelist =3D get_freepointer(s, objec=
t);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0c->page->inuse =3D c->page->objects;
> > @@ -1646,16 +1661,18 @@ new_slab:
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto load_fr=
eelist;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >
> > +grow_slab:
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (gfpflags & __GFP_WAIT)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_en=
able();
> >
> > - =C2=A0 =C2=A0 =C2=A0 new =3D new_slab(s, gfpflags, node);
> > + =C2=A0 =C2=A0 =C2=A0 new =3D new_slab(s, gfpflags, node, &reserve=
);
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (gfpflags & __GFP_WAIT)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_di=
sable();
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (new) {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0c =3D __this=
_cpu_ptr(s->cpu_slab);
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 c->reserve =3D r=
eserve;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0stat(s, ALLO=
C_SLAB);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (c->page)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0flush_slab(s, c);
> > @@ -1667,10 +1684,20 @@ new_slab:
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(gfpflags & __GFP_NOWARN) && printk=
_ratelimit())
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0slab_out_of_=
memory(s, gfpflags, node);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> > -debug:
> > - =C2=A0 =C2=A0 =C2=A0 if (!alloc_debug_processing(s, c->page, obje=
ct, addr))
> > +
> > +slow_path:
> > + =C2=A0 =C2=A0 =C2=A0 if (!c->reserve && !alloc_debug_processing(s=
, c->page, object, addr))
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto another=
_slab;
> >
> > + =C2=A0 =C2=A0 =C2=A0 /*
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Avoid the slub fast path in slab_all=
oc() by not setting
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* c->freelist and the fast path in sla=
b_free() by making
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* node_match() fail by setting c->node=
 to -1.
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We use this for for debug and reserv=
e checks which need
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to be done for each allocation.
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> > +
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0c->page->inuse++;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0c->page->freelist =3D get_freepointer(s,=
 object);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0c->node =3D -1;
> > @@ -2095,10 +2122,11 @@ static void early_kmem_cache_node_alloc(gfp=
_t gfpflags, int node)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct kmem_cache_node *n;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long flags;
> > + =C2=A0 =C2=A0 =C2=A0 int reserve;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(kmalloc_caches->size < sizeof(str=
uct kmem_cache_node));
> >
> > - =C2=A0 =C2=A0 =C2=A0 page =3D new_slab(kmalloc_caches, gfpflags, =
node);
> > + =C2=A0 =C2=A0 =C2=A0 page =3D new_slab(kmalloc_caches, gfpflags, =
node, &reserve);
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!page);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page_to_nid(page) !=3D node) {
> > --
> > 1.7.1.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org =C2=A0For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a=
>
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
