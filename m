From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Mon, 31 Jul 2017 13:04:17 -0700
Message-ID: <CAK6E8=dyuurH4iT5qf0U=JgOEr3X=mDGtG69-KKz5uj6nFYvwQ@mail.gmail.com>
References: <20170727233117.29695-1-fw@strlen.de> <CADVnQym-aDwv-NhcwM5eTW4XQZcKMS+64-VwObKFxT5maT=TGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Westphal <fw@strlen.de>, Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>, Lawrence Brakmo <brakmo@fb.com>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Van Jacobson <vanj@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:38751 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdGaUFA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 16:05:00 -0400
Received: by mail-wr0-f173.google.com with SMTP id f21so127012606wrf.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 13:04:59 -0700 (PDT)
In-Reply-To: <CADVnQym-aDwv-NhcwM5eTW4XQZcKMS+64-VwObKFxT5maT=TGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 29, 2017 at 7:25 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Thu, Jul 27, 2017 at 7:31 PM, Florian Westphal <fw@strlen.de> wrote:
>> This RFC removes tcp prequeueing and header prediction support.
>>
>> After a hallway discussion with Eric Dumazet some
>> maybe-not-so-useful-anymore TCP stack features came up, HP and
>> Prequeue among these.
>>
>> So this RFC proposes to axe both.
>>
>> In brief, TCP prequeue assumes a single-process-blocking-read
>> design, which is not that common anymore, and the most frequently
>> used high-performance networking program that does this is netperf :)
>>
>> With more commong (e)poll designs, prequeue doesn't work.
>>
>> The idea behind prequeueing isn't so bad in itself; it moves
>> part of tcp processing -- including ack processing (including
>> retransmit queue processing) into process context.
>> However, removing it would not just avoid some code, for most
>> programs it elimiates dead code.
>>
>> As processing then always occurs in BH context, it would allow us
>> to experiment e.g. with bulk-freeing of skb heads when a packet acks
>> data on the retransmit queue.
>>
>> Header prediction is also less useful nowadays.
>> For packet trains, GRO will aggregate packets so we do not get
>> a per-packet benefit.
>> Header prediction will also break down with light packet loss due to SACK.
>>
>> So, In short: What do others think?
>>
>> Florian Westphal (6):
>>       tcp: remove prequeue support
>>       tcp: reindent two spots after prequeue removal
>>       tcp: remove low_latency sysctl
>>       tcp: remove header prediction
>>       tcp: remove CA_ACK_SLOWPATH
>>       tcp: remove unused mib counters
>>
>>  Documentation/networking/ip-sysctl.txt |    7
>>  include/linux/tcp.h                    |   15 -
>>  include/net/tcp.h                      |   40 ----
>>  include/uapi/linux/snmp.h              |    8
>>  net/ipv4/proc.c                        |    8
>>  net/ipv4/sysctl_net_ipv4.c             |    3
>>  net/ipv4/tcp.c                         |  109 -----------
>>  net/ipv4/tcp_input.c                   |  303 +++------------------------------
>>  net/ipv4/tcp_ipv4.c                    |   63 ------
>>  net/ipv4/tcp_minisocks.c               |    3
>>  net/ipv4/tcp_output.c                  |    2
>>  net/ipv4/tcp_timer.c                   |   12 -
>>  net/ipv4/tcp_westwood.c                |   31 ---
>>  net/ipv6/tcp_ipv6.c                    |    3
>>  14 files changed, 43 insertions(+), 564 deletions(-)
>>
>
> I unconditionally support the removal of prequeue support.
>
> For the header prediction code: IMHO before removing the header
> prediction code it would be useful to do some kind of before-and-after
> benchmarking on a low-powered device where battery life is the main
> concern. I am thinking about ARM-based cell phones, IoT/embedded
> devices, raspberry pi, etc. You mention GRO helping to make header
> prediction obsolete, but in those devices packets arrive so slowly
> that probably GRO does not help. With slow CPUs and battery life the
> main concern, it seems conceivable to me that header prediction might
> still be a win (and worth keeping, since the complexity cost is

by the time these devices use 4.12 kernels they are likely powerful
enough to make header prediction irrelevant...

> largely in the past; the maintenance overhead has been low). Just a
> thought.
>
> thanks,
> neal
