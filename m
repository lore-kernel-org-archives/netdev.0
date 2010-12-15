From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_sfq: add backlog info in
 sfq_dump_class_stats()
Date: Wed, 15 Dec 2010 20:10:41 +0100
Message-ID: <1292440241.3427.393.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>
	 <1292432120.3427.366.camel@edumazet-laptop>  <4D08F4F4.3050501@trash.net>
	 <1292432980.3427.369.camel@edumazet-laptop>  <4D08F91C.4070000@trash.net>
	 <1292434227.3427.377.camel@edumazet-laptop>
	 <1292437116.3427.386.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54960 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476Ab0LOTKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 14:10:46 -0500
Received: by wwa36 with SMTP id 36so1650819wwa.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 11:10:45 -0800 (PST)
In-Reply-To: <1292437116.3427.386.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 19:18 +0100, Eric Dumazet a =C3=
=A9crit :
> We currently return for each active SFQ slot the number of packets in
> queue. We can also give number of bytes accounted for these packets.
>=20
> tc -s class show dev ifb0
>=20
> Before patch :
>=20
> class sfq 11:3d9 parent 11:=20
>  (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 3p requeues 0=20
>  allot 1266=20
>=20
> After patch :
>=20
> class sfq 11:3e4 parent 11:=20
>  (dropped 0, overlimits 0 requeues 0)=20
>  backlog 4380b 3p requeues 0=20
>  allot 1212=20
>=20
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/sched/sch_sfq.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..cb331de 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -548,8 +548,13 @@ static int sfq_dump_class_stats(struct Qdisc *sc=
h, unsigned long cl,
>  {
>  	struct sfq_sched_data *q =3D qdisc_priv(sch);
>  	sfq_index idx =3D q->ht[cl-1];
> -	struct gnet_stats_queue qs =3D { .qlen =3D q->qs[idx].qlen };
> +	struct sk_buff_head *list =3D &q->qs[idx];
> +	struct gnet_stats_queue qs =3D { .qlen =3D list->qlen };
>  	struct tc_sfq_xstats xstats =3D { .allot =3D q->allot[idx] };
> +	struct sk_buff *skb;
> +
> +	skb_queue_walk(list, skb)
> +		qs.backlog +=3D qdisc_pkt_len(skb);
> =20
>  	if (gnet_stats_copy_queue(d, &qs) < 0)
>  		return -1;
>=20


By the way, I could not find out how to make "tc -s class show dev ifb0=
"
reports correct backlog information on parent class itself :

Here we can see 126p, and 0b in backlog :

class cbq 1:11 parent 1:1 leaf 11: rate 50000Kbit cell 8b mpu 64b (boun=
ded) prio 2/2 weight 50000Kbit allot 2250b=20
level 0 ewma 5 avpkt 1500b maxidle 0us=20
 Sent 330418440 bytes 226314 pkt (dropped 280142, overlimits 689534 req=
ueues 0)=20
 rate 52200Kbit 4469pps backlog 0b 126p requeues 0=20
  borrowed 0 overactions 182814 avgidle -3363 undertime 2812

qdisc is OK :

qdisc sfq 11: parent 1:11 limit 127p quantum 1514b flows 127/1024 pertu=
rb 60sec=20
 Sent 1712372746 bytes 1172859 pkt (dropped 1451945, overlimits 0 reque=
ues 0)=20
 rate 52287Kbit 4477pps backlog 185420b 127p requeues 0=20


