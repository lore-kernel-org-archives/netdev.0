From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 03/15] ehea: Remove force_irq logic in napi poll routine
Date: Tue, 24 May 2011 13:32:35 +1000
Message-ID: <1306207955.7481.212.camel@pasglop>
References: <20110512005213.897432612@samba.org>
	 <20110512005622.766206152@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44045 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756501Ab1EXDhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 May 2011 23:37:15 -0400
In-Reply-To: <20110512005622.766206152@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> plain text document attachment (ehea_3.patch)
> commit 18604c548545 (ehea: NAPI multi queue TX/RX path for SMP) added
> driver specific logic for exiting napi mode. I'm not sure what it was
> trying to solve and it should be up to the network stack to decide when
> we are done polling so remove it.

I -think- the force_irq trick was meant to allow migration of the
workload if the interrupt moved. IE. Without it, continuous traffic
would cause NAPI to always happen on the same CPU, regardless of the
affinity of the corresponding queue IRQ.

I suspect all of that is obsoleted by the newer generic infrastructure.

Cheers,
Ben.

> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
> 
> Index: linux-net/drivers/net/ehea/ehea_main.c
> ===================================================================
> --- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:49.640116670 +1000
> +++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:51.960153456 +1000
> @@ -927,7 +927,6 @@ static struct ehea_cqe *ehea_proc_cqes(s
>  	return cqe;
>  }
>  
> -#define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
>  #define EHEA_POLL_MAX_CQES 65535
>  
>  static int ehea_poll(struct napi_struct *napi, int budget)
> @@ -937,18 +936,13 @@ static int ehea_poll(struct napi_struct
>  	struct net_device *dev = pr->port->netdev;
>  	struct ehea_cqe *cqe;
>  	struct ehea_cqe *cqe_skb = NULL;
> -	int force_irq, wqe_index;
> +	int wqe_index;
>  	int rx = 0;
>  
> -	force_irq = (pr->poll_counter > EHEA_NAPI_POLL_NUM_BEFORE_IRQ);
>  	cqe_skb = ehea_proc_cqes(pr, EHEA_POLL_MAX_CQES);
> +	rx += ehea_proc_rwqes(dev, pr, budget - rx);
>  
> -	if (!force_irq)
> -		rx += ehea_proc_rwqes(dev, pr, budget - rx);
> -
> -	while ((rx != budget) || force_irq) {
> -		pr->poll_counter = 0;
> -		force_irq = 0;
> +	while ((rx != budget)) {
>  		napi_complete(napi);
>  		ehea_reset_cq_ep(pr->recv_cq);
>  		ehea_reset_cq_ep(pr->send_cq);
> @@ -968,7 +962,6 @@ static int ehea_poll(struct napi_struct
>  		rx += ehea_proc_rwqes(dev, pr, budget - rx);
>  	}
>  
> -	pr->poll_counter++;
>  	return rx;
>  }
>  
> Index: linux-net/drivers/net/ehea/ehea.h
> ===================================================================
> --- linux-net.orig/drivers/net/ehea/ehea.h	2011-05-12 07:47:49.640116670 +1000
> +++ linux-net/drivers/net/ehea/ehea.h	2011-05-12 07:47:51.960153456 +1000
> @@ -383,7 +383,6 @@ struct ehea_port_res {
>  	u64 tx_bytes;
>  	u64 rx_packets;
>  	u64 rx_bytes;
> -	u32 poll_counter;
>  	struct net_lro_mgr lro_mgr;
>  	struct net_lro_desc lro_desc[MAX_LRO_DESCRIPTORS];
>  	int sq_restart_flag;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


