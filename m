From: Andrew Jeffery <andrew@aj.id.au>
Subject: Re: [PATCH v3] net: ftgmac100: Request clock and set speed
Date: Tue, 17 Oct 2017 12:30:22 +1030
Message-ID: <1508205622.24322.12.camel@aj.id.au>
References: <20171013041638.30763-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-FTxvgb6muKfV95DakX6F"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joel Stanley <joel@jms.id.au>,
        "David S . Miller" <davem@davemloft.net>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013041638.30763-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FTxvgb6muKfV95DakX6F
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-10-13 at 12:16 +0800, Joel Stanley wrote:
> According to the ASPEED datasheet, gigabit speeds require a clock of
> 100MHz or higher. Other speeds require 25MHz or higher. This patch
> configures a 100MHz clock if the system has a direct-attached
> PHY, or 25MHz if the system is running NC-SI which is limited to 100MHz.
>=C2=A0
> There appear to be no other upstream users of the FTGMAC100 driver it is
> hard to know the clocking requirements of other platforms. Therefore a
> conservative approach was taken with enabling clocks. If the platform is
> not ASPEED, both requesting the clock and configuring the speed is
> skipped.
>=C2=A0
> Signed-off-by: Joel Stanley <joel@jms.id.au>

Tested on an AST2500 EVB and an OpenPOWER Palmetto (AST2400) machine.
Confirmed clock rates were nominally what was requested, and successfully
downloaded a 100MB test file.

Tested-by: Andrew Jeffery <andrew@aj.id.au>

> ---
> Andrew, can you please give this one a spin on hardware?
>=C2=A0
> v3:
> =C2=A0- Fix errors from v2
> v2:
> =C2=A0- only touch the clocks on Aspeed platforms
> =C2=A0- unconditionally call clk_unprepare_disable
>=C2=A0
> =C2=A0drivers/net/ethernet/faraday/ftgmac100.c | 26 +++++++++++++++++++++=
+++++
> =C2=A01 file changed, 26 insertions(+)
>=C2=A0
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ether=
net/faraday/ftgmac100.c
> index 9ed8e4b81530..78db8e62a83f 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -21,6 +21,7 @@
> =C2=A0
> =C2=A0#define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt
> =C2=A0
> +#include <linux/clk.h>
> =C2=A0#include <linux/dma-mapping.h>
> =C2=A0#include <linux/etherdevice.h>
> =C2=A0#include <linux/ethtool.h>
> @@ -59,6 +60,9 @@
> =C2=A0/* Min number of tx ring entries before stopping queue */
> =C2=A0#define TX_THRESHOLD		(MAX_SKB_FRAGS + 1)
> =C2=A0
> +#define FTGMAC_100MHZ		100000000
> +#define FTGMAC_25MHZ		25000000
> +
> =C2=A0struct ftgmac100 {
> =C2=A0	/* Registers */
> =C2=A0	struct resource *res;
> @@ -96,6 +100,7 @@ struct ftgmac100 {
> =C2=A0	struct napi_struct napi;
> =C2=A0	struct work_struct reset_task;
> =C2=A0	struct mii_bus *mii_bus;
> +	struct clk *clk;
> =C2=A0
> =C2=A0	/* Link management */
> =C2=A0	int cur_speed;
> @@ -1734,6 +1739,22 @@ static void ftgmac100_ncsi_handler(struct ncsi_dev=
 *nd)
> =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0nd->link_up ? "up" : "down");
> =C2=A0}
> =C2=A0
> +static void ftgmac100_setup_clk(struct ftgmac100 *priv)
> +{
> +	priv->clk =3D devm_clk_get(priv->dev, NULL);
> +	if (IS_ERR(priv->clk))
> +		return;
> +
> +	clk_prepare_enable(priv->clk);
> +
> +	/* Aspeed specifies a 100MHz clock is required for up to
> +	=C2=A0* 1000Mbit link speeds. As NCSI is limited to 100Mbit, 25MHz
> +	=C2=A0* is sufficient
> +	=C2=A0*/
> +	clk_set_rate(priv->clk, priv->use_ncsi ? FTGMAC_25MHZ :
> +			FTGMAC_100MHZ);
> +}
> +
> =C2=A0static int ftgmac100_probe(struct platform_device *pdev)
> =C2=A0{
> =C2=A0	struct resource *res;
> @@ -1830,6 +1851,9 @@ static int ftgmac100_probe(struct platform_device *=
pdev)
> =C2=A0			goto err_setup_mdio;
> =C2=A0	}
> =C2=A0
> +	if (priv->is_aspeed)
> +		ftgmac100_setup_clk(priv);
> +
> =C2=A0	/* Default ring sizes */
> =C2=A0	priv->rx_q_entries =3D priv->new_rx_q_entries =3D DEF_RX_QUEUE_ENT=
RIES;
> =C2=A0	priv->tx_q_entries =3D priv->new_tx_q_entries =3D DEF_TX_QUEUE_ENT=
RIES;
> @@ -1883,6 +1907,8 @@ static int ftgmac100_remove(struct platform_device =
*pdev)
> =C2=A0
> =C2=A0	unregister_netdev(netdev);
> =C2=A0
> +	clk_disable_unprepare(priv->clk);
> +
> =C2=A0	/* There's a small chance the reset task will have been re-queued,
> =C2=A0	=C2=A0* during stop, make sure it's gone before we free the struct=
ure.
> =C2=A0	=C2=A0*/
--=-FTxvgb6muKfV95DakX6F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJZ5WQ2AAoJEJ0dnzgO5LT51aEP/RRRz+klQzX8/P14hLLrmjUs
ksC+mb/D1oT33d5S9KNbVVhdrg3iUjMZ6KXJhAVGoVQ0oFGz6UJmiihQEjhOjNwl
Wqxghkp5Guk9hAiPk3k0wJn4LW5XYtFBl2kyLYYgsINRIhQvUARcLO9B37QSG9MK
taVRO95E7PHzeKKXJQKJMXca7w3R/rHW5opmHN2SD5MmyHZ2cNxQ9kz9huxo7cko
v/qyPMtpxEFwT1YPH2ap4UwHrpb4vbpg+G2vUHWqufT8iJFdWwplt9avewOOI6I8
GxW5Z0SkfTiWpYO+aEa0onBtvCOhQkMYD4hMSTRpEGfkgGZpYLv5pvHYQAwXzsZb
sjFpSzvo/r2qPqrOkH61QkqWTZVVayPPEq2hdfFx/LtHQgfQMY14P4ercyM5cQKY
DwyLyNmERUuFnNwcO3vQhbu0k1U8NZq5xWXaDDwTGLfUEE8Ux5CTS1XZUDLYG0JW
Luz9ABicYPqgloKJdnPS/eb3B8DEqLdWBtXJ34rk/2ZXOwRkz+FkNYtXoyFfpCNq
cEykIAGpxCSKjyRO1vxCgzqukqxolcJqF1pv/Vjl5FBqVmBcHV+PT3pnOLVzRfLi
k5e5xS9m7dN8OGj+hk/l/K287eN5Ppb8DdD2y6OSq6+6YLTJ6pg5t78rtihtNIRF
Cy31jBWAqI0KAB0RK74g
=RubY
-----END PGP SIGNATURE-----

--=-FTxvgb6muKfV95DakX6F--
