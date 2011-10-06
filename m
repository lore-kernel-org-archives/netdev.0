From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 6 Oct 2011 17:00:22 +0100
Message-ID: <1317916822.21903.252.camel@zakaz.uk.xensource.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
	 <1317810532-24984-1-git-send-email-ian.campbell@citrix.com>
	 <CAHXqBFKX5eojLMhT1MW1inAUH9cfVne4-rhDQYSLsUh-OTzuPQ@mail.gmail.com>
	 <1317884756.24742.13.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Mason <jdmason@kudzu.us>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:8724 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964856Ab1JFQAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 12:00:24 -0400
In-Reply-To: <1317884756.24742.13.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 08:05 +0100, Ian Campbell wrote:
> On Wed, 2011-10-05 at 22:03 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> > 2011/10/5 Ian Campbell <ian.campbell@citrix.com>:
> > [...]
> > > --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> > > +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> > > @@ -923,9 +923,9 @@ vxge_xmit(struct sk_buff *skb, struct net_dev=
ice *dev)
> > >                if (!frag->size)
> > >                        continue;
> > >
> > > -               dma_pointer =3D (u64) pci_map_page(fifo->pdev, fr=
ag->page,
> > > -                               frag->page_offset, frag->size,
> > > -                               PCI_DMA_TODEVICE);
> > > +               dma_pointer =3D (u64)skb_frag_dma_map(&fifo->pdev=
->dev, frag,
> > > +                                                   0, frag->size=
,
> > > +                                                   PCI_DMA_TODEV=
ICE);
> >=20
> > This should be DMA_TO_DEVICE instead of PCI_DMA_TODEVICE.
> >=20
> > >
> > >                if (unlikely(pci_dma_mapping_error(fifo->pdev, dma=
_pointer)))
> > >                        goto _exit2;
> >=20
> > I would also change this to dma_mapping_error() in one go.
> >=20
> > Just a random patch check.
>=20
> Thanks Micha=C5=82.
>=20
> I'm sure I must have made the same mistakes in a whole bunch of patch=
es
> which have already been applied. I'll knock up a fixup patch.

Here it is. David, if you want N separate patches (or a git pull
request?) let me know.

8<---------------------------------------------

=46rom 755028af197868cc63ac71248742b3bc3eefaf37 Mon Sep 17 00:00:00 200=
1
=46rom: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 6 Oct 2011 11:10:48 +0100
Subject: [PATCH] net: use DMA_x_DEVICE and dma_mapping_error with skb_f=
rag_dma_map

When I converted some drivers from pci_map_page to skb_frag_dma_map I
neglected to convert PCI_DMA_xDEVICE into DMA_x_DEVICE and
pci_dma_mapping_error into dma_mapping_error.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/infiniband/hw/amso1100/c2.c                |    3 +--
 drivers/infiniband/hw/nes/nes_nic.c                |    4 ++--
 drivers/net/ethernet/alteon/acenic.c               |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    4 ++--
 drivers/net/ethernet/chelsio/cxgb/sge.c            |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/sge.c           |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |    4 ++--
 drivers/net/ethernet/marvell/skge.c                |    2 +-
 drivers/net/ethernet/marvell/sky2.c                |    8 ++++----
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    2 +-
 drivers/net/ethernet/natsemi/ns83820.c             |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    4 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    4 ++--
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    4 ++--
 drivers/net/ethernet/qlogic/qla3xxx.c              |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    4 ++--
 drivers/net/ethernet/sfc/tx.c                      |    6 +++---
 drivers/net/ethernet/sun/cassini.c                 |    2 +-
 drivers/net/ethernet/sun/sungem.c                  |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    2 +-
 drivers/staging/et131x/et1310_tx.c                 |    2 +-
 29 files changed, 43 insertions(+), 44 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2.c b/drivers/infiniband/h=
