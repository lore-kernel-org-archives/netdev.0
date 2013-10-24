From: Neal Cardwell <ncardwell@google.com>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 22:37:00 -0400
Message-ID: <CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
References: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Dave_T=E4ht?= <dave.taht@bufferbloat.net>,
	Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:41370 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278Ab3JXChC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 22:37:02 -0400
Received: by mail-ea0-f173.google.com with SMTP id g10so855670eak.4
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 19:37:01 -0700 (PDT)
In-Reply-To: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 10:29 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> In the course of testing routing functionality, I discovered a that the single flow TCP
> throughput was much worse than expected. At first, it looked like a router problem,
> or maybe because one end was a FreeBSD system (which has noticeably slower TCP performance).
> But reducing it down to two systems directly connected over 10G (ixgbe) found the problem.
...
>   4. Do something smarter like a dynamic TCP small queue that adapts.

Yep, Eric made TSQ dynamic a few weeks ago, and mentioned that his
commit helps a single flow on 10Gbps link:

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c9eeec26e32e087359160406f96e0949b3cc6f10

Can you please check the performance in your setup on 3.12-rc4 or newer? :-)

Thanks!

neal

---

commit c9eeec26e32e087359160406f96e0949b3cc6f10
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Sep 27 03:28:54 2013 -0700

    tcp: TSQ can use a dynamic limit

    When TCP Small Queues was added, we used a sysctl to limit amount of
    packets queues on Qdisc/device queues for a given TCP flow.

    Problem is this limit is either too big for low rates, or too small
    for high rates.

    Now TCP stack has rate estimation in sk->sk_pacing_rate, and TSO
    auto sizing, it can better control number of packets in Qdisc/device
    queues.

    New limit is two packets or at least 1 to 2 ms worth of packets.

    Low rates flows benefit from this patch by having even smaller
    number of packets in queues, allowing for faster recovery,
    better RTT estimations.

    High rates flows benefit from this patch by allowing more than 2 packets
    in flight as we had reports this was a limiting factor to reach line
    rate. [ In particular if TX completion is delayed because of coalescing
    parameters ]

    Example for a single flow on 10Gbp link controlled by FQ/pacing

    14 packets in flight instead of 2
    ...
