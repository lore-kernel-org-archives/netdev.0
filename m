From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH 3/4] ll_temac: free everything on error path
Date: Thu, 8 Jul 2010 17:56:09 +0400
Message-ID: <AANLkTilMaITOMsn_9MmZ7-zHwpvTd2ZYjj4UUWOloYsn@mail.gmail.com>
References: <1278591012-3213-1-git-send-email-segooon@gmail.com>
	<AANLkTilm1b61ikLi28We3aLrF3Ld4c05oFZlh3K1pORe@mail.gmail.com>
	<20100708134651.GA27196@shinshilla>
Reply-To: dkirjanov@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kernel Janitors <kernel-janitors@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	John Linn <john.linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Pirko <jpirko@redhat.com>,
	Brian Hill <brian.hill@xilinx.com>, netdev@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64058 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab0GHN4M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 09:56:12 -0400
In-Reply-To: <20100708134651.GA27196@shinshilla>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 8, 2010 at 5:46 PM, Kulikov Vasiliy <segooon@gmail.com> wro=
te:
> On Thu, Jul 08, 2010 at 17:16 +0400, Denis Kirjanov wrote:
>> On Thu, Jul 8, 2010 at 4:10 PM, Kulikov Vasiliy <segooon@gmail.com> =
wrote:
>> > temac_dma_bd_init() must free all allocated resources: memory, dma=
, skbs.
>> >
>> > Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
>> > ---
>> > =A0drivers/net/ll_temac_main.c | =A0 30 +++++++++++++++++++++++++-=
----
>> > =A01 files changed, 25 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_ma=
in.c
>> > index a2da3d7..38d658a 100644
>> > --- a/drivers/net/ll_temac_main.c
>> > +++ b/drivers/net/ll_temac_main.c
>> > @@ -200,6 +200,7 @@ static int temac_dma_bd_init(struct net_device=
 *ndev)
>> > =A0 =A0 =A0 =A0struct temac_local *lp =3D netdev_priv(ndev);
>> > =A0 =A0 =A0 =A0struct sk_buff *skb;
>> > =A0 =A0 =A0 =A0int i;
>> > + =A0 =A0 =A0 int tx_bd_v_size, rx_bd_v_size;
>> >
>> > =A0 =A0 =A0 =A0lp->rx_skb =3D kzalloc(sizeof(*lp->rx_skb) * RX_BD_=
NUM, GFP_KERNEL);
>> > =A0 =A0 =A0 =A0if (!lp->rx_skb) {
>> > @@ -209,21 +210,23 @@ static int temac_dma_bd_init(struct net_devi=
ce *ndev)
>> > =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0/* allocate the tx and rx ring buffer descriptors. =
*/
>> > =A0 =A0 =A0 =A0/* returns a virtual addres and a physical address.=
 */
>> > + =A0 =A0 =A0 tx_bd_v_size =3D sizeof(*lp->tx_bd_v) * TX_BD_NUM;
>> > =A0 =A0 =A0 =A0lp->tx_bd_v =3D dma_alloc_coherent(ndev->dev.parent=
,
> =A0 =A0 =A0 =A0 =A0 ^^^^^^^^^^^
> =A0 =A0 =A0 =A0 =A0 =A01st
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sizeof(*lp->tx_bd_v) * TX_BD_NUM,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 tx_bd_v_size,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 &lp->tx_bd_p, GFP_KERNEL);
>> > =A0 =A0 =A0 =A0if (!lp->tx_bd_v) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&ndev->dev,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"un=
able to allocate DMA TX buffer descriptors");
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_rx_skb;
>> > =A0 =A0 =A0 =A0}
>> > + =A0 =A0 =A0 rx_bd_v_size =3D sizeof(*lp->rx_bd_v) * RX_BD_NUM;
>> > =A0 =A0 =A0 =A0lp->rx_bd_v =3D dma_alloc_coherent(ndev->dev.parent=
,
> =A0 =A0 =A0 =A0 =A0 ^^^^^^^^^^^
> =A0 =A0 =A0 =A0 =A0 =A02nd
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0sizeof(*lp->rx_bd_v) * RX_BD_NUM,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0rx_bd_v_size,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 &lp->rx_bd_p, GFP_KERNEL);
>> > =A0 =A0 =A0 =A0if (!lp->rx_bd_v) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&ndev->dev,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"un=
able to allocate DMA RX buffer descriptors");
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_tx_bd;
>> > =A0 =A0 =A0 =A0}
>> >
>> > =A0 =A0 =A0 =A0memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD=
_NUM);
>> > @@ -242,7 +245,7 @@ static int temac_dma_bd_init(struct net_device=
 *ndev)
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb =3D=3D 0) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&ndev->dev,=
 "alloc_skb error %d\n", i);
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_dma_single;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_skb[i] =3D skb;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* returns physical address of skb-=
>data */
>> > @@ -274,6 +277,23 @@ static int temac_dma_bd_init(struct net_devic=
e *ndev)
>> >
>> > =A0 =A0 =A0 =A0return 0;
>> >
>> > +err_dma_single:
>> > + =A0 =A0 =A0 for (i =3D 0; i < RX_BD_NUM; i++) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lp->rx_skb[i] =3D=3D NULL)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(lp->rx_skb[i]);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unmap_single(ndev->dev.parent, l=
p->rx_bd_v[i].phys,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 XTE_=
MAX_JUMBO_FRAME_SIZE, DMA_FROM_DEVICE);
>> > + =A0 =A0 =A0 }
>> > +
>> > + =A0 =A0 =A0 dma_free_coherent(ndev->dev.parent, rx_bd_v_size,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->=
rx_bd_v, lp->rx_bd_p);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
^^^^^^^^^^^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 2nd
>> > +err_tx_bd:
>> > + =A0 =A0 =A0 dma_free_coherent(ndev->dev.parent, tx_bd_v_size,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->=
tx_bd_v, lp->tx_bd_p);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
^^^^^^^^^^^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 1st
>> > +err_rx_skb:
>> > + =A0 =A0 =A0 kfree(lp->rx_skb);
>> > =A0out:
>> > =A0 =A0 =A0 =A0return -ENOMEM;
>> > =A0}
>> > --
>> > 1.7.0.4
>> This is not enough. DMA resources also must be released on exit.
> Could you point to it? I see only two variables with allocated DMA (s=
ee above).
> --
I just sent a patch that fixes this.

> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Denis
