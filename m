From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Fri, 23 Jan 2009 01:14:58 +0100
Message-ID: <49790C02.90800@cosmosbay.com>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com>	<4978EE03.9040207@cosmosbay.com> <m3iqo7dkw4.wl%vmayatsk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:60882 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756044AbZAWAPH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 19:15:07 -0500
In-Reply-To: <m3iqo7dkw4.wl%vmayatsk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Mayatskikh a =E9crit :
> At Thu, 22 Jan 2009 23:06:59 +0100, Eric Dumazet wrote:
>=20
>>> 		err =3D bind(s, (const struct sockaddr*)&sa, sizeof(sa));
>> Bug here, if bind() returns -1 (all ports are in use)
>=20
> Yeah, there was assert(), but the program drops to problems very soon=
,
> I was lazy to handle this situation correctly and just removed it ;)
>=20
>>> Thanks!
>> Hello Vitaly, thanks for this excellent report.
>>
>> Yes, current code is really not good when all ports are in use :
>>
>> We now have to scan 28232 [1] times long chains of 220 sockets.
>> Thats very long (but at least thread is preemptable)
>>
>> In the past (before patches), only one thread was allowed to run in =
kernel while scanning
>> udp port table (we had only one global lock udp_hash_lock protecting=
 the whole udp table).
>=20
> Very true, my (older) kernel with udp_hash_lock just become totally
> unresponsive after running this test. .29-rc2 become jerky only, but
> still works.
>=20
>> This thread was faster because it was not slowed down by other threa=
ds.
>> (But the rwlock we used was responsible for starvations of writers i=
f many UDP frames
>> were received)
>>
>>
>>
>> One way to solve the problem could be to use following :
>>
>> 1) Raising UDP_HTABLE_SIZE from 128 to 1024 to reduce average chain =
lengths.
>>
>> 2) In bind(0) algo, use rcu locking to find a possible usable port. =
All cpus can run in //, without
>> dirtying locks. Then lock the found chain and recheck port is availa=
ble before using it.
>=20
> I think 2 is definitely better than 1, because 1 is not actually
> fixing anything, but postpones the problem slightly.
>=20
>> [1] replace 28232 by your actual /proc/sys/net/ipv4/ip_local_port_ra=
nge values
>> 61000 - 32768 =3D 28232
>>
>> I will try to code a patch before this week end.
>=20
> Cool!
>=20
>> Thanks
>>
>> Note : I tried to use a mutex to force only one thread in bind(0) co=
de but got no real speedup.
>> But it should help if you have a SMP machine, since only one cpu wil=
l be busy in bind(0)
>>
>=20
> You saved my time, I was thinking about trying mutexes also. Thanks :=
)
>=20

Could you try following patch ?

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
index cf5ab05..adbdbd8 100644
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
@@ -158,34 +165,44 @@ int udp_lib_get_port(struct sock *sk, unsigned sh=
ort snum,
 	struct net *net =3D sock_net(sk);
=20
 	if (!snum) {
-		int low, high, remaining;
-		unsigned rand;
+		int low, high;
+		unsigned rand, slotn, bias;
 		unsigned short first;
+		DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);
=20
 		inet_get_local_port_range(&low, &high);
-		remaining =3D (high - low) + 1;
=20
 		rand =3D net_random();
-		snum =3D first =3D rand % remaining + low;
-		rand |=3D 1;
-		for (;;) {
-			hslot =3D &udptable->hash[udp_hashfn(net, snum)];
+		bias =3D rand;
+		rand =3D ((rand >> 16) | 1) * UDP_HTABLE_SIZE;
+		for (slotn =3D 0; slotn < UDP_HTABLE_SIZE; slotn++) {
+			first =3D slotn + bias;
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

