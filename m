From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Wed, 08 Sep 2010 06:42:45 +0200
Message-ID: <1283920965.2634.723.camel@edumazet-laptop>
References: <20100907.125947.39192078.davem@davemloft.net>
	 <1283895316.2634.248.camel@edumazet-laptop> <4C86F653.6070707@hp.com>
	 <20100907.203410.245386536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, ole@ans.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52310 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab0IHEmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 00:42:52 -0400
Received: by fxm16 with SMTP id 16so501400fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 21:42:51 -0700 (PDT)
In-Reply-To: <20100907.203410.245386536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 20:34 -0700, David Miller a =C3=A9cri=
t :
> From: Brian Haley <brian.haley@hp.com>
> Date: Tue, 07 Sep 2010 22:34:59 -0400
>=20
> > Is this really the right thing to do?  Linux has been doing this fo=
rever,
> > right?  Just like BSD has done it forever.
>=20
> Indeed, I checked for this in Stevens volume 2 when I reviewed
> Eric's patch, the logic is identical.
>=20
> > The way I've always "cleared" a local address is to set the address
> > family to AF_UNSPEC on the next connect() call, as mentioned on the
> > man page.  I just want to make sure we're not changing something
> > just to work around a broken application, sendto()/sendmsg() work
> > perfect in this case by not setting the local address.
> >=20

Problem is AF_UNSPEC always clears the remote address (as stated in
manual), and sometimes local one (as not stated)

if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
	inet_reset_saddr(sk);

This is the workaround that was coded years ago in Linux to undo the
local addr setting ;)


=46ollowing program produces this output :

local addr=3D0x7f000001 sin_port=3D37877
after connect(AF_UNSPEC) local addr=3D0x0 sin_port=3D0
local addr=3D0x7f000001 sin_port=3D37877
after connect(AF_UNSPEC) local addr=3D0x7f000001 sin_port=3D0



#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	int fd;
	struct sockaddr_in target, me;
	socklen_t len;

	if ((fd =3D socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) =3D=3D -1) {
		perror("socket");
		return 1;
	}
	memset(&target, 0, sizeof(target));
	target.sin_family =3D AF_INET;
	target.sin_port =3D 123;
	target.sin_addr.s_addr =3D htonl(0x7f000001);
	if (connect(fd, (const struct sockaddr *)&target, sizeof(target)) =3D=3D=
 -1) {
		perror("connect");
		close(fd);
		return 2;
	}
	len =3D sizeof(me);
	if (getsockname(fd, (struct sockaddr *)&me, &len)=3D=3D -1) {
		perror("getsockname");
		close(fd);
		return 3;
	}
	printf("local addr=3D0x%x sin_port=3D%u\n",
		ntohl(me.sin_addr.s_addr), ntohs(me.sin_port));
	memset(&target, 0, sizeof(target));
	target.sin_family =3D AF_UNSPEC;
	if (connect(fd, (const struct sockaddr *)&target, sizeof(target)) =3D=3D=
 -1) {
		perror("connect AF_UNSPEC");
		close(fd);
		return 4;
	}=09
	len =3D sizeof(me);
	if (getsockname(fd, (struct sockaddr *)&me, &len)=3D=3D -1) {
		perror("getsockname 2");
		close(fd);
		return 3;
	}
	printf("after connect(AF_UNSPEC) local addr=3D0x%x sin_port=3D%u\n",
		ntohl(me.sin_addr.s_addr), ntohs(me.sin_port));
	memset(&target, 0, sizeof(target));
	target.sin_family =3D AF_INET;
	target.sin_addr.s_addr =3D htonl(0x7f000001);
	if (bind(fd, (const struct sockaddr *)&target, sizeof(target)) =3D=3D =
-1) {
		perror("bind");
		close(fd);
		return 2;
	}
	len =3D sizeof(me);
	if (getsockname(fd, (struct sockaddr *)&me, &len)=3D=3D -1) {
		perror("getsockname");
		close(fd);
		return 3;
	}
	printf("local addr=3D0x%x sin_port=3D%u\n",
		ntohl(me.sin_addr.s_addr), ntohs(me.sin_port));

	memset(&target, 0, sizeof(target));
	target.sin_family =3D AF_UNSPEC;
	if (connect(fd, (const struct sockaddr *)&target, sizeof(target)) =3D=3D=
 -1) {
		perror("connect AF_UNSPEC");
		close(fd);
		return 4;
	}=09

	len =3D sizeof(me);
	if (getsockname(fd, (struct sockaddr *)&me, &len)=3D=3D -1) {
		perror("getsockname 2");
		close(fd);
		return 3;
	}
	printf("after connect(AF_UNSPEC) local addr=3D0x%x sin_port=3D%u\n",
		ntohl(me.sin_addr.s_addr), ntohs(me.sin_port));
	return 0;
}



