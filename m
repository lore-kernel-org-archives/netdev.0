From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 15:01:11 +1000
Message-ID: <E1KakUR-0001xp-00@gondolin.me.apana.org.au>
References: <20080902.195148.193704236.davem@davemloft.net>
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42573 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751069AbYICFBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:01:18 -0400
In-Reply-To: <20080902.195148.193704236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> This is what added the xfrm_state_lock grabbing in __xfrm_state_destroy().

This is simply bogus.  We should remove the entry from the list
when the state is deleted, not when it's destroyed.  That is, we
should be deleting x->all in places like __xfrm_state_delete instead
of __xfrm_state_destroy.

The fact that we're adding x->all in __xfrm_state_insert means
that we should be deleting it from its counter-part, which is
__xfrm_state_delete.

The same thing applies to the policies of course.  Once a policy
or state is deleted there is no reason why it should show up in a
walk just because some dst is holding onto it.
 
> ipsec: Fix deadlock in xfrm_state management.
> 
> Ever since commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3
> ("[XFRM]: Speed up xfrm_policy and xfrm_state walking") it is
> illegal to call __xfrm_state_destroy (and thus xfrm_state_put())
> with xfrm_state_lock held.  If we do, we'll deadlock since we
> have the lock already and __xfrm_state_destroy() tries to take
> it again.
> 
> Fix this by pushing the xfrm_state_put() calls after the lock
> is dropped.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

However, moving things out of critical sections is always a good
idea.  So I think your patch is an improvement regardless of why
it came about :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
