From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: bond_select_queue off by one
Date: Fri, 18 Feb 2011 03:46:31 +0000
Message-ID: <1298000791.6865.2.camel@localhost>
References: <20110218020713.GA9696@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2950 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525Ab1BRDqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 22:46:38 -0500
In-Reply-To: <20110218020713.GA9696@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-17 at 18:07 -0800, Phil Oester wrote:
> The bonding driver's bond_select_queue function simply returns
> skb->queue_mapping.  However queue_mapping could be == 16
> for queue #16.  This causes the following message to be flooded
> to syslog:
> 
> kernel: bondx selects TX queue 16, but real number of TX queues is 16
> 
> ndo_select_queue wants a zero-based number, so bonding driver needs
> to subtract one to return the proper queue number.  Also fix grammar in
> a comment while in the vicinity.
> 
> Phil Oester
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>

> --- linux-2.6/drivers/net/bonding/bond_main.c.orig      2011-01-30 09:15:09.813843817 -0800
> +++ linux-2.6/drivers/net/bonding/bond_main.c   2011-02-17 18:02:46.919050909 -0800
> @@ -4537,11 +4537,11 @@
>  {
>         /*
>          * This helper function exists to help dev_pick_tx get the correct
> -        * destination queue.  Using a helper function skips the a call to
> +        * destination queue.  Using a helper function skips a call to
>          * skb_tx_hash and will put the skbs in the queue we expect on their
>          * way down to the bonding driver.
>          */
> -       return skb->queue_mapping;
> +       return skb->queue_mapping ? skb->queue_mapping - 1 : 0;
>  }
>  
>  static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev) 

This looks basically correct, but it should use the proper functions:

	skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

