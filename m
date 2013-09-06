From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/arc/arc_emac: optimize the Tx/Tx-reclaim
 paths a bit
Date: Fri, 06 Sep 2013 01:03:03 -0400 (EDT)
Message-ID: <20130906.010303.1964966449906114324.davem@davemloft.net>
References: <1378299791-24598-1-git-send-email-vgupta@synopsys.com>
	<20130905.142436.685399325201245026.davem@davemloft.net>
	<C2D7FE5348E1B147BCA15975FBA23075141D3B@IN01WEMBXA.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey.Brodkin@synopsys.com,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	arc-linux-dev@synopsys.com
To: Vineet.Gupta1@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075141D3B@IN01WEMBXA.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Fri, 6 Sep 2013 04:24:39 +0000

> On 09/05/2013 11:54 PM, David Miller wrote:
>> You should keep the check in the transmit queueing code as a BUG check,
>> almost every driver has code of the form (using NIU as an example):
 ...
>> Otherwise queue management bugs are incredibly hard to diagnose.
>>
>> I'm not applying this patch.
> 
> The check is already there for current BD. What I removed was checking for next BD
> too (please see below). IMHO this is useless since it will be done in next
> iteration anyways. In my tests, the next check never got hit, so it was waste of
> cycles.
> 
> static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> {
>     if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC)) {
>         netif_stop_queue(ndev);
>         return NETDEV_TX_BUSY;
>     }
> 
> ...
>         *txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> 
> -       /* Get "info" of the next BD */
> -       info = &priv->txbd[*txbd_curr].info;
> -
> -       /* Check if if Tx BD ring is full - next BD is still owned by EMAC */
> -       if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC))
> -               netif_stop_queue(ndev);
> 
> OTOH, I do see a slight stats update issue - if the queue is stopped (but pkt not
> dropped) we are failing to increment tx_errors. But that would be a separate patch.

It is exactly the correct thing to do.  The driver should _NEVER_
return NETDEV_TX_BUSY under normal circumstances.  The queue should
always be stopped by the ->ndo_start_xmit() method when it fills the
queue.

Again, when ->ndo_start_xmit() is invoked, it should never see the
queue full.  When that happens it is a bug.

You are deleting exactly the correct part of this function, what it is
doing right now is precisely the correct way to manage netif queue
state.

The only valid change you can make here is to make the:

	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC)) {
		netif_stop_queue(ndev);
		return NETDEV_TX_BUSY;
	}

print out an error message and increment tx_errors.
