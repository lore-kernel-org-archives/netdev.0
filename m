From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Fri, 21 Mar 2014 08:37:33 +0100
Message-ID: <4951263.YfedV5kHCP@wuerfel>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org> <201403201531.20416.arnd@arndb.de> <CAMj5BkgMuw-O7b7KnVgZ9gmTGDv=OhCxvAYBu+wZy=j6m8Anmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Zhangfei Gao <zhangfei.gao@gmail.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.13]:55345 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbaCUHhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 03:37:42 -0400
In-Reply-To: <CAMj5BkgMuw-O7b7KnVgZ9gmTGDv=OhCxvAYBu+wZy=j6m8Anmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 21 March 2014 13:19:07 Zhangfei Gao wrote:
> On Thu, Mar 20, 2014 at 10:31 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>
> > Yes, this looks better, but where does 'speed' come from now? I assume
> > even in SGMII mode, you should allow autonegotiation and set this correctly
> > from the PHY code. Is that what you do here?
> 
> Yes, for the SGMII, there is the auto negotiation.
> 'speed' coming from adjust_link.
> While the MII mode, I will directly set 100M at probe, since no auto
> negotiation.

Ok, good.

> >
> >> >> +static void hip04_set_xmit_desc(struct hip04_priv *priv, dma_addr_t phys)
> >> >> +{
> >> >> +     writel_relaxed(phys, priv->base + PPE_CFG_TX_PKT_BD_ADDR);
> >> >> +}
> >> >> +
> >> >> +static void hip04_set_recv_desc(struct hip04_priv *priv, dma_addr_t phys)
> >> >> +{
> >> >> +     writel_relaxed(phys, ppebase + priv->port * 4 + PPE_CFG_RX_CFF_ADDR);
> >> >> +}
> >> >> +
> >> >> +static u32 hip04_recv_cnt(struct hip04_priv *priv)
> >> >> +{
> >> >> +     return readl_relaxed(priv->base + PPE_HIS_RX_PKT_CNT);
> >> >> +}
> >> >
> >> > At the very least, the hip04_set_xmit_desc() function needs to use 'writel'
> >> > rather than 'writel_relaxed'. Otherwise data that is being sent out
> >> > can be stuck in the CPU's write buffers and you send stale data on the wire.
> >> >
> >> > For the receive path, you may or may not need to use 'readl', depending
> >> > on how DMA is serialized by this device. If you have MSI interrupts, the
> >> > interrupt message should already do the serialization, but if you have
> >> > edge or level triggered interrupts, you normally need to have one readl()
> >> > from the device register between the IRQ and the data access.
> >>
> >> Really, will update to readl/wirtel in xmit and hip04_rx_poll.
> >> I just got impression, use *_relaxed as much as possible for better performance.
> >
> > Ok. The _relaxed() versions are really meant for people that understand
> > the ordering requirements. The regular readl/writel accessors contain
> > extra barriers to make them equivalent to what x86 does.
> 
> Thanks for the knowledge.
> So generally readl/writel should be put in critical process, where we
> want the immediate result,
> like irq handler?

Strictly speaking you only need one writel after preparing an
outbound DMA buffer, and and one readl before reading an inbound
DMA buffer.

