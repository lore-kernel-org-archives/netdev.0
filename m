From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL + Basic Latency under load results - 100Mbit, GSO/TSO off,
 pfifo_fast vs SFQ vs QFQ
Date: Mon, 02 Jan 2012 05:55:25 +0100
Message-ID: <1325480125.2526.13.camel@edumazet-laptop>
References: <CAA93jw6r45zBn4p76R9-2UNdp=OM+uiYqPKcKnjqBReR_oh1BA@mail.gmail.com>
	 <CAA93jw5JjVBQOFL=td55rOpXbUYc=uT_rjeY04O137g_-tBJHw@mail.gmail.com>
	 <CAA93jw7bLnHtVnZGN5wVPQZc46XT_B--cY1ocUbnm1AS=J_YHw@mail.gmail.com>
	 <1325478811.2526.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jg@freedesktop.org, Stephen Hemminger <shemminger@vyatta.com>,
	Juliusz Chroboczek <jch@pps.jussieu.fr>,
	Kathleen Nichols <nichols@pollere.com>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57147 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab2ABEzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2012 23:55:31 -0500
Received: by werm1 with SMTP id m1so7283447wer.19
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2012 20:55:29 -0800 (PST)
In-Reply-To: <1325478811.2526.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 05:33 +0100, Eric Dumazet a =C3=A9crit =
:
> Le lundi 02 janvier 2012 =C3=A0 00:17 +0100, Dave Taht a =C3=A9crit :
> > QFQ wins even bigger vs SFQ at 50 iperfs
> >=20
> > http://www.teklibre.com/~d/bloat/pfifo_sfq_vs_qfq_linear50.png
> >=20
> > And I think it's going to win even bigger at 10 Mbit.
> >=20
>=20
> Happy new year !
>=20
> This makes no sense to me for such a low amount of flows, SFQ should
> perform the same than QFQ :)
>=20
> You dont find out why it is so.
>=20
>=20
>=20
> Please try following patch :
>=20
> [PATCH net-next] sch_sfq: dont put new flow at the end of flows
>=20
> SFQ enqueue algo puts a new flow _behind_ all pre-existing flows in t=
he
> circular list. In fact this is probably an old SFQ implementation bug=
=2E
>=20
> 100 Mbits =3D ~8333 full frames per second, or ~8 frames per ms.
>=20
> With 50 flows, it means your "new flow" will have to wait 50 packets
> being sent before its own packet. Thats the ~6ms.
>=20
> We certainly can change SFQ to give a priority advantage to new flows=
,
> so that next dequeued packet is taken from a new flow, not an old one=
=2E
>=20
> Reported-by: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index c23b957..f7f62a5 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -366,11 +366,11 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
>  	if (slot->qlen =3D=3D 1) {		/* The flow is new */
>  		if (q->tail =3D=3D NULL) {	/* It is the first flow */
>  			slot->next =3D x;
> +			q->tail =3D slot;
>  		} else {
>  			slot->next =3D q->tail->next;
>  			q->tail->next =3D x;
>  		}
> -		q->tail =3D slot;
>  		slot->allot =3D q->scaled_quantum;
>  	}
>  	if (++sch->q.qlen <=3D q->limit)
>=20

I tested this patch with a 50 concurrent netperf workload, and indeed
this fixes the problem for me.

# ping 192.168.20.108
PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
64 bytes from 192.168.20.108: icmp_req=3D1 ttl=3D64 time=3D0.021 ms
64 bytes from 192.168.20.108: icmp_req=3D2 ttl=3D64 time=3D0.011 ms
64 bytes from 192.168.20.108: icmp_req=3D3 ttl=3D64 time=3D0.011 ms
64 bytes from 192.168.20.108: icmp_req=3D4 ttl=3D64 time=3D0.010 ms
64 bytes from 192.168.20.108: icmp_req=3D5 ttl=3D64 time=3D0.010 ms
64 bytes from 192.168.20.108: icmp_req=3D6 ttl=3D64 time=3D0.010 ms


# tc -s -d qdisc show dev eth3
qdisc htb 1: root refcnt 18 r2q 10 default 1 direct_packets_stat 0 ver =
3.17
 Sent 1178661043 bytes 806848 pkt (dropped 9068, overlimits 382834 requ=
eues 3)=20
 rate 97748Kbit 8355pps backlog 0b 122p requeues 3=20
qdisc sfq 10: parent 1:1 limit 127p quantum 1514b flows 127/1024 diviso=
r 1024=20
 Sent 1178661043 bytes 806848 pkt (dropped 17568, overlimits 0 requeues=
 0)=20
 rate 97748Kbit 8355pps backlog 962708b 122p requeues 0=20


