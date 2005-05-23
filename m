From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] : bug fix in multipath drr code.
Date: Tue, 24 May 2005 09:22:24 +1000
Message-ID: <20050523232224.GA25349@gondor.apana.org.au>
References: <4291CBFF.6080106@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: pravin <pravins@calsoftinc.com>
Content-Disposition: inline
In-Reply-To: <4291CBFF.6080106@calsoftinc.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2005 at 05:56:39PM +0530, pravin wrote:
>  AFAIU, there is a race condition in multipath_drr code,
> these code paths try to access & change last_selection variable
> without any synchronization.

Yes you're right.
 
> Index: linux-2.6.12-rc4/net/ipv4/multipath_drr.c
> ===================================================================
> --- linux-2.6.12-rc4.orig/net/ipv4/multipath_drr.c	2005-05-06 22:20:31.000000000 -0700
> +++ linux-2.6.12-rc4/net/ipv4/multipath_drr.c	2005-05-22 06:41:39.000000000 -0700
> @@ -145,11 +145,13 @@
>  	int cur_min_devidx = -1;
>  
>         	/* if necessary and possible utilize the old alternative */
> -	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 &&
> -	    last_selection != NULL) {
> -		result = last_selection;
> -		*rp = result;
> -		return;
> +	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 ) {
> +		struct rtable *last_result = last_selection;
> +		if(last_result != NULL &&
> +		   multipath_comparekeys(&last_result->fl, flp)) {
> +			*rp = last_result;
> +			return;
> +		}
>  	}

You don't need all this code.  All you need to do is do
result = last_selection before the if condition and then
check result in the if condition instead of last_selection.

The multipath_comparekeys isn't necessary either.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
