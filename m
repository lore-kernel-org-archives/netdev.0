From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 22:08:30 +0100
Message-ID: <1317935310.24742.18.camel@dagon.hellion.org.uk>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
	 <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
	 <CAHXqBFKX5eojLMhT1MW1inAUH9cfVne4-rhDQYSLsUh-OTzuPQ@mail.gmail.com>
	 <1317884756.24742.13.camel@dagon.hellion.org.uk>
	 <1317916822.21903.252.camel@zakaz.uk.xensource.com>
	 <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Mason <jdmason@kudzu.us>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:13326 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759174Ab1JFVId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:08:33 -0400
In-Reply-To: <CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 21:45 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> W dniu 6 pa=C5=BAdziernika 2011 18:00 u=C5=BCytkownik Ian Campbell
> <Ian.Campbell@citrix.com> napisa=C5=82:
> > On Thu, 2011-10-06 at 08:05 +0100, Ian Campbell wrote:
> >> On Wed, 2011-10-05 at 22:03 +0100, Micha=C5=82 Miros=C5=82aw wrote=
:
> >> > 2011/10/5 Ian Campbell <ian.campbell@citrix.com>:
> >> > [...]
> >> > > --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> >> > > +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> >> > > @@ -923,9 +923,9 @@ vxge_xmit(struct sk_buff *skb, struct net_=
device *dev)
> >> > >                if (!frag->size)
> >> > >                        continue;
> >> > >
> >> > > -               dma_pointer =3D (u64) pci_map_page(fifo->pdev,=
 frag->page,
> >> > > -                               frag->page_offset, frag->size,
> >> > > -                               PCI_DMA_TODEVICE);
> >> > > +               dma_pointer =3D (u64)skb_frag_dma_map(&fifo->p=
dev->dev, frag,
> >> > > +                                                   0, frag->s=
ize,
> >> > > +                                                   PCI_DMA_TO=
DEVICE);
> >> >
> >> > This should be DMA_TO_DEVICE instead of PCI_DMA_TODEVICE.
> >> > >                if (unlikely(pci_dma_mapping_error(fifo->pdev, =
dma_pointer)))
> >> > >                        goto _exit2;
> >> > I would also change this to dma_mapping_error() in one go.
> >> > Just a random patch check.
> >> Thanks Micha=C5=82.
> >> I'm sure I must have made the same mistakes in a whole bunch of pa=
tches
> >> which have already been applied. I'll knock up a fixup patch.
> > Here it is. David, if you want N separate patches (or a git pull
> > request?) let me know.
>=20
> There's a catch there, though:
>=20
> [...]
> >                        mapping =3D skb_frag_dma_map(&tp->pdev->dev,=
 frag, 0,
> > -                                                  len, PCI_DMA_TOD=
EVICE);
> > +                                                  len, DMA_TO_DEVI=
CE);
> >
> >                        tnapi->tx_buffers[entry].skb =3D NULL;
> >                        dma_unmap_addr_set(&tnapi->tx_buffers[entry]=
, mapping,
> >                                           mapping);
> > -                       if (pci_dma_mapping_error(tp->pdev, mapping=
))
> > +                       if (dma_mapping_error(tp->pdev, mapping))
>=20
> dma_mapping_error() takes struct device *, so those changes should be=
:
>=20
> dma_mapping_error(&tp->pdev->dev, mapping)
>=20
> (Like skb_frag_dma_map()'s first argument).

You are absolutely right, I've no idea how I missed the very obvious
warning this produces. Incremental patch is below, sorry about this!

8<-------------------------------------------------------

=46rom 5be2edc6eec5c66b58f4287f1d3ba3637afa7ad6 Mon Sep 17 00:00:00 200=
1
=46rom: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 6 Oct 2011 22:05:41 +0100
Subject: [PATCH] net: fix argument to dma_mapping_error after conversio=
n to skb_frag_dma_map

The recent conversion from pci_dma_mapping_error to dma_mapping_error m=
issed
the change in the exact parameter, which needs to be the struct device =
* not
the struct pci_device *.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/ethernet/broadcom/tg3.c                |    2 +-
 drivers/net/ethernet/marvell/sky2.c                |    4 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qla3xxx.c              |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    2 +-
 drivers/net/ethernet/sfc/tx.c                      |    2 +-
 8 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index 3abcb4d..9dbd1af 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6784,7 +6784,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff =
*skb, struct net_device *dev)
 			tnapi->tx_buffers[entry].skb =3D NULL;
 			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
 					   mapping);
