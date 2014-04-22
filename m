From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
Date: Tue, 22 Apr 2014 13:11:31 +0200
Message-ID: <53564E63.4010803@pengutronix.de>
References: <3e750ec3-9d47-4b4e-8173-56698ab19786@CH1EHSMHS029.ehs.local> <53562E7D.7090509@pengutronix.de> <957b07ca-f74c-47fb-963a-084710d48c5a@AM1EHSMHS014.ehs.local> <535643D9.3070601@pengutronix.de> <9f70ceca-c6fd-4d57-a54a-8cbf9d888137@CH1EHSMHS016.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="iRhW9Bx7nSvEMJ2bcB4mKRNamM4NR2vw2"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Michal Simek <michals@xilinx.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"wg@grandegger.com" <wg@grandegger.com>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <9f70ceca-c6fd-4d57-a54a-8cbf9d888137@CH1EHSMHS016.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iRhW9Bx7nSvEMJ2bcB4mKRNamM4NR2vw2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/22/2014 01:08 PM, Appana Durga Kedareswara Rao wrote:
> Hi Marc,
>=20
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>> Sent: Tuesday, April 22, 2014 3:57 PM
>> To: Appana Durga Kedareswara Rao; wg@grandegger.com; Michal Simek;
>> grant.likely@linaro.org; robh+dt@kernel.org
>> Cc: linux-can@vger.kernel.org; netdev@vger.kernel.org; linux-arm-
>> kernel@lists.infradead.org; linux-kernel@vger.kernel.org;
>> devicetree@vger.kernel.org
>> Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
>>
>> On 04/22/2014 12:06 PM, Appana Durga Kedareswara Rao wrote:
>>
>>>> Meanwhile Thomas Gleixner put some effort into the c_can driver and
>>>> found some problems in most of the can driver. See comments inline.
>>>>
>>> Ok will look into that patches
>>
>> I've commented the relevant parts of your patch. Although more
>> background information can be found in the c_can patches.
>>
> Ok
>=20
>>>>> +/**
>>>>> + * xcan_tx_interrupt - Tx Done Isr
>>>>> + * @ndev:  net_device pointer
>>>>> + * @isr:   Interrupt status register value
>>>>> + */
>>>>> +static void xcan_tx_interrupt(struct net_device *ndev, u32 isr) {
>>>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>>>> +
>>>>> +   while (priv->tx_head - priv->tx_tail > 0) {
>>>>> +           priv->write_reg(priv, XCAN_ICR_OFFSET,
>>>> XCAN_IXR_TXOK_MASK);
>>>>> +           if (!(isr & XCAN_IXR_TXOK_MASK))
>>>>> +                   break;
>>>>
>>>> This looks broken. I assume you have to issue the
>> XCAN_IXR_TXOK_MASK-
>>>> write once per tx-completed CAN frame. If you enter this loop you
>>>> write once, then isr is read, then you write again and may exit this=

>>>> loop if XCAN_IXR_TXOK_MASK is not set anymore.
>>
>> Let's assume you have put 3 CAN frames into the TX-queue and we're int=
o
>> tx-complete interrupt for the first frame and the other 2 are still no=
t
>> completed.
>>
>> This means the while() loop is not terminated by (priv->tx_head -
>> priv->tx_tail > 0), as it can loop 3 times.
>>
>> What happens is:
>>
>> - priv->write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MASK);
>> - if (!(isr & XCAN_IXR_TXOK_MASK)) -> no break
>> - can_get_echo_skb()
>> - ...
>> - isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
>> - loop ->
>> - priv->write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MASK);
>> - if (!(isr & XCAN_IXR_TXOK_MASK)) -> break
>>
>> So you have 2x write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MASK),
>> but only a single TX completed CAN frame.
>>
>=20
> Ok now got it :). Thanks for the explanation.
> Will modify the loop logic like below.
>=20
> while (priv->tx_head - priv->tx_tail > 0) {
>                  if ((isr & XCAN_IXR_TXOK_MASK)) {
>                 priv->write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MA=
SK);
>                         can_get_echo_skb(ndev, priv->tx_tail %
>                                                 priv->tx_max);
>                         priv->tx_tail++;
>                         stats->tx_packets++;
>                 } else {
>                 break;
>         }
>                =20
>   }
> Are you ok with this?

what about this:

while ((priv->tx_head - priv->tx_tail > 0) &&
	(isr & XCAN_IXR_TXOK_MASK)) {

	[...]

	isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
}

or even

while ((priv->tx_head - priv->tx_tail > 0) &&
	(priv->read_reg(priv, XCAN_ISR_OFFSET) & XCAN_IXR_TXOK_MASK)) {

	[...]

}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--iRhW9Bx7nSvEMJ2bcB4mKRNamM4NR2vw2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlNWTmMACgkQjTAFq1RaXHMiQwCePMQgdCx7rNb+TRMjU/By+rDF
EHIAn0kn/OuXK8C84eJpTErhieQKK9de
=4mw0
-----END PGP SIGNATURE-----

--iRhW9Bx7nSvEMJ2bcB4mKRNamM4NR2vw2--
