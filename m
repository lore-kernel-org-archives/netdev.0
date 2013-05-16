From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: Enable accelerated RFS on vlans
Date: Thu, 16 May 2013 19:38:44 +0100
Message-ID: <1368729524.2655.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <4bdabd4670b726348cdcdc0d2d635dd660671ee3.1368229353.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58431 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab3EPSis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 14:38:48 -0400
In-Reply-To: <4bdabd4670b726348cdcdc0d2d635dd660671ee3.1368229353.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-10 at 16:51 -0700, Andy Lutomirski wrote:
> As far as I know, the hardware doesn't support matching on both IP
> fields and vlan tag, but it can at least match on the vlan tag.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
> 
> Tested on the OpenOnload version of the driver, but the patch is the same
> other than some offset.

This looks correct, but I'll have to actually test it.  So I'll queue
this up and re-submit along with other sfc patches later on, OK?

> With this patch, accelerated RFS works for me.  (Oddly, some packets end
> up on otherwise idle cores, even when those cores have weight zero in
> ethtool --set-rxfh-indir; I'm not sure what's going on there.)

Some packets, or some interrupts?  TX completions and wake-up events (if
you use user-level networking) are of course not affected by the RX flow
hash indirection table..

You might find it useful to dump the complete RX filter table by running
'ethtool -d'.  ('ethtool -n' only shows the manually controlled
filters.)

Ben.

>  drivers/net/ethernet/sfc/filter.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
> index 8af42cd..5313ffe 100644
> --- a/drivers/net/ethernet/sfc/filter.c
> +++ b/drivers/net/ethernet/sfc/filter.c
> @@ -1076,8 +1076,21 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
>  
>  	nhoff = skb_network_offset(skb);
>  
> -	if (skb->protocol != htons(ETH_P_IP))
> +	if (skb->protocol == htons(ETH_P_8021Q)) {
> +		EFX_BUG_ON_PARANOID(skb_headlen(skb) <
> +				    nhoff + sizeof(struct vlan_hdr));
> +		if (((const struct vlan_hdr *)skb->data + nhoff)->
> +		    h_vlan_encapsulated_proto != htons(ETH_P_IP))
> +			return -EPROTONOSUPPORT;
> +
> +		/* This is IP over 802.1q VLAN.  We can't filter on the
> +		 * IP 5-tuple and the vlan together, so just strip the
> +		 * vlan header and filter on the IP part.
> +		 */
> +		nhoff += sizeof(struct vlan_hdr);
> +	} else if (skb->protocol != htons(ETH_P_IP)) {
>  		return -EPROTONOSUPPORT;
> +	}
>  
>  	/* RFS must validate the IP header length before calling us */
>  	EFX_BUG_ON_PARANOID(skb_headlen(skb) < nhoff + sizeof(*ip));

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
