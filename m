From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: Convert to runtime_pm
Date: Mon, 12 Jan 2015 20:52:35 +0100
Message-ID: <54B42603.1070409@pengutronix.de>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="DOoGIEGOFWuAO7v5VUdKXPINbrDqSgOkH"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, grant.likely@linaro.org,
	robh+dt@kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--DOoGIEGOFWuAO7v5VUdKXPINbrDqSgOkH
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2015 04:04 PM, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driver=
,
> Use the runtime_pm framework. This consolidates the actions for runtime=
 PM
> In the appropriate callbacks and makes the driver more readable and man=
tainable.
>=20
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>

FTBFS:

> drivers/net/can/xilinx_can.c:1064:9: error: undefined identifier 'SET_P=
M_RUNTIME_PM_OPS'
>   CC [M]  drivers/net/can/xilinx_can.o
> drivers/net/can/xilinx_can.c:1064:2: error: implicit declaration of fun=
ction =E2=80=98SET_PM_RUNTIME_PM_OPS=E2=80=99 [-Werror=3Dimplicit-functio=
n-declaration]
>   SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume, NULL=
)
>   ^
> drivers/net/can/xilinx_can.c:1065:1: error: initializer element is not =
constant
>  };
>  ^
> drivers/net/can/xilinx_can.c:1065:1: error: (near initialization for =E2=
=80=98xcan_dev_pm_ops.prepare=E2=80=99)

Have a look at commit 40bd62c6194bdee1bc6652b3b0aa28e34883f603:

More comments inline. Looks quite good now.

