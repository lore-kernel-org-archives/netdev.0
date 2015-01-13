From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: Convert to runtime_pm
Date: Tue, 13 Jan 2015 19:03:32 +0100
Message-ID: <54B55DF4.2090505@pengutronix.de>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl> <3a3437c5c8ff48d9a45fee7e81fa8dca@BY2FFO11FD058.protection.gbl> <54B4FCB5.6040904@pengutronix.de> <6ea3c0ea0f5c4deb9a6e4738a8d94a36@BN1AFFO11FD047.protection.gbl> <54B55326.1060606@pengutronix.de> <1ef3e0f060f54c888061514bd2926762@BY2FFO11FD033.protection.gbl> <54B55993.4020806@pengutronix.de> <922ff1827dfb484bbc42dbb56649d4b4@BN1BFFO11FD013.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="SEhNSrAsSAQLiljcMkceg6CWMXUW3We6F"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <922ff1827dfb484bbc42dbb56649d4b4@BN1BFFO11FD013.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SEhNSrAsSAQLiljcMkceg6CWMXUW3We6F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/13/2015 06:49 PM, S=C3=B6ren Brinkmann wrote:
> On Tue, 2015-01-13 at 06:44PM +0100, Marc Kleine-Budde wrote:
>> On 01/13/2015 06:24 PM, S=C3=B6ren Brinkmann wrote:
>>> On Tue, 2015-01-13 at 06:17PM +0100, Marc Kleine-Budde wrote:
>>>> On 01/13/2015 06:08 PM, S=C3=B6ren Brinkmann wrote:
>>>>> On Tue, 2015-01-13 at 12:08PM +0100, Marc Kleine-Budde wrote:
>>>>>> On 01/12/2015 07:45 PM, S=C3=B6ren Brinkmann wrote:
>>>>>>> On Mon, 2015-01-12 at 08:34PM +0530, Kedareswara rao Appana wrote=
:
>>>>>>>> Instead of enabling/disabling clocks at several locations in the=
 driver,
