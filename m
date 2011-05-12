From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Thu, 12 May 2011 09:36:50 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105120932260.24560@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home>  <1305047682.2758.1.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101226460.2875@router.home>  <alpine.DEB.2.00.1105101242420.2875@router.home>
  <1305050754.2758.12.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101323290.4023@router.home>  <1305055948.2437.13.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101435480.4023@router.home>  <1305057989.2437.18.camel@edumazet-laptop>
 <alpine.DEB.2.00.1105101531160.4023@router.home>  <1305060353.2437.26.camel@edumazet-laptop>  <alpine.DEB.2.00.1105101619430.4023@router.home> <1305083543.2437.39.camel@edumazet-laptop>
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
Received: from smtp101.prem.mail.ac4.yahoo.com ([76.13.13.40]:23523 "HELO
	smtp101.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757387Ab1ELOg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 10:36:56 -0400
In-Reply-To: <1305083543.2437.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 May 2011, Eric Dumazet wrote:

> > The cpu sets a page flag called PageFrozen() and points a per cpu pointer
> > to the page.
> >
> >
>
> So, if I understand you, there is no problem at all and no patch even
> needed ? I can start a stress test and you guarantee there wont be a
> crash ?
>
> Sorry, its 5h11 in the morning here ;)

There is a problem if an interrupt or a preemption occurs and there is no
object left on the page. Then the current page will be unfrozen and a new
page put into place for allocation. The old page may then be freed by some other
process on another processor before we continue the interrupted
slab_alloc().

When slab_alloc() resumes in this scenario then it will ultimately see
that the tid was incremented and so the cmpxchg will fail. But before we
do the cmpxchgwe determine the pointer to the next object. And for that
we access the old page. The access must not cause a page fault (which it
currently does with CONFIG_DEBUG_PAGEALLOC). That is why we need the patch introducing

	get_freepointer_safe()

The result does not matter since we will repeat the cmpxchg loop.



