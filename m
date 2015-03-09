From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: bcmgenet: add support for xmit_more
Date: Mon, 9 Mar 2015 15:13:12 -0700
Message-ID: <CAGVrzcYKYGtGWdUGK8OW_DeWba2OG78t+SObwsQPMARtz_aHvA@mail.gmail.com>
References: <1425937937-26955-1-git-send-email-f.fainelli@gmail.com>
 <1425937937-26955-3-git-send-email-f.fainelli@gmail.com> <1425939020.8261.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:46416 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbbCIWNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:13:53 -0400
Received: by iecrd18 with SMTP id rd18so16758962iec.13
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:13:52 -0700 (PDT)
In-Reply-To: <1425939020.8261.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-09 15:10 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2015-03-09 at 14:52 -0700, Florian Fainelli wrote:
>> Delay the update of the TDMA producer index unless this is the last SKB in a
>> batch, or the queue is already stopped.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index 9b3b8a3db59b..8419826da6a7 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -1316,8 +1316,10 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
>>       ring->prod_index += nr_frags + 1;
>>       ring->prod_index &= DMA_P_INDEX_MASK;
>>
>> -     bcmgenet_tdma_ring_writel(priv, ring->index,
>> -                               ring->prod_index, TDMA_PROD_INDEX);
>> +     if (!skb->xmit_more || netif_xmit_stopped(txq))
>> +             /* Packets are ready, update producer index */
>> +             bcmgenet_tdma_ring_writel(priv, ring->index,
>> +                                       ring->prod_index, TDMA_PROD_INDEX);
>>
>>       if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
>>               netif_tx_stop_queue(txq);
>
> It seems you have a race here, if you stop the queue right now, while
> this skb had skb->xmit_more set.

bcmgenet_xmit() and bcmgenet_tx_reclaim() are the only two functions
that can stop a queue, and they are using a spinlock to avoid that.
--
Florian
