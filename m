From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v3] can: Convert to runtime_pm
Date: Thu, 27 Nov 2014 14:47:41 -0800
Message-ID: <820358d5369f465188dfa9306eae5658@BL2FFO11FD009.protection.gbl>
References: <6b6db31d46074512a322eae6e4ef64d4@BN1BFFO11FD038.protection.gbl>
 <54779501.8060009@pengutronix.de>
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
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54779501.8060009@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-27 at 10:17PM +0100, Marc Kleine-Budde wrote:
> On 11/27/2014 02:08 PM, Kedareswara rao Appana wrote:
> > Instead of enabling/disabling clocks at several locations in the dr=
iver,
> > use the runtime_pm framework. This consolidates the actions for
> > runtime PM in the appropriate callbacks and makes the driver more
> > readable and mantainable.
> >=20
> > Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> > Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > ---
> > Changes for v3:
> >   - Converted the driver to use runtime_pm.
> > Changes for v2:
> >   - Removed the struct platform_device* from suspend/resume
> >     as suggest by Lothar.
> >=20
> >  drivers/net/can/xilinx_can.c |  119 +++++++++++++++++++++++++-----=
-----------
> >  1 files changed, 72 insertions(+), 47 deletions(-)
> >=20
> > diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_=
can.c
> > index 8a998e3..1be28ed 100644
> > --- a/drivers/net/can/xilinx_can.c
> > +++ b/drivers/net/can/xilinx_can.c
[...]
> > @@ -1030,7 +1046,10 @@ static int __maybe_unused xcan_resume(struct=
 device *dev)
> >  	return 0;
> >  }
> > =20
> > -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend, xcan_resum=
e);
> > +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
> > +	SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
> > +	SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume, =
NULL)
> > +};
> > =20
> >  /**
> >   * xcan_probe - Platform registration call
> > @@ -1071,7 +1090,7 @@ static int xcan_probe(struct platform_device =
*pdev)
> >  		return -ENOMEM;
> > =20
> >  	priv =3D netdev_priv(ndev);
> > -	priv->dev =3D ndev;
> > +	priv->dev =3D &pdev->dev;
> >  	priv->can.bittiming_const =3D &xcan_bittiming_const;
> >  	priv->can.do_set_mode =3D xcan_do_set_mode;
> >  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
> > @@ -1137,6 +1156,11 @@ static int xcan_probe(struct platform_device=
 *pdev)
> > =20
> >  	netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
> > =20
> > +	pm_runtime_set_active(&pdev->dev);
> > +	pm_runtime_irq_safe(&pdev->dev);
>=20
> You use just clock_enable()/disable() in the runtime functions, thus =
you
> can say they are irq_safe. On the other the the zync grpio driver use=
s
> "full" prepare_enable/disable_unprepare calls. What's best practice h=
ere?

IIRC, the prepare/unprepare functions can sleep. xcan_get_berr_counter
is called from atomic context. So, I think we have to use the
disable/enable functions without the prepare/unprepare.
In the GPIO driver the that problem does not exist.

	S=C3=B6ren
