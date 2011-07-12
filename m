From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA
 API usage
Date: Tue, 12 Jul 2011 22:53:16 +0200
Message-ID: <20110712205316.GA13503@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl>
 <4E1BCF36.2010506@openwrt.org>
 <20110712193204.GB13413@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
To: Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110712193204.GB13413-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2011 at 08:32:04PM +0100, Ralf Baechle wrote:
> On Tue, Jul 12, 2011 at 12:36:06PM +0800, Felix Fietkau wrote:
>=20
> > >diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/w=
ireless/ath/ath9k/recv.c
> > >index 70dc8ec..c5f46d5 100644
> > >--- a/drivers/net/wireless/ath/ath9k/recv.c
> > >+++ b/drivers/net/wireless/ath/ath9k/recv.c
> > >@@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct ath_=
softc *sc,
> > >  	BUG_ON(!bf);
> > >
> > >  	dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
> > >-				common->rx_bufsize, DMA_FROM_DEVICE);
> > >+				common->rx_bufsize, DMA_BIDIRECTIONAL);
> > >
> > >  	ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
> > >-	if (ret =3D=3D -EINPROGRESS) {
> > >-		/*let device gain the buffer again*/
> > >-		dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
> > >-				common->rx_bufsize, DMA_FROM_DEVICE);
> > >+	if (ret =3D=3D -EINPROGRESS)
> > >  		return false;
> > >-	}
> > >
> > >  	__skb_unlink(skb,&rx_edma->rx_fifo);
> > >  	if (ret =3D=3D -EINVAL) {
> > I have strong doubts about this change. On most MIPS devices,
> > dma_sync_single_for_cpu is a no-op, whereas
> > dma_sync_single_for_device flushes the cache range. With this
> > change, the CPU could cache the DMA status part behind skb->data an=
d
> > that cache entry would not be flushed inbetween calls to this
> > functions on the same buffer, likely leading to rx stalls.
>=20
> The code was already broken before.  By the time dma_sync_single_for_=
cpu
> and ath9k_hw_process_rxdesc_edma are called, the DMA engine may still=
 be
> active in the buffer,  yet the driver is looking at it.
>=20
> dma_sync_single_for_cpu() is part of changing the buffer ownership fr=
om
> the device to the CPU.  When it is being called, DMA into the buffer =
should
> already have been completed ...  or else the shit may hit the jet eng=
ine.

Let's get rid of the "buffer ownership" misunderstanding from the pictu=
re.
Ownership is about who is expected to be writing (or is assured the dat=
a
is not being changed under his foot). This has nothing to do with DMA A=
PI.

DMA API is there for two purposes: to make part of memory visible to
both CPU and device (map/unmap) and to ensure memory consistency in
presence of caches (sync; implicitly done in map/unmap).

In the case we're analysing, the ownership is on the device's side
until it stops writing the buffer. sync_to_cpu doesn't change that.
It only allows the CPU to see more recent data (in case the CPU cached
something earlier).

> Imagine what would happen on a hypothetic cache architecture which do=
es not
> have a dirty bit, that is which would have to write back every cache =
line -
> even clean lines - to memory in order to evict it.  Corruption.

dma_map_whatever() would mark the memory uncachable on such an architec=
ture.
Otherwise this would violate assumptions on DMA_FROM_DEVICE mappings (o=
r
"device owned buffers") that the CPU does not write to the mapped memor=
y.

Best Regards,
Micha=B3 Miros=B3aw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
