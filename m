From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ipsec-next 4/5] net: Prepare for IPsec GRO
Date: Wed, 04 Jan 2017 04:34:15 -0800
Message-ID: <1483533255.4337.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
         <1483518230-6777-5-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35527 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753396AbdADMeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:34:20 -0500
Received: by mail-pg0-f67.google.com with SMTP id i5so37078058pgh.2
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:34:19 -0800 (PST)
In-Reply-To: <1483518230-6777-5-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-04 at 09:23 +0100, Steffen Klassert wrote:
> This patch prepares the generic codepath for IPsec GRO.
> We introduce a new GRO_CONSUMED notifier to reflect that
> IPsec can return asynchronous. On IPsec GRO we grab the
> packet and reinject it back to layer 2 after IPsec
> processing. We also use one xfrm_gro bit on the sk_buff
> that will be set from IPsec to notify about GRO. If this
> bit is set, we call napi_gro_receive for the backlog device
> instead of __netif_receive_skb.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  include/linux/netdevice.h |  1 +
>  include/linux/skbuff.h    | 14 +++++++++++++-
>  net/core/dev.c            | 17 ++++++++++++++++-
>  net/xfrm/Kconfig          |  4 ++++
>  4 files changed, 34 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ecd78b3..89bad76 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -352,6 +352,7 @@ enum gro_result {
>  	GRO_HELD,
>  	GRO_NORMAL,
>  	GRO_DROP,
> +	GRO_CONSUMED,
>  };
>  typedef enum gro_result gro_result_t;
>  
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index b53c0cf..a78cd90 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -749,7 +749,10 @@ struct sk_buff {
>  #ifdef CONFIG_NET_SWITCHDEV
>  	__u8			offload_fwd_mark:1;
>  #endif
> -	/* 2, 4 or 5 bit hole */
> +#ifdef CONFIG_XFRM_OFFLOAD
> +	__u8			xfrm_gro:1;



Arg, yet another skb bit.

> +#endif
> +	/* 1 to 5 bits hole */
>  
>  #ifdef CONFIG_NET_SCHED
>  	__u16			tc_index;	/* traffic control index */
> @@ -3698,6 +3701,15 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
>  #endif
>  }
>  

>  
> @@ -4843,7 +4853,12 @@ static int process_backlog(struct napi_struct *napi, int quota)
>  
>  		while ((skb = __skb_dequeue(&sd->process_queue))) {
>  			rcu_read_lock();
> -			__netif_receive_skb(skb);
> +
> +			if (skb_xfrm_gro(skb))
> +				napi_gro_receive(napi, skb);
> +			else
> +				__netif_receive_skb(skb);
> +


But napi here is device independent. It is a fake NAPI, per cpu.

I am not sure of the various implications of using it at this point,
this looks quite dangerous/invasive to me, compared to the gro_cells
infra which was designed to have no impact on core code paths.

To me, the caller should call napi_gro_receive() skb, instead of letting
core networking stack add this extra skb bit and extra conditional.

( Also I am not sure device dismantle will be properly managed by your
changes. It is really tricky to get it right. )

Thanks.
