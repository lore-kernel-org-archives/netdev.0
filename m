From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected: d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Sun, 13 Dec 2009 17:57:08 +0100
Message-ID: <4B251CE4.9080401@gmail.com>
References: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>	 <20091211.214117.200029438.davem@davemloft.net>	 <86802c440912121705y59eea3ebq3bdbd3e7459e748e@mail.gmail.com>	 <86802c440912121757g474a7df4od6b50f6d5a210cf0@mail.gmail.com>	 <86802c440912121825h20663affv9ff8d004974d0d31@mail.gmail.com> <86802c440912121841j34cde8ecv892d7d74a32313ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu, sri@us.ibm.com,
	herbert@gondor.apana.org.au, torvalds@linux-foundation.org,
	sjayaraman@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38212 "HELO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750817AbZLMQ6g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 11:58:36 -0500
In-Reply-To: <86802c440912121841j34cde8ecv892d7d74a32313ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/12/2009 03:41, Yinghai Lu a =E9crit :
>
>>> cause the problem: nfs mount fail.
>>>
>>> the setup is:
>>> 64bit kernel, have all needed drivers in kernel, and boot with
>>> ip=3Ddhcp, root disk is 256M ramdisk.
>>> then try to mount nfs....
>>>
>>
>> change entries default value from 65536 to 256,
>> nfs mount will work.
>>
> interesting:
>=20
> m:~/dump # grep UDP dmesg.txt
> [   28.996034] UDP hash table entries: 65536 (order: 11, 10485760 byt=
es)
> [   29.032364] UDP-Lite hash table entries: 65536 (order: 11, 1048576=
0 bytes)
>=20
> will not work
>=20
> but 32768 will work.

Thanks a lot for this work Yinghai !
This last bit helped me a lot ...

Hmm, udp_lib_get_port() assumes it can loop at least one time in :

for (last =3D first + udptable->mask + 1;
	first !=3D last;
	first++) {
// unit_work
}

but if udptable->mask =3D=3D 65535, loop is not entered at all (since l=
ast =3D=3D first)

We should convert it to a do { } while(...); construct, or use 32bit va=
riables
and (u16) casts.

Thanks

[PATCH] udp: udp_lib_get_port() fix

Now we can have a large udp hash table, udp_lib_get_port() loop
should be converted to a do {} while (cond) form,
or we dont enter it at all if hash table size is exactly 65536.

Reported-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1f95348..f0126fd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -216,9 +216,8 @@ int udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
 		 */
 		rand =3D (rand | 1) * (udptable->mask + 1);
-		for (last =3D first + udptable->mask + 1;
-		     first !=3D last;
-		     first++) {
+		last =3D first + udptable->mask + 1;
+		do {
 			hslot =3D udp_hashslot(udptable, net, first);
 			bitmap_zero(bitmap, PORTS_PER_CHAIN);
 			spin_lock_bh(&hslot->lock);
@@ -238,7 +237,7 @@ int udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 				snum +=3D rand;
 			} while (snum !=3D first);
 			spin_unlock_bh(&hslot->lock);
-		}
+		} while (++first !=3D last);
 		goto fail;
 	} else {
 		hslot =3D udp_hashslot(udptable, net, snum);
