From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [RFC PATCH 2/2] ppp_mppe: Check coherency counter for out-of-order
 sequencing
Date: Mon, 20 May 2013 20:03:40 +0200
Message-ID: <519A657C.8040606@dti2.net>
References: <1369067640-2793-1-git-send-email-jorge@dti2.net>  <1369067640-2793-2-git-send-email-jorge@dti2.net> <1369071170.3301.198.camel@edumazet-glaptop>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369071170.3301.198.camel@edumazet-glaptop>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El 20/05/2013 19:32, Eric Dumazet escribi=C3=B3:
> On Mon, 2013-05-20 at 18:34 +0200, Jorge Boncompte [DTI2] wrote:
>> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
>>
>> While testing a L2TP tunnel without sequencing with MPPE encryption =
in
>> stateless mode noticed that after a packet was reordered the encapsu=
lated
>> traffic session was stuck but testing against a Cisco gear did work.
>>
>> From RFC3078 "MPPE expects packets to be delivered in sequence".
>>
>> The thing it's that the ppp_mppe module treats the reorder as if the
>> coherency counter did wrap and rekeys all the "missing" packets.
>>
>> The link layer protocol should deliver the packets in order but at l=
east
>> with this patch in place the decryption process survives some packet=
 reorder.
>>
>> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
>> ---
>>  drivers/net/ppp/ppp_mppe.c |   21 +++++++++++++++++++++
>>  1 file changed, 21 insertions(+)
>>
>> diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
>> index 9a1849a..0a10a6d 100644
>> --- a/drivers/net/ppp/ppp_mppe.c
>> +++ b/drivers/net/ppp/ppp_mppe.c
>> @@ -55,6 +55,7 @@
>>  #include <linux/ppp_defs.h>
>>  #include <linux/ppp-comp.h>
>>  #include <linux/scatterlist.h>
>> +#include <linux/net.h>
>>  #include <asm/unaligned.h>
>> =20
>>  #include "ppp_mppe.h"
>> @@ -469,6 +470,15 @@ static void mppe_decomp_reset(void *arg)
>>  }
>> =20
>>  /*
>> + * Compares two coherency counter values.
>> + */
>> +static int
>> +mppe_cmp_ccount(unsigned int a, unsigned int b)
>> +{
>> +	return (int)((a << 20) - (b << 20));
>> +}
>> +
>=20
> How was chosen this magical value ?

	The coherency count it's a 12-bit value. I'll add a define for it.

>=20
>> +/*
>>   * Decompress (decrypt) an MPPE packet.
>>   */
>>  static int
>> @@ -547,6 +557,17 @@ mppe_decompress(void *arg, unsigned char *ibuf,=
 int isize, unsigned char *obuf,
>>  	 */
>> =20
>>  	if (!state->stateful) {
>> +		if (mppe_cmp_ccount(ccount, state->ccount) < 0) {
>> +			if (state->debug >=3D 7 && net_ratelimit())
>> +				printk(KERN_DEBUG
>> +				       "%s[%d:]: Dropping out-of-order packet, "
>> +				       "ccount %u expecting %u.\n",
>> +				       __func__, state->unit, ccount,
>> +				       state->ccount);
>> +
>=20
>=20
> net_dbg_ratelimited() ?

	I think it will be better if I prepare a third patch that cleanups the=
 whole
file after.

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jorge Boncompte - Ingenieria y Gestion de RED
DTI2 - Desarrollo de la Tecnologia de las Comunicaciones
--------------------------------------------------------------
C/ Abogado Enriquez Barrios, 5   14004 CORDOBA (SPAIN)
Tlf: +34 957 761395 / FAX: +34 957 450380
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- There is only so much duct tape you can put on something
  before it just becomes a giant ball of duct tape.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

