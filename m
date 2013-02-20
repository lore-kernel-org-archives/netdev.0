From: David Miller <davem@davemloft.net>
Subject: Re: Kernel 3.7.2 strange warning and short system hang
Date: Wed, 20 Feb 2013 12:57:15 -0500 (EST)
Message-ID: <20130220.125715.2150428275032134361.davem@davemloft.net>
References: <5124F57A.6080908@enas.net>
	<1361379176.19353.187.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bind@enas.net, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361379176.19353.187.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Feb 2013 08:52:56 -0800

> I guess tg3 needs to call dev_kfree_skb_any()
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index bdb0869..22d9e44 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -5942,7 +5942,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
>  		pkts_compl++;
>  		bytes_compl += skb->len;
>  
> -		dev_kfree_skb(skb);
> +		dev_kfree_skb_any(skb);
>  
>  		if (unlikely(tx_bug)) {
>  			tg3_tx_recover(tp);

I've seen this pattern on several occasions and I have to wonder...

Do we really require, therefore, every NAPI driver to use dev_kfree_skb_any()
in it's TX reclaim if it supports netpoll?

That seems completely bogus.

netpoll is supposed to provide an execution environment when it invokes
->poll() that is identical to the normal NAPI execution.  If that would
be true, then this change above would be completely unnecessary.

We need to figure out what is the case here, and audit all the NAPI
drivers to make sure they do the right thing once we know what the
right thing actually is.
