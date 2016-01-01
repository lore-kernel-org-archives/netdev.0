From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/3] net-gianfar: Less function calls in
 gfar_ethflow_to_filer_table() after error detection
Date: Fri, 1 Jan 2016 13:35:14 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1601011334200.2054@localhost6.localdomain6>
References: <566ABCD9.1060404@users.sourceforge.net> <56866E7F.8080609@users.sourceforge.net> <56866F68.6070904@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:2931 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751689AbcAAMfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jan 2016 07:35:17 -0500
In-Reply-To: <56866F68.6070904@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 1 Jan 2016, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 11:16:04 +0100
> 
> The kfree() function was called in one case by the
> gfar_ethflow_to_filer_table() function during error handling
> even if a passed variable contained a null pointer.
> 
> * Return directly if a memory allocation failed at the beginning.
> 
> * Adjust jump targets according to the Linux coding style convention.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/freescale/gianfar_ethtool.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> index 4b0ee85..be4941e 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -778,11 +778,13 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>  
>  	local_rqfpr = kmalloc_array(MAX_FILER_IDX + 1, sizeof(unsigned int),
>  				    GFP_KERNEL);
> +	if (!local_rqfpr)
> +		return 1;

Why return 1?  Previously 0 was returned.

Normally, one returns -ENOMEM for this case, but it looks like this 
function is returning 0 on failure.

julia

>  	local_rqfcr = kmalloc_array(MAX_FILER_IDX + 1, sizeof(unsigned int),
>  				    GFP_KERNEL);
> -	if (!local_rqfpr || !local_rqfcr) {
> +	if (!local_rqfcr) {
>  		ret = 0;
> -		goto err;
> +		goto free_fpr;
>  	}
>  
>  	switch (class) {
> @@ -802,7 +804,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>  		netdev_err(priv->ndev,
>  			   "Right now this class is not supported\n");
>  		ret = 0;
> -		goto err;
> +		goto free_fcr;
>  	}
>  
>  	for (i = 0; i < MAX_FILER_IDX + 1; i++) {
> @@ -819,7 +821,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>  		netdev_err(priv->ndev,
>  			   "No parse rule found, can't create hash rules\n");
>  		ret = 0;
> -		goto err;
> +		goto free_fcr;
>  	}
>  
>  	/* If a match was found, then it begins the starting of a cluster rule
> @@ -862,9 +864,9 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
>  			break;
>  		priv->cur_filer_idx = priv->cur_filer_idx - 1;
>  	}
> -
> -err:
> +free_fcr:
>  	kfree(local_rqfcr);
> +free_fpr:
>  	kfree(local_rqfpr);
>  	return ret;
>  }
> -- 
> 2.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
