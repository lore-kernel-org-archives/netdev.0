From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Wed, 28 Feb 2007 19:18:12 -0800
Message-ID: <45E645F4.2090403@intel.com>
References: <45E64080.4070004@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18548 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932625AbXCADSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 22:18:15 -0500
In-Reply-To: <45E64080.4070004@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Huth wrote:
> Current e1000_xmit_frame spews raw interrupt disabled nag messages when
> used with RT kernel patches.  This patch uses spin_trylock_irqsave,
> which allows RT patches to properly manage the irq semantics.

Looks OK with me on first sight, I'll keep it on my stack and push it upstream 
after Jesse looks it over.

Which -RT paches make this pop up btw? I'd like to repro it.

Thanks,

Auke




> Signed-off-by: Mark Huth <mhuth@mvista.com>
> ---
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 619c892..48f94ee 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3363,12 +3363,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  	    (adapter->hw.mac_type == e1000_82573))
>  		e1000_transfer_dhcp_info(adapter, skb);
>  
> -	local_irq_save(flags);
> -	if (!spin_trylock(&tx_ring->tx_lock)) {
> +	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
>  		/* Collision - tell upper layer to requeue */
> -		local_irq_restore(flags);
>  		return NETDEV_TX_LOCKED;
> -	}
>  
>  	/* need: count + 2 desc gap to keep tail from touching
>  	 * head, otherwise try next time */
