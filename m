From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH][VIA-RHINE]: Fix CONFIG_VIA_RHINE_NAPI usage
Date: Wed, 22 Aug 2007 19:19:47 -0300
Message-ID: <20070822221946.GE23220@ghostprotocols.net>
References: <20070822214659.GC23220@ghostprotocols.net> <20070822.145855.32177470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:54552 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934150AbXHVWTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 18:19:55 -0400
Received: by wr-out-0506.google.com with SMTP id 36so246858wra
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 15:19:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070822.145855.32177470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Aug 22, 2007 at 02:58:55PM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Wed, 22 Aug 2007 18:46:59 -0300
> 
> > Hi David,
> > 
> > 	napi is broken here, with this patch at least I can isolate this
> > breakage and boot the machine with a non-napi via-rhine driver.
> > 
> 
> Thanks for finding this problem.
> 
> The core issue seems to be that via-rhine.c tries to perform
> a napi_enable() when there has not been a previous napi_disable().
> 
> So lets make sure that all paths that lead to an init_registers()
> call makes a preceeding napi_disable().
> 
> Please give this patch a try:

Tried with and without CONFIG_VIA_RHINE_NAPI, did stress testing with
netperf only with NAPI enabled. Works great


Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
 
> diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
> index 8f4cf82..0e6aefe 100644
> --- a/drivers/net/via-rhine.c
> +++ b/drivers/net/via-rhine.c
> @@ -1167,6 +1167,7 @@ static int rhine_open(struct net_device *dev)
>  		free_irq(rp->pdev->irq, dev);
>  		return rc;
>  	}
> +	napi_disable(&rp->napi);
>  	alloc_rbufs(dev);
>  	alloc_tbufs(dev);
>  	rhine_chip_reset(dev);
> @@ -1195,6 +1196,8 @@ static void rhine_tx_timeout(struct net_device *dev)
>  	/* protect against concurrent rx interrupts */
>  	disable_irq(rp->pdev->irq);
>  
> +	napi_disable(&rp->napi);
> +
>  	spin_lock(&rp->lock);
>  
>  	/* clear all descriptors */
> @@ -1935,6 +1938,7 @@ static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
>  	if (!netif_running(dev))
>  		return 0;
>  
> +	napi_disable(&rp->napi);
>  	netif_device_detach(dev);
>  	pci_save_state(pdev);
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
