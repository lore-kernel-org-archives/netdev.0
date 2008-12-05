From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Fri, 05 Dec 2008 17:57:50 +0000
Message-ID: <1228499870.3520.66.camel@achroite>
References: <49394379.9000501@simtec.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Daniel Silverstone <dsilvers@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:57977 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214AbYLER5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 12:57:55 -0500
In-Reply-To: <49394379.9000501@simtec.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-05 at 15:06 +0000, Daniel Silverstone wrote:
> Hello,
>=20
> Attached is a patch which implements the Micrel KS8695 SoC's Ethernet
> interfaces.
>=20
> The driver is only of use on the KS8695.

> =EF=BB=BFKS8695: Add support for the KS8695 ethernet devices.
>=20
> Implements the KS8695 ethernet device (ks8695net).
>=20
> Signed-off-by: Daniel Silverstone <dsilvers@simtec.co.uk>
> Signed-off-by: Vincent Sanders <vince@simtec.co.uk>
> Acked-by: Ben Dooks <ben@simtec.co.uk>
> Index: linux-2.6.27/drivers/net/arm/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.27.orig/drivers/net/arm/Kconfig   2008-12-05 11:29:29.6=
29076651 +0000
> +++ linux-2.6.27/drivers/net/arm/Kconfig        2008-12-05 11:30:15.3=
57075120 +0000

netdev patches should really be based on David Miller's net-next-2.6.

> Index: linux-2.6.27/drivers/net/arm/ks8695net.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null   1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6.27/drivers/net/arm/ks8695net.c    2008-12-05 13:07:56.7=
73076323 +0000
[...]
> +/**
> + *     enum ks8695_dtype - Device type
> + *     @KS8695_DTYPE_WAN: This device is a WAN interface
> + *     @KS8695_DTYPE_LAN: This device is a LAN interface
> + *     @KS8695_DTYPE_HPNA: This device is an HPNA interfacew
> + */
> +enum ks8695_dtype {
> +  KS8695_DTYPE_WAN,
> +  KS8695_DTYPE_LAN,
> +  KS8695_DTYPE_HPNA,
> +};

The enumerators should be indented with tabs.

> +/**
> + *     struct ks8695_priv - Private data for the KS8695 Ethernet
> + *     @in_suspend: Flag to indicate if we're suspending/resuming
> + *     @ndev: The net_device for this interface
> + *     @dev: The device object for this interface

Which device object - the platform device?

[...]
> +/**
> + *     ks8695_get_priv - Retrieve the private data from a net_device=
=2E
> + *     @ndev: The net_device to read the private data pointer from
> + *
> + *     Returns the private structure for the KS8695 Ethernet device.
> + */
> +static inline struct ks8695_priv *
> +ks8695_get_priv(struct net_device *ndev)
> +{
> +       return ndev->priv;
> +}

Don't use ndev->priv, use netdev_priv(ndev).  Which makes this function
redundant, except for the implicit pointer conversion.

[...]
> +/**
> + *     ks8695_refill_rxbuffers - Re-fill the RX buffer ring
> + *     @ksp: The device to refill
> + *
> + *     Iterates the RX ring of the device looking for empty slots.
> + *     For each empty slot, we allocate and map a new SKB and give i=
t
> + *     to the hardware.
> + *     This can be called from interrupt context safely.
> + */
> +static void
> +ks8695_refill_rxbuffers(struct ks8695_priv *ksp)
> +{
> +       /* Run around the RX ring, filling in any missing sk_buff's *=
/
> +       int buff_n;
> +
> +       for (buff_n =3D 0; buff_n < MAX_RX_DESC; ++buff_n) {
> +               if (!ksp->rx_buffers[buff_n].skb) {
> +                       struct sk_buff *skb =3D dev_alloc_skb(MAX_RXB=
UF_SIZE);
> +                       dma_addr_t mapping;
> +
> +                       ksp->rx_buffers[buff_n].skb =3D skb;
> +                       if (skb =3D=3D NULL) {
> +                               /* Failed to allocate one, perhaps
> +                                * we'll try again later.
> +                                */
> +                               break;
> +                       }
> +
> +                       mapping =3D dma_map_single(ksp->dev, skb->dat=
a,
> +                                                MAX_RXBUF_SIZE,
> +                                                DMA_FROM_DEVICE);

