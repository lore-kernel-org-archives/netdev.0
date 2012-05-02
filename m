From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding: don't increase rx_dropped after processing LACPDUs
Date: Wed, 02 May 2012 22:36:49 +0200
Message-ID: <1335991009.22133.639.camel@edumazet-glaptop>
References: <20120502202309.GA25355@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64512 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab2EBUgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 16:36:55 -0400
Received: by bkcji2 with SMTP id ji2so814862bkc.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 13:36:53 -0700 (PDT)
In-Reply-To: <20120502202309.GA25355@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 22:23 +0200, Jiri Bohac wrote:
> Since commit 3aba891d, bonding processes LACP frames (802.3ad
> mode) with bond_handle_frame(). Currently a copy of the skb is
> made and the original is left to be processed by other
> rx_handlers and the rest of the network stack by returning
> RX_HANDLER_ANOTHER.  As there is no protocol handler for
> PKT_TYPE_LACPDU, the frame is dropped and dev->rx_dropped
> increased.
> 
> Fix this by making bond_handle_frame() return RX_HANDLER_CONSUMED
> if bonding has processed the LACP frame.  
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 

Nice idea but...

> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1444,8 +1444,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  	struct sk_buff *skb = *pskb;
>  	struct slave *slave;
>  	struct bonding *bond;
> -	void (*recv_probe)(struct sk_buff *, struct bonding *,
> +	int (*recv_probe)(struct sk_buff *, struct bonding *,
>  				struct slave *);
> +	int ret = RX_HANDLER_ANOTHER;
>  
>  	skb = skb_share_check(skb, GFP_ATOMIC);
>  	if (unlikely(!skb))
> @@ -1464,8 +1465,10 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
>  
>  		if (likely(nskb)) {
> -			recv_probe(nskb, bond, slave);
> +			ret = recv_probe(nskb, bond, slave);
>  			dev_kfree_skb(nskb);
> +			if (ret == RX_HANDLER_CONSUMED)
> +				kfree_skb(skb);

After this point, you have use after free :

if (bond_should_deliver_exact_match(skb, slave, bond)) { 
	...
}
skb->dev = bond->dev;
...


>  		}
>  	}
>  
> @@ -1487,7 +1490,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
>  	}
>  
> -	return RX_HANDLER_ANOTHER;
> +	return ret;
>  }
>  
