From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 18:40:56 +0200
Message-ID: <4A118F98.60101@cosmosbay.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090516141430.GB3013@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46901 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbZERQlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 12:41:08 -0400
In-Reply-To: <20090516141430.GB3013@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Fri, May 15, 2009 at 03:49:31PM +0100, Antonio Almeida wrote:
> ...
>> I also note that, for HTB rate configurations over 500Mbit/s on leaf
>> class, when I stop the traffic, in the output of "tc -s -d class ls
>> dev eth1" command, I see that leaf's rate (in bits/s) is growing
>> instead of decreasing (as expected since I've stopped the traffic).
>> Rate in pps is ok and decreases until 0pps. Rate in bits/s increases
>> above 1000Mbit and stays there for a few minutes. After two or three
>> minutes it becomes 0bit. The same happens for it's ancestors (also f=
or
>> root class).Here's tc output of my leaf class for this situation:
>>
>> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
>> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
>> 70901b/8 mpu 0b overhead 0b level 0
>>  Sent 120267768144 bytes 242475339 pkt (dropped 62272599, overlimits=
 0
>> requeues 0)
>>  rate 1074Mbit 0pps backlog 0b 0p requeues 0
>>  lended: 242475339 borrowed: 0 giants: 0
>>  tokens: 8 ctokens: 8
>=20
> This looks like a regular bug. I guess it's an overflow in
> gen_estimator(), but I'm not sure there is nothing more. Could you
> try the patch below? (An offset warning when patching 2.6.25 is OK)
>=20
> Thanks,
> Jarek P.
> ---
>=20
>  net/core/gen_estimator.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> index 9cc9f95..87f0ced 100644
> --- a/net/core/gen_estimator.c
> +++ b/net/core/gen_estimator.c
> @@ -127,7 +127,11 @@ static void est_timer(unsigned long arg)
>  		npackets =3D e->bstats->packets;
>  		rate =3D (nbytes - e->last_bytes)<<(7 - idx);
>  		e->last_bytes =3D nbytes;
> -		e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
> +		if (rate > e->avbps)
> +			e->avbps +=3D (rate - e->avbps) >> e->ewma_log;
> +		else
> +			e->avbps -=3D (e->avbps - rate) >> e->ewma_log;
> +
>  		e->rate_est->bps =3D (e->avbps+0xF)>>5;
> =20
>  		rate =3D (npackets - e->last_packets)<<(12 - idx);

With a typical estimator "1sec 8sec", ewma_log value is 3

At gigabit speeds, we are very close to overflow yes, since
we only have 27 bits available, so 134217728 bytes per second
or 1073741824 bits per second.

So formula :
e->avbps +=3D ((long)rate - (long)e->avbps) >> e->ewma_log;
is going to overflow.

One way to avoid the overflow would be to use a smaller estimator, like=
 "500ms 4sec"=20

Or use a 64bits rate & avbps, this is needed fo 10Gb speeds I suppose..=
=2E

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9cc9f95..150e2f5 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
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

