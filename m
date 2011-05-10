From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 12:30:43 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101226460.2875@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE901C.2090809@cs.helsinki.fi>  <1303286998.3186.18.camel@edumazet-laptop>
  <1303290464.3186.32.camel@edumazet-laptop>  <1303293765.3186.74.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200904440.8634@router.home>  <1303309591.3186.84.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200942020.9266@router.home>  <1303311687.3186.100.camel@edumazet-laptop>
  <alpine.DEB.2.00.1105092241390.6784@tiger>  <alpine.DEB.2.00.1105091502260.26839@router.home>  <1305016988.2614.6.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>  <4DC91137.4030109@cs.helsinki.fi>
 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home> <1305047682.2758.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-508703631-1305048645=:2875"
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:42171 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751449Ab1EJRar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 13:30:47 -0400
In-Reply-To: <1305047682.2758.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-508703631-1305048645=:2875
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 10 May 2011, Eric Dumazet wrote:

> Le mardi 10 mai 2011 =C3=A0 11:39 -0500, Christoph Lameter a =C3=A9crit :
>
> > #ifdef CONFIG_DEBUG_PAGE_ALLOC
> > =09if (illegal_page_alloc-address(object))
> > =09=09goto redo;
> > #endif
> >
> > before the cmpxchg should do the trick.
> >
>
> Again, it wont work...
>
> You can have an IRQ right after the check and before cmpxchg

Ok guess then we also need to disable irq if CONFIG_PAGE_ALLOC is set?

The cmpxchg is not the problem. The problem is the following expression
which retrieves the pointer to the next available object from the object
on the page:

get_freepointer(s, object)

In the CONFIG_PAGE_ALLOC case we could disable interrupts, then do the
check, then fetch the pointer and then reenable interrupts.

All of this can occur before the cmpxchg.

> This interrupt can allocate this block of memory, free it, and unmap
> page from memory.
>
> cmpxchg() reads unmapped memory -> BUG

The cmpxchg is not accessing any memory on the page.

---1463811839-508703631-1305048645=:2875--
