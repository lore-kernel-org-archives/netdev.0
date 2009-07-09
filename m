From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ip_push_pending_frames() fix
Date: Thu, 09 Jul 2009 02:20:42 +0200
Message-ID: <4A5537DA.1060200@gmail.com>
References: <4A53CD39.7080407@gmail.com>	<20090707.191424.167842005.davem@davemloft.net>	<EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com> <20090708.104539.226485646.davem@davemloft.net> <4A552A0D.8080106@gmail.com> <EA929A9653AAE14F841771FB1DE5A1365F8AD4E371@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"emils.tantilov@gmail.com" <emils.tantilov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jolsa@redhat.com" <jolsa@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36762 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbZGIAVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 20:21:09 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F8AD4E371@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S a =E9crit :
> Eric Dumazet wrote:
>> David Miller a =E9crit :
>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>> Date: Wed, 8 Jul 2009 11:02:22 -0600
>>>
>>>> Still seeing traces during the test even with this patch applied:
>>>>
>>>> [ 1089.430093] ------------[ cut here ]------------
>>>> [ 1089.435667] WARNING: at include/net/sock.h:423
>>>> udp_lib_unhash+0x73/0xa0() [ 1089.435670] Hardware name: S5520HC
>>> Ok I'll back this out for now, needs more investigation
>>> obviously.
>> Hmm... I never said it was supposed to fix Emil problem, just that
>> I discovered one potential problem by code inspection.
>>
>> I could not find yet sk_refcnt mismatch.
>> As we do less atomic ops per packet than before, some old bug could
>> surface now...
>>
>> Emil, is it easy to reproduce this problem, considering I have a
>> similar platform than yours (dual quad core machine, E5450 cpus @
>> 3GHz) ?=20
>=20
> Eric,
>=20
> It should be easy to reproduce. At least I have been able to consiste=
ntly=20
> reproduce it on several different systems with different drivers (e10=
00, e1000e, igb).=20
>=20
> The test I'm running is a mix of IPV4/6 TCP/UDP traffic with netperf =
(also mixing different types TCP/UDP_STREAM, TCP_MAERTS, TCP_UDP_RR etc=
). How much this matters I don't know - it's possible that just UDP tra=
ffic would do it. I also think it may have something to do with IPv6
> because of the trace, but I am not sure.
>=20
> If you need more information let me know.
>=20

OK thanks, this was helpful, corking or not corking, that is the questi=
on :)

I think ip6_push_pending_frames() & ip_push_pending_frames=20
have a problem after recent commit 2b85a34e911bf483c27cfdd124aeb1605145=
dc80=20
(net: No more expensive sock_hold()/sock_put() on each tx)

[PATCH] net: ip_push_pending_frames() fix

After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80=20
(net: No more expensive sock_hold()/sock_put() on each tx)
we do not take any more references on sk->sk_refcnt on outgoing packets=
=2E

I forgot to delete two __sock_put() from ip_push_pending_frames()
and ip6_push_pending_frames().

Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2470262..7d08210 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1243,7 +1243,6 @@ int ip_push_pending_frames(struct sock *sk)
 		skb->len +=3D tmp_skb->len;
 		skb->data_len +=3D tmp_skb->len;
 		skb->truesize +=3D tmp_skb->truesize;
-		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor =3D NULL;
 		tmp_skb->sk =3D NULL;
 	}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7c76e3d..87f8419 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1484,7 +1484,6 @@ int ip6_push_pending_frames(struct sock *sk)
 		skb->len +=3D tmp_skb->len;
 		skb->data_len +=3D tmp_skb->len;
 		skb->truesize +=3D tmp_skb->truesize;
-		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor =3D NULL;
 		tmp_skb->sk =3D NULL;
 	}
