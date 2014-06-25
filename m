From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Wed, 25 Jun 2014 12:26:49 +0200
Message-ID: <53AAA3E9.6030409@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com> <53AA8805.3050309@pengutronix.de> <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="M7sowpW4aHnxPxnsI4oIDdT9C8rR0lbPe"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <ae6e49865206432ea871b08b159bae55@BN1PR03MB220.namprd03.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--M7sowpW4aHnxPxnsI4oIDdT9C8rR0lbPe
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/25/2014 11:41 AM, bhupesh.sharma@freescale.com wrote:
>>> This patch ensures that the register read/write APIs are remodelled t=
o
>>> address such cases, while ensuring that existing platforms (where the=

>>> FlexCAN IP was modelled in LE way) do not break.
>>
>> I'm not sure if it's better to handle this via the DT attributes big-
>> endian, little-endian, no attribute would mean native endianess for
>> backwards compatibility.
>=20
> My 1st approach path was do it via DT itself, but that would mean
> changing existing DTS/DTSI for SoCs which use FlexCAN, unless we
> say no endianess attribute means that the module is still LE, and thus
> effectively add 'big-endian' only a node to the LS1021A FlexCAN DT node=
=2E

If no attributes means native endianess the dts will stay compatible.

>> With this solution, you're breaking all ARM non DT boards, as the stru=
ct
>> platform_device_id still uses fsl_p1010_devtype_data. You're breaking =
DT
>> based mx35, as struct of_device_id has no entry for mx35.
>>
>> With this patch fsl,p1010-flexcan isn't compatible with the imx/mxs an=
y
>> more, please change the device trees in the kernel.
>>
>> Please update the "FLEXCAN hardware feature flags" table in the driver=

>> and check if any of the mentioned quirks are needed for the LS1021A.
>=20
> I have confirmed the same. No quirks are required for LS1021A.
> BTW, can't we have the quirks field in the DT node itself?

I don't know, probably for historic reasons, feel free to post a patch.

>> See comment inline.....
>>
>>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma@freescale.com>
>>> ---
>>> Rebased againt v3.16-rc1
>>>
>>>  drivers/net/can/flexcan.c |  213
>>> +++++++++++++++++++++++++++------------------
>>>  1 file changed, 126 insertions(+), 87 deletions(-)
>>>
>>> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
>>> index f425ec2..00c4740 100644
>>> --- a/drivers/net/can/flexcan.c
>>> +++ b/drivers/net/can/flexcan.c
>>
>> [...]
>>
>>>  static const struct can_bittiming_const flexcan_bittiming_const =3D =
{
>>> @@ -237,32 +256,36 @@ static const struct can_bittiming_const
>>> flexcan_bittiming_const =3D {  };
>>>
>>>  /*
>>> - * Abstract off the read/write for arm versus ppc. This
>>> - * assumes that PPC uses big-endian registers and everything
>>> - * else uses little-endian registers, independent of CPU
>>> - * endianess.
>>> + * FlexCAN module is essentially modelled as a little-endian IP in
>>> + most
>>> + * SoCs, i.e the registers as well as the message buffer areas are
>>> + * implemented in a little-endian fashion.
>>> + *
>>> + * However there are some SoCs (e.g. LS1021A) which implement the
>>> + FlexCAN
>>> + * module in a big-endian fashion (i.e the registers as well as the
>>> + * message buffer areas are implemented in a big-endian way).
>>> + *
>>> + * In addition, the FlexCAN module can be found on SoCs having ARM o=
r
>>> + * PPC cores. So, we need to abstract off the register read/write
>>> + * functions, ensuring that these cater to all the combinations of
>>> + module
>>> + * endianess and underlying CPU endianess.
>>>   */
>>> -#if defined(CONFIG_PPC)
>>> -static inline u32 flexcan_read(void __iomem *addr)
>>> +static inline u32 flexcan_read(const struct flexcan_priv *priv,
>>> +			       void __iomem *addr)
>>>  {
>>> -	return in_be32(addr);
>>> -}
>>> -
>>> -static inline void flexcan_write(u32 val, void __iomem *addr) -{
>>> -	out_be32(addr, val);
>>> -}
>>> -#else
>>> -static inline u32 flexcan_read(void __iomem *addr) -{
>>> -	return readl(addr);
>>> +	if (priv->devtype_data->module_is_big_endian)
>>> +		return ioread32be(addr);
>>> +	else
>>> +		return ioread32(addr);
>>>  }
>>>
>>> -static inline void flexcan_write(u32 val, void __iomem *addr)
>>> +static inline void flexcan_write(const struct flexcan_priv *priv,
>>> +				 u32 val, void __iomem *addr)
>>>  {
>>> -	writel(val, addr);
>>> +	if (priv->devtype_data->module_is_big_endian)
>>
>> Please move the devtype_data into the struct flexcan_priv, so that you=

>> don't need a double pointer dereference in the hot path.
>=20
> Ok. Or should I create two functions for read and write - one does it i=
n LE way and the other
> in BE way and parse the DT to understand which endianness the module su=
pports.

What about function pointers in the priv? So that flexcan_read() becomes
priv->read().

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--M7sowpW4aHnxPxnsI4oIDdT9C8rR0lbPe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOqo+kACgkQjTAFq1RaXHP/8ACfZ/aaUEoiIDwWRFUkkmntcKNV
0swAnjfKytHt5VO+qKkvwzQl5m70Ou+X
=dwzt
-----END PGP SIGNATURE-----

--M7sowpW4aHnxPxnsI4oIDdT9C8rR0lbPe--
