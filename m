From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v4] can: Convert to runtime_pm
Date: Tue, 23 Dec 2014 14:43:08 -0800
Message-ID: <46c28dc78c764efb80cc334df189db3b@BY2FFO11FD055.protection.gbl>
References: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <grant.likely@linaro.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0092.outbound.protection.outlook.com ([157.56.111.92]:46839
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756487AbaLWWnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 17:43:22 -0500
Content-Disposition: inline
In-Reply-To: <58f37b6fd9104ce185c413c473fe047b@BY2FFO11FD050.protection.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-23 at 05:55PM +0530, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driv=
er,
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
>  drivers/net/can/xilinx_can.c |  123 +++++++++++++++++++++++++-------=
----------
>  1 files changed, 74 insertions(+), 49 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_ca=
n.c
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

Does this create the intended output? I haven't seen '\r' anywhere else=
=2E
Shouldn't this simply be:
	netdev_err(ndev, "%s: pm_runtime_get failed (%d)\n",

[...]
> @@ -934,27 +927,20 @@ static int xcan_get_berr_counter(const struct n=
et_device *ndev,
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

ditto

	S=C3=B6ren
