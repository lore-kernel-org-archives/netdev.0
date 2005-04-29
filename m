From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch2: del/get byid
Date: Sat, 30 Apr 2005 09:49:52 +1000
Message-ID: <20050429234952.GB22699@gondor.apana.org.au>
References: <20050428022549.GA23556@gondor.apana.org.au> <1114655980.7663.76.camel@localhost.localdomain> <20050428024253.GA23695@gondor.apana.org.au> <1114656932.7663.88.camel@localhost.localdomain> <20050428030325.GB23823@gondor.apana.org.au> <1114658657.7663.110.camel@localhost.localdomain> <1114698033.7663.197.camel@localhost.localdomain> <20050428231154.GA14215@gondor.apana.org.au> <1114779104.7800.22.camel@localhost.localdomain> <1114816846.8929.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114816846.8929.6.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2005 at 07:20:46PM -0400, jamal wrote:
>
> @@ -341,17 +341,35 @@
>  {
>  	struct xfrm_policy *pol, **p;
>  	struct xfrm_policy *delpol = NULL;
> +	struct xfrm_policy *delpol2 = NULL;
> +	struct xfrm_policy *delp = NULL;
>  	struct xfrm_policy **newpos = NULL;
> +	int ret = -EINVAL;
> +
> +	if (policy->index)
> +		delpol = xfrm_policy_byid(dir, policy->index, 0);
> +	delpol2 = xfrm_policy_bysel(dir, &policy->selector, 0);
> +
> +	/* must be unique in both index and selector */
> +	if (delpol && delpol2) 
> +		if (delpol != delpol2) 
> +			goto pol_err;
>  
> +	if (delpol) 
> +		delp = delpol;
> +	else 
> +		delp = delpol2;
> +			
> +	if (delp && excl) { 
> +		ret = -EEXIST;
> +		goto pol_err;
> +	}
> +
> +	/* insert, sorted by prio*/
>  	write_lock_bh(&xfrm_policy_lock);

...

>  	write_unlock_bh(&xfrm_policy_lock);
>  
> -	if (delpol) {
> -		xfrm_policy_kill(delpol);
> +	if (delp) {
> +		xfrm_policy_kill(delp);
>  	}

This is racy.  The policy could be killed by the timer in the middle.

This is also getting pretty hairy for something that nobody has needed so
far.  Which user-space application is going to use this index thing?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
