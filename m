From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix leak of expired xfrm_states
Date: Mon, 26 Nov 2007 17:52:15 +0100
Message-ID: <474AF9BF.2050603@trash.net>
References: <474AE0B7.5010709@trash.net> <20071126154625.GI28022@gondor.apana.org.au> <474AEB8E.9040903@trash.net> <20071126155408.GA29097@gondor.apana.org.au> <474AEC91.5090907@trash.net> <20071126162223.GA29293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050507030207080902030906"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61448 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbXKZQxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 11:53:08 -0500
In-Reply-To: <20071126162223.GA29293@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050507030207080902030906
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Mon, Nov 26, 2007 at 04:56:01PM +0100, Patrick McHardy wrote:
>> That should work as long as we keep the del_timer_sync to avoid
>> a use-after-free. It seems a bit fragile though.
> 
> Well we're relying on the del_timer_sync already to avoid the
> ref count on the timer.  Otherwise if the admin deletes the
> SA while the timer is running it'll go up in smoke too.
> 
> If you look in the history you'll find that the same patch
> that removed the ref count on the timer introduced the call
> to del_timer_sync :)


OK, here's a patch to use xfrm_state_put in __xfrm_state_delete().
I've checked the other callers and it should be fine. lock ordering
between x->lock and xfrm_state_gc_lock also doesn't seem to be an
issue.



--------------050507030207080902030906
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit ba63b1baf5d8a63f3bb3097a7201de75c1b77e2d
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 26 16:00:50 2007 +0100

    [XFRM]: Fix leak of expired xfrm_states

    The xfrm_timer calls __xfrm_state_delete, which drops the final reference
    manually without triggering destruction of the state. Change it to use
    xfrm_state_put to add the state to the gc list when we're dropping the
    last reference. The timer function may still continue to use the state
    safely since the final destruction does a del_timer_sync().

    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 224b44e..cf43c49 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -552,7 +552,7 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		 * The xfrm_state_alloc call gives a reference, and that
 		 * is what we are dropping here.
 		 */
-		__xfrm_state_put(x);
+		xfrm_state_put(x);
 		err = 0;
 	}
 

--------------050507030207080902030906--
