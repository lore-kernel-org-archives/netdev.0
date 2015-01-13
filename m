From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5] can: Convert to runtime_pm
Date: Tue, 13 Jan 2015 10:43:54 -0800
Message-ID: <07e66b114b764211b8f04b4c53462181@BY2FFO11FD046.protection.gbl>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl>
 <3a3437c5c8ff48d9a45fee7e81fa8dca@BY2FFO11FD058.protection.gbl>
 <54B4FCB5.6040904@pengutronix.de>
 <6ea3c0ea0f5c4deb9a6e4738a8d94a36@BN1AFFO11FD047.protection.gbl>
 <54B55326.1060606@pengutronix.de>
 <1ef3e0f060f54c888061514bd2926762@BY2FFO11FD033.protection.gbl>
 <54B55993.4020806@pengutronix.de>
 <922ff1827dfb484bbc42dbb56649d4b4@BN1BFFO11FD013.protection.gbl>
 <54B55DF4.2090505@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <54B55DF4.2090505-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-13 at 07:03PM +0100, Marc Kleine-Budde wrote:
> On 01/13/2015 06:49 PM, S=C3=B6ren Brinkmann wrote:
> > On Tue, 2015-01-13 at 06:44PM +0100, Marc Kleine-Budde wrote:
> >> On 01/13/2015 06:24 PM, S=C3=B6ren Brinkmann wrote:
> >>> On Tue, 2015-01-13 at 06:17PM +0100, Marc Kleine-Budde wrote:
> >>>> On 01/13/2015 06:08 PM, S=C3=B6ren Brinkmann wrote:
> >>>>> On Tue, 2015-01-13 at 12:08PM +0100, Marc Kleine-Budde wrote:
> >>>>>> On 01/12/2015 07:45 PM, S=C3=B6ren Brinkmann wrote:
> >>>>>>> On Mon, 2015-01-12 at 08:34PM +0530, Kedareswara rao Appana w=
rote:
> >>>>>>>> Instead of enabling/disabling clocks at several locations in=
 the driver,
> >>>>>>>> Use the runtime_pm framework. This consolidates the actions =
for runtime PM
> >>>>>>>> In the appropriate callbacks and makes the driver more reada=
ble and mantainable.
> >>>>>>>>
> >>>>>>>> Signed-off-by: Soren Brinkmann <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> >>>>>>>> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> >>>>>>>> ---
> >>>>>>>> Changes for v5:
> >>>>>>>>  - Updated with the review comments.
> >>>>>>>>    Updated the remove fuction to use runtime_pm.
> >>>>>>>> Chnages for v4:
> >>>>>>>>  - Updated with the review comments.
> >>>>>>>> Changes for v3:
> >>>>>>>>   - Converted the driver to use runtime_pm.
> >>>>>>>> Changes for v2:
> >>>>>>>>   - Removed the struct platform_device* from suspend/resume
> >>>>>>>>     as suggest by Lothar.
> >>>>>>>>
> >>>>>>>>  drivers/net/can/xilinx_can.c |  157 +++++++++++++++++++++++=
+++++-------------
> >>>>>>>>  1 files changed, 107 insertions(+), 50 deletions(-)
> >>>>>>> [..]
> >>>>>>>> +static int __maybe_unused xcan_runtime_resume(struct device=
 *dev)