> >> >> +static int hip04_rx_poll(struct napi_struct *napi, int budget)
> >> >> +{
> >> >> +     struct hip04_priv *priv = container_of(napi,
> >> >> +                           struct hip04_priv, napi);
> >> >> +     struct net_device *ndev = priv->ndev;
> >> >> +     struct sk_buff *skb;
> >> >> +     struct rx_desc *desc;
> >> >> +     unsigned char *buf;
> >> >> +     int rx = 0;
> >> >> +     unsigned int cnt = hip04_recv_cnt(priv);
> >> >> +     unsigned int len, tmp[16];
> >> >> +
> >> >> +     while (cnt) {
> >> >> +             buf = priv->rx_buf[priv->rx_head];
> >> >> +             skb = build_skb(buf, priv->rx_buf_size);
> >> >> +             if (unlikely(!skb))
> >> >> +                     net_dbg_ratelimited("build_skb failed\n");
> >> >> +             dma_map_single(&ndev->dev, skb->data,
> >> >> +                     RX_BUF_SIZE, DMA_FROM_DEVICE);
> >> >> +             memcpy(tmp, skb->data, 64);
> >> >> +             endian_change((void *)tmp, 64);
> >> >> +             desc = (struct rx_desc *)tmp;
> >> >> +             len = desc->pkt_len;
> >> >
> >> > The dma_map_single() seems misplaced here, for all I can tell, the
> >> > data has already been transferred. Maybe you mean dma_unmap_single?
> >> >
> >> > I don't see why you copy 64 bytes out of the buffer using endian_change,
> >> > rather than just looking at the first word, which seems to have the
> >> > only value you are interested in.
> >> Russell suggested using be16_to_cpu etc to replace memcpy.
> >
> > Right, but doesn't it have to be be32_to_cpu?
> 
> The reason I got frustrated before is there are u16 and u32 in the structure.
> While Russell reminded changing the structure layout.
> So switching u16 & be16_to_cpu, and using be32_to_cpu for u32 works out.

Ok. The endian_change() function did multiple 32-bit swaps, so I assumed
that was what the design required. Swapping each field individually with
its actual length is more sensible though, so if that works, it is probably
the correct solution and the endian_change() function was in fact wrong.

> >> >> +static int hip04_alloc_ring(struct net_device *ndev, struct device *d)
> >> >> +{
> >> >> +     struct hip04_priv *priv = netdev_priv(ndev);
> >> >> +     int i;
> >> >> +
> >> >> +     priv->rx_buf_size = RX_BUF_SIZE +
> >> >> +                         SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> >> >> +
> >> >> +     priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
> >> >> +                             SKB_DATA_ALIGN(sizeof(struct tx_desc)), 0);
> >> >> +     if (!priv->desc_pool)
> >> >> +             return -ENOMEM;
> >> >> +
> >> >> +     for (i = 0; i < TX_DESC_NUM; i++) {
> >> >> +             priv->td_ring[i] = dma_pool_alloc(priv->desc_pool,
> >> >> +                                     GFP_ATOMIC, &priv->td_phys[i]);
> >> >> +             if (!priv->td_ring[i])
> >> >> +                     return -ENOMEM;
> >> >> +     }
> >> >
> >> > Why do you create a dma pool here, when you do all the allocations upfront?
> >> >
> >> > It looks to me like you could simply turn the td_ring array of pointers
> >> > to tx descriptors into a an array of tx descriptors (no pointers) and allocate
> >> > that one using dma_alloc_coherent.
> >>
> >> dma pool used here mainly because of alignment,
> >> the desc has requirement of SKB_DATA_ALIGN,
> >> so use the simplest way
> >>         priv->desc_pool = dma_pool_create(DRV_NAME, d, sizeof(struct tx_desc),
> >>                                 SKB_DATA_ALIGN(sizeof(struct tx_desc)), 0);
> >
> > dma_alloc_coherent() will actually give you PAGE_SIZE alignment, so that's
> > still easier.
> However since the alignment requirement, it can not simply use desc[i]
> to get each desc.
> desc = dma_alloc_coherent(d, size, &phys, GFP_KERNEL);
> desc[i] is not what we want.
> So still prefer using dma_pool_alloc here.

Ah, I see what you mean: struct tx_desc is actually smaller than the
required alignment. You can fix that by marking the structure
"____cacheline_aligned". 

> >>                         };
> >>
> >>                         eth1_port: port@0 {
> >>                                 reg = <0>;
> >>                         };
> >>
> >>                         eth2_port: port@8 {
> >>                                 reg = <8>;
> >>                         };
> >>                 };
> >>                 fe: ethernet@28b0000 {
> >>                         compatible = "hisilicon,hip04-mac";
> >>                         reg = <0x28b0000 0x10000>;
> >>                         interrupts = <0 413 4>;
> >>                         phy-mode = "mii";
> >>                         port-handle = <&eth0_port>;
> >>                 };
> >> And the port info can be found from port-handle
> >> n = of_parse_phandle(node, "port-handle", 0);
> >> ret = of_property_read_u32(n, "reg", &priv->port);
> >>
> >> The id is the controller start channel in ppe, either use alias or
> >> another property in the port.
> >
> > Yes, this seems fine as well, as long as you are sure that the ppe
> > device is only used by hip04 ethernet devices, I think it
> > would get messy if your hardware shares them with other units.
> 
> Checked syscon_regmap, looks it specially useful for the accessing
> common registers.
> Here ppe is ethernet "accelerator", used specifically in this driver.
> Since here only have several places access the ppebase, it maybe
> simpler access directly.

Right. I was just bringing it up because some similar designs
(e.g. TI keystone or APM x-gene) share an accelarator between
multiple users, not just the ethernet devices, and in that case
you might need a more general solution.

	Arnd
