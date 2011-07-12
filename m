From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA
 API usage
Date: Tue, 12 Jul 2011 21:13:45 +0200
Message-ID: <20110712191345.GA12934@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl>
 <4E1BCF36.2010506@openwrt.org>
 <20110712095541.GA6236@rere.qmqm.pl>
 <B4765EFC-B5C9-4E2D-BE00-ED5519D13A4E@nbd.name>
 <20110712130316.GA8621@rere.qmqm.pl>
 <EC2F82D7-9206-4139-9539-F5DDE38A5629@nbd.name>
 <20110712155849.GB10651@rere.qmqm.pl>
 <57124BD4-F53A-4424-A61F-5D8E629EB36F@nbd.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd@openwrt.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Jouni Malinen <jmalinen@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	"linux-mips@linux-mips.org" <linux-mips@linux-mips.org>
To: Felix Fietkau <nbd@nbd.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50239 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab1GLTNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 15:13:46 -0400
Content-Disposition: inline
In-Reply-To: <57124BD4-F53A-4424-A61F-5D8E629EB36F@nbd.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2011 at 12:04:50AM +0800, Felix Fietkau wrote:
> On 12.07.2011, at 23:58, Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl=
> wrote:
>=20
> > On Tue, Jul 12, 2011 at 10:21:05PM +0800, Felix Fietkau wrote:
> >> On 12.07.2011, at 21:03, Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm=
=2Epl> wrote:
> >>=20
> >>> On Tue, Jul 12, 2011 at 08:54:32PM +0800, Felix Fietkau wrote:
> >>>> On 12.07.2011, at 17:55, Micha=B3 Miros=B3aw <mirq-linux@rere.qm=
qm.pl> wrote:
> >>>>=20
> >>>>> On Tue, Jul 12, 2011 at 12:36:06PM +0800, Felix Fietkau wrote:
> >>>>>> On 2011-07-11 8:52 AM, Micha=B3 Miros=B3aw wrote:
> >>>>>>> Also constify buf_addr for ath9k_hw_process_rxdesc_edma() to =
verify
> >>>>>>> assumptions --- dma_sync_single_for_device() call can be remo=
ved.
> >>>>>>>=20
> >>>>>>> Signed-off-by: Micha=B3 Miros=B3aw<mirq-linux@rere.qmqm.pl>
> >>>>>>> ---
> >>>>>>> drivers/net/wireless/ath/ath9k/ar9003_mac.c |    4 ++--
> >>>>>>> drivers/net/wireless/ath/ath9k/ar9003_mac.h |    2 +-
> >>>>>>> drivers/net/wireless/ath/ath9k/recv.c       |   10 +++-------
> >>>>>>> 3 files changed, 6 insertions(+), 10 deletions(-)
> >>>>>>>=20
> >>>>>>> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/=
net/wireless/ath/ath9k/recv.c
> >>>>>>> index 70dc8ec..c5f46d5 100644
> >>>>>>> --- a/drivers/net/wireless/ath/ath9k/recv.c
> >>>>>>> +++ b/drivers/net/wireless/ath/ath9k/recv.c
> >>>>>>> @@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct=
 ath_softc *sc,
