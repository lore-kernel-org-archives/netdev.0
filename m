From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Mon, 6 Jun 2016 16:15:42 -0700
Message-ID: <CAM_iQpURiYyBqpKG=u4qvbgToe4kQd4=8d_N0ohbfG_cONw_8Q@mail.gmail.com>
References: <1465231036-10674-1-git-send-email-edumazet@google.com> <1465231036-10674-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35178 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbcFFXQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:16:02 -0400
Received: by mail-yw0-f193.google.com with SMTP id n16so20974465ywd.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:16:02 -0700 (PDT)
In-Reply-To: <1465231036-10674-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 6, 2016 at 9:37 AM, Eric Dumazet <edumazet@google.com> wrote:
>  void
> -__gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
> +__gnet_stats_copy_basic(const seqcount_t *running,
> +                       struct gnet_stats_basic_packed *bstats,
>                         struct gnet_stats_basic_cpu __percpu *cpu,
>                         struct gnet_stats_basic_packed *b)
>  {
> +       unsigned int seq;
> +
>         if (cpu) {
>                 __gnet_stats_copy_basic_cpu(bstats, cpu);
> -       } else {
> +               return;
> +       }
> +       do {
> +               if (running)
> +                       seq = read_seqcount_begin(running);
>                 bstats->bytes = b->bytes;
>                 bstats->packets = b->packets;
> -       }
> +       } while (running && read_seqcount_retry(running, seq));
>  }

Why only these basic stats need to get read seqlock?
Queue stats (gnet_stats_copy_queue()) too, right?
