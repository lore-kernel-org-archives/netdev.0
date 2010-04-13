From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEADDR with UDP (again)
Date: Tue, 13 Apr 2010 14:21:37 +0200
Message-ID: <1271161297.16881.293.camel@edumazet-laptop>
References: <20100413093408.GA16595@myhost.felk.cvut.cz>
	 <1271155163.16881.244.camel@edumazet-laptop>
	 <20100413112726.GB16595@myhost.felk.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Svoboda <michal.svoboda@agents.felk.cvut.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:38127 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab0DMMWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 08:22:06 -0400
Received: by bwz19 with SMTP id 19so375bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 05:22:02 -0700 (PDT)
In-Reply-To: <20100413112726.GB16595@myhost.felk.cvut.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 13:27 +0200, Michal Svoboda a =C3=A9crit =
:
> Eric Dumazet wrote:
> > Why do you use REUSEADDR ? This is doing what is documented.
> >=20
> >        SO_REUSEADDR
> >               Indicates that the rules used in validating addresses=
  supplied
> >               in  a  bind(2) call should allow reuse of local addre=
sses.  For
> >               AF_INET sockets this means that a socket may bind, ex=
cept  when
> >               there is an active listening socket bound to the addr=
ess.  When
> >               the listening socket is bound to  INADDR_ANY  with  a=
  specific
> >               port then it is not possible to bind to this port for=
 any local
> >               address.  Argument is an integer boolean flag.
>=20
> I read it 10 times but it doesn't say anything about stealing frames,=
 or
> implementation-defined behavior in this case.

If it is not documented, it is implementation defined.

>=20
> > An UDP application wanting a port for its exclusive use dont set
> > REUSEADDR, or basically allows anybody to bind an udp socket to sam=
e
> > port, and potentially steal incoming frames.
>=20
> That's fair enough, I will talk to the developers of the "very buggy"
> applications that use this flag and ask them to reconsider.

;)

> =20
> > REUSEADDR is usually used when an application has several sockets b=
ound
> > to same port, but different IP addresses (or bound to different dev=
ices)
>=20
> I just tried that and you can bind to different IPs without REUSEADDR=
=2E

Of course it is possible !

REUSEADDR allows following :

(Note that both sockets MUST have requested REUSEADDR=3D1)


#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>

main()
{
int sock1, sock2;
struct sockaddr_in addr;
int on =3D 1;

memset(&addr, 0, sizeof(addr));
addr.sin_port =3D htons(3444);
addr.sin_family =3D AF_INET;

sock1 =3D socket(AF_INET, SOCK_DGRAM, 0);
setsockopt(sock1, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
addr.sin_addr.s_addr =3D htonl(0x7f000001);
if (bind(sock1, (struct sockaddr *)&addr, sizeof(addr)))
	perror("bind1");

sock2 =3D socket(AF_INET, SOCK_DGRAM, 0);
setsockopt(sock2, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
addr.sin_addr.s_addr =3D INADDR_ANY; /* or htonl(0x7f000001); */
if (bind(sock2, (struct sockaddr *)&addr, sizeof(addr)))
	perror("bind2");
}



If an application didnt specified REUSEADDR=3D1, then its UDP port is
private, it cannot be stolen.

Therefore, applications should not use REUSEADDR on unicast UDP, unless
it is a non security issue (for example, if it is able to react to any
new IP addresses added by the administrator on the machine, and complai=
n
loudly if another application could bind() before itself)

REUSADDR has a meaning for multicast, but for unicast... this is hardly
useful ?


About the connect() thing, its also a fact that connected sockets have =
a
higher priority (they'll receive incoming frames, their score his highe=
r
than a non connected socket, if source of the packet matches the connec=
t
destination of course). Same thing if you play with BINDTODEVICE.



