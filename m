From: Ulrich Drepper <drepper@redhat.com>
Subject: drop association of connection-less socket
Date: Wed, 19 Sep 2007 00:28:57 -0700
Message-ID: <46F0CFB9.30808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874AbXISH3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 03:29:08 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8J7T6RI002183
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 03:29:06 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8J7T6cj026048
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 03:29:06 -0400
Received: from myware66.akkadia.org (vpn-14-92.rdu.redhat.com [10.11.14.92])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id l8J7T4tT017929
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 03:29:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

The Linux man page for connect(2) currently says:

  Connectionless sockets may dissolve the association by connecting to
  an address with the sa_family member of sockaddr set to AF_UNSPEC.


No such wording is in the POSIX definition which only says

  If  address is a null address for the protocol, the socket=E2=80=99s =
peer
  address shall be reset.


This is not the same but seems to be what Linux implements.


The problem is that I tried to reuse a socket which has been associated
with an IPv6 address to later connect to an IPv4 address.  This is part
of the getaddrinfo implementation and an effort to make it more
efficient.  strace's output  looks like this:

connect(3, {sa_family=3DAF_INET6, sin6_port=3Dhtons(0), inet_pton(AF_IN=
ET6,
"2001:11b8:1:0:207:e94f:ee7c:4b72", &sin6_addr), sin6_flowinfo=3D0,
sin6_scope_id=3D0}, 28) =3D -1 ENETUNREACH (Network is unreachable)

connect(3, {sa_family=3DAF_UNSPEC,
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, 28) =3D 0

connect(3, {sa_family=3DAF_INET, sin_port=3Dhtons(0),
sin_addr=3Dinet_addr("192.168.1.72")}, 16) =3D 0


I.e., despite what the man page says, the second connect only reset the
address, as required by the POSIX spec.  It did not reset the address
family of the socket.


What I ideally would like to see is what the Linux man page says.  I.e.=
,
if the .sa_family field is AF_UNSPEC all, the address and address
family, is reset.  Otherwise only the address association itself is res=
et.

Is this functionality which got lost over time?  Or is the man page
wrong and this never was the case?  Is this a worthwhile change?

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG8M+52ijCOnn/RHQRAnTEAJ0Z/DrTkcCjpbybB5lqDad9Z0MbZwCeLZOh
u/mNfxV7uDjRsSuOj4YwuIg=3D
=3DFO70
-----END PGP SIGNATURE-----
