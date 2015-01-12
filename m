From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v5] can: Convert to runtime_pm
Date: Mon, 12 Jan 2015 10:45:04 -0800
Message-ID: <3a3437c5c8ff48d9a45fee7e81fa8dca@BY2FFO11FD058.protection.gbl>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <grant.likely@linaro.org>,
	<robh+dt@kernel.org>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-12 at 08:34PM +0530, Kedareswara rao Appana wrote:
> Instead of enabling/disabling clocks at several locations in the driv=
er,
> Use the runtime_pm framework. This consolidates the actions for runti=
me PM
> In the appropriate callbacks and makes the driver more readable and m=
antainable.
>=20
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
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
>  drivers/net/can/xilinx_can.c |  157 ++++++++++++++++++++++++++++----=
---------
>  1 files changed, 107 insertions(+), 50 deletions(-)
[..]
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
> @@ -1014,15 +1030,28 @@ static int __maybe_unused xcan_resume(struct =
device *dev)
>  	ret =3D clk_enable(priv->can_clk);
>  	if (ret) {
>  		dev_err(dev, "Cannot enable clock.\n");
> -		clk_disable_unprepare(priv->bus_clk);
> +		clk_disable(priv->bus_clk);
[...]
> @@ -1173,12 +1219,23 @@ static int xcan_remove(struct platform_device=
 *pdev)
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

Shouldn't pretty much all these occurrences of clk_disable/enable
disappear? This should all be handled by the runtime_pm framework now.

	S=C3=B6ren
