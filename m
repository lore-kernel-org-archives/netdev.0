From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Mon, 15 Dec 2014 18:04:30 +0000
Message-ID: <20141215180430.GK11285@n2100.arm.linux.org.uk>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
 <20141211.151055.817876561546126576.davem@davemloft.net>
 <20141211202507.GS11285@n2100.arm.linux.org.uk>
 <20141211.152756.1471877201690056873.davem@davemloft.net>
 <BLUPR03MB37339496B52755D0F32B002F5600@BLUPR03MB373.namprd03.prod.outlook.com>
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
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:60242 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750772AbaLOSEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 13:04:44 -0500
Content-Disposition: inline
In-Reply-To: <BLUPR03MB37339496B52755D0F32B002F5600@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 05:34:01AM +0000, fugang.duan@freescale.com wro=
te:
> I will submit one patch to fix the issue.

There's more bugs in the FEC driver... here's the relevant bits:

static void
fec_enet_tx_queue(struct net_device *ndev, u16 queue_id)
{
        bdp =3D txq->dirty_tx;

        bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_id);

        while (((status =3D bdp->cbd_sc) & BD_ENET_TX_READY) =3D=3D 0) =
{
                /* current queue is empty */
                if (bdp =3D=3D txq->cur_tx)
                        break;

                skb =3D txq->tx_skbuff[index];
                txq->tx_skbuff[index] =3D NULL;
                if (!IS_TSO_HEADER(txq, bdp->cbd_bufaddr))
                        dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufa=
ddr,
                                        bdp->cbd_datlen, DMA_TO_DEVICE)=
;
                bdp->cbd_bufaddr =3D 0;
                if (!skb) {
                        bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_i=
d);
                        continue;
                }
=2E..
                txq->dirty_tx =3D bdp;
                bdp =3D fec_enet_get_nextdesc(bdp, fep, queue_id);
        }

Consider the following code path:
- we enter this function
- get the dirty_tx pointer
- move to the next descriptor (which we'll call descriptor A)
- next descriptor indicates that TX_READY =3D 0
- bdp !=3D txq->cur_tx
- we unmap if needed
- we set bdp->cmdbufaddr =3D 0
- assume skb is NULL, so we move to the next descriptor (we'll call thi=
s B)
- next descriptor _may_ have TX_READY =3D 1
- we break out of the loop, and return

Some time later, we re-enter:
- get the dirty_tx pointer
- move to the next descriptor (which is descriptor A above)
- next descriptor indicates that TX_READY =3D 0
- bdp !=3D txq->cur_tx
- we call dma_unmap_single(..., bdp->cbd_bufaddr, which we previously z=
eroed
  - the DMA API debugging complains that FEC is unmapping memory which =
it
    doesn't own

Unfortunately, this does appear to happen - from a paste from Jon
Nettleton from iMX6Q:

 32.=A0[ =A0 45.033001] unmapping this address 0x0 size 66
 33.=A0[ =A0 45.037470] ------------[ cut here ]------------
 34.=A0[ =A0 45.042127] WARNING: CPU: 0 PID: 102 at lib/dma-debug.c:108=
0 check_unmap+0x784/0x9f4()
 35.=A0[ =A0 45.050066] fec 2188000.ethernet: DMA-API: device driver tr=
ies to free DMA memory it has not a]

(where the printk at line 32 is something that was added to debug this.=
)

The sad thing is that the remainder of my FEC patches did go a long way
to clean up these kinds of issues in the driver (and there's /many/ of
them), but unfortunately other conflicting changes got merged before I
could finish rebasing them, I decided to move on to other things and
discard the remainder of my patch set.  Marek showed some interest in
taking the patch set over, but I've not heard anything more - and I'm
not about to resurect my efforts only to get into the same situation
where I'm carrying 50 odd patches which I can't merge back into mainlin=
e
without spending weeks endlessly rebasing them.

--=20
=46TTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
