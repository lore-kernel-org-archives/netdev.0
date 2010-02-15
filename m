From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Mon, 15 Feb 2010 16:10:52 +0800
Message-ID: <20100215081052.GA18516@gondor.apana.org.au>
References: <20100214144415.GA8115@x200> <20100215001849.GB15437@gondor.apana.org.au> <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com> <20100215080846.GA18446@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45347 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755356Ab0BOIK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 03:10:57 -0500
Content-Disposition: inline
In-Reply-To: <20100215080846.GA18446@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 04:08:46PM +0800, Herbert Xu wrote:
> 
> How about just getting rid of the ipcomp_destroy call in ipcomp's
> init_state functions? Calling the destructor twice is a bit iffy
> even if we can make it work by setting various things to NULL and
> testing for it.

Something like this (totally untested):

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
