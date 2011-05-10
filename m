From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 13:28:18 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101323290.4023@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home>  <1305047682.2758.1.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101226460.2875@router.home>  <alpine.DEB.2.00.1105101242420.2875@router.home>
 <1305050754.2758.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.prem.mail.ac4.yahoo.com ([76.13.13.43]:39553 "HELO
	smtp104.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750915Ab1EJS2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 14:28:23 -0400
In-Reply-To: <1305050754.2758.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011, Eric Dumazet wrote:

> > +	else
> > +		p = get_freepointer(s, object);
> > +
> > +	local_irq_restore(flags);
> > +#else
> > +	p = get_freepointer(s, object);
> > +#endif
> > +	return p;
> > +}
> > +
> >  static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
> >  {
> >  	*(void **)(object + s->offset) = fp;
> > @@ -1933,7 +1954,7 @@ redo:
> >  		if (unlikely(!irqsafe_cpu_cmpxchg_double(
> >  				s->cpu_slab->freelist, s->cpu_slab->tid,
> >  				object, tid,
> > -				get_freepointer(s, object), next_tid(tid)))) {
> > +				get_freepointer_safe(s, object), next_tid(tid)))) {
> >
> >  			note_cmpxchg_failure("slab_alloc", s, tid);
> >  			goto redo;
>
>
> Really this wont work Stephen

I am not Stephen.

> You have to disable IRQ _before_ even fetching 'object'

The object pointer is being obtained from a per cpu structure and
not from the page. What is the problem with fetching the object pointer?

> Or else, you can have an IRQ, allocate this object, pass to another cpu.

If that occurs then TID is being incremented and we will restart the loop
getting the new object pointer from the per cpu structure. The object
pointer that we were considering is irrelevant.

> This other cpu can free the object and unmap page right after you did
> the probe_kernel_address(object) (successfully), and before your cpu :
>
> p = get_freepointer(s, object); << BUG >>

If the other cpu frees the object and unmaps the page then
get_freepointer_safe() can obtain an arbitrary value since the TID was
incremented. We will restart the loop and discard the value retrieved.

