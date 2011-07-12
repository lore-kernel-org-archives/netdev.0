From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA
 API usage
Date: Tue, 12 Jul 2011 17:58:49 +0200
Message-ID: <20110712155849.GB10651@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl>
 <4E1BCF36.2010506@openwrt.org>
 <20110712095541.GA6236@rere.qmqm.pl>
 <B4765EFC-B5C9-4E2D-BE00-ED5519D13A4E@nbd.name>
 <20110712130316.GA8621@rere.qmqm.pl>
 <EC2F82D7-9206-4139-9539-F5DDE38A5629@nbd.name>
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
Received: from rere.qmqm.pl ([89.167.52.164]:48743 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753704Ab1GLP6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 11:58:50 -0400
Content-Disposition: inline
In-Reply-To: <EC2F82D7-9206-4139-9539-F5DDE38A5629@nbd.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 10:21:05PM +0800, Felix Fietkau wrote:
> On 12.07.2011, at 21:03, Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl=
> wrote:
>=20
> > On Tue, Jul 12, 2011 at 08:54:32PM +0800, Felix Fietkau wrote:
> >> On 12.07.2011, at 17:55, Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm=
=2Epl> wrote:
> >>=20
> >>> On Tue, Jul 12, 2011 at 12:36:06PM +0800, Felix Fietkau wrote:
> >>>> On 2011-07-11 8:52 AM, Micha=B3 Miros=B3aw wrote:
> >>>>> Also constify buf_addr for ath9k_hw_process_rxdesc_edma() to ve=
rify
> >>>>> assumptions --- dma_sync_single_for_device() call can be remove=
d.
> >>>>>=20
> >>>>> Signed-off-by: Micha=B3 Miros=B3aw<mirq-linux@rere.qmqm.pl>
> >>>>> ---
> >>>>> drivers/net/wireless/ath/ath9k/ar9003_mac.c |    4 ++--
> >>>>> drivers/net/wireless/ath/ath9k/ar9003_mac.h |    2 +-
> >>>>> drivers/net/wireless/ath/ath9k/recv.c       |   10 +++-------
> >>>>> 3 files changed, 6 insertions(+), 10 deletions(-)
> >>>>>=20
> >>>>> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/ne=
t/wireless/ath/ath9k/recv.c
> >>>>> index 70dc8ec..c5f46d5 100644
> >>>>> --- a/drivers/net/wireless/ath/ath9k/recv.c
> >>>>> +++ b/drivers/net/wireless/ath/ath9k/recv.c
> >>>>> @@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct a=
th_softc *sc,
> >>>>>   BUG_ON(!bf);
> >>>>>=20
> >>>>>   dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
> >>>>> -                common->rx_bufsize, DMA_FROM_DEVICE);
> >>>>> +                common->rx_bufsize, DMA_BIDIRECTIONAL);
> >>>>>=20
> >>>>>   ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
> >>>>> -    if (ret =3D=3D -EINPROGRESS) {
> >>>>> -        /*let device gain the buffer again*/
> >>>>> -        dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
> >>>>> -                common->rx_bufsize, DMA_FROM_DEVICE);
> >>>>> +    if (ret =3D=3D -EINPROGRESS)
> >>>>>       return false;
> >>>>> -    }
> >>>>>=20
> >>>>>   __skb_unlink(skb,&rx_edma->rx_fifo);
> >>>>>   if (ret =3D=3D -EINVAL) {
> >>>> I have strong doubts about this change. On most MIPS devices,
> >>>> dma_sync_single_for_cpu is a no-op, whereas
> >>>> dma_sync_single_for_device flushes the cache range. With this
> >>>> change, the CPU could cache the DMA status part behind skb->data=
 and
> >>>> that cache entry would not be flushed inbetween calls to this
> >>>> functions on the same buffer, likely leading to rx stalls.
> >>> You're suggesting a platform implementation bug then. If the plat=
form is not
> >>> cache-coherent, it should invalidate relevant CPU cache lines for=
 sync_to_cpu
> >>> and unmap cases. Do other devices show such symptoms on MIPS syst=
ems?
> >>>=20
> >>> I'm not familiar with the platform internals, so we should ask MI=
PS people.
> >> I only mentioned MIPS to describe the potential side effect of thi=
s change. From my current understanding of the DMA API, it would be wro=
ng on other platforms as well. I believe the _for_device function needs=
 to be used to transfer ownership of the buffer back to the device, bef=
ore calling _for_cpu again later for another read.
> > What you're saying reminds the wording in DMA-API-HOWTO.txt that I =
find
> > wrong (or at least misleading) compared to what DMA-API.txt describ=
es.
> > DMA sync calls do not transfer the ownership of the buffer - they a=
re
> > cache synchronization points, ownership passing is handled entirely=
 by
> > the driver.
> What I meant was that the DMA sync calls reflect the ownership transf=
er of the memory regions. In this case ownership is transferred between=
 device and CPU multiple times and the code reflects that.
> >> This is definitely required in this case, because when the return =
code is -EINPROGRESS, the driver waits for the hardware to complete thi=
s buffer, and the next call has to fetch the memory again after the dev=
ice has updated it.
> > Correctness of this access should be provided by sync_to_cpu() call=
=2E
> At least in MIPS I'm sure it isn't. If I remember correctly, it also =
isn't on ARM, so I'm pretty sure that either your understanding of the =
API is incorrect, or arch code does not implement it properly. In eithe=
r case, this change (and probably also the p54 one) should not be merge=
d.

I briefly looked through DMA API implementation in MIPS, and except
for R10k and R12k both sync_for_cpu and sync_for_device are no-ops
(see: arch/mips/mm/dma-default.c).  For R10k and R12k the syncs are
in both points, and exactly like I described before - CPU cachelines
are invalidated for DMA_FROM_DEVICE mappings, written back for
DMA_TO_DEVICE, both for DMA_BIDIRECTIONAL (including redundant
mapping+sync direction).

So doing that sync_to_device you are just invalidating the same cacheli=
nes
twice for no gain (or do nothing twice in some cases) - they are not re=
ad
by CPU between sync_to_device -> sync_to_cpu (unless you have other bug=
s
in the driver).=20

Best Regards,
Micha=B3 Miros=B3aw
