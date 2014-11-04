From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 7/7] can: m_can: workaround for transmit data less than
 4 bytes
Date: Tue, 04 Nov 2014 11:33:09 +0100
Message-ID: <5458AB65.7000500@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-7-git-send-email-b29396@freescale.com> <5457B1D1.6080301@pengutronix.de> <20141104082505.GA8060@shlinux1.ap.freescale.net> <54589AC8.4010106@pengutronix.de> <20141104092651.GC8060@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="a0lWMEpNaQ0Mq0BXIjWj328fHfLwQhoQB"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141104092651.GC8060@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--a0lWMEpNaQ0Mq0BXIjWj328fHfLwQhoQB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/04/2014 10:27 AM, Dong Aisheng wrote:
>>>> It should be possible to change the for loop to go always to 8, or
>>>> simply unroll the loop:
>>>>
>>>> /* errata description goes here */
>>>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0)=
);
>>>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4)=
);
>>>>
>>>
>>> Yes, i tried to fix it as follows.
>>>
>>> /* FIXME: we meet an IC issue that we have to write the full 8
>>>  * bytes (whatever value for the second word) in Message RAM to
>>>  * avoid bit error for transmit data less than 4 bytes
>>>  */
>>> if (cf->len <=3D 4) {
>>>         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0),
>>>                          *(u32 *)(cf->data + 0));
>>>         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1),
>>>                          *(u32 *)(cf->data + 4));
>>> } else {
>>>         for (i =3D 0; i < cf->len; i +=3D 4)
>>>                 m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
>>>                                  *(u32 *)(cf->data + i));
>>>
>>> Will update the patch.
>>
>> Both branches of the above if are doing the same thing, I think you ca=
n
>> replace the while if ... else ... for with this:
>>
>=20
> Not the same thing.
> The later one will cover payload up to 64 bytes.

Doh! I'm not used to CAN-FD, yet :) However, I'll apply this fix before
adding the CAN-FD support.

>> /* errata description goes here */
>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));=

>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));=

>>
>> However if writing to DATA(0) and DATA(1) once in the open() function =
is
>> enough this code should stay as it is.
>=20
> I tried put them into open() function and the quick test showed it work=
ed.
>=20
> Do you think it's ok to put things into open() function for this issue
> as follows?
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index 065e4f1..ca55988 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -901,6 +901,15 @@ static void m_can_chip_config(struct net_device *d=
ev)
>         /* set bittiming params */
>         m_can_set_bittiming(dev);
>=20
> +       /* We meet an IC issue that we have to write the full 8

At least on the *insert SoC name here*, an issue with the Message RAM
was discovered. Sending CAN frames with dlc less than 4 bytes will lead
to bit errors, when the first 8 bytes of the Message RAM have not been
initialized (i.e. written to). To work around this issue, the first 8
bytes are initialized here.

> +        * bytes (whatever value for the second word) in Message RAM to=

> +        * avoid bit error for transmit data less than 4 bytes at the f=
irst
> +        * time. By initializing the first 8 bytes of tx buffer before =
using
> +        * it can avoid such issue.
> +        */
> +       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
> +       m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
> +
>         m_can_config_endisable(priv, false);
>  }

Can you trigger the issue when sending CAN-FD frames with dlc > 8 && dlc
< 64?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--a0lWMEpNaQ0Mq0BXIjWj328fHfLwQhoQB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWKtlAAoJECte4hHFiupUYngP/jfVxTk6mIicW3B0P6tHeGgX
+Wpuj3Fy5uv6uhFuW4aLY4pehL4NAxgH4IkuGF6jtKEp89hOnhVU7tdIz/+YVyAe
T5NBu5Kw/zZ2/mvi2mGmTalJMOyJnK78frYfb7R3pzTtFvwuZinyhTQYczTgoDii
q4Ivd0yX6H55OK4RrlbLKYKZAeGCIgOxA5Sfx4QVBqh4WLd3yoxBEKr5O4a0O/zF
d2VPHvq0foo4X274ezNqPmg0OKBBKPc6v5L7F1UlrSntpw5OPIzl249qBamgp7MT
I0TRC2FUfr1O1n7IySp7uTcSbg+eKo7tlkbqWPt7OjSGT5iB2dV8ezvt2v6Gxw8o
HhKSSTnmLBmU/gFDT6HiznTJqTtrjBkyzZMEQz8bj6zNSprq76lRR1kIMjcXUZej
JqCyoV+HNEub6EjGNPzJBADZsJgJ3eRddh6Fi77psyxYZk+tu3/uVkY+5Ag32StI
/eNrvZwLFNKW0IY8ekdKTmF3e8wwNnDi0tUrtKondN3eTicEYoMPRpi3zM/bj2/g
E6wQqv3IIhntXXRn8bPP3CZclfzfoCYbYsGwSUuEmcCHFWE2DXchwMZIu/6hzuug
BxG5cxh4JaIW0A2lxmp0HS7RzuHg3cqxDCyy9DW6CSc4agmI7oR+tRJYy0aIWOgF
Z7+F9oAB3I9zWBe5MA0p
=5D60
-----END PGP SIGNATURE-----

--a0lWMEpNaQ0Mq0BXIjWj328fHfLwQhoQB--
