From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 00/10] net: l3mdev: Support for sockets bound to
 enslaved device
Date: Fri, 4 Aug 2017 14:17:27 -0600
Message-ID: <27f911f6-465a-7963-c4d1-4e81286bad39@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
 <20170801.174159.2041906157460737035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34461 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752170AbdHDUR3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:17:29 -0400
Received: by mail-pg0-f43.google.com with SMTP id u185so11903248pgb.1
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:17:28 -0700 (PDT)
In-Reply-To: <20170801.174159.2041906157460737035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/17 6:41 PM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Mon, 31 Jul 2017 20:13:16 -0700
> 
>> Existing code for socket lookups already pass in 6+ arguments. Rather
>> than add another for the enslaved device index, the existing lookups
>> are converted to use a new sk_lookup struct. From there, the enslaved
>> device index becomes another element of the struct.
> 
> Sorry, not gonna happen :-)
> 
> I know it's difficult, but maybe we should think about why we're
> passing so much crap into each lookup.\

The 'crap' is essential data to find a socket -- the hash table (common
lookup functions for multiple backends), destination address, dest port,
source address, source port and device index make 6 parameters to be
matched. The socket data is what I consolidated into 1 struct.
Ultimately that data has to make its way from high level wrappers to
compute_score and INET{6}_MATCH at the very bottom.

> 
> And perhaps, why it can't (for example) be constituted in the lookup
> function itself given sufficient (relevant) context.

There are several contexts for lookups -- ingress packets (ipv4 and v6,
tcp, udp, updlite, dccp), error paths for those protocols, netfilter and
socket diagnostic API. The 5 socket parameters do not have a consistent
storage across those contexts.

Further there are several layers of wrappers to what are the real lookup
functions, each wrapper abstracting some piece of data. The call
heirarchy for inet lookups for example:

tcp_v4_early_demux
    __inet_lookup_established

tcp_v4_rcv / dccp_v4_rcv
    __inet_lookup_skb
        __inet_lookup
            __inet_lookup_listener
            __inet_lookup_established

tcp_v4_rcv - TCP_TW_SYN
    inet_lookup_listener
        __inet_lookup_listener

nf_tproxy_get_sock_v4
    inet_lookup_listener
        __inet_lookup_listener

    inet_lookup_established
        __inet_lookup_established


inet_diag_find_one_icsk / nf_socket_get_sock_v4
    inet_lookup
        __inet_lookup
            __inet_lookup_listener
            __inet_lookup_established

tcp_v4_send_reset - MD5 path
    __inet_lookup_listener


tcp_v4_err / dccp_v4_err
    __inet_lookup_established


> 
> I think passing a big struct into the lookups, by reference, is a big
> step backwards.
> 
> For one thing, if you pass it by pointer then the compiler can't
> potentially pass parts in registers even if it could.  However
> if you pass it by value, that's actually a possibility.
> 
> But I'd like to avoid this on-stack blob altogether if possible.

Just sent a v2 that just adds sdif to the existing functions.
