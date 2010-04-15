From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 11:41:46 +0800
Message-ID: <h2q412e6f7f1004142041ld9c760aw5dfd192da506e92c@mail.gmail.com>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	<1271302133.16881.1814.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:39744 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756730Ab0DODmJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 23:42:09 -0400
Received: by yxe37 with SMTP id 37so533659yxe.21
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 20:42:07 -0700 (PDT)
In-Reply-To: <1271302133.16881.1814.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 11:28 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> ----
>> =C2=A0net/core/dev.c | =C2=A0 =C2=A05 ++---
>> =C2=A01 file changed, 2 insertions(+), 3 deletions(-)
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index a10a216..b38a991 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2336,7 +2336,6 @@ static int enqueue_to_backlog(struct sk_buff *=
skb, int cpu)
>> =C2=A0 =C2=A0 =C2=A0 queue =3D &per_cpu(softnet_data, cpu);
>>
>> =C2=A0 =C2=A0 =C2=A0 local_irq_save(flags);
>> - =C2=A0 =C2=A0 __get_cpu_var(netdev_rx_stat).total++;
>
> I think this was nice, because we can see number of frames received b=
y
> this cpu, before giving them to another cpu.
>

:( Packets will be counted again in __net_receive_skb(). Now the
meaning of total is confusing.

> Maybe we want a new counter ?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__get_cpu_var(netdev_rx_stat).inpackets++;
>

How about replacing total with received?

>>
>> =C2=A0 =C2=A0 =C2=A0 rps_lock(queue);
>> =C2=A0 =C2=A0 =C2=A0 if (queue->input_pkt_queue.qlen <=3D netdev_max=
_backlog) {
>> @@ -2366,9 +2365,9 @@ enqueue:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto enqueue;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> + =C2=A0 =C2=A0 per_cpu(netdev_rx_stat, cpu).dropped++;
>
> This is a bit expensive, and could be a queue->rx_stat.dropped++
> if netdev_rx_stat is moved inside queue structure.
>

It will make softnet_data larger.?

>
>> =C2=A0 =C2=A0 =C2=A0 rps_unlock(queue);
>>
>> - =C2=A0 =C2=A0 __get_cpu_var(netdev_rx_stat).dropped++;
>> =C2=A0 =C2=A0 =C2=A0 local_irq_restore(flags);
>>
>> =C2=A0 =C2=A0 =C2=A0 kfree_skb(skb);
>> @@ -3565,7 +3564,7 @@ static int softnet_seq_show(struct seq_file *s=
eq, void *v)
>> =C2=A0 =C2=A0 =C2=A0 struct netif_rx_stats *s =3D v;
>>
>> =C2=A0 =C2=A0 =C2=A0 seq_printf(seq, "%08x %08x %08x %08x %08x %08x =
%08x %08x %08x %08x\n",
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->total, s=
->dropped, s->time_squeeze, 0,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->total + =
s->dropped, s->dropped, s->time_squeeze, 0,
>
> This is wrong I believe... I prefer to add a new column, s->inpackets=
 ?

If I rename total to received, is it still confusing?



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
