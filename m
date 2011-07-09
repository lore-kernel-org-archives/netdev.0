From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH] net: clean up rx_copybreak handling
Date: Sat, 9 Jul 2011 10:54:44 +0200
Message-ID: <20110709085444.GA5522@rere.qmqm.pl>
References: <f73b8ed0717151cd2c72e5c23d275cc0de28d277.1310167326.git.mirq-linux@rere.qmqm.pl>
 <1310175469.26320.9.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42415 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab1GIIyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 04:54:47 -0400
Content-Disposition: inline
In-Reply-To: <1310175469.26320.9.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 08, 2011 at 09:37:49PM -0400, David Dillow wrote:
> On Sat, 2011-07-09 at 01:27 +0200, Micha=B3 Miros=B3aw wrote:
> > diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
>=20
> > @@ -1675,25 +1674,14 @@ typhoon_rx(struct typhoon *tp, struct basic=
_ring *rxRing, volatile __le32 * read
> > =20
> >                 pkt_len =3D le16_to_cpu(rx->frameLen);
> > =20
> > -               if(pkt_len < rx_copybreak &&
> > -                  (new_skb =3D dev_alloc_skb(pkt_len + 2)) !=3D NU=
LL) {
> > -                       skb_reserve(new_skb, 2);
> > -                       pci_dma_sync_single_for_cpu(tp->pdev, dma_a=
ddr,
> > -                                                   PKT_BUF_SZ,
> > -                                                   PCI_DMA_FROMDEV=
ICE);
> > -                       skb_copy_to_linear_data(new_skb, skb->data,=
 pkt_len);
> > -                       pci_dma_sync_single_for_device(tp->pdev, dm=
a_addr,
> > -                                                      PKT_BUF_SZ,
> > -                                                      PCI_DMA_FROM=
DEVICE);
> > -                       skb_put(new_skb, pkt_len);
> > +               new_skb =3D dev_skb_finish_rx_dma(&rxb->skb,
> > +                       pkt_len, rx_copybreak,
> > +                       &tp->pdev->dev, dma_addr, PKT_BUF_SZ);
>=20
> Needs a few more tabs in front of the arguments. It looks like
> 		new_skb =3D dev_skb_finish_rx_dma(&rxb->skb, pkt_len,
> 						rx_copybreak, &tp->pdev->dev,
> 						dma_addr, PKT_BUF_SZ);
>=20
> would fit the style around it better.
>=20
> > +               if (!rxb->skb)
> >                         typhoon_recycle_rx_skb(tp, idx);
>=20
> I think you either meant
> 		if (rxb->skb)
> 			typhoon_recycle_rx_skb(tp, idx);
>=20
> or to swap typhoon_{recycle,alloc}_rx_skb(). As it stands, you'll rel=
oad
> the NIC with a NULL skb pointer, and it will DMA to the old location
> when it eventually uses this descriptor.
>=20
> > -               } else {
> > -                       new_skb =3D skb;
> > -                       skb_put(new_skb, pkt_len);
> > -                       pci_unmap_single(tp->pdev, dma_addr, PKT_BU=
=46_SZ,
> > -                                      PCI_DMA_FROMDEVICE);
> > +               else
> >                         typhoon_alloc_rx_skb(tp, idx);

All fixed.

What about the patch's general idea?

Best Regards,
Micha=B3 Miros=B3aw
