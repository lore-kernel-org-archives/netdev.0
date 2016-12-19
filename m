From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS
Date: Mon, 19 Dec 2016 10:55:33 +0000
Message-ID: <3c70d3c0-d312-054f-6e8c-54035c63573e@synopsys.com>
References: <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com> <20161214125735.GA19542@amd>
 <79642215-95ce-7f04-3db7-121c585e2f2a@synopsys.com>
 <20161217173824.GB20231@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "Andy Shevchenko" <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>, <larper@axis.com>,
        <rabinv@axis.com>, netdev <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Jie.Deng1@synopsys.com>,
        Stephen Warren <swarren@nvidia.com>
To: Pavel Machek <pavel@ucw.cz>, Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:52090 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758732AbcLSKzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 05:55:40 -0500
In-Reply-To: <20161217173824.GB20231@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Pavel,

Às 5:38 PM de 12/17/2016, Pavel Machek escreveu:
> Hi!
> 
>>>> So if there is a long time before handling interrupts,
>>>> I guess that it makes sense that one stream could
>>>> get an advantage in the net scheduler.
>>>>
>>>> If I find the time, and if no one beats me to it, I will try to replace
>>>> the normal timers with HR timers + a smaller default timeout.
>>>>
>>>
>>> Can you try something like this? Highres timers will be needed, too,
>>> but this fixes the logic problem.
>>>
>>> You'll need to apply it twice as code is copy&pasted.
>>>
>>> Best regards,
>>> 									Pavel
>>>
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>
>>>  	 */
>>>  	priv->tx_count_frames += nfrags + 1;
>>>  	if (likely(priv->tx_coal_frames > priv->tx_count_frames)) {
>>> -		mod_timer(&priv->txtimer,
>>> -			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
>>> +		if (priv->tx_count_frames == nfrags + 1)
>>> +			mod_timer(&priv->txtimer,
>>> +				  STMMAC_COAL_TIMER(priv->tx_coal_timer));
>>>  	} else {
>>>  		priv->tx_count_frames = 0;
>>>  		priv->hw->desc->set_tx_ic(desc);
>>>
>>>
>>
>> I know that this is completely of topic, but I am facing a dificulty with
>> stmmac. I have interrupts, mac well configured rx packets being received
>> successfully, but TX is not working, resulting in Tx errors = Total TX packets.
>> I have made a lot of debug and my conclusions is that by some reason when using
>> stmmac after starting tx dma, the hw state machine enters a deadend state
>> resulting in those errors. Anyone faced this trouble?
> 
> SMP or UP system? AFAICT the driver gets the memory barriers wrong. It
> does not fail completely for me, but still fails rather quickly.

I was able to put my setup receiving and transmiting packets. The problem is
that because my hw controller supports multi-queues, I had to enable the TX
queue 0 in order for it to work.

Now I am facing a new problem. My DUT with stmmac does not answer to ARP
messages. When I execute a "ping" the other machine in the nework executes a ARP
message asking "who is the owner of IP XXXX" which my DUT does not reply. I used
wireshark and the ARP messages are reaching the DUT machine, but for some reason
it does not reply. Did you ever face this problem when using stmmac?

When using my internal driver, it works perfectly, so some detail in the stmmac
I suppose.

Tahnks.

> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3e40578..641b03d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2121,11 +2205,11 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (mss_desc)
>  		priv->hw->desc->set_tx_owner(mss_desc);
>  
> -	/* The own bit must be the latest setting done when prepare the
> +	/* The own bit must be the latest setting done when preparing the
>  	 * descriptor and then barrier is needed to make sure that
>  	 * all is coherent before granting the DMA engine.
>  	 */
> -	smp_wmb();
> +	wmb();
>  
>  	if (netif_msg_pktdata(priv)) {
>  		pr_info("%s: curr=%d dirty=%d f=%d, e=%d, f_p=%p, nfrags %d\n",
> @@ -2336,9 +2401,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  		/* The own bit must be the latest setting done when prepare the
>  		 * descriptor and then barrier is needed to make sure that
> -		 * all is coherent before granting the DMA engine.
> +		 * all is coherent before granting access to the DMA engine.
>  		 */
> -		smp_wmb();
> +		wmb();
>  	}
>  
>  	netdev_sent_queue(dev, skb->len);
> 
> Plus I'd suggest... at least (hand-edited). Driver should really be
> modified to use readl() when accessing memory that changes.
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3e40578..641b03d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1309,6 +1323,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>  		status = priv->hw->desc->tx_status(&priv->dev->stats,
>  						      &priv->xstats, p,
>  						      priv->ioaddr);
> +		rmb();
> +		
>  		/* Check if the descriptor is owned by the DMA */
>  		if (unlikely(status & tx_dma_own))
>  			break;
> 
> 									Pavel
> 
