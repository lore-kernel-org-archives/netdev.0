From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: c_can: Speed up rx_poll function
Date: Sun, 03 Nov 2013 22:05:46 +0100
Message-ID: <5276BAAA.6020005@pengutronix.de>
References: <1383298596-18385-1-git-send-email-mpa@pengutronix.de> <5276A1FE.7040804@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4tJBKLmBLaPqLk8HoH3rhDH88D9W5I8rX"
Cc: Markus Pargmann <mpa@pengutronix.de>,
	Joe Perches <joe@perches.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5276A1FE.7040804@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4tJBKLmBLaPqLk8HoH3rhDH88D9W5I8rX
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/03/2013 08:20 PM, Wolfgang Grandegger wrote:
> On 11/01/2013 10:36 AM, Markus Pargmann wrote:
>> This patch speeds up the rx_poll function by reducing the number of
>> register reads.
>>
>> Replace the 32bit register read by a 16bit register read. Currently
>> the 32bit register read is implemented by using 2 16bit reads. This is=

>> inefficient as we only use the lower 16bit in rx_poll.
>>
>> The for loop reads the pending interrupts in every iteration. This
>> leads up to 16 reads of pending interrupts. The patch introduces a new=

>> outer loop to read the pending interrupts as long as 'quota' is above =
0.
>> This reduces the total number of reads.
>>
>> The third change is to replace the for-loop by a ffs loop.
>>
>> Tested on AM335x. I removed all 'static' and 'inline' from c_can.c to
>> see the timings for all functions. I used the function tracer with
>> trace_stats.
>>
>> 125kbit:
>>   Function                               Hit    Time            Avg   =
          s^2
>>   --------                               ---    ----            ---   =
          ---
>>   c_can_do_rx_poll                     63960    10168178 us     158.97=
7 us      1493056 us
>> With patch:
>>   c_can_do_rx_poll                     63941    3764057 us      58.867=
 us       776162.2 us
>>
>> 1Mbit:
>>   Function                               Hit    Time            Avg   =
          s^2
>>   --------                               ---    ----            ---   =
          ---
>>   c_can_do_rx_poll                     69489    30049498 us     432.43=
5 us      9271851 us
>> With patch:
>>   c_can_do_rx_poll                    207109    24322185 us     117.43=
6 us      171469047 us
>>
>> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
>> ---
>>
>> Notes:
>>     Changes in v3:
>>      - Update commit message (measurements and ffs)
>>    =20
>>     Changes in v2:
>>      - Small changes, find_next_bit -> ffs and other
>>
>>  drivers/net/can/c_can/c_can.c | 22 ++++++++++++----------
>>  1 file changed, 12 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_c=
an.c
>> index a668cd4..428681e 100644
>> --- a/drivers/net/can/c_can/c_can.c
>> +++ b/drivers/net/can/c_can/c_can.c
>> @@ -798,17 +798,19 @@ static int c_can_do_rx_poll(struct net_device *d=
ev, int quota)
>>  	u32 num_rx_pkts =3D 0;
>>  	unsigned int msg_obj, msg_ctrl_save;
>>  	struct c_can_priv *priv =3D netdev_priv(dev);
>> -	u32 val =3D c_can_read_reg32(priv, C_CAN_INTPND1_REG);
>> +	u16 val;
>> +
>> +	/*
>> +	 * It is faster to read only one 16bit register. This is only possib=
le
>> +	 * for a maximum number of 16 objects.
>> +	 */
>> +	BUILD_BUG_ON_MSG(C_CAN_MSG_OBJ_RX_LAST > 16,
>> +			"Implementation does not support more message objects than 16");
>> +
>> +	while (quota > 0 && (val =3D priv->read_reg(priv, C_CAN_INTPND1_REG)=
)) {
>> +		while ((msg_obj =3D ffs(val)) && quota > 0) {
>> +			val &=3D ~BIT(msg_obj - 1);
>=20
> IIRC, we should avoid assignment in if/while statements.

Yes, but the code looks IMHO better this way.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4tJBKLmBLaPqLk8HoH3rhDH88D9W5I8rX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJ2uqoACgkQjTAFq1RaXHMqOQCdG3OQrv7WHJcn/STW6TFLFh/c
eDEAoJGTv8uMCgmwBK/tptn+N5tOMnay
=lzfS
-----END PGP SIGNATURE-----

--4tJBKLmBLaPqLk8HoH3rhDH88D9W5I8rX--
