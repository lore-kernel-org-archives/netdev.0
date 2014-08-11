From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next] udp: clear rps flow table for packets recv on
 UDP unconnected sockets
Date: Mon, 11 Aug 2014 08:47:05 -0700
Message-ID: <CA+mtBx_PSWwGuJdCcQnoR75zMEp199r8fgPQ5Paz_028c0Vo5g@mail.gmail.com>
References: <alpine.DEB.2.02.1408091013240.1087@tomh.mtv.corp.google.com>
	<1407689978.10122.9.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_1f=861mJRjR_Te3y=va=+n1j8fUtcPrexHpWU=zQcnA@mail.gmail.com>
	<1407719268.10122.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:64483 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbaHKPrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 11:47:06 -0400
Received: by mail-ie0-f169.google.com with SMTP id rd18so10074984iec.14
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 08:47:06 -0700 (PDT)
In-Reply-To: <1407719268.10122.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2014 at 6:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-08-10 at 13:14 -0700, Tom Herbert wrote:
>
>> Sorry, I don't see how this is feasible and would fundamentally break
>> the whole model that RPS/RFS is flow based, not protocol-flow based--
>
> In a 5-tuple we _do_ have the protocol : TCP, UDP, ...
>
> I do not know why you want to say it should be protocol independent.
>
> This is only because you want to use a NIC provided hash, but this is
> wrong in many cases (tunnels...), and we often fallback to flow
> dissection anyway.
>
> The thing is : 100% of TCP packets are flows steered.
>
> And 99% of UDP packets are not, especially on servers where network
> performance is an issue.
>
> Current UDP stack do not allow to use millions of connected UDP flows on
> a server. So a 'server' is _forced_ to use non connected UDP sockets.
>
> RFS _assumed_ that all packets would participate in the dance, while its
> obviously not true. When we have a mix of connected/unconnected packets,
> then the RFS hit rate is very low.
>
> Allowing TCP packets to use RFS, and only TCP packets, would immediately
> solve the problem, and remove one cache miss per incoming UDP packet.
>
>
>> Even in TCP, if the number of active connections far exceeds
>> the flow table size P(x) could start to approach 1.
>
> Experiments show that only a fraction of flows are really active at a
> given point. For the others, we do not care which cpu handles the one
> packet every xx seconds.
>
> Experiments show that increasing flow hash table has very little impact,
> but overall memory increase.
>
> If we have a lot of TCP "active" flows, then RFS is not worth it.
>
> Prefer a normal steering on a multiqueue NIC, because affine wakeups
> will be far better.
>
Then why not do that if it solves your problem? RFS is optionally
configured and no one is under any obligation to use it. In fact, if
RFS is indeed completely useless, I'd rather see it removed from the
kernel than hacked up just to extend it's lifetime if it's now only
useful in a few specialized use cases. On the other hand, if you are
really interested in fixing it, please start to articulate and
quantify the problems you're seeing, provide the test cases and real
data that demonstrates the problem, and describe exactly what possible
solutions you've tried and precisely why they have or haven't worked.

Thanks,
Tom

>
>
