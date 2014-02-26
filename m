From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: xilinx CAN controller support.
Date: Wed, 26 Feb 2014 14:22:04 +0100
Message-ID: <530DEA7C.6010609@pengutronix.de>
References: <74d607e9-ac9c-4a9b-ac49-e84ae49d20c2@TX2EHSMHS031.ehs.local> <530D0A9C.5090402@pengutronix.de> <cd00fb2d-c8a7-423d-8aa0-2b413e9ac101@CO9EHSMHS017.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="WLaE7bP6u1l5645uGMVJRtbhg45ixMqLi"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <cd00fb2d-c8a7-423d-8aa0-2b413e9ac101@CO9EHSMHS017.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WLaE7bP6u1l5645uGMVJRtbhg45ixMqLi
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/26/2014 02:07 PM, Appana Durga Kedareswara Rao wrote:
>> This loop looks broken. Can you explain how it works.
>>
>> What it shoud do is:
>> We have put (priv->tx_head - priv->tx_tail) CAN frames into the FIFO.
>> This means at maximum there could be this amount of CAN frames which
>> have been successfully transmitted. For every cycle in this while loop=
 you
>> should:
>> a) check if a CAN frame has successfully been transmitted
>>    (as this CAN core uses a FIFO it should be "oldest")
>>    A read_reg() of some kind is missing in your loop.
>> b) if needed, remove this event from the FIFO or
>>    mark the interrupt as done. Whatever you hardware needs.
>> c) update your statistics
>> d) Use can_get_echo_skb to push this frame into the networking stack
>> e) As a CAN frame has been transmitted successfully, wake the tx_queue=
=2E
>>
>>> +   while (priv->tx_head - priv->tx_tail > 0) {
>>> +           if (isr & XCAN_IXR_TXFLL_MASK) {
>>> +                   priv->write_reg(priv, XCAN_ICR_OFFSET,
>>> +                                   XCAN_IXR_TXFLL_MASK);
>>> +                   netif_stop_queue(ndev);
>>
>> Why do you stop the queue here? A CAN frame has successfully been
>> transmitted, there should be room in the FIFO.
>>
>>> +                   break;
>>> +           }
>>> +           can_get_echo_skb(ndev, priv->tx_tail %
>>> +                                   priv->xcan_echo_skb_max_tx);
>>> +           priv->tx_tail++;
>>> +   }
>>> +
>=20
> The below are the bit fields available for the Transmit FIFO.
> 1) In the ISR(interrupt status register)  Tx Ok interrupt and Tx fifo f=
ull interrupt.
> 2) in the SR(Status Register) Tx fifo full condition.
>=20
>=20
> I am modifying the entire tx interrupt logic to like below.
>=20
> static void xcan_tx_interrupt(struct net_device *ndev, u32 isr)
> {
>         struct xcan_priv *priv =3D netdev_priv(ndev);
>         struct net_device_stats *stats =3D &ndev->stats;
>=20
>             while (priv->tx_head - priv->tx_tail > 0) {
>                 if (isr & XCAN_IXR_TXFLL_MASK) {
>                         priv->write_reg(priv, XCAN_ICR_OFFSET,
>                                         XCAN_IXR_TXFLL_MASK);
>                           break;
>                 }
>                 can_get_echo_skb(ndev, priv->tx_tail %
>                                         priv->xcan_echo_skb_max_tx);
>                 priv->tx_tail++;
>          stats->tx_packets++;
>         netif_wake_queue(ndev);
>               can_led_event(ndev, CAN_LED_EVENT_TX);
>=20
>         }

You just need to wake the queue once.

> }
>=20
>=20
> Are you Ok with the above logic?

No, how can you tell how many frames have been transmitted?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--WLaE7bP6u1l5645uGMVJRtbhg45ixMqLi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMN6nwACgkQjTAFq1RaXHPQGQCffOrc4qe/mhVZnM1NvNN3XTMq
JfAAn3poCqSBHxbeZtkG8DiW4dHP6rDk
=fs9R
-----END PGP SIGNATURE-----

--WLaE7bP6u1l5645uGMVJRtbhg45ixMqLi--
