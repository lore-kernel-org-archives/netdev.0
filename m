From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Tue, 16 Dec 2014 10:57:08 +0000
Message-ID: <20141216105707.GO11285@n2100.arm.linux.org.uk>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
 <20141211.151055.817876561546126576.davem@davemloft.net>
 <20141211202507.GS11285@n2100.arm.linux.org.uk>
 <20141211.152756.1471877201690056873.davem@davemloft.net>
 <BLUPR03MB37339496B52755D0F32B002F5600@BLUPR03MB373.namprd03.prod.outlook.com>
 <20141215180430.GK11285@n2100.arm.linux.org.uk>
 <BLUPR03MB37305CF1F6797329BD9B183F56C0@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:33529 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751326AbaLPK5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 05:57:22 -0500
Content-Disposition: inline
In-Reply-To: <BLUPR03MB37305CF1F6797329BD9B183F56C0@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 02:19:38AM +0000, fugang.duan@freescale.com wro=
te:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk> Sent: Tuesday=
, December 16, 2014 2:05 AM
> > To: Duan Fugang-B38611
> > Cc: David Miller; Estevam Fabio-R49496; ezequiel.garcia@free-
> > electrons.com; netdev@vger.kernel.org
> > Subject: Re: Bug: mv643xxx fails with highmem
> >=20
> > On Fri, Dec 12, 2014 at 05:34:01AM +0000, fugang.duan@freescale.com=
 wrote:
