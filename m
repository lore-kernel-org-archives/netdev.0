From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet driver
Date: Thu, 21 Sep 2017 21:27:47 +0900
Message-ID: <20170921212746.9119.4A936039@socionext.com>
References: <df4ec8b2-67cf-5dee-2600-88cffd1bcd11@gmail.com> <20170911155555.6719.4A936039@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Andrew Lunn" <andrew@lunn.ch>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170911155555.6719.4A936039@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Sep 2017 15:55:56 +0900 <hayashi.kunihiko@socionext.com> wrote:

> > > +static int ave_set_rxdesc(struct net_device *ndev, int entry)
> > > +{
> > > +	struct ave_private *priv = netdev_priv(ndev);
> > > +	struct sk_buff *skb;
> > > +	unsigned long align;
> > > +	dma_addr_t paddr;
> > > +	void *buffptr;
> > > +	int ret = 0;
> > > +
> > > +	skb = priv->rx.desc[entry].skbs;
> > > +	if (!skb) {
> > > +		skb = netdev_alloc_skb_ip_align(ndev,
> > > +						AVE_MAX_ETHFRAME + NET_SKB_PAD);
> > > +		if (!skb) {
> > > +			netdev_err(ndev, "can't allocate skb for Rx\n");
> > > +			return -ENOMEM;
> > > +		}
> > > +	}
> > > +
> > > +	/* set disable to cmdsts */
> > > +	ave_wdesc(ndev, AVE_DESCID_RX, entry, 0, AVE_STS_INTR | AVE_STS_OWN);
> > > +
> > > +	/* align skb data for cache size */
> > > +	align = (unsigned long)skb_tail_pointer(skb) & (NET_SKB_PAD - 1);
> > > +	align = NET_SKB_PAD - align;
> > > +	skb_reserve(skb, align);
> > > +	buffptr = (void *)skb_tail_pointer(skb);
> > 
> > Are you positive you need this? Because by default, the networking stack
> > will align to the maximum between your L1 cache line size and 64 bytes,
> > which should be a pretty good alignment guarantee.
> 
> Now if L1 cache line size is 128,
> the skb buffer is also aligned to 128, isn't it?
> So this code doesn't make sense.

Although the above cache-alignment operation isn't necessary,
we should add the address adjustment because of the restriction of the hardware
specification.

The netdev_alloc_skb_ip_align() allocates the cache-aligned buffer
and add 2 byte to skb->data by skb_reserve(skb, NET_IP_ALIGN).
Then skb->data points to "aligned address + 2 byte".

When we call dma_map_single() with skb->data, it might return the aligned address
and there might not be 2 byte space.

On the other hand, according to the hardware specification,
the Rx buffer address set to the descriptor is assumed that:
 - the Rx address is 4 byte aligned,
 - the Rx address begins with 2 byte headroom, data will be put from (buffer+2).

Therefore, to make headroom in front of returned address from ave_dma_map(),
I think that the buffer address should be adjusted like that:

    skb = netdev_alloc_skb_ip_align(ndev, AVE_MAX_ETHFRAME);

    paddr = ave_dma_map(ndev, &priv->rx.desc[entry],
		skb->data - NET_IP_ALIGN,
		AVE_MAX_ETHFRAME + NET_IP_ALIGN, DMA_FROM_DEVICE);

    ave_wdesc_addr(ndev, AVE_DESCID_RX, entry, 4, paddr);

I'll apply the code to next patch.

BTW, since the Tx buffer address doesn't have any restrictions, the adjustment
like this isn't necessary.


> > > +
> > > +	/* enable clock */
> > > +	priv->clk = devm_clk_get(dev, NULL);
> > > +	if (IS_ERR(priv->clk))
> > > +		priv->clk = NULL;
> > > +	clk_prepare_enable(priv->clk);
> > 
> > Same here with the clock, the block is clocked, so it can consume some
> > amount of power, just do the necessary HW initialization with the clock
> > enabled, then defer until ndo_open() before turning it back on.

There are a number of the functions that needs clock enabled and "block reset"
operations, like mdiobus_register(), phy_connect(), and so on.

I tried to move such functions to ndo_open() to defer clock enabled until ndo_open().
However, the driver didn't work for some reasons of hardware restriction.
I think it's hard to change this sequence.

---
Best Regards,
Kunihiko Hayashi
