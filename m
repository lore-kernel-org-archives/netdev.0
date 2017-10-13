From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Fri, 13 Oct 2017 10:33:40 -0700
Message-ID: <CAM_iQpViWy+nKX0RdnXmGq3hP4W=T=iLV_URUu=YbMpiso2rmA@mail.gmail.com>
References: <20171012224807.1669-1-xiyou.wangcong@gmail.com> <20171012231839.upwbtco3h524mmui@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Neal Cardwell <ncardwell@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:47288 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753138AbdJMReB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 13:34:01 -0400
Received: by mail-pg0-f68.google.com with SMTP id r25so1712004pgn.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 10:34:01 -0700 (PDT)
In-Reply-To: <20171012231839.upwbtco3h524mmui@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 4:18 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Oct 12, 2017 at 03:48:07PM -0700, Cong Wang wrote:
>> We need a real-time notification for tcp retransmission
>> for monitoring.
>>
>> Of course we could use ftrace to dynamically instrument this
>> kernel function too, however we can't retrieve the connection
>> information at the same time, for example perf-tools [1] reads
>> /proc/net/tcp for socket details, which is slow when we have
>> a lots of connections.
>>
>> Therefore, this patch adds a tracepoint for tcp_retransmit_skb()
>> and exposes src/dst IP addresses and ports of the connection.
>> This also makes it easier to integrate into perf.
>>
>> Note, I expose both IPv4 and IPv6 addresses at the same time:
>> for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
>> for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
>> Also, add sk and skb pointers as they are useful for BPF.
>>
>> 1. https://github.com/brendangregg/perf-tools/blob/master/net/tcpretrans
>>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  include/trace/events/tcp.h | 68 ++++++++++++++++++++++++++++++++++++++++++++++
>>  net/core/net-traces.c      |  1 +
>>  net/ipv4/tcp_output.c      |  3 ++
>>  3 files changed, 72 insertions(+)
>>  create mode 100644 include/trace/events/tcp.h
>>
>> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
>> new file mode 100644
>> index 000000000000..749f93c542ab
>> --- /dev/null
>> +++ b/include/trace/events/tcp.h
>> @@ -0,0 +1,68 @@
>> +#undef TRACE_SYSTEM
>> +#define TRACE_SYSTEM tcp
>> +
>> +#if !defined(_TRACE_TCP_H) || defined(TRACE_HEADER_MULTI_READ)
>> +#define _TRACE_TCP_H
>> +
>> +#include <linux/ipv6.h>
>> +#include <linux/tcp.h>
>> +#include <linux/tracepoint.h>
>> +#include <net/ipv6.h>
>> +
>> +TRACE_EVENT(tcp_retransmit_skb,
>> +
>> +     TP_PROTO(struct sock *sk, struct sk_buff *skb, int segs),
>> +
>> +     TP_ARGS(sk, skb, segs),
>> +
>> +     TP_STRUCT__entry(
>> +             __field(void *, skbaddr)
>> +             __field(void *, skaddr)
>> +             __field(__u16, sport)
>> +             __field(__u16, dport)
>> +             __array(__u8, saddr, 4)
>> +             __array(__u8, daddr, 4)
>> +             __array(__u8, saddr_v6, 16)
>> +             __array(__u8, daddr_v6, 16)
>> +     ),
> ...
>>       if (likely(!err)) {
>>               TCP_SKB_CB(skb)->sacked |= TCPCB_EVER_RETRANS;
>> +             trace_tcp_retransmit_skb(sk, skb, segs);
>
> looks great to me, but why 'segs' is there?
> It's unused.

Ah, I copy-n-paste the tcp_retransmit_skb() prototype...
I will remove it.

Thanks.