> > > I will submit one patch to fix the issue.
> >=20
> > There's more bugs in the FEC driver... here's the relevant bits:
> >=20
> > static void
> > fec_enet_tx_queue(struct net_device *ndev, u16 queue_id) {
> >         bdp =3D txq->dirty_tx;
> >=20
> >         bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_id);
> >=20
> >         while (((status =3D bdp->cbd_sc) & BD_ENET_TX_READY) =3D=3D=
 0) {
> >                 /* current queue is empty */
> >                 if (bdp =3D=3D txq->cur_tx)
> >                         break;
> >=20
> >                 skb =3D txq->tx_skbuff[index];
> >                 txq->tx_skbuff[index] =3D NULL;
> >                 if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
> >                         dma_unmap_single(&fep->pdev->dev, bdp-
> > >cbd_bufaddr,
> >                                         bdp->cbd_datlen, DMA_TO_DEV=
ICE);
> >                 bdp->cbd_bufaddr =3D 0;
> >                 if (!skb) {
> >                         bdp =3D fec_enet_get_nextdesc(bdp, fep, que=
ue_id);
> >                         continue;
> >                 }
> > ...
> >                 txq->dirty_tx =3D bdp;
> >                 bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_id);
> >         }
> >=20
> > Consider the following code path:
> > - we enter this function
> > - get the dirty_tx pointer
> > - move to the next descriptor (which we'll call descriptor A)
> > - next descriptor indicates that TX_READY =3D 0
> > - bdp !=3D txq->cur_tx
> > - we unmap if needed
> > - we set bdp->cmdbufaddr =3D 0
> > - assume skb is NULL, so we move to the next descriptor (we'll call=
 this
> > B)
> > - next descriptor _may_ have TX_READY =3D 1
> > - we break out of the loop, and return
> >=20
> > Some time later, we re-enter:
> > - get the dirty_tx pointer
> > - move to the next descriptor (which is descriptor A above)
> > - next descriptor indicates that TX_READY =3D 0
> > - bdp !=3D txq->cur_tx
> > - we call dma_unmap_single(..., bdp->cbd_bufaddr, which we previous=
ly
> > zeroed
> >   - the DMA API debugging complains that FEC is unmapping memory wh=
ich it
> >     doesn't own
> >=20
> > Unfortunately, this does appear to happen - from a paste from Jon
> > Nettleton from iMX6Q:
> >=20
> >  32.=A0[ =A0 45.033001] unmapping this address 0x0 size 66  33.=A0[=
 =A0 45.037470]
> > ------------[ cut here ]------------  34.=A0[ =A0 45.042127] WARNIN=
G: CPU: 0
> > PID: 102 at lib/dma-debug.c:1080 check_unmap+0x784/0x9f4()
> > 35.=A0[ =A0 45.050066] fec 2188000.ethernet: DMA-API: device driver=
 tries to
> > free DMA memory it has not a]
> >=20
> > (where the printk at line 32 is something that was added to debug t=
his.)
> >=20
> > The sad thing is that the remainder of my FEC patches did go a long=
 way
> > to clean up these kinds of issues in the driver (and there's /many/=
 of
> > them), but unfortunately other conflicting changes got merged befor=
e I
> > could finish rebasing them, I decided to move on to other things an=
d
> > discard the remainder of my patch set.  Marek showed some interest =
in
> > taking the patch set over, but I've not heard anything more - and I=
'm not
> > about to resurect my efforts only to get into the same situation wh=
ere
> > I'm carrying 50 odd patches which I can't merge back into mainline
> > without spending weeks endlessly rebasing them.
> >=20
> Russell, many thanks for your effort and thanks for your pointing out=
 the bug.
> I will think one method to fix it.
>=20
> And I have one question for highmem dma mapping issue as below:
> fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq, struct s=
k_buff *skb, struct net_device *ndev)
> {
> 	...
> 		    bufaddr =3D page_address(this_frag->page.p) + this_frag->page_o=
ffset;
>=20
>                 index =3D fec_enet_get_bd_index(txq->tx_bd_base, bdp,=
 fep);
>                 if (((unsigned long) bufaddr) & fep->tx_align ||
>                         fep->quirks & FEC_QUIRK_SWAP_FRAME) {
>                         memcpy(txq->tx_bounce[index], bufaddr, frag_l=
en);
>                         bufaddr =3D txq->tx_bounce[index];
>=20
>                         if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
>                                 swap_buffer(bufaddr, frag_len);
>                 }
>=20
>                 addr =3D dma_map_single(&fep->pdev->dev, bufaddr, fra=
g_len,
>                                       DMA_TO_DEVICE);
>                 if (dma_mapping_error(&fep->pdev->dev, addr)) {
>                         dev_kfree_skb_any(skb);
>                         if (net_ratelimit())
>                                 netdev_err(ndev, "Tx DMA memory map f=
ailed\n");
>                         goto dma_mapping_error;
>                 }
> 	...
> }
>
> If the frag page is located at high memory, use dma_map_single() is n=
ot
> right, must use skb_frag_dma_map() or dma_map_page().

Correct.

> But before mapping, if tx has buffer alignment limitation (tx_align i=
s
> not zero), there need to do memcpy for buffer alignment.

Right, and that can be detected by simply checking this_frag->page_offs=
et
as we know that a page address is always aligned to a page.

> So, there we need to check whether the page is in highmem, if so, we
> need to call kmap_atomic() or kmap_high_get() to get cpu address,
> And then do memcpy or swap buffer operation.

Yes - you'd need to do something like this:

	if (this_frag->page_offset & fep->tx_align ||
	    fep->quirks & FEC_QUIRK_SWAP_FRAME) {
		bufaddr =3D kmap_atomic(this_frag->page.p) + this_frag->page_offset;
		memcpy(txq->tx_bounce[index], bufaddr, frag_len);
		kunmap_atomic(bufaddr);

		bufaddr =3D txq->tx_bounce[index];
		if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
			swap_buffer(bufaddr, frag_len);
                addr =3D dma_map_single(&fep->pdev->dev, bufaddr, frag_=
len,
                                      DMA_TO_DEVICE);
	} else {
		addr =3D skb_frag_dma_map(&fep->pdev->dev, this_frag, 0,
					frag_len, DMA_TO_DEVICE);
	}

	if (dma_mapping_error(&fep->pdev->dev, addr)) {
		dev_kfree_skb_any(skb);
		if (net_ratelimit())
			netdev_err(ndev, "Tx DMA memory map failed\n");
		goto dma_mapping_error;
	}

You'll also need to record whether you should use dma_unmap_page() or
dma_unmap_single().

--=20
=46TTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
