From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 2 Apr 2014 10:04:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EE729@AcuExch.aculab.com>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org>
 <1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org>
 <9532591.5yuCbpL4pV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org"
	<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'Arnd Bergmann' <arnd-r2nGTMty4D4@public.gmane.org>,
	Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9532591.5yuCbpL4pV@wuerfel>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> On Tuesday 01 April 2014 21:27:12 Zhangfei Gao wrote:
> > +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> 
> While it looks like there are no serious functionality bugs left, this
> function is rather inefficient, as has been pointed out before:
> 
> > +{
> > +       struct hip04_priv *priv = netdev_priv(ndev);
> > +       struct net_device_stats *stats = &ndev->stats;
> > +       unsigned int tx_head = priv->tx_head;
> > +       struct tx_desc *desc = &priv->tx_desc[tx_head];
> > +       dma_addr_t phys;
> > +
> > +       hip04_tx_reclaim(ndev, false);
> > +       mod_timer(&priv->txtimer, jiffies + RECLAIM_PERIOD);
> > +
> > +       if (priv->tx_count >= TX_DESC_NUM) {
> > +               netif_stop_queue(ndev);
> > +               return NETDEV_TX_BUSY;
> > +       }
> 
> This is where you have two problems:
> 
> - if the descriptor ring is full, you wait for RECLAIM_PERIOD,
>   which is far too long at 500ms, because during that time you
>   are not able to add further data to the stopped queue.

Best to have some idea how long it will take for the ring to empty.
IIRC you need a count of the bytes in the tx ring anyway.
There isn't much point waking up until most of the queued
transmits have had time to complete.

> - As David Laight pointed out earlier, you must also ensure that
>   you don't have too much /data/ pending in the descriptor ring
>   when you stop the queue. For a 10mbit connection, you have already
>   tested (as we discussed on IRC) that 64 descriptors with 1500 byte
>   frames gives you a 68ms round-trip ping time, which is too much.
>   Conversely, on 1gbit, having only 64 descriptors actually seems
>   a little low, and you may be able to get better throughput if
>   you extend the ring to e.g. 512 descriptors.

The descriptor count matters most for small packets.
There are workloads (I've got one) that can send 1000s of small packets/sec
on a single TCP connection (there will be receive traffic).

> > +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> > +       if (dma_mapping_error(&ndev->dev, phys)) {
> > +               dev_kfree_skb(skb);
> > +               return NETDEV_TX_OK;
> > +       }
> > +
> > +       priv->tx_skb[tx_head] = skb;
> > +       priv->tx_phys[tx_head] = phys;
> > +       desc->send_addr = cpu_to_be32(phys);
> > +       desc->send_size = cpu_to_be16(skb->len);
> > +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
> > +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
> > +       desc->wb_addr = cpu_to_be32(phys);
> 
> One detail: since you don't have cache-coherent DMA, "desc" will
> reside in uncached memory, so you try to minimize the number of accesses.
> It's probably faster if you build the descriptor on the stack and
> then atomically copy it over, rather than assigning each member at
> a time.

I'm not sure, the writes to uncached memory will probably be
asynchronous, but you may avoid a stall by separating the
cycles in time.
What you need to avoid is reads from uncached memory.
It may well beneficial for the tx reclaim code to first
check whether all the transmits have completed (likely)
instead of testing each descriptor in turn.

> The same would be true for the rx descriptors.

Actually it is reasonably feasible to put the rx descriptors
in cacheable memory and to flush the cache lines after adding
new entries.
You just need to add the entries one cache line full at a time
(and ensure that the rx processing code doesn't dirty the line).

Without cache-coherent memory cached tx descriptors are much harder work.

	David





--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
