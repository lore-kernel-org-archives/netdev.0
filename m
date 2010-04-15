From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 05:28:53 +0200
Message-ID: <1271302133.16881.1814.camel@edumazet-laptop>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47090 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307Ab0DOD3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 23:29:01 -0400
Received: by bwz25 with SMTP id 25so980273bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 20:29:00 -0700 (PDT)
In-Reply-To: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 11:01 +0800, Changli Gao a =C3=A9crit :
> fix softnet_stat
>=20
> Per cpu variable softnet_data.total was shared between IRQ and SoftIR=
Q context
> without any protection. And enqueue_to_backlog should update the netd=
ev_rx_stat
> of the target CPU.
>=20
> This patch changes the meaning of softnet_data.total to the number of=
 packets
> processed, not includes dropped, in order to avoid it sharing between=
 IRQ and
> SoftIRQ. And softnet_data.dropped is protected in the corresponding
> input_pkt_queue.lock, if RPS is enabled.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/core/dev.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a10a216..b38a991 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2336,7 +2336,6 @@ static int enqueue_to_backlog(struct sk_buff *s=
kb, int cpu)
>  	queue =3D &per_cpu(softnet_data, cpu);
> =20
>  	local_irq_save(flags);
> -	__get_cpu_var(netdev_rx_stat).total++;

I think this was nice, because we can see number of frames received by
this cpu, before giving them to another cpu.

Maybe we want a new counter ?

	__get_cpu_var(netdev_rx_stat).inpackets++;


> =20
>  	rps_lock(queue);
>  	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> @@ -2366,9 +2365,9 @@ enqueue:
>  		goto enqueue;
>  	}
> =20
> +	per_cpu(netdev_rx_stat, cpu).dropped++;

This is a bit expensive, and could be a queue->rx_stat.dropped++
if netdev_rx_stat is moved inside queue structure.


>  	rps_unlock(queue);
> =20
> -	__get_cpu_var(netdev_rx_stat).dropped++;
>  	local_irq_restore(flags);
> =20
>  	kfree_skb(skb);
> @@ -3565,7 +3564,7 @@ static int softnet_seq_show(struct seq_file *se=
q, void *v)
>  	struct netif_rx_stats *s =3D v;
> =20
>  	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\=
n",
> -		   s->total, s->dropped, s->time_squeeze, 0,
> +		   s->total + s->dropped, s->dropped, s->time_squeeze, 0,

This is wrong I believe... I prefer to add a new column, s->inpackets ?

>  		   0, 0, 0, 0, /* was fastroute */
>  		   s->cpu_collision, s->received_rps);
>  	return 0;
> --



