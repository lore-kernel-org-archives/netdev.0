From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Mon, 15 Feb 2010 19:28:10 +0200
Message-ID: <20100215172810.GC4905@x200>
References: <20100214144415.GA8115@x200>
 <20100215001849.GB15437@gondor.apana.org.au>
 <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com>
 <20100215080846.GA18446@gondor.apana.org.au>
 <20100215081052.GA18516@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:40402 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261Ab0BOR2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 12:28:24 -0500
Received: by fxm20 with SMTP id 20so5130523fxm.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 09:28:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100215081052.GA18516@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 04:10:52PM +0800, Herbert Xu wrote:
> On Mon, Feb 15, 2010 at 04:08:46PM +0800, Herbert Xu wrote:
> > 
> > How about just getting rid of the ipcomp_destroy call in ipcomp's
> > init_state functions? Calling the destructor twice is a bit iffy
> > even if we can make it work by setting various things to NULL and
> > testing for it.
> 
> Something like this (totally untested):

OK, it survives beating here.

> --- a/net/ipv4/ipcomp.c
> +++ b/net/ipv4/ipcomp.c
> @@ -124,16 +124,12 @@ static int ipcomp4_init_state(struct xfrm_state *x)
>  	if (x->props.mode == XFRM_MODE_TUNNEL) {
>  		err = ipcomp_tunnel_attach(x);
>  		if (err)
> -			goto error_tunnel;
> +			goto out;
>  	}
>  
>  	err = 0;
>  out:
>  	return err;
> -
> -error_tunnel:
> -	ipcomp_destroy(x);
> -	goto out;
>  }
>  
>  static const struct xfrm_type ipcomp_type = {
> diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
> index 2f2a5ca..002e6ee 100644
> --- a/net/ipv6/ipcomp6.c
> +++ b/net/ipv6/ipcomp6.c
> @@ -154,16 +154,12 @@ static int ipcomp6_init_state(struct xfrm_state *x)
>  	if (x->props.mode == XFRM_MODE_TUNNEL) {
>  		err = ipcomp6_tunnel_attach(x);
>  		if (err)
> -			goto error_tunnel;
> +			goto out;
>  	}
>  
>  	err = 0;
>  out:
>  	return err;
> -error_tunnel:
> -	ipcomp_destroy(x);
> -
> -	goto out;
>  }
>  
>  static const struct xfrm_type ipcomp6_type =
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
