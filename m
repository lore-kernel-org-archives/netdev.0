From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH] ks8851: Cancel any pending IRQ work
Date: Thu, 12 Apr 2012 13:19:55 -0700
Message-ID: <4F8738EB.2060806@codeaurora.org>
References: <1334249091-7605-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ben@simtec.co.uk, netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:51483 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487Ab2DLUT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:19:56 -0400
In-Reply-To: <1334249091-7605-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/12 09:44, mjr@cs.wisc.edu wrote:
> From: Matt Renzelmann <mjr@cs.wisc.edu>
>
> An unexpected/spurious interrupt may cause the irq_work queue to
> execute during or after module unload, which can cause a crash.  It
> should be canceled.
>
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> ---
>  drivers/net/ethernet/micrel/ks8851.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> index c722aa6..ab46953 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -1540,6 +1540,7 @@ static int __devexit ks8851_remove(struct spi_device *spi)
>  		dev_info(&spi->dev, "remove\n");
>  
>  	unregister_netdev(priv->netdev);
> +	cancel_work_sync(&priv->irq_work);
>  	free_irq(spi->irq, priv);
>  	free_netdev(priv->netdev);
>  

Is this actually solving anything? Presumably cancel_work_sync() could
run and then another spurious interrupt could come in after that
function returns and we would have the same problem again. We should
probably free the irq before unregistering the netdev so that
ks8851_net_stop() would run after the interrupt is no longer registered,
and the flush_work() in there would finish the last work. But then we
have a problem where we're enabling the irq in the irq_work callback
after the irq has been freed. Ugh.

I also see a potential deadlock in ks8851_net_stop(). ks8851_net_stop()
holds the ks->lock while calling flush_work() which could deadlock if an
interrupt comes and schedules an irq_work between the time
ks8851_net_stop() grabs the mutex and calls flush_work().

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
