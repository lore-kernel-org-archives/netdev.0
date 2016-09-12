From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [RFC PATCH 9/9] ethernet: sun8i-emac: add pm_runtime support
Date: Mon, 12 Sep 2016 22:44:51 +0200
Message-ID: <20160912204451.GO9449@lukather>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-10-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vDEbda84Uy/oId5W"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:45140 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752736AbcILUoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 16:44:54 -0400
Content-Disposition: inline
In-Reply-To: <1473425117-18645-10-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vDEbda84Uy/oId5W
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Sep 09, 2016 at 02:45:17PM +0200, Corentin Labbe wrote:
> This patch add pm_runtime support to sun8i-emac.
> For the moment, only basic support is added, (the device is marked as
> used when net/open)
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/allwinner/sun8i-emac.c | 62 +++++++++++++++++++++++=
+++++-
>  1 file changed, 60 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/allwinner/sun8i-emac.c b/drivers/net/et=
hernet/allwinner/sun8i-emac.c
> index 1c4bc80..cce886e 100644
> --- a/drivers/net/ethernet/allwinner/sun8i-emac.c
> +++ b/drivers/net/ethernet/allwinner/sun8i-emac.c
> @@ -9,7 +9,6 @@
>   * - MAC filtering
>   * - Jumbo frame
>   * - features rx-all (NETIF_F_RXALL_BIT)
> - * - PM runtime
>   */
>  #include <linux/bitops.h>
>  #include <linux/clk.h>
> @@ -27,6 +26,7 @@
>  #include <linux/pinctrl/consumer.h>
>  #include <linux/pinctrl/pinctrl.h>
>  #include <linux/platform_device.h>
> +#include <linux/pm_runtime.h>
>  #include <linux/reset.h>
>  #include <linux/scatterlist.h>
>  #include <linux/skbuff.h>
> @@ -1301,11 +1301,18 @@ static int sun8i_emac_open(struct net_device *nde=
v)
>  	int err;
>  	u32 v;
> =20
> +	err =3D pm_runtime_get_sync(priv->dev);
> +	if (err) {
> +		pm_runtime_put_noidle(priv->dev);
> +		dev_err(priv->dev, "pm_runtime error: %d\n", err);
> +		return err;
> +	}
> +
>  	err =3D request_irq(priv->irq, sun8i_emac_dma_interrupt, 0,
>  			  dev_name(priv->dev), ndev);
>  	if (err) {
>  		dev_err(priv->dev, "Cannot request IRQ: %d\n", err);
> -		return err;
> +		goto err_runtime;
>  	}
> =20
>  	/* Set interface mode (and configure internal PHY on H3) */
> @@ -1395,6 +1402,8 @@ err_syscon:
>  	sun8i_emac_unset_syscon(ndev);
>  err_irq:
>  	free_irq(priv->irq, ndev);
> +err_runtime:
> +	pm_runtime_put(priv->dev);
>  	return err;
>  }
> =20
> @@ -1483,6 +1492,8 @@ static int sun8i_emac_stop(struct net_device *ndev)
>  	dma_free_coherent(priv->dev, priv->nbdesc_tx * sizeof(struct dma_desc),
>  			  priv->dd_tx, priv->dd_tx_phy);
> =20
> +	pm_runtime_put(priv->dev);
> +
>  	return 0;
>  }
> =20
> @@ -2210,6 +2221,8 @@ static int sun8i_emac_probe(struct platform_device =
*pdev)
>  		goto probe_err;
>  	}
> =20
> +	pm_runtime_enable(priv->dev);
> +
>  	return 0;
> =20
>  probe_err:
> @@ -2221,6 +2234,8 @@ static int sun8i_emac_remove(struct platform_device=
 *pdev)