> >>>>>>>  BUG_ON(!bf);
> >>>>>>>=20
> >>>>>>>  dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
> >>>>>>> -                common->rx_bufsize, DMA_FROM_DEVICE);
> >>>>>>> +                common->rx_bufsize, DMA_BIDIRECTIONAL);
> >>>>>>>=20
> >>>>>>>  ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
> >>>>>>> -    if (ret =3D=3D -EINPROGRESS) {
> >>>>>>> -        /*let device gain the buffer again*/
> >>>>>>> -        dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
> >>>>>>> -                common->rx_bufsize, DMA_FROM_DEVICE);
> >>>>>>> +    if (ret =3D=3D -EINPROGRESS)
> >>>>>>>      return false;
> >>>>>>> -    }
> >>>>>>>=20
> >>>>>>>  __skb_unlink(skb,&rx_edma->rx_fifo);
> >>>>>>>  if (ret =3D=3D -EINVAL) {
> >>>>>> I have strong doubts about this change. On most MIPS devices,
> >>>>>> dma_sync_single_for_cpu is a no-op, whereas
> >>>>>> dma_sync_single_for_device flushes the cache range. With this
> >>>>>> change, the CPU could cache the DMA status part behind skb->da=
ta and
> >>>>>> that cache entry would not be flushed inbetween calls to this
> >>>>>> functions on the same buffer, likely leading to rx stalls.
> >>>>> You're suggesting a platform implementation bug then. If the pl=
atform is not
> >>>>> cache-coherent, it should invalidate relevant CPU cache lines f=
or sync_to_cpu
> >>>>> and unmap cases. Do other devices show such symptoms on MIPS sy=
stems?
> >>>>>=20
> >>>>> I'm not familiar with the platform internals, so we should ask =
MIPS people.
> >>>> I only mentioned MIPS to describe the potential side effect of t=
his change. From my current understanding of the DMA API, it would be w=
rong on other platforms as well. I believe the _for_device function nee=
ds to be used to transfer ownership of the buffer back to the device, b=
efore calling _for_cpu again later for another read.
> >>> What you're saying reminds the wording in DMA-API-HOWTO.txt that =
I find
> >>> wrong (or at least misleading) compared to what DMA-API.txt descr=
ibes.
> >>> DMA sync calls do not transfer the ownership of the buffer - they=
 are
> >>> cache synchronization points, ownership passing is handled entire=
ly by
> >>> the driver.
> >> What I meant was that the DMA sync calls reflect the ownership tra=
nsfer of the memory regions. In this case ownership is transferred betw=
een device and CPU multiple times and the code reflects that.
> >>>> This is definitely required in this case, because when the retur=
n code is -EINPROGRESS, the driver waits for the hardware to complete t=
his buffer, and the next call has to fetch the memory again after the d=
evice has updated it.
> >>> Correctness of this access should be provided by sync_to_cpu() ca=
ll.
> >> At least in MIPS I'm sure it isn't. If I remember correctly, it al=
so isn't on ARM, so I'm pretty sure that either your understanding of t=
he API is incorrect, or arch code does not implement it properly. In ei=
ther case, this change (and probably also the p54 one) should not be me=
rged.
> >=20
> > I briefly looked through DMA API implementation in MIPS, and except
> > for R10k and R12k both sync_for_cpu and sync_for_device are no-ops
> > (see: arch/mips/mm/dma-default.c).  For R10k and R12k the syncs are
> > in both points, and exactly like I described before - CPU cacheline=
s
> > are invalidated for DMA_FROM_DEVICE mappings, written back for
> > DMA_TO_DEVICE, both for DMA_BIDIRECTIONAL (including redundant
> > mapping+sync direction).
> >=20
> > So doing that sync_to_device you are just invalidating the same cac=
helines
> > twice for no gain (or do nothing twice in some cases) - they are no=
t read
> > by CPU between sync_to_device -> sync_to_cpu (unless you have other=
 bugs
> > in the driver).=20
> I think you're missing something. It works like this: In the AR9380 r=
x path, the descriptor is part of the skb. The rx tasklet checks for rx=
 frame completion by calling the sync for cpu, reading the completion f=
lag and (in case of a not completed frame) flushes the cache for that l=
ocation again (for device). If you remove the for_device call, the next=
 call to this function can see stale data, as the for_cpu call can be a=
 no-op.

Is the descriptor modified in any way before being checked again? Looks=
 like
it isn't. That is my assumption - if this doesn't hold, then we're talk=
ing
about different things.

When I looked through the DMA API implementation for MIPS, I saw that w=
henever
sync_to_cpu is a no-op, sync_to_device is also a no-op. So the bug you'=
re
seeing is not related to those calls. It might be that despite no-op sy=
nc
primitives, the platform is not cache-coherent --- that is DMA writes b=
y
device do not cause corresponding CPU cache lines to be invalidated.

BTW, cache flush (other name: invalidation) is needed just before readi=
ng the
value. Doing it once more earlier does not really matter. Unless you're
modifying some data in the same cache line as mapped buffer --- then th=
is
is a BUG in the driver and should either use DMA_BIDIRECTIONAL if the m=
odified
value is part of the buffer, or move the modified data away.

Best Regards,
Micha=B3 Miros=B3aw
