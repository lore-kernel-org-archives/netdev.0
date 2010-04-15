From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 06:03:54 +0200
Message-ID: <1271304234.16881.1865.camel@edumazet-laptop>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	 <1271302133.16881.1814.camel@edumazet-laptop>
	 <h2q412e6f7f1004142041ld9c760aw5dfd192da506e92c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47223 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab0DOEEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 00:04:02 -0400
Received: by bwz25 with SMTP id 25so994204bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 21:04:01 -0700 (PDT)
In-Reply-To: <h2q412e6f7f1004142041ld9c760aw5dfd192da506e92c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 11:41 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 15, 2010 at 11:28 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >> ----
> >>  net/core/dev.c |    5 ++---
> >>  1 file changed, 2 insertions(+), 3 deletions(-)
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index a10a216..b38a991 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -2336,7 +2336,6 @@ static int enqueue_to_backlog(struct sk_buff=
 *skb, int cpu)
> >>       queue =3D &per_cpu(softnet_data, cpu);
> >>
> >>       local_irq_save(flags);
> >> -     __get_cpu_var(netdev_rx_stat).total++;
> >
> > I think this was nice, because we can see number of frames received=
 by
> > this cpu, before giving them to another cpu.
> >
>=20
> :( Packets will be counted again in __net_receive_skb(). Now the
> meaning of total is confusing.

Yes, this should be documented somewhere :)

>=20
> > Maybe we want a new counter ?
> >
> >        __get_cpu_var(netdev_rx_stat).inpackets++;
> >
>=20
> How about replacing total with received?
>=20
> >>
> >>       rps_lock(queue);
> >>       if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> >> @@ -2366,9 +2365,9 @@ enqueue:
> >>               goto enqueue;
> >>       }
> >>
> >> +     per_cpu(netdev_rx_stat, cpu).dropped++;
> >
> > This is a bit expensive, and could be a queue->rx_stat.dropped++
> > if netdev_rx_stat is moved inside queue structure.
> >
>=20
> It will make softnet_data larger.?

We move a per_cpu struture inside another one. No extra bytes needed.

>=20
> >
> >>       rps_unlock(queue);
> >>
> >> -     __get_cpu_var(netdev_rx_stat).dropped++;
> >>       local_irq_restore(flags);
> >>
> >>       kfree_skb(skb);
> >> @@ -3565,7 +3564,7 @@ static int softnet_seq_show(struct seq_file =
*seq, void *v)
> >>       struct netif_rx_stats *s =3D v;
> >>
> >>       seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08=
x %08x\n",
> >> -                s->total, s->dropped, s->time_squeeze, 0,
> >> +                s->total + s->dropped, s->dropped, s->time_squeez=
e, 0,
> >
> > This is wrong I believe... I prefer to add a new column, s->inpacke=
ts ?
>=20
> If I rename total to received, is it still confusing?

Keep in mind /proc/net/softnet_stat is an ABI, and first column had the
meaning : number of packets processed by this cpu.

But this was pre RPS time. Now we have a two phases process.


This makes sense to :

let 'total' be the counter of packets processed in upper levels (IP/TCP
stack). As /proc/net/softnet_stat has no header, the 'total' name is no=
t
important and could be changed.

add a new column (after the existing ones in /proc file to keep ABI
compatibility) with the meaning : number of packets pre-processed befor=
e
network stacks.

total : number of packets processed in upper layers (IP stack for
example)
dropped: number of packets dropped because this cpu queue was full
time_squeeze: number of time squeeze of this cpu
cpu_collision:...
received_rps: number of time this cpu received a RPS signal from anothe=
r
cpu
inpackets : number of packets processed in layer 1 by this cpu (RPS
level)


