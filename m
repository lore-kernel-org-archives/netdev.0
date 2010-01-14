From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 09:51:20 -0800
Message-ID: <20100114095120.59236446@nehalam>
References: <20100113194148.139091a3@nehalam>
	<20100114101445.GA7210@ff.dom.local>
	<20100114111636.GB7210@ff.dom.local>
	<20100114.032009.20669539.davem@davemloft.net>
	<20100114112653.GA8543@ff.dom.local>
	<4B4F19EB.5080207@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, mbreuer@majjas.com,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50797 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102Ab0ANRvg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 12:51:36 -0500
In-Reply-To: <4B4F19EB.5080207@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jan 2010 22:19:39 +0900
Mike McCormack <mikem@ring3k.org> wrote:

>  /* Number of list elements available for next tx */
>  static inline int tx_avail(const struct sky2_port *sky2)
>  {
> +	if (unlikely(!sky2->tx_ring))
> +		return 0;
>  	return sky2->tx_pending - tx_inuse(sky2);
>  }
>

Breaks in detach case

> @@ -1925,7 +1929,9 @@ static int sky2_down(struct net_device *dev)
>  	sky2_read32(hw, B0_IMSK);
>  
>  	synchronize_irq(hw->pdev->irq);
> -	napi_synchronize(&hw->napi);
> +	netif_tx_lock_bh(dev);
> +	napi_disable(&hw->napi);
> +	netif_stop_queue(dev);
>  
>  	spin_lock_bh(&sky2->phy_lock);
>  	sky2_phy_power_down(hw, port);
> @@ -1939,6 +1945,8 @@ static int sky2_down(struct net_device *dev)
>  	sky2_rx_clean(sky2);
>  
>  	sky2_free_buffers(sky2);
> +	napi_enable(&hw->napi);
> +	netif_tx_unlock_bh(dev);
>  
>  	return 0;

Breaks on dual ported boards
