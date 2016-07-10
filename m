From: Sergei Trofimovich <slyfox@gentoo.org>
Subject: [BUG?] tcp regression in v4.7-r1:
 c14ac9451c34832554db33386a4393be8bba3a7b breaks pulseaudio over TCP
Date: Sun, 10 Jul 2016 12:42:40 +0100
Message-ID: <20160710124240.7d484f44@sf>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/odjIeIcLbnk0K+npN_DyRjg"; protocol="application/pgp-signature"
Cc: Willem de Bruijn <willemb@google.com>, Tanu Kaskinen <tanuk@iki.fi>
To: Soheil Hassas Yeganeh <soheil@google.com>,
	"Signed-off-by: David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37636 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbcGJLmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2016 07:42:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/odjIeIcLbnk0K+npN_DyRjg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi netdev folk!

Commit c14ac9451c34832554db33386a4393be8bba3a7b
broke pulseaudio (PA) over TCP.

PA does unusual thing: it calls
    sendmsg(cmsg_type=3DSCM_CREDENTIALS)
on a TCP socket. It's not a new PA behaviour though.

Originally reported as PA bug (has more details)
    https://bugs.freedesktop.org/show_bug.cgi?id=3D96873

It looks like kernel used to ignore control messages
but now it does not:
    http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/diff/net=
/ipv4/tcp.c?id=3Dc14ac9451c34832554db33386a4393be8bba3a7b

+	if (msg->msg_controllen) {
+		err =3D sock_cmsg_send(sk, msg, &sockc);
+		if (unlikely(err)) {
+			err =3D -EINVAL;
+			goto out_err;
+		}
+	}

This change breaks streaming of pulse clients.

Pulseaudio will be fixed at some point.

But kernel change does not look like intentional
breakage of old behaviour.

Perhaps kernel should have a grace period and only
warn about unsupported control messages for a socket?

Last working kernel: v4.6

Thanks!

--=20

  Sergei

--Sig_/odjIeIcLbnk0K+npN_DyRjg
Content-Type: application/pgp-signature
Content-Description: Цифровая подпись OpenPGP

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAleCNLUACgkQcaHudmEf86oJ/wCfTbcDQTVFdocyCWLp6rJXM4S3
/loAn3UKeMt7Du++30g+JrKEGQUDzcok
=KONn
-----END PGP SIGNATURE-----

--Sig_/odjIeIcLbnk0K+npN_DyRjg--
