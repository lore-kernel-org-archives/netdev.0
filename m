From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: Convert to runtime_pm
Date: Thu, 27 Nov 2014 23:55:47 +0100
Message-ID: <5477ABF3.1020605@pengutronix.de>
References: <6b6db31d46074512a322eae6e4ef64d4@BN1BFFO11FD038.protection.gbl> <54779501.8060009@pengutronix.de> <820358d5369f465188dfa9306eae5658@BL2FFO11FD009.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="51knajKoOKTW4w1i0LO6F0CUOfHOJqo0v"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <820358d5369f465188dfa9306eae5658@BL2FFO11FD009.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--51knajKoOKTW4w1i0LO6F0CUOfHOJqo0v
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/27/2014 11:47 PM, S=C3=B6ren Brinkmann wrote:
> On Thu, 2014-11-27 at 10:17PM +0100, Marc Kleine-Budde wrote:
>> On 11/27/2014 02:08 PM, Kedareswara rao Appana wrote:
>>> Instead of enabling/disabling clocks at several locations in the driv=
er,
>>> use the runtime_pm framework. This consolidates the actions for
>>> runtime PM in the appropriate callbacks and makes the driver more
>>> readable and mantainable.
>>>
>>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
>>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>>> ---
>>> Changes for v3:
>>>   - Converted the driver to use runtime_pm.
>>> Changes for v2:
>>>   - Removed the struct platform_device* from suspend/resume
>>>     as suggest by Lothar.
>>>
>>>  drivers/net/can/xilinx_can.c |  119 +++++++++++++++++++++++++-------=
---------
>>>  1 files changed, 72 insertions(+), 47 deletions(-)
>>>
>>> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_ca=
n.c
>>> index 8a998e3..1be28ed 100644
>>> --- a/drivers/net/can/xilinx_can.c
>>> +++ b/drivers/net/can/xilinx_can.c
> [...]
>>> @@ -1030,7 +1046,10 @@ static int __maybe_unused xcan_resume(struct d=
evice *dev)
>>>  	return 0;
>>>  }
>>> =20
>>> -static SIMPLE_DEV_PM_OPS(xcan_dev_pm_ops, xcan_suspend, xcan_resume)=
;
>>> +static const struct dev_pm_ops xcan_dev_pm_ops =3D {
>>> +	SET_SYSTEM_SLEEP_PM_OPS(xcan_suspend, xcan_resume)
>>> +	SET_PM_RUNTIME_PM_OPS(xcan_runtime_suspend, xcan_runtime_resume, NU=
LL)
>>> +};
>>> =20
>>>  /**
>>>   * xcan_probe - Platform registration call
>>> @@ -1071,7 +1090,7 @@ static int xcan_probe(struct platform_device *p=
dev)
>>>  		return -ENOMEM;
>>> =20
>>>  	priv =3D netdev_priv(ndev);
>>> -	priv->dev =3D ndev;
>>> +	priv->dev =3D &pdev->dev;
>>>  	priv->can.bittiming_const =3D &xcan_bittiming_const;
>>>  	priv->can.do_set_mode =3D xcan_do_set_mode;
>>>  	priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
>>> @@ -1137,6 +1156,11 @@ static int xcan_probe(struct platform_device *=
pdev)
>>> =20
>>>  	netif_napi_add(ndev, &priv->napi, xcan_rx_poll, rx_max);
>>> =20
>>> +	pm_runtime_set_active(&pdev->dev);
>>> +	pm_runtime_irq_safe(&pdev->dev);
>>
>> You use just clock_enable()/disable() in the runtime functions, thus y=
ou
>> can say they are irq_safe. On the other the the zync grpio driver uses=

>> "full" prepare_enable/disable_unprepare calls. What's best practice he=
re?
>=20
> IIRC, the prepare/unprepare functions can sleep. xcan_get_berr_counter
> is called from atomic context. So, I think we have to use the
> disable/enable functions without the prepare/unprepare.
> In the GPIO driver the that problem does not exist.

IC, yes, correct.

This is why we introducted in other drivers a __get_berr_counter()
function, that doesn't touch the clocks, which is used from within the
driver (from the atomic contects), while get_berr_counter() will fiddle
with the clocks. This function is used for the
priv->can.do_get_berr_counter callback.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--51knajKoOKTW4w1i0LO6F0CUOfHOJqo0v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUd6vzAAoJECte4hHFiupUCtwP/2b/iHS4WK7Qh9I+lHgv6SEI
XXtKjGJ/ePMtu/23HIONi5Rj5EQSnY0q8umaYJh+iveuOfRPUUMVn+fRRTwluBnC
PVNlRtOyysa7X5dj8FaGGzOn31fs3iSo/A+ZYt/btIv/FdAsYtgCdrqUbMzjc7yX
uA9aG+hbYCFk5DD5hV71gKJGOe00BYYRvnXhGQlwR9rOM4RnCiFQmyOahKjA8c7F
BVGnLZ3NRRK3dwvEwhCJ8zsEDKquPIwz48K2aqVcw3jKV/THoXnd5bMgvGM9BFXq
nZ18nUlyuL4atIYMwyL8AZTDQ2YgGgBWV6bSmjWDbYx5t5XfUz7TIrCQOHNBwhcR
Gg/px8mpZ5J7IAaNulJaAErmhsgJfm+6+yYphxyLXd0D/6wGFSjs3RSjwqfKi4oi
jTeVJ/5N5QQHicKLYmkK/7eD+G8H8OG9RsmEVUW08VmlLFxaB2G4Js32va1J3Thv
xpObEZJPf1C+VfHmNkgvdr/XdICD+yLshSRw/CEwpffLEtl/z/UJj8m+nKX3UXFW
SDmio4LPcLkiT0TpvAyxv0l4iRbxhC4v2ICUn5ntbzyEQ7IUVY9qfCb90gFmpiQm
IU/bFIC1xc2Mbr6F/r5UEAqkmPjAQmluOvo5GtW9IhDY9CC4h6QpOZDPsmZT1y7l
3kPYDUPIsbVmrj99+S+8
=+Uzd
-----END PGP SIGNATURE-----

--51knajKoOKTW4w1i0LO6F0CUOfHOJqo0v--
