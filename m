From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: poll broken (for can)
Date: Wed, 30 Mar 2011 10:53:17 +0200
Message-ID: <4D92EF7D.8050902@pengutronix.de>
References: <1301321142.9519.10.camel@lukonin-pc>	<4D90A7E9.1080804@grandegger.com>
	<4D90AA8A.9010804@pengutronix.de> <4D90AF67.1080405@grandegger.com>
	<4D90B3B0.2010401@pengutronix.de> <4D90CB17.4030205@hartkopp.net>
	<4D90E262.1090201@pengutronix.de> <4D923B00.20500@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1815453595974729127=="
Cc: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D923B00.20500-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============1815453595974729127==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5AE48E2C373109D9A08F0F0C"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5AE48E2C373109D9A08F0F0C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/29/2011 10:03 PM, Oliver Hartkopp wrote:
> On 28.03.2011 21:32, Marc Kleine-Budde wrote:
>> On 03/28/2011 07:53 PM, Oliver Hartkopp wrote:
>>> On 28.03.2011 18:13, Marc Kleine-Budde wrote:
>>>> On 03/28/2011 05:55 PM, Wolfgang Grandegger wrote:
>>>>>> BTW: I figured out why poll() wakes you up but the next write will=
 fail
>>>>>> with -ENOBUFS again.
>>>>>
>>>>> Ah, I'm curious? I also did realize that poll does burn CPU cycles
>>>>> (instead of waiting).
>>>>
>>>> The poll callback checks if the used memory is less than the half of=
 per
>>>> socket snd buffer (IIRC ~60K). See:
>>>>
>>>> datagram_poll (http://lxr.linux.no/linux+v2.6.38/net/core/datagram.c=
#L737)
>>>> sock_writeable (http://lxr.linux.no/linux+v2.6.38/include/net/sock.h=
#L1618)
>>>>
>>>> Because the size of a can frame (+the skb overhead) is much less the=
n
>>>> the ethernet frame (+overhead) the default value for the snd buffer =
is
>>>> too big for can.
>>>>
>>>> We get the -ENOBUF from write() if the tx_queue_len (default 10) is
>>>> exceeded.
>>>>
>>>> http://lxr.linux.no/linux+v2.6.38/drivers/net/can/dev.c#L435
>>>> http://lxr.linux.no/linux+v2.6.38/net/can/af_can.c#L268
>>>>
>>>
>>> What would be your suggestion? Decreasing the socket send buffer for =
CAN by
>>> default?
>>
>> I haven't done any testing.....As far as I understand the code, we can=

>> a) increase the default tx_queue_len and/or
>> b) decrease the default snd buffer size.
>>
>> Note: a) is a per device setting whereas b) is a per socket setting.
>>
>> With the current settings the -ENOBUF is triggered if we have X unsend=

>> can frames (per device) where X equals the tx_queue_len. This means
>> using 5 applications, it about 2 queued (i.e. unsent) frames per app a=
nd
>> device.
>>
>> If we increase the tx_queue_len to a high value (via ifconfig), so tha=
t
>> the snd buffer is fully used, before the tx_queue_len is exceeded the
>> write system call will block, (or return -EAGAIN of opened non
>> blocking). At least the last time I've done this.
>>
>> I think solution b) would lead to a similar behavioural change.
>>
>> What do we really want to specify?
>=20
> Hm - the problem could be that people expect their frames to be sent 'i=
n
> time', so if we increase the tx_queue_len, it's not transparent when th=
e
> frames are potentially leaving the system - and if the application data=
 is
> already out-dated when hitting the medium.
>=20
> What about having up to three CAN frames in each CAN_RAW socket send bu=
ffer
> and e.g.50 frames in the tx_queue_len of the netdevice as a starting po=
int?

With current the tx_queue_len of 10 it's 10 frames for a single
application scenario. But I don't have any real world CAN experience.

>> Something like: queue up to X frames per socket and queue only Y frame=
s
>> per device. Where Y =3D X * n and n is "I don't know yet"?
>>
>> Y is simple, it's the tx_queue_len. But X is more complicated. The can=

>> frames have non constant length (i.e. dlc) and I'm not sure that the
>> netdev people say if we misuse the sock_alloc_send_pskb() for our
>> tx-flow-control :)

> I would propose to count the CAN frames independently from the can_dlc.=
 AFAIK

Sure - That's what we want. The code has to be written, though :)

> the tx_queue_len is dealing with skb's - and the skb->len for the socke=
t send
> buffer is also size of struct can_frame, right?

I don't know the code in depth, but I think the skb holding the outgoing
can frame is allocated (or at least accounted) from the snd buffer.
Maybe even more data structures.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig5AE48E2C373109D9A08F0F0C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2S74AACgkQjTAFq1RaXHOzlQCgks4d5n4ghFZvZx30UQmG3oay
h+0AnRArCCjaBUW34WSeN836Qm0xkE0Y
=IbfT
-----END PGP SIGNATURE-----

--------------enig5AE48E2C373109D9A08F0F0C--

--===============1815453595974729127==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============1815453595974729127==--
