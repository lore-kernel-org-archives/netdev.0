From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: Properly propagate errors from
 dsa_switch_setup_one
Date: Fri, 29 May 2015 20:28:09 +0200
Message-ID: <20150529182809.GE19580@lunn.ch>
References: <1432920586-20482-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, linux@roeck-us.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47826 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756060AbbE2Sd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 14:33:27 -0400
Content-Disposition: inline
In-Reply-To: <1432920586-20482-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 10:29:46AM -0700, Florian Fainelli wrote:
> While shuffling some code around, dsa_switch_setup_one() was introduced,
> and it was modified to return either an error code using ERR_PTR() or a
> NULL pointer when running out of memory or failing to setup a switch.
> 
> This is a problem for its caler: dsa_switch_setup() which uses IS_ERR()
> and expects to find an error code, not a NULL pointer, so we still try
> to proceed with dsa_switch_setup() and operate on invalid memory
> addresses. This can be easily reproduced by having e.g: the bcm_sf2
> driver built-in, but having no such switch, such that drv->setup will
> fail.
> 
> Fix this by using PTR_ERR() consistently which is both more informative
> and avoids for the caller to use IS_ERR_OR_NULL().
> 
> Fixes: df197195a5248 ("net: dsa: split dsa_switch_setup into two functions")
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Hi Florian

No more crash and burn :-)

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  net/dsa/dsa.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index e6f6cc3a1bcf..392e29a0227d 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -359,7 +359,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  	 */
>  	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
>  	if (ds == NULL)
> -		return NULL;
> +		return ERR_PTR(-ENOMEM);
>  
>  	ds->dst = dst;
>  	ds->index = index;
> @@ -370,7 +370,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  
>  	ret = dsa_switch_setup_one(ds, parent);
>  	if (ret)
> -		return NULL;
> +		return ERR_PTR(ret);
>  
>  	return ds;
>  }
> -- 
> 2.1.0
> 
