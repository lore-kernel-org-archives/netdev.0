From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Mon, 07 Feb 2011 20:39:20 +0000
Message-ID: <1297111160.4077.14.camel@bwh-desktop>
References: <20110124184752.1d0947dd@delilah>
	 <1295918675.4105.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	linux-net-drivers@solarflare.com
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24717 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab1BGUjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 15:39:23 -0500
In-Reply-To: <1295918675.4105.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-25 at 11:24 +1000, Ben Hutchings wrote:
> On Mon, 2011-01-24 at 18:47 +0100, Michal Schmidt wrote:
> > Suppose that several linear skbs of the same flow were received by GRO. They
> > were thus merged into one skb with a frag_list. Then a new skb of the same flow
> > arrives, but it is a paged skb with data starting in its frags[].
> > 
> > Before adding the skb to the frag_list skb_gro_receive() will of course adjust
> > the skb to throw away the headers. It correctly modifies the page_offset and
> > size of the frag, but it leaves incorrect information in the skb:
> >  ->data_len is not decreased at all.
> >  ->len is decreased only by headlen, as if no change were done to the frag.
> > Later in a receiving process this causes skb_copy_datagram_iovec() to return
> > -EFAULT and this is seen in userspace as the result of the recv() syscall.
> > 
> > In practice the bug can be reproduced with the sfc driver. By default the
> > driver uses an adaptive scheme when it switches between using
> > napi_gro_receive() (with skbs) and napi_gro_frags() (with pages). The bug is
> > reproduced when under rx load with enough successful GRO merging the driver
> > decides to switch from the former to the latter.
> [...]
> 
> This is odd because I thought we made sure to flush before making such a
> change.  Perhaps that got lost during the conversion from inet_lro to
> GRO?

That is indeed the case; commit da3bc07171dff957906cbe2ad5abb443eccf57c4
made the following deletions:

-       /* Both our generic-LRO and SFC-SSR support skb and page based
-        * allocation, but neither support switching from one to the
-        * other on the fly. If we spot that the allocation mode has
-        * changed, then flush the LRO state.
-        */
-       if (unlikely(channel->rx_alloc_pop_pages != (rx_buf->page != NULL))) {
-               efx_flush_lro(channel);
-               channel->rx_alloc_pop_pages = (rx_buf->page != NULL);
-       }

Ben.

> Anyway, thanks very much for fixing this.
> 
> Ben.
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

