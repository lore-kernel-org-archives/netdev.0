From: Tom Parkin <tparkin@katalix.com>
Subject: Re: problems with L2TP
Date: Fri, 3 Jul 2015 16:41:56 +0100
Message-ID: <20150703154155.GA19294@jackdaw>
References: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sumit Semwal <sumit.semwal@linaro.org>
To: Sam Protsenko <semen.protsenko@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:58044 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755233AbbGCPuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2015 11:50:08 -0400
Content-Disposition: inline
In-Reply-To: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sam,

On Fri, Jul 03, 2015 at 04:49:51PM +0300, Sam Protsenko wrote:
> Hi,
>=20
> I'm having issues running user-space code, which uses net/l2tp/l2tp_ppp.c.
> The code is supposed to be running in LAC mode (which is I believe is def=
ault).
> My server configuration described here: https://wiki.linaro.org/LMG/Kerne=
l/PPP
>=20
> I was trying to use next code snippets as user-space part:
>   1. Code example from comments in net/l2tp/l2tp_ppp.c
>   2. Code examples from Documentation/networking/l2tp.txt
>   3. Code from this project: http://www.kvack.org/~bcrl/pppol2tp/multihop=
=2Ec
>=20
> Basically, I was trying two options for user-space code:
>   1. Creating only one sockaddr_pppol2tp, like this:
>=20
>     <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
>     session_fd =3D socket(AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
>     session_sa.sa_family =3D AF_PPPOX;
>     session_sa.sa_protocol =3D PX_PROTO_OL2TP;
>     session_sa.pppol2tp.fd =3D udp_fd;
>     session_sa.pppol2tp.s_tunnel =3D local_tunnel;
>     session_sa.pppol2tp.s_session =3D local_session;
>     session_sa.pppol2tp.d_tunnel =3D remote_tunnel;
>     session_sa.pppol2tp.d_session =3D remote_session;
>     connect(session_fd, (struct sockaddr *)&session_sa,
>             sizeof(session_sa));
>     <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
>=20
>     In that case user-space tool was failing on connect() call.
>=20
>   2. Creating two sockaddr_pppol2tp, like this:
>=20
>     <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
>=20
>     tunnel_fd =3D socket(AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
>     tunnel_sa.sa_family =3D AF_PPPOX;
>     tunnel_sa.sa_protocol =3D PX_PROTO_OL2TP;
>     tunnel_sa.pppol2tp.fd =3D the_socket; /* UDP socket */
>     tunnel_sa.pppol2tp.s_tunnel =3D local_tunnel;
>     tunnel_sa.pppol2tp.s_session =3D 0; /* special case: mgmt socket */
>     tunnel_sa.pppol2tp.d_tunnel =3D remote_tunnel;
>     tunnel_sa.pppol2tp.d_session =3D 0; /* special case: mgmt socket */
>     connect(tunnel_fd, (struct sockaddr *)&tunnel_sa,
>             sizeof(tunnel_sa));
>=20
>     session_fd =3D socket(AF_PPPOX, SOCK_DGRAM, PX_PROTO_OL2TP);
>     session_sa.sa_family =3D AF_PPPOX;
>     session_sa.sa_protocol =3D PX_PROTO_OL2TP;
>     session_sa.pppol2tp.fd =3D udp_fd;
>     session_sa.pppol2tp.s_tunnel =3D local_tunnel;
>     session_sa.pppol2tp.s_session =3D local_session;
>     session_sa.pppol2tp.d_tunnel =3D remote_tunnel;
>     session_sa.pppol2tp.d_session =3D remote_session;
>     connect(session_fd, (struct sockaddr *)&session_sa,
>             sizeof(session_sa));
>     <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
>=20
>     In this case my user-space tool works fine, but my server shows
> next errors in /var/log/syslog:
>=20
>     <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
>     Jul  3 16:32:49 joe-laptop xl2tpd[2978]: Can not find tunnel 25061
> (refhim=3D0)
>     Jul  3 16:32:49 joe-laptop xl2tpd[2978]: network_thread: unable to
> find call or tunnel to handle packet.  call =3D 48566, tunnel =3D 25061
> Dumping.
>     <<<<<<<<<<<<<<<<<<<<<< cut here >>>>>>>>>>>>>>>>>>
>=20
> UDP socket was created next way (for both cases):
> https://android.googlesource.com/platform/external/mtpd/+/0269612ac00a070=
0997dda333faf0a3c33a388b8/mtpd.c#253
>=20
> (see the_socket variable in create_socket() function).
>=20
> So my questions are:
> 1. Am I doing something wrong in userspace part? Because my server
> part is working fine with Android kernel implementation of LAC
> (drivers/net/ppp/pppolac.c). When I'm trying to do the same with
> mainline kernel implementation of LAC -- I'm having issues described
> above.

The second approach looks good to me.  Note that the session only
stays up as long as session_fd is open.

How is the tunnel/session being created on the server side?  How are
you deriving the session and tunnel IDs?  The fact that xl2tp is
complaining about being unable to find tunnel IDs suggests that data
is arriving there but that something isn't correctly configured at
that end.

> 2. Do we have some testing code for L2TP (particularly LAC)? Or maybe
> just some working user-space code sample?
>=20
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVlq1DAAoJEJSMBmUKuovQ6C8IAJMlY1eqz9mtshG9nRd+qiFV
vn7RpxUp03JlV8aRWlB7BJoiLqVe6zFXSMfYPprgB4btgMdU7tAZPhGQbZxbKyj/
0dR0V6zx+P1Q0T3escmYqtEBP+1/4pFjdw9lq2m514eieyH4HzjHRFitU6onsGQd
Bb6th1hiwhcL13hoLI2LtniMJCncgXkWbF3HFsQ7WNQi+uIlkMnpzZZLcxumlU11
8PymY61F7qW8+CXtazFPgygyHaibB1Ymn1CicpkYIepq8ED0HjL2HaUv7NBKRmQ7
FwqW4ZvOIlQ+vXwxlmxslNwhZ6gOaxiodJxyVTkQYj9FmZ3fEfaFo84i8spdzM0=
=FFIj
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
