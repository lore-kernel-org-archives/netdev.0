From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [net-next PATCH 16/16] Add documentation
Date: Fri, 3 Oct 2008 10:01:18 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0810030949300.3893@fbirervta.pbzchgretzou.qr>
References: <20081001142431.4893.48078.stgit@este> <20081001142431.4893.5367.stgit@este>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:59713 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbYJCOBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 10:01:20 -0400
In-Reply-To: <20081001142431.4893.5367.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2008-10-01 10:24, KOVACS Krisztian wrote:

>+Transparent proxy support
>+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
>+
>+This feature adds Linux 2.2-like transparent proxy support to current=
 kernels.
>+To use it, enable NETFILTER_TPROXY, the socket match and the TPROXY t=
arget in
>+your kernel config. You will need policy routing too, so be sure to e=
nable that
>+as well.

To use server-side transparent proxying (i.e. using a foreign address
when sending out packets), only tproxy_core is needed.

>+fd =3D socket(AF_INET, SOCK_STREAM, 0);

You want to be using IPPROTO_TCP here, as I doubt there is a guarantee
that 0 will never choose SCTP.

>+int value =3D 1;

Const is good:
	static const unsigned int value =3D 1;

>+setsockopt(fd, SOL_IP, IP_TRANSPARENT, &value, sizeof(value));
>+/* - 8< -*/
>+name.sin_family =3D AF_INET;
>+name.sin_port =3D htons(0xCAFE);
>+name.sin_addr.s_addr =3D htonl(0xDEADBEEF);

Replace last one by
	inet_pton(PF_INET, "192.0.2.37", &name.sin_addr);

(Hacking anything inside sin_addr is, strictly speaking, breaking the
=E2=80=9Cencapsulation=E2=80=9D, as far as that =E2=80=9Cexists=E2=80=9D=
 in C.)

>+bind(fd, &name, sizeof(name));

You will need

	bind(fd, (const void *)&name, sizeof(name));

to avoid a compiler warning ;-)

>+2. Redirecting traffic
>+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>+
>+Transparent proxying often involves "intercepting" traffic on a route=
r. This is
>+usually done with the iptables REDIRECT target, however, there are se=
rious
>+limitations of that method. One of the major issues is that it actual=
ly
>+modifies the packets to change the destination address -- which might=
 not be
>+acceptable in certain situations. (Think of proxying UDP for example:=
 you won't
>+be able to find out the original destination address. Even in case of=
 TCP
>+getting the original destination address is racy.)

IIRC, you _can_ find out, though I agree it's rather a hack (with=20
tproxy, you can just use the address as received via recvmsg):

	getsockopt(fd, SOL_IP, SO_ORIGINAL_DST, &sockaddr, &sizeptr);

