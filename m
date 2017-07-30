From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Sat, 29 Jul 2017 22:25:23 -0400
Message-ID: <CADVnQym-aDwv-NhcwM5eTW4XQZcKMS+64-VwObKFxT5maT=TGg@mail.gmail.com>
References: <20170727233117.29695-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>, Lawrence Brakmo <brakmo@fb.com>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33286 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753176AbdG3CZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 22:25:54 -0400
Received: by mail-oi0-f52.google.com with SMTP id a9so159949266oih.0
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 19:25:54 -0700 (PDT)
In-Reply-To: <20170727233117.29695-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 7:31 PM, Florian Westphal <fw@strlen.de> wrote:
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

I unconditionally support the removal of prequeue support.

For the header prediction code: IMHO before removing the header
prediction code it would be useful to do some kind of before-and-after
benchmarking on a low-powered device where battery life is the main
concern. I am thinking about ARM-based cell phones, IoT/embedded
devices, raspberry pi, etc. You mention GRO helping to make header
prediction obsolete, but in those devices packets arrive so slowly
that probably GRO does not help. With slow CPUs and battery life the
main concern, it seems conceivable to me that header prediction might
still be a win (and worth keeping, since the complexity cost is
largely in the past; the maintenance overhead has been low). Just a
thought.

thanks,
neal
