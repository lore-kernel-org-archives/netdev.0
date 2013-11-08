From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 8 Nov 2013 14:02:44 +0100
Message-ID: <20131108130244.GE5876@order.stressinduktion.org>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58066 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757086Ab3KHNCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 08:02:46 -0500
Content-Disposition: inline
In-Reply-To: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 04:54:09PM -0800, Eric Dumazet wrote:
> TCP does proper randomization of ports on active connections only if
> bind() is used between socket() and connect()
> 
> If bind() is not specifically used, kernel performs autobind, and TCP
> autobind typically uses a sequential allocation for a given (dst
> address, dst port, src address) tuple.
> 
> UDP autobind does a randomization, as part of the effort to make DNS
> more secure.

If I understand the code correctly the UDP ports are fully randomized? This
is good as per-peer randomization and then incrementation seems to be
theoretically broken:

<https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf>

Looking at the code I somehow would like to check the use of net_random there.
The prandom function is reseeded as late_initcall and then only seeded by some
network addresses.

At the time the late_initcall reseeds the PRNG my tests have shown that
the nonblockingpool was still not fully initialized where the PRNG gets
reseeded from.

Hm, I propose a patch which does reseed the pool as soon as the nonblocking
pool got credited enough entropy in credit_entropy_bits. This should help
later binds().

> TCP autobind uses a global sequential number (called @hint in source
> code) with a perturbation done by secure_ipv4_port_ephemeral(),
>  so that the 'hint' of the next port is per (saddr, daddr, dport) tuple
> 
> This was probably done to maximize port use and avoid hitting timewait
> sockets, but I think it should be OK to replace this stuff by a random
> selection to have more entropy in the various flow hashing functions,
> and in general higher security levels. TCP timestamps are now well
> deployed.

We recently had a thread that Windows (since Vista?) disabled tcp
timestamps by default. But I don't see how this should make a great
difference (and still wonder why they give up PAWS.)

> Patch would be trivial, but I'd like to get some comments if
> you think this idea is wrong.

I would like to see this happening.

Thanks,

  Hannes
