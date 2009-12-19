From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 1/6] enic: Bug fix: use safe queue shutdown in
 dev->stop
Date: Sat, 19 Dec 2009 15:34:59 +0000
Message-ID: <1261236899.2418.93.camel@localhost>
References: <20091219020758.2745.85264.stgit@savbu-pc100.cisco.com>
	 <20091219020941.2745.47459.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36082 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZLSPfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 10:35:04 -0500
In-Reply-To: <20091219020941.2745.47459.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 18:09 -0800, Scott Feldman wrote:
> enic: Bug fix: use safe queue shutdown in dev->stop
> 
> Fix dev->stop shutdown bug where driver was stopping xmit queue and then
> disabling intrs.  Fix is to disable intrs first and then stop the xmit
> queue, otherwise an interrupt could cause the queue to be rewoken.  Also,
> no need to explicitly do queue servicing because queues are cleaned and
> reset back to initial state at end of dev->stop.  Servicing queues also
> had the side-effect of also rewakening the xmit queue, which is not what
> we want.
[...]
> @@ -1409,16 +1382,18 @@ static int enic_stop(struct net_device *netdev)
>  	unsigned int i;
>  	int err;
>  
> +	for (i = 0; i < enic->intr_count; i++)
> +		vnic_intr_mask(&enic->intr[i]);
> +

I think you need to use synchronize_irq() after this.

>  	del_timer_sync(&enic->notify_timer);
>  
>  	spin_lock(&enic->devcmd_lock);
>  	vnic_dev_disable(enic->vdev);
>  	spin_unlock(&enic->devcmd_lock);
>  	napi_disable(&enic->napi);
> -	netif_stop_queue(netdev);
> -
> -	for (i = 0; i < enic->intr_count; i++)
> -		vnic_intr_mask(&enic->intr[i]);
> +	netif_tx_disable(netdev);
> +	msleep(10);

This sleep is suspicious.

> +	netif_carrier_off(netdev);
[...]

And this should be unnecessary.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