> >>>>>>>>  {
> >>>>>>>> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
> >>>>>>>> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
> >>>>>>>> +	struct net_device *ndev =3D dev_get_drvdata(dev);
> >>>>>>>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> >>>>>>>>  	int ret;
> >>>>>>>> +	u32 isr, status;
> >>>>>>>> =20
> >>>>>>>>  	ret =3D clk_enable(priv->bus_clk);
> >>>>>>>>  	if (ret) {
> >>>>>>>> @@ -1014,15 +1030,28 @@ static int __maybe_unused xcan_resum=
e(struct device *dev)
> >>>>>>>>  	ret =3D clk_enable(priv->can_clk);
> >>>>>>>>  	if (ret) {
> >>>>>>>>  		dev_err(dev, "Cannot enable clock.\n");
> >>>>>>>> -		clk_disable_unprepare(priv->bus_clk);
> >>>>>>>> +		clk_disable(priv->bus_clk);
> >>>>>>> [...]
> >>>>>>>> @@ -1173,12 +1219,23 @@ static int xcan_remove(struct platfo=
rm_device *pdev)
> >>>>>>>>  {
> >>>>>>>>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
> >>>>>>>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> >>>>>>>> +	int ret;
> >>>>>>>> +
> >>>>>>>> +	ret =3D pm_runtime_get_sync(&pdev->dev);
> >>>>>>>> +	if (ret < 0) {
> >>>>>>>> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
> >>>>>>>> +				__func__, ret);
> >>>>>>>> +		return ret;
> >>>>>>>> +	}
> >>>>>>>> =20
> >>>>>>>>  	if (set_reset_mode(ndev) < 0)
> >>>>>>>>  		netdev_err(ndev, "mode resetting failed!\n");
> >>>>>>>> =20
> >>>>>>>>  	unregister_candev(ndev);
> >>>>>>>> +	pm_runtime_disable(&pdev->dev);
> >>>>>>>>  	netif_napi_del(&priv->napi);
> >>>>>>>> +	clk_disable_unprepare(priv->bus_clk);
> >>>>>>>> +	clk_disable_unprepare(priv->can_clk);
> >>>>>>>
> >>>>>>> Shouldn't pretty much all these occurrences of clk_disable/en=
able
> >>>>>>> disappear? This should all be handled by the runtime_pm frame=
work now.
> >>>>>>
> >>>>>> We have:
> >>>>>> - clk_prepare_enable() in probe
> >>>>>
> >>>>> This should become something like pm_runtime_get_sync(), should=
n't it?
> >>>>>
> >>>>>> - clk_disable_unprepare() in remove
> >>>>>
> >>>>> pm_runtime_put()
> >>>>>
> >>>>>> - clk_enable() in runtime_resume
> >>>>>> - clk_disable() in runtime_suspend
> >>>>>
> >>>>> These are the ones needed.
> >>>>>
> >>>>> The above makes me suspect that the clocks are always on, regar=
dless of
> >>>>
> >>>> Define "on" :)
> >>>> The clocks are prepared after probe() exists, but not enabled. T=
he first
> >>>> pm_runtime_get_sync() will enable the clocks.
> >>>>
> >>>>> the runtime suspend state since they are enabled in probe and d=
isabled
> >>>>> in remove, is that right? Ideally, the usage in probe and remov=
e should
> >>>>> be migrated to runtime_pm and clocks should really only be runn=
ing when
> >>>>> needed and not throughout the whole lifetime of the driver.
> >>>>
> >>>> The clocks are not en/disabled via pm_runtime, because
> >>>> pm_runtime_get_sync() is called from atomic contect. We can have=
 another
> >>>> look into the driver and try to change this.
> >>
> >>> Wasn't that why the call to pm_runtime_irq_safe() was added?
> >>
> >> Good question. That should be investigated.
> >>
> >>> Also, clk_enable/disable should be okay to be run from atomic con=
text.
> >>> And if the clock are already prepared after the exit of probe tha=
t
> >>> should be enough. Then remove() should just have to do the unprep=
are.
> >>> But I don't see why runtime_pm shouldn't be able to do the
> >>> enable/disable.
> >>
> >> runtime_pm does call the clk_{enable,disable} function. But you me=
an
> >> clk_prepare() + pm_runtime_get_sync() should be used in probe() in=
stead
> >> of calling clk_prepare_enable(). Good idea! I think the
> >> "pm_runtime_set_active(&pdev->dev);" has to be removed from the pa=
tch.
> >=20
> > Right, that's what I was thinking. The proposed changes make sense,=
 IMHO.
> >=20
> >>
> >> Coming back whether blocking calls are allowed or not.
> >> If you make a call to pm_runtime_irq_safe(), you state that it's o=
kay to
> >> call pm_runtime_get_sync() from atomic context. But it's only call=
ed in
> >> open, probe, remove and in xcan_get_berr_counter, which is not cal=
led
> >> from atomic either. So let's try to remove the pm_runtime_irq_safe=
() and
> >> use clk_prepare_enable() clk_disable_unprepare() in the runtime_re=
sume()
> >> runtime_suspend() functions.
> >=20
> > IIRC, xcan_get_berr_counter() is called from atomic context. I thin=
k
> > that was how this got started.
>=20
> In some drivers the get_berr_counter() function is used in the irq
> handler, but here it's only called from outside, an thus from non ato=
mic
> context.
>=20
> From an older mail of yours:
>=20
> > I have the feeling I'm missing something. If I remove the 'must not
> > sleep' requirement from the runtime suspend/resume functions, I get
> > this:
> >=20
> > BUG: sleeping function called from invalid context at drivers/base/=
power/runtime.c:954
>=20
> http://lxr.free-electrons.com/source/drivers/base/power/runtime.c#L95=
4
>=20
> I think it's failing because of the pm_runtime_irq_safe() call.

Adding that call fixed this issue.

	S=C3=B6ren
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