w/amso1100/c2.c
index 6a8f36e..6e85a75 100644
--- a/drivers/infiniband/hw/amso1100/c2.c
+++ b/drivers/infiniband/hw/amso1100/c2.c
@@ -803,8 +803,7 @@ static int c2_xmit_frame(struct sk_buff *skb, struc=
t net_device *netdev)
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
 			maplen =3D frag->size;
 			mapaddr =3D skb_frag_dma_map(&c2dev->pcidev->dev, frag,
-						   0, maplen,
-						   PCI_DMA_TODEVICE);
+						   0, maplen, DMA_TO_DEVICE);
 			elem =3D elem->next;
 			elem->skb =3D NULL;
 			elem->mapaddr =3D mapaddr;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index 96cb35a..7cb7f29 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -445,7 +445,7 @@ static int nes_nic_send(struct sk_buff *skb, struct=
 net_device *netdev)
 				&skb_shinfo(skb)->frags[skb_fragment_index];
 			bus_address =3D skb_frag_dma_map(&nesdev->pcidev->dev,
 						       frag, 0, frag->size,
-						       PCI_DMA_TODEVICE);
+						       DMA_TO_DEVICE);
 			wqe_fragment_length[wqe_fragment_index] =3D
 					cpu_to_le16(skb_shinfo(skb)->frags[skb_fragment_index].size);
 			set_wqe_64bit_value(nic_sqe->wqe_words, NES_NIC_SQ_WQE_FRAG0_LOW_ID=
X+(2*wqe_fragment_index),
@@ -566,7 +566,7 @@ tso_sq_no_longer_full:
 				tso_bus_address[tso_frag_count] =3D
 					skb_frag_dma_map(&nesdev->pcidev->dev,
 							 frag, 0, frag->size,
-							 PCI_DMA_TODEVICE);
+							 DMA_TO_DEVICE);
 			}
=20
 			tso_frag_index =3D 0;
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/etherne=
t/alteon/acenic.c
index 8794cf8..b1a4e82 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -2487,7 +2487,7 @@ restart:
=20
 			mapping =3D skb_frag_dma_map(&ap->pdev->dev, frag, 0,
 						   frag->size,
-						   PCI_DMA_TODEVICE);
+						   DMA_TO_DEVICE);
=20
 			flagsize =3D (frag->size << 16);
 			if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/=
net/ethernet/atheros/atl1c/atl1c_main.c
index 2b9f925..12a0b30 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2183,7 +2183,7 @@ static void atl1c_tx_map(struct atl1c_adapter *ad=
apter,
 		buffer_info->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
 						    frag, 0,
 						    buffer_info->length,
-						    PCI_DMA_TODEVICE);
+						    DMA_TO_DEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE,
 			ATL1C_PCIMAP_TODEVICE);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/=
net/ethernet/atheros/atl1e/atl1e_main.c
index 7e27eb3..97c45a4b 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1769,7 +1769,7 @@ static void atl1e_tx_map(struct atl1e_adapter *ad=
apter,
 							  frag,
 							  (i * MAX_TX_BUF_LEN),
 							  tx_buffer->length,
-							  PCI_DMA_TODEVICE);
+							  DMA_TO_DEVICE);
 			ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_PAGE);
 			use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);
 			use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/eth=
ernet/atheros/atlx/atl1.c
index edf826a..43511ab 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2285,7 +2285,7 @@ static void atl1_tx_map(struct atl1_adapter *adap=
ter, struct sk_buff *skb,
 			buf_len -=3D buffer_info->length;
 			buffer_info->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
 				frag, i * ATL1_MAX_TX_BUF_LEN,
-				buffer_info->length, PCI_DMA_TODEVICE);
+				buffer_info->length, DMA_TO_DEVICE);
=20
 			if (++next_to_use =3D=3D tpd_ring->count)
 				next_to_use =3D 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/etherne=
t/broadcom/bnx2.c
index 21bdda3..ad24d8c 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6539,7 +6539,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
=20
 		len =3D frag->size;
 		mapping =3D skb_frag_dma_map(&bp->pdev->dev, frag, 0, len,
-					   PCI_DMA_TODEVICE);
+					   DMA_TO_DEVICE);
 		if (dma_mapping_error(&bp->pdev->dev, mapping))
 			goto dma_error;
 		dma_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index 26c6bd4..3abcb4d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6779,12 +6779,12 @@ static netdev_tx_t tg3_start_xmit(struct sk_buf=
f *skb, struct net_device *dev)
=20
 			len =3D frag->size;
 			mapping =3D skb_frag_dma_map(&tp->pdev->dev, frag, 0,
-						   len, PCI_DMA_TODEVICE);
+						   len, DMA_TO_DEVICE);
=20
 			tnapi->tx_buffers[entry].skb =3D NULL;
 			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
 					   mapping);
-			if (pci_dma_mapping_error(tp->pdev, mapping))
+			if (dma_mapping_error(tp->pdev, mapping))
 				goto dma_error;
