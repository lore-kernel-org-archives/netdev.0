From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: ems_usb: Fix possible tx overflow
Date: Mon, 22 Feb 2016 13:18:38 +0100
Message-ID: <56CAFC9E.7050306@pengutronix.de>
References: <1456068458-14271-1-git-send-email-mkl@pengutronix.de>
 <1456068458-14271-2-git-send-email-mkl@pengutronix.de>
 <56CAFAEE.2020602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="7qx7wNMqf6IboxkQHeQ2irPeGMBAb4WHr"
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>,
	linux-stable <stable@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56CAFAEE.2020602@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7qx7wNMqf6IboxkQHeQ2irPeGMBAb4WHr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 02/22/2016 01:11 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 2/21/2016 6:27 PM, Marc Kleine-Budde wrote:
>=20
>> From: Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>
>>
>> This patch fixes the problem that more CAN messages could be sent to t=
he
>> interface as could be send on the CAN bus. This was more likely for sl=
ow baud
>> rates. The sleeping _start_xmit was woken up in the _write_bulk_callba=
ck. Under
>> heavy TX load this produced another bulk transfer without checking the=

>> free_slots variable and hence caused the overflow in the interface.
>>
>> Signed-off-by: Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>
>> Cc: linux-stable <stable@vger.kernel.org>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> ---
>>   drivers/net/can/usb/ems_usb.c | 14 ++++++++++----
>>   1 file changed, 10 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_u=
sb.c
>> index fc5b75675cd8..eb7192fab593 100644
>> --- a/drivers/net/can/usb/ems_usb.c
>> +++ b/drivers/net/can/usb/ems_usb.c
>> @@ -117,6 +117,9 @@ MODULE_LICENSE("GPL v2");
>>    */
>>   #define EMS_USB_ARM7_CLOCK 8000000
>>
>> +#define CPC_TX_QUEUE_TRIGGER_LOW	25
>> +#define CPC_TX_QUEUE_TRIGGER_HIGH	35
>> +
>>   /*
>>    * CAN-Message representation in a CPC_MSG. Message object type is
>>    * CPC_MSG_TYPE_CAN_FRAME or CPC_MSG_TYPE_RTR_FRAME or
>> @@ -278,6 +281,11 @@ static void ems_usb_read_interrupt_callback(struc=
t urb *urb)
>>   	switch (urb->status) {
>>   	case 0:
>>   		dev->free_slots =3D dev->intr_in_buffer[1];
>> +		if(dev->free_slots > CPC_TX_QUEUE_TRIGGER_HIGH){
>> +			if (netif_queue_stopped(netdev)){
>> +				netif_wake_queue(netdev);
>> +			}
>> +		}
>=20
>     Hm, did anyone run scripts/checkpatch.pl on this patch?

Obviously not. :(

David, I can send a patch to clean up the coding style. Do you want it
for net or via net-next?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--7qx7wNMqf6IboxkQHeQ2irPeGMBAb4WHr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWyvyeAAoJED07qiWsqSVq2ZkH/i56zQP0NKTQ0Ixjx0JT9gMW
1cMsnK8P0A3G+C7A5Q19OHtyDmdqSFW983MKZUxz7oqM3dKb6CwAyDlugkew/U3v
m2pZ55Y/kInS451RyR7RuBgH6dT3J/wi1iYxKsg9x+B1XxdMFKkTpyiINDI3sreb
pzunciLPTHPrS/TnTb+AqVp6fZ7Qdq0YVVS4yNDdZoSRKyaQx+Q37Bv21nbmPlDy
NJYGiXYksCVhaT9bSqVe4nJuhvW+M+HHG+FPCc1okslGL02MLFBHVrwO7MHeu2BM
ips7if8MJv+HuMcy8X0ZrqlVN63QXdHWzQEv3CwvtncgNm09TFcq7Ygvp4aJkzY=
=Wpix
-----END PGP SIGNATURE-----

--7qx7wNMqf6IboxkQHeQ2irPeGMBAb4WHr--
