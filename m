From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/2] net: macb: Check DMA mappings for error
Date: Thu, 27 Feb 2014 23:57:39 +0000
Message-ID: <1393545459.14067.79.camel@deadeye.wl.decadent.org.uk>
References: <1393538285-28297-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-REnZseB9rYb9yHTq8IRs"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393538285-28297-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-REnZseB9rYb9yHTq8IRs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-27 at 13:58 -0800, Soren Brinkmann wrote:
[...]
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/c=
adence/macb.c
> index 3190d38e16fb..a9c2ccfc1740 100644
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
> =20
>  			if (entry =3D=3D RX_RING_SIZE - 1)
>  				paddr |=3D MACB_BIT(RX_WRAP);
> @@ -1040,6 +1045,10 @@ static int macb_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev)

A bit more context:

	entry =3D macb_tx_ring_wrap(bp->tx_head);
	bp->tx_head++;

>  	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
>  	mapping =3D dma_map_single(&bp->pdev->dev, skb->data,
>  				 len, DMA_TO_DEVICE);
> +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
> +		kfree_skb(skb);
> +		goto unlock;
> +	}

You need to move the bp->tx_head increment below this error check.
Sorry I didn't spot this the first time.

Ben.

>  	tx_skb =3D &bp->tx_skb[entry];
>  	tx_skb->skb =3D skb;
> @@ -1066,6 +1075,7 @@ static int macb_start_xmit(struct sk_buff *skb, str=
uct net_device *dev)
>  	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < 1)
>  		netif_stop_queue(dev);
> =20
> +unlock:
>  	spin_unlock_irqrestore(&bp->lock, flags);
> =20
>  	return NETDEV_TX_OK;

--=20
Ben Hutchings
It is easier to change the specification to fit the program than vice versa=
.

--=-REnZseB9rYb9yHTq8IRs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUw/Q8+e/yOyVhhEJAQqywg/+Ivi3z8MWimM6uUBsqbXLLIujaQGiu6Y+
b7rI3fljaIhAV9PFgurc4wcxtoYlXKZG8mWjWUdwwIeOZqLhO9fryqf9U4DvKLr8
uM0Oua2Aa7E2EGa8U5CMIU6DVRJ3w0/0WqaBv1ERCE9dhUKJqq4uK2S69VKmlt9N
QwdMgFHc0cj2x8xRPZKbpHqlOlzvajUYlZCSYkS3ZNE+BvNumZCwH0qzumfcX0Yg
PvH55qwDnCDbhPP69h7yn7fpXHiKuiF3gAF64vcM3T3L7TDNDoQNe6kvqIk5obSY
WBMfsBSfbZtrSn44gfQzHnSJe5se8Zhs2GWCnXBMWPXNQDWpwFcRZKje1JS9PdqY
a+stuXFnU5h87NmknyzPnxysQP7PWGx5gWwfD/GxFQQlzDISgQf/OBvmGFiM1IKf
M77XpvgfJKkBZPiE/BavXzu/PYreMdl0GsFvz9hddWqpOh9dBL/rAx4ePt93/x+o
cQ+nqGU07e8CLaGhqoMAF3LUr2CYzTe1Lcbr6T3Cs3bNxfEdW+e5mGV/bOTEI2p4
5oWOkhrLVIljQnA29vTISfKQ1dbTtweOiLqOhwDeSnZa3VX9SpgRieqiP5Rqz/9Z
53kGqy5CP1FGAI/bAuMWPhHMzg8FXlmNmXfyUM9VfR701yPXPsEepkydnGpYPUaG
FAGjmDCD+mA=
=cG6d
-----END PGP SIGNATURE-----

--=-REnZseB9rYb9yHTq8IRs--
