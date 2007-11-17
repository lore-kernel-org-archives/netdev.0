From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPV4 : Move ip route cache flush (secret_rebuild) from softirq to workqueue
Date: Sun, 18 Nov 2007 00:29:39 +0800
Message-ID: <20071117162939.GA21563@gondor.apana.org.au>
References: <20071116174027.726e6eca.dada1@cosmosbay.com> <20071116.165445.172804063.davem@davemloft.net> <473EB75B.7000607@cosmosbay.com> <20071117143622.GA20813@gondor.apana.org.au> <473F145B.5090303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4774 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751332AbXKQQ3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 11:29:48 -0500
Content-Disposition: inline
In-Reply-To: <473F145B.5090303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 17, 2007 at 05:18:35PM +0100, Eric Dumazet wrote:
>
> >This seems to be the only potentially softirq caller of rt_run_flush.
> >However, I just checked the callers of it and most of them seem to
> >hold the RTNL which would indicate that they're in process context.
> >
> >So do you know if you we have any real softirq callers left?
> >If we do perhaps we can look at either moving them out or see
> >if they can cope with the flush occuring after the call returns.
> >
> >If not we can get rid of the softirq special case.
> 
> Unfortunatly we have softirq callers left. But my goal is to move 
> everything to process context yes. I choose small patches, so that they can 
> be more easyly reviewed and accepted.
> 
> The most common case is triggered by "ip route flush cache"
> Since it's arming a 2 second timer (ip_rt_min_delay) . When this
> timer is fired (softirq), it is flushing the table.
> 
> Then, every calls to rt_cache_flush(-1) are asking the same thing, while 
> rt_cache_flush(0) are synchronous (immediate flushing unless a flush 
> already is in flight)

Right.  Obviously the ones with non-zero arguments aren't an
issue because it's delayed anyway.

What I meant above is that which of the ones that call it with
zero are really in a softirq context.  As the ones I looked at
all seem to hold the RTNL it would suggest that most of them
are already in process context.

However, since you're already working on this as your next step
I can wait :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
