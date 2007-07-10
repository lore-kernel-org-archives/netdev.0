From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 7990 : Various fixes and cleanups
Date: Tue, 10 Jul 2007 12:38:45 -0400
Message-ID: <4693B615.6010605@garzik.org>
References: <20070706095828.GA12270@muff.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60110 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761828AbXGJQis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:38:48 -0400
In-Reply-To: <20070706095828.GA12270@muff.macqel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe De Muyter wrote:
> This patch
> - avoids 7990 blocking when no tx buffer is available,
[...]
> diff -r 6c0a10cc415a drivers/net/7990.c
> --- a/drivers/net/7990.c	Thu Jul  5 16:10:16 2007 -0700
> +++ b/drivers/net/7990.c	Fri Jul  6 11:27:20 2007 +0200
[...]
> @@ -541,9 +546,6 @@ int lance_start_xmit (struct sk_buff *sk
>          static int outs;
>  	unsigned long flags;
>  
> -        if (!TX_BUFFS_AVAIL)
> -                return -1;
> -
>  	netif_stop_queue (dev);
>  
>          skblen = skb->len;
> @@ -565,9 +567,11 @@ int lance_start_xmit (struct sk_buff *sk
>          ib->btx_ring [entry].length = (-len) | 0xf000;
>          ib->btx_ring [entry].misc = 0;
>  
> -	if (skb->len < ETH_ZLEN)
> -		memset((void *)&ib->tx_buf[entry][0], 0, ETH_ZLEN);
>          skb_copy_from_linear_data(skb, (void *)&ib->tx_buf[entry][0], skblen);
> +    	if (skblen < ETH_ZLEN)
> +    		memset((char *)&ib->tx_buf[entry][0] + skblen, 0, ETH_ZLEN - skblen);
> +
> +	lp->stats.tx_bytes += skblen;


NAK

It "avoids" by removing an overrun check in hard_start_xmit that should 
not be removed.

