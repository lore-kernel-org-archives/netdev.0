From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 03 Apr 2014 23:38:40 +0800
Message-ID: <533D8080.6030909@linaro.org>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel> <063D6719AE5E284EB5DD2968C1650D6D0F6EE729@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Arnd Bergmann' <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:36534 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbaDCPiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:38:46 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so2013298pbc.6
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 08:38:45 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EE729@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David

On 04/02/2014 06:04 PM, David Laight wrote:
> From: Arnd Bergmann
>> On Tuesday 01 April 2014 21:27:12 Zhangfei Gao wrote:
>>> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>
>> While it looks like there are no serious functionality bugs left, this
>> function is rather inefficient, as has been pointed out before:
>>
>>> +{
>>> +       struct hip04_priv *priv = netdev_priv(ndev);
>>> +       struct net_device_stats *stats = &ndev->stats;
>>> +       unsigned int tx_head = priv->tx_head;
>>> +       struct tx_desc *desc = &priv->tx_desc[tx_head];
>>> +       dma_addr_t phys;
>>> +
>>> +       hip04_tx_reclaim(ndev, false);
>>> +       mod_timer(&priv->txtimer, jiffies + RECLAIM_PERIOD);
>>> +
>>> +       if (priv->tx_count >= TX_DESC_NUM) {
>>> +               netif_stop_queue(ndev);
>>> +               return NETDEV_TX_BUSY;
>>> +       }
>>
>> This is where you have two problems:
>>
>> - if the descriptor ring is full, you wait for RECLAIM_PERIOD,
>>    which is far too long at 500ms, because during that time you
>>    are not able to add further data to the stopped queue.
>
> Best to have some idea how long it will take for the ring to empty.
> IIRC you need a count of the bytes in the tx ring anyway.
> There isn't much point waking up until most of the queued
> transmits have had time to complete.

In fact, there is no good way to check when the packed is send out 
except check desc becomes 0, even this is not accurate in 100M mode.
The hardware guy just suggest we can assume the data is send out when 
send to the dma.
Though it can work with iperf, still heistate to use it.

>
>> - As David Laight pointed out earlier, you must also ensure that
>>    you don't have too much /data/ pending in the descriptor ring
>>    when you stop the queue. For a 10mbit connection, you have already
>>    tested (as we discussed on IRC) that 64 descriptors with 1500 byte
>>    frames gives you a 68ms round-trip ping time, which is too much.
>>    Conversely, on 1gbit, having only 64 descriptors actually seems
>>    a little low, and you may be able to get better throughput if
>>    you extend the ring to e.g. 512 descriptors.
>
> The descriptor count matters most for small packets.
> There are workloads (I've got one) that can send 1000s of small packets/sec
> on a single TCP connection (there will be receive traffic).
>
>>> +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>>> +       if (dma_mapping_error(&ndev->dev, phys)) {
>>> +               dev_kfree_skb(skb);
>>> +               return NETDEV_TX_OK;
>>> +       }
>>> +
>>> +       priv->tx_skb[tx_head] = skb;
>>> +       priv->tx_phys[tx_head] = phys;
>>> +       desc->send_addr = cpu_to_be32(phys);
>>> +       desc->send_size = cpu_to_be16(skb->len);
>>> +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
>>> +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
>>> +       desc->wb_addr = cpu_to_be32(phys);
>>
>> One detail: since you don't have cache-coherent DMA, "desc" will
>> reside in uncached memory, so you try to minimize the number of accesses.
>> It's probably faster if you build the descriptor on the stack and
>> then atomically copy it over, rather than assigning each member at
>> a time.
>
> I'm not sure, the writes to uncached memory will probably be
> asynchronous, but you may avoid a stall by separating the
> cycles in time.
> What you need to avoid is reads from uncached memory.
> It may well beneficial for the tx reclaim code to first
> check whether all the transmits have completed (likely)
> instead of testing each descriptor in turn.

It may not needed since no better way to check whether all packets and 
send out.

For 100M interface, the perf is 94M, almost no space to upgrade.
For 1G interface, it is rather fast, when check with iperf by default.
There is only 1 buffer used, so every time free only 1 buffer.

However, just find the throughput improves a lot when increasing thread.
iperf -P 1, throughput: 420M
iperf -P 2, throughput: 740M
iperf -P 4, throughput: 930M


>
>> The same would be true for the rx descriptors.
>
> Actually it is reasonably feasible to put the rx descriptors
> in cacheable memory and to flush the cache lines after adding
> new entries.
> You just need to add the entries one cache line full at a time
> (and ensure that the rx processing code doesn't dirty the line).
>
> Without cache-coherent memory cached tx descriptors are much harder work.
>
> 	David
>
>
>
>
>