I take it that dma_map_single() can never fail on ARM?

> +                       ksp->rx_buffers[buff_n].dma_ptr =3D mapping;
> +                       skb->dev =3D ksp->ndev;
> +                       ksp->rx_buffers[buff_n].length =3D MAX_RXBUF_=
SIZE;
> +
> +                       /* Record this into the DMA ring */
> +                       ksp->rx_ring[buff_n].data_ptr =3D cpu_to_le32=
(mapping);
> +                       ksp->rx_ring[buff_n].length =3D
> +                               cpu_to_le32(MAX_RXBUF_SIZE);

You need a wmb() in here, otherwise the descriptor might not be complet=
e
when the hardware sees RDES_OWN set.

> +                       /* And give ownership over to the hardware */
> +                       ksp->rx_ring[buff_n].status =3D cpu_to_le32(R=
DES_OWN);
> +               }
> +       }
> +}
[...]
> +
> +/* Interrupt handling */
> +
> +/**
> + *     ks8695_tx_irq - Transmit IRQ handler
> + *     @irq: The IRQ which went off (ignored)
> + *     @dev_id: The net_device for the interrupt
> + *
> + *     Process the TX ring, clearing out any transmitted slots.
> + *     Allows the net_device to pass us new packets once slots are
> + *     freed.
> + */
> +static irqreturn_t
> +ks8695_tx_irq(int irq, void *dev_id)
> +{
> +       struct net_device *ndev =3D (struct net_device *)dev_id;
> +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> +       int buff_n;
> +
> +       for (buff_n =3D 0; buff_n < MAX_TX_DESC; ++buff_n) {
> +               if (ksp->tx_buffers[buff_n].skb &&
> +                   !(ksp->tx_ring[buff_n].owner & cpu_to_le32(TDES_O=
WN))) {

rmb()

> +                       /* An SKB which is not owned by HW is present=
 */
> +                       /* Update the stats for the net_device */
> +                       ndev->stats.tx_packets++;
> +                       ndev->stats.tx_bytes +=3D ksp->tx_buffers[buf=
f_n].length;
> +
> +                       /* Free the packet from the ring */
> +                       ksp->tx_ring[buff_n].data_ptr =3D 0;

Clearing data_ptr seems redundant.  The TDES_OWN flag indicates whether
the descriptor is pending and the skb pointer indicates whether a buffe=
r
needs to be freed.

> +                       /* Free the sk_buff */
> +                       dma_unmap_single(ksp->dev,
> +                                        ksp->tx_buffers[buff_n].dma_=
ptr,
> +                                        ksp->tx_buffers[buff_n].leng=
th,
> +                                        DMA_TO_DEVICE);
> +                       dev_kfree_skb_irq(ksp->tx_buffers[buff_n].skb=
);
> +                       ksp->tx_buffers[buff_n].skb =3D NULL;
> +                       ksp->tx_ring_used--;
> +               }
> +       }

Do you need to test all the descriptors or can you keep track of which
to check first and then stop when you find one still pending?  Maybe it
doesn't matter when you only have 8 of them...

> +       netif_wake_queue(ndev);
> +
> +       return IRQ_HANDLED;
> +}
> +
> +/**
> + *     ks8695_rx_irq - Receive IRQ handler
> + *     @irq: The IRQ which went off (ignored)
> + *     @dev_id: The net_device for the interrupt
> + *
> + *     Process the RX ring, passing any received packets up to the
> + *     host.  If we received anything other than errors, we then
> + *     refill the ring.
> + */
> +static irqreturn_t
> +ks8695_rx_irq(int irq, void *dev_id)
> +{
> +       struct net_device *ndev =3D (struct net_device *)dev_id;
> +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> +       struct sk_buff *skb;
> +       int buff_n;
> +       u32 flags;
> +       int pktlen;
> +       int last_rx_processed =3D -1;
> +
> +       buff_n =3D ksp->next_rx_desc_read;
> +       do {
> +               if (ksp->rx_buffers[buff_n].skb &&
> +                   !(ksp->rx_ring[buff_n].status & cpu_to_le32(RDES_=
OWN))) {

rmb()

> +                       flags =3D le32_to_cpu(ksp->rx_ring[buff_n].st=
atus);
> +                       /* Found an SKB which we own, this means we
> +                        * received a packet
> +                        */
> +                       if ((flags & (RDES_FS | RDES_LS)) !=3D
> +                           (RDES_FS | RDES_LS)) {
> +                               /* This packet is not the first and
> +                                * the last segment.  Therefore it is
> +                                * a "spanning" packet and we can't
> +                                * handle it
> +                                */
> +                               goto rx_failure;
> +                       }
> +
> +                       if (flags & (RDES_ES | RDES_RE)) {
> +                               /* It's an error packet */
> +                               ndev->stats.rx_errors++;
> +                               if (flags & RDES_TL)
> +                                       ndev->stats.rx_length_errors+=
+;
> +                               if (flags & RDES_RF)
> +                                       ndev->stats.rx_length_errors+=
+;
> +                               if (flags & RDES_CE)
> +                                       ndev->stats.rx_crc_errors++;
> +                               if (flags & RDES_RE)
> +                                       ndev->stats.rx_missed_errors+=
+;
> +
> +                               goto rx_failure;
> +                       }
> +
> +                       pktlen =3D flags & RDES_FLEN;
> +                       pktlen -=3D 4; /* Drop the CRC */
> +
> +                       skb =3D ksp->rx_buffers[buff_n].skb;

I think this line belongs after the following comment.

> +                       /* Extract the sk_buff from the ring */
> +                       ksp->rx_buffers[buff_n].skb =3D NULL;
> +                       ksp->rx_ring[buff_n].data_ptr =3D 0;
>
> +                       /* Unmap the SKB */
> +                       dma_unmap_single(ksp->dev,
> +                                        ksp->rx_buffers[buff_n].dma_=
ptr,
> +                                        ksp->rx_buffers[buff_n].leng=
th,
> +                                        DMA_FROM_DEVICE);
> +
> +                       /* Relinquish the SKB to the network layer */
> +                       skb_put(skb, pktlen);
> +                       skb->protocol =3D eth_type_trans(skb, ndev);
> +                       netif_rx(skb);
> +
> +                       /* Record stats */
> +                       ndev->last_rx =3D jiffies;
> +                       ndev->stats.rx_packets++;
> +                       ndev->stats.rx_bytes +=3D pktlen;
> +                       goto rx_finished;
> +
> +rx_failure:
> +                       /* This ring entry is an error, but we can
> +                        * re-use the skb
> +                        */
> +                       /* Give the ring entry back to the hardware *=
/
> +                       ksp->rx_ring[buff_n].status =3D cpu_to_le32(R=
DES_OWN);
> +rx_finished:
> +                       /* And note this as processed so we can start
> +                        * from here next time
> +                        */
> +                       last_rx_processed =3D buff_n;
> +               } else {
> +                       /* Ran out of things to process, stop now */
> +                       break;
> +               }
> +               buff_n =3D (buff_n + 1) % MAX_RX_DESC;

That's another expensive division.

> +       } while (buff_n !=3D ksp->next_rx_desc_read);
> +
> +       /* And note which RX descriptor we last did anything with */
> +       if (likely(last_rx_processed !=3D -1))
> +               ksp->next_rx_desc_read =3D (last_rx_processed + 1) % =
MAX_RX_DESC;
> +
> +       /* And refill the buffers */
> +       ks8695_refill_rxbuffers(ksp);
> +
> +       /* Kick the RX DMA engine, in case it became suspended */
> +       ks8695_writereg(ksp, KS8695_DRSC, 0);
> +
> +       return IRQ_HANDLED;
> +}
[...]
> +
> +/* KS8695 Device functions */
> +
> +/**
> + *     ks8695_reset - Reset a KS8695 ethernet interface
> + *     @ksp: The interface to reset
> + *
> + *     Perform an engine reset of the interface and re-program it
> + *     with sensible defaults.
> + */
> +static void
> +ks8695_reset(struct ks8695_priv *ksp)
> +{
> +       int reset_timeout =3D watchdog;
> +       /* Issue the reset via the TX DMA control register */
> +       ks8695_writereg(ksp, KS8695_DTXC, DTXC_TRST);
> +       while (reset_timeout--) {
> +               if (!(ks8695_readreg(ksp, KS8695_DTXC) & DTXC_TRST))
> +                       break;
> +               msleep(1);
> +       }

Is there any reason this timeout should be tied to the TX watchdog
timeout?

[...]
> +/**
> + *     ks8695_init_net - Initialise a KS8695 ethernet interface
> + *     @ksp: The interface to initialise
> + *
> + *     This routine fills the RX ring, initialises the DMA engines,
> + *     allocates the IRQs and then starts the packet TX and RX
> + *     engines.
> + */
> +static int
> +ks8695_init_net(struct ks8695_priv *ksp)
> +{
> +       int ret;
> +       u32 ctrl;
> +
> +       ks8695_refill_rxbuffers(ksp);
> +
> +       /* Initialise the DMA engines */
> +       ks8695_writereg(ksp, KS8695_RDLB, (u32) ksp->rx_ring_dma);
> +       ks8695_writereg(ksp, KS8695_TDLB, (u32) ksp->tx_ring_dma);
> +
> +       /* Request the IRQs */
> +       ret =3D ks8695_setup_irq(ksp->rx_irq, ksp->rx_irq_name,
> +                              ks8695_rx_irq, ksp->ndev);
> +       if (ret)
> +               return ret;
> +       ret =3D ks8695_setup_irq(ksp->tx_irq, ksp->tx_irq_name,
> +                              ks8695_tx_irq, ksp->ndev);
> +       if (ret)
> +               return ret;
> +       if (ksp->link_irq !=3D -1) {
> +               ret =3D ks8695_setup_irq(ksp->link_irq, ksp->link_irq=
_name,
> +                                      ks8695_link_irq, ksp->ndev);
> +               if (ret)
> +                       return ret;
> +       }

The RX and TX IRQ handlers need to be released in case the TX or link
IRQ setup fails.

> +       /* Set up the ring indices */
> +       ksp->next_rx_desc_read =3D 0;
> +       ksp->tx_ring_next_slot =3D 0;
> +       ksp->tx_ring_used =3D 0;
> +
> +       /* Bring up transmission */
> +       ctrl =3D ks8695_readreg(ksp, KS8695_DTXC);
> +       /* Enable packet transmission */
> +       ks8695_writereg(ksp, KS8695_DTXC, ctrl | DTXC_TE);
> +
> +       /* Bring up the reception */
> +       ctrl =3D ks8695_readreg(ksp, KS8695_DRXC);
> +       /* Enable packet reception */
> +       ks8695_writereg(ksp, KS8695_DRXC, ctrl | DRXC_RE);
> +       /* And start the DMA engine */
> +       ks8695_writereg(ksp, KS8695_DRSC, 0);
> +
> +       /* All done */
> +       return 0;
> +}
> +
> +/**
> + *     ks8695_release_device - HW resource release for KS8695 e-net
> + *     @ksp: The device to be freed
> + *
> + *     This unallocates io memory regions, dma-coherent regions etc
> + *     which were allocated in ks8695_probe.
> + */
> +static void
> +ks8695_release_device(struct ks8695_priv *ksp)
> +{
> +       /* Unmap the registers */
> +       iounmap(ksp->io_regs);
> +       if (ksp->phyiface_regs)
> +               iounmap(ksp->phyiface_regs);
> +
> +       /* And release the request */
> +       release_resource(ksp->regs_req);
> +       kfree(ksp->regs_req);
> +       if (ksp->phyiface_req) {
> +               release_resource(ksp->phyiface_req);
> +               kfree(ksp->phyiface_req);
> +       }
> +
> +       /* Free the ring buffers */
> +       dma_free_coherent(ksp->dev, RING_DMA_SIZE,
> +                         ksp->ring_base, ksp->ring_base_dma);
> +}

> +/**
> + *     ks8695_get_settings - Get device-specific settings.
> + *     @ndev: The network device to read settings from
> + *     @cmd: The ethtool structure to read into
> + */
> +static int
> +ks8695_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd=
)
> +{
> +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> +       u32 ctrl;
> +
> +       /* All ports on the KS8695 support these... */
> +       cmd->supported =3D (SUPPORTED_10baseT_Half | SUPPORTED_10base=
T_Full |
> +                         SUPPORTED_100baseT_Half | SUPPORTED_100base=
T_Full |
> +                         SUPPORTED_TP | SUPPORTED_MII);
> +       cmd->advertising =3D ADVERTISED_TP | ADVERTISED_MII;
> +       cmd->port =3D PORT_MII;
> +       cmd->transceiver =3D XCVR_INTERNAL;

I think the TP and MII flags should be dependent on ksp->dtype.

> +       /* Port specific extras */
> +       switch (ksp->dtype) {
> +       case KS8695_DTYPE_HPNA:
> +               cmd->phy_address =3D 0;
> +               /* not supported for HPNA */
> +               cmd->autoneg =3D AUTONEG_DISABLE;
> +
> +               /* BUG: Erm, dtype hpna implies no phy regs */
> +               /*
> +               ctrl =3D readl(KS8695_MISC_VA + KS8695_HMC);
> +               cmd->speed =3D (ctrl & HMC_HSS) ? SPEED_100 : SPEED_1=
0;
> +               cmd->duplex =3D (ctrl & HMC_HDS) ? DUPLEX_FULL : DUPL=
EX_HALF;
> +               */
> +               break;
[...]
> +       case KS8695_DTYPE_LAN:
> +               /* TODO: Implement this for the switch ports */
> +               break;
> +       }

You'd better implement these or return -EOPNOTSUPP.  Similarly in
ks8695_set_settings() and ks8695_nwayreset().

> +       return 0;
> +}
[...]
> +/**
> + *     ks8695_set_pause - Configure pause/flow-control
> + *     @ndev: The device to configure
> + *     @param: The pause parameters to set
> + *
> + *     TODO: Implement this

Yes, or return -EOPNOTSUPP.

> + */
> +static int
> +ks8695_set_pause(struct net_device *ndev, struct ethtool_pauseparam =
*param)
> +{
> +       return 0;
> +}
[...]
> +/**
> + *     ks8695_timeout - Handle a network tx/rx timeout.
> + *     @ndev: The net_device which timed out.
> + *
> + *     A network transaction timed out, reset the device.
> + */
> +static void
> +ks8695_timeout(struct net_device *ndev)
> +{
> +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> +
> +       netif_stop_queue(ndev);
> +       ks8695_shutdown(ksp);
> +
> +       ks8695_reset(ksp);
> +
> +       ks8695_update_mac(ksp);
> +
> +       /* We ignore the return from this since it managed to init
> +        * before it probably will be okay to init again.
> +        */
> +       ks8695_init_net(ksp);
> +
> +       netif_start_queue(ndev);
> +}

