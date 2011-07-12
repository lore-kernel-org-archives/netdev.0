From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA
 API usage
Date: Tue, 12 Jul 2011 15:03:16 +0200
Message-ID: <20110712130316.GA8621@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl>
 <4E1BCF36.2010506@openwrt.org>
 <20110712095541.GA6236@rere.qmqm.pl>
 <B4765EFC-B5C9-4E2D-BE00-ED5519D13A4E@nbd.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	"ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org" <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	"linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
To: Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <B4765EFC-B5C9-4E2D-BE00-ED5519D13A4E-Vt+b4OUoWG0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2011 at 08:54:32PM +0800, Felix Fietkau wrote:
> On 12.07.2011, at 17:55, Micha=B3 Miros=B3aw <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org=
> wrote:
>=20
> > On Tue, Jul 12, 2011 at 12:36:06PM +0800, Felix Fietkau wrote:
> >> On 2011-07-11 8:52 AM, Micha=B3 Miros=B3aw wrote:
> >>> Also constify buf_addr for ath9k_hw_process_rxdesc_edma() to veri=
fy
> >>> assumptions --- dma_sync_single_for_device() call can be removed.
> >>>=20
> >>> Signed-off-by: Micha=B3 Miros=B3aw<mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
> >>> ---
> >>> drivers/net/wireless/ath/ath9k/ar9003_mac.c |    4 ++--
> >>> drivers/net/wireless/ath/ath9k/ar9003_mac.h |    2 +-
> >>> drivers/net/wireless/ath/ath9k/recv.c       |   10 +++-------
> >>> 3 files changed, 6 insertions(+), 10 deletions(-)
> >>>=20
> >>> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/=
wireless/ath/ath9k/recv.c
> >>> index 70dc8ec..c5f46d5 100644
> >>> --- a/drivers/net/wireless/ath/ath9k/recv.c
> >>> +++ b/drivers/net/wireless/ath/ath9k/recv.c
> >>> @@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct ath=
_softc *sc,
> >>>    BUG_ON(!bf);
> >>>=20
> >>>    dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
> >>> -                common->rx_bufsize, DMA_FROM_DEVICE);
> >>> +                common->rx_bufsize, DMA_BIDIRECTIONAL);
> >>>=20
> >>>    ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
> >>> -    if (ret =3D=3D -EINPROGRESS) {
> >>> -        /*let device gain the buffer again*/
> >>> -        dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
> >>> -                common->rx_bufsize, DMA_FROM_DEVICE);
> >>> +    if (ret =3D=3D -EINPROGRESS)
> >>>        return false;
> >>> -    }
> >>>=20
> >>>    __skb_unlink(skb,&rx_edma->rx_fifo);
> >>>    if (ret =3D=3D -EINVAL) {
> >> I have strong doubts about this change. On most MIPS devices,
> >> dma_sync_single_for_cpu is a no-op, whereas
> >> dma_sync_single_for_device flushes the cache range. With this
> >> change, the CPU could cache the DMA status part behind skb->data a=
nd
> >> that cache entry would not be flushed inbetween calls to this
> >> functions on the same buffer, likely leading to rx stalls.
> >=20
> > You're suggesting a platform implementation bug then. If the platfo=
rm is not
> > cache-coherent, it should invalidate relevant CPU cache lines for s=
ync_to_cpu
> > and unmap cases. Do other devices show such symptoms on MIPS system=
s?
> >=20
> > I'm not familiar with the platform internals, so we should ask MIPS=
 people.
> I only mentioned MIPS to describe the potential side effect of this c=
hange. From my current understanding of the DMA API, it would be wrong =
on other platforms as well. I believe the _for_device function needs to=
 be used to transfer ownership of the buffer back to the device, before=
 calling _for_cpu again later for another read.

What you're saying reminds the wording in DMA-API-HOWTO.txt that I find
wrong (or at least misleading) compared to what DMA-API.txt describes.
DMA sync calls do not transfer the ownership of the buffer - they are
cache synchronization points, ownership passing is handled entirely by
the driver.

> This is definitely required in this case, because when the return cod=
e is -EINPROGRESS, the driver waits for the hardware to complete this b=
uffer, and the next call has to fetch the memory again after the device=
 has updated it.

Correctness of this access should be provided by sync_to_cpu() call.

Best Regards,
Micha=B3 Miros=B3aw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
