From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 11633] Kernel panic after patch
	f3994eceebf64cf356a82ffb2718ef538eb8d4f4
Date: Thu, 25 Sep 2008 10:36:22 +0800
Message-ID: <20080925023622.GA15800@gondor.apana.org.au>
References: <20080924.133120.21071803.davem@davemloft.net> <20080925011035.GA15055@gondor.apana.org.au> <20080925012105.GA15241@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34731 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752166AbYIYCgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 22:36:31 -0400
Content-Disposition: inline
In-Reply-To: <20080925012105.GA15241@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 09:21:05AM +0800, Herbert Xu wrote:
> On Thu, Sep 25, 2008 at 09:10:35AM +0800, Herbert Xu wrote:
> > 
> > Perhaps something somewhere is creating an skb with the old way
> > while someone else is assuming that it has the amount of space
> > set out by needed_*room.
> 
> This changeset looks very suspicious:
> 
> commit f5184d267c1aedb9b7a8cc44e08ff6b8d382c3b5
> Author: Johannes Berg <johannes@sipsolutions.net>
> Date:   Mon May 12 20:48:31 2008 -0700
> 
>     net: Allow netdevices to specify needed head/tailroom
> 
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index 09cd9c0..3f964db 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -25,11 +25,11 @@ static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
>  	struct dst_entry *dst = skb->dst;
>  	int nhead = dst->header_len + LL_RESERVED_SPACE(dst->dev)
>  		- skb_headroom(skb);
> +	int ntail = dst->dev->needed_tailroom - skb_tailroom(skb);
>  
> -	if (nhead > 0)
> -		return pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
> +	if (nhead > 0 || ntail > 0)
> +		return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
> 
> If nhead < 0 and ntail > 0 we'll go boom...

Here's the fix.

ipsec: Fix pskb_expand_head corruption in xfrm_state_check_space

We're never supposed to shrink the headroom or tailroom.  In fact,
shrinking the headroom is a fatal action.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index ac25b4c..dc50f1e 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -27,10 +27,14 @@ static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
 		- skb_headroom(skb);
 	int ntail = dst->dev->needed_tailroom - skb_tailroom(skb);
 
-	if (nhead > 0 || ntail > 0)
-		return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
-
-	return 0;
+	if (nhead <= 0) {
+		if (ntail <= 0)
+			return 0;
+		nhead = 0;
+	} else if (ntail < 0)
+		ntail = 0;
+
+	return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
 }
 
 static int xfrm_output_one(struct sk_buff *skb, int err)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
