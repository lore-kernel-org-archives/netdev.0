From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Sat, 22 Dec 2012 03:45:29 +0400
Message-ID: <20121221234529.GA4938@ms2.inr.ac.ru>
References: <1356072468.21834.4805.camel@edumazet-glaptop> <20121221.115910.1536088448298730991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: erdnetdev@gmail.com, netdev@vger.kernel.org, rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:36366 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750766Ab2LVAOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2012 19:14:00 -0500
Content-Disposition: inline
In-Reply-To: <20121221.115910.1536088448298730991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 21, 2012 at 11:59:10AM -0800, David Miller wrote:
> From: Eric Dumazet <erdnetdev@gmail.com>
> > Changing IP_MAX_MTU from 0xFFF0 to 0x10000 seems safe [1], but I might
> > miss something really obvious ?

Maximal IP MTU is 65535 (due to iph->len).


> > It might be because in old days we reserved 16 bytes for the ethernet
> > header, and we wanted to avoid kmalloc() round-up to kmalloc-131072
> > slab ?
> > 
> > If so, we certainly can limit skb->head to 32 or 64 KB and complete with
> > page fragments the remaining space.
> 
> I don't think it has to do with kmalloc() at all.
> 
> Maybe something strange to do with the fact that each frag has to
> be an 8-byte multiple, or something like that?
> 
> Alexey choose this value back in 1998, maybe he remembers the
> reason for the strange value.

Vaguely. I do not think it was something clever.

Apparently, this was done while implementing IPv6 jumbo frames.
dev->mtu was allowed to be arbitrarily high and for use with IPv4 it had
to be clamped at some reasonable value. This value should be 65535, of course.

Here was a problem: apparently, when experimenting with jumbo frames I used
virtual device (loopback?) setting some crazy values for mtu there. And it looked
dubious that nicely aligned device mtu sort of 256K converted to perverted odd
value 65535 for IP. This value would be translated to odd value for mss and so on.
Nothing fatal, but forcing tcp segmentation to an odd value looked too weird.

So, I just decided to apply some bound which looked sane, safe and aligned. :-)
Note that values of mtu > 65280 (or something like that, which was used by some funny hippi device)
were purely of theoritical value, they were used only to experiment with jumbo frames or for stress
testing, so actual value did not have any meaning.
