From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] fq_codel: dont reinit flow state
Date: Sat, 1 Sep 2012 11:12:29 -0700
Message-ID: <CAA93jw6mdAaomNfNWt0D4MZYFqXZ3=P+HYe9AEkvwNkAH84GSQ@mail.gmail.com>
References: <1346505597.7996.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36381 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572Ab2IASMb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2012 14:12:31 -0400
Received: by wgbdr13 with SMTP id dr13so3427408wgb.1
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2012 11:12:30 -0700 (PDT)
In-Reply-To: <1346505597.7996.76.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

partial NAK.

There is no need to reset dropped either, and resetting quantum or not
is an interesting question.

(in both cases they can be initted at init time)

Lastly, stats->maxpacket is presently a shared resource in fq_codel,
and the initial setting of 256 was an artifact some test ns2 code
(according to kathie). In the case of ack traffic owning a queue, this
can be 64 or 66 bytes (or larger on ipv6 acks).

It's totally unclear if this distinction is important in fq_codel at
present. :/. Obviously in codel which is a pure FIFO, maxpacket will
hit the max size really fast.

A related problem on maxpacket is if someone turns off tso/gso/ufo, it
remains set to the largest packet seen forever until the qdisc is
re-initialized.
This leads to really puzzling behavior... (I'll submit a patch for
this shortly but not change fq_codel's
centralized stats)

I'd be happy (for now) if dropped was preserved,
and to fiddle with the other ideas a while longer.

On Sat, Sep 1, 2012 at 6:19 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> When fq_codel builds a new flow, it should not reset codel state.
>
> Codel algo needs to get previous values (lastcount, drop_next) to get
> proper behavior.
>
> Signed-off-by: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/sched/sch_fq_codel.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 9fc1c62..4e606fc 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -191,7 +191,6 @@ static int fq_codel_enqueue(struct sk_buff *skb, =
struct Qdisc *sch)
>
>         if (list_empty(&flow->flowchain)) {
>                 list_add_tail(&flow->flowchain, &q->new_flows);
> -               codel_vars_init(&flow->cvars);
>                 q->new_flow_count++;
>                 flow->deficit =3D q->quantum;
>                 flow->dropped =3D 0;
> @@ -418,6 +417,7 @@ static int fq_codel_init(struct Qdisc *sch, struc=
t nlattr *opt)
>                         struct fq_codel_flow *flow =3D q->flows + i;
>
>                         INIT_LIST_HEAD(&flow->flowchain);
> +                       codel_vars_init(&flow->cvars);
>                 }
>         }
>         if (sch->limit >=3D 1)
>
>



--=20
Dave T=E4ht
http://www.bufferbloat.net/projects/cerowrt/wiki - "3.3.8-17 is out
with fq_codel!"
