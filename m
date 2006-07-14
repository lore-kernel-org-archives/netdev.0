From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Update frag_list in pskb_trim
Date: Thu, 13 Jul 2006 19:22:10 -0700 (PDT)
Message-ID: <20060713.192210.35014155.davem@davemloft.net>
References: <20060713090341.GA28426@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61356
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161191AbWGNCWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 22:22:24 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060713090341.GA28426@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Jul 2006 19:03:41 +1000

> [NET]: Update frag_list in pskb_trim
> 
> When pskb_trim has to defer to ___pksb_trim to trim the frag_list part of
> the packet, the frag_list is not updated to reflect the trimming.  This
> will usually work fine until you hit something that uses the packet length
> or tail from the frag_list.
> 
> Examples include esp_output and ip_fragment.
> 
> Another problem caused by this is that you can end up with a linear packet
> with a frag_list attached.
> 
> It is possible to get away with this if we audit everything to make sure
> that they always consult skb->len before going down onto frag_list.  In
> fact we can do the samething for the paged part as well to avoid copying
> the data area of the skb.  For now though, let's do the conservative fix
> and update frag_list.
> 
> Many thanks to Marco Berizzi for helping me to track down this bug.
> 
> This 4-year old bug took 3 months to track down.  Marco was very patient
> indeed :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I happened to be looking at this function just the other day
and said to myself: "It only drops the fraglist if the whole
thing is trimmed, lazy and inefficient but seems to work"

Even the existing check for when to drop the whole fraglist
seems to be buggy, it only drops if the length drops below
headlen.  Paged and fraglist skbs are legal, so the proper
check would be to drop the entire fraglist when len drops
to headlen + the length of the paged portion (if any).

In any event leaving stale chunks there on the fraglist is
certainly a major bug, thanks for fixing this Herbert.

I bet a suitably placed assertion or two would have caught this
sooner.  One good spot would have been skb_cow_data(), where it has to
mince the fragments due to the presence of a frag_list.
