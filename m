From: Andrew Savchenko <bircoph@gmail.com>
Subject: Kernel recieves DNS reply, but doesn't deliver it to a waiting
 application
Date: Wed, 3 Oct 2012 23:25:48 +0400
Message-ID: <20121003232548.eb6b6b22.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__3_Oct_2012_23_25_48_+0400_7AG+reyv7Fg1U.=o"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:47490 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116Ab2JCT0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 15:26:01 -0400
Received: by lagh6 with SMTP id h6so3171023lag.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 12:26:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__3_Oct_2012_23_25_48_+0400_7AG+reyv7Fg1U.=o
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I encountered a very weird bug: after a while of uptime kernel stops to del=
iver
DNS reply to applications. Tcpdump shows that correct reply is recieved, bu=
t=20
strace shows inquiring application never recieves it and ends with timeout,
epoll_wait() always returns 0:
a slice from: $ host kernel.org 8.8.8.8:

sendmsg(20, {msg_name(16)=3D{sa_family=3DAF_INET, sin_port=3Dhtons(53),
sin_addr=3Dinet_addr("8.8.8.8")}, msg_iov(1)=3D[{"\266\344\1\0\0\1\0\0\0\0\=
0\0\6k
ernel\3org\0\0\1\0\1", 28}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 28 =
          =20
epoll_wait(3, {}, 64, 0)                =3D 0                              =
      =20
epoll_wait(3, {}, 64, 4999)             =3D 0

Though tcpdump shows a normal reply:

20:28:44.162897 IP 10.7.74.7.43167 > 8.8.8.8.domain: 46820+ A? kernel.org. =
(28)=20
20:28:44.221308 IP 8.8.8.8.domain > 10.7.74.7.43167: 46820 1/0/0 A 149.20.4=
.69
(44)

After this bug has occured, it is no longer possible to perform DNS request=
 on
the crippled system. I tried to stop/restart all network-related daemons, to
recreate network interfaces whenever possible (e.g. pppX devices), but with=
 no
help. I use iptables and ebtables on this host, but reseting them (flushing=
 all
chains, removing user chains, setting all policies to ACCEPT) doesn't help.=
 The
only worknig solution is to reboot the system.

This bug happens rarely and randomly (about once in 7-12 days on 24x7 avail=
able
production system), but I had it 5 times already. Due to rare and random na=
ture
of the bug I can't bisect it.

This problem occured after I updated vanilla kernel from 2.6.39.4 to 3.4.6.
Afterward I updated kernel to 3.4.10 in the hope that this will fix the
problem, but with no result. (I updated kernel due to commit
2ce42ec4ef551b08d2e5d26775d838ac640f82ad, which describes somewhat similar
issue, though I don't use I/OAT engine due to lack of hardware support.)

More details, attached trace files and kernel configs are available at bugz=
illa:
https://bugzilla.kernel.org/show_bug.cgi?id=3D48081

In a few days I'll try 3.4.12 (I need to rebuild kernel anyway due to unrel=
ated
issue) and will report if this bug will occur again. But please note it may
take several weeks to check this.

Best regards,
Andrew Savchenko

--Signature=_Wed__3_Oct_2012_23_25_48_+0400_7AG+reyv7Fg1U.=o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlBskUUACgkQ2anJBBcsZw0IyACeOyGzFHV80ukyeh5J/myFtsQN
7AgAn1G09F3qDwAEdbw13WXoe9M0SILw
=gT3O
-----END PGP SIGNATURE-----

--Signature=_Wed__3_Oct_2012_23_25_48_+0400_7AG+reyv7Fg1U.=o--
