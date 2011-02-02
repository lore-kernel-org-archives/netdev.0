From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v5] Gemini: Gigabit ethernet driver
Date: Wed, 2 Feb 2011 18:18:14 +0100
Message-ID: <20110202171814.GA10458@rere.qmqm.pl>
References: <20101230083905.5A8EB13909@rere.qmqm.pl> <20110126232419.4794513909@rere.qmqm.pl> <20110128.143159.48506419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ulli.kroll@googlemail.com, gemini-board-dev@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel.bfrz@manchmal.in-ulm.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45784 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab1BBRSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 12:18:16 -0500
Content-Disposition: inline
In-Reply-To: <20110128.143159.48506419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 28, 2011 at 02:31:59PM -0800, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Thu, 27 Jan 2011 00:24:19 +0100 (CET)
> > +#define NETIF_TSO_FEATURES	\
> > +	(NETIF_F_TSO|NETIF_F_TSO_ECN|NETIF_F_TSO6)
> > +#define GMAC_TX_OFFLOAD_FEATURES	\
> > +	(NETIF_TSO_FEATURES|NETIF_F_ALL_CSUM)
>=20
> Please, when definiting macros locally for your driver, do not name
> them with prefixes that match those defined generically by the
> network stack.  Otherwise it is confusing for people reading the
> driver.
>=20
> One should be able to see "NETIF_XXX" somewhere and expect to find
> it's definition somewhere in the generic networking driver interfaces=
,
> not in the driver itself.

Sure. Renamed to GMAC_TSO_FEATURES for next versions.

> > +static struct toe_private *netdev_to_toe(struct net_device *dev)
> > +{
> > +	return dev->ml_priv;
> > +}
>=20
> There is no reason to use ->ml_priv just to have a common backpointer
> to a structure shared between multiple interfaces.
>=20
> Simply add a "struct toe_private *" to your "struct gmac_private" and
> stick it there.
>=20
> The cost of the dereference is identical in both cases, so there is n=
ot
> even a performance incentive to use ->ml_priv.

What is the correct use of ml_priv? I saw that a few drivers use it for
same or similar purpose (pointer to state shared between network device=
s).

> > +static void __iomem *gmac_ctl_reg(struct net_device *dev, unsigned=
 int reg)
> > +{
> > +	return (void __iomem *)dev->base_addr + reg;
> > +}
> Please do not abuse dev->base_addr in this way, simply define another
> "void __iomem *" pointer in your gmac_private and use that.

The field is unused for memory-mapped devices. Still, that's why I wrap
this kind of things in one-liners - I can easily change it.

> > +	page =3D pfn_to_page(dma_to_pfn(toe->dev, rx->word2.buf_adr));
> Please do not use non-portable routines such as dma_to_pfn() unless i=
t
> is absolutely unavoidable.  Instead, use schemes for page struct
> lookup like those used by drivers such as drivers/net/niu.c, which us=
es
> a hash table to find pages based upon DMA address.
>=20
> I'd like you to be able to enable this driver on as many platforms as
> possible, not just ARM, so we can be build testing your driver as we
> make changes to various network driver APIs, and we can't do that if
> you put ARM specific stuff in here.

To make it build I need to add a bunch of #ifdefs to compile out other
platform-specific code. I see no reason to make it inefficient on the
only platform it's supposed to work. I have isolated the code to anothe=
r
one-liner functions in case this happens to be bigger problem.

If I make it buildable (NOT working) on other archs is it enough I add
Kconfig dependency on (ARCH_GEMINI || BROKEN) to allow it to be
build-tested there?

> > +		dev_err(&dev->dev, "Unsupported MII interface\n");
> Please use "netdev_err(dev, ..."
> Please use netdev_*() when possible elsewhere in this driver too.

=46ixed. This is called before the netdev is registered, though.

> > +	writel(
> > +		(GMAC0_SWTQ00_EOF_INT_BIT|GMAC0_SWTQ00_FIN_INT_BIT)
> > +			<< (6 * dev->dev_id + txq_num),
> > +		toe_reg(toe, GLOBAL_INTERRUPT_STATUS_0_REG));
> Please format this more reasonably, this looks awful.

=46ixed.

> > +	txq->ring[w].word0.bits32 =3D skb_headlen(skb);
> > +	txq->ring[w].word1.bits32 =3D skb->len | tss_flags;
> > +	txq->ring[w].word2.bits32 =3D mapping;
> > +	txq->ring[w].word3.bits32 =3D tss_pkt_len(skb) | SOF_BIT;
> What is the endinness of the RX and TX descriptors of this chipset?
> Please use "__be32", "__le32", and the endianness conversion interfac=
es
> as needed.

StorLink people who wrote original spaghetti-code probably didn't know
either.  The SoC has beed used only in little-endian mode so it isn't e=
ven
possible for me to test how would it work in big-endian mode.

Best Regards,
Micha=B3 Miros=B3aw

