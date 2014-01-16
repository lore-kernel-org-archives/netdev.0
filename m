From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] r6040: use ETH_ZLEN instead of MISR for
 SKB length checking
Date: Thu, 16 Jan 2014 07:23:21 +0000
Message-ID: <1389857001.19462.33.camel@deadeye.wl.decadent.org.uk>
References: <1389819866-32142-1-git-send-email-florian@openwrt.org>
	 <1389819866-32142-3-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xeWU4H9su69eCg8unitY"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49752 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159AbaAPHX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 02:23:27 -0500
In-Reply-To: <1389819866-32142-3-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xeWU4H9su69eCg8unitY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-15 at 13:04 -0800, Florian Fainelli wrote:
> Ever since this driver was merged the following code was included:
>=20
> if (skb->len < MISR)
> 	skb->len =3D MISR;

The second 'skb->len' is currently 'descptr->len'.

> MISR is defined to 0x3C which is also equivalent to ETH_ZLEN, but use
> ETH_ZLEN directly which is exactly what we want to be checking for.
>=20
> Reported-by: Marc Volovic <marcv@ezchip.com>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
>  drivers/net/ethernet/rdc/r6040.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/=
r6040.c
> index ff4683a..eb15ebf 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -836,8 +836,8 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *s=
kb,
>  	/* Set TX descriptor & Transmit it */
>  	lp->tx_free_desc--;
>  	descptr =3D lp->tx_insert_ptr;
> -	if (skb->len < MISR)
> -		descptr->len =3D MISR;
> +	if (skb->len < ETH_ZLEN)
> +		descptr->len =3D ETH_ZLEN;

It looks like this is just increasing the TX descriptor length so the
packet is tail-padded with whatever happens to come next in the skb.
This is absolutely incorrect behaviour and may leak sensitive
information.

Presumably it is necessary to pad the frame because the MAC is too lame
to do it, and the correct way to do that is using skb_padto(skb,
ETH_ZLEN).  But this may fail as it might have to allocate memory

Additionally, the driver DMA-maps a length of skb->len but needs to map
a length of descptr->len.

Finally, it doesn't check for failure of DMA mapping.

Tidying up naming should be way down the list of priorities for
fixing this code.

I think this will fix those problems, though I need to split it up into
multiple patches:

--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -816,6 +816,7 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb=
,
 	struct r6040_descriptor *descptr;
 	void __iomem *ioaddr =3D lp->base;
 	unsigned long flags;
+	dma_addr_t dma_addr;
=20
 	/* Critical Section */
 	spin_lock_irqsave(&lp->lock, flags);
@@ -828,24 +829,35 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *s=
kb,
 		return NETDEV_TX_BUSY;
 	}
=20
-	/* Statistic Counter */
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes +=3D skb->len;
 	/* Set TX descriptor & Transmit it */
-	lp->tx_free_desc--;
 	descptr =3D lp->tx_insert_ptr;
-	if (skb->len < MISR)
-		descptr->len =3D MISR;
-	else
-		descptr->len =3D skb->len;
+
+	/* MAC doesn't pad frames so we have to */
+	if (skb_padto(skb, ETH_ZLEN)) {
+		kfree_skb(skb);
+		goto out;
+	}
+	descptr->len =3D max_t(int, skb->len, ETH_ZLEN);
+
+	dma_addr =3D pci_map_single(lp->pdev, skb->data, descptr->len,
+				  PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(lp->pdev, dma_addr)) {
+		kfree_skb(skb);
+		goto out;
+	}
+
+	lp->tx_free_desc--;
=20
 	descptr->skb_ptr =3D skb;
-	descptr->buf =3D cpu_to_le32(pci_map_single(lp->pdev,
-		skb->data, skb->len, PCI_DMA_TODEVICE));
+	descptr->buf =3D cpu_to_le32(dma_addr);
 	descptr->status =3D DSC_OWNER_MAC;
=20
 	skb_tx_timestamp(skb);
=20
+	/* Statistic Counter */
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes +=3D skb->len;
+
 	/* Trigger the MAC to check the TX descriptor */
 	iowrite16(TM2TX, ioaddr + MTPR);
 	lp->tx_insert_ptr =3D descptr->vndescp;
@@ -854,6 +866,7 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb=
,
 	if (!lp->tx_free_desc)
 		netif_stop_queue(dev);
=20
+out:
 	spin_unlock_irqrestore(&lp->lock, flags);
=20
 	return NETDEV_TX_OK;
---

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-xeWU4H9su69eCg8unitY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUteI6ee/yOyVhhEJAQpTCg//QIFvu/1ZfSAJoQBrdlzvkCpMHNuTaFJ1
fR9/N6uwyvNl0AOGxzOOz7VxTEurMy8OFa4wQBG+Q2S990q5P4HB+mrIBHJunaea
2oOJA0zOc+ptAXAzMTJxBrNJosrc96/6Bq+UyzFd+3vXSH9Jes13Vjj1/6cikABY
BNwpb2skUZe4mnl4EPrTplpOgcASnobb8jPQ1zZ0Wo/GCASnsp2Q7JHcAvgBRr2L
0+Wr2Av/7biCVN9CUPpNX3JSxq/gujpmGF68dygVZRnFud32WMHowboKy9K21/fI
nd9wlOuqaPsgMBa7Bn0PxxVFUq/vl4dMehihHKpniGRgpk1hQ2Xzre+zjI7QDh8i
AL3Ap7ZFnTIMi0T1F//8e1EvpUkIcBtuvq1GOzDVaxtDYJZTc7DuJGskeo5nvUHJ
mpZqtQ8v0IbQ/b/+4sjm4z9ubsPC0yIGjvqAbTralZWkBtiUoK9uAgnK9CvA5S14
yYE0Bt59EEY7x9Zs9nTmwzqpNFGKjb0uVt13gxw+4/OcjMsFXBaIqJ+T91px8KmT
ga7L5OxI5+l0uyoZXkFDcGfCR/x6R+5odfTgzTzdt+eh4AXcxy5fcR8pSZkePiUi
/ij3qWjeZUXXxpxvnMgbw6CQEq2Si/5UGerYZ/aOxqST1zj9VCs1xr5Rbsyhb506
rTCUA3j4SOQ=
=wxdz
-----END PGP SIGNATURE-----

--=-xeWU4H9su69eCg8unitY--
