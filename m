From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] tcp: Check daddr_cache before use in tracepoint
Date: Mon, 16 Oct 2017 15:55:00 -0600
Message-ID: <cfd6b39a-41a6-ccf6-80a7-07089a2d6fea@gmail.com>
References: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
 <CAM_iQpUgWJwjaRYw3vX4t20foheOrebU3U2ACZqrAbTYqYc-5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:44769 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752471AbdJPVzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:55:02 -0400
Received: by mail-pf0-f196.google.com with SMTP id x7so16806863pfa.1
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 14:55:01 -0700 (PDT)
In-Reply-To: <CAM_iQpUgWJwjaRYw3vX4t20foheOrebU3U2ACZqrAbTYqYc-5A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/17 3:46 PM, Cong Wang wrote:
> Well, for NULL case, the entry->saddr_v6 will not be filled with
> your patch.

I think you meant daddr_v6 and yes it will not get filled in, but 0 is
better than a panic ;-)

> 
> How about using sk->sk_v6_daddr?
> 

That works, but then both addresses should come from sk and not np:

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 1ffab6d96e94..7989c2dcedf1 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -46,9 +46,9 @@ TRACE_EVENT(tcp_retransmit_skb,

                if (np) {
                        pin6 = (struct in6_addr *)__entry->saddr_v6;
-                       *pin6 = np->saddr;
+                       *pin6 = sk->sk_v6_rcv_saddr;
                        pin6 = (struct in6_addr *)__entry->daddr_v6;
-                       *pin6 = *(np->daddr_cache);
+                       *pin6 = sk->sk_v6_daddr;
                } else {
                        pin6 = (struct in6_addr *)__entry->saddr_v6;
                        ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);


So np is just a trigger for IPv6 versus v4 mapped.

I do have a question about why ipv4 addresses are non-NULL:

$ perf script
         swapper     0 [000]    25.025102: tcp:tcp_retransmit_skb:
sport=22 dport=48076 saddr=127.0.0.6 daddr=127.0.0.6
saddrv6=2001:db8:1::4 daddrv6=2001:db8:1::64
         swapper     0 [000]    25.231125: tcp:tcp_retransmit_skb:
sport=22 dport=48076 saddr=127.0.0.6 daddr=127.0.0.6
saddrv6=2001:db8:1::4 daddrv6=2001:db8:1::64