It looks like this might lose multicast settings.

> +/**
> + *     ks8695_start_xmit - Start a packet transmission
> + *     @skb: The packet to transmit
> + *     @ndev: The network device to send the packet on
> + *
> + *     This routine, called by the net layer, takes ownership of the
> + *     sk_buff and adds it to the TX ring. It then kicks the TX DMA
> + *     engine to ensure transmission begins.
> + */
> +static int
> +ks8695_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> +       int buff_n;
> +
> +       spin_lock_irq(&ksp->txq_lock);
> +
> +       if (ksp->tx_ring_used =3D=3D MAX_TX_DESC) {
> +               /* Somehow we got entered when we have no room */
> +               spin_unlock_irq(&ksp->txq_lock);
> +               return -ENOSPC;

You must return NETDEV_TX_OK or =EF=BB=BFNETDEV_TX_BUSY, not 0 or a neg=
ative
error code.

> +       }
> +
> +       buff_n =3D ksp->tx_ring_next_slot;
> +       ksp->tx_ring_next_slot =3D (buff_n + 1) % MAX_TX_DESC;

That's an expensive division, which could be avoided by either (1)
declaring buff_n unsigned or (2) explicitly masking.

> +       if (ksp->tx_buffers[buff_n].skb) {
> +               /* This slot is used, try later */
> +               spin_unlock_irq(&ksp->txq_lock);
> +               return -EAGAIN;

Since you already tested tx_ring_used, wouldn't this indicate a bug?

> +       }
> +
> +       ksp->tx_buffers[buff_n].skb =3D skb;
> +       ksp->tx_buffers[buff_n].length =3D skb->len;
> +       ksp->tx_buffers[buff_n].dma_ptr =3D dma_map_single(
> +               ksp->dev, skb->data, skb->len, DMA_TO_DEVICE);
> +
> +       /* Fill out the TX descriptor */
> +       ksp->tx_ring[buff_n].data_ptr =3D
> +               cpu_to_le32(ksp->tx_buffers[buff_n].dma_ptr);
> +       ksp->tx_ring[buff_n].status =3D
> +               cpu_to_le32(TDES_IC | TDES_FS | TDES_LS |
> +                           (skb->len & TDES_TBS));

