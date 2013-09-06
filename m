From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH] ethernet/arc/arc_emac: optimize the Tx/Tx-reclaim paths
 a bit
Date: Fri, 6 Sep 2013 04:24:39 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075141D3B@IN01WEMBXA.internal.synopsys.com>
References: <1378299791-24598-1-git-send-email-vgupta@synopsys.com>
 <20130905.142436.685399325201245026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Alexey.Brodkin@synopsys.com" <Alexey.Brodkin@synopsys.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 09/05/2013 11:54 PM, David Miller wrote:
> From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
> Date: Wed, 4 Sep 2013 18:33:11 +0530
>
>> This came out of staring at code due to recent performance fix.
>>
>> * TX BD reclaim can call netif_wake_queue() once, outside the loop if
>>   one/more BDs were freed, NO need to do this each iteration.
>>
>> * TX need not look at next BD to stop the netif queue. It rather be done
>>   in the next tx call, when it actually fails as the queue seldom gets
>>   full but the check nevertheless needs to be done for each packet Tx.
>>   Profiled this under heavy traffic (big tar file cp, LMBench betworking
>>   tests) and saw not a single hit to that code.
>>
>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> You should keep the check in the transmit queueing code as a BUG check,
> almost every driver has code of the form (using NIU as an example):
>
> 	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
> 		netif_tx_stop_queue(txq);
> 		dev_err(np->device, "%s: BUG! Tx ring full when queue awake!\n", dev->name);
> 		rp->tx_errors++;
> 		return NETDEV_TX_BUSY;
> 	}
>
> and arc_emac should too.
>
> Otherwise queue management bugs are incredibly hard to diagnose.
>
> I'm not applying this patch.

The check is already there for current BD. What I removed was checking for next BD
too (please see below). IMHO this is useless since it will be done in next
iteration anyways. In my tests, the next check never got hit, so it was waste of
cycles.

static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
{
    if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC)) {
        netif_stop_queue(ndev);
        return NETDEV_TX_BUSY;
    }

...
        *txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;

-       /* Get "info" of the next BD */
-       info = &priv->txbd[*txbd_curr].info;
-
-       /* Check if if Tx BD ring is full - next BD is still owned by EMAC */
-       if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC))
-               netif_stop_queue(ndev);

OTOH, I do see a slight stats update issue - if the queue is stopped (but pkt not
dropped) we are failing to increment tx_errors. But that would be a separate patch.

-Vineet
