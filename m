From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ehea: Fixing LRO configuration
Date: Wed, 08 Dec 2010 18:44:09 +0000
Message-ID: <1291833849.2560.26.camel@bwh-desktop>
References: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46854 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127Ab0LHSoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:44:12 -0500
In-Reply-To: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-08 at 16:31 -0200, leitao@linux.vnet.ibm.com wrote:
> In order to set LRO on ehea, the user must set a module parameter, which
> is not the standard way to do so. This patch adds a way to set LRO using
> the ethtool tool.
[...]
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index a84c389..c7132e8 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -675,7 +675,7 @@ static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
>  	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
>  			      pr->port->vgrp);
>  
> -	if (use_lro) {
> +	if (skb->dev->features && NETIF_F_LRO) {

Should be & not &&.

>  		if (vlan_extracted)
>  			lro_vlan_hwaccel_receive_skb(&pr->lro_mgr, skb,
>  						     pr->port->vgrp,
> @@ -777,7 +777,7 @@ static int ehea_proc_rwqes(struct net_device *dev,
>  		}
>  		cqe = ehea_poll_rq1(qp, &wqe_index);
>  	}
> -	if (use_lro)
> +	if (dev->features && NETIF_F_LRO)

Ditto.

Ben.

>  		lro_flush_all(&pr->lro_mgr);
>  
>  	pr->rx_packets += processed;
> @@ -3265,6 +3265,9 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
>  		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
>  		      | NETIF_F_LLTX;
>  	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
> +
> +	if (use_lro)
> +		dev->features |= NETIF_F_LRO;
>  
>  	INIT_WORK(&port->reset_task, ehea_reset_port);
>  

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

