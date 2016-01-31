From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 19:45:07 -0800 (PST)
Message-ID: <20160130.194507.777391919166997236.davem@davemloft.net>
References: <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
	<1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sowmini.varadhan@oracle.com,
	aduyck@mirantis.com, netdev@vger.kernel.org, tom@herbertland.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757192AbcAaDpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 22:45:11 -0500
In-Reply-To: <CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Sat, 30 Jan 2016 17:13:35 -0800

> The NIC hardware only allows us to set receive buffer sizes in 1K
> increments.  I think fm10k may be an exception in that it may be able
> to support 512 byte, but otherwise igb and ixgbe are strictly set in
> 1K increments.  So basically if we did the NET_IP_ALIGN of the page we
> are limited to 1K buffers if we were to retain the current page reuse,
> or we could go up to 3K if we were to allocate order 1 pages for
> receive buffers as currently occurs with FCoE.
> 
> I would really prefer to keep the pages DMA aligned, and the skb->data
> IP aligned.  If nothing else it has the advantage of actually having
> the proper alignment on all the headers if I only pull the outer
> headers and leave the inner headers in the page.. :-/

I am unconvinced by your arguments.  People getting hit by these
arguments don't care.  For those not hitting the problem, nothing is
going to change.

x86 uses NET_IP_ALIGN==0, and therefore nothing will change for the
only platform people care a lot about.  PowerPC too.

For platforms with NET_IP_ALIGN==2 or similar, all of these cases
where 1K extra buffer is allocator or _whatever_ other side effect you
think is such as huge deal...  trust me it's _nothing_ compared to the
alternative:

1) Unaligned accesses

2) Constantly having to say "oops this case, oops that case, oops shit
   we have to handle this too" as we constantly patch up flow
   dissector and other paths.

Please, pass aligned buffers to the flow dissector, and let's put this
behind us, _provably_, for good.

Thanks.