=20
 			if (tg3_tx_frag_set(tnapi, &entry, &budget, mapping,
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethe=
rnet/chelsio/cxgb/sge.c
index 7cde425..0a511c4a 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -1278,7 +1278,7 @@ static inline void write_tx_descs(struct adapter =
*adapter, struct sk_buff *skb,
 		}
=20
 		mapping =3D skb_frag_dma_map(&adapter->pdev->dev, frag, 0,
-					   frag->size, PCI_DMA_TODEVICE);
+					   frag->size, DMA_TO_DEVICE);
 		desc_mapping =3D mapping;
 		desc_len =3D frag->size;
=20
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/eth=
ernet/chelsio/cxgb3/sge.c
index a0baaa0..2f46b37 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -980,7 +980,7 @@ static inline unsigned int make_sgl(const struct sk=
_buff *skb,
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 		mapping =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
-					   PCI_DMA_TODEVICE);
+					   DMA_TO_DEVICE);
 		sgp->len[j] =3D cpu_to_be32(frag->size);
 		sgp->addr[j] =3D cpu_to_be64(mapping);
 		j ^=3D 1;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/=
ethernet/cisco/enic/enic_main.c
index aeab6cd..1bc908f 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -607,7 +607,7 @@ static inline void enic_queue_wq_skb_cont(struct en=
ic *enic,
 		enic_queue_wq_desc_cont(wq, skb,
 			skb_frag_dma_map(&enic->pdev->dev,
 					 frag, 0, frag->size,
-					 PCI_DMA_TODEVICE),
+					 DMA_TO_DEVICE),
 			frag->size,
 			(len_left =3D=3D 0),	/* EOP? */
 			loopback);
@@ -726,7 +726,7 @@ static inline void enic_queue_wq_skb_tso(struct eni=
c *enic,
 				(unsigned int)WQ_ENET_MAX_DESC_LEN);
 			dma_addr =3D skb_frag_dma_map(&enic->pdev->dev, frag,
 						    offset, len,
-						    PCI_DMA_TODEVICE);
+						    DMA_TO_DEVICE);
 			enic_queue_wq_desc_cont(wq, skb,
 				dma_addr,
 				len,
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet=
/marvell/skge.c
index a0a6471..32db4c8 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2777,7 +2777,7 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff=
 *skb,
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 			map =3D skb_frag_dma_map(&hw->pdev->dev, frag, 0,
-					       frag->size, PCI_DMA_TODEVICE);
+					       frag->size, DMA_TO_DEVICE);
=20
 			e =3D e->next;
 			e->skb =3D skb;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet=
/marvell/sky2.c
index 338b10c..7baff3e 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1229,9 +1229,9 @@ static int sky2_rx_map_skb(struct pci_dev *pdev, =
struct rx_ring_info *re,
=20
 		re->frag_addr[i] =3D skb_frag_dma_map(&pdev->dev, frag, 0,
 						    frag->size,
-						    PCI_DMA_FROMDEVICE);
+						    DMA_FROM_DEVICE);
=20
-		if (pci_dma_mapping_error(pdev, re->frag_addr[i]))
+		if (dma_mapping_error(pdev, re->frag_addr[i]))
 			goto map_page_error;
 	}
 	return 0;
@@ -1936,9 +1936,9 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff=
 *skb,
 		const skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 		mapping =3D skb_frag_dma_map(&hw->pdev->dev, frag, 0,
-					   frag->size, PCI_DMA_TODEVICE);
+					   frag->size, DMA_TO_DEVICE);
=20
-		if (pci_dma_mapping_error(hw->pdev, mapping))
+		if (dma_mapping_error(hw->pdev, mapping))
 			goto mapping_unwind;
=20
 		upper =3D upper_32_bits(mapping);
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers=
/net/ethernet/myricom/myri10ge/myri10ge.c
index 8bf6034..2663727 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -2928,7 +2928,7 @@ again:
 		frag_idx++;
 		len =3D frag->size;
 		bus =3D skb_frag_dma_map(&mgp->pdev->dev, frag, 0, len,
-				       PCI_DMA_TODEVICE);
+				       DMA_TO_DEVICE);
 		dma_unmap_addr_set(&tx->info[idx], bus, bus);
 		dma_unmap_len_set(&tx->info[idx], len, len);
 	}
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ether=
net/natsemi/ns83820.c
index e0895e4..73616b9 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1161,7 +1161,7 @@ again:
 			break;