-			if (dma_mapping_error(tp->pdev, mapping))
+			if (dma_mapping_error(&tp->pdev->dev, mapping))
 				goto dma_error;
=20
 			if (tg3_tx_frag_set(tnapi, &entry, &budget, mapping,
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet=
/marvell/sky2.c
index 7baff3e..a3ce9b6 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1231,7 +1231,7 @@ static int sky2_rx_map_skb(struct pci_dev *pdev, =
struct rx_ring_info *re,
 						    frag->size,
 						    DMA_FROM_DEVICE);
=20
-		if (dma_mapping_error(pdev, re->frag_addr[i]))
+		if (dma_mapping_error(&pdev->dev, re->frag_addr[i]))
 			goto map_page_error;
 	}
 	return 0;
@@ -1938,7 +1938,7 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff=
 *skb,
 		mapping =3D skb_frag_dma_map(&hw->pdev->dev, frag, 0,
 					   frag->size, DMA_TO_DEVICE);
=20
-		if (dma_mapping_error(hw->pdev, mapping))
+		if (dma_mapping_error(&hw->pdev->dev, mapping))
 			goto mapping_unwind;
=20
 		upper =3D upper_32_bits(mapping);
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/eth=
ernet/pasemi/pasemi_mac.c
index d247030..c6f0056 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1508,7 +1508,7 @@ static int pasemi_mac_start_tx(struct sk_buff *sk=
b, struct net_device *dev)
 		map[i + 1] =3D skb_frag_dma_map(&mac->dma_pdev->dev, frag, 0,
 					      frag->size, DMA_TO_DEVICE);
 		map_size[i+1] =3D frag->size;
-		if (dma_mapping_error(mac->dma_pdev, map[i + 1])) {
+		if (dma_mapping_error(&mac->dma_pdev->dev, map[i + 1])) {
 			nfrags =3D i;
 			goto out_err_nolock;
 		}
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/dri=
vers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index b061c07..e2ba78b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1907,7 +1907,7 @@ netxen_map_tx_skb(struct pci_dev *pdev,
=20
 		map =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
 				       DMA_TO_DEVICE);
-		if (dma_mapping_error(pdev, map))
+		if (dma_mapping_error(&pdev->dev, map))
 			goto unwind;
=20
 		nf->dma =3D map;
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethern=
et/qlogic/qla3xxx.c
index 8932265..46f9b64 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2391,7 +2391,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 		map =3D skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
 				       DMA_TO_DEVICE);
=20
-		err =3D dma_mapping_error(qdev->pdev, map);
+		err =3D dma_mapping_error(&qdev->pdev->dev, map);
 		if (err) {
 			netdev_err(qdev->ndev,
 				   "PCI mapping frags failed with error: %d\n",
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers=
/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index c9756e7..eac19e7d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2137,7 +2137,7 @@ qlcnic_map_tx_skb(struct pci_dev *pdev,
=20
 		map =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
 				       DMA_TO_DEVICE);
-		if (dma_mapping_error(pdev, map))
+		if (dma_mapping_error(&pdev->dev, map))
 			goto unwind;
=20
 		nf->dma =3D map;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net=
/ethernet/qlogic/qlge/qlge_main.c
index 094ac22..f2d9bb7 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1434,7 +1434,7 @@ static int ql_map_send(struct ql_adapter *qdev,
 		map =3D skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
 				       DMA_TO_DEVICE);
=20
-		err =3D dma_mapping_error(qdev->pdev, map);
+		err =3D dma_mapping_error(&qdev->pdev->dev, map);
 		if (err) {
 			netif_err(qdev, tx_queued, qdev->ndev,
 				  "PCI mapping frags failed with error: %d.\n",
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/t=
x.c
index 7f47efc..3964a62 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -927,7 +927,7 @@ static int tso_get_fragment(struct tso_state *st, s=
truct efx_nic *efx,
 {
 	st->unmap_addr =3D skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
 					  frag->size, DMA_TO_DEVICE);
-	if (likely(!dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
 		st->unmap_single =3D false;
 		st->unmap_len =3D frag->size;
 		st->in_len =3D frag->size;
--=20
1.7.2.5



Ian.
