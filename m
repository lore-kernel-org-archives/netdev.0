From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 9 Sep 2010 22:38:06 +0900
Message-ID: <002501cb5024$5a5e3800$66f8800a@maildom.okisemi.com>
References: <4C81019E.1010808@dsn.okisemi.com> <4C8123D6.8020001@suse.cz> <003901cb4f5d$bf977c80$66f8800a@maildom.okisemi.com> <4C879AAB.6000905@suse.cz>
Cc: "Randy Dunlap" <randy.dunlap@oracle.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"ML netdev" <netdev@vger.kernel.org>,
	"MeeGo" <meego-dev@meego.com>, "Maxime Bizon" <mbizon@freebox.fr>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"John Linn" <john.linn@xilinx.com>,
	"Joe Perches" <joe@perches.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "Jiri Slaby" <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:24655 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752390Ab0IINi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:38:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri

Thank you for your answer

On: Wed, 08 Sep 2010 16:16:11 +0200,: Jiri Slaby wrote:
> >>> + u32 TX_DMA_ST;
> >>> + u32 reserve7[2];
> >>> + u32 WOL_ST;
> >>> + u32 WOL_CTRL;
> >>> + u32 WOL_ADDR_MASK;
> >>> +};
> >>
> >> Shouldn't that be packed? As it is full of u32, probably not, but
> >> consider this comment when thinking about all structures you have here.
> >
> > [masa]
> > packed?
> > I am sorry, I can not understand.
> > Please let me know details.
>
> attribute((packed)). It ensures that compiler won't add gaps in there
> for better alignment. As I wrote I'm not sure whether you need them at
> all, since you use u32 here which are aligned naturally. But bear this
> in mind while defining the rest of your structures which are transferred
> from/to the HW.

[masa]
I understood.
"__attribute ((packed))" is added

    u32 WOL_ST;
    u32 WOL_CTRL;
    u32 WOL_ADDR_MASK;
} __attribute ((packed));


> >>> + rxdr->count = max(ring->rx_pending, (u32) PCH_GBE_MIN_RXD);
> >>> + rxdr->count = min(rxdr->count, (u32) PCH_GBE_MAX_RXD);
> >>
> >> clamp()
> >> And why you need the cast?
> >
> > [masa]
> > Since warning appears at the time of a make.
>
> OK, then you have type error which you should fix instead. Perhaps
> define the constnts with U suffix?

[masa]
I will modify like Stephen's comment
rxdr->count = clamp_val(ring->rx_pending, PCH_GBE_MIN_RXD, PCH_GBE_MAX_RXD);


> >>> + /* wait busy */
> >>> + while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
> >>> + cpu_relax();
> >>
> >> There should be probably some time limit. Nobody trusts hardware.
> >
> > [masa]
> > How should it modify?
>
> Similarly to other busy waiting code you have in other places. Some
> udelay with a loop bound.

[masa]
I understood.
This will be modified.


> >>> + if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
> >>> + pr_err("Transfer length Error: skb len: %d > max: %d\n",
> >>> +        skb->len, adapter->hw.mac.max_frame_size);
> >>> + dev_kfree_skb_any(skb);
> >>> + adapter->stats.tx_length_errors++;
> >>> + return NETDEV_TX_BUSY;
> >>
> >> Not nice. ndev layer will reuse the freed skb now.
> >
> > [masa]
> > How should it modify?
>
> Remove dev_kfree_skb_any(skb) to not free the skb so that ndev layer can
> requeue the buffer.

[masa]
"dev_kfree_skb_any(skb)" is removed.


> >>> +#ifdef CONFIG_PM
> >>> + /* Implement our own version of pci_save_state(pdev) because pci-
> >>> + * express adapters have 256-byte config spaces. */
> >>> + retval = pci_save_state(pdev);
> >>
> >> But PCIe saves all caps, why you need this?
> >
> > [masa]
> > I can not understand.
> > Please let me know details.
>
> What exactly do you need the state of pcie for? The core should do it
> fine on its own...

[masa]
Since a config space needs to be stored, pci_save_state() is used.


> >>> + if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
> >>> + && !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> >>> + ;
> >>> + } else {
> >>
> >> You should invert the logic. And use pci_ variants.
> >
> > [masa]
> > This will be modified like
> > if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
> >  || dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> >
> > What is pci_ variants?
>
> No, don't use them, they used to be pci specific intended for dma
> setting/mapping but are deprecated now which I didn't realize.

[masa]
I use "pci_set_dma_mask" and "pci_set_coherent_mask".
This will be modified like below
OK?

> >>> + mmio_start = pci_resource_start(pdev, PCH_GBE_PCI_BAR);
> >>> + mmio_len = pci_resource_len(pdev, PCH_GBE_PCI_BAR);
> >>> + adapter->hw.reg = ioremap_nocache(mmio_start, mmio_len);
> >>
> >> pci_ioremap_bar()
> >>
> >> Anyway you should not use ioread/iowrite* on an ioremapped space. It is
> >> intended for iomapped space (pci_iomap) and is slower.
> >
> > [masa]
> > This will be modified like
> > pci_iomap(pdev, PCH_GBE_PCI_BAR, 0) is used.
>
> If you don't mind one extra branching in each read/write, then OK :).
> Here you know it's MMIO space I think, so pci_ioremap_map+readl/writel
> would be more appropriate and faster. But it's your call.

[masa]
I use "pci_ioremap_bar()"

Thanks Ohtake


