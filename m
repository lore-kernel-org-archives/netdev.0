From: Daniel Silverstone <dsilvers@simtec.co.uk>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Mon, 08 Dec 2008 11:05:18 +0000
Message-ID: <1228734318.19000.84.camel@petitemort>
References: <49394379.9000501@simtec.co.uk>
	 <1228499870.3520.66.camel@achroite>
Reply-To: dsilvers@simtec.co.uk
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from batfish.pepperfish.net ([87.237.62.180]:40251 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751627AbYLHLFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 06:05:22 -0500
Received: from cpc2-asht1-0-0-cust815.manc.cable.ntl.com ([80.5.55.48] helo=[10.19.3.101])
	by flounder.pepperfish.net with esmtpsa (Exim 4.68 #1 (Debian))
	id 1L9dvT-0000HH-SH
	for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 11:05:20 +0000
In-Reply-To: <1228499870.3520.66.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-05 at 17:57 +0000, Ben Hutchings wrote:
> > Index: linux-2.6.27/drivers/net/arm/Kconfig
> netdev patches should really be based on David Miller's net-next-2.6.

Noted, I shall forward-port to that tree before issuing a new patch.

> > Index: linux-2.6.27/drivers/net/arm/ks8695net.c
> > +enum ks8695_dtype {
> > +  KS8695_DTYPE_WAN,
> > +  KS8695_DTYPE_LAN,
> > +  KS8695_DTYPE_HPNA,
> > +};
> The enumerators should be indented with tabs.

Gah, I wonder how checkpatch missed that, fixed, thanks.

> > +/**
> > + *     struct ks8695_priv - Private data for the KS8695 Ethernet
> > + *     @in_suspend: Flag to indicate if we're suspending/resuming
> > + *     @ndev: The net_device for this interface
> > + *     @dev: The device object for this interface
> Which device object - the platform device?

Assuming the struct device obtained from the struct platform_device is
the "platform device object" then yes. I've updated the comment.

> > +static inline struct ks8695_priv *
> > +ks8695_get_priv(struct net_device *ndev)
> Don't use ndev->priv, use netdev_priv(ndev).  Which makes this functi=
on
> redundant, except for the implicit pointer conversion.

Aah, I didn't know about that one, updated.

> > +static void
> > +ks8695_refill_rxbuffers(struct ks8695_priv *ksp)

> > +                       mapping =3D dma_map_single(ksp->dev, skb->d=
ata,
> > +                                                MAX_RXBUF_SIZE,
> > +                                                DMA_FROM_DEVICE);
> I take it that dma_map_single() can never fail on ARM?

No it can't. It essentially boils down to some pointer arithmetic on
this platform.

> > +                       ksp->rx_ring[buff_n].length =3D
> > +                               cpu_to_le32(MAX_RXBUF_SIZE);
>=20
> You need a wmb() in here, otherwise the descriptor might not be compl=
ete
> when the hardware sees RDES_OWN set.

Noted and added.

> > +       for (buff_n =3D 0; buff_n < MAX_TX_DESC; ++buff_n) {
> > +               if (ksp->tx_buffers[buff_n].skb &&
> > +                   !(ksp->tx_ring[buff_n].owner & cpu_to_le32(TDES=
_OWN))) {
> rmb()

Added.

> > +                       /* Free the packet from the ring */
> > +                       ksp->tx_ring[buff_n].data_ptr =3D 0;
> Clearing data_ptr seems redundant.  The TDES_OWN flag indicates wheth=
er
> the descriptor is pending and the skb pointer indicates whether a buf=
fer
> needs to be freed.

This was simply me being neat. If you feel that it is an overly
expensive thing to do then I shall elide it.

> Do you need to test all the descriptors or can you keep track of whic=
h
> to check first and then stop when you find one still pending?  Maybe =
it
> doesn't matter when you only have 8 of them...

Keeping track of which to check first seemed to make the overall code
larger, and with a small number of TX descriptors, as you say, it reall=
y
doesn't matter.

Also, as a point, I have tested shovelling as much data as I can throug=
h
this over various protocols including NFS and basic TCP with multiple
simultaneous streams and I have yet to exhaust the TX descriptor ring. =
I
think the 266MHz ARM processor simply can't stoke it fast enough.

> > +static irqreturn_t
> > +ks8695_rx_irq(int irq, void *dev_id)
> > +               if (ksp->rx_buffers[buff_n].skb &&
> > +                   !(ksp->rx_ring[buff_n].status & cpu_to_le32(RDE=
S_OWN))) {
> rmb()

Added.

> > +                       skb =3D ksp->rx_buffers[buff_n].skb;
>=20
> I think this line belongs after the following comment.
>=20
> > +                       /* Extract the sk_buff from the ring */
> > +                       ksp->rx_buffers[buff_n].skb =3D NULL;
> > +                       ksp->rx_ring[buff_n].data_ptr =3D 0;

I've shifted the comment and reworded it slightly so that the first lik=
e
is marked 'retrieve the sk_buff' and the latter lines 'clear it from th=
e
ring' which I believe better describes the situation.


> > +               buff_n =3D (buff_n + 1) % MAX_RX_DESC;
> That's another expensive division.

I was expecting the compiler to go "aaha! mod <powerof2> =3D> bitwise
mask".

However, it does indeed seem to not be the case. I have reworked these
into & MAX_RX_DESC_MASK etc.

> > +static void
> > +ks8695_reset(struct ks8695_priv *ksp)
> Is there any reason this timeout should be tied to the TX watchdog
> timeout?

It was a convenient timeout. Basically I wanted something which would
allow me to time-out the reset of the chip, but I didn't feel it
worthwhile to add another module parameter for it, and I didn't want to
pluck a number out of the air per-se. If you feel it deserves its own
separate timeout then I will add one.

> > +static int
> > +ks8695_init_net(struct ks8695_priv *ksp)

> The RX and TX IRQ handlers need to be released in case the TX or link
> IRQ setup fails.

The only time that this might fail, I.E. initial device open, we check
the return value of ks8695_init_net and call ks86985_shutdown if needed
which will release the IRQs.

It seemed daft to replicate the cleanup code in two places. If however
that is the accepted style then I shall add the cleanups to
ks8695_init_net() -- Is my method acceptable or should I change?

> > +static int
> > +ks8695_get_settings(struct net_device *ndev, struct ethtool_cmd *c=
md)
> > +{
> > +       cmd->advertising =3D ADVERTISED_TP | ADVERTISED_MII;
> > +       cmd->port =3D PORT_MII;
> I think the TP and MII flags should be dependent on ksp->dtype.

Certainly until I can decode this switch datasheet I agree. Changed.

> > +       /* Port specific extras */
> > +       switch (ksp->dtype) {
> > +       case KS8695_DTYPE_HPNA:
> > +               cmd->phy_address =3D 0;
> > +               /* not supported for HPNA */
> > +               cmd->autoneg =3D AUTONEG_DISABLE;
> > +
> > +               /* BUG: Erm, dtype hpna implies no phy regs */
> > +               /*
> > +               ctrl =3D readl(KS8695_MISC_VA + KS8695_HMC);
> > +               cmd->speed =3D (ctrl & HMC_HSS) ? SPEED_100 : SPEED=
_10;
> > +               cmd->duplex =3D (ctrl & HMC_HDS) ? DUPLEX_FULL : DU=
PLEX_HALF;
> > +               */
> > +               break;
> [...]
> > +       case KS8695_DTYPE_LAN:
> > +               /* TODO: Implement this for the switch ports */
> > +               break;
> > +       }
> You'd better implement these or return -EOPNOTSUPP.  Similarly in
> ks8695_set_settings() and ks8695_nwayreset().

Unfortunately I currently lack any hardware with HPNA on it, and the
only reference for implementing the LAN switch stuff is an immensely
confusing and likely-to-be-incorrect datasheet from Micrel which I have
yet to successfully decode.

=46or now, all those functions will return -EOPNOTSUPP, thanks for the
pointer.

> > + *     TODO: Implement this
> Yes, or return -EOPNOTSUPP.

Until I can decode this datasheet, it's -EOPNOTSUPP :-(

> > +static void
> > +ks8695_timeout(struct net_device *ndev)
> It looks like this might lose multicast settings.

Yep, when I wrote this routine, I hadn't gotten around to the multicast
stuff, and I forgot to go back and correct it. I'll do so now.

> > +static int
> > +ks8695_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> > +{
> > +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> > +       int buff_n;
> > +
> > +       spin_lock_irq(&ksp->txq_lock);
> > +
> > +       if (ksp->tx_ring_used =3D=3D MAX_TX_DESC) {
> > +               /* Somehow we got entered when we have no room */
> > +               spin_unlock_irq(&ksp->txq_lock);
> > +               return -ENOSPC;
> You must return NETDEV_TX_OK or =EF=BB=BFNETDEV_TX_BUSY, not 0 or a n=
egative
> error code.

Aha, thanks.

> > +       buff_n =3D ksp->tx_ring_next_slot;
> > +       ksp->tx_ring_next_slot =3D (buff_n + 1) % MAX_TX_DESC;
>=20
> That's an expensive division, which could be avoided by either (1)
> declaring buff_n unsigned or (2) explicitly masking.

Using masking as elsewhere you noted this.

> > +       if (ksp->tx_buffers[buff_n].skb) {
> > +               /* This slot is used, try later */
> > +               spin_unlock_irq(&ksp->txq_lock);
> > +               return -EAGAIN;
> Since you already tested tx_ring_used, wouldn't this indicate a bug?

Yep, this was old code before I kept a track in tx_ring_used. Changed
to:

BUG_ON(ksp->tx_buffers[buff_n].skb);

> > +       ksp->tx_ring[buff_n].status =3D
> > +               cpu_to_le32(TDES_IC | TDES_FS | TDES_LS |
> > +                           (skb->len & TDES_TBS));
>=20
> wmb()

Added

> > +static int __devinit
> > +ks8695_probe(struct platform_device *pdev)
> > +       /* Tell the net_device all about us */
> > +       ndev->base_addr =3D (unsigned long)ksp->io_regs;
> > +       ndev->irq       =3D ksp->rx_irq;
> Don't bother setting base_addr and irq; they are for ancient ISA crap=
=2E

Removed.

> > +       ndev->open               =3D &ks8695_open;
> > +       ndev->stop               =3D &ks8695_stop;
> > +       ndev->hard_start_xmit    =3D &ks8695_start_xmit;
> > +       ndev->tx_timeout         =3D &ks8695_timeout;
> > +       ndev->set_multicast_list =3D &ks8695_set_multicast;
> > +       ndev->watchdog_timeo     =3D msecs_to_jiffies(watchdog);
> > +       ndev->ethtool_ops        =3D &ks8695_ethtool_ops;
> > +       ndev->set_mac_address    =3D &ks8695_set_mac;
> You should use net_device_ops now.

I shall do that as I bring it up to net-next-2.6 in a bit.

> > +               dev_info(ksp->dev, "ks8695 ethernet (%s) MAC: %s\n"=
,
> > +                        ks8695_port_type(ksp), print_mac(mac, ndev=
->dev_addr));
> Use %pM to format a MAC address instead of %s and print_mac().

I believe this must be new since 2.6.27 so I'll get that as I move to
net-next-2.6, thanks for the info.

> > +       } else {
> > +               /* Report the failure to register the net_device */
> > +               goto failure;
> I don't think this reports anything!

It reports to the next level up via the return code, which IIRC prints =
a
message, but I've added a dev_err() anyway before the goto failure.

> > +static int
> > +ks8695_drv_resume(struct platform_device *pdev)

> > +       if (netif_running(ndev)) {
> > +               ks8695_reset(ksp);
> > +               ks8695_init_net(ksp);
> Does this reinit the MAC address or multicast?

Nope, as per the timeout, I'd missed adding it here. That is now
corrected.

Thank you very much for your comments. Once this pull of net-next-2.6 i=
s
complete and I can do my forward-porting, I'll issue a new patch. Can I
ask what the magic runes are which I need in subject / precis to
actually request that my driver be merged rather than just reviewed?

Regards,

Daniel.

--=20
Daniel Silverstone                              http://www.simtec.co.uk=
/
PGP mail accepted and encouraged.            Key Id: 2BC8 4016 2068 789=
5


