From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Fri, 23 Jan 2009 14:44:22 +0100
Message-ID: <4979C9B6.3080302@cosmosbay.com>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com>	<4978EE03.9040207@cosmosbay.com>	<m3iqo7dkw4.wl%vmayatsk@redhat.com>	<49790C02.90800@cosmosbay.com> <m3bpty1hq7.wl%vmayatsk@redhat.com> <4979ADCA.2080106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reverse.completel.net ([212.99.114.194]:51689 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbZAWNo2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:44:28 -0500
In-Reply-To: <4979ADCA.2080106@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Vitaly Mayatskikh a =E9crit :
>> At Fri, 23 Jan 2009 01:14:58 +0100, Eric Dumazet wrote:
>>
>>> Could you try following patch ?
>>>
>>> Thank you
>>>
>>> [PATCH] udp: optimize bind(0) if many ports are in use
>>>
>>> commit 9088c5609584684149f3fb5b065aa7f18dcb03ff
>>> (udp: Improve port randomization) introduced a regression for UDP b=
ind() syscall
>>> to null port (getting a random port) in case lot of ports are alrea=
dy in use.
>>>
>>> This is because we do about 28000 scans of very long chains (220 so=
ckets per chain),
>>> with many spin_lock_bh()/spin_unlock_bh() calls.
>>>
>>> Fix this using a bitmap (64 bytes for current value of UDP_HTABLE_S=
IZE)
>>> so that we scan chains at most once.
>>>
>>> Instead of 250 ms per bind() call, we get after patch a time of 2.9=
 ms=20
>> It's much better, thanks. FPS in glxgears now drops down only 2x
>> harder if compare with 2.6.28. However, this again kills randomness =
:)
>> Now number distribution is k*x^2 with x-axis zero in the (high - low=
)

>=20
> Interesting... Please note I dont search in the bitmap from its begin=
ing,
> but from a random point.
>=20
> Maybe we should study lib/random32.c and discover it has said distrib=
ution :)
>=20
> Since my algo uses net_random() (random32() to get 32 bits number, th=
at we
> split in two "16 bits numbers" (bias & rand).
>=20
> One (bias) to select the starting chain and starting slot in chain (s=
o it really should be random)
> first =3D bias + 0  (slotn=3D0)
>=20
> One (rand, forced to be odd) to select next slot in chain in case cur=
rent slot is already in use.
> I feel this is the problem, because when we hit a slot outside of ip_=
local_port_range, it seems we
> escape from this range with the distribution you got. maybe we should=
 get rand depending on ip_local_port_range
>=20
>=20

Here is an updated of patch, that still have an uniform random distribu=
tion,
keeping a starting point in the range [low - high].

My attempt to avoid a divide failed ;)

Thank you

[PATCH] udp: optimize bind(0) if many ports are in use

commit 9088c5609584684149f3fb5b065aa7f18dcb03ff
(udp: Improve port randomization) introduced a regression for UDP bind(=
) syscall
to null port (getting a random port) in case lot of ports are already i=
n use.

This is because we do about 28000 scans of very long chains (220 socket=
s per chain),
with many spin_lock_bh()/spin_unlock_bh() calls.

=46ix this using a bitmap (64 bytes for current value of UDP_HTABLE_SIZ=
E)
so that we scan chains at most once.

Instead of 250 ms per bind() call, we get after patch a time of 2.9 ms=20

Based on a report from Vitaly Mayatskikh

Reported-by: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cf5ab05..6e27868 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -120,8 +120,11 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
 atomic_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
=20
+#define PORTS_PER_CHAIN (65536 / UDP_HTABLE_SIZE)
+
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       const struct udp_hslot *hslot,
+			       unsigned long *bitmap,
 			       struct sock *sk,
 			       int (*saddr_comp)(const struct sock *sk1,
 						 const struct sock *sk2))
@@ -132,12 +135,16 @@ static int udp_lib_lport_inuse(struct net *net, _=
_u16 num,
 	sk_nulls_for_each(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net)			&&
 		    sk2 !=3D sk					&&
-		    sk2->sk_hash =3D=3D num				&&
+		    (bitmap || sk2->sk_hash =3D=3D num)		&&
 		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
 			|| sk2->sk_bound_dev_if =3D=3D sk->sk_bound_dev_if) &&
-		    (*saddr_comp)(sk, sk2))
-			return 1;
+		    (*saddr_comp)(sk, sk2)) {
+			if (bitmap)
+				__set_bit(sk2->sk_hash / UDP_HTABLE_SIZE, bitmap);
+			else
+				return 1;
+		}
 	return 0;
 }
=20
@@ -160,32 +167,42 @@ int udp_lib_get_port(struct sock *sk, unsigned sh=
ort snum,
 	if (!snum) {
 		int low, high, remaining;
 		unsigned rand;
-		unsigned short first;
+		unsigned short first, last;
+		DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);
=20
 		inet_get_local_port_range(&low, &high);
 		remaining =3D (high - low) + 1;
=20
 		rand =3D net_random();
-		snum =3D first =3D rand % remaining + low;
-		rand |=3D 1;
-		for (;;) {
-			hslot =3D &udptable->hash[udp_hashfn(net, snum)];
+		first =3D rand % remaining + low;
+		rand =3D (rand | 1) * UDP_HTABLE_SIZE;
+		for (last =3D first + UDP_HTABLE_SIZE; first !=3D last; first++) {
+			hslot =3D &udptable->hash[udp_hashfn(net, first)];
+			bitmap_zero(bitmap, PORTS_PER_CHAIN);
 			spin_lock_bh(&hslot->lock);
-			if (!udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
-				break;
-			spin_unlock_bh(&hslot->lock);
+			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk, saddr_comp);
+
+			snum =3D first;
+			/*
+			 * PORTS_PER_CHAIN loops, because snum is unsigned short
+			 * and we add an odd multiple of UDP_HTABLE_SIZE
+			 */
 			do {
-				snum =3D snum + rand;
-			} while (snum < low || snum > high);
-			if (snum =3D=3D first)
-				goto fail;
+				if (low <=3D snum && snum <=3D high &&
+				    !test_bit(snum / UDP_HTABLE_SIZE, bitmap))
+					goto found;
+				snum +=3D rand;
+			} while (snum !=3D first);
+			spin_unlock_bh(&hslot->lock);
 		}
+		goto fail;
 	} else {
 		hslot =3D &udptable->hash[udp_hashfn(net, snum)];
 		spin_lock_bh(&hslot->lock);
-		if (udp_lib_lport_inuse(net, snum, hslot, sk, saddr_comp))
+		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk, saddr_comp))
 			goto fail_unlock;
 	}
+found:
 	inet_sk(sk)->num =3D snum;
 	sk->sk_hash =3D snum;
 	if (sk_unhashed(sk)) {

