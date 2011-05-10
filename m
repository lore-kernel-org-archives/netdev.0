From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 11:39:22 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101133440.2611@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/> <1303183217.4152.49.camel@edumazet-laptop> <alpine.DEB.2.00.1104191210011.17888@router.home> <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi> <1303279470.2756.17.camel@edumazet-laptop>
 <1303285519.4dae8f0fdf9b1@imp.free.fr> <4DAE901C.2090809@cs.helsinki.fi> <1303286998.3186.18.camel@edumazet-laptop> <1303290464.3186.32.camel@edumazet-laptop> <1303293765.3186.74.camel@edumazet-laptop> <alpine.DEB.2.00.1104200904440.8634@router.home>
 <1303309591.3186.84.camel@edumazet-laptop> <alpine.DEB.2.00.1104200942020.9266@router.home> <1303311687.3186.100.camel@edumazet-laptop> <alpine.DEB.2.00.1105092241390.6784@tiger> <alpine.DEB.2.00.1105091502260.26839@router.home> <1305016988.2614.6.camel@edumazet-laptop>
 <4DC90D7D.9030808@cs.helsinki.fi> <1305022632.2614.18.camel@edumazet-laptop> <4DC91137.4030109@cs.helsinki.fi> <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Vegard Nossum <vegardno@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.prem.mail.ac4.yahoo.com ([76.13.13.47]:23505 "HELO
	smtp108.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753509Ab1EJQj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 12:39:26 -0400
In-Reply-To: <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011, Vegard Nossum wrote:

> Presumably the problem is that the page can get freed, and that with
> DEBUG_PAGEALLOC, the page will therefore not be present and subsequently
> trigger a page fault when doing this cmpxchg() on the possibly freed object.

The problem is not the cmpxchg. The cmpxchg is occurring on the per cpu
structure for the slab and that remains even if the page is freed.

The problem is the speculative fetch of the address of the following
object from a pointer into the page. The cmpxchg will fail in that case
because the TID was incremented and the result of the address fetch will
be discarded.

> Regardless of DEBUG_PAGEALLOC or kmemcheck, what happens if the page gets
> freed, then allocated again for a completely different purpose in another part
> of the kernel, and new user of the page by chance writes the same "tid" number
> that the cmpxchg() is expecting?

The tid is not stored in the page struct but in a per cpu structure.

Doing an explicit check if this is an illegal address in the PAGE_ALLOC
case and redoing the loop will address the issue.

So

#ifdef CONFIG_DEBUG_PAGE_ALLOC
	if (illegal_page_alloc-address(object))
		goto redo;
#endif

before the cmpxchg should do the trick.

