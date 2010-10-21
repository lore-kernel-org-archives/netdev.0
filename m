From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] can: mcp251x: fix endless loop in interrupt handler
 if CANINTF_MERRF is set
Date: Thu, 21 Oct 2010 14:24:32 +0200
Message-ID: <4CC03100.6050706@pengutronix.de>
References: <1287568946-32727-1-git-send-email-mkl@pengutronix.de>	<1287568946-32727-2-git-send-email-mkl@pengutronix.de> <201010211408.08467.david.jander@protonic.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDD813EA954E5993B0A14D902"
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: David Jander <david.jander@protonic.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34603 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756385Ab0JUMYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 08:24:37 -0400
In-Reply-To: <201010211408.08467.david.jander@protonic.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDD813EA954E5993B0A14D902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/21/2010 02:08 PM, David Jander wrote:
> On Wednesday 20 October 2010 12:02:25 pm Marc Kleine-Budde wrote:
>> Commit d3cd15657516141adce387810be8cb377baf020e introduced a bug, the
>> interrupt handler would loop endlessly if the CANINTF_MERRF bit is set=
,
>> because it's not cleared.
>>
>> This patch fixes the problem by masking out the CANINTF_MERRF and all =
other
>> non interesting bits.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> ---
>>  drivers/net/can/mcp251x.c |   14 +++++++++-----
>>  1 files changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
>> index c664be2..59f40bc 100644
>> --- a/drivers/net/can/mcp251x.c
>> +++ b/drivers/net/can/mcp251x.c
>> @@ -125,8 +125,9 @@
>>  #  define CANINTF_TX0IF 0x04
>>  #  define CANINTF_RX1IF 0x02
>>  #  define CANINTF_RX0IF 0x01
>> -#  define CANINTF_ERR_TX \
>> -	(CANINTF_ERRIF | CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
>> +#  define CANINTF_RX (CANINTF_RX0IF | CANINTF_RX1IF)
>> +#  define CANINTF_TX (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
>> +#  define CANINTF_ERR (CANINTF_ERRIF)
>=20
> Is it just me, or do you still miss MERRF?
>=20
>>  #define EFLG	      0x2d
>>  #  define EFLG_EWARN	0x01
>>  #  define EFLG_RXWAR	0x02
>> @@ -790,6 +791,9 @@ static irqreturn_t mcp251x_can_ist(int irq, void
>>  *dev_id)
>>
>>  		mcp251x_read_2regs(spi, CANINTF, &intf, &eflag);
>>
>> +		/* mask out flags we don't care about */
>> +		intf &=3D CANINTF_RX | CANINTF_TX | CANINTF_ERR;
>> +
>>  		/* receive buffer 0 */
>>  		if (intf & CANINTF_RX0IF) {
>>  			mcp251x_hw_rx(spi, 0);
>> @@ -810,8 +814,8 @@ static irqreturn_t mcp251x_can_ist(int irq, void
>>  *dev_id) }
>>
>>  		/* any error or tx interrupt we need to clear? */
>> -		if (intf & CANINTF_ERR_TX)
>> -			clear_intf |=3D intf & CANINTF_ERR_TX;
>> +		if (intf & (CANINTF_ERR | CANINTF_TX))
>> +			clear_intf |=3D intf & (CANINTF_ERR | CANINTF_TX);
>>  		if (clear_intf)
>>  			mcp251x_write_bits(spi, CANINTF, clear_intf, 0x00);
>>
>> @@ -887,7 +891,7 @@ static irqreturn_t mcp251x_can_ist(int irq, void
>>  *dev_id) if (intf =3D=3D 0)
>>  			break;
>>
>> -		if (intf & (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)) {
>> +		if (intf & CANINTF_TX) {
>>  			net->stats.tx_packets++;
>>  			net->stats.tx_bytes +=3D priv->tx_len - 1;
>>  			if (priv->tx_len) {
>=20
> I've been staring at the changes for quite some time now, but I still d=
on't=20
> understand how an "CANINTF" value of "0x80" is ever cleared (MERRF set)=
=2E
> Granted, you don't loop anymore, but shouldn't that flag be handled pro=
perly?

No need to clear the bit, because we don't get en interrupt when it's
set. Because we don't enable it to trigger an interrupt:

> 	/* Enable interrupts */
> 	mcp251x_write_reg(spi, CANINTE,
> 			  CANINTE_ERRIE | CANINTE_TX2IE | CANINTE_TX1IE |
> 			  CANINTE_TX0IE | CANINTE_RX1IE | CANINTE_RX0IE);

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigDD813EA954E5993B0A14D902
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzAMQQACgkQjTAFq1RaXHNG0gCfd0FHNyro5sDjI7fr+jRU3XYF
tLUAn32jw/qsKZW7bAmWM+AP+eTBUcp2
=0GPM
-----END PGP SIGNATURE-----

--------------enigDD813EA954E5993B0A14D902--
