From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 10 May 2011 20:05:54 +0200
Message-ID: <1305050754.2758.12.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105092241390.6784@tiger>
	 <alpine.DEB.2.00.1105091502260.26839@router.home>
	 <1305016988.2614.6.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
	 <1305022632.2614.18.camel@edumazet-laptop>
	 <4DC91137.4030109@cs.helsinki.fi>
	 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
	 <alpine.DEB.2.00.1105101133440.2611@router.home>
	 <1305047682.2758.1.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101226460.2875@router.home>
	 <alpine.DEB.2.00.1105101242420.2875@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39729 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab1EJSF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 14:05:58 -0400
Received: by wya21 with SMTP id 21so4880689wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 11:05:57 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105101242420.2875@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 12:43 -0500, Christoph Lameter a =C3=A9crit=
 :
> Draft for a patch
>=20
>=20
> Subject: slub: Make CONFIG_PAGE_ALLOC work with new fastpath
>=20
> Fastpath can do a speculative access to a page that CONFIG_PAGE_ALLOC=
 may have
> marked as invalid to retrieve the pointer to the next free object.
>=20
> Probe that address before dereferencing the pointer to the page.
> All of that needs to occur with interrupts disabled since an interrup=
t
> could cause the page status to change (as pointed out by Eric).
>=20
> Signed-off-by: Christoph Lameter <cl@linux.com>
> ---
>  mm/slub.c |   23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
>=20
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c	2011-05-10 12:35:30.000000000 -0500
> +++ linux-2.6/mm/slub.c	2011-05-10 12:38:53.000000000 -0500
> @@ -261,6 +261,27 @@ static inline void *get_freepointer(stru
>  	return *(void **)(object + s->offset);
>  }
>=20
> +static inline void *get_freepointer_safe(struct kmem_cache *s, void =
*object)
> +{
> +	void *p;
> +
> +#ifdef CONFIG_PAGE_ALLOC
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +
> +	if (probe_kernel_address(object))
> +		p =3D NULL;	/* Invalid */
> +	else
> +		p =3D get_freepointer(s, object);
> +
> +	local_irq_restore(flags);
> +#else
> +	p =3D get_freepointer(s, object);
> +#endif
> +	return p;
> +}
> +
>  static inline void set_freepointer(struct kmem_cache *s, void *objec=
t, void *fp)
>  {
>  	*(void **)(object + s->offset) =3D fp;
> @@ -1933,7 +1954,7 @@ redo:
>  		if (unlikely(!irqsafe_cpu_cmpxchg_double(
>  				s->cpu_slab->freelist, s->cpu_slab->tid,
>  				object, tid,
> -				get_freepointer(s, object), next_tid(tid)))) {
> +				get_freepointer_safe(s, object), next_tid(tid)))) {
>=20
>  			note_cmpxchg_failure("slab_alloc", s, tid);
>  			goto redo;


Really this wont work Stephen

You have to disable IRQ _before_ even fetching 'object'

Or else, you can have an IRQ, allocate this object, pass to another cpu=
=2E

This other cpu can free the object and unmap page right after you did
the probe_kernel_address(object) (successfully), and before your cpu :

p =3D get_freepointer(s, object); << BUG >>

I really dont understand your motivation to keep the buggy commit.



