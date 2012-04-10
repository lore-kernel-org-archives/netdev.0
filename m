From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: via-rhine: Problem with lost link after a while
Date: Wed, 11 Apr 2012 01:58:56 +0200
Message-ID: <CACPM=kUX4dPXW93V_mHBvNb_d-kTUWdMNRyEN80n7ztStiHk=w@mail.gmail.com>
References: <CACPM=kWa=UWuCMaYAtVMGJ7pzCy-PfyNRWBSuJnTZGtssU0W6g@mail.gmail.com>
	<20120410204249.GA26627@electric-eye.fr.zoreil.com>
	<CACPM=kWsU8QZOHqwEThTQCuSSvaTDoxO1d17EyoW=+kx8QG3vw@mail.gmail.com>
	<20120410225534.GA28480@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Svenning_S=F8rensen?= <sss@secomea.com>,
	Andreas Mohr <andi@lisas.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120410225534.GA28480@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

11. apr. 2012 00.55 skrev Francois Romieu <romieu@fr.zoreil.com>:
> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
>> 10. apr. 2012 22.42 skrev Francois Romieu <romieu@fr.zoreil.com>:
> [...]
>> > http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;h=3D=
3f8c91a7398b9266fbe7abcbe4bd5dffef907643
> [...]
>> Great, I'll try a 3.4-rc2 kernel, and see how it runs.
>>
>> The thread I was talking about earlier is here:
>> http://lists.soekris.com/pipermail/soekris-tech/2012-April/018318.ht=
ml
>> Is there any of the changes he has there, that makes sense in the ne=
w
>> driver you wrote ?
>
> (I did not write a new driver)

Sorry, bad choice of words, meant fixed some issues with the driver :)

> Regarding Svenning's patch:
> - the wmb in alloc_rbufs may help rhine_reset_task().
> - one should probably add one in rhine_rx() as well.
> - rhine_start_tx() is supposed to stop queueing when there is no room=
 left.
> =A0I'm curious to know if the "Tx descriptor busy" test triggered.
> - the rmb() in rhine_tx() will not make a difference for a single cor=
e but
> =A0it's a good reminder that I should not have forgotten to propagate=
 the
> =A0xmit / Tx completion fix back from the r8169 driver to the via-rhi=
ne one
> =A0(sigh)
>
> mmiowb is probably missing. I doubt it hits hard right now.

I'll give it a spin tomorrow, and see how it runs :)

> I have not checked if MMIO flushes are missing. Actually I need some =
sleep.
>
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ether=
net/via/via-rhine.c
> index fcfa01f..dfa9fc0 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -1163,6 +1163,7 @@ static void alloc_rbufs(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 PCI_DMA_FROMDEVICE);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->rx_ring[i].addr =3D cpu_to_le32(rp=
->rx_skbuff_dma[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmb();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->rx_ring[i].rx_status =3D cpu_to_le=
32(DescOwn);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rp->dirty_rx =3D (unsigned int)(i - RX_RING_SIZE);
> @@ -1709,8 +1710,13 @@ static netdev_tx_t rhine_start_tx(struct sk_bu=
ff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioaddr + ChipCmd1);
> =A0 =A0 =A0 =A0IOSYNC;
>
> - =A0 =A0 =A0 if (rp->cur_tx =3D=3D rp->dirty_tx + TX_QUEUE_LEN)
> + =A0 =A0 =A0 if (rp->cur_tx =3D=3D rp->dirty_tx + TX_QUEUE_LEN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_wmb();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_stop_queue(dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_mb();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rp->cur_tx !=3D rp->dirty_tx + TX_Q=
UEUE_LEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(dev);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0netif_dbg(rp, tx_queued, dev, "Transmit frame #%d queu=
ed in slot %d\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->cur_tx - 1, entry);
> @@ -1759,6 +1765,7 @@ static void rhine_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0int txstatus =3D 0, entry =3D rp->dirty_tx % TX_RING_S=
IZE;
>
> + =A0 =A0 =A0 smp_rmb();
> =A0 =A0 =A0 =A0/* find and cleanup dirty tx descriptors */
> =A0 =A0 =A0 =A0while (rp->dirty_tx !=3D rp->cur_tx) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0txstatus =3D le32_to_cpu(rp->tx_ring[e=
ntry].tx_status);
> @@ -1806,8 +1813,12 @@ static void rhine_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->tx_skbuff[entry] =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0entry =3D (++rp->dirty_tx) % TX_RING_S=
IZE;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
> +
> + =A0 =A0 =A0 smp_mb();
> + =A0 =A0 =A0 if (netif_queue_stopped(dev) &&
> + =A0 =A0 =A0 =A0 =A0 (rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)=
 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_wake_queue(dev);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0/**
> @@ -1947,6 +1958,7 @@ static int rhine_rx(struct net_device *dev, int=
 limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 PCI_DMA_FROMDEVICE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->rx_ring[entry].add=
r =3D cpu_to_le32(rp->rx_skbuff_dma[entry]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmb();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->rx_ring[entry].rx_status =3D cpu_t=
o_le32(DescOwn);
> =A0 =A0 =A0 =A0}
>
> --
> Ueimor
>
> Will code drivers for food.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
