From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix GRO for multiple page fragments
Date: Fri, 17 Apr 2009 01:27:59 -0700 (PDT)
Message-ID: <20090417.012759.184081814.davem@davemloft.net>
References: <1239905060.3203.28.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753864AbZDQI2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:28:07 -0400
In-Reply-To: <1239905060.3203.28.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 16 Apr 2009 19:04:20 +0100

> This loop over fragments in napi_fraginfo_skb() was "interesting".
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This is not tested, as only cxgb3 will currently pass in multiple
> fragments at the same time.  skb_shinfo(skb)->nr_frags would already be
> 0 but it makes no sense to rely on that.  I hope I'm not missing some
> subtlety...

I think the code still isn't right after your changes.

The intent seems to be to append frags from 'info' into the SKB,
so that it works even if the SKB already has some frags.

And being that cxgb3 is pretty well tested with GRO I'm suspicious
even moreso :-)

Herbert?

> diff --git a/net/core/dev.c b/net/core/dev.c
> index ea8eb22..15ecc51 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2539,9 +2539,9 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
>  	}
>  
>  	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
> -	frag = &info->frags[info->nr_frags - 1];
> +	frag = info->frags;
>  
> -	for (i = skb_shinfo(skb)->nr_frags; i < info->nr_frags; i++) {
> +	for (i = 0; i < info->nr_frags; i++) {
>  		skb_fill_page_desc(skb, i, frag->page, frag->page_offset,
>  				   frag->size);
>  		frag++;
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
