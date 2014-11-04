From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 7/7] can: m_can: workaround for transmit data less than
 4 bytes
Date: Tue, 04 Nov 2014 10:22:16 +0100
Message-ID: <54589AC8.4010106@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-7-git-send-email-b29396@freescale.com> <5457B1D1.6080301@pengutronix.de> <20141104082505.GA8060@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="W2lmAHmv7QdJh8RouhtoLfODuGCUqCTPv"
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141104082505.GA8060@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--W2lmAHmv7QdJh8RouhtoLfODuGCUqCTPv
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/04/2014 09:25 AM, Dong Aisheng wrote:
>>> We meet an IC issue that we have to write the full 8 bytes (whatever
>>> value for the second word) in Message RAM to avoid bit error for tran=
smit
>>> data less than 4 bytes.
>>
>> Is this a SoC or a m_can problem? Are all versions of the SoC/m_can
>> affected? Is there a m_can version register somewhere?

> I'm still not sure it's SoC or m_can problem.
> Our IC guys ran the simulation code and found this issue.
> But due to some reasons, it may be very slow for they to investigate
> and get the conclusion.

Let's hope they will find the root cause of this problem.

>>> Without the workaround, we can easily see the following errors:
>>> root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
>>> [   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes read=
y
>>> root@imx6qdlsolo:~# cansend can0 123#112233
>>> [   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected
>>>
>>> Signed-off-by: Dong Aisheng <b29396@freescale.com>
>>> ---
>>>  drivers/net/can/m_can/m_can.c | 11 ++++++++++-
>>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_=
can.c
>>> index 219e0e3..f2d9ebe 100644
>>> --- a/drivers/net/can/m_can/m_can.c
>>> +++ b/drivers/net/can/m_can/m_can.c
>>> @@ -1058,10 +1058,19 @@ static netdev_tx_t m_can_start_xmit(struct sk=
_buff *skb,
>>>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_ID, id);
>>>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, can_len2dlc(cf->len) << 1=
6);
>>> =20
>>> -	for (i =3D 0; i < cf->len; i +=3D 4)
>>> +	for (i =3D 0; i < cf->len; i +=3D 4) {
>>>  		m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
>>>  				 *(u32 *)(cf->data + i));
>>> =20
>>> +		/* FIXME: we meet an IC issue that we have to write the full 8
>>
>> FIXME usually indicates that the driver needs some work here. Just
>> describe your hardware bug, you might add a reference to an errata if
>> available, though.
>
> We don't have an errata for it now.
> Because i'm not sure this is the final workaround and also not sure if =
other
> SoC vendors having the same issue, so i used FIXME here firstly.
> Since the code is harmless, so i wish we could put it here first
> until we find evidence no need for other SoC or only belong to specific=

> IP version.

It's better to write this in the comment than a FIXME, which is much
harder to interpret....

>>> +		 * bytes (whatever value for the second word) in Message RAM to
>>> +		 * avoid bit error for transmit data less than 4 bytes
>>> +		 */
>>> +		if (cf->len <=3D 4)
>>> +			m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4 + 1),
>>> +					 0x0);
>>
>> This workaround doesn't handle the dlc =3D=3D 0 case, your error descr=
iption
>> isn't completely if this is a problem, too.

> You're right.
> I just checked the dlc =3D=3D 0 case also had such issue and it also ne=
eds
> the extra 8 bytes write to avoid such issue.
>=20
> BTW the issue only happened on the first time when you send a frame wit=
h no
> data(dlc =3D=3D 0) at the first time.
> e.g.
> root@imx6sxsabresd:~# ip link set can0 up type can bitrate 1000000
> [   62.326014] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> root@imx6sxsabresd:~# cansend can0 123#R
> [   69.233645] m_can 20e8000.can can0: Bit Error Uncorrected
> [   69.239167] m_can 20e8000.can can0: Bit Error Corrected
>=20
> If we send a frame success first (e.g. 5 bytes data), it will not fail
> again even you send no data frame (dlc =3D=3D 0) later.
>=20
> The former failure of sending data less than 4 bytes is similar.
>=20
> Looks like the first 8 bytes of message ram has to be initialised
> for the first using.

What about putting

/* errata description goes here */
m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);

into the open() function? Can you ask the hardware colleges if this is a
functional workaround.

>> It should be possible to change the for loop to go always to 8, or
>> simply unroll the loop:
>>
>> /* errata description goes here */
>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));=

>> m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));=

>>
>=20
> Yes, i tried to fix it as follows.
>=20
> /* FIXME: we meet an IC issue that we have to write the full 8
>  * bytes (whatever value for the second word) in Message RAM to
>  * avoid bit error for transmit data less than 4 bytes
>  */
> if (cf->len <=3D 4) {
>         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0),
>                          *(u32 *)(cf->data + 0));
>         m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1),
>                          *(u32 *)(cf->data + 4));
> } else {
>         for (i =3D 0; i < cf->len; i +=3D 4)
>                 m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
>                                  *(u32 *)(cf->data + i));
>=20
> Will update the patch.

Both branches of the above if are doing the same thing, I think you can
replace the while if ... else ... for with this:

/* errata description goes here */
m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));

However if writing to DATA(0) and DATA(1) once in the open() function is
enough this code should stay as it is.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--W2lmAHmv7QdJh8RouhtoLfODuGCUqCTPv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWJrLAAoJECte4hHFiupUYfwQAJ4ckc3xJZfgLOxn525AFZd0
tzUoNhv3Ka8/SzkeJQ2B6kvtM3ekrE+ddM5MrYelKo2DZsb+Aja7tfHd6AoRqLqE
oROzmX2D9ICoiJ19NeNT4QmqTWsLdrxh6zi+LNVd+560+fBVcZSXowkIMnA42n5A
5Xw70fFuJZvgfCdr4bbmPLJsfJN95K9tMMjUXJIQw3QR7/dflOQ7UXpPFPqUQYby
cqp6p6bXT5cMIXguOKTD39RFveJMYOjUF92IJwo7xjeehClfHJET6fMWYkt3EmPP
pkOy9IVUtDOG3YM5ofntbO3GE5n3SJzBvDasHXH2YRDxnqYSm+69DeUgy2OWVBsQ
Ml2Du8VbOj+UCLTGUnlOtHamMrE9tnsejKE79WEX7mrmXLskAxR5gMxkJeYUdgcA
LEXJ+3Jv95ahlyDN6EhCJ9YP1DecEhqMvMt0fgVix7LaKa/DbU84w4slMxTE5zDe
T/ykBreIxpu/9nQ+2iJgNfG9LmhrijqzgaWjwZgUySo1+hcQWeM9YAFwlsh1PgZ0
ByK8TZrokXdHcSkSL0ZRuiC90acmpH9TqW4oPmpvUM6Us6suxYrL56GFzPlyk8Uy
RzRLnhqnDXIT72GhCMEhyoIvgSi/4gc6LpdFW4+2eNL6iMszICLbg5DE3CKM0awj
8rr45jKr1oAi9+0JACgj
=qjYE
-----END PGP SIGNATURE-----

--W2lmAHmv7QdJh8RouhtoLfODuGCUqCTPv--
