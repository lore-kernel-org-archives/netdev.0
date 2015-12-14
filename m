From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 6/8] tcp: Fix conditions to determine checksum offload
Date: Mon, 14 Dec 2015 12:39:12 -0800
Message-ID: <CALx6S34NgOUathkcaMv0y1mHPyd-0oOwqrzSatjEW51m2UFcfQ@mail.gmail.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
	<1450120787-1773171-7-git-send-email-tom@herbertland.com>
	<1450121944.8474.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37569 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbbLNUjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 15:39:12 -0500
Received: by igcto18 with SMTP id to18so92063506igc.0
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 12:39:12 -0800 (PST)
In-Reply-To: <1450121944.8474.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2015 at 11:39 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-12-14 at 11:19 -0800, Tom Herbert wrote:
>> In tcp_send_sendpage and tcp_sendmsg we check the route capabilities to
>> determine if checksum offload can be performed. This check currently
>> does not take the IP protocol into account for devices that advertise
>> only one of NETIF_F_IPV6_CSUM or NETIF_F_IP_CSUM. This patch adds a
>> function to check capabilities for checksum offload with a socket
>> called sk_check_csum_caps. This function checks for specific IPv4 or
>> IPv6 offload support based on the family of the socket.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>>  include/net/sock.h | 9 +++++++++
>>  net/ipv4/tcp.c     | 4 ++--
>>  2 files changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 0ca22b0..ab0269f 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -1791,6 +1791,15 @@ static inline void sk_nocaps_add(struct sock *sk, netdev_features_t flags)
>>       sk->sk_route_caps &= ~flags;
>>  }
>>
>> +static inline bool sk_check_csum_caps(struct sock *sk)
>> +{
>> +     return (sk->sk_route_caps & NETIF_F_HW_CSUM) ||
>> +            (sk->sk_family == PF_INET &&
>> +             (sk->sk_route_caps & NETIF_F_IP_CSUM)) ||
>> +            (sk->sk_family == PF_INET6 &&
>> +             (sk->sk_route_caps & NETIF_F_IPV6_CSUM));
>> +}
>> +
>
> Not sure this handles ipv6_mapped correctly ?
>
It would be handled correctly, but might be suboptimal since we could
be missing opportunities to offload. The original code would assume
that all IPv6 can be offloaded with just NETIF_F_IP_CSUM which
presumably is also suboptimal because we're missing opportunity to do
copy-csum. I don't know which is better to optimize for...

> Since this is going to be called quite often, we might set a single bit
> in sk_setup_caps() or elsewhere and test it here as fast as possible.
>
>
>
