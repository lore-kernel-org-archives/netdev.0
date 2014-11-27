From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v3] can: Convert to runtime_pm
Date: Thu, 27 Nov 2014 10:23:37 -0800
Message-ID: <6268c783e4514fe9bbae2aff8fd75edd@BY2FFO11FD043.protection.gbl>
References: <6b6db31d46074512a322eae6e4ef64d4@BN1BFFO11FD038.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <grant.likely@linaro.org>,
	<robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-can@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6b6db31d46074512a322eae6e4ef64d4@BN1BFFO11FD038.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kedar,

On Thu, 2014-11-27 at 06:38PM +0530, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driv=
er,
> use the runtime_pm framework. This consolidates the actions for
> runtime PM in the appropriate callbacks and makes the driver more
> readable and mantainable.
>=20
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
> Changes for v3:
>   - Converted the driver to use runtime_pm.
> Changes for v2:
>   - Removed the struct platform_device* from suspend/resume
>     as suggest by Lothar.
>=20
>  drivers/net/can/xilinx_can.c |  119 +++++++++++++++++++++++++-------=
---------
>  1 files changed, 72 insertions(+), 47 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_ca=
n.c
> index 8a998e3..1be28ed 100644
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
> +		netdev_err(ndev, "%s: runtime CAN resume failed(%d)\n\r",

There might be other issues than the resume that make this fail. It
should probably just say 'pm_runtime_get failed'.
The CAN in the string should not be needed, the netdev_err macro makes
sure the device name is printed.
Can we have a space between 'failed' and the error code?
There should not be a '\r'

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
> @@ -934,27 +927,21 @@ static int xcan_get_berr_counter(const struct n=
et_device *ndev,
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>  	int ret;
> =20
> -	ret =3D clk_prepare_enable(priv->can_clk);
> -	if (ret)
> -		goto err;
> +	ret =3D pm_runtime_get_sync(priv->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: runtime resume failed(%d)\n\r",
> +				__func__, ret);

As above.

	S=C3=B6ren