>     PM: Remove the SET_PM_RUNTIME_PM_OPS() macro
>=20
>     There're now no users left of the SET_PM_RUNTIME_PM_OPS() macro, si=
nce
>     all have converted to use the SET_RUNTIME_PM_OPS() macro instead, s=
o
>     let's remove it.
> ---
> Changes for v5:
>  - Updated with the review comments.
>    Updated the remove fuction to use runtime_pm.
> Chnages for v4:
>  - Updated with the review comments.
> Changes for v3:
>   - Converted the driver to use runtime_pm.
> Changes for v2:
>   - Removed the struct platform_device* from suspend/resume
>     as suggest by Lothar.
>=20
>  drivers/net/can/xilinx_can.c |  157 ++++++++++++++++++++++++++++------=
-------
>  1 files changed, 107 insertions(+), 50 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.=
c
> index 6c67643..67aef00 100644
> --- a/drivers/net/can/xilinx_can.c
> +++ b/drivers/net/can/xilinx_can.c
> @@ -32,6 +32,7 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
>  #include <linux/can/led.h>
> +#include <linux/pm_runtime.h>
> =20
>  #define DRIVER_NAME	"xilinx_can"
> =20
> @@ -138,7 +139,7 @@ struct xcan_priv {
>  	u32 (*read_reg)(const struct xcan_priv *priv, enum xcan_reg reg);
>  	void (*write_reg)(const struct xcan_priv *priv, enum xcan_reg reg,
>  			u32 val);
> -	struct net_device *dev;
> +	struct device *dev;
>  	void __iomem *reg_base;
>  	unsigned long irq_flags;
>  	struct clk *bus_clk;
> @@ -842,6 +843,13 @@ static int xcan_open(struct net_device *ndev)
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>  	int ret;
> =20
> +	ret =3D pm_runtime_get_sync(priv->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> +				__func__, ret);
> +		return ret;
> +	}
> +
>  	ret =3D request_irq(ndev->irq, xcan_interrupt, priv->irq_flags,
>  			ndev->name, ndev);
>  	if (ret < 0) {
> @@ -849,29 +857,17 @@ static int xcan_open(struct net_device *ndev)
>  		goto err;
>  	}
> =20
> -	ret =3D clk_prepare_enable(priv->can_clk);
> -	if (ret) {
> -		netdev_err(ndev, "unable to enable device clock\n");
> -		goto err_irq;
> -	}
> -
> -	ret =3D clk_prepare_enable(priv->bus_clk);
> -	if (ret) {
> -		netdev_err(ndev, "unable to enable bus clock\n");
> -		goto err_can_clk;
> -	}
> -
>  	/* Set chip into reset mode */
>  	ret =3D set_reset_mode(ndev);
>  	if (ret < 0) {
>  		netdev_err(ndev, "mode resetting failed!\n");
> -		goto err_bus_clk;
> +		goto err_irq;
>  	}
> =20
>  	/* Common open */
>  	ret =3D open_candev(ndev);
>  	if (ret)
> -		goto err_bus_clk;
> +		goto err_irq;
> =20
>  	ret =3D xcan_chip_start(ndev);
>  	if (ret < 0) {
> @@ -887,13 +883,11 @@ static int xcan_open(struct net_device *ndev)
> =20
>  err_candev:
>  	close_candev(ndev);
> -err_bus_clk:
> -	clk_disable_unprepare(priv->bus_clk);
> -err_can_clk:
> -	clk_disable_unprepare(priv->can_clk);
>  err_irq:
>  	free_irq(ndev->irq, ndev);
>  err:
> +	pm_runtime_put(priv->dev);
> +
>  	return ret;
>  }
> =20
> @@ -910,12 +904,11 @@ static int xcan_close(struct net_device *ndev)
>  	netif_stop_queue(ndev);
>  	napi_disable(&priv->napi);
>  	xcan_chip_stop(ndev);
> -	clk_disable_unprepare(priv->bus_clk);
> -	clk_disable_unprepare(priv->can_clk);
>  	free_irq(ndev->irq, ndev);
>  	close_candev(ndev);
> =20
>  	can_led_event(ndev, CAN_LED_EVENT_STOP);
> +	pm_runtime_put(priv->dev);
> =20
>  	return 0;
>  }
> @@ -934,27 +927,20 @@ static int xcan_get_berr_counter(const struct net=
_device *ndev,
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>  	int ret;
> =20
> -	ret =3D clk_prepare_enable(priv->can_clk);
> -	if (ret)
> -		goto err;
> -
> -	ret =3D clk_prepare_enable(priv->bus_clk);
> -	if (ret)
> -		goto err_clk;
> +	ret =3D pm_runtime_get_sync(priv->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> +				__func__, ret);
> +		return ret;
> +	}
> =20
>  	bec->txerr =3D priv->read_reg(priv, XCAN_ECR_OFFSET) & XCAN_ECR_TEC_M=
ASK;
>  	bec->rxerr =3D ((priv->read_reg(priv, XCAN_ECR_OFFSET) &
>  			XCAN_ECR_REC_MASK) >> XCAN_ESR_REC_SHIFT);
> =20
> -	clk_disable_unprepare(priv->bus_clk);
> -	clk_disable_unprepare(priv->can_clk);
> +	pm_runtime_put(priv->dev);
> =20
>  	return 0;
> -
> -err_clk:
> -	clk_disable_unprepare(priv->can_clk);
> -err:
> -	return ret;
>  }
> =20
> =20
> @@ -967,15 +953,45 @@ static const struct net_device_ops xcan_netdev_op=
s =3D {
> =20
>  /**
>   * xcan_suspend - Suspend method for the driver
> - * @dev:	Address of the platform_device structure
> + * @dev:	Address of the device structure
>   *
>   * Put the driver into low power mode.
> - * Return: 0 always
> + * Return: 0 on success and failure value on error
>   */
>  static int __maybe_unused xcan_suspend(struct device *dev)
>  {
> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	if (!device_may_wakeup(dev))
> +		return pm_runtime_force_suspend(dev);
> +
> +	return 0;
> +}
> +
> +/**
> + * xcan_resume - Resume from suspend
> + * @dev:	Address of the device structure
> + *
> + * Resume operation after suspend.
> + * Return: 0 on success and failure value on error
> + */
> +static int __maybe_unused xcan_resume(struct device *dev)
> +{
> +	if (!device_may_wakeup(dev))
> +		return pm_runtime_force_resume(dev);
> +
> +	return 0;
> +
> +}
> +
> +/**
> + * xcan_runtime_suspend - Runtime suspend method for the driver
> + * @dev:	Address of the device structure
> + *
> + * Put the driver into low power mode.
> + * Return: 0 always
> + */
> +static int __maybe_unused xcan_runtime_suspend(struct device *dev)
> +{
> +	struct net_device *ndev =3D dev_get_drvdata(dev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> =20
>  	if (netif_running(ndev)) {
> @@ -993,18 +1009,18 @@ static int __maybe_unused xcan_suspend(struct de=
vice *dev)
>  }
> =20
>  /**
> - * xcan_resume - Resume from suspend
> - * @dev:	Address of the platformdevice structure
> + * xcan_runtime_resume - Runtime resume from suspend
> + * @dev:	Address of the device structure
>   *
>   * Resume operation after suspend.
>   * Return: 0 on success and failure value on error
>   */
> -static int __maybe_unused xcan_resume(struct device *dev)
> +static int __maybe_unused xcan_runtime_resume(struct device *dev)
>  {
> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct net_device *ndev =3D dev_get_drvdata(dev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>  	int ret;
> +	u32 isr, status;
> =20
>  	ret =3D clk_enable(priv->bus_clk);
>  	if (ret) {
> @@ -1014,15 +1030,28 @@ static int __maybe_unused xcan_resume(struct de=
vice *dev)
>  	ret =3D clk_enable(priv->can_clk);
>  	if (ret) {
>  		dev_err(dev, "Cannot enable clock.\n");
> -		clk_disable_unprepare(priv->bus_clk);
> +		clk_disable(priv->bus_clk);
>  		return ret;
>  	}
> =20
>  	priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>  	priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
> -	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +	isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
> +	status =3D priv->read_reg(priv, XCAN_SR_OFFSET);
> =20
>  	if (netif_running(ndev)) {
> +		if (isr & XCAN_IXR_BSOFF_MASK) {
> +			priv->can.state =3D CAN_STATE_BUS_OFF;
> +			priv->write_reg(priv, XCAN_SRR_OFFSET,
> +					XCAN_SRR_RESET_MASK);
> +		} else if ((status & XCAN_SR_ESTAT_MASK) =3D=3D
> +					XCAN_SR_ESTAT_MASK) {
> +			priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		} else if (status & XCAN_SR_ERRWRN_MASK) {
> +			priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		} else {
> +			priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +		}
>  		netif_device_attach(ndev);
>  		netif_start_queue(ndev);
>  	}
> @@ -1030,7 +1059,10 @@ static int __maybe_unused xcan_resume(struct dev=
ice *dev)
>  	return 0;
>  }
> =20
> -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend, xcan_resume);
> +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
> +	SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
> +	SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume, NULL=
)
> +};
> =20
>  /**
>   * xcan_probe - Platform registration call
> @@ -1071,7 +1103,7 @@ static int xcan_probe(struct platform_device *pde=
v)
>  		return -ENOMEM;
> =20
>  	priv =3D netdev_priv(ndev);
> -	priv->dev =3D ndev;
> +	priv->dev =3D &pdev->dev;
>  	priv->can.bittiming_const =3D &xcan_bittiming_const;
>  	priv->can.do_set_mode =3D xcan_do_set_mode;
>  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
> @@ -1137,6 +1169,16 @@ static int xcan_probe(struct platform_device *pd=
ev)
> =20
>  	netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
> =20
> +	pm_runtime_set_active(&pdev->dev);
> +	pm_runtime_irq_safe(&pdev->dev);
> +	pm_runtime_enable(&pdev->dev);
> +	ret =3D pm_runtime_get_sync(&pdev->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> +			__func__, ret);
> +		goto err_pmdisable;

after err_pmdisable is a runtime_put(), your cleanup is broken.

> +	}
> +
>  	ret =3D register_candev(ndev);
>  	if (ret) {
>  		dev_err(&pdev->dev, "fail to register failed (err=3D%d)\n", ret);
> 		goto err_unprepare_disable_busclk;

I think you have to adjust the jump label.

> 	}
>=20
> 	devm_can_led_init(ndev);
>=20
> 	pm_runtime_put(&pdev->dev);



> @@ -1144,15 +1186,19 @@ static int xcan_probe(struct platform_device *p=
dev)
>  	}
> =20
>  	devm_can_led_init(ndev);
> -	clk_disable_unprepare(priv->bus_clk);
> -	clk_disable_unprepare(priv->can_clk);
> +
> +	pm_runtime_put(&pdev->dev);
> +
>  	netdev_dbg(ndev, "reg_base=3D0x%p irq=3D%d clock=3D%d, tx fifo depth:=
%d\n",
>  			priv->reg_base, ndev->irq, priv->can.clock.freq,
>  			priv->tx_max);
> =20
>  	return 0;
> =20
> +err_pmdisable:
> +	pm_runtime_disable(&pdev->dev);
>  err_unprepare_disable_busclk:
> +	pm_runtime_put(priv->dev);

This cleanup is not correct.

>  	clk_disable_unprepare(priv->bus_clk);
>  err_unprepare_disable_dev:
>  	clk_disable_unprepare(priv->can_clk);
> @@ -1173,12 +1219,23 @@ static int xcan_remove(struct platform_device *=
pdev)
>  {
>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	ret =3D pm_runtime_get_sync(&pdev->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> +				__func__, ret);
> +		return ret;
> +	}
> =20
>  	if (set_reset_mode(ndev) < 0)
>  		netdev_err(ndev, "mode resetting failed!\n");
> =20
>  	unregister_candev(ndev);
> +	pm_runtime_disable(&pdev->dev);
>  	netif_napi_del(&priv->napi);
> +	clk_disable_unprepare(priv->bus_clk);
> +	clk_disable_unprepare(priv->can_clk);
>  	free_candev(ndev);
> =20
>  	return 0;
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--DOoGIEGOFWuAO7v5VUdKXPINbrDqSgOkH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtCYDAAoJECte4hHFiupUnKQP/RwqtUd19MU84O76MYBw3WeR
HymCP+whu2tWiQom5mJS4GDy8YXxvrQUb4j/gBK/npPkOZyK4eZpdCpgmNLSbIhG
VI3+qvC9x5PtfNRBhSfLXW/w7Ivr2ujNLC3AN4rbh1fw3+wkPk17u38hqu2MCPRc
g09xFhCKvPwHf5UzZoPngGSVKXyiKcszqE2jXJxADp4q3SrRfVnh8xgJ4acaxFAT
Z67dp3765fbGTdM8IZjVeoNbtt2U/9l+2X0KK4dNX24ehDjpv+ZgD+nnp65JGZpA
zg/67eDx2i/gTTcsMNYHYPy0VgFCIJolen+cUGb2p5yi3ZVFTOjFJ4DljezVDFAt
b9ftt+e5DXznInOU+THbFnufSaoF5vSG1aQPS/FA2p8u5mG+tDSZmQpXLbsh50Yb
58nlHrcheT4RYRvrixVh8Ye8S47FqDD8FYdfUcctUHSe5HIqiuGkdjlsyXpob5Ej
jraTilk/9y5hjV0+LZ7IbtU1z4Rrz+5l3zWTC6ft7F093Rbui915ABGRItbu6JFs
1Fv/QcnCn8x+szMF3VZ2FCACU4+bmkcO4fZpHAoiu0m24LXMG8MHcxWZXpxYAudw
cTWb9JBUA9n5ac9mT3J7WdnKt4MW96ZdD1Fp8IAQ7jCPqQ110uviLEKciXdgs7Ux
Krw4GBTaEn9pt29ptFMd
=0NZC
-----END PGP SIGNATURE-----

--DOoGIEGOFWuAO7v5VUdKXPINbrDqSgOkH--
