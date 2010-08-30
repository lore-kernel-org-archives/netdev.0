From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Mon, 30 Aug 2010 21:09:00 +0200
Message-ID: <20100830190900.GA3141@del.dom.local>
References: <1283107162.2297.32.camel@edumazet-laptop>
 <20100830064231.GA7060@ff.dom.local>
 <20100830085721.54c8c31b@nehalam>
 <20100830.095012.233695092.davem@davemloft.net>
 <20100830105117.0f0cf140@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42403 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab0H3TJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 15:09:06 -0400
Received: by fxm13 with SMTP id 13so3503190fxm.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 12:09:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100830105117.0f0cf140@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 10:51:17AM -0700, Stephen Hemminger wrote:
> 
>  There's something very important I forgot to tell you.
>  What?
> 
>  Don't cross the GRO streams.
>  Why?
> 
>  It would be bad.
>  I'm fuzzy on the whole good/bad thing. What do you mean, "bad"?
> 
>  Try to imagine all the Internet as you know it stopping instantaneously
>   and every bit in every packet swapping at the speed of light.
>  Total packet reordering.
>  Right. That's bad. Okay. All right. Important safety tip. Thanks, Hubert

Looks really bad to me, so... let's forget it! ;-) (At least until
next next.)

Jarek P.

> 
> The simplest way to stop this is just avoid doing GRO on the second port.
> Very few Marvell boards support two ports per ring, and GRO is just
> an optimization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/sky2.c	2010-08-30 10:13:28.211536096 -0700
> +++ b/drivers/net/sky2.c	2010-08-30 10:22:01.347183151 -0700
> @@ -2520,24 +2520,27 @@ static inline void sky2_tx_done(struct n
>  	}
>  }
>  
> -static inline void sky2_skb_rx(const struct sky2_port *sky2,
> +static inline void sky2_skb_rx(struct napi_struct *napi,
> +			       const struct sky2_port *sky2,
>  			       u32 status, struct sk_buff *skb)
>  {
>  #ifdef SKY2_VLAN_TAG_USED
> -	u16 vlan_tag = be16_to_cpu(sky2->rx_tag);
>  	if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
> -		if (skb->ip_summed == CHECKSUM_NONE)
> +		u16 vlan_tag = be16_to_cpu(sky2->rx_tag);
> +
> +		if (skb->ip_summed == CHECKSUM_NONE ||
> +		    sky2->netdev != napi->dev)
>  			vlan_hwaccel_receive_skb(skb, sky2->vlgrp, vlan_tag);
>  		else
> -			vlan_gro_receive(&sky2->hw->napi, sky2->vlgrp,
> -					 vlan_tag, skb);
> +			vlan_gro_receive(napi, sky2->vlgrp, vlan_tag, skb);
>  		return;
>  	}
>  #endif
> -	if (skb->ip_summed == CHECKSUM_NONE)
> +	if (skb->ip_summed == CHECKSUM_NONE ||
> +	    sky2->netdev != napi->dev)
>  		netif_receive_skb(skb);
>  	else
> -		napi_gro_receive(&sky2->hw->napi, skb);
> +		napi_gro_receive(napi, skb);
>  }
>  
>  static inline void sky2_rx_done(struct sky2_hw *hw, unsigned port,
> @@ -2638,7 +2641,7 @@ static int sky2_status_intr(struct sky2_
>  
>  			skb->protocol = eth_type_trans(skb, dev);
>  
> -			sky2_skb_rx(sky2, status, skb);
> +			sky2_skb_rx(&hw->napi, sky2, status, skb);
>  
>  			/* Stop after net poll weight */
>  			if (++work_done >= to_do)
