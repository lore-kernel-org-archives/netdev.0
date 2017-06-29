From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 8/9] nfp: add a stats handler for flower
 offloads
Date: Wed, 28 Jun 2017 19:55:18 -0700
Message-ID: <20170628195518.3397bab1@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36090 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdF2CzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 22:55:21 -0400
Received: by mail-pf0-f169.google.com with SMTP id q86so42801937pfl.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 19:55:20 -0700 (PDT)
In-Reply-To: <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 22:30:01 +0200, Simon Horman wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> 
> Previously there was no way of updating flow rule stats after they
> have been offloaded to hardware. This is solved by keeping track of
> stats received from hardware and providing this to the TC handler
> on request.
> 
> Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

> @@ -334,7 +441,10 @@ int nfp_modify_flow_metadata(struct nfp_app *app,
>  	/* Update flow payload with mask ids. */
>  	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
>  
> -	return 0;
> +	/* Release the stats ctx id. */
> +	temp_ctx_id = be32_to_cpu(nfp_flow->meta.host_ctx_id);
> +
> +	return nfp_release_stats_entry(app, temp_ctx_id);
>  }
>  
>  int nfp_flower_metadata_init(struct nfp_app *app)
> @@ -362,6 +472,15 @@ int nfp_flower_metadata_init(struct nfp_app *app)
>  		return -ENOMEM;
>  	}
>  
> +	/* Init ring buffer and unallocated stats_ids. */
> +	priv->stats_ids.free_list.buf =
> +		vmalloc(NFP_FL_STATS_ENTRY_RS * NFP_FL_STATS_ELEM_RS);
> +	if (!priv->stats_ids.free_list.buf) {
> +		vfree(priv->mask_ids.mask_id_free_list.buf);
> +		return -ENOMEM;

This is hiding a leak, I think.  There were 2 things allocate above.
Please add a proper unwind path with goto's - it makes catching bugs
like this much easier.

> +	}
> +	priv->stats_ids.init_unalloc = NFP_FL_REPEATED_HASH_MAX;
> +
>  	return 0;
>  }
>  
