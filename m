From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] Gemini: Gigabit ethernet driver
Date: Fri, 28 Jan 2011 14:31:59 -0800 (PST)
Message-ID: <20110128.143159.48506419.davem@davemloft.net>
References: <20101230083905.5A8EB13909@rere.qmqm.pl>
	<20110126232419.4794513909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ulli.kroll@googlemail.com, gemini-board-dev@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel.bfrz@manchmal.in-ulm.de
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44233
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751702Ab1A1WbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:31:24 -0500
In-Reply-To: <20110126232419.4794513909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 27 Jan 2011 00:24:19 +0100 (CET)

> +#define NETIF_TSO_FEATURES	\
> +	(NETIF_F_TSO|NETIF_F_TSO_ECN|NETIF_F_TSO6)
> +#define GMAC_TX_OFFLOAD_FEATURES	\
> +	(NETIF_TSO_FEATURES|NETIF_F_ALL_CSUM)

Please, when definiting macros locally for your driver, do not name
them with prefixes that match those defined generically by the
network stack.  Otherwise it is confusing for people reading the
driver.

One should be able to see "NETIF_XXX" somewhere and expect to find
it's definition somewhere in the generic networking driver interfaces,
not in the driver itself.

> +static struct toe_private *netdev_to_toe(struct net_device *dev)
> +{
> +	return dev->ml_priv;
> +}

There is no reason to use ->ml_priv just to have a common backpointer
to a structure shared between multiple interfaces.

Simply add a "struct toe_private *" to your "struct gmac_private" and
stick it there.

The cost of the dereference is identical in both cases, so there is not
even a performance incentive to use ->ml_priv.


> +static void __iomem *gmac_ctl_reg(struct net_device *dev, unsigned i=
nt reg)
> +{
> +	return (void __iomem *)dev->base_addr + reg;
> +}

Please do not abuse dev->base_addr in this way, simply define another
"void __iomem *" pointer in your gmac_private and use that.

> +	page =3D pfn_to_page(dma_to_pfn(toe->dev, rx->word2.buf_adr));

Please do not use non-portable routines such as dma_to_pfn() unless it
is absolutely unavoidable.  Instead, use schemes for page struct
lookup like those used by drivers such as drivers/net/niu.c, which uses
a hash table to find pages based upon DMA address.

I'd like you to be able to enable this driver on as many platforms as
possible, not just ARM, so we can be build testing your driver as we
make changes to various network driver APIs, and we can't do that if
you put ARM specific stuff in here.

> +		dev_err(&dev->dev, "Unsupported MII interface\n");

Please use "netdev_err(dev, ..."

Please use netdev_*() when possible elsewhere in this driver too.

> +	writel(
> +		(GMAC0_SWTQ00_EOF_INT_BIT|GMAC0_SWTQ00_FIN_INT_BIT)
> +			<< (6 * dev->dev_id + txq_num),
> +		toe_reg(toe, GLOBAL_INTERRUPT_STATUS_0_REG));

Please format this more reasonably, this looks awful.

> +	txq->ring[w].word0.bits32 =3D skb_headlen(skb);
> +	txq->ring[w].word1.bits32 =3D skb->len | tss_flags;
> +	txq->ring[w].word2.bits32 =3D mapping;
> +	txq->ring[w].word3.bits32 =3D tss_pkt_len(skb) | SOF_BIT;

What is the endinness of the RX and TX descriptors of this chipset?
Please use "__be32", "__le32", and the endianness conversion interfaces
as needed.
