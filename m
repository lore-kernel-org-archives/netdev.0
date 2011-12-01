From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: Is there any necessary to add multicast route for a loopback
 device?
Date: Thu, 01 Dec 2011 14:01:27 +0800
Message-ID: <4ED71837.6010309@cn.fujitsu.com>
References: <4ED5DD7D.10908@cn.fujitsu.com>		<4ED6E6A8.3080702@cn.fujitsu.com>	 <20111130.223539.675481575068605501.davem@davemloft.net>	 <4ED70332.4000405@cn.fujitsu.com> <1322714206.2577.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50918 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab1LAGBO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 01:01:14 -0500
In-Reply-To: <1322714206.2577.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 12:31 +0800, Li Wei a =C3=A9cri=
t :
>>> From: Li Wei <lw@cn.fujitsu.com>
>>> Date: Thu, 01 Dec 2011 10:30:00 +0800
>>>
>>>> what's your opinion?
>>> I have many higher priority tasks than this issue, so it is a poor
>>> idea to try and force me to look into this.
>>>
>>> If no other developer cares to answer, maybe it isn't all that
>>> important.
>>>
>>>
>> My apologize :(
>=20
> It would help us if you provide a test program an setup script, becau=
se
> we have litle time to figure out what exact problem you hit.
>=20
>=20
>=20
>=20
>=20

Thanks Eric!

The following is the test code:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D cut =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>

#define MADDR	"ff00::00"

int main(int argc, char **argv) {
	struct ipv6_mreq mreq;
	struct in6_addr addr;
	unsigned int mcast_if;
	int sk;

	if((sk =3D socket(AF_INET6, SOCK_DGRAM, 0)) =3D=3D -1) {
		printf("socket\n");
		exit(1);
	}

	inet_pton(AF_INET6, MADDR, &addr);
	mreq.ipv6mr_multiaddr =3D addr;

	printf("=3D=3D join a multicast group with the interface index is spec=
ified as 0 =3D=3D\n");
	mreq.ipv6mr_interface =3D 0;
	if (setsockopt(sk, IPPROTO_IPV6, IPV6_JOIN_GROUP,
		       (char *) &mreq, sizeof(mreq)) =3D=3D -1) {
		perror("setsockopt IPV6_JOIN_GROUP");
		exit(1);
	}

	close(sk);

	printf("OK\n");
	return 0;
}
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D cut =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

My aim is to join a multicast group without the interface index specifi=
ed, as the RFC 3493
(5.2 Sending and Receiving Multicast Packets) said "If the interface in=
dex is specified as 0,
the kernel chooses the local interface.".

When this test run on Fedora 15(ipv6 enabled), it failed and return err=
or ENODEV.

This problem can be reproduced by the following steps:
1. enable ipv6 if you haven't
# modprobe ipv6
2. make all network interfaces down
# ip link set lo down; ip link set eth0 down; ...
3. set a ipv6 address for lo
# ip addr add ::1/128 dev lo
4. make all interfaces up
# ip link set lo up; ip link set eth0 up; ...

run test and it will return ENODEV
