From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Fri, 23 Jan 2009 12:45:14 +0100
Message-ID: <4979ADCA.2080106@cosmosbay.com>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com>	<4978EE03.9040207@cosmosbay.com>	<m3iqo7dkw4.wl%vmayatsk@redhat.com>	<49790C02.90800@cosmosbay.com> <m3bpty1hq7.wl%vmayatsk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reverse.completel.net ([212.99.114.194]:34859 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754870AbZAWMAs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 07:00:48 -0500
In-Reply-To: <m3bpty1hq7.wl%vmayatsk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Mayatskikh a =E9crit :
> At Fri, 23 Jan 2009 01:14:58 +0100, Eric Dumazet wrote:
>=20
>> Could you try following patch ?
>>
>> Thank you
>>
>> [PATCH] udp: optimize bind(0) if many ports are in use
>>
>> commit 9088c5609584684149f3fb5b065aa7f18dcb03ff
>> (udp: Improve port randomization) introduced a regression for UDP bi=
nd() syscall
>> to null port (getting a random port) in case lot of ports are alread=
y in use.
>>
>> This is because we do about 28000 scans of very long chains (220 soc=
kets per chain),
>> with many spin_lock_bh()/spin_unlock_bh() calls.
>>
>> Fix this using a bitmap (64 bytes for current value of UDP_HTABLE_SI=
ZE)
>> so that we scan chains at most once.
>>
>> Instead of 250 ms per bind() call, we get after patch a time of 2.9 =
ms=20
>=20
> It's much better, thanks. FPS in glxgears now drops down only 2x
> harder if compare with 2.6.28. However, this again kills randomness :=
)
> Now number distribution is k*x^2 with x-axis zero in the (high - low)
> / 2. Try this program, it produces input file for Octave + Gnuplot.
>=20
> #include <stdio.h>
> #include <errno.h>
> #include <string.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
>=20
> #define PORTS 65536
>=20
> int main()
> {
> 	int s, err, i, j;
> 	char buf[256];
> 	struct sockaddr_in sa;
> 	int optval =3D 1, port;
> 	unsigned int p[PORTS] =3D { 0 };
>=20
> 	for (i =3D 0; i < PORTS * 100; ++i) {
> 		s =3D socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
> 		memset(&sa, 0, sizeof(sa));
> 		sa.sin_addr.s_addr =3D htonl(INADDR_ANY);
> 		sa.sin_family =3D AF_INET;
> 		sa.sin_port =3D 0;
> 		setsockopt(s, IPPROTO_UDP, SO_REUSEADDR, &optval, sizeof(optval));
> 		err =3D bind(s, (const struct sockaddr*)&sa, sizeof(sa));
> 		getsockname(s, (struct sockaddr*)&sa, &j);
> 		port =3D ntohs(sa.sin_port);
> 		p[port]++;
> 		close(s);
> 	}
> 	printf("x =3D 32766:1:65535;\ny =3D [-100; ");
> 	for (i =3D 32767; i < PORTS; i++)
> 		printf("%d%s", p[i], (i + 1 < PORTS ? "; " : ""));
> 	printf("];\nplot(x,y,'.');pause;");
> }
>=20
> I was thinking about bitmap also, but in a bit different approach. It
> is also uses bias (delta) value instead of exact port number. When we
> get next random port value (from rng or in the next iteration), we ca=
n
> calculate byte offset in that bitmap:
>=20
>     A        B        C        D
> 76543210 76543210 7654321 076543210
> 11110111 11011110 1001111 011110111
>             ^
>=20
> We here land in the byte B in the marked bit position, but it is
> already busy. If there're any free bits in this byte B, we can stop
> further iterations and use any free bit. I don't think it can kill
> randomness too much, because average bias will be small. May be it
> only needs some more complicated logic for searching free bit in the
> byte, because it's not good to do scanning always from the beginning.
>=20

Interesting... Please note I dont search in the bitmap from its beginin=
g,
but from a random point.

Maybe we should study lib/random32.c and discover it has said distribut=
ion :)

Since my algo uses net_random() (random32() to get 32 bits number, that=
 we
split in two "16 bits numbers" (bias & rand).

One (bias) to select the starting chain and starting slot in chain (so =
it really should be random)
first =3D bias + 0  (slotn=3D0)

One (rand, forced to be odd) to select next slot in chain in case curre=
nt slot is already in use.
I feel this is the problem, because when we hit a slot outside of ip_lo=
cal_port_range, it seems we
escape from this range with the distribution you got. maybe we should g=
et rand depending on ip_local_port_range



