From: Simon Farnsworth <simon@farnz.org.uk>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is received
Date: Fri, 20 Feb 2015 16:41:17 +0000
Message-ID: <2498181.kKNYHvd3hx@f19simon>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk> <20150220171014.3970204f0h4aebmu@berry.schulz.ip-v6.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2446833.QqoNWWN2jK"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	mostrows@gmail.com, linux-ppp@vger.kernel.org
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claranet-outbound-smtp07.uk.clara.net ([195.8.89.40]:57060 "EHLO
	claranet-outbound-smtp07.uk.clara.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755294AbbBTQlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 11:41:36 -0500
In-Reply-To: <20150220171014.3970204f0h4aebmu@berry.schulz.ip-v6.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2446833.QqoNWWN2jK
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Friday 20 February 2015 17:10:14 Christoph Schulz wrote:
> (Cc: linux-ppp@vger.kernel.org, mostrows@gmail.com)
>=20
> Hello!
>=20
> Simon Farnsworth schrieb am Thu, 19 Feb 2015 21:24:28 +0000:
>=20
> > When a PADT frame is received, the socket may not be in a good stat=
e to
> > close down the PPP interface. The current implementation handles th=
is by
> > simply blocking all further PPP traffic, and hoping that the lack o=
f traffic
> > will trigger the user to investigate.
> >
> > Use schedule_work to get to a process context from which we clear d=
own the
> > PPP interface, in a fashion analogous to hangup on a TTY-based PPP
> > interface. This causes pppd to disconnect immediately, and allows t=
ools to
> > take immediate corrective action.
>=20
> Tested-by: Christoph Schulz <develop@kristov.de>
>=20
<snip success report>
> However, note also that your patch causes pppd (or rather the rp-pppo=
e =20
> plugin) to wonder about the socket closed by the kernel:
>=20
> Feb 20 16:45:44 sandbox local2.err pppd[539]: Failed to disconnect =20=

> PPPoE socket: 114 Operation already in progress
>
I assume there's nothing else wrong here, other than pppd complaining? =
The
code doesn't suggest there will be issues if we fail to disconnect.

> I don't fully understand the code there; it seems that the plugin =20=

> *connects* the PPPoE session socket in order to *disconnect* it:
>=20
> static void
> PPPOEDisconnectDevice(void)
> {
>      struct sockaddr_pppox sp;
>=20
>      sp.sa_family =3D AF_PPPOX;
>      sp.sa_protocol =3D PX_PROTO_OE;
>      sp.sa_addr.pppoe.sid =3D 0;
>      memcpy(sp.sa_addr.pppoe.dev, conn->ifName, IFNAMSIZ);
>      memcpy(sp.sa_addr.pppoe.remote, conn->peerEth, ETH_ALEN);
>      if (connect(conn->sessionSocket, (struct sockaddr *) &sp,
>                  sizeof(struct sockaddr_pppox)) < 0)
>          error("Failed to disconnect PPPoE socket: %d %m", errno);
>      close(conn->sessionSocket);
>      /* don't send PADT?? */
>      if (conn->discoverySocket >=3D 0)
>          close(conn->discoverySocket);
> }

The code is trying to disconnect the session by connecting to session 0=

(which is invalid) in order to stop data flow. I'll have another look a=
t the
kernel code tonight to see if that does anything that
close(conn->sessionSocket) won't do - I can't see a good reason for it,=

though.

I suspect this is a straight bug in the rp-pppoe.so plugin.
=2D-
Simon Farnsworth

--nextPart2446833.QqoNWWN2jK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABAgAGBQJU52OwAAoJEOsKZy3xM+c79sYH/0P2+K6c9Tch8+fVBGorGTku
yjZE9YAiJvNTLEnH7DYPGaZBgFl4V4LbNkrUfJO6yauDzq79SZAVyckI+Xcrm5aQ
JlswTfby7ix0om/x28xI2jxILv1E58MJPKZ73J+Ce+xInxQWnP9+bYAEuegIJG88
GSnAyydrFwGYmysiq5DXxJUiq/rRed3Fa3JLnY6PzsDoG98SI2I5/uq7o0c2j0ge
Kt82TWH+PVlBwygiuJf8eeIofaeW67xqLNgZxtXLo9g++yqZ+jyb0yH8YbsllX3q
v3pLKgl4AlbdHZolsEHYW1VIexd+t3Uausz5m9qqYG/7XlHqDEN7ExylUbMY6Gw=
=wmGK
-----END PGP SIGNATURE-----

--nextPart2446833.QqoNWWN2jK--
