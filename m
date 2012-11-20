From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Tue, 20 Nov 2012 11:59:10 +0100
Message-ID: <50AB627E.5010802@pengutronix.de>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <1349162164-16149-1-git-send-email-olivier@sobrie.be> <509AC491.2090701@pengutronix.de> <20121120084626.GA14897@hposo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig78D7FEB07B28AD73F5798CA6"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20121120084626.GA14897@hposo>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig78D7FEB07B28AD73F5798CA6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/20/2012 09:46 AM, Olivier Sobrie wrote:
[...]

>>> +static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>>> +					 struct net_device *netdev)
>>> +{
>>> +	struct kvaser_usb_net_priv *priv =3D netdev_priv(netdev);
>>> +	struct kvaser_usb *dev =3D priv->dev;
>>> +	struct net_device_stats *stats =3D &netdev->stats;
>>> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
>>> +	struct kvaser_usb_tx_urb_context *context =3D NULL;
>>> +	struct urb *urb;
>>> +	void *buf;
>>> +	struct kvaser_msg *msg;
>>> +	int i, err;
>>> +	int ret =3D NETDEV_TX_OK;
>>> +
>>> +	if (can_dropped_invalid_skb(netdev, skb))
>>> +		return NETDEV_TX_OK;
>>> +
>>> +	urb =3D usb_alloc_urb(0, GFP_ATOMIC);
>>> +	if (!urb) {
>>> +		netdev_err(netdev, "No memory left for URBs\n");
>>> +		stats->tx_dropped++;
>>
>> Move the dev_kfree_skb to the end and goto there.
>=20
> I assume you mean doing something like that at the end of the function:=


Yes.

>  releasebuf:
>  	kfree(buf);
>  nobufmem:
>  	usb_free_urb(urb);
>  nourbmem:
>  	dev_kfree_skb(skb);
>  	return ret;
>=20
> If I do that it will give problems when the 'releasebuf' condition is
> reached. The skb buffer will be freed twice. The skb is already freed
> by the function can_free_echo_skb().

Okay. dev_kfree_skb(skb) will work with skb =3D=3D NULL. So just set skb =
to
NULL after can_free_echo_skb(). Maybe along with a short comment: "set
to NULL to avoid double free in dev_kfree_skb(skb)".
>=20
>>
>>> +		dev_kfree_skb(skb);
>>> +		return NETDEV_TX_OK;
>>> +	}
>>> +
>>> +	buf =3D kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
>>> +	if (!buf) {
>>> +		netdev_err(netdev, "No memory left for USB buffer\n");
>>> +		stats->tx_dropped++;
>> You cann usb_free_urb twice...here and in the error handling at the en=
d.
>=20
> Indeed thanks.
>=20
>>
>>> +		dev_kfree_skb(skb);
>>> +		usb_free_urb(urb);
>>> +		goto nobufmem;
>>> +	}
>>> +
>>> +	msg =3D buf;
>>> +	msg->len =3D MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
>>> +	msg->u.tx_can.flags =3D 0;
>>> +	msg->u.tx_can.channel =3D priv->channel;
>>> +
>>> +	if (cf->can_id & CAN_EFF_FLAG) {
>>> +		msg->id =3D CMD_TX_EXT_MESSAGE;
>>> +		msg->u.tx_can.msg[0] =3D (cf->can_id >> 24) & 0x1f;
>>> +		msg->u.tx_can.msg[1] =3D (cf->can_id >> 18) & 0x3f;
>>> +		msg->u.tx_can.msg[2] =3D (cf->can_id >> 14) & 0x0f;
>>> +		msg->u.tx_can.msg[3] =3D (cf->can_id >> 6) & 0xff;
>>> +		msg->u.tx_can.msg[4] =3D cf->can_id & 0x3f;
>>> +	} else {
>>> +		msg->id =3D CMD_TX_STD_MESSAGE;
>>> +		msg->u.tx_can.msg[0] =3D (cf->can_id >> 6) & 0x1f;
>>> +		msg->u.tx_can.msg[1] =3D cf->can_id & 0x3f;
>>> +	}
>>> +
>>> +	msg->u.tx_can.msg[5] =3D cf->can_dlc;
>>> +	memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
>>> +
>>> +	if (cf->can_id & CAN_RTR_FLAG)
>>> +		msg->u.tx_can.flags |=3D MSG_FLAG_REMOTE_FRAME;
>>> +
>>> +	for (i =3D 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
>>> +		if (priv->tx_contexts[i].echo_index =3D=3D MAX_TX_URBS) {
>>> +			context =3D &priv->tx_contexts[i];
>>> +			break;
>>> +		}
>>> +	}
>>> +
>>> +	if (!context) {
>>> +		netdev_warn(netdev, "cannot find free context\n");
>>> +		ret =3D  NETDEV_TX_BUSY;
>>> +		goto releasebuf;
>>> +	}
>>> +
>>> +	context->priv =3D priv;
>>> +	context->echo_index =3D i;
>>> +	context->dlc =3D cf->can_dlc;
>>> +
>>> +	msg->u.tx_can.tid =3D context->echo_index;
>>> +
>>> +	usb_fill_bulk_urb(urb, dev->udev,
>>> +			  usb_sndbulkpipe(dev->udev,
>>> +					  dev->bulk_out->bEndpointAddress),
>>> +			  buf, msg->len,
>>> +			  kvaser_usb_write_bulk_callback, context);
>>> +	usb_anchor_urb(urb, &priv->tx_submitted);
>>> +
>>> +	can_put_echo_skb(skb, netdev, context->echo_index);
>>> +
>>> +	atomic_inc(&priv->active_tx_urbs);
>>> +
>>> +	if (atomic_read(&priv->active_tx_urbs) >=3D MAX_TX_URBS)
>>> +		netif_stop_queue(netdev);
>>> +
>>> +	err =3D usb_submit_urb(urb, GFP_ATOMIC);
>>> +	if (unlikely(err)) {
>>> +		can_free_echo_skb(netdev, context->echo_index);
>>> +
		skb =3D NULL;	/* +comment */

>>> +		atomic_dec(&priv->active_tx_urbs);
>>> +		usb_unanchor_urb(urb);
>>> +
>>> +		stats->tx_dropped++;
>>> +
>>> +		if (err =3D=3D -ENODEV)
>>> +			netif_device_detach(netdev);
>>> +		else
>>> +			netdev_warn(netdev, "Failed tx_urb %d\n", err);
>>> +
>>> +		goto releasebuf;
>>> +	}
>>> +
>>> +	usb_free_urb(urb);
>>> +
>>> +	return NETDEV_TX_OK;
>>> +
>>> +releasebuf:
>>> +	kfree(buf);
>>> +nobufmem:
>>> +	usb_free_urb(urb);
>>> +	return ret;
>>> +}

[...]

>>> +static struct usb_driver kvaser_usb_driver =3D {
>>> +	.name =3D "kvaser_usb",
>>> +	.probe =3D kvaser_usb_probe,
>>> +	.disconnect =3D kvaser_usb_disconnect,
>>> +	.id_table =3D kvaser_usb_table
>>                                   ^^^
>> nitpick, please add a "," there.
>=20
> Ok.
>=20
>>> +};
>>>
>> can you please add MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
>=20
> It is already present just after the kvaser_usb_table structure.

:) You're right.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig78D7FEB07B28AD73F5798CA6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlCrYoEACgkQjTAFq1RaXHNVQgCcDT+hrxL6pxYL+DzP0qmGggsI
MlwAoJiPM+dlD8cg/oTbjUGy+iDn/lSD
=/RP6
-----END PGP SIGNATURE-----

--------------enig78D7FEB07B28AD73F5798CA6--
