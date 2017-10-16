From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] tcp: Check daddr_cache before use in tracepoint
Date: Mon, 16 Oct 2017 15:05:45 -0700
Message-ID: <CAM_iQpVy-YY+e1R17P_9uV22n5DbXxL8+ACpY+E5yJYdp8doAQ@mail.gmail.com>
References: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
 <CAM_iQpUgWJwjaRYw3vX4t20foheOrebU3U2ACZqrAbTYqYc-5A@mail.gmail.com> <cfd6b39a-41a6-ccf6-80a7-07089a2d6fea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:53927 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753036AbdJPWGG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 18:06:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id t188so14300423pfd.10
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 15:06:06 -0700 (PDT)
In-Reply-To: <cfd6b39a-41a6-ccf6-80a7-07089a2d6fea@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 2:55 PM, David Ahern <dsahern@gmail.com> wrote:
> On 10/16/17 3:46 PM, Cong Wang wrote:
>> Well, for NULL case, the entry->saddr_v6 will not be filled with
>> your patch.
>
> I think you meant daddr_v6 and yes it will not get filled in, but 0 is
> better than a panic ;-)
>

Sure, but we can do even better with sk->sk_v6_daddr.


>>
>> How about using sk->sk_v6_daddr?
>>
>
> That works, but then both addresses should come from sk and not np:

Yes.

>
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> index 1ffab6d96e94..7989c2dcedf1 100644
> --- a/include/trace/events/tcp.h
> +++ b/include/trace/events/tcp.h
> @@ -46,9 +46,9 @@ TRACE_EVENT(tcp_retransmit_skb,
>
>                 if (np) {
>                         pin6 = (struct in6_addr *)__entry->saddr_v6;
> -                       *pin6 = np->saddr;
> +                       *pin6 = sk->sk_v6_rcv_saddr;
>                         pin6 = (struct in6_addr *)__entry->daddr_v6;
> -                       *pin6 = *(np->daddr_cache);
> +                       *pin6 = sk->sk_v6_daddr;
>                 } else {
>                         pin6 = (struct in6_addr *)__entry->saddr_v6;
>                         ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
>
>
> So np is just a trigger for IPv6 versus v4 mapped.
>
> I do have a question about why ipv4 addresses are non-NULL:

If you really mean non-NULL, they are addresses, not pointers to
addresses.

Or if you mean non-zero, they are set to LOOPBACK4_IPV6
which is what I expect.
