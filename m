From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v4] Network driver for the Armada 370 and Armada XP ARM
 Marvell SoCs
Date: Tue, 13 Nov 2012 12:34:19 +0100
Message-ID: <20121113123419.4516b4b8@skate>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121030105154.5b7c8e48@skate>
	<20121102232137.3c9da5e4@skate>
	<20121103115321.GA4539@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:47979 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab2KMLed convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 06:34:33 -0500
In-Reply-To: <20121103115321.GA4539@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ran=C3=A7ois,

Thanks for your detailed review. I have a few comments/questions below
on specific topics.

On Sat, 3 Nov 2012 12:53:21 +0100, Francois Romieu wrote:
> > +	if (rxq->descs =3D=3D NULL) {
> > +		netdev_err(pp->dev,
> > +			   "rxQ=3D%d: Can't allocate %d bytes for %d RX descr\n",
> > +			   rxq->id, rxq->size * MVNETA_DESC_ALIGNED_SIZE,
> > +			   rxq->size);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	BUG_ON(rxq->descs !=3D
> > +	       PTR_ALIGN(rxq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));
>=20
> There is no reason to crash.

Well, there is a reason: the hardware will not work properly if
rxq->descs is not aligned on a MVNETA_CPU_D_CACHE_LINE_SIZE boundary.
So one solution is to over-allocated to guarantee the alignment, but
since practically speaking MVNETA_CPU_D_CACHE_LINE_SIZE=3D32 and
dma_alloc_coherent() returns things that seem at least 32 bytes
aligned, it sounded overkill to include more code to fix a problem that
doesn't exist. This BUG_ON() is here solely for the purpose of noisily
letting the user know if this implicit assumption on the alignment of
dma_alloc_coherent() allocated buffer changes in the future. I can turn
this into an error if you prefer:

	if (rxq->descs !=3D PTR_ALIGN(rxq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE=
)) {
		netdev_err(pp->dev, "improper buffer alignement assumption, driver ne=
eds fixing\n");
		dma_free_coherent(...);
		return -EINVAL;
	}

> (...]
> > +static int mvneta_txq_init(struct mvneta_port *pp,
> > +			   struct mvneta_tx_queue *txq)
> > +{
> > +	txq->size =3D pp->tx_ring_size;
> > +
> > +	/* Allocate memory for TX descriptors */
> > +	txq->descs =3D dma_alloc_coherent(pp->dev->dev.parent,
> > +					txq->size * MVNETA_DESC_ALIGNED_SIZE,
> > +					&txq->descs_phys,
> > +					DMA_BIDIRECTIONAL);
>=20
> 					&txq->descs_phys, DMA_BIDIRECTIONAL);

Aaah, thanks for pointing this one! It should have been GFP_KERNEL, not
DMA_BIDIRECTIONAL here.

> > +	if (txq->descs =3D=3D NULL) {
> > +		netdev_err(pp->dev,
> > +			   "txQ=3D%d: Can't allocate %d bytes for %d TX descr\n",
> > +			   txq->id, txq->size * MVNETA_DESC_ALIGNED_SIZE,
> > +			   txq->size);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	/* Make sure descriptor address is cache line size aligned  */
> > +	BUG_ON(txq->descs !=3D
> > +	       PTR_ALIGN(txq->descs, MVNETA_CPU_D_CACHE_LINE_SIZE));
>=20
> There is no reason to crash.

Same as above :-)

> [...]
> > +static int mvneta_setup_rxqs(struct mvneta_port *pp)
> > +{
> > +	int queue;
> > +
> > +	for (queue =3D 0; queue < rxq_number; queue++) {
> > +		int err =3D mvneta_rxq_init(pp, &pp->rxqs[queue]);
> > +		if (err) {
> > +			netdev_err(pp->dev,
> > +				   "%s: can't create RxQ rxq=3D%d\n",
>=20
> 			netdev_err(pp->dev, "%s: can't create RxQ rxq=3D%d\n",
>=20
> > +				   __func__, queue);
> > +			mvneta_cleanup_rxqs(pp);
> > +			return -ENODEV;
>=20
> mvneta_rxq_init should return a proper error code and it should be
> propagated (option: break instead of return and mvneta_setup_rxqs sco=
ped
> err variable)

Besides turning the "return -ENODEV;" into "return err;", I don't see
what is the other problem here? mvneta_rxq_init() properly returns
-ENOMEM where there is a memory allocation failure, and
mvneta_cleanup_rxqs() properly cleans up *all* initialized rxqs. Is
there something I'm missing?

Thanks again for your review!

Thomas
--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