wmb()

> +       /* Hand it over to the hardware */
> +       ksp->tx_ring[buff_n].owner =3D cpu_to_le32(TDES_OWN);
[...]
> +/**
> + *     ks8695_probe - Probe and initialise a KS8695 ethernet interfa=
ce
> + *     @pdev: The platform device to probe
> + *
> + *     Initialise a KS8695 ethernet device from platform data.
> + *
> + *     This driver requires at least one IORESOURCE_MEM for the
> + *     registers and two IORESOURCE_IRQ for the RX and TX IRQs
> + *     respectively. It can optionally take an additional
> + *     IORESOURCE_MEM for the switch or phy in the case of the lan o=
r
> + *     wan ports, and an IORESOURCE_IRQ for the link IRQ for the wan
> + *     port.
> + */
> +static int __devinit
> +ks8695_probe(struct platform_device *pdev)
> +{
[...]
> +       /* Tell the net_device all about us */
> +       ndev->base_addr =3D (unsigned long)ksp->io_regs;
> +       ndev->irq       =3D ksp->rx_irq;

Don't bother setting base_addr and irq; they are for ancient ISA crap.

> +       /* driver system setup */
> +       ether_setup(ndev);
> +
> +       ndev->open               =3D &ks8695_open;
> +       ndev->stop               =3D &ks8695_stop;
> +       ndev->hard_start_xmit    =3D &ks8695_start_xmit;
> +       ndev->tx_timeout         =3D &ks8695_timeout;
> +       ndev->set_multicast_list =3D &ks8695_set_multicast;
> +       ndev->watchdog_timeo     =3D msecs_to_jiffies(watchdog);
> +       ndev->ethtool_ops        =3D &ks8695_ethtool_ops;
> +       ndev->set_mac_address    =3D &ks8695_set_mac;

You should use net_device_ops now.

> +       /* Initialise the port (physically) */
> +       if (ksp->phyiface_regs && ksp->link_irq =3D=3D -1) {
> +               ks8695_init_switch(ksp);
> +               ksp->dtype =3D KS8695_DTYPE_LAN;
> +       } else if (ksp->phyiface_regs && ksp->link_irq !=3D -1) {
> +               ks8695_init_wan_phy(ksp);
> +               ksp->dtype =3D KS8695_DTYPE_WAN;
> +       } else {
> +               /* No initialisation since HPNA does not have a PHY *=
/
> +               ksp->dtype =3D KS8695_DTYPE_HPNA;
> +       }
> +
> +       /* And bring up the net_device with the net core */
> +       platform_set_drvdata(pdev, ndev);
> +       ret =3D register_netdev(ndev);
> +
> +       if (ret =3D=3D 0) {
> +               DECLARE_MAC_BUF(mac);
> +               dev_info(ksp->dev, "ks8695 ethernet (%s) MAC: %s\n",
> +                        ks8695_port_type(ksp), print_mac(mac, ndev->=
dev_addr));

Use %pM to format a MAC address instead of %s and print_mac().

> +       } else {
> +               /* Report the failure to register the net_device */
> +               goto failure;

I don't think this reports anything!

> +       }
> +
> +       /* All is well */
> +       return 0;
> +
> +       /* Error exit path */
> +failure:
> +       ks8695_release_device(ksp);
> +       free_netdev(ndev);
> +
> +       return ret;
> +}
[...]
> +/**
> + *     ks8695_drv_resume - Resume a KS8695 ethernet platform device.
> + *     @pdev: The device to resume
> + *
> + *     This routine re-initialises and re-attaches a KS8695 ethernet
> + *     device.
> + */
> +static int
> +ks8695_drv_resume(struct platform_device *pdev)
> +{
> +       struct net_device *ndev =3D platform_get_drvdata(pdev);
> +       struct ks8695_priv *ksp =3D ks8695_get_priv(ndev);
> +
> +       if (netif_running(ndev)) {
> +               ks8695_reset(ksp);
> +               ks8695_init_net(ksp);

Does this reinit the MAC address or multicast?

> +               netif_device_attach(ndev);
> +       }
> +
> +       ksp->in_suspend =3D 0;
> +
> +       return 0;
> +}
[...]

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

