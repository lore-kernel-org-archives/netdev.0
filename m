From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [xfrm_user] BUG: sleeping function called from invalid context
Date: Fri, 13 Aug 2010 11:36:58 -0400
Message-ID: <20100813153658.GA27982@gondor.apana.org.au>
References: <20100812125027.GA12982@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60076 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754493Ab0HMPhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 11:37:00 -0400
Content-Disposition: inline
In-Reply-To: <20100812125027.GA12982@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luca Tettamanti <kronos.it@gmail.com> wrote:
>
> xfrm_user_policy takes read_lock(&xfrm_km_lock) before calling
> xfrm_compile_policy (via km->compile_policy), which in turn calls
> xfrm_policy_alloc with GFP_KERNEL.

Thanks for discovering this bug, it only took 8 years :)

xfrm: Use GFP_ATOMIC in xfrm_compile_policy

As xfrm_compile_policy runs within a read_lock, we cannot use
GFP_KERNEL for memory allocations.

Reported-by: Luca Tettamanti <kronos.it@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ba59983..b14ed4b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2504,7 +2504,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	if (p->dir > XFRM_POLICY_OUT)
 		return NULL;
 
-	xp = xfrm_policy_alloc(net, GFP_KERNEL);
+	xp = xfrm_policy_alloc(net, GFP_ATOMIC);
 	if (xp == NULL) {
 		*dir = -ENOBUFS;
 		return NULL;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
