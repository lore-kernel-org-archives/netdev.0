From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Wed, 07 Jan 2015 13:28:44 +0100
Message-ID: <54AD267C.4060004@pengutronix.de>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ROCntkijGLSK0rBkPtWddJkxRDHvn3qu6"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>,
	Soren Brinkmann <soren.brinkmann@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com, grant.likely@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ROCntkijGLSK0rBkPtWddJkxRDHvn3qu6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/23/2014 01:25 PM, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driver=
,
> use the runtime_pm framework. This consolidates the actions for
> runtime PM in the appropriate callbacks and makes the driver more
> readable and mantainable.
>=20
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
> Chnages for v4:
>  - Updated with the review comments.
> Changes for v3:
>   - Converted the driver to use runtime_pm.
> Changes for v2:
>   - Removed the struct platform_device* from suspend/resume
>     as suggest by Lothar.
>=20
>  drivers/net/can/xilinx_can.c |  123 +++++++++++++++++++++++++---------=
--------
>  1 files changed, 74 insertions(+), 49 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.=
c
> index 6c67643..c71f683 100644
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
> +		netdev_err(ndev, "%s: pm_runtime_get failed\r(%d)\n\r",
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
> +		netdev_err(ndev, "%s: pm_runtime_get failed\r(%d)\n\r",
> +				__func__, ret);

Please remove the \r from the error messages.

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
> @@ -993,16 +1009,15 @@ static int __maybe_unused xcan_suspend(struct de=
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

Some more context:

> 	ret =3D clk_enable(priv->bus_clk);
> 	if (ret) {
> 		dev_err(dev, "Cannot enable clock.\n");
> 		return ret;
> 	}
> 	ret =3D clk_enable(priv->can_clk);
> 	if (ret) {
> 		dev_err(dev, "Cannot enable clock.\n");
> 		clk_disable_unprepare(priv->bus_clk);

This disable_unprepare looks wrong, should be a disable only.

> 		return ret;
> 	}
>=20
> 	priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
> 	priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>=20
> 	if (netif_running(ndev)) {
> 		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;

What happens if the device was not in ACTIVE state prior to the
runtime_suspend?

> 		netif_device_attach(ndev);
> 		netif_start_queue(ndev);
> 	}
>=20
> 	return 0;
> }


> =20
> @@ -1020,9 +1035,9 @@ static int __maybe_unused xcan_resume(struct devi=
ce *dev)
> =20
>  	priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>  	priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
> -	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
>  	if (netif_running(ndev)) {
> +		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>  		netif_device_attach(ndev);
>  		netif_start_queue(ndev);
>  	}
> @@ -1030,7 +1045,10 @@ static int __maybe_unused xcan_resume(struct dev=
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
> @@ -1071,7 +1089,7 @@ static int xcan_probe(struct platform_device *pde=
v)
>  		return -ENOMEM;
> =20
>  	priv =3D netdev_priv(ndev);
> -	priv->dev =3D ndev;
> +	priv->dev =3D &pdev->dev;
>  	priv->can.bittiming_const =3D &xcan_bittiming_const;
>  	priv->can.do_set_mode =3D xcan_do_set_mode;
>  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
> @@ -1137,15 +1155,22 @@ static int xcan_probe(struct platform_device *p=
dev)
> =20
>  	netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
> =20
> +	pm_runtime_set_active(&pdev->dev);
> +	pm_runtime_irq_safe(&pdev->dev);
> +	pm_runtime_enable(&pdev->dev);
> +	pm_runtime_get_sync(&pdev->dev);
Check error values?
> +
>  	ret =3D register_candev(ndev);
>  	if (ret) {
>  		dev_err(&pdev->dev, "fail to register failed (err=3D%d)\n", ret);
> +		pm_runtime_put(priv->dev);

Please move the pm_runtime_put into the common error exit path.

>  		goto err_unprepare_disable_busclk;
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
>=20

I think you have to convert the _remove() function, too. Have a look at
the gpio-zynq.c driver:

> static int zynq_gpio_remove(struct platform_device *pdev)
> {
> 	struct zynq_gpio *gpio =3D platform_get_drvdata(pdev);
>=20
> 	pm_runtime_get_sync(&pdev->dev);

However I don't understand why the get_sync() is here. Maybe S=C3=B6ren c=
an help?
=09
> 	gpiochip_remove(&gpio->chip);
> 	clk_disable_unprepare(gpio->clk);
> 	device_set_wakeup_capable(&pdev->dev, 0);
> 	return 0;
> }

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ROCntkijGLSK0rBkPtWddJkxRDHvn3qu6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrSZ8AAoJECte4hHFiupUfGsP/RAcUSl1B7eOJ5y9W8GEeBkF
AVL15ABsryhowfyWJPJDvdseWgJJzS0+SY2l/wAx8IDYdDgjahMtl1OeHQOuq08O
wlrv8BWhDVdZ6xAoAF4BjpVNB/QQ3esCBihmJ7eMH2i2vJgUJ1CXL2LRpf6FW/Dp
xcPKE9Td4ll6U63vz9UdspMLbyhfWqnk5NKb9jw0nnOV3MLHamtUBuH1MYDbYu24
RtvJG2owUWYP2lVIbV/Q3p3POiKv6eJiYufS1IcIhYQ/FttZESI/G9NADh/ZRgI/
XRowKMToxxeuNNYN/JrvTSAJ+T9UHeEBHGRhjzIMqmPLt8c6HamvD8vziPsNXNlq
6pGiPMA8PkueEaS3tawLVz31CVjlaCDJF1MA6puFCsu6aZs7TsJ3hMdxu4WM36w9
yVhgqCS17N7BQkYW4QCFPXSHgZb+yrt+2nrQKnf5L4PBwqkXXj152ats2WKpo1rz
bSLolgThznx6/dFFfVZTetoFeLX0MjzqVz3FvVTsThXTV3X2qaLtZ5StueVvrSEq
rsEgr5sjJ6d1M8stn1cDZVTsvgUZxUtR1gXvYS/thzDQmUNNzXffEISWxNahQK5K
tM4sYXNOskaoNut96hqNRWVYJ0y4XPyijWWqMSpsS9gcjKS2rWmNsyYIpB5o39cf
tXTPMETE1cuzuEqZ6CpB
=Riuy
-----END PGP SIGNATURE-----

--ROCntkijGLSK0rBkPtWddJkxRDHvn3qu6--
