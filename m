From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v5] can: Convert to runtime_pm
Date: Tue, 13 Jan 2015 09:24:36 -0800
Message-ID: <1ef3e0f060f54c888061514bd2926762@BY2FFO11FD033.protection.gbl>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
 <3a3437c5c8ff48d9a45fee7e81fa8dca@BY2FFO11FD058.protection.gbl>
 <54B4FCB5.6040904@pengutronix.de>
 <6ea3c0ea0f5c4deb9a6e4738a8d94a36@BN1AFFO11FD047.protection.gbl>
 <54B55326.1060606@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	<wg@grandegger.com>, <michal.simek@xilinx.com>,
	<grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B55326.1060606@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-13 at 06:17PM +0100, Marc Kleine-Budde wrote:
> On 01/13/2015 06:08 PM, S=C3=B6ren Brinkmann wrote:
> > On Tue, 2015-01-13 at 12:08PM +0100, Marc Kleine-Budde wrote:
> >> On 01/12/2015 07:45 PM, S=C3=B6ren Brinkmann wrote:
> >>> On Mon, 2015-01-12 at 08:34PM +0530, Kedareswara rao Appana wrote=
:
> >>>> Instead of enabling/disabling clocks at several locations in the=
 driver,
> >>>> Use the runtime_pm framework. This consolidates the actions for =
runtime PM
> >>>> In the appropriate callbacks and makes the driver more readable =
and mantainable.
> >>>>
> >>>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> >>>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> >>>> ---
> >>>> Changes for v5:
> >>>>  - Updated with the review comments.
> >>>>    Updated the remove fuction to use runtime_pm.
> >>>> Chnages for v4:
> >>>>  - Updated with the review comments.
> >>>> Changes for v3:
> >>>>   - Converted the driver to use runtime_pm.
> >>>> Changes for v2:
> >>>>   - Removed the struct platform_device* from suspend/resume
> >>>>     as suggest by Lothar.
> >>>>
> >>>>  drivers/net/can/xilinx_can.c |  157 +++++++++++++++++++++++++++=
+-------------
> >>>>  1 files changed, 107 insertions(+), 50 deletions(-)
> >>> [..]
> >>>> +static int __maybe_unused xcan_runtime_resume(struct device *de=
v)
> >>>>  {
> >>>> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
> >>>> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
> >>>> +	struct net_device *ndev =3D dev_get_drvdata(dev);
> >>>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> >>>>  	int ret;
> >>>> +	u32 isr, status;
> >>>> =20
> >>>>  	ret =3D clk_enable(priv->bus_clk);
> >>>>  	if (ret) {
> >>>> @@ -1014,15 +1030,28 @@ static int __maybe_unused xcan_resume(st=
ruct device *dev)
> >>>>  	ret =3D clk_enable(priv->can_clk);
> >>>>  	if (ret) {
> >>>>  		dev_err(dev, "Cannot enable clock.\n");
> >>>> -		clk_disable_unprepare(priv->bus_clk);
> >>>> +		clk_disable(priv->bus_clk);
> >>> [...]
> >>>> @@ -1173,12 +1219,23 @@ static int xcan_remove(struct platform_d=
evice *pdev)
> >>>>  {
> >>>>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
> >>>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> >>>> +	int ret;
> >>>> +
> >>>> +	ret =3D pm_runtime_get_sync(&pdev->dev);
> >>>> +	if (ret < 0) {
> >>>> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> >>>> +				__func__, ret);
> >>>> +		return ret;
> >>>> +	}
> >>>> =20
> >>>>  	if (set_reset_mode(ndev) < 0)
> >>>>  		netdev_err(ndev, "mode resetting failed!\n");
> >>>> =20
> >>>>  	unregister_candev(ndev);
> >>>> +	pm_runtime_disable(&pdev->dev);
> >>>>  	netif_napi_del(&priv->napi);
> >>>> +	clk_disable_unprepare(priv->bus_clk);
> >>>> +	clk_disable_unprepare(priv->can_clk);
> >>>
> >>> Shouldn't pretty much all these occurrences of clk_disable/enable
> >>> disappear? This should all be handled by the runtime_pm framework=
 now.
> >>
> >> We have:
> >> - clk_prepare_enable() in probe
> >=20
> > This should become something like pm_runtime_get_sync(), shouldn't =
it?
> >=20
> >> - clk_disable_unprepare() in remove
> >=20
> > pm_runtime_put()
> >=20
> >> - clk_enable() in runtime_resume
> >> - clk_disable() in runtime_suspend
> >=20
> > These are the ones needed.
> >=20
> > The above makes me suspect that the clocks are always on, regardles=
s of
>=20
> Define "on" :)
> The clocks are prepared after probe() exists, but not enabled. The fi=
rst
> pm_runtime_get_sync() will enable the clocks.
>=20
> > the runtime suspend state since they are enabled in probe and disab=
led
> > in remove, is that right? Ideally, the usage in probe and remove sh=
ould
> > be migrated to runtime_pm and clocks should really only be running =
when
> > needed and not throughout the whole lifetime of the driver.
>=20
> The clocks are not en/disabled via pm_runtime, because
> pm_runtime_get_sync() is called from atomic contect. We can have anot=
her
> look into the driver and try to change this.

Wasn't that why the call to pm_runtime_irq_safe() was added?
Also, clk_enable/disable should be okay to be run from atomic context.
And if the clock are already prepared after the exit of probe that
should be enough. Then remove() should just have to do the unprepare.
But I don't see why runtime_pm shouldn't be able to do the
enable/disable.

	S=C3=B6ren