>>>>>>>> Use the runtime_pm framework. This consolidates the actions for =
runtime PM
>>>>>>>> In the appropriate callbacks and makes the driver more readable =
and mantainable.
>>>>>>>>
>>>>>>>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
>>>>>>>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>>>>>>>> ---
>>>>>>>> Changes for v5:
>>>>>>>>  - Updated with the review comments.
>>>>>>>>    Updated the remove fuction to use runtime_pm.
>>>>>>>> Chnages for v4:
>>>>>>>>  - Updated with the review comments.
>>>>>>>> Changes for v3:
>>>>>>>>   - Converted the driver to use runtime_pm.
>>>>>>>> Changes for v2:
>>>>>>>>   - Removed the struct platform_device* from suspend/resume
>>>>>>>>     as suggest by Lothar.
>>>>>>>>
>>>>>>>>  drivers/net/can/xilinx_can.c |  157 +++++++++++++++++++++++++++=
+-------------
>>>>>>>>  1 files changed, 107 insertions(+), 50 deletions(-)
>>>>>>> [..]
>>>>>>>> +static int __maybe_unused xcan_runtime_resume(struct device *de=
v)
>>>>>>>>  {
>>>>>>>> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
>>>>>>>> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
>>>>>>>> +	struct net_device *ndev =3D dev_get_drvdata(dev);
>>>>>>>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>>>>>>>>  	int ret;
>>>>>>>> +	u32 isr, status;
>>>>>>>> =20
>>>>>>>>  	ret =3D clk_enable(priv->bus_clk);
>>>>>>>>  	if (ret) {
>>>>>>>> @@ -1014,15 +1030,28 @@ static int __maybe_unused xcan_resume(st=
ruct device *dev)
>>>>>>>>  	ret =3D clk_enable(priv->can_clk);
>>>>>>>>  	if (ret) {
>>>>>>>>  		dev_err(dev, "Cannot enable clock.\n");
>>>>>>>> -		clk_disable_unprepare(priv->bus_clk);
>>>>>>>> +		clk_disable(priv->bus_clk);
>>>>>>> [...]
>>>>>>>> @@ -1173,12 +1219,23 @@ static int xcan_remove(struct platform_d=
evice *pdev)
>>>>>>>>  {
>>>>>>>>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>>>>>>>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>>>>>>>> +	int ret;
>>>>>>>> +
>>>>>>>> +	ret =3D pm_runtime_get_sync(&pdev->dev);
>>>>>>>> +	if (ret < 0) {
>>>>>>>> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
>>>>>>>> +				__func__, ret);
>>>>>>>> +		return ret;
>>>>>>>> +	}
>>>>>>>> =20
>>>>>>>>  	if (set_reset_mode(ndev) < 0)
>>>>>>>>  		netdev_err(ndev, "mode resetting failed!\n");
>>>>>>>> =20
>>>>>>>>  	unregister_candev(ndev);
>>>>>>>> +	pm_runtime_disable(&pdev->dev);
>>>>>>>>  	netif_napi_del(&priv->napi);
>>>>>>>> +	clk_disable_unprepare(priv->bus_clk);
>>>>>>>> +	clk_disable_unprepare(priv->can_clk);
>>>>>>>
>>>>>>> Shouldn't pretty much all these occurrences of clk_disable/enable=

>>>>>>> disappear? This should all be handled by the runtime_pm framework=
 now.
>>>>>>
>>>>>> We have:
>>>>>> - clk_prepare_enable() in probe
>>>>>
>>>>> This should become something like pm_runtime_get_sync(), shouldn't =
it?
>>>>>
>>>>>> - clk_disable_unprepare() in remove
>>>>>
>>>>> pm_runtime_put()
>>>>>
>>>>>> - clk_enable() in runtime_resume
>>>>>> - clk_disable() in runtime_suspend
>>>>>
>>>>> These are the ones needed.
>>>>>
>>>>> The above makes me suspect that the clocks are always on, regardles=
s of
>>>>
>>>> Define "on" :)
>>>> The clocks are prepared after probe() exists, but not enabled. The f=
irst
>>>> pm_runtime_get_sync() will enable the clocks.
>>>>
>>>>> the runtime suspend state since they are enabled in probe and disab=
led
>>>>> in remove, is that right? Ideally, the usage in probe and remove sh=
ould
>>>>> be migrated to runtime_pm and clocks should really only be running =
when
>>>>> needed and not throughout the whole lifetime of the driver.
>>>>
>>>> The clocks are not en/disabled via pm_runtime, because
>>>> pm_runtime_get_sync() is called from atomic contect. We can have ano=
ther
>>>> look into the driver and try to change this.
>>
>>> Wasn't that why the call to pm_runtime_irq_safe() was added?
>>
>> Good question. That should be investigated.
>>
>>> Also, clk_enable/disable should be okay to be run from atomic context=
=2E
>>> And if the clock are already prepared after the exit of probe that
>>> should be enough. Then remove() should just have to do the unprepare.=

>>> But I don't see why runtime_pm shouldn't be able to do the
>>> enable/disable.
>>
>> runtime_pm does call the clk_{enable,disable} function. But you mean
>> clk_prepare() + pm_runtime_get_sync() should be used in probe() instea=
d
>> of calling clk_prepare_enable(). Good idea! I think the
>> "pm_runtime_set_active(&pdev->dev);" has to be removed from the patch.=

>=20
> Right, that's what I was thinking. The proposed changes make sense, IMH=
O.
>=20
>>
>> Coming back whether blocking calls are allowed or not.
>> If you make a call to pm_runtime_irq_safe(), you state that it's okay =
to
>> call pm_runtime_get_sync() from atomic context. But it's only called i=
n
>> open, probe, remove and in xcan_get_berr_counter, which is not called
>> from atomic either. So let's try to remove the pm_runtime_irq_safe() a=
nd
>> use clk_prepare_enable() clk_disable_unprepare() in the runtime_resume=
()
>> runtime_suspend() functions.
>=20
> IIRC, xcan_get_berr_counter() is called from atomic context. I think
> that was how this got started.

In some drivers the get_berr_counter() function is used in the irq
handler, but here it's only called from outside, an thus from non atomic
context.

=46rom an older mail of yours:

> I have the feeling I'm missing something. If I remove the 'must not
> sleep' requirement from the runtime suspend/resume functions, I get
> this:
>=20
> BUG: sleeping function called from invalid context at drivers/base/powe=
r/runtime.c:954

http://lxr.free-electrons.com/source/drivers/base/power/runtime.c#L954

I think it's failing because of the pm_runtime_irq_safe() call.

> in_atomic(): 0, irqs_disabled(): 0, pid: 161, name: ip
> INFO: lockdep is turned off.
> CPU: 0 PID: 161 Comm: ip Not tainted 3.18.0-rc1-xilinx-00059-g21da26693=
b61-dirty #104
> [<c00186a8>] (unwind_backtrace) from [<c00139f4>] (show_stack+0x20/0x24=
)
> [<c00139f4>] (show_stack) from [<c055a41c>] (dump_stack+0x8c/0xd0)
> [<c055a41c>] (dump_stack) from [<c0054808>] (__might_sleep+0x1ac/0x1e4)=

> [<c0054808>] (__might_sleep) from [<c034f8f0>] (__pm_runtime_resume+0x4=
0/0x9c)
> [<c034f8f0>] (__pm_runtime_resume) from [<c03b48d8>] (xcan_get_berr_cou=
nter+0x2c/0x9c)
> [<c03b48d8>] (xcan_get_berr_counter) from [<c03b2ecc>] (can_fill_info+0=
x160/0x1f4)
> [<c03b2ecc>] (can_fill_info) from [<c049f3b0>] (rtnl_fill_ifinfo+0x794/=
0x970)
> [<c049f3b0>] (rtnl_fill_ifinfo) from [<c04a0048>] (rtnl_dump_ifinfo+0x1=
b4/0x2fc)
> [<c04a0048>] (rtnl_dump_ifinfo) from [<c04af9c8>] (netlink_dump+0xe4/0x=
270)
> [<c04af9c8>] (netlink_dump) from [<c04b0764>] (__netlink_dump_start+0xd=
c/0x170)
> [<c04b0764>] (__netlink_dump_start) from [<c04a1fc4>] (rtnetlink_rcv_ms=
g+0x154/0x1e0)
> [<c04a1fc4>] (rtnetlink_rcv_msg) from [<c04b1e88>] (netlink_rcv_skb+0x6=
8/0xc4)
> [<c04b1e88>] (netlink_rcv_skb) from [<c04a045c>] (rtnetlink_rcv+0x28/0x=
34)
> [<c04a045c>] (rtnetlink_rcv) from [<c04b1770>] (netlink_unicast+0x144/0=
x210)
> [<c04b1770>] (netlink_unicast) from [<c04b1c9c>] (netlink_sendmsg+0x394=
/0x414)
> [<c04b1c9c>] (netlink_sendmsg) from [<c046ffcc>] (sock_sendmsg+0x8c/0xc=
0)
> [<c046ffcc>] (sock_sendmsg) from [<c04726bc>] (SyS_sendto+0xd8/0x114)
> [<c04726bc>] (SyS_sendto) from [<c000f3e0>] (ret_fast_syscall+0x0/0x48)=

>=20
> I.e. the core calls this function from atomic context. And in an earlie=
r
> thread you said the core can also call this before/after calling the
> open/close callbacks (which applies here too, I think).

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--SEhNSrAsSAQLiljcMkceg6CWMXUW3We6F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtV30AAoJECte4hHFiupUTAkP/3oxzW+dLkJ1G5cGI9Fg8lSp
h4E0dX88j9ZYBucN6h7xdpe5gUx7sSKwfOnI14YjHt3xNBsdq3tAkZsipCNR9NMZ
Vb4eX9hJY2ZaiJf3uJbmNe0zDKPfb5Z9jcdo+ONULl/shnyudIqnSuq8Qp/LskJ8
1FwQ+tUH5qIQUvoBLRpYZw5i+k2lEY05k8rK92J0bn/E6L6HV0FphnVkT9GeJIxC
2/8VQheuZxDd3Ii9HeD1I4esIhRDXoB4aOxtJPow4Zg89YehuVrzN65G9clLBPhU
4vhR7P4YIW5/SwmeY+pz1xJpSdlMH0ZzKhtquYhhEDv1ULxWbDp50J47OrWdBouQ
81lbCtcQaO6V9Fq53t+qXCJytQ6v4HZECGy1GuySoeHmoJzcZVG19r/PxGMP8q8Z
7EATM26B3I3buclWdkyzpCpN3jsSynLM1vSOU8HOMAWTWzwBeCOoroPyqb9Qr6Vg
Y8Z28X8+tHAnsYfpYlU3AoSRYyS+bDCgHeVYxHvBUUsYOgMdhUFbJwY7lKiVbkaQ
hs8qCaYstGFIxuXp4bSnIALkrtXwewSFt5rHlmX6rSEowTjC0iyhv1nKBX5T9oEU
e7FOzAxxIORNFs9yuv0E/OyPNXhnR5bKGydp6rpDZQXH49gvl8KB/vgwSp9I3cI/
hncOGO72BGIRjyETHsaD
=x6mL
-----END PGP SIGNATURE-----

--SEhNSrAsSAQLiljcMkceg6CWMXUW3We6F--
