From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of
 kfree_skb.
Date: Mon, 10 Mar 2014 20:44:27 -0700
Message-ID: <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <874n3fow2i.fsf@xmission.com>
	 <20140304.160825.893718566461536483.davem@davemloft.net>
	 <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33003 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaCKDo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:44:29 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so7988765pdj.3
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 20:44:29 -0700 (PDT)
In-Reply-To: <87vbvlpgnk.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 20:18 -0700, Eric W. Biederman wrote:
> Replace kfree_skb with dev_kfree_skb_any in functions that can
> be called in hard irq and other contexts.
> 
> Replace consume_skb with dev_consume_skb_any in functions that can
> be called in hard irq and other contexts.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/bonding/bond_3ad.c  |    2 +-
>  drivers/net/bonding/bond_alb.c  |    2 +-
>  drivers/net/bonding/bond_main.c |   14 +++++++-------
>  3 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index a2ef3f72de88..dee2a84a2929 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2479,7 +2479,7 @@ out:
>  	return NETDEV_TX_OK;
>  err_free:
>  	/* no suitable interface, frame not sent */
> -	kfree_skb(skb);
> +	dev_kfree_skb_any(skb);
>  	goto out;
>  }
>  
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index aaeeacf767f2..9cf836b67b15 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -1464,7 +1464,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  	}
>  
>  	/* no suitable interface, frame not sent */
> -	kfree_skb(skb);
> +	dev_kfree_skb_any(skb);
>  out:
>  	return NETDEV_TX_OK;
>  }
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 730d72c706c9..63f8df8af4d4 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1115,7 +1115,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  	if (recv_probe) {
>  		ret = recv_probe(skb, bond, slave);
>  		if (ret == RX_HANDLER_CONSUMED) {
> -			consume_skb(skb);
> +			dev_consume_skb_any(skb);

Why is this needed ? AFAIK we run in softirq here.

>  			return ret;
>  		}
>  	}
> @@ -1132,7 +1132,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  
>  		if (unlikely(skb_cow_head(skb,
>  					  skb->data - skb_mac_header(skb)))) {
> -			kfree_skb(skb);
> +			dev_kfree_skb_any(skb);

same here.

>  			return RX_HANDLER_CONSUMED;
>  		}
>  		ether_addr_copy(eth_hdr(skb)->h_dest, bond->dev->dev_addr);
> @@ -3548,7 +3548,7 @@ static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int sl
>  		}
