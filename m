From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 12/30] mm: memory reserve management
Date: Mon, 28 Jul 2008 13:06:03 +0300
Message-ID: <1217239564.7813.36.camel@penberg-laptop>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Neil Brown <neilb@suse.de>, mpm@selenic.com,
	cl@linux-foundation.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43669 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbYG1KGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 06:06:06 -0400
In-Reply-To: <20080724141530.127530749@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
> +/*
> + * alloc wrappers
> + */
> +

=EF=BB=BFHmm, I'm not sure I like the use of __kmalloc_track_caller() (=
even
though you do add the wrappers for SLUB). The functions really are SLAB
internals so I'd prefer to see kmalloc_reserve() moved to the
allocators.

> +void *___kmalloc_reserve(size_t size, gfp_t flags, int node, void *i=
p,
> +			 struct mem_reserve *res, int *emerg)
> +{

This function could use some comments...

> +	void *obj;
> +	gfp_t gfp;
> +
> +	gfp =3D flags | __GFP_NOMEMALLOC | __GFP_NOWARN;
> +	obj =3D __kmalloc_node_track_caller(size, gfp, node, ip);
> +
> +	if (obj || !(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS))
> +		goto out;
> +
> +	if (res && !mem_reserve_kmalloc_charge(res, size)) {
> +		if (!(flags & __GFP_WAIT))
> +			goto out;
> +
> +		wait_event(res->waitqueue,
> +				mem_reserve_kmalloc_charge(res, size));
> +
> +		obj =3D __kmalloc_node_track_caller(size, gfp, node, ip);
> +		if (obj) {
> +			mem_reserve_kmalloc_charge(res, -size);

Why do we discharge here?

> +			goto out;
> +		}

If the allocation fails, we try again (but nothing has changed, right?)=
=2E
Why?

> +	}
> +
> +	obj =3D __kmalloc_node_track_caller(size, flags, node, ip);
> +	WARN_ON(!obj);

Why don't we discharge from the reserve here if !obj?

> +	if (emerg)
> +		*emerg |=3D 1;
> +
> +out:
> +	return obj;
> +}
> +
> +void __kfree_reserve(void *obj, struct mem_reserve *res, int emerg)

I don't see 'emerg' used anywhere.

> +{
> +	size_t size =3D ksize(obj);
> +
> +	kfree(obj);

We're trying to get rid of kfree() so I'd __kfree_reserve() could to
mm/sl?b.c. Matt, thoughts?

> +	/*
> +	 * ksize gives the full allocated size vs the requested size we use=
d to
> +	 * charge; however since we round up to the nearest power of two, t=
his
> +	 * should all work nicely.
> +	 */
> +	mem_reserve_kmalloc_charge(res, -size);
> +}
>=20

