From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH RFC 1/2] net: macb: Check DMA mappings for error
Date: Sun, 23 Feb 2014 00:13:13 +0000
Message-ID: <1393114393.6823.25.camel@deadeye.wl.decadent.org.uk>
References: <1393011025-18537-1-git-send-email-soren.brinkmann@xilinx.com>
	 <1393011025-18537-2-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-owIvHiavApekxpCxz3hC"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393011025-18537-2-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-owIvHiavApekxpCxz3hC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-02-21 at 11:30 -0800, Soren Brinkmann wrote:
[...]
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -632,11 +632,16 @@ static void gem_rx_refill(struct macb *bp)
>  					   "Unable to allocate sk_buff\n");
>  				break;
>  			}
> -			bp->rx_skbuff[entry] =3D skb;
> =20
>  			/* now fill corresponding descriptor entry */
>  			paddr =3D dma_map_single(&bp->pdev->dev, skb->data,
>  					       bp->rx_buffer_size, DMA_FROM_DEVICE);
> +			if (dma_mapping_error(&bp->pdev->dev, paddr)) {
> +				dev_kfree_skb(skb);
> +				break;
> +			}
> +
> +			bp->rx_skbuff[entry] =3D skb;

This bit looks good.

>  			if (entry =3D=3D RX_RING_SIZE - 1)
>  				paddr |=3D MACB_BIT(RX_WRAP);
> @@ -1040,6 +1045,10 @@ static int macb_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
>  	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
>  	mapping =3D dma_map_single(&bp->pdev->dev, skb->data,
>  				 len, DMA_TO_DEVICE);
> +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
> +		dev_kfree_skb(skb);

You need to unlock bp->lock before returning.  Also, I think this should
be kfree_skb(), as that can be observed through dropwatch whereas
dev_kfree_skb() is completely silent.

Ben.

> +		return NETDEV_TX_OK;
> +	}
> =20
>  	tx_skb =3D &bp->tx_skb[entry];
>  	tx_skb->skb =3D skb;

--=20
Ben Hutchings
All the simple programs have been written, and all the good names taken.

--=-owIvHiavApekxpCxz3hC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwk9Gee/yOyVhhEJAQr+kBAAwnAsudRcIW7gfaz1uzH0TzvzLlP2s2Y/
PrTAybrE5Rk1pOaHknjH2SOUEh8sBY5RZ8D8MUjqn/l9RYpKPd0ebbziXTSzQzyP
QAzrh8OtsSkm12O1ZUmN03lrtWqVG5rvJiISWqwCUGb7fb0eBDy+a6TPsurD3wVh
KGj2f5hNt4v3zf0Wow6yKYnTUFeayr85/dIl47wlSbf8wSRRMbmHFJi5vtICPZW+
1J3J4IjdkbjvInwVf3fmCI5i054Mdb1vMxrPP4MNW0mAqPwu0gd1V9QH1RnvYmCY
l6KPkDb4JnAMiK1OAFSIFJ6zD7FAfVmE1P843yfpH0mJPPgtMt702PreLmfmreUF
b32JE6ZwfrGg1nUgdm76nQ89vwoSdU7xsw5g36cVel7ALndIbQsvBR/zEVPjy4B4
qeRBIu+ilBAkZGT69nG7thgC+KFUEDwZ+83A+nwx2f+7zXu2AEibpH6iIH/gTUMG
Rq4AU9hDFMzVR9gwmbuMOzLMhcDsA/ZPn6SeY1XSsxIk96/Y84qCOmLhM+XI50Mm
jqXn5GFM3CZ7RuKXknSxBK0xgcTrwa8AiPNnuwAbHn6xMFubFA4jLeGk1Tf5Sr69
Bx3UVPjpi9/MlYEWMkXkREl/NOWpK4exse1R0eRV6HC2kDLrTrE3l9KF1KqYw0ja
jsX59nIzXKQ=
=Tezt
-----END PGP SIGNATURE-----

--=-owIvHiavApekxpCxz3hC--
