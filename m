From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7] can: xilinx: Convert to runtime_pm
Date: Sun, 25 Oct 2015 21:23:56 +0100
Message-ID: <562D3A5C.9020901@pengutronix.de>
References: <1445577818-26165-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="e6LuNV2iI7hSErhKiDjpXRLACLodhpsFT"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	anirudh@xilinx.com, wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1445577818-26165-1-git-send-email-appanad@xilinx.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--e6LuNV2iI7hSErhKiDjpXRLACLodhpsFT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/23/2015 07:23 AM, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driver=
,
> Use the runtime_pm framework. This consolidates the actions for runtime=
 PM
> In the appropriate callbacks and makes the driver more readable and man=
tainable.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
> Changes for v7:
>   - Removed the unnecessary clk_prepare/clk_unprepare calls
>     From  the probe and remove as suggested by Soren.
> Changes for v6:
>  - Updated the driver with review comments as suggested by Marc.
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
>  drivers/net/can/xilinx_can.c | 177 +++++++++++++++++++++++++----------=
--------
>  1 file changed, 102 insertions(+), 75 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.=
c
> index fc55e8e..fcb584f 100644
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
> @@ -843,6 +844,13 @@ static int xcan_open(struct net_device *ndev)
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
> @@ -850,29 +858,17 @@ static int xcan_open(struct net_device *ndev)
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
> @@ -888,13 +884,11 @@ static int xcan_open(struct net_device *ndev)
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
> @@ -911,12 +905,11 @@ static int xcan_close(struct net_device *ndev)
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
> @@ -935,27 +928,20 @@ static int xcan_get_berr_counter(const struct net=
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
> @@ -968,15 +954,45 @@ static const struct net_device_ops xcan_netdev_op=
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
> @@ -987,43 +1003,55 @@ static int __maybe_unused xcan_suspend(struct de=
vice *dev)
>  	priv->write_reg(priv, XCAN_MSR_OFFSET, XCAN_MSR_SLEEP_MASK);
>  	priv->can.state =3D CAN_STATE_SLEEPING;
> =20
> -	clk_disable(priv->bus_clk);
> -	clk_disable(priv->can_clk);
> +	clk_disable_unprepare(priv->bus_clk);
> +	clk_disable_unprepare(priv->can_clk);
> =20
>  	return 0;
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
> -	ret =3D clk_enable(priv->bus_clk);
> +	ret =3D clk_prepare_enable(priv->bus_clk);
>  	if (ret) {
>  		dev_err(dev, "Cannot enable clock.\n");
>  		return ret;
>  	}
> -	ret =3D clk_enable(priv->can_clk);
> +	ret =3D clk_prepare_enable(priv->can_clk);
>  	if (ret) {
>  		dev_err(dev, "Cannot enable clock.\n");
>  		clk_disable_unprepare(priv->bus_clk);
>  		return ret;
>  	}
> =20
> -	priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
> -	priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
> -	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +	priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_RESET_MASK);
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
> @@ -1031,7 +1059,10 @@ static int __maybe_unused xcan_resume(struct dev=
ice *dev)
>  	return 0;
>  }
> =20
> -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend, xcan_resume);
> +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
> +	SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
> +	SET_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume, NULL)
> +};
> =20
>  /**
>   * xcan_probe - Platform registration call
> @@ -1072,7 +1103,7 @@ static int xcan_probe(struct platform_device *pde=
v)
>  		return -ENOMEM;
> =20
>  	priv =3D netdev_priv(ndev);
> -	priv->dev =3D ndev;
> +	priv->dev =3D &pdev->dev;
>  	priv->can.bittiming_const =3D &xcan_bittiming_const;
>  	priv->can.do_set_mode =3D xcan_do_set_mode;
>  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
> @@ -1114,21 +1145,18 @@ static int xcan_probe(struct platform_device *p=
dev)
>  		}
>  	}
> =20
> -	ret =3D clk_prepare_enable(priv->can_clk);
> -	if (ret) {
> -		dev_err(&pdev->dev, "unable to enable device clock\n");
> -		goto err_free;
> -	}
> -
> -	ret =3D clk_prepare_enable(priv->bus_clk);
> -	if (ret) {
> -		dev_err(&pdev->dev, "unable to enable bus clock\n");
> -		goto err_unprepare_disable_dev;
> -	}
> -
>  	priv->write_reg =3D xcan_write_reg_le;
>  	priv->read_reg =3D xcan_read_reg_le;
> =20
> +	pm_runtime_irq_safe(&pdev->dev);

Have you tested the patch with lockdep enabled? clk_prepare_enable() can
sleep and pm_runtime_irq_safe() says that's it's ok to call the code
from atomic context. Either remove the pm_runtime_irq_safe() or only
call the clk_enable(), clk_disable in the RM runtime handlers.

> +	pm_runtime_enable(&pdev->dev);
> +	ret =3D pm_runtime_get_sync(&pdev->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> +			__func__, ret);
> +		goto err_pmdisable;
> +	}
> +
>  	if (priv->read_reg(priv, XCAN_SR_OFFSET) !=3D XCAN_SR_CONFIG_MASK) {
>  		priv->write_reg =3D xcan_write_reg_be;
>  		priv->read_reg =3D xcan_read_reg_be;
> @@ -1141,22 +1169,23 @@ static int xcan_probe(struct platform_device *p=
dev)
>  	ret =3D register_candev(ndev);
>  	if (ret) {
>  		dev_err(&pdev->dev, "fail to register failed (err=3D%d)\n", ret);
> -		goto err_unprepare_disable_busclk;
> +		goto err_disableclks;
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
> -err_unprepare_disable_busclk:
> -	clk_disable_unprepare(priv->bus_clk);
> -err_unprepare_disable_dev:
> -	clk_disable_unprepare(priv->can_clk);
> +err_disableclks:
> +	pm_runtime_put(priv->dev);
> +err_pmdisable:
> +	pm_runtime_disable(&pdev->dev);
>  err_free:
>  	free_candev(ndev);
>  err:
> @@ -1175,10 +1204,8 @@ static int xcan_remove(struct platform_device *p=
dev)
>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> =20
> -	if (set_reset_mode(ndev) < 0)
> -		netdev_err(ndev, "mode resetting failed!\n");
> -
>  	unregister_candev(ndev);
> +	pm_runtime_disable(&pdev->dev);
>  	netif_napi_del(&priv->napi);
>  	free_candev(ndev);
> =20
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--e6LuNV2iI7hSErhKiDjpXRLACLodhpsFT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWLTpcAAoJEP5prqPJtc/HD3sIAJRzsFD2EOicfb38eBbuDiCx
acPC7jJ3+pZuQhuKPBR6hPlAiSayvjFiMJyXRlrj6pHxrI8NGEWc3hGknvB7LAMU
EOGlDuHWl+3fg9mPMNo5S40mOfsXvgOyfSm8MO4bLxxmrWWsaaRGgUCngc8OYn1b
S3axMk3yKVqZ8MwwlunU+pTJ6FuLGLivwaQH4JRkBZw99egxjq3d98Z/ayp59E9E
C1jkIk8Ts69KVgDxh12JCK8L8dCBde/aJVaXTqXyqKcTT6bc3yVQwLjmgsG9f/gf
hYTWy/4GzZRA+lCygJsnCiTBY37O777tHlnLFu2EZzNqYKdxRZWXjd4fCFV8XTM=
=FBjs
-----END PGP SIGNATURE-----

--e6LuNV2iI7hSErhKiDjpXRLACLodhpsFT--
