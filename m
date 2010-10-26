From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 21:58:44 -0400
Message-ID: <20101026015844.GB31631@hmsreliant.think-freely.org>
References: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
 <1288045856.3296.19.camel@edumazet-laptop>
 <20101025233558.GA30118@hmsreliant.think-freely.org>
 <20101025.164646.104054845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54232 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944Ab0JZB6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 21:58:54 -0400
Content-Disposition: inline
In-Reply-To: <20101025.164646.104054845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 04:46:46PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 25 Oct 2010 19:35:58 -0400
> 
> > On Tue, Oct 26, 2010 at 12:30:56AM +0200, Eric Dumazet wrote:
> >> I would try a two level thing : Try to get high order pages, and
> >> fallback on low order pages, but normally libpcap does this for us ?
> >> 
> >> 
> > It does, but it tries them in that order, which causes the problem I'm
> > describing, which is to say that attempting to get a large high order allocation
> > causes the system to dig into swap and become unresponsive while it tries to
> > assemble those allocations.  I would suggest a vmalloc, with a backoff to high
> > order allocation if that fails.
> 
> I think that logic should be maintained, except that one of the GFP_*
> flags should be specified so that it doesn't go all swap crazy on us,
> and instead fails a high order allocation earlier.
> 
I suppose we can do that.  Specifically we can add __GFP_NORETRY so that we
don't continually drive I/O or swap to get pages freed, but I think that all
that will result in is earlier failures.  No matter how you look at it, order 4
allocations are hard to come by, and we can make it work with non-contigous
pages (the vmalloc case).  Given that each of the cases can fail, I can see this
being a workable fallback set:

1) get_free_pages (GFP_KERNEL|...+|__GFP_NORETRY)
2) vmalloc
3) get_free_pages (GFP_KERNEL|...)

Theres no reason to fail af_packet socket options just because the system is
under presure.  My only concern is that, since af_packet is typically used for
debugging/tracing, I'd rather not have its memory allocation adversely affect
system behavio.
