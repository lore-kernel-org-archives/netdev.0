From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Tue, 16 Feb 2010 13:24:30 +0800
Message-ID: <20100216052430.GA27643@gondor.apana.org.au>
References: <20100214144415.GA8115@x200> <20100215001849.GB15437@gondor.apana.org.au> <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com> <20100215080846.GA18446@gondor.apana.org.au> <20100215081052.GA18516@gondor.apana.org.au> <20100215172810.GC4905@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35210 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750740Ab0BPFYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 00:24:37 -0500
Content-Disposition: inline
In-Reply-To: <20100215172810.GC4905@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 07:28:10PM +0200, Alexey Dobriyan wrote:
>
> OK, it survives beating here.

Thanks a lot for testing! I'll do the clean-up you suggested in
another patch.  Let's get this fixed first.

ipcomp: Avoid duplicate calls to ipcomp_destroy

When ipcomp_tunnel_attach fails we will call ipcomp_destroy twice.
This may lead to double-frees on certain structures.

As there is no reason to explicitly call ipcomp_destroy, this patch
removes it from ipcomp*.c and lets the standard xfrm_state destruction
take place.

This is based on the discovery and patch by Alexey Dobriyan.

Tested-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 38fbf04..544ce08 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -124,16 +124,12 @@ static int ipcomp4_init_state(struct xfrm_state *x)
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = ipcomp_tunnel_attach(x);
 		if (err)
-			goto error_tunnel;
+			goto out;
 	}
 
 	err = 0;
 out:
 	return err;
-
-error_tunnel:
-	ipcomp_destroy(x);
-	goto out;
 }
 
 static const struct xfrm_type ipcomp_type = {
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 2f2a5ca..002e6ee 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -154,16 +154,12 @@ static int ipcomp6_init_state(struct xfrm_state *x)
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = ipcomp6_tunnel_attach(x);
 		if (err)
-			goto error_tunnel;
+			goto out;
 	}
 
 	err = 0;
 out:
 	return err;
-error_tunnel:
-	ipcomp_destroy(x);
-
-	goto out;
 }
 
 static const struct xfrm_type ipcomp6_type =

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