# tc -s -d cl show dev eth3
class htb 1:1 root leaf 10: prio 0 quantum 80000 rate 100000Kbit ceil 1=
00000Kbit=20
burst 40000b/256 mpu 0b overhead 0b cburst 40000b/256 mpu 0b overhead 0=
b level 0=20
 Sent 1367302331 bytes 935622 pkt (dropped 10494, overlimits 0 requeues=
 0)=20
 rate 100156Kbit 8560pps backlog 0b 125p requeues 0=20
 lended: 207922 borrowed: 0 giants: 0
 tokens: -14605 ctokens: -14605

class sfq 10:15 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 14678b 3p requeues 0=20
 allot -3264=20

class sfq 10:17 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 20Kb 3p requeues 0=20
 allot -6912=20

class sfq 10:22 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 17508b 2p requeues 0=20
 allot -808=20

class sfq 10:3c parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 17508b 2p requeues 0=20
 allot -4208=20

class sfq 10:5e parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 27Kb 2p requeues 0=20
 allot -6024=20

class sfq 10:66 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 11716b 2p requeues 0=20
 allot -4856=20

class sfq 10:8d parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 14612b 2p requeues 0=20
 allot 1296=20

class sfq 10:9b parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 7504b 4p requeues 0=20
 allot 1184=20

class sfq 10:9c parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 14612b 2p requeues 0=20
 allot -104=20

class sfq 10:a9 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 18956b 2p requeues 0=20
 allot -5456=20

class sfq 10:ab parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 14678b 3p requeues 0=20
 allot -88=20

class sfq 10:ba parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot -624=20

class sfq 10:c3 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 27710b 3p requeues 0=20
 allot -8440=20

class sfq 10:ce parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 18956b 2p requeues 0=20
 allot -3160=20

class sfq 10:f2 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 20Kb 3p requeues 0=20
 allot -672=20

class sfq 10:11c parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 5990b 3p requeues 0=20
 allot -712=20

class sfq 10:17c parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 17508b 2p requeues 0=20
 allot -4000=20

class sfq 10:188 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 16060b 2p requeues 0=20
 allot -6640=20

class sfq 10:1b9 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 10202b 1p requeues 0=20
 allot 120=20

class sfq 10:1c2 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 5924b 2p requeues 0=20
 allot 264=20

class sfq 10:1cb parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 19022b 3p requeues 0=20
 allot -2904=20

class sfq 10:1e5 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 23366b 3p requeues 0=20
 allot -7800=20

class sfq 10:1f9 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 8984b 4p requeues 0=20
 allot 560=20

class sfq 10:210 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 17574b 3p requeues 0=20
 allot -384=20

class sfq 10:231 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 19022b 3p requeues 0=20
 allot 1416=20

class sfq 10:27c parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 20404b 2p requeues 0=20
 allot 752=20

class sfq 10:289 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 19022b 3p requeues 0=20
 allot 1208=20

class sfq 10:2a3 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 14612b 2p requeues 0=20
 allot -2592=20

class sfq 10:2a6 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 19022b 3p requeues 0=20
 allot -5008=20

class sfq 10:2c7 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 7570b 5p requeues 0=20
 allot -1168=20

class sfq 10:2d0 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 8820b 2p requeues 0=20
 allot -1088=20

class sfq 10:2e5 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 20404b 2p requeues 0=20
 allot -10648=20

class sfq 10:2ec parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 13164b 2p requeues 0=20
 allot -1800=20

class sfq 10:2ee parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 20Kb 3p requeues 0=20
 allot -9016=20

class sfq 10:305 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 10400b 4p requeues 0=20
 allot -872=20

class sfq 10:318 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 504=20

class sfq 10:31f parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 10400b 4p requeues 0=20
 allot -4024=20

class sfq 10:328 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 16060b 2p requeues 0=20
 allot -16=20

class sfq 10:32d parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 21918b 3p requeues 0=20
 allot -840=20

class sfq 10:37d parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 14612b 2p requeues 0=20
 allot 432=20

class sfq 10:3ac parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 4542b 3p requeues 0=20
 allot 1224=20

class sfq 10:3d0 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 20Kb 3p requeues 0=20
 allot -11232=20

class sfq 10:3d1 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 26262b 3p requeues 0=20
 allot -1832=20

class sfq 10:3d8 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 5924b 2p requeues 0=20
 allot -512=20

class sfq 10:3e7 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 29158b 3p requeues 0=20
 allot -10976=20

class sfq 10:3f0 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 32054b 3p requeues 0=20
 allot -2080=20

class sfq 10:3f9 parent 10:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 18956b 2p requeues 0=20
 allot -1704=20