=20
 		buf =3D skb_frag_dma_map(&dev->pci_dev->dev, frag, 0,
-				       frag->size, PCI_DMA_TODEVICE);
+				       frag->size, DMA_TO_DEVICE);
 		dprintk("frag: buf=3D%08Lx  page=3D%08lx offset=3D%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/etherne=
t/neterion/s2io.c
index ef5b825..4ec7e3f 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -4193,7 +4193,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb,=
 struct net_device *dev)
 		txdp->Buffer_Pointer =3D (u64)skb_frag_dma_map(&sp->pdev->dev,
 							     frag, 0,
 							     frag->size,
-							     PCI_DMA_TODEVICE);
+							     DMA_TO_DEVICE);
 		txdp->Control_1 =3D TXD_BUFFER0_SIZE(frag->size);
 		if (offload_type =3D=3D SKB_GSO_UDP)
 			txdp->Control_1 |=3D TXD_UFO_EN;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethe=
rnet/nvidia/forcedeth.c
index 4e39b8c..84baa59 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -2150,7 +2150,7 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *=
skb, struct net_device *dev)
 							&np->pci_dev->dev,
 							frag, offset,
 							bcnt,
-							PCI_DMA_TODEVICE);
+							DMA_TO_DEVICE);
 			np->put_tx_ctx->dma_len =3D bcnt;
 			np->put_tx_ctx->dma_single =3D 0;
 			put_tx->buf =3D cpu_to_le32(np->put_tx_ctx->dma);
@@ -2264,7 +2264,7 @@ static netdev_tx_t nv_start_xmit_optimized(struct=
 sk_buff *skb,
 							&np->pci_dev->dev,
 							frag, offset,
 							bcnt,
-							PCI_DMA_TODEVICE);
+							DMA_TO_DEVICE);
 			np->put_tx_ctx->dma_len =3D bcnt;
 			np->put_tx_ctx->dma_single =3D 0;
 			put_tx->bufhigh =3D cpu_to_le32(dma_high(np->put_tx_ctx->dma));
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/eth=
ernet/pasemi/pasemi_mac.c
index 5322095..d247030 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1506,9 +1506,9 @@ static int pasemi_mac_start_tx(struct sk_buff *sk=
b, struct net_device *dev)
 		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 		map[i + 1] =3D skb_frag_dma_map(&mac->dma_pdev->dev, frag, 0,
-					      frag->size, PCI_DMA_TODEVICE);
+					      frag->size, DMA_TO_DEVICE);
 		map_size[i+1] =3D frag->size;
-		if (pci_dma_mapping_error(mac->dma_pdev, map[i+1])) {
+		if (dma_mapping_error(mac->dma_pdev, map[i + 1])) {
 			nfrags =3D i;
 			goto out_err_nolock;
 		}
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/dri=
vers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index dc9e21a..b061c07 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1906,8 +1906,8 @@ netxen_map_tx_skb(struct pci_dev *pdev,
 		nf =3D &pbuf->frag_array[i+1];
=20
 		map =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
-				       PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, map))
+				       DMA_TO_DEVICE);
+		if (dma_mapping_error(pdev, map))
 			goto unwind;
=20
 		nf->dma =3D map;
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethern=
et/qlogic/qla3xxx.c
index 1871d88..8932265 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2389,9 +2389,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 		}
=20
 		map =3D skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
-				       PCI_DMA_TODEVICE);
+				       DMA_TO_DEVICE);
=20
-		err =3D pci_dma_mapping_error(qdev->pdev, map);
+		err =3D dma_mapping_error(qdev->pdev, map);
 		if (err) {
 			netdev_err(qdev->ndev,
 				   "PCI mapping frags failed with error: %d\n",
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers=
/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 445956e..c9756e7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2136,8 +2136,8 @@ qlcnic_map_tx_skb(struct pci_dev *pdev,
 		nf =3D &pbuf->frag_array[i+1];
=20
 		map =3D skb_frag_dma_map(&pdev->dev, frag, 0, frag->size,
-				       PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, map))
+				       DMA_TO_DEVICE);
+		if (dma_mapping_error(pdev, map))
 			goto unwind;
=20
 		nf->dma =3D map;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net=
/ethernet/qlogic/qlge/qlge_main.c
index ce6c6fe..094ac22 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1432,9 +1432,9 @@ static int ql_map_send(struct ql_adapter *qdev,
 		}
=20
 		map =3D skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
-				       PCI_DMA_TODEVICE);
+				       DMA_TO_DEVICE);
=20
-		err =3D pci_dma_mapping_error(qdev->pdev, map);
+		err =3D dma_mapping_error(qdev->pdev, map);
 		if (err) {
 			netif_err(qdev, tx_queued, qdev->ndev,
 				  "PCI mapping frags failed with error: %d.\n",
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/t=
x.c
index f2467a1..7f47efc 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -243,7 +243,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx=
_queue, struct sk_buff *skb)
 		/* Map for DMA */
 		unmap_single =3D false;
 		dma_addr =3D skb_frag_dma_map(&pci_dev->dev, fragment, 0, len,
-					    PCI_DMA_TODEVICE);
+					    DMA_TO_DEVICE);
 	}
