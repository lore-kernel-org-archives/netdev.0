From: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] net: micrel : ks8851-ml: add vdd-supply support
Date: Fri, 21 Mar 2014 09:51:58 +0100
Message-ID: <20140321085158.GB30910@pengutronix.de>
References: <1395384768-8461-1-git-send-email-nm@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NDin8bjvE/0mNLFQ"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1395384768-8461-1-git-send-email-nm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Mar 21, 2014 at 01:52:48AM -0500, Nishanth Menon wrote:
> Few platforms use external regulator to keep the ethernet MAC supplied.
> So, request and enable the regulator for driver functionality.
>=20
> Fixes: 66fda75f47dc (regulator: core: Replace direct ops->disable usage)
> Reported-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> Suggested-by: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Signed-off-by: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
> ---
>=20
> This fixes a regression in SDP4430 platform as reported by Russel here:
> http://marc.info/?t=3D139509918200014&r=3D1&w=3D2
>=20
> Patch is based on [v3.14-rc7] tag, if it is too late to submit, I can rep=
ost
> rebased to git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.g=
it
>=20
>  .../devicetree/bindings/net/micrel-ks8851.txt      |    1 +
>  drivers/net/ethernet/micrel/ks8851.c               |   30 ++++++++++++++=
+++++-
>  2 files changed, 30 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/micrel-ks8851.txt b/Do=
cumentation/devicetree/bindings/net/micrel-ks8851.txt
> index 11ace3c..4fc3927 100644
> --- a/Documentation/devicetree/bindings/net/micrel-ks8851.txt
> +++ b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
> @@ -7,3 +7,4 @@ Required properties:
> =20
>  Optional properties:
>  - local-mac-address : Ethernet mac address to use
> +- vdd-supply:	supply for Ethernet mac
> diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/=
micrel/ks8851.c
> index 727b546a..e0c92e0 100644
> --- a/drivers/net/ethernet/micrel/ks8851.c
> +++ b/drivers/net/ethernet/micrel/ks8851.c
> @@ -23,6 +23,7 @@
>  #include <linux/crc32.h>
>  #include <linux/mii.h>
>  #include <linux/eeprom_93cx6.h>
> +#include <linux/regulator/consumer.h>
> =20
>  #include <linux/spi/spi.h>
> =20
> @@ -83,6 +84,7 @@ union ks8851_tx_hdr {
>   * @rc_rxqcr: Cached copy of KS_RXQCR.
>   * @eeprom_size: Companion eeprom size in Bytes, 0 if no eeprom
>   * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
> + * @vdd_reg:	Optional regulator supplying the chip
>   *
>   * The @lock ensures that the chip is protected when certain operations =
are
>   * in progress. When the read or write packet transfer is in progress, m=
ost
> @@ -130,6 +132,7 @@ struct ks8851_net {
>  	struct spi_transfer	spi_xfer2[2];
> =20
>  	struct eeprom_93cx6	eeprom;
> +	struct regulator	*vdd_reg;
>  };
> =20
>  static int msg_enable;
> @@ -1414,6 +1417,21 @@ static int ks8851_probe(struct spi_device *spi)
>  	ks->spidev =3D spi;
>  	ks->tx_space =3D 6144;
> =20
> +	ks->vdd_reg =3D regulator_get_optional(&spi->dev, "vdd");

You could use devm_regulator_get_optional here and remove the
regulator_put.

Regards,

Markus

> +	if (IS_ERR(ks->vdd_reg)) {
> +		ret =3D PTR_ERR(ks->vdd_reg);
> +		if (ret =3D=3D -EPROBE_DEFER)
> +			goto err_reg;
> +	} else {
> +		ret =3D regulator_enable(ks->vdd_reg);
> +		if (ret) {
> +			dev_err(&spi->dev, "regulator enable fail: %d\n",
> +				ret);
> +			goto err_reg_en;
> +		}
> +	}
> +
> +
>  	mutex_init(&ks->lock);
>  	spin_lock_init(&ks->statelock);
> =20
> @@ -1508,8 +1526,14 @@ static int ks8851_probe(struct spi_device *spi)
>  err_netdev:
>  	free_irq(ndev->irq, ks);
> =20
> -err_id:
>  err_irq:
> +err_id:
> +	if (!IS_ERR(ks->vdd_reg))
> +		regulator_disable(ks->vdd_reg);
> +err_reg_en:
> +	if (!IS_ERR(ks->vdd_reg))
> +		regulator_put(ks->vdd_reg);
> +err_reg:
>  	free_netdev(ndev);
>  	return ret;
>  }
> @@ -1523,6 +1547,10 @@ static int ks8851_remove(struct spi_device *spi)
> =20
>  	unregister_netdev(priv->netdev);
>  	free_irq(spi->irq, priv);
> +	if (!IS_ERR(priv->vdd_reg)) {
> +		regulator_disable(priv->vdd_reg);
> +		regulator_put(priv->vdd_reg);
> +	}
>  	free_netdev(priv->netdev);
> =20
>  	return 0;
> --=20
> 1.7.9.5
>=20
>=20

--=20
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

--NDin8bjvE/0mNLFQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTK/2uAAoJEEpcgKtcEGQQix4QAKr4rSOgvX4LrZlnvGGD8JY7
p7nUIfs6GiRcjNN1GMOlYSnboEWh/CS1VITMWwRS6Xq2XL4MYf+sKwBCYFbZfH7o
TLKWpG6gXe8EA4UXxZ/m3fzQLsuTt1OvxLJdjI+Y5dxnYA2UdtPx/nXrMP+vqAaD
25lhWQ7R01Z/WaLp1i1UN3SZKu8RIPX4glLVHM4BpEhfHa4SKUhtVGAR570IXh2+
Iu1K7cEPRhuhQLWWlzefwOC9yj/H4+2EtUB4CT20HU/V4/uNTxy3FvKAivn+uFyR
u5ayShPnMHIiAh9uR/E65FMpLkxmb0EtYrhKHTX0pH7XTKMFVcQSCiImNLnyBpNx
/u+SKSAPubw1kJzUXdbF/ud10glZxUQ5cOOoViwZIv0In+VloAFfq1CBLl22rmh2
aWhpbg18UXnlhvjWfpLcxThg4zoFtbEmDWwdQ0CC9/4dkKFIhb2aK/R5cpc68+HW
8kunMFN0Fw5F7ARScSlWop/f4NRzGdXN2HTSFCUSpomg0pFhvkuGxM/WSKjOWWtn
Jf7305eWYy47v/VRDaSUgPsvaO4U8G42dHh8TAIe2oHKNe93nn1xK3IzWg3qvii6
oYwP+ww4Pi/wWxIenltWI6rXTQlNmvGhsinIQXCIW5+RzaI0+yuuxq3OUgNS+Mtn
5JbXNhXs/EbjPL3B1J91
=n/HU
-----END PGP SIGNATURE-----

--NDin8bjvE/0mNLFQ--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
