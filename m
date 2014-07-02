From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/3] can: m_can: add Bosch M_CAN controller support
Date: Wed, 02 Jul 2014 09:57:50 +0200
Message-ID: <53B3BB7E.6040903@pengutronix.de>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com> <1403863246-18822-2-git-send-email-b29396@freescale.com> <53B28D7D.5080005@pengutronix.de> <20140702061944.GA8762@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="RxSGD6ewoAQaKBAmxh95jlGJIRewJgTN6"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	wg@grandegger.com, devicetree@vger.kernel.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140702061944.GA8762@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RxSGD6ewoAQaKBAmxh95jlGJIRewJgTN6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/02/2014 08:20 AM, Dong Aisheng wrote:
[...]

>>> +static int m_can_do_rx_poll(struct net_device *dev, int quota)
>>> +{
>>> +	struct m_can_priv *priv =3D netdev_priv(dev);
>>> +	struct net_device_stats *stats =3D &dev->stats;
>>> +	struct sk_buff *skb;
>>> +	struct can_frame *frame;
>>> +	u32 rxfs, flags, fgi;
>>> +	u32 num_rx_pkts =3D 0;
>>> +
>>> +	rxfs =3D m_can_read(priv, M_CAN_RXF0S);
>>> +	if (!(rxfs & RXFS_FFL_MASK)) {
>>> +		netdev_dbg(dev, "no messages in fifo0\n");
>>> +		return 0;
>>> +	}
>>> +
>>> +	while ((rxfs & RXFS_FFL_MASK) && (quota > 0)) {
>>> +		netdev_dbg(dev, "fifo0 status 0x%x\n", rxfs);
>>
>> Please remove the netdev_dbg(), once the driver is stable it should be=

>> of no use.
>>
>=20
> Got it.
>=20
>>> +		if (rxfs & RXFS_RFL)
>>> +			netdev_warn(dev, "Rx FIFO 0 Message Lost\n");
>>
>> What does that mean? Can you still rx the message if it's lost?
>>
>=20
> It just warns that there's a message lost, but there are still other
> message in fifo to receive.
>=20
>>> +
>>> +		skb =3D alloc_can_skb(dev, &frame);
>>> +		if (!skb) {
>>> +			stats->rx_dropped++;
>>> +			return -ENOMEM;
>>
>> Have a look at the user of m_can_do_rx_poll() and how it makes use of
>> the return value.
>>
>=20
> Right, thanks for spotting it.
>=20
>>> +		}
>>> +
>>> +		fgi =3D (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
>>
>> BTW: Is this a _real_ fifo? Or evolution of the c_can/d_can interface
>> where it's not a fifo at all.
>>
>=20
> Yes, it is real fifo in the message ram.
>=20
>>> +		flags =3D readl(priv->mram_base + priv->rxf0_off + fgi * 16);
>>> +		if (flags & RX_BUF_XTD)
>>> +			frame->can_id =3D (flags & CAN_EFF_MASK) | CAN_EFF_FLAG;
>>> +		else
>>> +			frame->can_id =3D (flags >> 18) & CAN_SFF_MASK;
>>> +		netdev_dbg(dev, "R0 0x%x\n", flags);
>>
>> please remove dbg
>>> +
>>> +		if (flags & RX_BUF_RTR) {
>>> +			frame->can_id |=3D CAN_RTR_FLAG;
>>> +		} else {
>>> +			flags =3D readl(priv->mram_base +
>>> +					priv->rxf0_off + fgi * 16 + 0x4);
>>> +			frame->can_dlc =3D get_can_dlc((flags >> 16) & 0x0F);
>>> +			netdev_dbg(dev, "R1 0x%x\n", flags);
>>
>> please remove
>>
>>> +
>>> +			*(u32 *)(frame->data + 0) =3D readl(priv->mram_base +
>>> +					priv->rxf0_off + fgi * 16 + 0x8);
>>> +			*(u32 *)(frame->data + 4) =3D readl(priv->mram_base +
>>> +					priv->rxf0_off + fgi * 16 + 0xC);
>>
>>
>> can you create a wrapper function to hide the pointer arithmetics here=
?
>> Somethig like m_can_read_fifo()
>>
>=20
> Yes, i could make a wrapper function for it.
>=20
>>> +			netdev_dbg(dev, "R2 0x%x\n", *(u32 *)(frame->data + 0));
>>> +			netdev_dbg(dev, "R3 0x%x\n", *(u32 *)(frame->data + 4));
>>> +		}
>>> +
>>> +		/* acknowledge rx fifo 0 */
>>> +		m_can_write(priv, M_CAN_RXF0A, fgi);
>>> +
>>> +		netif_receive_skb(skb);
>>> +		netdev_dbg(dev, "new packet received\n");
>>> +
>>> +		stats->rx_packets++;
>>> +		stats->rx_bytes +=3D frame->can_dlc;
>>
>> Please move the stats handling in front of netif_receive_skb() as the
>> skb and thus frame is not a valid pointer anymore.
>>
>=20
> Good catch!
> Will change it.
>=20
>>> +
>>> +		can_led_event(dev, CAN_LED_EVENT_RX);
>>
>> Please move out of the loop so that it is just called once (if a CAN
>> frame is rx'ed) per  m_can_do_rx_poll().

> Why that?
> The purpose is calling it for each new packet received.

It will only trigger LED blinking, and tglx pointed out, that we don't
need the overhead of calling it for every CAN frame.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--RxSGD6ewoAQaKBAmxh95jlGJIRewJgTN6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOzu4YACgkQjTAFq1RaXHMUFgCfaZZIGsxFyAK8bgsnfK+e+11w
XocAn3pbVtA7Q4hbnAtGadUN0P+L6dEv
=Lwmo
-----END PGP SIGNATURE-----

--RxSGD6ewoAQaKBAmxh95jlGJIRewJgTN6--
