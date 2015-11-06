From: Tom Herbert <tom@herbertland.com>
Subject: Re: question about checksumming and tcp_sendpage
Date: Fri, 6 Nov 2015 17:23:02 +0900
Message-ID: <CALx6S369t4iOKYnM=Qzc-oguVZECK93=VJXbhzt+objjs70W4Q@mail.gmail.com>
References: <trinity-80ad84c3-456a-4f51-a3e9-afee4e8ae504-1446759288452@3capp-1and1-bs03>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "ronny.hegewald@online.de" <ronny.hegewald@online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34743 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757237AbbKFIXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 03:23:04 -0500
Received: by iody8 with SMTP id y8so116833397iod.1
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 00:23:02 -0800 (PST)
In-Reply-To: <trinity-80ad84c3-456a-4f51-a3e9-afee4e8ae504-1446759288452@3capp-1and1-bs03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 6, 2015 at 6:34 AM, ronny.hegewald@online.de
<ronny.hegewald@online.de> wrote:
> While reading through net-code i came across some code in tcp_sendpage which i think
> it is not working in the intended way all tie time. But as this code is at that a
> central place and pretty old, im suspicious if my analysis is really right.
>
> The code in question is this
>
> (from net/ipv4/tcp.c)
>
>        if (!(sk->sk_route_caps & NETIF_F_SG) ||
>            !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
>                  return sock_no_sendpage(sk->sk_socket, page, offset, size,
>                                          flags);
>
>
> especially this part.
>
>       !(sk->sk_route_caps & NETIF_F_ALL_CSUM)
>
> The problem occurs if a device only supports checksumming for ipv4 or ipv6. In
> this cases only NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM is set.
>
> Lets assume a device is only supporting checksumming in ipv6 via NETIF_F_IPV6_CSUM,
> and we are calling tcp_sendpage for a ipv4 connection. From my understanding the intend
> of the above code is that in this case sock_no_sendpage should be called. But the bit-check
> against NETIF_F_ALL_CSUM will be always > 0, as it is defined as
>
> (from include/linux/netdev_features.h)
>
> #define NETIF_F_V4_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
> #define NETIF_F_V6_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
> #define NETIF_F_ALL_CSUM        (NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
>
> so it will never get in that branch.
>
> So imo the code should be something like this (in pseudocode)
>
>       (!(sk->sk_route_caps & NETIF_F_V4_CSUM) && proto == IPV4) ||
>       (!(sk->sk_route_caps & NETIF_F_V6_CSUM) && proto == IPV6)
>
> So what am i missing?

Well, looking at the code I don't readily see how this works either,
but note that tcp_sendmsg has the same check also. If your analysis is
correct then checksum for IPv6 would commonly be broken (i.e. several
devices support IPv4 checksum but not IPv6)-- so I find that hard to
believe so I'm probably missing something too! (at least this
ambiguity is one more reason why we need to get rid of NETIF_F_IP_CSUM
and NETIF_F_V6_CSUM!).

Can you try to verify this a bug with some testing?

Thanks,
Tom



> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
