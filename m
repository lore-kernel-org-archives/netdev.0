From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 11:46:15 -0500
Message-ID: <4B4F4A57.5050708@majjas.com>
References: <20100113194148.139091a3@nehalam>
 <20100114101445.GA7210@ff.dom.local> <20100114111636.GB7210@ff.dom.local>
 <20100114.032009.20669539.davem@davemloft.net>
 <20100114112653.GA8543@ff.dom.local> <4B4F19EB.5080207@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:58703 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab0ANQqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 11:46:51 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta1.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW8002ABX9ZBBY0@mta1.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Thu, 14 Jan 2010 11:46:48 -0500 (EST)
In-reply-to: <4B4F19EB.5080207@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/2010 8:19 AM, Mike McCormack wrote:
> Jarek Poplawski wrote:
>    
>> On Thu, Jan 14, 2010 at 03:20:09AM -0800, David Miller wrote:
>>      
>>> From: Jarek Poplawski<jarkao2@gmail.com>
>>> Date: Thu, 14 Jan 2010 11:16:36 +0000
>>>
>>>        
>>>> So, now I really ;-) agree with David: this needs a proper fix.
>>>>          
>>> Now Jarek, do you now see my dirty little secret?
>>>
>>> When people disagree with me, I just silently sit around waiting for
>>> them to eventually change their mind.
>>>
>>> Isn't it brilliant? -)
>>>        
>> If it were that easy... (it never works for me :-()
>>
>> Probably, there is something more... ;-)
>>      
> Here's what was sitting in my tree...
>
>
> Subject: [PATCH] sky2: Don't detach device when restarting
>
> Block the tx queue from transmitting when restarting
>   rather than trying to take the device offline.
>
> Signed-off-by: Mike McCormack<mikem@ring3k.org>
> ---
>   drivers/net/sky2.c |   13 +++++++++----
>   1 files changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index d76d907..061f6f2 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1580,6 +1580,8 @@ static int sky2_up(struct net_device *dev)
>   	if (netif_msg_ifup(sky2))
>   		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
>
> +	netif_start_queue(dev);
> +
>   	return 0;
>
>   err_out:
> @@ -1596,6 +1598,8 @@ static inline int tx_inuse(const struct sky2_port *sky2)
>   /* Number of list elements available for next tx */
>   static inline int tx_avail(const struct sky2_port *sky2)
>   {
> +	if (unlikely(!sky2->tx_ring))
> +		return 0;
>   	return sky2->tx_pending - tx_inuse(sky2);
>   }
>
> @@ -1925,7 +1929,9 @@ static int sky2_down(struct net_device *dev)
>   	sky2_read32(hw, B0_IMSK);
>
>   	synchronize_irq(hw->pdev->irq);
> -	napi_synchronize(&hw->napi);
> +	netif_tx_lock_bh(dev);
> +	napi_disable(&hw->napi);
> +	netif_stop_queue(dev);
>
>   	spin_lock_bh(&sky2->phy_lock);
>   	sky2_phy_power_down(hw, port);
> @@ -1939,6 +1945,8 @@ static int sky2_down(struct net_device *dev)
>   	sky2_rx_clean(sky2);
>
>   	sky2_free_buffers(sky2);
> +	napi_enable(&hw->napi);
> +	netif_tx_unlock_bh(dev);
>
>   	return 0;
>   }
> @@ -3177,9 +3185,6 @@ static void sky2_reset(struct sky2_hw *hw)
>   static void sky2_detach(struct net_device *dev)
>   {
>   	if (netif_running(dev)) {
> -		netif_tx_lock_bh(dev);
> -		netif_device_detach(dev);	/* stop txq */
> -		netif_tx_unlock_bh(dev);
>   		sky2_down(dev);
>   	}
>   }
> -- 1.5.6.5
>    
Ok - no obvious difference with this patch + Stephen's.

I still see:

No reported errors; decent throughput; earlier issues with IRQ resolved.
But... still seeing DHCP DISCOVER/OFFER (no REQUEST/ACK) while under 
load. I can try to sniff this... but given that it's under load, I'd 
probably have to filter out non DHCP stuff and might miss whatever is 
really going on. Again - main point here is that absent these patches I 
don't see this issue. It's also possible that these two patches allow 
the load to be heavier thus actually causing a different problem.
