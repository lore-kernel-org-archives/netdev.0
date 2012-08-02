From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Thu, 02 Aug 2012 13:56:23 +0200
Message-ID: <501A6AE7.9060508@pengutronix.de>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <50166BF2.9000700@pengutronix.de> <20120730133323.GA13941@hposo> <5017ABC6.7030307@pengutronix.de> <20120731130650.GA23541@hposo> <5017DD5B.2030701@pengutronix.de> <20120802105358.GA23787@hposo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0AF6AB88EEBBD5E06510C7AE"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120802105358.GA23787@hposo>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0AF6AB88EEBBD5E06510C7AE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/02/2012 12:53 PM, Olivier Sobrie wrote:
>>> 1) With the short circuit:
>>>
>>> I perform the test you described. It showed that the Kvaser passes fr=
om
>>> ERROR-WARNING to ERROR-PASSIVE and then BUS-OFF. But after going to t=
he
>>> state BUS-OFF it comes back to ERROR-WARNING.
>>>
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>>
>> Why don't we have any rx/tx numbers in the error frame?
>=20
> Because the hardware seems to not update the tx/rx_errors_count
> fields :-(

Okay.

>> From the hardware point of view the short circuit and open end tests
>> look good. Please adjust the driver to turn off the CAN interface in
>> case of a bus off if restart_ms is 0.
>=20
> And in the case where restart_ms is not 0? Don't I've to put it off so
> and drop the frame?

No, don't drop the frame. restart-ms !=3D 0 means the controller is
automatically restarted after the specified time (if the controller
supports). Or in your and the at91 case, automatically.

> I actually implemeted it as you said and here is what I observed in
> candump output with restart_ms set to 100 ms:
>=20
> t0: Short circuit between CAN-H and CAN-L + cansend can1 123#1122
>   can1  2000008C  [8] 00 04 90 00 00 00 00 00   ERRORFRAME
> 	controller-problem{rx-error-warning}
> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> 	bus-error
>   can1  2000008C  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> 	controller-problem{rx-error-passive}
> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> 	bus-error
>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> 	bus-off
> 	bus-error
> ...
>   can1  2000008C  [8] 00 04 90 00 00 00 00 00   ERRORFRAME
> 	controller-problem{rx-error-warning}
> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> 	bus-error
>   can1  2000008C  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> 	controller-problem{rx-error-passive}
> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> 	bus-error
>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> 	bus-off
> 	bus-error
>=20
> t1: short circuit removed
>   can1  123  [2] 11 22
>   can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
> 	restarted-after-bus-of
>=20
> The echo coming before the restart looks weird? No?
> Shouldn't we drop the frame once BUF-OFF is reached?

No, I don't think so. But wait for Wolfgang, here's more into error
handling then me.

>=20
>>>>>>> +		if ((priv->can.state =3D=3D CAN_STATE_ERROR_WARNING) ||
>>>>>>> +		    (priv->can.state =3D=3D CAN_STATE_ERROR_PASSIVE)) {
>>>>>>> +			cf->data[1] =3D (txerr > rxerr) ?
>>>>>>> +				CAN_ERR_CRTL_TX_PASSIVE
>>>>>>> +				: CAN_ERR_CRTL_RX_PASSIVE;
>>
>> Please use CAN_ERR_CRTL_RX_WARNING, CAN_ERR_CRTL_TX_WARNING where
>> appropriate.

> Ok. As the hardware doesn't report good values for txerr and rxerr, I'l=
l
> also remove the tests on txerr and rxerr.
> I observed the same behavior with the original driver.
> I asked Kvaser for this problem. I've to wait before their developer is=

> back (same for the GPL issue).

Okay.

>>>>>>> +static int kvaser_usb_get_berr_counter(const struct net_device *=
netdev,
>>>>>>> +				       struct can_berr_counter *bec)
>>>>>>> +{
>>>>>>> +	struct kvaser_usb_net_priv *priv =3D netdev_priv(netdev);
>>>>>>> +
>>>>>>> +	bec->txerr =3D priv->bec.txerr;
>>>>>>> +	bec->rxerr =3D priv->bec.rxerr;
>>
>> I think you can copy the struct like this:
>>
>> 	*bec =3D priv->bec;
>=20
> Thanks. I'll remove the function kvaser_usb_get_berr_counter as the
> hardware seems to never report txerr and rxerr.

Sounds reasonable.

BTW: is it possible to update the firmware on these devices?

> I'll look deeper at this driver during the week-end if possible...

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig0AF6AB88EEBBD5E06510C7AE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlAaauoACgkQjTAFq1RaXHNeMwCeJ6zDBNuUzLs9N9muGlt2u+/F
Ez8AniRPP2r6QqZyy3X/0Hfy4H+A3yJC
=v4ti
-----END PGP SIGNATURE-----

--------------enig0AF6AB88EEBBD5E06510C7AE--
