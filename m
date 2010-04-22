From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 16:33:25 +0200
Message-ID: <1271946805.7895.5658.camel@edumazet-laptop>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
	 <1271936227.7895.5285.camel@edumazet-laptop>
	 <y2n412e6f7f1004220606id324dc9bj2cc04cfbad50a101@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41147 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab0DVOdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 10:33:36 -0400
Received: by mail-bw0-f225.google.com with SMTP id 25so9716703bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 07:33:35 -0700 (PDT)
In-Reply-To: <y2n412e6f7f1004220606id324dc9bj2cc04cfbad50a101@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 21:06 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 22, 2010 at 7:37 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > Please reorder things better.
> >
> > Most likely this function is called for one packet.
> >
> > In your version you take twice the rps_lock()/rps_unlock() path, so
> > it'll be slower.
> >
> > Once to 'transfert' one list to process list
> >
> > Once to be able to do the 'label out:' post processing.
> >
>=20
> It doesn't make any difference. We have to hold rps_lock to update
> input_pkt_queue_len, if we don't use another variable to record the
> length of the process queue, or atomic variable.
>=20

It does make a difference, Damn it.

I really really start to think you dont read what I wrote, or you dont
care.

Damn, cant you update all the things at once, taking this lock only
once ?

You focus having an ultra precise count of pkt_queue.len, but we dont
care at all ! We only want a _limit_, or else the box can be killed by
DOS.

If in practice this limit can be 2*limit, thats OK.=20

Cant you understand this ?

> I think it is better that using another variable to record the length
> of the process queue, and updating it before process_backlog()
> returns. For one packet, there is only one locking/unlocking. There i=
s
> only one issue you concerned: cache miss due to sum the two queues'
> length. I'll change softnet_data to:
>=20
> struct softnet_data {
>         struct Qdisc            *output_queue;
>         struct list_head        poll_list;
>         struct sk_buff          *completion_queue;
>         struct sk_buff_head     process_queue;
>=20
> #ifdef CONFIG_RPS
>         struct softnet_data     *rps_ipi_list;
>=20
>         /* Elements below can be accessed between CPUs for RPS */
>         struct call_single_data csd ____cacheline_aligned_in_smp;
>         struct softnet_data     *rps_ipi_next;
>         unsigned int            cpu;
>         unsigned int            input_queue_head;
> #endif
>         unsigned int            process_queue_len;
>         struct sk_buff_head     input_pkt_queue;
>         struct napi_struct      backlog;
> };
>=20
> For one packets, we have to update process_queue_len in any way. For
> more packets, we only change process_queue_len just before
> process_backlog() returns. It means that process_queue_len change is
> batched.
>=20

We need one limit. Not two limits.

I already told you how to do it, but you ignored me and started yet
another convoluted thing.


process_backlog() transfert the queue to its own queue and reset pkt_le=
n
to 0 (Only once)

End of story.

Maximum packet queued to this cpu softnet_data will be 2 * old_limit.

So what ?


