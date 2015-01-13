From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: Convert to runtime_pm
Date: Tue, 13 Jan 2015 12:08:37 +0100
Message-ID: <54B4FCB5.6040904@pengutronix.de>
References: <baf987c11c0242c2bf87b81f9396b09d@BN1BFFO11FD018.protection.gbl> <3a3437c5c8ff48d9a45fee7e81fa8dca@BY2FFO11FD058.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="tKF0c7NqosXqDUeHMTQh4uD42V9tvVtFR"
Cc: wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <3a3437c5c8ff48d9a45fee7e81fa8dca@BY2FFO11FD058.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--tKF0c7NqosXqDUeHMTQh4uD42V9tvVtFR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2015 07:45 PM, S=C3=B6ren Brinkmann wrote:
> On Mon, 2015-01-12 at 08:34PM +0530, Kedareswara rao Appana wrote:
>> Instead of enabling/disabling clocks at several locations in the drive=
r,
>> Use the runtime_pm framework. This consolidates the actions for runtim=
e PM
>> In the appropriate callbacks and makes the driver more readable and ma=
ntainable.
>>
>> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>> ---
>> Changes for v5:
>>  - Updated with the review comments.
>>    Updated the remove fuction to use runtime_pm.
>> Chnages for v4:
>>  - Updated with the review comments.
>> Changes for v3:
>>   - Converted the driver to use runtime_pm.
>> Changes for v2:
>>   - Removed the struct platform_device* from suspend/resume
>>     as suggest by Lothar.
>>
>>  drivers/net/can/xilinx_can.c |  157 ++++++++++++++++++++++++++++-----=
--------
>>  1 files changed, 107 insertions(+), 50 deletions(-)
> [..]
>> +static int __maybe_unused xcan_runtime_resume(struct device *dev)
>>  {
>> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
>> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
>> +	struct net_device *ndev =3D dev_get_drvdata(dev);
>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>>  	int ret;
>> +	u32 isr, status;
>> =20
>>  	ret =3D clk_enable(priv->bus_clk);
>>  	if (ret) {
>> @@ -1014,15 +1030,28 @@ static int __maybe_unused xcan_resume(struct d=
evice *dev)
>>  	ret =3D clk_enable(priv->can_clk);
>>  	if (ret) {
>>  		dev_err(dev, "Cannot enable clock.\n");
>> -		clk_disable_unprepare(priv->bus_clk);
>> +		clk_disable(priv->bus_clk);
> [...]
>> @@ -1173,12 +1219,23 @@ static int xcan_remove(struct platform_device =
*pdev)
>>  {
>>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>> +	int ret;
>> +
>> +	ret =3D pm_runtime_get_sync(&pdev->dev);
>> +	if (ret < 0) {
>> +		netdev_err(ndev, "%s: pm_runtime_get failed(%d)\n",
>> +				__func__, ret);
>> +		return ret;
>> +	}
>> =20
>>  	if (set_reset_mode(ndev) < 0)
>>  		netdev_err(ndev, "mode resetting failed!\n");
>> =20
>>  	unregister_candev(ndev);
>> +	pm_runtime_disable(&pdev->dev);
>>  	netif_napi_del(&priv->napi);
>> +	clk_disable_unprepare(priv->bus_clk);
>> +	clk_disable_unprepare(priv->can_clk);
>=20
> Shouldn't pretty much all these occurrences of clk_disable/enable
> disappear? This should all be handled by the runtime_pm framework now.

We have:
- clk_prepare_enable() in probe
- clk_disable_unprepare() in remove
- clk_enable() in runtime_resume
- clk_disable() in runtime_suspend

Which is, as far as I understand the right way to do it. Maybe
Kedareswara can post the clock debug output again with this patch
iteration. Have I missed something?

regards,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--tKF0c7NqosXqDUeHMTQh4uD42V9tvVtFR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtPy1AAoJECte4hHFiupUOZwP+wcPUxYKUa1142511vue+Mhp
zWCTdzlvCzAfEAjHD0lMJtD2WQ3nTivLsJtGffa6rzjHqV2qUJ/n/HNTKEGziZjQ
01LaV+yH0m0IoIH+79naXb57YUhATjMt0ho9PuLo4riTrKUsjwTAbbT753QCvRxA
SF9lx21zDeHrA84y3V2qF1fo7JIBo69O5WqUAIZq7re7SolIlqRRa+2IB2SCM/jb
a/f+WGyENHFwqefgZOe17lVwxAyyuxYrW8fZyRv3AvuJqod0AGxe4yL9siFiS4Vw
4CplQugbEbIEKjm/kU5zaKn92+vuz0bYZ9j7+hSqpmFMh+aV67N5RnjR7cXP19Ei
YgMa31imPj8yO+06VVO7iVvdo+bbDLePcIcjby7z0X1kzZAY4oSSIOObTtqCn6Wr
5ycc4SPerI76iJvqsFTxLoZ7XSTdtzVhWLsfNPBO8CECql+PtH/k8iIcqpJq9d+T
n0XaOPGq9DpALKRK0k32TM6eFL7LI+tU/97/iULROOUnCD306WpQwbeTxCqDjwxh
0e9fcvAYzpCRRR38uN3o7GJ9Rde9+dYpacDvT2hiEnNt6sWeyH4UImZy8SHJS70V
up9r75iIs/M/Q1Ap7hKjTGOkD52lats1QmLO//VipM9PxTkbXlI3p0Oq0hkwQe2R
4JT/xCOdxx5TTMpw2Owd
=T8PD
-----END PGP SIGNATURE-----

--tKF0c7NqosXqDUeHMTQh4uD42V9tvVtFR--
