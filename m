From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next v2] tcp: add a tracepoint for
 tcp_retransmit_skb()
Date: Thu, 12 Oct 2017 16:18:40 -0700
Message-ID: <20171012231839.upwbtco3h524mmui@ast-mbp>
References: <20171012224807.1669-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:48528 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752592AbdJLXSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 19:18:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id b79so7108869pfk.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 16:18:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171012224807.1669-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 03:48:07PM -0700, Cong Wang wrote:
> We need a real-time notification for tcp retransmission
> for monitoring.
> 
> Of course we could use ftrace to dynamically instrument this
> kernel function too, however we can't retrieve the connection
> information at the same time, for example perf-tools [1] reads
> /proc/net/tcp for socket details, which is slow when we have
> a lots of connections.
> 
> Therefore, this patch adds a tracepoint for tcp_retransmit_skb()
> and exposes src/dst IP addresses and ports of the connection.
> This also makes it easier to integrate into perf.
> 
> Note, I expose both IPv4 and IPv6 addresses at the same time:
> for a IPv4 socket, v4 mapped address is used as IPv6 addresses,
> for a IPv6 socket, LOOPBACK4_IPV6 is already filled by kernel.
> Also, add sk and skb pointers as they are useful for BPF.
> 
> 1. https://github.com/brendangregg/perf-tools/blob/master/net/tcpretrans
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  include/trace/events/tcp.h | 68 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/core/net-traces.c      |  1 +
>  net/ipv4/tcp_output.c      |  3 ++
>  3 files changed, 72 insertions(+)
>  create mode 100644 include/trace/events/tcp.h
> 
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> new file mode 100644
> index 000000000000..749f93c542ab
> --- /dev/null
> +++ b/include/trace/events/tcp.h
> @@ -0,0 +1,68 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM tcp
> +
> +#if !defined(_TRACE_TCP_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_TCP_H
> +
> +#include <linux/ipv6.h>
> +#include <linux/tcp.h>
> +#include <linux/tracepoint.h>
> +#include <net/ipv6.h>
> +
> +TRACE_EVENT(tcp_retransmit_skb,
> +
> +	TP_PROTO(struct sock *sk, struct sk_buff *skb, int segs),
> +
> +	TP_ARGS(sk, skb, segs),
> +
> +	TP_STRUCT__entry(
> +		__field(void *, skbaddr)
> +		__field(void *, skaddr)
> +		__field(__u16, sport)
> +		__field(__u16, dport)
> +		__array(__u8, saddr, 4)
> +		__array(__u8, daddr, 4)
> +		__array(__u8, saddr_v6, 16)
> +		__array(__u8, daddr_v6, 16)
> +	),
...
>  	if (likely(!err)) {
>  		TCP_SKB_CB(skb)->sacked |= TCPCB_EVER_RETRANS;
> +		trace_tcp_retransmit_skb(sk, skb, segs);

looks great to me, but why 'segs' is there?
It's unused.
