From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Fri, 18 Mar 2016 10:19:31 -0700
Message-ID: <CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
References: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
	<20160316.195341.68257764618999441.davem@davemloft.net>
	<1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, weiwan@google.com,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:36667 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbcCRRTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 13:19:33 -0400
Received: by mail-yw0-f182.google.com with SMTP id g3so147327170ywa.3
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 10:19:32 -0700 (PDT)
In-Reply-To: <1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 8:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-03-16 at 22:38 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 16 Mar 2016 17:22:07 -0700
>>
>> > One of the issue is that IPV6_MTU getsockopt() will not check the dst,
>> > but simply use __sk_dst_get() : It will then report old mtu.
>>
>> That's a bug.
>>
>> ipv4 does it right with a proper sk_dst_get() and so should
>> ipv6.
>
> Using rcu + __sk_dst_get() (in IPv6) is absolutely equivalent to
> sk_dst_get() + dst_release() (in IPv4), modulo atomic ops on dst
> refcnt...
>
> Presumably IPv6 implementation using rcu is slightly better if this
> getsockopt() is badly needed, but apparently nobody cares.
>
> sk_dst_check() is a different beast.
>
> The problem is that dst_mtu(dst) is not able to perform a route lookup
> by itself.
>
> Do we really want to use ip6_sk_dst_lookup_flow() and its associated
> setup for this IP6_MTU thing, and maybe other points we might use an
> obsolete dst ?
>
> Looking at the complexity of udpv6_sendmsg() and rawv6_sendmsg() I
> really wonder if it is worth extracting the route logic.

I think the reason why IPv4 does this correctly is ipv4_sk_update_pmtu()
takes care of the sk cached dst, while the similar part for IPv6,
ip6_sk_update_pmtu() does not that. As Martin already points it out
in the previous version.
