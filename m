From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH v3] can: Convert to runtime_pm
Date: Thu, 27 Nov 2014 15:46:03 -0800
Message-ID: <cb000149727543b5a08b9f56d9cc0626@BN1BFFO11FD036.protection.gbl>
References: <6b6db31d46074512a322eae6e4ef64d4@BN1BFFO11FD038.protection.gbl>
 <54779501.8060009@pengutronix.de>
 <820358d5369f465188dfa9306eae5658@BL2FFO11FD009.protection.gbl>
 <5477ABF3.1020605@pengutronix.de>
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
In-Reply-To: <5477ABF3.1020605@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-27 at 11:55PM +0100, Marc Kleine-Budde wrote:
> On 11/27/2014 11:47 PM, S=C3=B6ren Brinkmann wrote:
> > On Thu, 2014-11-27 at 10:17PM +0100, Marc Kleine-Budde wrote:
> >> On 11/27/2014 02:08 PM, Kedareswara rao Appana wrote:
> >>> Instead of enabling/disabling clocks at several locations in the =
driver,
> >>> use the runtime_pm framework. This consolidates the actions for
> >>> runtime PM in the appropriate callbacks and makes the driver more
> >>> readable and mantainable.
> >>>
> >>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> >>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> >>> ---
> >>> Changes for v3:
> >>>   - Converted the driver to use runtime_pm.
> >>> Changes for v2:
> >>>   - Removed the struct platform_device* from suspend/resume
> >>>     as suggest by Lothar.
> >>>
> >>>  drivers/net/can/xilinx_can.c |  119 +++++++++++++++++++++++++---=
-------------
> >>>  1 files changed, 72 insertions(+), 47 deletions(-)
> >>>
> >>> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilin=
x_can.c
> >>> index 8a998e3..1be28ed 100644
> >>> --- a/drivers/net/can/xilinx_can.c
> >>> +++ b/drivers/net/can/xilinx_can.c
> > [...]
> >>> @@ -1030,7 +1046,10 @@ static int __maybe_unused xcan_resume(stru=
ct device *dev)
> >>>  	return 0;
> >>>  }
> >>> =20
> >>> -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend, xcan_res=
ume);
> >>> +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
> >>> +	SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
> >>> +	SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume=
, NULL)
> >>> +};
> >>> =20
> >>>  /**
> >>>   * xcan_probe - Platform registration call
> >>> @@ -1071,7 +1090,7 @@ static int xcan_probe(struct platform_devic=
e *pdev)
> >>>  		return -ENOMEM;
> >>> =20
> >>>  	priv =3D netdev_priv(ndev);
> >>> -	priv->dev =3D ndev;
> >>> +	priv->dev =3D &pdev->dev;
> >>>  	priv->can.bittiming_const =3D &xcan_bittiming_const;
> >>>  	priv->can.do_set_mode =3D xcan_do_set_mode;
> >>>  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
> >>> @@ -1137,6 +1156,11 @@ static int xcan_probe(struct platform_devi=
ce *pdev)
> >>> =20
> >>>  	netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
> >>> =20
> >>> +	pm_runtime_set_active(&pdev->dev);
> >>> +	pm_runtime_irq_safe(&pdev->dev);
> >>
> >> You use just clock_enable()/disable() in the runtime functions, th=
us you
> >> can say they are irq_safe. On the other the the zync grpio driver =
uses
> >> "full" prepare_enable/disable_unprepare calls. What's best practic=
e here?
> >=20
> > IIRC, the prepare/unprepare functions can sleep. xcan_get_berr_coun=
ter
> > is called from atomic context. So, I think we have to use the
> > disable/enable functions without the prepare/unprepare.
> > In the GPIO driver the that problem does not exist.
>=20
> IC, yes, correct.
>=20
> This is why we introducted in other drivers a __get_berr_counter()
> function, that doesn't touch the clocks, which is used from within th=
e
> driver (from the atomic contects), while get_berr_counter() will fidd=
le
> with the clocks. This function is used for the
> priv->can.do_get_berr_counter callback.

I have the feeling I'm missing something. If I remove the 'must not
sleep' requirement from the runtime suspend/resume functions, I get
this:

BUG: sleeping function called from invalid context at drivers/base/powe=
r/runtime.c:954
in_atomic(): 0, irqs_disabled(): 0, pid: 161, name: ip
INFO: lockdep is turned off.
CPU: 0 PID: 161 Comm: ip Not tainted 3.18.0-rc1-xilinx-00059-g21da26693=
b61-dirty #104
[<c00186a8>] (unwind_backtrace) from [<c00139f4>] (show_stack+0x20/0x24=
)
[<c00139f4>] (show_stack) from [<c055a41c>] (dump_stack+0x8c/0xd0)
[<c055a41c>] (dump_stack) from [<c0054808>] (__might_sleep+0x1ac/0x1e4)
[<c0054808>] (__might_sleep) from [<c034f8f0>] (__pm_runtime_resume+0x4=
0/0x9c)
[<c034f8f0>] (__pm_runtime_resume) from [<c03b48d8>] (xcan_get_berr_cou=
nter+0x2c/0x9c)
[<c03b48d8>] (xcan_get_berr_counter) from [<c03b2ecc>] (can_fill_info+0=
x160/0x1f4)
[<c03b2ecc>] (can_fill_info) from [<c049f3b0>] (rtnl_fill_ifinfo+0x794/=
0x970)
[<c049f3b0>] (rtnl_fill_ifinfo) from [<c04a0048>] (rtnl_dump_ifinfo+0x1=
b4/0x2fc)
[<c04a0048>] (rtnl_dump_ifinfo) from [<c04af9c8>] (netlink_dump+0xe4/0x=
270)
[<c04af9c8>] (netlink_dump) from [<c04b0764>] (__netlink_dump_start+0xd=
c/0x170)
[<c04b0764>] (__netlink_dump_start) from [<c04a1fc4>] (rtnetlink_rcv_ms=
g+0x154/0x1e0)
[<c04a1fc4>] (rtnetlink_rcv_msg) from [<c04b1e88>] (netlink_rcv_skb+0x6=
8/0xc4)
[<c04b1e88>] (netlink_rcv_skb) from [<c04a045c>] (rtnetlink_rcv+0x28/0x=
34)
[<c04a045c>] (rtnetlink_rcv) from [<c04b1770>] (netlink_unicast+0x144/0=
x210)
[<c04b1770>] (netlink_unicast) from [<c04b1c9c>] (netlink_sendmsg+0x394=
/0x414)
[<c04b1c9c>] (netlink_sendmsg) from [<c046ffcc>] (sock_sendmsg+0x8c/0xc=
0)
[<c046ffcc>] (sock_sendmsg) from [<c04726bc>] (SyS_sendto+0xd8/0x114)
[<c04726bc>] (SyS_sendto) from [<c000f3e0>] (ret_fast_syscall+0x0/0x48)

I.e. the core calls this function from atomic context. And in an earlie=
r
thread you said the core can also call this before/after calling the
open/close callbacks (which applies here too, I think).

I think the callback is required to
 - not sleep
 - get the device in a power state that allows querying its registers

So, I don't see how splitting the xcan_get_berr_counter callback helps
here, especially since it is not even used within the driver.

	Thanks,
	S=C3=B6ren
