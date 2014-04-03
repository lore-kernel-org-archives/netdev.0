From: Zhangfei Gao <zhangfei.gao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 3 Apr 2014 14:24:25 +0800
Message-ID: <CAMj5BkgfwE1hHpVeqH9WRitwCB30x3c4w0qw7sXT3PiOV-QcPQ@mail.gmail.com>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org>
	<9532591.5yuCbpL4pV@wuerfel>
	<063D6719AE5E284EB5DD2968C1650D6D0F6EE729@AcuExch.aculab.com>
	<4698724.S4F2PxkdOH@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org"
	<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4698724.S4F2PxkdOH@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 2, 2014 at 11:49 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Wednesday 02 April 2014 10:04:34 David Laight wrote:
>> From: Arnd Bergmann
>> > On Tuesday 01 April 2014 21:27:12 Zhangfei Gao wrote:
>> > > +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
>> > > +       if (dma_mapping_error(&ndev->dev, phys)) {
>> > > +               dev_kfree_skb(skb);
>> > > +               return NETDEV_TX_OK;
>> > > +       }
>> > > +
>> > > +       priv->tx_skb[tx_head] = skb;
>> > > +       priv->tx_phys[tx_head] = phys;
>> > > +       desc->send_addr = cpu_to_be32(phys);
>> > > +       desc->send_size = cpu_to_be16(skb->len);
>> > > +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
>> > > +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
>> > > +       desc->wb_addr = cpu_to_be32(phys);
>> >
>> > One detail: since you don't have cache-coherent DMA, "desc" will
>> > reside in uncached memory, so you try to minimize the number of accesses.
>> > It's probably faster if you build the descriptor on the stack and
>> > then atomically copy it over, rather than assigning each member at
>> > a time.
>>
>> I'm not sure, the writes to uncached memory will probably be
>> asynchronous, but you may avoid a stall by separating the
>> cycles in time.
>
> Right.
>
>> What you need to avoid is reads from uncached memory.
>> It may well beneficial for the tx reclaim code to first
>> check whether all the transmits have completed (likely)
>> instead of testing each descriptor in turn.
>
> Good point, reading from noncached memory is actually the
> part that matters. For slow networks (e.g. 10mbit), checking if
> all of the descriptors have finished is not quite as likely to succeed
> as for fast (gbit), especially if the timeout is set to expire
> before all descriptors have completed.
>
> If it makes a lot of difference to performance, one could use
> a binary search over the outstanding descriptors rather than looking
> just at the last one.
>

I am afraid, there may no simple way to check whether all transmits completed.

Still want enable the cache coherent feature first.
Then two benefits:
1. dma buffer cacheable.
2. descriptor can directly use cacheable memory, so the performance
concern here may be solved accordingly.

So how about using this version as first version, while tuning the
performance in the next step.
Currently, the gbit interface can reach 420M bits/s in iperf, and the
100M interface can reach 94M bits/s.

Thanks
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
