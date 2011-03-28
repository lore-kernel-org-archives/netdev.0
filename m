From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: poll broken (for can)
Date: Mon, 28 Mar 2011 21:32:50 +0200
Message-ID: <4D90E262.1090201@pengutronix.de>
References: <1301321142.9519.10.camel@lukonin-pc>	<4D90A7E9.1080804@grandegger.com>
	<4D90AA8A.9010804@pengutronix.de> <4D90AF67.1080405@grandegger.com>
	<4D90B3B0.2010401@pengutronix.de> <4D90CB17.4030205@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1113765869952639809=="
Cc: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D90CB17.4030205-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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
--===============1113765869952639809==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2D727D7A3683CA563D9B9853"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2D727D7A3683CA563D9B9853
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/28/2011 07:53 PM, Oliver Hartkopp wrote:
> On 28.03.2011 18:13, Marc Kleine-Budde wrote:
>> On 03/28/2011 05:55 PM, Wolfgang Grandegger wrote:
>>>> BTW: I figured out why poll() wakes you up but the next write will f=
ail
>>>> with -ENOBUFS again.
>>>
>>> Ah, I'm curious? I also did realize that poll does burn CPU cycles
>>> (instead of waiting).
>>
>> The poll callback checks if the used memory is less than the half of p=
er
>> socket snd buffer (IIRC ~60K). See:
>>
>> datagram_poll (http://lxr.linux.no/linux+v2.6.38/net/core/datagram.c#L=
737)
>> sock_writeable (http://lxr.linux.no/linux+v2.6.38/include/net/sock.h#L=
1618)
>>
>> Because the size of a can frame (+the skb overhead) is much less then
>> the ethernet frame (+overhead) the default value for the snd buffer is=

>> too big for can.
>>
>> We get the -ENOBUF from write() if the tx_queue_len (default 10) is
>> exceeded.
>>
>> http://lxr.linux.no/linux+v2.6.38/drivers/net/can/dev.c#L435
>> http://lxr.linux.no/linux+v2.6.38/net/can/af_can.c#L268
>>
>=20
> What would be your suggestion? Decreasing the socket send buffer for CA=
N by
> default?

I haven't done any testing.....As far as I understand the code, we can
a) increase the default tx_queue_len and/or
b) decrease the default snd buffer size.

Note: a) is a per device setting whereas b) is a per socket setting.

With the current settings the -ENOBUF is triggered if we have X unsend
can frames (per device) where X equals the tx_queue_len. This means
using 5 applications, it about 2 queued (i.e. unsent) frames per app and
device.

If we increase the tx_queue_len to a high value (via ifconfig), so that
the snd buffer is fully used, before the tx_queue_len is exceeded the
write system call will block, (or return -EAGAIN of opened non
blocking). At least the last time I've done this.

I think solution b) would lead to a similar behavioural change.

What do we really want to specify?

Something like: queue up to X frames per socket and queue only Y frames
per device. Where Y =3D X * n and n is "I don't know yet"?

Y is simple, it's the tx_queue_len. But X is more complicated. The can
frames have non constant length (i.e. dlc) and I'm not sure that the
netdev people say if we misuse the sock_alloc_send_pskb() for our
tx-flow-control :)

Cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig2D727D7A3683CA563D9B9853
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2Q4mYACgkQjTAFq1RaXHNUeQCeN+pL7YvFnwYIo5TWG2Fm2R95
mioAn2Di2Kn+7xCpOiBQBJUe/OgaMi6o
=kY7V
-----END PGP SIGNATURE-----

--------------enig2D727D7A3683CA563D9B9853--

--===============1113765869952639809==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============1113765869952639809==--
