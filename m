From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net: skb_gro_checksum_* functions
Date: Fri, 20 Jun 2014 22:09:09 -0700
Message-ID: <1403327349.16682.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406201630550.12976@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:63337 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbaFUFJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 01:09:13 -0400
Received: by mail-we0-f181.google.com with SMTP id q59so4495849wes.26
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 22:09:12 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406201630550.12976@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-20 at 16:37 -0700, Tom Herbert wrote:
> Add skb_gro_checksum_validate, skb_gro_checksum_validate_zero_check,
> and skb_gro_checksum_simple_validate, and __skb_gro_checksum_complete.
> These are the cognates of the normal checksum functions but are used
> in the gro_receive path and operate on GRO related fields in sk_buffs.


Why a new 'encapsulation' field is needed in napi_gro_cb ?

> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h | 54 ++++++++++++++++++++++++++++++++++++++++++++++-
>  net/core/dev.c            | 31 +++++++++++++++++++++++++++
>  net/ipv4/udp_offload.c    |  2 ++
>  3 files changed, 86 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 66f9a04..63d8bbc 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1760,7 +1760,10 @@ struct napi_gro_cb {
>  	u16	proto;
>  
>  	/* Used in udp_gro_receive */
> -	u16	udp_mark;
> +	u8	udp_mark;
> +
> +	/* Crossed encapsulation boundary */
> +	u8	encapsulation;
>  

> diff --git a/net/core/dev.c b/net/core/dev.c
> index a04b12f..fe38c2a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3955,6 +3955,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
>  		NAPI_GRO_CB(skb)->flush = 0;
>  		NAPI_GRO_CB(skb)->free = 0;
>  		NAPI_GRO_CB(skb)->udp_mark = 0;
> +		NAPI_GRO_CB(skb)->encapsulation = 0;

...

>  
>  		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
>  		break;
> @@ -4183,6 +4184,36 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
>  }
>  EXPORT_SYMBOL(napi_gro_frags);
>  
> +/* Compute the checksum from gro_offset and return the folded value
> + * after adding in any pseudo checksum. Also, compute the checksum
> + * for bytes preceeding the gro_offset and add that to the GRO checksum
> + * to derive and save checksum for the whole packet.
> + */
> +__sum16 __skb_gro_checksum_complete(struct sk_buff *skb)
> +{
> +	__wsum wsum;
> +	__sum16 sum;
> +
> +	wsum = skb_checksum(skb, skb_gro_offset(skb), skb_gro_len(skb), 0);
> +
> +	/* NAPI_GRO_CB(skb)->csum holds pseudo checksum */
> +	sum = csum_fold(csum_add(NAPI_GRO_CB(skb)->csum, wsum));
> +	if (likely(!sum)) {
> +		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
> +		    !skb->csum_complete_sw)
> +			netdev_rx_csum_fault(skb->dev);
> +	}
> +
> +	/* Save result in checksum complete */
> +	skb->csum = skb_checksum(skb, 0, skb_gro_offset(skb), wsum);
> +	skb->ip_summed = CHECKSUM_COMPLETE;
> +	skb->csum_complete_sw = 1;
> +	NAPI_GRO_CB(skb)->csum = wsum;

Why is this affectation (NAPI_GRO_CB(skb)->csum = wsum) needed ?

And why CHECKSUM_UNNECESSARY isn't used instead ?

This is a bit confusing, as tcp_gro_complete() will later set
CHECKSUM_PARTIAL

You might add comments, because this is so confusing, and I'd like to
understand and maintain gro layer.

> +
> +	return sum;
> +}
> +EXPORT_SYMBOL(__skb_gro_checksum_complete);
> +
>  /*
>   * net_rps_action_and_irq_enable sends any pending IPI's for rps.
>   * Note: called with local irq disabled, but exits with local irq enabled.
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 546d2d4..fb8e6ba 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -176,6 +176,8 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
>  			goto out;
>  	}
>  
> +	NAPI_GRO_CB(skb)->encapsulation = 1;
> +
>  	rcu_read_lock();
>  	uo_priv = rcu_dereference(udp_offload_base);
>  	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