>  {
>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
> =20
> +	pm_runtime_disable(&pdev->dev);
> +
>  	unregister_netdev(ndev);
>  	platform_set_drvdata(pdev, NULL);
>  	free_netdev(ndev);
> @@ -2228,6 +2243,47 @@ static int sun8i_emac_remove(struct platform_devic=
e *pdev)
>  	return 0;
>  }
> =20
> +static int __maybe_unused sun8i_emac_suspend(struct platform_device *pde=
v, pm_message_t state)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
> +
> +	napi_disable(&priv->napi);
> +
> +	if (netif_running(ndev))
> +		netif_device_detach(ndev);
> +
> +	sun8i_emac_stop_tx(ndev);
> +	sun8i_emac_stop_rx(ndev);
> +
> +	sun8i_emac_rx_clean(ndev);
> +	sun8i_emac_tx_clean(ndev);
> +
> +	phy_stop(ndev->phydev);
> +
> +	return 0;
> +}
> +
> +static int __maybe_unused sun8i_emac_resume(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
> +
> +	phy_start(ndev->phydev);
> +
> +	sun8i_emac_start_tx(ndev);
> +	sun8i_emac_start_rx(ndev);
> +
> +	if (netif_running(ndev))
> +		netif_device_attach(ndev);
> +
> +	netif_start_queue(ndev);
> +
> +	napi_enable(&priv->napi);
> +
> +	return 0;
> +}

The main idea behind the runtime PM hooks is that they bring the
device to a working state and shuts it down when it's not needed
anymore.

However, they shouldn't be called when the device is still in used, so
all the mangling with NAPI, the phy and so on is irrelevant here, but
the clocks, resets, for example, are.

>  static const struct of_device_id sun8i_emac_of_match_table[] =3D {
>  	{ .compatible =3D "allwinner,sun8i-a83t-emac",
>  	  .data =3D &emac_variant_a83t },
> @@ -2246,6 +2302,8 @@ static struct platform_driver sun8i_emac_driver =3D=
 {
>  		.name           =3D "sun8i-emac",
>  		.of_match_table	=3D sun8i_emac_of_match_table,
>  	},
> +	.suspend	=3D sun8i_emac_suspend,
> +	.resume		=3D sun8i_emac_resume,

These are not the runtime PM hooks. How did you test that?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--vDEbda84Uy/oId5W
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX1xPDAAoJEBx+YmzsjxAgBxMP/0OHclENQ0ToA2ihIE2wFDbe
sphvSfQZF/+57gEaiY61WAt6uoOOpNHnN5jF1EVJXzzu3kiD5cX/QjvMAVz4kM+j
gqJFediAcfzaIgWvtkj5/xS4zBlToR8eHWy18SkCe5C2EkuBlD/TkjyFCd4KfWMD
B2LgWYpkVRGJ/APCrIxNYRWrJf8VEcLmnKJ1wrqHRW4aaSwUng7gPdwRySSK+dvZ
SZ7JesisypxoX2Nf1Ju476CpX2bvdEhDuKziaKheV3LjZMfpWiVNK6CY6FA62BWI
w4lN5UsYS1hDDcFFkXmA6s5mXF4b2C0PoYN+KNso+Lsmy/EA961fKKy5AOQZCUnn
A7OCPMZ4oABbY13XI4qtsFm+XM771MyBQuF6QUvIKZ1kbem3qjgB3ZZYjU1DgqZW
XGtJS9Xh5VgaEk5ZC6+/SM9j62g1E86IapOSMLZXD1ojC/Gxgeha9jj+3k6R5lOv
IM/mkAgpLIMiYV7uWs06XXqfcCPPAmlTm7/3BRt3IikJfy4TSCVrxPudmzOQaZGF
i9Ul3FVt+oi06aCWZINslLJptT33SllIjgmQ0iEcgwRikg1Fth7PHaKZAG0s3dOO
22XtPbzUxirxIht5qqTZxdaDyThHHRMQRBDL9Hnhzxh3mNisQ3yU2sDryi+JOJpL
0uyX+ilDfCLrrSRg2TLd
=iK1/
-----END PGP SIGNATURE-----

--vDEbda84Uy/oId5W--
