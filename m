From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v6] can: xilinx: Convert to runtime_pm
Date: Thu, 22 Oct 2015 15:13:20 -0700
Message-ID: <20151022221320.GQ5257@xsjsorenbubuntu>
References: <1445489120-10933-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <anirudh@xilinx.com>, <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445489120-10933-1-git-send-email-appanad@xilinx.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kedar,

On Thu, 2015-10-22 at 10:15AM +0530, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driv=
er,
> Use the runtime_pm framework. This consolidates the actions for runti=
me PM
> In the appropriate callbacks and makes the driver more readable and m=
antainable.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
[...]
>  /**
>   * xcan_probe - Platform registration call
> @@ -1072,7 +1103,7 @@ static int xcan_probe(struct platform_device *p=
dev)
>  		return -ENOMEM;
> =20
>  	priv =3D netdev_priv(ndev);
> -	priv->dev =3D ndev;
> +	priv->dev =3D &pdev->dev;
>  	priv->can.bittiming_const =3D &xcan_bittiming_const;
>  	priv->can.do_set_mode =3D xcan_do_set_mode;
>  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
> @@ -1114,21 +1145,30 @@ static int xcan_probe(struct platform_device =
*pdev)
>  		}
>  	}
> =20
> -	ret =3D clk_prepare_enable(priv->can_clk);
> +	ret =3D clk_prepare(priv->can_clk);
>  	if (ret) {
>  		dev_err(&pdev->dev, "unable to enable device clock\n");
>  		goto err_free;
>  	}
> =20
> -	ret =3D clk_prepare_enable(priv->bus_clk);
> +	ret =3D clk_prepare(priv->bus_clk);

Are these clk_prepare calls needed here? The runtime PM calls do
clk_prepare_enable and clk_disable_unprepare.

>  	if (ret) {
>  		dev_err(&pdev->dev, "unable to enable bus clock\n");
> -		goto err_unprepare_disable_dev;
> +		goto err_unprepare_dev;
>  	}
> =20
>  	priv->write_reg =3D xcan_write_reg_le;
>  	priv->read_reg =3D xcan_read_reg_le;
> =20
> +	pm_runtime_irq_safe(&pdev->dev);
> +	pm_runtime_enable(&pdev->dev);
> +	ret =3D pm_runtime_get_sync(&pdev->dev);
> +	if (ret < 0) {
> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> +			__func__, ret);
> +		goto err_unprepare_busclk;
> +	}
> +
>  	if (priv->read_reg(priv, XCAN_SR_OFFSET) !=3D XCAN_SR_CONFIG_MASK) =
{
>  		priv->write_reg =3D xcan_write_reg_be;
>  		priv->read_reg =3D xcan_read_reg_be;
> @@ -1141,22 +1181,26 @@ static int xcan_probe(struct platform_device =
*pdev)
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
>  	netdev_dbg(ndev, "reg_base=3D0x%p irq=3D%d clock=3D%d, tx fifo dept=
h:%d\n",
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
> +err_unprepare_busclk:
> +	pm_runtime_disable(&pdev->dev);
> +	clk_unprepare(priv->bus_clk);
> +err_unprepare_dev:
> +	clk_unprepare(priv->can_clk);
>  err_free:
>  	free_candev(ndev);
>  err:
> @@ -1175,11 +1219,11 @@ static int xcan_remove(struct platform_device=
 *pdev)
>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> =20
> -	if (set_reset_mode(ndev) < 0)
> -		netdev_err(ndev, "mode resetting failed!\n");
> -
>  	unregister_candev(ndev);
> +	pm_runtime_disable(&pdev->dev);
>  	netif_napi_del(&priv->napi);
> +	clk_unprepare(priv->bus_clk);
> +	clk_unprepare(priv->can_clk);

I think this can go away when the prepare calls in probe go away.

	Thanks,
	S=C3=B6ren
