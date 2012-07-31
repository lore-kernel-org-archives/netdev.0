From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Tue, 31 Jul 2012 15:27:55 +0200
Message-ID: <5017DD5B.2030701@pengutronix.de>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <50166BF2.9000700@pengutronix.de> <20120730133323.GA13941@hposo> <5017ABC6.7030307@pengutronix.de> <20120731130650.GA23541@hposo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF4642317F4E8EB509F88FF0F"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120731130650.GA23541@hposo>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF4642317F4E8EB509F88FF0F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 07/31/2012 03:06 PM, Olivier Sobrie wrote:
[...]

>>>> Please check if your driver survives hot-unplugging while sending an=
d
>>>> receiving CAN frames at maximum laod.
>>>
>>> I tested this with two Kvaser sending frames with "cangen can0 -g 0 -=
i"
>>> never saw a crash.
>>
>> Please test send sending and receiving at the same time.
>=20
> Yes that's what I did; "cangen can0 -g 0 -i" on both sides.

Fine.

[...]

>>>>> --- /dev/null
>>>>> +++ b/drivers/net/can/usb/kvaser_usb.c
>>>>> @@ -0,0 +1,1062 @@
>>>>> +/*
>>>>
>>>> Please add a license statement and probably your copyright:
>>>>
>>>>  * This program is free software; you can redistribute it and/or
>>>>  * modify it under the terms of the GNU General Public License as
>>>>  * published by the Free Software Foundation version 2.
>>>>
>>>> You also should copy the copyright from the drivers you used:
>>>>
>>>>> + * Parts of this driver are based on the following:
>>>>> + *  - Kvaser linux leaf driver (version 4.78)
>>>>
>>>> I just downloaded their driver and noticed that it's quite sparse on=

>>>> stating the license the code is released under.
>>>> "doc/HTMLhelp/copyright.htx" is quite restrictive, the word GPL occu=
rs 3
>>>> times, all in MODULE_LICENSE("GPL"). Running modinfo on the usbcan.k=
o
>>>> shows "license: GPL"
>>>
>>> I'll add the license statement.
>>> In fact it's the leaf.ko which is used for this device and it is unde=
r
>>> GPL as modinfo said.
>>
>> I just talked to my boss and we're the same opinion, that
>> MODULE_LICENSE("GPL") is a technical term and not relevant if the
>> included license doesn't say a word about GPL. If the kvaser tarball
>> violates the GPL, however is written on different sheet of paper (as w=
e
>> say in Germany).
>>
>> So I cannot put my S-o-b under this driver as long as we haven't talke=
d
>> to kvaser.
>=20
> Ok I thought it was sufficient enough to have MODULE_LICENSE("GPL") in
> the code to indicate it is a GPL driver. I'll ask Kvaser before sending=

> any new version of the patch.

We can continue the review process, this problem has to be sorted out
before I can apply this patch to linux-can-next tree.

[...]

>>>>> +static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>>>>> +				const struct kvaser_msg *msg)
>>>>> +{
>>>>> +	struct can_frame *cf;
>>>>> +	struct sk_buff *skb;
>>>>> +	struct net_device_stats *stats;
>>>>> +	struct kvaser_usb_net_priv *priv;
>>>>> +	u8 channel, status, txerr, rxerr;
>>>>> +
>>>>> +	if (msg->id =3D=3D CMD_CAN_ERROR_EVENT) {
>>>>> +		channel =3D msg->u.error_event.channel;
>>>>> +		status =3D  msg->u.error_event.status;
>>>>> +		txerr =3D msg->u.error_event.tx_errors_count;
>>>>> +		rxerr =3D msg->u.error_event.rx_errors_count;
>>>>> +	} else {
>>>>> +		channel =3D msg->u.chip_state_event.channel;
>>>>> +		status =3D  msg->u.chip_state_event.status;
>>>>> +		txerr =3D msg->u.chip_state_event.tx_errors_count;
>>>>> +		rxerr =3D msg->u.chip_state_event.rx_errors_count;
>>>>> +	}
>>>>> +
>>>>> +	if (channel >=3D dev->nchannels) {
>>>>> +		dev_err(dev->udev->dev.parent,
>>>>> +			"Invalid channel number (%d)\n", channel);
>>>>> +		return;
>>>>> +	}
>>>>> +
>>>>> +	priv =3D dev->nets[channel];
>>>>> +	stats =3D &priv->netdev->stats;
>>>>> +
>>>>> +	skb =3D alloc_can_err_skb(priv->netdev, &cf);
>>>>> +	if (!skb) {
>>>>> +		stats->rx_dropped++;
>>>>> +		return;
>>>>> +	}
>>>>> +
>>>>> +	if ((status & M16C_STATE_BUS_OFF) ||
>>>>> +	    (status & M16C_STATE_BUS_RESET)) {
>>>>> +		priv->can.state =3D CAN_STATE_BUS_OFF;
>>>>> +		cf->can_id |=3D CAN_ERR_BUSOFF;
>>>>> +		can_bus_off(priv->netdev);
>>
>> you should increment priv->can.can_stats.bus_off
>> What does the firmware do in this state? Does it automatically try to
>> recover and try to send the outstanding frames?
>=20
> Yes that's what I observed.

It's behaves like the at91_can.

>> If so, you should turn of the CAN interface, it possible. See:
>> http://lxr.free-electrons.com/source/drivers/net/can/at91_can.c#L986
>=20
> Ok I'll have a look at this.
>=20
>>
>> Please test Bus-Off behaviour:
>> - setup working CAN network
>> - short circuit CAN-H and CAN-L wires
>> - start "candump any,0:0,#FFFFFFFF" on one shell
>> - send one can frame on the other
>>
>> then
>>
>> - remove the short circuit
>> - see if the can frame is transmitted to the other side
>> - it should show up as an echo'ed CAN frame on the sender side
>>
>> Repeat the same test with disconnecting CAN-H and CAN-L from the other=

>> CAN station instead of short circuit.
>>
>> Please send the output from candump.
>=20
> 1) With the short circuit:
>=20
> I perform the test you described. It showed that the Kvaser passes from=

> ERROR-WARNING to ERROR-PASSIVE and then BUS-OFF. But after going to the=

> state BUS-OFF it comes back to ERROR-WARNING.
>=20
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME

Why don't we have any rx/tx numbers in the error frame?

>   ...
>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME  <-- bus off=

>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   ...
>   can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
>   can1  123  [2] 11 22	          <-- short circuit removed
>=20
> I see the echo and on the other end I see the frame coming in.
> By the way I see that the txerr and rxerr fields of the structure
> kvaser_msg_error_event stay at 0.
>=20
> 2) With CAN-H and CAN-L disconnected:
>=20
> I never see the bus going in OFF state. It stays in PASSIVE mode.
>=20
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   ...
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  20000088  [8] 00 10 80 1B 00 00 00 00   ERRORFRAME
>   can1  123  [2] 11 22            <-- other end connected

=46rom the hardware point of view the short circuit and open end tests
look good. Please adjust the driver to turn off the CAN interface in
case of a bus off if restart_ms is 0.

>>>>> +	} else if (status & M16C_STATE_BUS_ERROR) {
>>>>> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
>>>>> +		priv->can.can_stats.error_warning++;
>>>>> +	} else if (status & M16C_STATE_BUS_PASSIVE) {
>>>>> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
>>>>> +		priv->can.can_stats.error_passive++;
>>>>> +	} else {
>>>>> +		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>>>> +		cf->can_id |=3D CAN_ERR_PROT;
>>>>> +		cf->data[2] =3D CAN_ERR_PROT_ACTIVE;
>>>>> +	}
>>>>> +
>>>>> +	if (msg->id =3D=3D CMD_CAN_ERROR_EVENT) {
>>>>> +		u8 error_factor =3D msg->u.error_event.error_factor;
>>>>> +
>>>>> +		priv->can.can_stats.bus_error++;
>>>>> +		stats->rx_errors++;
>>>>> +
>>>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>>>> +
>>>>> +		if ((priv->can.state =3D=3D CAN_STATE_ERROR_WARNING) ||
>>>>> +		    (priv->can.state =3D=3D CAN_STATE_ERROR_PASSIVE)) {
>>>>> +			cf->data[1] =3D (txerr > rxerr) ?
>>>>> +				CAN_ERR_CRTL_TX_PASSIVE
>>>>> +				: CAN_ERR_CRTL_RX_PASSIVE;

Please use CAN_ERR_CRTL_RX_WARNING, CAN_ERR_CRTL_TX_WARNING where
appropriate.

>>>>> +		}
>>>>> +
>>>>> +		if (error_factor & M16C_EF_ACKE)
>>>>> +			cf->data[3] |=3D (CAN_ERR_PROT_LOC_ACK |
>>>>> +					CAN_ERR_PROT_LOC_ACK_DEL);
>>>>> +		if (error_factor & M16C_EF_CRCE)
>>>>> +			cf->data[3] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
>>>>> +					CAN_ERR_PROT_LOC_CRC_DEL);
>>>>> +		if (error_factor & M16C_EF_FORME)
>>>>> +			cf->data[2] |=3D CAN_ERR_PROT_FORM;
>>>>> +		if (error_factor & M16C_EF_STFE)
>>>>> +			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
>>>>> +		if (error_factor & M16C_EF_BITE0)
>>>>> +			cf->data[2] |=3D CAN_ERR_PROT_BIT0;
>>>>> +		if (error_factor & M16C_EF_BITE1)
>>>>> +			cf->data[2] |=3D CAN_ERR_PROT_BIT1;
>>>>> +		if (error_factor & M16C_EF_TRE)
>>>>> +			cf->data[2] |=3D CAN_ERR_PROT_TX;
>>>>> +	}
>>>>> +
>>>>> +	cf->data[6] =3D txerr;
>>>>> +	cf->data[7] =3D rxerr;
>>>>> +
>>>>> +	netif_rx(skb);
>>>>> +
>>>>> +	priv->bec.txerr =3D txerr;
>>>>> +	priv->bec.rxerr =3D rxerr;
>>>>> +
>>>>> +	stats->rx_packets++;
>>>>> +	stats->rx_bytes +=3D cf->can_dlc;
>>>>> +}
>>>>> +

[...]

>>>>> +static int kvaser_usb_get_berr_counter(const struct net_device *ne=
tdev,
>>>>> +				       struct can_berr_counter *bec)
>>>>> +{
>>>>> +	struct kvaser_usb_net_priv *priv =3D netdev_priv(netdev);
>>>>> +
>>>>> +	bec->txerr =3D priv->bec.txerr;
>>>>> +	bec->rxerr =3D priv->bec.rxerr;

I think you can copy the struct like this:

	*bec =3D priv->bec;

>>>>> +
>>>>> +	return 0;
>>>>> +}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF4642317F4E8EB509F88FF0F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlAX3WEACgkQjTAFq1RaXHOECwCeM7aPumUe5u2YovfFxTJoBGeT
pgYAn028ZwtI8hyhcUHH139ciO1mO+Fv
=X+YI
-----END PGP SIGNATURE-----

--------------enigF4642317F4E8EB509F88FF0F--
