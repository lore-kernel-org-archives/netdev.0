From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Thu, 26 Apr 2007 10:30:04 -0400
Message-ID: <4630B76C.7070603@nvidia.com>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:19196 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031377AbXDZSNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 14:13:10 -0400
In-Reply-To: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't see why the NAPI handler needs to process tx packets. The ISR 
will handle all tx processing.


akpm@linux-foundation.org wrote:
> From: Ingo Molnar <mingo@elte.hu>
> 
> Another forcedeth.c thing: i noticed that its NAPI handler does not do
> tx-ring processing.  The patch below implements this - tested on DESC_VER_2
> hardware, with CONFIG_FORCEDETH_NAPI=y.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-improve-napi-logic drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-improve-napi-logic
> +++ a/drivers/net/forcedeth.c
> @@ -3108,9 +3108,17 @@ static int nv_napi_poll(struct net_devic
>  	int retcode;
>  
>  	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
> +		spin_lock_irqsave(&np->lock, flags);
> +		nv_tx_done(dev);
> +		spin_unlock_irqrestore(&np->lock, flags);
> +
>  		pkts = nv_rx_process(dev, limit);
>  		retcode = nv_alloc_rx(dev);
>  	} else {
> +		spin_lock_irqsave(&np->lock, flags);
> +		nv_tx_done_optimized(dev, np->tx_ring_size);
> +		spin_unlock_irqrestore(&np->lock, flags);
> +
>  		pkts = nv_rx_process_optimized(dev, limit);
>  		retcode = nv_alloc_rx_optimized(dev);
>  	}
> _
