From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on
 pmtu events if possible
Date: Fri, 25 Mar 2016 10:17:38 -0700
Message-ID: <CAM_iQpUUhMNjx6=-5HCJvJepLstFR2UQHSBb-q3RZcYaOJ6pbg@mail.gmail.com>
References: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
	<1458851740.12033.24.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpVDN_LPsa2XgVWoqMjrOYpg9JNjPJVwEvTuxPgYyWRWmg@mail.gmail.com>
	<1458870680.6473.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Wei Wang <weiwan@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33439 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbcCYRRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 13:17:39 -0400
Received: by mail-qk0-f177.google.com with SMTP id s5so34173464qkd.0
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 10:17:39 -0700 (PDT)
In-Reply-To: <1458870680.6473.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 6:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-03-24 at 17:15 -0700, Cong Wang wrote:
>
>> My understanding is that bh_lock_sock() prevents concurrent
>> access to sock struct. Since this is in softirq context, multiple
>> CPU's could call this function concurrently, the whole pmtu
>> update needs to be done atomically.
>>
>> UDP, on the other hand, doesn't do this logic, it just looks up
>> for dst and save it in sk_dst_cache.
>
> Two ICMP messages processed on two different cpus can still get two
> different sockets pointing to the same dst.
>

Yeah, and dst is refcounted so a shared dst will not be freed by both.

> I do not see how dst pmtu update could be protected by a lock on each
> socket. It would require a dst lock , or some simple memory writes that
> do not require special synchro.

I am lost here because you removed the dst lock in ipv4_sk_update_pmtu():

commit 7f502361531e9eecb396cf99bdc9e9a59f7ebd7f
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Jun 30 01:26:23 2014 -0700

    ipv4: irq safe sk_dst_[re]set() and ipv4_sk_update_pmtu() fix

    We have two different ways to handle changes to sk->sk_dst

    First way (used by TCP) assumes socket lock is owned by caller, and use
    no extra lock : __sk_dst_set() & __sk_dst_reset()

    Another way (used by UDP) uses sk_dst_lock because socket lock is not
    always taken. Note that sk_dst_lock is not softirq safe.

    These ways are not inter changeable for a given socket type.

    ipv4_sk_update_pmtu(), added in linux-3.8, added a race, as it used
    the socket lock as synchronization, but users might be UDP sockets.

    Instead of converting sk_dst_lock to a softirq safe version, use xchg()
    as we did for sk_rx_dst in commit e47eb5dfb296b ("udp: ipv4: do not use
    sk_dst_lock from softirq context")

    In a follow up patch, we probably can remove sk_dst_lock, as it is
    only used in IPv6.

My understand is that:

1) sock lock protects the whole update: the whole check, update, recheck,
set logic, to make sure another CPU will not do the same to the same socket
at the same time.

2) the dst itself is safe, because it is always refcounted, and we use xchg()
to change the pointer in sk_dst_cache.

Or am I still missing anything here?

Thanks.
