From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net-next v3] tcp: add a tracepoint for tcp retransmission
Date: Fri, 13 Oct 2017 17:13:26 -0600
Message-ID: <861e895d-eaf5-a1f3-1f3d-38a7aff9f1d7@gmail.com>
References: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:53431 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdJMXN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 19:13:29 -0400
Received: by mail-pf0-f193.google.com with SMTP id t188so8982478pfd.10
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 16:13:28 -0700 (PDT)
In-Reply-To: <20171013200316.28561-1-xiyou.wangcong@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/17 2:03 PM, Cong Wang wrote:
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> new file mode 100644
> index 000000000000..3d1cbd072b7e
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
> +	TP_PROTO(struct sock *sk, struct sk_buff *skb),
> +
> +	TP_ARGS(sk, skb),
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
> +
> +	TP_fast_assign(
> +		struct ipv6_pinfo *np = inet6_sk(sk);
> +		struct inet_sock *inet = inet_sk(sk);
> +		struct in6_addr *pin6;
> +		__be32 *p32;
> +
> +		__entry->skbaddr = skb;
> +		__entry->skaddr = sk;
> +
> +		__entry->sport = ntohs(inet->inet_sport);
> +		__entry->dport = ntohs(inet->inet_dport);
> +
> +		p32 = (__be32 *) __entry->saddr;
> +		*p32 = inet->inet_saddr;
> +
> +		p32 = (__be32 *) __entry->daddr;
> +		*p32 =  inet->inet_daddr;
> +
> +		if (np) {
> +			pin6 = (struct in6_addr *)__entry->saddr_v6;
> +			*pin6 = np->saddr;
> +			pin6 = (struct in6_addr *)__entry->daddr_v6;
> +			*pin6 = *(np->daddr_cache);
> +		} else {
> +			pin6 = (struct in6_addr *)__entry->saddr_v6;
> +			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
> +			pin6 = (struct in6_addr *)__entry->daddr_v6;
> +			ipv6_addr_set_v4mapped(inet->inet_daddr, pin6);
> +		}
> +	),
> +
> +	TP_printk("sport=%hu dport=%hu saddr=%pI4 daddr=%pI4 saddrv6=%pI6 daddrv6=%pI6",

%pI6c is more user friendly for IPv6 addresses.
