From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: Fix bug in suspend/resume
Date: Thu, 13 Nov 2014 11:46:12 +0100
Message-ID: <54648BF4.60007@pengutronix.de>
References: <a44efc1fb0144cca9d0c4851cc51db25@BL2FFO11FD024.protection.gbl> <546484D9.4030005@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="JDTIScx6ajdfsQADus7HgWIFDNJFgeGnv"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, grant.likely@linaro.org,
	robh+dt@kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <546484D9.4030005@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JDTIScx6ajdfsQADus7HgWIFDNJFgeGnv
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2014 11:15 AM, Marc Kleine-Budde wrote:
> On 11/13/2014 07:58 AM, Kedareswara rao Appana wrote:
>> When accessing the priv structure use container_of instead of dev_get_=
drvdata.
>=20
> Why?

The drvdata here is the struct net_device, not the platform device.
Please state this in the commit message.

If I understand the code correct, you can make use of the existing
helper function to_platform_device():

http://lxr.free-electrons.com/source/include/linux/platform_device.h#L42

>=20
>> Enable the clocks in the suspend before accessing the registers of the=
 CAN.
>>
>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>> ---
>>  drivers/net/can/xilinx_can.c |   20 ++++++++++++++++++--
>>  1 files changed, 18 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can=
=2Ec
>> index 5e8b560..63ef645 100644
>> --- a/drivers/net/can/xilinx_can.c
>> +++ b/drivers/net/can/xilinx_can.c
>> @@ -972,15 +972,30 @@ static const struct net_device_ops xcan_netdev_o=
ps =3D {
>>   */
>>  static int __maybe_unused xcan_suspend(struct device *dev)
>>  {
>> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
>> +	struct platform_device *pdev =3D container_of(dev,
>> +			struct platform_device, dev);
>>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>> +	int ret;
>> =20
>>  	if (netif_running(ndev)) {
>>  		netif_stop_queue(ndev);
>>  		netif_device_detach(ndev);
>>  	}
>> =20
>> +	ret =3D clk_prepare_enable(priv->can_clk);
>> +	if (ret) {
>> +		dev_err(dev, "unable to enable device clock\n");
>> +		return ret;
>> +	}
>> +
>> +	ret =3D clk_prepare_enable(priv->bus_clk);
>> +	if (ret) {
>> +		dev_err(dev, "unable to enable bus clock\n");
>> +		clk_disable_unprepare(priv->can_clk);
>> +		return ret;
>> +	}
>=20
> Now you have clock imbalance. Per suspend/resume cycle the clocks are
> enabled twice, but disabled only once.
>=20
>> +
>>  	priv->write_reg(priv, XCAN_MSR_OFFSET, XCAN_MSR_SLEEP_MASK);
>>  	priv->can.state =3D CAN_STATE_SLEEPING;
>> =20
>> @@ -999,7 +1014,8 @@ static int __maybe_unused xcan_suspend(struct dev=
ice *dev)
>>   */
>>  static int __maybe_unused xcan_resume(struct device *dev)
>>  {
>> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
>> +	struct platform_device *pdev =3D container_of(dev,
>> +			struct platform_device, dev);
>>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>>  	int ret;

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--JDTIScx6ajdfsQADus7HgWIFDNJFgeGnv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZIv0AAoJECte4hHFiupUBRAQAIEwZXuTkeRCmFmiy27yYlmw
LIsgVArhIbenkJnaT1LKOlx++6vj+7NzdJfX1K4eU1LLDwbQB4Rl4QDDvMvKjbDg
5pNq51d5es0fCLP4ZEGTMmmXunlYhTajvBO7+BnPOvCgBXSAd+Ch+wfhtpSf6pwR
JkwzG39/c4oqDDarqSEbHN6sdsaBWxKY1mANg7MDVYxu0k5BASeus8Jk7YIWJYN+
UAOgTDRAXdDsegaH3ZgPtNP9QY7Ui0yUNQvVIX5J4W6kr93H4IHbrLTcJ6a+8rgY
9flcjPrwEh1w+qcUa5875zI89YsnUKZCXArCYeJL3+ty+KUFBqk24lu3RFm9bJ+e
VNWuSWTzb3uF6nMFLvg9BJoSCm7c/f9enirVDJk2hE188aF00Kf6wntT+eHnOYyg
zioxAmscDRvIR7EH/U541sldYDQzCvr6jevWnmaMVbInmtL0wFw7Pw7Lof+fybIa
s8DGxH/SrvC7vbiqVV3XsbDpxHgQ+nSdeoqZ4u+4x74dMCjU9/9auqN3BbgP9eBS
hNpp1J3kAS4gj4GaaGC7cns47KgJE0+jW2vXwWCrPZ/AegXpNrYFoLL10kIBVM0c
qbjZXBtmS+J92WhDfZx8g5fJ9uWe9zUQLP7IITUuYPyubN/roAR8fZqXxMQ5N7Ce
1YzhFTcp+AhOl7bZYHw6
=ncoe
-----END PGP SIGNATURE-----

--JDTIScx6ajdfsQADus7HgWIFDNJFgeGnv--
