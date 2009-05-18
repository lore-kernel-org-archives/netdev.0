From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] pkt_sched: gen_estimator: use 64 bits intermediate counters
 for bps
Date: Tue, 19 May 2009 01:59:55 +0200
Message-ID: <4A11F67B.3050805@cosmosbay.com>
References: <20090516141430.GB3013@ami.dom.local>	<4A118F98.60101@cosmosbay.com>	<20090518172349.GA2755@ami.dom.local> <20090518.145233.212710505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, vexwek@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, devik@cdi.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44611 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbZESAAJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 20:00:09 -0400
In-Reply-To: <20090518.145233.212710505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 18 May 2009 19:23:49 +0200
>=20
>> On Mon, May 18, 2009 at 06:40:56PM +0200, Eric Dumazet wrote:
>>> With a typical estimator "1sec 8sec", ewma_log value is 3
>>>
>>> At gigabit speeds, we are very close to overflow yes, since
>>> we only have 27 bits available, so 134217728 bytes per second
>>> or 1073741824 bits per second.
>>>
>>> So formula :
>>> e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
>>> is going to overflow.
>>>
>>> One way to avoid the overflow would be to use a smaller estimator, =
like "500ms 4sec"=20
>>>
>>> Or use a 64bits rate & avbps, this is needed fo 10Gb speeds I suppo=
se...
>> Yes, I considered this too, but because of an overhead I decided to
>> fix as designed (according to the comment) for now. But probably you
>> are right, and we should go further, so I'm OK with your patch.
>=20
> I like this patch too, Eric can you submit this formally with
> proper signoffs etc.?
>=20

Sure, here it is. We might need a similar patch to get a correct pps va=
lue
too, since we currently are limited to ~ 2^21 packets per second.

[PATCH] pkt_sched: gen_estimator: use 64 bit intermediate counters for =
bps

gen_estimator can overflow bps (bytes per second) with Gb links, while
it was designed with a u32 API, with a theorical limit of 34360Mbit (2^=
32 bytes)

Using 64 bit intermediate avbps/brate counters can allow us to reach th=
is
theorical limit.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9cc9f95..ea28659 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -66,9 +66,9 @@
=20
    NOTES.
=20
-   * The stored value for avbps is scaled by 2^5, so that maximal
-     rate is ~1Gbit, avpps is scaled by 2^10.
-
+   * avbps is scaled by 2^5, avpps is scaled by 2^10.
+   * both values are reported as 32 bit unsigned values. bps can
+     overflow for fast links : max speed being 34360Mbit/sec
    * Minimal interval is HZ/4=3D250msec (it is the greatest common div=
isor
      for HZ=3D100 and HZ=3D1024 8)), maximal interval
      is (HZ*2^EST_MAX_INTERVAL)/4 =3D 8sec. Shorter intervals
@@ -86,9 +86,9 @@ struct gen_estimator
 	spinlock_t		*stats_lock;
 	int			ewma_log;
 	u64			last_bytes;
+	u64			avbps;
 	u32			last_packets;
 	u32			avpps;
-	u32			avbps;
 	struct rcu_head		e_rcu;
 	struct rb_node		node;
 };
@@ -115,6 +115,7 @@ static void est_timer(unsigned long arg)
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &elist[idx].list, list) {
 		u64 nbytes;
+		u64 brate;
 		u32 npackets;
 		u32 rate;
=20
@@ -125,9 +126,9 @@ static void est_timer(unsigned long arg)
=20
 		nbytes =3D e->bstats->bytes;
 		npackets =3D e->bstats->packets;
-		rate =3D (nbytes - e->last_bytes)<<(7 - idx);
+		brate =3D (nbytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes =3D nbytes;
-		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
+		e->avbps +=3D ((s64)(brate - e->avbps)) >> e->ewma_log;
 		e->rate_est->bps =3D (e->avbps+0xF)>>5;
=20
 		rate =3D (npackets - e->last_packets)<<(12 - idx);

