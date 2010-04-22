From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 16:24:31 +0200
Message-ID: <1271946271.7895.5631.camel@edumazet-laptop>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
	 <20100422.024336.119875321.davem@davemloft.net>
	 <t2t412e6f7f1004220527mb5340bebye1d1fda0963dcf2a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	therbert@google.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:34059 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979Ab0DVOYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 10:24:43 -0400
Received: by bwz25 with SMTP id 25so9705985bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 07:24:41 -0700 (PDT)
In-Reply-To: <t2t412e6f7f1004220527mb5340bebye1d1fda0963dcf2a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 20:27 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 22, 2010 at 5:43 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Changli Gao <xiaosuo@gmail.com>
> > Date: Thu, 22 Apr 2010 17:09:17 +0800
> >
> >> +     unsigned int            input_pkt_queue_len;
> >> +     struct sk_buff          *input_pkt_queue_head;
> >> +     struct sk_buff          **input_pkt_queue_tailp;
> >> +
> >
> > Please do not ignore Stephen Hemminger's feedback.
> >
> > We already have enough odd SKB queue implementations, we
> > do not need yet another one in a core location.  This makes
> > it harder and harder to eventually convert sk_buff to use
> > "struct list_head".
> >
> > Instead, use "struct sk_buff_head" and the lockless accessors
> > (__skb_insert, etc.) and initializer (__skb_queue_head_init).
> >
>=20
> If I want to keep softnet_data small, I have to access the internal
> fields of sk_buff_head, and modify them in a hack way. It doesn't
> sound good. If not, softnet_data will become:
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
>         unsigned int            input_pkt_queue_len;
>         struct sk_buff_head     input_pkt_queue;
>         struct napi_struct      backlog;
> };
>=20
> Eric, do you think it is too fat?

No it is not, as long as we are careful to separate cache lines.

By the way, input_pkt_queue_len is already in input_ptk_queue (.len)

Thanks


