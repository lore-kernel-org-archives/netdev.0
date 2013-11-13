From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: shutdown(3) and bluetooth.
Date: Wed, 13 Nov 2013 10:58:43 +0900
Message-ID: <78727581-9350-4E23-95C6-5E7510C24A72@holtmann.org>
References: <20131112211125.GA2912@redhat.com> <DF4C2B40-BD87-4E88-911D-E3E5F488CAE4@holtmann.org> <20131112221038.GA6689@redhat.com> <FC5CE013-B077-4EA5-81C1-A7D8B4A5EF85@holtmann.org> <20131112224819.GE9057@redhat.com> <D8BE686E-E81D-48CD-8D67-2B138191E0CC@holtmann.org> <20131113002819.GB12615@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"linux-bluetooth@vger.kernel.org development"
	<linux-bluetooth@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55050 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239Ab3KMB6w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:58:52 -0500
In-Reply-To: <20131113002819.GB12615@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>>> So it seems it affects both SCO and RFCOMM.
>>>=20
>>>> What kernel did you run this against? It is a shot in the dark, bu=
t can you try linux-next quickly.
>>>> There was a socket related fix for the socket options where we con=
fused RFCOMM vs L2CAP struct sock.
>>>=20
>>> first noticed it on Linus' latest HEAD, and then reproduced it on 3=
=2E11.6
>>> I'll look at linux-next tomorrow.
>>=20
>> I looked through the code and only call bt_sock_wait_state when SOCK=
_LINGER and sk_lingertime is set. In that case we actually block until =
the socket state changes to BT_CLOSED.
>>=20
>> The only way I see this could happen is if you have a huge linger ti=
meout and confused the socket state before. What is actually the list o=
f system calls that you are throwing at this socket.
>=20
> Ah. I recently changed some code that's now doing this on every socke=
t at shutdown..
> (simplified cut-n-paste)
>=20
>        struct linger ling =3D { .l_onoff =3D FALSE, };
>=20
>        for (i =3D 0; i < nr_sockets; i++) {
>                fd =3D shm->sockets[i].fd;
>                shm->sockets[i].fd =3D 0;
>=20
>                setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(st=
ruct linger));
>                shutdown(fd, SHUT_RDWR);
>                close(fd);
>        }
>=20
> I could just rip out that linger code completely and just hope that s=
ockets staying in
> TIME_WAIT is good enough. iirc, I added it when after multiple runs, =
some of the
> weirder protocols would fail to open a socket once a certain number o=
f existing
> sockets had opened, even if they were in SOCK_WAIT
>=20
> two remaining questions though. That code is setting linger to false.=
 Why would
> that cause the sk_lingertime to be taken into consideration ?  And wh=
y is this
> only a problem for bluetooth (apparently) ?

we are not touching that part of setsockopt. That is handled by net/cor=
e/sock.c and we just check if SOCK_LINGER flag is set and if we have a =
positive sk_lingertime. So this is a bit suspicious on why this is happ=
ening, but I don=92t think it is our mistake.

Regards

Marcel
