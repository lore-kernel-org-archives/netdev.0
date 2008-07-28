From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 12/30] mm: memory reserve management
Date: Mon, 28 Jul 2008 12:17:04 +0200
Message-ID: <1217240224.6331.32.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Neil Brown <neilb@suse.de>, mpm@selenic.com,
	cl@linux-foundation.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:64287 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752835AbYG1KRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 06:17:13 -0400
Received: from edge05.upc.biz ([192.168.13.212]) by viefep19-int.chello.at
          (InterMail vM.7.08.02.02 201-2186-121-104-20070414) with ESMTP
          id <20080728101710.ECNI9441.viefep19-int.chello.at@edge05.upc.biz>
          for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 12:17:10 +0200
In-Reply-To: <1217239564.7813.36.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-28 at 13:06 +0300, Pekka Enberg wrote:
> Hi Peter,
>=20
> On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
> > +/*
> > + * alloc wrappers
> > + */
> > +
>=20
> =EF=BB=BFHmm, I'm not sure I like the use of __kmalloc_track_caller()=
 (even
> though you do add the wrappers for SLUB). The functions really are SL=
AB
> internals so I'd prefer to see kmalloc_reserve() moved to the
> allocators.

See below..

> > +void *___kmalloc_reserve(size_t size, gfp_t flags, int node, void =
*ip,
> > +			 struct mem_reserve *res, int *emerg)
> > +{
>=20
> This function could use some comments...

Yes, my latest does have those.. let me paste the relevant bit:

+void *___kmalloc_reserve(size_t size, gfp_t flags, int node, void *ip,
+                        struct mem_reserve *res, int *emerg)
+{
+       void *obj;
+       gfp_t gfp;
+
+       /*
+        * Try a regular allocation, when that fails and we're not enti=
tled
+        * to the reserves, fail.
+        */
+       gfp =3D flags | __GFP_NOMEMALLOC | __GFP_NOWARN;
+       obj =3D __kmalloc_node_track_caller(size, gfp, node, ip);
+
+       if (obj || !(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS))
+               goto out;
+
+       /*
+        * If we were given a reserve to charge against, try that.
+        */
+       if (res && !mem_reserve_kmalloc_charge(res, size)) {
+               /*
+                * If we failed to charge and we're not allowed to wait=
 for
+                * it to succeed, bail.
+                */
+               if (!(flags & __GFP_WAIT))
+                       goto out;
+
+               /*
+                * Wait for a successfull charge against the reserve. A=
ll
+                * uncharge operations against this reserve will wake u=
s up.
+                */
+               wait_event(res->waitqueue,
+                               mem_reserve_kmalloc_charge(res, size));
+
+               /*
+                * After waiting for it, again try a regular allocation=
=2E
+                * Pressure could have lifted during our sleep. If this
+                * succeeds, uncharge the reserve.
+                */
+               obj =3D __kmalloc_node_track_caller(size, gfp, node, ip=
);
+               if (obj) {
+                       mem_reserve_kmalloc_charge(res, -size);
+                       goto out;
+               }
+       }
+
+       /*
+        * Regular allocation failed, and we've successfully charged ou=
r
+        * requested usage against the reserve. Do the emergency alloca=
tion.
+        */
+       obj =3D __kmalloc_node_track_caller(size, flags, node, ip);
+       WARN_ON(!obj);
+       if (emerg)
+               *emerg |=3D 1;
+
+out:
+       return obj;
+}


> > +	void *obj;
> > +	gfp_t gfp;
> > +
> > +	gfp =3D flags | __GFP_NOMEMALLOC | __GFP_NOWARN;
> > +	obj =3D __kmalloc_node_track_caller(size, gfp, node, ip);
> > +
> > +	if (obj || !(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS))
> > +		goto out;
> > +
> > +	if (res && !mem_reserve_kmalloc_charge(res, size)) {
> > +		if (!(flags & __GFP_WAIT))
> > +			goto out;
> > +
> > +		wait_event(res->waitqueue,
> > +				mem_reserve_kmalloc_charge(res, size));
> > +
> > +		obj =3D __kmalloc_node_track_caller(size, gfp, node, ip);
> > +		if (obj) {
> > +			mem_reserve_kmalloc_charge(res, -size);
>=20
> Why do we discharge here?

because a regular allocation succeeded.

> > +			goto out;
> > +		}
>=20
> If the allocation fails, we try again (but nothing has changed, right=
?).
> Why?

Note the different allocation flags for the two allocations.

> > +	}
> > +
> > +	obj =3D __kmalloc_node_track_caller(size, flags, node, ip);
> > +	WARN_ON(!obj);
>=20
> Why don't we discharge from the reserve here if !obj?

Well, this allocation should never fail:
  - we reserved memory
  - we accounted/throttle its usage

Thus this allocation should always succeed.

> > +	if (emerg)
> > +		*emerg |=3D 1;
> > +
> > +out:
> > +	return obj;
> > +}
> > +
> > +void __kfree_reserve(void *obj, struct mem_reserve *res, int emerg=
)
>=20
> I don't see 'emerg' used anywhere.

Patch 19/30 has:

-       data =3D kmalloc_node_track_caller(size + sizeof(struct skb_sha=
red_info),
-                       gfp_mask, node);
+       data =3D kmalloc_reserve(size + sizeof(struct skb_shared_info),
+                       gfp_mask, node, &net_skb_reserve, &emergency);
        if (!data)
                goto nodata;

@@ -205,6 +211,7 @@ struct sk_buff *__alloc_skb(unsigned int
         * the tail pointer in struct sk_buff!
         */
        memset(skb, 0, offsetof(struct sk_buff, tail));
+       skb->emergency =3D emergency;
        skb->truesize =3D size + sizeof(struct sk_buff);
        atomic_set(&skb->users, 1);
        skb->head =3D data;


> > +{
> > +	size_t size =3D ksize(obj);
> > +
> > +	kfree(obj);
>=20
> We're trying to get rid of kfree() so I'd __kfree_reserve() could to
> mm/sl?b.c. Matt, thoughts?

My issue with moving these helpers into mm/sl?b.c is that it would
require replicating all this code 3 times. Even though the functionalit=
y
is (or should) be invariant to the actual slab implementation.

> > +	/*
> > +	 * ksize gives the full allocated size vs the requested size we u=
sed to
> > +	 * charge; however since we round up to the nearest power of two,=
 this
> > +	 * should all work nicely.
> > +	 */
> > +	mem_reserve_kmalloc_charge(res, -size);
> > +}
> >=20
>=20