=20
 	/* Transfer ownership of the skb to the final buffer */
@@ -926,8 +926,8 @@ static int tso_get_fragment(struct tso_state *st, s=
truct efx_nic *efx,
 			    skb_frag_t *frag)
 {
 	st->unmap_addr =3D skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
-					  frag->size, PCI_DMA_TODEVICE);
-	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+					  frag->size, DMA_TO_DEVICE);
+	if (likely(!dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
 		st->unmap_single =3D false;
 		st->unmap_len =3D frag->size;
 		st->in_len =3D frag->size;
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/=
sun/cassini.c
index 1206821..d9460d8 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -2830,7 +2830,7 @@ static inline int cas_xmit_tx_ringN(struct cas *c=
p, int ring,
=20
 		len =3D fragp->size;
 		mapping =3D skb_frag_dma_map(&cp->pdev->dev, fragp, 0, len,
-					   PCI_DMA_TODEVICE);
+					   DMA_TO_DEVICE);
=20
 		tabort =3D cas_calc_tabort(cp, fragp->page_offset, len);
 		if (unlikely(tabort)) {
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/s=
un/sungem.c
index 2bfa171..6b62a73 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1072,7 +1072,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff =
*skb,
=20
 			len =3D this_frag->size;
 			mapping =3D skb_frag_dma_map(&gp->pdev->dev, this_frag,
-						   0, len, PCI_DMA_TODEVICE);
+						   0, len, DMA_TO_DEVICE);
 			this_ctrl =3D ctrl;
 			if (frag =3D=3D skb_shinfo(skb)->nr_frags - 1)
 				this_ctrl |=3D TXDCTRL_EOF;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/etherne=
t/tehuti/tehuti.c
index 1151cf9..c77e3bf 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1499,7 +1499,7 @@ bdx_tx_map_skb(struct bdx_priv *priv, struct sk_b=
uff *skb,
 		db->wptr->len =3D frag->size;
 		db->wptr->addr.dma =3D skb_frag_dma_map(&priv->pdev->dev, frag,
 						      0, frag->size,
-						      PCI_DMA_TODEVICE);
+						      DMA_TO_DEVICE);
=20
 		pbl++;
 		pbl->len =3D CPU_CHIP_SWAP32(db->wptr->len);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethe=
rnet/via/via-velocity.c
index 1ec32c4..b47bce1 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2559,7 +2559,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *=
skb,
 		tdinfo->skb_dma[i + 1] =3D skb_frag_dma_map(&vptr->pdev->dev,
 							  frag, 0,
 							  frag->size,
-							  PCI_DMA_TODEVICE);
+							  DMA_TO_DEVICE);
=20
 		td_ptr->td_buf[i + 1].pa_low =3D cpu_to_le32(tdinfo->skb_dma[i + 1])=
;
 		td_ptr->td_buf[i + 1].pa_high =3D 0;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vm=
xnet3_drv.c
index 57e7c66..1694038 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -750,7 +750,7 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3=
_tx_ctx *ctx,
 		tbi->map_type =3D VMXNET3_MAP_PAGE;
 		tbi->dma_addr =3D skb_frag_dma_map(&adapter->pdev->dev, frag,
 						 0, frag->size,
-						 PCI_DMA_TODEVICE);
+						 DMA_TO_DEVICE);
=20
 		tbi->len =3D frag->size;
=20
diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131=
x/et1310_tx.c
index 03e7a4e..e4f51e6 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -524,7 +524,7 @@ static int nic_send_packet(struct et131x_adapter *e=
tdev, struct tcb *tcb)
 							&frags[i - 1],
 							0,
 							frags[i - 1].size,
-							PCI_DMA_TODEVICE);
+							DMA_TO_DEVICE);
 		}
 	}
=20
--=20
1.7.2.5
