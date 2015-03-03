From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Tue, 03 Mar 2015 08:09:19 -0800
Message-ID: <54F5DCAF.9070102@redhat.com>
References: <1425383112-23851-1-git-send-email-nschichan@freebox.fr>	 <1425389399.5130.169.camel@edumazet-glaptop2.roam.corp.google.com> <1425390142.5130.173.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	Felipe Balbi <balbi@ti.com>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbbCCQJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 11:09:35 -0500
In-Reply-To: <1425390142.5130.173.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/03/2015 05:42 AM, Eric Dumazet wrote:
> On Tue, 2015-03-03 at 05:29 -0800, Eric Dumazet wrote:
>> On Tue, 2015-03-03 at 12:45 +0100, Nicolas Schichan wrote:
>>> In case there was some tx buffer reclaimed and not enough rx packets
>>> to consume the whole budget, napi_complete would not be called and
>>> interrupts would be kept disabled, effectively resulting in the
>>> network core never to call the poll callback again and no rx/tx
>>> interrupts to be fired either.
>>>
>>> Fix that by only accounting the rx work done in the poll callback.
>>>
>>> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
>>> ---
>> This looks better, thanks.
>>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>>
>> Note that the way bcm_enet_tx_reclaim() is written, it can livelock on
>> SMP hosts :
>>
>> CPU 1,2,3,...  keep queuing packets via ndo_start_xmit()
>>
>> CPU 0 is looping forever in bcm_enet_tx_reclaim() draining queue and
>> freeing skbs.
>>
>> To avoid that, I would take priv->tx_lock only once, or add a limit on
>> the number of skbs that can be drained per round.
> Something like this (untested) patch
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> index 21206d33b638..9e8e83865e52 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -429,29 +429,23 @@ static int bcm_enet_receive_queue(struct net_device *dev, int budget)
>    */
>   static int bcm_enet_tx_reclaim(struct net_device *dev, int force)
>   {
> -	struct bcm_enet_priv *priv;
> -	int released;
> +	struct bcm_enet_priv *priv = netdev_priv(dev);
> +	int released = 0;
>   
> -	priv = netdev_priv(dev);
> -	released = 0;
> +	spin_lock(&priv->tx_lock);
>   
>   	while (priv->tx_desc_count < priv->tx_ring_size) {
>   		struct bcm_enet_desc *desc;
>   		struct sk_buff *skb;
>   
> -		/* We run in a bh and fight against start_xmit, which
> -		 * is called with bh disabled  */
> -		spin_lock(&priv->tx_lock);
> -
>   		desc = &priv->tx_desc_cpu[priv->tx_dirty_desc];
>   
> -		if (!force && (desc->len_stat & DMADESC_OWNER_MASK)) {
> -			spin_unlock(&priv->tx_lock);
> +		if (!force && (desc->len_stat & DMADESC_OWNER_MASK))
>   			break;
> -		}
>   
>   		/* ensure other field of the descriptor were not read
> -		 * before we checked ownership */
> +		 * before we checked ownership
> +		 */
>   		rmb();
>   

This rmb() can probably be replaced with a dma_rmb() since it is just a 
coherent/coherent ordering you are concerned with based on the comment.

- Alex
