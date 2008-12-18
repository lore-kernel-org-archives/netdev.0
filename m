From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: ppp_generic - use idr technique instead of
 cardmaps
Date: Wed, 17 Dec 2008 17:16:25 -0800
Message-ID: <20081217171625.776d4e46.akpm@linux-foundation.org>
References: <20081216192000.GF26390@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, paulus@samba.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xemul@openvz.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40372 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028AbYLRBQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 20:16:31 -0500
In-Reply-To: <20081216192000.GF26390@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Dec 2008 22:20:00 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> Here is an attempt to convert cardmaps into ird.
> I would really appreciate any feedback.
> 
> I've tested ird under qemu (by some hacks not real ppp connection)
> so real loadings could reveal problems with the patch - review
> carefully please. (i'm not subcribed for netdev list CC me).
> 
> Any comments are _quite_ welcome! Paul?
> 
> ---
> From: Cyrill Gorcunov <gorcunov@openvz.org>
> Date: Tue, 16 Dec 2008 19:39:08 +0300
> Subject: [PATCH] net: ppp_generic - use idr technique instead of cardmaps
> 
> Use idr technique instead of own implemented cardmaps.
> It saves us a number of lines and gives an ability
> to use library functions.
>
> ...
>
> +static struct idr ppp_units_idr;

Could use DEFINE_IDR()

> @@ -859,6 +841,8 @@ static int __init ppp_init(void)
>  		device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), "ppp");
>  	}
>  
> +	idr_init(&ppp_units_idr);

then remove this.

>  out:
>  	if (err)
>  		printk(KERN_ERR "failed to register PPP device (%d)\n", err);
> @@ -2431,10 +2415,22 @@ ppp_create_interface(int unit, int *retp)
>  
>  	ret = -EEXIST;
>  	mutex_lock(&all_ppp_mutex);
> -	if (unit < 0)
> -		unit = cardmap_find_first_free(all_ppp_units);
> -	else if (cardmap_get(all_ppp_units, unit) != NULL)
> -		goto out2;	/* unit already exists */
> +
> +	if (unit < 0) {
> +		unit = unit_get(&ppp_units_idr, ppp);
> +		if (unit < 0) {
> +			*retp = unit;
> +			goto out2;
> +		}
> +	} else {
> +		if (unit_find(&ppp_units_idr, unit))
> +			goto out2; /* unit already exists */
> +		else {
> +			/* darn, someone is cheatting us? */

"cheating" ;)

> +			*retp = -EINVAL;
> +			goto out2;
> +		}
> +	}

It certainly cleaned things up.

What is the locking for the IDR tree?  all_ppp_mutex?

