From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 10 May 2011 21:32:28 +0200
Message-ID: <1305055948.2437.13.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
	 <1305022632.2614.18.camel@edumazet-laptop>
	 <4DC91137.4030109@cs.helsinki.fi>
	 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
	 <alpine.DEB.2.00.1105101133440.2611@router.home>
	 <1305047682.2758.1.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101226460.2875@router.home>
	 <alpine.DEB.2.00.1105101242420.2875@router.home>
	 <1305050754.2758.12.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101323290.4023@router.home>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57634 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab1EJTcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:32:32 -0400
Received: by wya21 with SMTP id 21so4937981wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 12:32:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105101323290.4023@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 13:28 -0500, Christoph Lameter a =C3=A9crit=
 :
> On Tue, 10 May 2011, Eric Dumazet wrote:
>=20
> > > +	else
> > > +		p =3D get_freepointer(s, object);
> > > +
> > > +	local_irq_restore(flags);
> > > +#else
> > > +	p =3D get_freepointer(s, object);
> > > +#endif
> > > +	return p;
> > > +}
> > > +
> > >  static inline void set_freepointer(struct kmem_cache *s, void *o=
bject, void *fp)
> > >  {
> > >  	*(void **)(object + s->offset) =3D fp;
> > > @@ -1933,7 +1954,7 @@ redo:
> > >  		if (unlikely(!irqsafe_cpu_cmpxchg_double(
> > >  				s->cpu_slab->freelist, s->cpu_slab->tid,
> > >  				object, tid,
> > > -				get_freepointer(s, object), next_tid(tid)))) {
> > > +				get_freepointer_safe(s, object), next_tid(tid)))) {
> > >
> > >  			note_cmpxchg_failure("slab_alloc", s, tid);
> > >  			goto redo;
> >
> >
> > Really this wont work Stephen
>=20
> I am not Stephen.
>=20

Yes, sorry Christoph.

> > You have to disable IRQ _before_ even fetching 'object'
>=20
> The object pointer is being obtained from a per cpu structure and
> not from the page. What is the problem with fetching the object point=
er?
>=20
> > Or else, you can have an IRQ, allocate this object, pass to another=
 cpu.
>=20
> If that occurs then TID is being incremented and we will restart the =
loop
> getting the new object pointer from the per cpu structure. The object
> pointer that we were considering is irrelevant.
>=20

Problem is not restart the loop, but avoiding accessing a non valid
memory area.

> > This other cpu can free the object and unmap page right after you d=
id
> > the probe_kernel_address(object) (successfully), and before your cp=
u :
> >
> > p =3D get_freepointer(s, object); << BUG >>
>=20
> If the other cpu frees the object and unmaps the page then
> get_freepointer_safe() can obtain an arbitrary value since the TID wa=
s
> incremented. We will restart the loop and discard the value retrieved=
=2E
>=20



In current code I see :

tid =3D c->tid;
barrier();
object =3D c->freelist;

There is no guarantee c->tid is fetched before c->freelist by cpu.

You need rmb() here.


I claim all this would be far more simple disabling IRQ before fetching
c->tid and c->freelist, in DEBUG_PAGE_ALLOC case.

You would not even need to use magic probe_kernel_read()


Why do you try so _hard_ trying to optimize this, I really wonder.
Nobody is able to read this code anymore and prove its correct.



