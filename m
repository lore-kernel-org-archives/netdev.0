From: zhangfei <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 02 Apr 2014 17:51:54 +0800
Message-ID: <533BDDBA.1060800@linaro.org>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9532591.5yuCbpL4pV@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Arnd

On 04/02/2014 05:21 PM, Arnd Bergmann wrote:
> On Tuesday 01 April 2014 21:27:12 Zhangfei Gao wrote:
>> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>
> While it looks like there are no serious functionality bugs left, this
> function is rather inefficient, as has been pointed out before:

Yes, still need more performance tuning in the next step.
We need to enable the hardware feature of cache flush, under help of 
arm-smmu, as a result dma_map_single etc can be removed.

>
>> +{
>> +       struct hip04_priv *priv = netdev_priv(ndev);
>> +       struct net_device_stats *stats = &ndev->stats;
>> +       unsigned int tx_head = priv->tx_head;
>> +       struct tx_desc *desc = &priv->tx_desc[tx_head];
>> +       dma_addr_t phys;
>> +
>> +       hip04_tx_reclaim(ndev, false);
>> +       mod_timer(&priv->txtimer, jiffies + RECLAIM_PERIOD);
>> +
>> +       if (priv->tx_count >= TX_DESC_NUM) {
>> +               netif_stop_queue(ndev);
>> +               return NETDEV_TX_BUSY;
>> +       }
>
> This is where you have two problems:
>
> - if the descriptor ring is full, you wait for RECLAIM_PERIOD,
>    which is far too long at 500ms, because during that time you
>    are not able to add further data to the stopped queue.

Understand
The idea here is not using the timer as much as possible.
As experiment shows, only xmit reclaim buffers, the best throughput can 
be achieved.

>
> - As David Laight pointed out earlier, you must also ensure that
>    you don't have too much /data/ pending in the descriptor ring
>    when you stop the queue. For a 10mbit connection, you have already
>    tested (as we discussed on IRC) that 64 descriptors with 1500 byte
>    frames gives you a 68ms round-trip ping time, which is too much.

When iperf & ping running together and only ping, it is 0.7 ms.

>    Conversely, on 1gbit, having only 64 descriptors actually seems
>    a little low, and you may be able to get better throughput if
>    you extend the ring to e.g. 512 descriptors.

OK, Will check throughput of upgrade xmit descriptors.
But is it said not using too much descripors for xmit since no xmit 
interrupt?

>
>> +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>> +       if (dma_mapping_error(&ndev->dev, phys)) {
>> +               dev_kfree_skb(skb);
>> +               return NETDEV_TX_OK;
>> +       }
>> +
>> +       priv->tx_skb[tx_head] = skb;
>> +       priv->tx_phys[tx_head] = phys;
>> +       desc->send_addr = cpu_to_be32(phys);
>> +       desc->send_size = cpu_to_be16(skb->len);
>> +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
>> +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
>> +       desc->wb_addr = cpu_to_be32(phys);
>
> One detail: since you don't have cache-coherent DMA, "desc" will
> reside in uncached memory, so you try to minimize the number of accesses.
> It's probably faster if you build the descriptor on the stack and
> then atomically copy it over, rather than assigning each member at
> a time.

I am sorry, not quite understand, could you clarify more?
The phys and size etc of skb->data is changing, so need to assign.
If member contents keep constant, it can be set when initializing.

>
> The same would be true for the rx descriptors.
>

Thanks
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
