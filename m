From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Fri, 28 Jul 2017 12:19:49 -0700
Message-ID: <CAK6E8=fF+93pun3+bjzuv0CGUqUf31hsvydTPx5w3xmJB1n4HQ@mail.gmail.com>
References: <20170727233117.29695-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>, Lawrence Brakmo <brakmo@fb.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37374 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbdG1TUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 15:20:32 -0400
Received: by mail-wm0-f41.google.com with SMTP id t201so4071902wmt.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 12:20:31 -0700 (PDT)
In-Reply-To: <20170727233117.29695-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 4:31 PM, Florian Westphal <fw@strlen.de> wrote:
>
> This RFC removes tcp prequeueing and header prediction support.
>
> After a hallway discussion with Eric Dumazet some
> maybe-not-so-useful-anymore TCP stack features came up, HP and
> Prequeue among these.
>
> So this RFC proposes to axe both.
>
> In brief, TCP prequeue assumes a single-process-blocking-read
> design, which is not that common anymore, and the most frequently
> used high-performance networking program that does this is netperf :)
>
> With more commong (e)poll designs, prequeue doesn't work.
>
> The idea behind prequeueing isn't so bad in itself; it moves
> part of tcp processing -- including ack processing (including
> retransmit queue processing) into process context.
> However, removing it would not just avoid some code, for most
> programs it elimiates dead code.
>
> As processing then always occurs in BH context, it would allow us
> to experiment e.g. with bulk-freeing of skb heads when a packet acks
> data on the retransmit queue.
>
> Header prediction is also less useful nowadays.
> For packet trains, GRO will aggregate packets so we do not get
> a per-packet benefit.
> Header prediction will also break down with light packet loss due to SACK.
>
> So, In short: What do others think?
+2 for this move. Will review the patches soon.

>
> Florian Westphal (6):
>       tcp: remove prequeue support
>       tcp: reindent two spots after prequeue removal
>       tcp: remove low_latency sysctl
>       tcp: remove header prediction
>       tcp: remove CA_ACK_SLOWPATH
>       tcp: remove unused mib counters
>
>  Documentation/networking/ip-sysctl.txt |    7
>  include/linux/tcp.h                    |   15 -
>  include/net/tcp.h                      |   40 ----
>  include/uapi/linux/snmp.h              |    8
>  net/ipv4/proc.c                        |    8
>  net/ipv4/sysctl_net_ipv4.c             |    3
>  net/ipv4/tcp.c                         |  109 -----------
>  net/ipv4/tcp_input.c                   |  303 +++------------------------------
>  net/ipv4/tcp_ipv4.c                    |   63 ------
>  net/ipv4/tcp_minisocks.c               |    3
>  net/ipv4/tcp_output.c                  |    2
>  net/ipv4/tcp_timer.c                   |   12 -
>  net/ipv4/tcp_westwood.c                |   31 ---
>  net/ipv6/tcp_ipv6.c                    |    3
>  14 files changed, 43 insertions(+), 564 deletions(-)
>
