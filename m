From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.8)
Date: Fri, 14 Jan 2011 15:24:03 +0100
Message-ID: <1295015043.3937.20.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net>  <4D3055C2.3060807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50668 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab1ANOYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 09:24:07 -0500
Received: by wyb28 with SMTP id 28so2869995wyb.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 06:24:06 -0800 (PST)
In-Reply-To: <4D3055C2.3060807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 14:55 +0100, Patrick McHardy a =C3=A9=
crit :
> On 14.01.2011 14:54, Patrick McHardy wrote:
> > On 14.01.2011 00:34, Stephen Hemminger wrote:
> >> +static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >> +{
> >> ...
> >> +	/* Is queue small? */
> >> +	if (p->qavg <=3D p->qth_min)
> >> +		p->qcount =3D -1;
> >> +	else {
> >> +		struct sk_buff *oskb;
> >> +		unsigned int idx;
> >> +
> >> +		/* Draw a packet at random from queue */
> >> +		oskb =3D choke_peek_random(sch, &idx);
> >> +
> >> +		/* Both packets from same flow ? */
> >> +		if (*(unsigned int *)(qdisc_skb_cb(oskb)->data) =3D=3D hash) {
> >> +			/* Drop both packets */
> >> +			q->stats.matched++;
> >> +			choke_drop_by_idx(q, idx);
> >> +			sch->qstats.backlog -=3D qdisc_pkt_len(skb);
> >> +			--sch->q.qlen;
> >> +			qdisc_drop(oskb, sch);
> >=20
> > You need to adjust the qlen values of parent qdiscs by calling
> > qdisc_tree_decrease_qlen(), they are not aware that a second
> > packet has been dropped.
>=20
> I just saw that Eric already fixed this :)
> --

Thanks Patrick, I did that in choke_change() only, not on this part of
the code.


qdisc cbq 1: root refcnt 2 rate 1000Mbit cell 8b (bounded,isolated) pri=
o no-transmit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 92016573 bytes 167811 pkt (dropped 615544, overlimits 982637 requ=
eues 0)=20
 rate 6248bit 9pps backlog 0b 191202p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
qdisc choke 11: parent 1:11 limit 130000b min 10833b max 32500b ewma 13=
 Plog 21 Scell_log 30
 Sent 91969929 bytes 167257 pkt (dropped 806746, overlimits 424342 requ=
eues 0)=20
 rate 56bit 0pps backlog 0b 0p requeues 0=20
  marked 0 early 424342 pdrop 0 other 0 matched 191202


So yes : we see 191202 were CHOKed, and upper cbq leaks 191202 packets =
in 'backlog'

After following patch :

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 29a91d8..5479f7e 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -223,6 +223,7 @@ static int choke_enqueue(struct sk_buff *skb, struc=
t Qdisc *sch)
 			q->stats.matched++;
 			choke_drop_by_idx(q, idx);
 			sch->qstats.backlog -=3D qdisc_pkt_len(oskb);
+			qdisc_tree_decrease_qlen(sch, 1);
 			--sch->q.qlen;
 			qdisc_drop(oskb, sch);
 			goto congestion_drop;

Everything seems fine :

qdisc cbq 1: root refcnt 2 rate 1000Mbit cell 8b (bounded,isolated) pri=
o no-transmit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 93962148 bytes 170940 pkt (dropped 633053, overlimits 1010490 req=
ueues 0)=20
 rate 568bit 1pps backlog 0b 0p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
qdisc choke 11: parent 1:11 limit 130000b min 10833b max 32500b ewma 13=
 Plog 21 Scell_log 30
 Sent 93957621 bytes 170888 pkt (dropped 829160, overlimits 436946 requ=
eues 0)=20
 rate 104bit 0pps backlog 0b 0p requeues 0=20
  marked 0 early 436946 pdrop 0 other 0 matched 196107


