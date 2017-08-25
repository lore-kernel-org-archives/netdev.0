From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2] net: mv643xx_eth: Be drop monitor friendly
Date: Fri, 25 Aug 2017 09:44:12 -0700
Message-ID: <d4947e36-7892-ef54-1177-4627eac0e9b3@gmail.com>
References: <20170825035540.26713-1-f.fainelli@gmail.com>
 <1503635699.2499.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        open list <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503635699.2499.100.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/2017 09:34 PM, Eric Dumazet wrote:
> On Thu, 2017-08-24 at 20:55 -0700, Florian Fainelli wrote:
>> txq_reclaim() does the normal transmit queue reclamation and
>> rxq_deinit() does the RX ring cleanup, none of these are packet drops,
>> so use dev_consume_skb() for both locations.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/ethernet/marvell/mv643xx_eth.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
>> index fb2d533ae4ef..81c1fac00d33 100644
>> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
>> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
>> @@ -1121,7 +1121,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>>  			struct sk_buff *skb = __skb_dequeue(&txq->tx_skb);
>>  
>>  			if (!WARN_ON(!skb))
>> -				dev_kfree_skb(skb);
>> +				dev_consume_skb_any(skb);
>>  		}
>>  
>>  		if (cmd_sts & ERROR_SUMMARY) {
>> @@ -2024,7 +2024,7 @@ static void rxq_deinit(struct rx_queue *rxq)
>>  
>>  	for (i = 0; i < rxq->rx_ring_size; i++) {
>>  		if (rxq->rx_skb[i]) {
>> -			dev_kfree_skb(rxq->rx_skb[i]);
>> +			dev_consume_skb_any(rxq->rx_skb[i]);
>>  			rxq->rx_desc_count--;
>>  		}
>>  	}
> 
> 
> I do not believe this patch is needed.
> 
> dev_kfree_skb() is an alias of consume_skb(), which is already drop
> monitor ready ;)

You are right, this patch is/was not needed, I have been too trigger
happy with the dev_kfree_skb*() replacement, but only
dev_kfree_skb_{any,irq} are valid candidates for replacement by
dev_consume_skb_{any,irq}. I will re-audit my other two submissions to
e1000e and r8169. Thanks Eric.
-- 
Florian
