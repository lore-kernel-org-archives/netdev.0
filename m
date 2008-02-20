From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates
Date: Wed, 20 Feb 2008 15:38:21 -0500
Message-ID: <47BC8FBD.2070401@garzik.org>
References: <20080211170516.GA13872@havoc.gtf.org> <47B0AB0B.806@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37518 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759068AbYBTUiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 15:38:25 -0500
In-Reply-To: <47B0AB0B.806@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> Jeff Garzik wrote:
>> Mostly fixes, a few cleanups (generally assisting fixes), and an
>> exception for PS3 wireless because it had been posted, reviewed and
>> acked for a while, just not committed.
>>
>> Please pull from 'upstream-davem' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
>> upstream-davem
>>
>> to receive the following updates:
>>
>>  
>>  drivers/net/cxgb3/sge.c          |   35 +-
>>    
>> diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
>> index 9ca8c66..979f3fc 100644
>> --- a/drivers/net/cxgb3/sge.c
>> +++ b/drivers/net/cxgb3/sge.c
>> @@ -1059,6 +1059,14 @@ static void write_tx_pkt_wr(struct adapter 
>> *adap, struct sk_buff *skb,
>>               htonl(V_WR_TID(q->token)));
>>  }
>>  
>> +static inline void t3_stop_queue(struct net_device *dev, struct 
>> sge_qset *qs,
>> +                 struct sge_txq *q)
>> +{
>> +    netif_stop_queue(dev);
>> +    set_bit(TXQ_ETH, &qs->txq_stopped);
>> +    q->stops++;
>> +}
>> +
>>  /**
>>   *    eth_xmit - add a packet to the Ethernet Tx queue
>>   *    @skb: the packet
>> @@ -1090,31 +1098,18 @@ int t3_eth_xmit(struct sk_buff *skb, struct 
>> net_device *dev)
>>      ndesc = calc_tx_descs(skb);
>>  
>>      if (unlikely(credits < ndesc)) {
>> -        if (!netif_queue_stopped(dev)) {
>> -            netif_stop_queue(dev);
>> -            set_bit(TXQ_ETH, &qs->txq_stopped);
>> -            q->stops++;
>> -            dev_err(&adap->pdev->dev,
>> -                "%s: Tx ring %u full while queue awake!\n",
>> -                dev->name, q->cntxt_id & 7);
>> -        }
>> +        t3_stop_queue(dev, qs, q);
>> +        dev_err(&adap->pdev->dev,
>> +            "%s: Tx ring %u full while queue awake!\n",
>> +            dev->name, q->cntxt_id & 7);
>>          spin_unlock(&q->lock);
>>          return NETDEV_TX_BUSY;
>>      }
>>  
>>      q->in_use += ndesc;
>> -    if (unlikely(credits - ndesc < q->stop_thres)) {
>> -        q->stops++;
>> -        netif_stop_queue(dev);
>> -        set_bit(TXQ_ETH, &qs->txq_stopped);
>> -#if !USE_GTS
>> -        if (should_restart_tx(q) &&
>> -            test_and_clear_bit(TXQ_ETH, &qs->txq_stopped)) {
>> -            q->restarts++;
>> -            netif_wake_queue(dev);
>> -        }
>> -#endif
>> -    }
>> +    if (unlikely(credits - ndesc < q->stop_thres))
>> +        if (USE_GTS || !should_restart_tx(q))
>> +            t3_stop_queue(dev, qs, q);
>>  
>>      gen = q->gen;
>>      q->unacked += ndesc;
>>   
> Hi Jeff,
> 
> I thought I had NAK'ed the patch modifying sge.c from Krishna Kumar.
> Looking back at my answer at the time, I was obviously unclear.
> Can you please revert the drivers/net/cxgb3sge.c change ?

Explain why, so I can include it in the changelog please...

	Jeff




