From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with "tcp: bind() fix when many ports are bound" commit
Date: Wed, 28 Apr 2010 19:34:00 +0200
Message-ID: <1272476040.2267.87.camel@edumazet-laptop>
References: <4BD82B29.3000105@retis.net.pl>
	 <20100428.095032.32709294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grzegorz.chwesewicz@retis.net.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100428.095032.32709294.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 28 avril 2010 =C3=A0 09:50 -0700, David Miller a =C3=A9crit=
 :
> From: Grzegorz Chwesewicz <grzegorz.chwesewicz@retis.net.pl>
> Date: Wed, 28 Apr 2010 14:33:45 +0200
>=20
> > 	Hi, I have a problem with binding to port with the latest git kern=
el
> > (my HEAD is at 1600f9def09de07c5dbeb539e978fa73880690dd). Please CC=
 to
> > me as I'm not subscribed to the list.
>=20
> Please send networking bug reports CC:'d to netdev and the people
> who wrote and signed off on the commit you've narrowed down the
> problem to.
>=20
> Otherwise the appropriate people will take longer to find out about
> your bug, and therefore the bug will take longer to fix than
> necessary.
>=20
> Thanks.
>=20
> >=20
> > Example with buggy kernel:
> >=20
> > ensima-hp ~ # /etc/init.d/apache2 start
> >  * Starting apache2 ...
> > (98)Address already in use: make_sock: could not bind to address
> > 127.0.0.1:80
> > no listening sockets available, shutting down
> > Unable to open logs
> >=20
> > As you can see nothing is listening on port 80, but there are old
> > connections to port 80 with CLOSE_WAIT and FIN_WAIT2 state.
> >=20
> > ensima-hp ~ # netstat -pan --inet|grep 80
> > netstat: no support for `AF INET (sctp)' on this system.
> > tcp        0      0 127.0.0.1:631           0.0.0.0:*
> > LISTEN      4806/cupsd
> > tcp        1      0 127.0.0.1:54040         127.0.0.1:80
> > CLOSE_WAIT  5814/konquerorHk573
> > tcp        0      0 127.0.0.1:80            127.0.0.1:54042
> > FIN_WAIT2   -
> > tcp        0      0 127.0.0.1:80            127.0.0.1:54040
> > FIN_WAIT2   -
> > tcp        1      0 127.0.0.1:54042         127.0.0.1:80
> > CLOSE_WAIT  6175/konquerordx573
> >=20
> > So I can't start apache as long as these connections are not fully
> > closed, after that apache starts without problems.
> >=20
> > ensima-hp ~ # netstat -pan --inet|grep 80
> > netstat: no support for `AF INET (sctp)' on this system.
> > tcp        0      0 127.0.0.1:631           0.0.0.0:*
> > LISTEN      4806/cupsd
> >=20
> > ensima-hp ~ # /etc/init.d/apache2 start
> >  * Starting apache2 ...		[OK]
> >=20
> > Problem occured between 2.6.34-rc4 and latest git, bisect shows tha=
t the
> > problem is caused by:
> >=20
> > commit fda48a0d7a8412cedacda46a9c0bf8ef9cd13559
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Wed Apr 21 09:26:15 2010 +0000


Oh well...

I am going to test following patch in a couple of hours (I have to
run ...)

Always allowing a reuse LISTEN if no other listener is already active o=
n
same IP.

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 78cbc39..e2076dd 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -78,6 +78,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
 				    sk2_rcv_saddr =3D=3D sk_rcv_saddr)
 					break;
 			} else if (reuse && sk2->sk_reuse &&
+				   sk->sk_state !=3D TCP_LISTEN &&
 				   sk2_rcv_saddr &&
 				   sk2_rcv_saddr =3D=3D sk_rcv_saddr)
 				break;
