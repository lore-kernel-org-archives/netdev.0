From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: large divisor for flow classifier
Date: Fri, 15 Oct 2010 22:01:45 +0200
Message-ID: <1287172905.2799.8.camel@edumazet-laptop>
References: <4CB899F7.0@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jonathan Thibault <jonathan@navigue.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44291 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756791Ab0JOUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 16:01:50 -0400
Received: by wwj40 with SMTP id 40so1498559wwj.1
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 13:01:49 -0700 (PDT)
In-Reply-To: <4CB899F7.0@navigue.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 octobre 2010 =C3=A0 14:14 -0400, Jonathan Thibault a =C3=
=A9crit :
> It appears that when setting a fairly large divisor on the flow class=
ifier for sfq, traffic stops altogether.
>=20
> On my machine, anything above divisor 2200 seems to stop all traffic.=
  If I want to be fair between hosts (but not flows) for a large networ=
k (say 6000 hosts), I run into problems.  Obviously the rates here are =
quite low but this is just an example.
>=20
> I also tested on a real interface with the same results.
>=20
> Example that works:
>=20
> tc qdisc add dev ifb0 root handle 3: htb default 10
>   tc class add dev ifb0 parent 3: classid 3:1 htb rate 80kbit
>     tc class add dev ifb0 parent 3:1 classid 3:10 htb rate 80kbit
>       tc qdisc add dev ifb0 parent 3:10 handle 310: sfq perturb 10
>       tc filter add dev ifb0 parent 3: protocol all prio 1 u32 match =
mark 0x000 0xf00 flowid 3:10
>       tc filter add dev ifb0 parent 310: protocol all handle 0x310 fl=
ow hash keys dst divisor 1024
>=20
> Example that doesn't work:
>=20
> tc qdisc add dev ifb0 root handle 3: htb default 10
>   tc class add dev ifb0 parent 3: classid 3:1 htb rate 80kbit
>     tc class add dev ifb0 parent 3:1 classid 3:10 htb rate 80kbit
>       tc qdisc add dev ifb0 parent 3:10 handle 310: sfq perturb 10
>       tc filter add dev ifb0 parent 3: protocol all prio 1 u32 match =
mark 0x000 0xf00 flowid 3:10
>       tc filter add dev ifb0 parent 310: protocol all handle 0x310 fl=
ow hash keys dst divisor 6144
>=20

SFQ is limited to a 1024 divisor

You might try following patch :

(8192 is the smallest power of two greater than 6144)

sizeof(struct sfq_sched_data) becomes 0x2ccc instead of 0x10cc

keep in mind hash distribution is not perfect.

What would be the real rate ?


diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..c4a53d6 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -77,7 +77,7 @@
 	It is easy to increase these values, but not in flight.  */
=20
 #define SFQ_DEPTH		128
-#define SFQ_HASH_DIVISOR	1024
+#define SFQ_HASH_DIVISOR	8192
=20
 /* This type should contain at least SFQ_DEPTH*2 values */
 typedef unsigned char sfq_index;


