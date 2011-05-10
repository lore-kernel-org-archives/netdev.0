From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 14:05:47 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101403110.4023@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home>  <1305047682.2758.1.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101226460.2875@router.home>  <alpine.DEB.2.00.1105101242420.2875@router.home>
 <1305050754.2758.12.camel@edumazet-laptop> <alpine.DEB.2.00.1105101323290.4023@router.home>
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
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:35349 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751051Ab1EJTFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:05:50 -0400
In-Reply-To: <alpine.DEB.2.00.1105101323290.4023@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011, Christoph Lameter wrote:

> > This other cpu can free the object and unmap page right after you did
> > the probe_kernel_address(object) (successfully), and before your cpu :
> >
> > p = get_freepointer(s, object); << BUG >>
>
> If the other cpu frees the object and unmaps the page then
> get_freepointer_safe() can obtain an arbitrary value since the TID was
> incremented. We will restart the loop and discard the value retrieved.

Ok. Forgot the element there of a different cpu. A different cpu cannot
unmap the page or free the page since the page is in a frozen state while
we allocate from it.

The page is only handled by the cpu it was assigned to until the cpu which
froze it releases it.

The only case that we need to protect against here is the case when an
interrupt or reschedule causes the *same* cpu to release the page. In that
case the TID must have been incremented.



