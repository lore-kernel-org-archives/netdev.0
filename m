From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 14:38:55 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101435480.4023@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home>  <1305047682.2758.1.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101226460.2875@router.home>  <alpine.DEB.2.00.1105101242420.2875@router.home>
  <1305050754.2758.12.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101323290.4023@router.home> <1305055948.2437.13.camel@edumazet-laptop>
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
Received: from smtp104.prem.mail.ac4.yahoo.com ([76.13.13.43]:41728 "HELO
	smtp104.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751381Ab1EJTjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:39:03 -0400
In-Reply-To: <1305055948.2437.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011, Eric Dumazet wrote:

> > > You have to disable IRQ _before_ even fetching 'object'
> >
> > The object pointer is being obtained from a per cpu structure and
> > not from the page. What is the problem with fetching the object pointer?
> >
> > > Or else, you can have an IRQ, allocate this object, pass to another cpu.
> >
> > If that occurs then TID is being incremented and we will restart the loop
> > getting the new object pointer from the per cpu structure. The object
> > pointer that we were considering is irrelevant.
> >
>
> Problem is not restart the loop, but avoiding accessing a non valid
> memory area.

Yes and could you please explain clearly what the problem is?

>
> > > This other cpu can free the object and unmap page right after you did
> > > the probe_kernel_address(object) (successfully), and before your cpu :
> > >
> > > p = get_freepointer(s, object); << BUG >>
> >
> > If the other cpu frees the object and unmaps the page then
> > get_freepointer_safe() can obtain an arbitrary value since the TID was
> > incremented. We will restart the loop and discard the value retrieved.
> >
>
>
>
> In current code I see :
>
> tid = c->tid;
> barrier();
> object = c->freelist;
>
> There is no guarantee c->tid is fetched before c->freelist by cpu.
>
> You need rmb() here.

Nope. This is not processor to processor concurrency. this_cpu operations
only deal with concurrency issues on the same processor. I.e. interrupts
and preemption.

> I claim all this would be far more simple disabling IRQ before fetching
> c->tid and c->freelist, in DEBUG_PAGE_ALLOC case.
>
> You would not even need to use magic probe_kernel_read()
>
>
> Why do you try so _hard_ trying to optimize this, I really wonder.
> Nobody is able to read this code anymore and prove its correct.

Optimizing? You think about this as concurrency issue between multiple
cpus. That is fundamentally wrong. This is dealing with access to per cpu
data and the concurrency issues are only with code running on the *same*
cpu.

