From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [RFC net-next PATCH 0/4] qlge: Performance changes for qlge.
Date: Tue, 18 Aug 2009 14:26:20 -0700
Message-ID: <20090818212620.GA17853@linux-ox1b.qlogic.org>
References: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com> <20090817.175700.207432952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:57816 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbZHRVb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 17:31:58 -0400
Content-Disposition: inline
In-Reply-To: <20090817.175700.207432952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
Thanks for the quick feedback.  I will re-spin per my comments below.

> 
> > 1) Do TX completions in send path (with cleaner timer).
> 
> You should really do them in NAPI context.
> 
> When you do them from hardware interrupt context, they all
> get rescheduled into a softirq for the real SKB freeing
> work anyways.
> 
> So by doing it in NAPI poll, you're avoiding some needless
> overhead.
> 
> BTW, it's insanely confusing that there is a function called
> qlge_msix_tx_isr() that of all things does RX work :-/
> 

I tried to do the patch series as a logical progression but might have
made it more confusing.  Patch 1 moves TX completion processing to the
hardware interrupt context (as you pointed out).  Patch 2 moves it from
interrupt context to the send path as many drivers do.
It wasn't my intention to do the processinging in the ISR.  Sorry about
the confusion.


> > 2) Change RSS queue count to match MSIx vector count instead
> >    of CPU count.  Some platforms didn't offer enough vectors
> >    for our previous approach.
> 
> Ideally you want "max(num_msix_vectors, num_cpus)" because
> if you hook up more MSIX vectors than you have cpus it's just
> extra overhead and depending upon the descrepency between the
> two counts it might unevenly distribute traffic work amongst
> the cpus.

I think you mean "min(num_msix_vectors, num_cpus)".  That is what I'm
trying to do in the patch.  I will clean it up and improve comments before I
resubmit.

> 
> > 3) Change large RX buffer logic to use either multiple pages
> >    or chunks of pages based on MTU and system page size.
> > 
> >    Examples:
> > 
> >    64k Pages with 1500 MTU.  The RX buffers size would be
> >    2048 bytes and there would be 32 per page.
> > 
> >    4k pages with 9000 MTU.  The RX buffer size would be 16k,
> >    or 4 pages per buffer.
> 
> This is wasteful, does the card have a mechnism by which it
> can dynamically carve up pages depending upon the actual
> frame size?
> 
> If anything, make sure that skb->truesize gets set to something
> reasonable, or else TCP is going to reallocate SKBs when the
> receive queue limits are hit.


