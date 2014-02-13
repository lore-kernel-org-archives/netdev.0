From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Thu, 13 Feb 2014 13:12:53 +0100
Message-ID: <52FCB6C5.6020001@pengutronix.de>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <52DCE9E4.7010209@pengutronix.de> <52E3148E.2010608@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="0BVWNFt2Jb2aJLf56oKO4gjD2IUwnFABA"
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52E3148E.2010608@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0BVWNFt2Jb2aJLf56oKO4gjD2IUwnFABA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/25/2014 02:34 AM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 01/20/2014 12:18 PM, Marc Kleine-Budde wrote:
>=20
>>> Add support for the CAN controller found in Renesas R-Car SoCs.
>=20
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
>>> ---
>>> The patch is against the 'linux-can-next.git' repo.
>=20
> [...]
>>> Index: linux-can-next/drivers/net/can/rcar_can.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- /dev/null
>>> +++ linux-can-next/drivers/net/can/rcar_can.c
>>> @@ -0,0 +1,857 @@
> [...]
>>> +/* Mailbox registers structure */
>>> +struct rcar_can_mbox_regs {
>>> +    u32 id;        /* IDE and RTR bits, SID and EID */
>>> +    u8 stub;    /* Not used */
>>> +    u8 dlc;        /* Data Length Code - bits [0..3] */
>>> +    u8 data[8];    /* Data Bytes */
>>> +    u8 tsh;        /* Time Stamp Higher Byte */
>>> +    u8 tsl;        /* Time Stamp Lower Byte */
>>> +} __packed;
>=20
>> If you have contact to the hardware designer please blame him for
>=20
>    Unfortunately, we don't.
>=20
>> placing the data register unaligned into the register space. :)
>=20
>    It's not even the only one or worst example of questionable register=

> design in this module IMO.
>=20
> [...]
>>> +static void rcar_can_tx_done(struct net_device *ndev)
>>> +{
>>> +    struct rcar_can_priv *priv =3D netdev_priv(ndev);
>>> +    struct net_device_stats *stats =3D &ndev->stats;
>>> +    int i;
>>> +
>>> +    spin_lock(&priv->skb_lock);
>>> +    for (i =3D 0; i < priv->frames_queued; i++)
>>> +        can_get_echo_skb(ndev, i);
>>> +    stats->tx_bytes +=3D priv->bytes_queued;
>>> +    stats->tx_packets +=3D priv->frames_queued;
>>> +    priv->bytes_queued =3D 0;
>>> +    priv->frames_queued =3D 0;
>>> +    spin_unlock(&priv->skb_lock);
>=20
>> This looks broken. What happens if you send 2 CAN frames in a row, the=

>> first one is send, a TX complete interrupt is issued and you handle it=

>> here? You assume, that all CAN frames have been sent.
>=20
>    TX interrupt will be issued only when TX FIFO gets empty (all 2 fram=
es
> have been transmitted in this case). Please see the comment to the
> RCAR_CAN_MIER1_TXFIT bit.

Does the hardware have a TX complete interrupt? If you only have TX FIFO
empty, you have to limit the FIFO depth to 1.

>>> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
>>> +{
>>> +    struct net_device *ndev =3D (struct net_device *)dev_id;
>=20
>> the cast is not needed
>=20
>    Removed.
>=20
> [...]
>>> +static void rcar_can_set_bittiming(struct net_device *dev)
>>> +{
>>> +    struct rcar_can_priv *priv =3D netdev_priv(dev);
>>> +    struct can_bittiming *bt =3D &priv->can.bittiming;
>>> +    u32 bcr;
>>> +    u8 clkr;
>>> +
>>> +    /* Don't overwrite CLKR with 32-bit BCR access */
>>> +    /* CLKR has 8-bit access */
>=20
>> Can you explain the register layout here? Why do you access BCR with 3=
2
>> bits when the register is defined as 3x8 bit? Can't you make it a
>> standard 32 bit register?
>=20
> 1. According to documentation BCR is the 24-bit register.
> Actually we can consider some 32-bit register that combines BCR and
> CLKR but according to documentation there are two separate registers.
> 2. BCR has 8- ,16-, and 32-bit access (according to documentation).
> 3. This is the algorithm that the documentation suggests.
> 4. We had a driver version with byte access but 32-bit access seems
> shorter.

Please use a normal read-modify-write 32 bit access.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--0BVWNFt2Jb2aJLf56oKO4gjD2IUwnFABA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlL8tsUACgkQjTAFq1RaXHMVNQCfaUKq1ie/GYjj4LqsoJMvu0qc
CN4An0K0pcamm/JCZFlZOUspfxHqsx1g
=qli/
-----END PGP SIGNATURE-----

--0BVWNFt2Jb2aJLf56oKO4gjD2IUwnFABA--
