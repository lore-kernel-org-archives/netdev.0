From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] udp: clear rps flow table for packets recv
 on UDP unconnected sockets
Date: Mon, 11 Aug 2014 03:07:48 +0200
Message-ID: <1407719268.10122.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1408091013240.1087@tomh.mtv.corp.google.com>
	 <1407689978.10122.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_1f=861mJRjR_Te3y=va=+n1j8fUtcPrexHpWU=zQcnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38590 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbaHKBHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 21:07:50 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so9807486pde.4
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2014 18:07:50 -0700 (PDT)
In-Reply-To: <CA+mtBx_1f=861mJRjR_Te3y=va=+n1j8fUtcPrexHpWU=zQcnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-08-10 at 13:14 -0700, Tom Herbert wrote:

> Sorry, I don't see how this is feasible and would fundamentally break
> the whole model that RPS/RFS is flow based, not protocol-flow based--

In a 5-tuple we _do_ have the protocol : TCP, UDP, ...

I do not know why you want to say it should be protocol independent.

This is only because you want to use a NIC provided hash, but this is
wrong in many cases (tunnels...), and we often fallback to flow
dissection anyway.

The thing is : 100% of TCP packets are flows steered.

And 99% of UDP packets are not, especially on servers where network
performance is an issue.

Current UDP stack do not allow to use millions of connected UDP flows on
a server. So a 'server' is _forced_ to use non connected UDP sockets.

RFS _assumed_ that all packets would participate in the dance, while its
obviously not true. When we have a mix of connected/unconnected packets,
then the RFS hit rate is very low.

Allowing TCP packets to use RFS, and only TCP packets, would immediately
solve the problem, and remove one cache miss per incoming UDP packet.


> Even in TCP, if the number of active connections far exceeds
> the flow table size P(x) could start to approach 1.

Experiments show that only a fraction of flows are really active at a
given point. For the others, we do not care which cpu handles the one
packet every xx seconds.

Experiments show that increasing flow hash table has very little impact,
but overall memory increase.

If we have a lot of TCP "active" flows, then RFS is not worth it.

Prefer a normal steering on a multiqueue NIC, because affine wakeups
will be far better. 
