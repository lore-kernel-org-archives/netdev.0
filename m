From: David Miller <davem@davemloft.net>
Subject: Re: [IPCOMP]: Fix truesize after decompression
Date: Tue, 11 Jul 2006 13:55:53 -0700 (PDT)
Message-ID: <20060711.135553.106801039.davem@davemloft.net>
References: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn>
	<20060711114544.GA11396@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Daniel.Beschorner@facton.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:931
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751158AbWGKUzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 16:55:05 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060711114544.GA11396@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 11 Jul 2006 21:45:44 +1000

> [IPCOMP]: Fix truesize after decompression
> 
> The truesize check has uncovered the fact that we forgot to update truesize
> after pskb_expand_head.  Unfortunately pskb_expand_head can't update it for
> us because it's used in all sorts of different contexts, some of which would
> not allow truesize to be updated by itself.
> 
> So the solution for now is to simply update it in IPComp.
> 
> This patch also changes skb_put to __skb_put since we've just expanded
> tailroom by exactly that amount so we know it's there (but gcc does not).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

I think it is possible cover a certain class of these situations
from within pskb_expand_head.  For example, if skb->sk is NULL
we can prove that updating skb->truesize is safe since no
socket's buffer accounting can possible depend upon the truesize
value of this skb.

That way, we don't need to dilly-dally around spotting all the
cases like these two decompression bits where we need to add
the truesize adjustment by-hand.

This got me thinking... we can probably handle the skb->sk != NULL
case with some minor surgery.  If we could give some more information
to the skb->destructor callback, it could be used for truesize
adjustments.

The only remaining issue is context within which the destructor
is called for truesize changes.  There are some messy assumptions
out that, such as sk_stream_rfree(), which work on the basis
that the SKB is always freed up from the socket code with the
socket locked.  They use this assumption in order to safely
be able to adjust sk->sk_forward_alloc without any explicit
locking.

So it gets a little messy, but I think it's doable in the end.

