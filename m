From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Tue, 16 Feb 2010 14:00:51 +0800
Message-ID: <20100216060051.GA27804@gondor.apana.org.au>
References: <20100214144415.GA8115@x200> <20100215001849.GB15437@gondor.apana.org.au> <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com> <20100215080846.GA18446@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43629 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751811Ab0BPGA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 01:00:58 -0500
Content-Disposition: inline
In-Reply-To: <20100215080846.GA18446@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 04:08:46PM +0800, Herbert Xu wrote:
>
> Doh, I was looking at the buggy xfrm_state_clone path (which
> incidently needs to be fixed to use xfrm_state_put).

Here's a fix for that problem.

xfrm: Fix xfrm_state_clone leak

xfrm_state_clone calls kfree instead of xfrm_state_put to free
a failed state.  Depending on the state of the failed state, it
can cause leaks to things like module references.

All states should be freed by xfrm_state_put past the point of
xfrm_init_state.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b36cc34..f445ea1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1102,7 +1102,7 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	int err = -ENOMEM;
 	struct xfrm_state *x = xfrm_state_alloc(net);
 	if (!x)
-		goto error;
+		goto out;
 
 	memcpy(&x->id, &orig->id, sizeof(x->id));
 	memcpy(&x->sel, &orig->sel, sizeof(x->sel));
@@ -1160,16 +1160,10 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	return x;
 
  error:
+	xfrm_state_put(x);
+out:
 	if (errp)
 		*errp = err;
-	if (x) {
-		kfree(x->aalg);
-		kfree(x->ealg);
-		kfree(x->calg);
-		kfree(x->encap);
-		kfree(x->coaddr);
-	}
-	kfree(x);
 	return NULL;
 }
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
