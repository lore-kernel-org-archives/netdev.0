From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Thu, 22 Jan 2009 23:06:59 +0100
Message-ID: <4978EE03.9040207@cosmosbay.com>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:35287 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbZAVWHH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:07:07 -0500
In-Reply-To: <m3sknbuqf9.wl%vmayatsk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Mayatskikh a =E9crit :
> Hello!
>=20
> I found your latest patches w.r.t. udp port randomization really solv=
e
> the "finding shortest chain kills randomness" problem, but
> significantly slow down system in the case when almost every port is
> in use. Kernel spends too much time trying to find free port number.
>=20
> Try to compile and run this reproducer (after increasing open files
> limit).
>=20
> #include <stdio.h>
> #include <stdlib.h>
> #include <errno.h>
> #include <string.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <pthread.h>
> #include <assert.h>
>=20
> #define PORTS 65536
> #define NP 64
> #define THREADS
>=20
> void* foo(void* arg)
> {
> 	int s, err, i, j;
> 	struct sockaddr_in sa;
> 	int optval =3D 1, port;
> 	unsigned int p[PORTS] =3D { 0 };
>=20
> 	for (i =3D 0; i < PORTS * 100; ++i) {
> 		s =3D socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
> 		assert(s > 0);
> 		memset(&sa, 0, sizeof(sa));
> 		sa.sin_addr.s_addr =3D htonl(INADDR_ANY);
> 		sa.sin_family =3D AF_INET;
> 		sa.sin_port =3D 0;
> 		err =3D bind(s, (const struct sockaddr*)&sa, sizeof(sa));

Bug here, if bind() returns -1 (all ports are in use)

>=20
> 		getsockname(s, (struct sockaddr*)&sa, &j);
> 		port =3D ntohs(sa.sin_port);
> 		p[port] =3D s;
> // free some ports
> 		if (p[port + 1]) {
> 			close(p[port + 1]);
> 			p[port + 1] =3D 0;
> 		}
> 		if (p[port - 1]) {
> 			close(p[port - 1]);
> 			p[port - 1] =3D 0;
> 		}
> 	}
> }
>=20
> int main()
> {
> 	int i, err;
> #ifdef THREADS
> 	pthread_t t[NP];
>=20
> 	for (i =3D 0; i < NP; ++i)
> 	{
> 		err =3D pthread_create(&t[i], NULL, foo, NULL);
> 		assert(err =3D=3D 0);
> 	}
> 	for (i =3D 0; i < NP; ++i)
> 	{
> 		err =3D pthread_join(t[i], NULL);
> 		assert(err =3D=3D 0);
> 	}
> #else
> 	for (i =3D 0; i < NP; ++i) {
> 		err =3D fork();
> 		if (err =3D=3D 0)
> 			foo(NULL);
> 	}
> #endif
> }
>=20
> I ran glxgears and had these numbers:
>=20
> $ glxgears=20
> 3297 frames in 5.0 seconds =3D 659.283 FPS
> 3680 frames in 5.0 seconds =3D 735.847 FPS
> 3840 frames in 5.0 seconds =3D 767.891 FPS
> 3574 frames in 5.0 seconds =3D 714.704 FPS
> -> here I ran reproducer
> 2507 frames in 5.1 seconds =3D 493.173 FPS
> 56 frames in 7.7 seconds =3D  7.316 FPS
> 14 frames in 5.1 seconds =3D  2.752 FPS
> 1 frames in 6.8 seconds =3D  0.146 FPS
> 9 frames in 7.6 seconds =3D  1.188 FPS
> 1 frames in 9.3 seconds =3D  0.108 FPS
> 12 frames in 5.5 seconds =3D  2.187 FPS
> 30 frames in 9.0 seconds =3D  3.338 FPS
> 25 frames in 5.1 seconds =3D  4.888 FPS
> <- here I killed reproducer
> 1034 frames in 5.0 seconds =3D 206.764 FPS
> 3728 frames in 5.0 seconds =3D 745.541 FPS
> 3668 frames in 5.0 seconds =3D 733.496 FPS
>=20
> Last stable kernel survives it more or less smoothly.
>=20
> Thanks!

Hello Vitaly, thanks for this excellent report.

Yes, current code is really not good when all ports are in use :

We now have to scan 28232 [1] times long chains of 220 sockets.
Thats very long (but at least thread is preemptable)

In the past (before patches), only one thread was allowed to run in ker=
nel while scanning
udp port table (we had only one global lock udp_hash_lock protecting th=
e whole udp table).
This thread was faster because it was not slowed down by other threads.
(But the rwlock we used was responsible for starvations of writers if m=
any UDP frames
were received)



One way to solve the problem could be to use following :

1) Raising UDP_HTABLE_SIZE from 128 to 1024 to reduce average chain len=
gths.

2) In bind(0) algo, use rcu locking to find a possible usable port. All=
 cpus can run in //, without
dirtying locks. Then lock the found chain and recheck port is available=
 before using it.

[1] replace 28232 by your actual /proc/sys/net/ipv4/ip_local_port_range=
 values
61000 - 32768 =3D 28232

I will try to code a patch before this week end.

Thanks

Note : I tried to use a mutex to force only one thread in bind(0) code =
but got no real speedup.
But it should help if you have a SMP machine, since only one cpu will b=
e busy in bind(0)


diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cf5ab05..a572407 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -155,6 +155,8 @@ int udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 	struct udp_hslot *hslot;
 	struct udp_table *udptable =3D sk->sk_prot->h.udp_table;
 	int    error =3D 1;
+	static DEFINE_MUTEX(bind0_mutex);
+	int mutex_acquired =3D 0;
 	struct net *net =3D sock_net(sk);
=20
 	if (!snum) {
@@ -162,6 +164,8 @@ int udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 		unsigned rand;
 		unsigned short first;
=20
+		mutex_lock(&bind0_mutex);
+		mutex_acquired =3D 1;
 		inet_get_local_port_range(&low, &high);
 		remaining =3D (high - low) + 1;
=20
@@ -196,6 +200,8 @@ int udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 fail_unlock:
 	spin_unlock_bh(&hslot->lock);
 fail:
+	if (mutex_acquired)
+		mutex_unlock(&bind0_mutex);
 	return error;
 }
=20

