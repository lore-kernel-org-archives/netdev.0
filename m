From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Wed, 29 Jul 2015 10:56:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507291047300.2968@ja.home.ssi.bg>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>
To: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42378 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752023AbbG2H45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 03:56:57 -0400
In-Reply-To: <55B6E8AC.4060600@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 28 Jul 2015, Richard Laing wrote:

> From: Richard Laing <richard.laing@alliedtelesis.co.nz>
> 
> Enable flow-based ECMP.
> 
> Currently if equal-cost multipath is enabled the kernel chooses between
> equal cost paths for each matching packet, essentially packets are
> round-robined between the routes. This means that packets from a single
> flow can traverse different routes. If one of the routes experiences
> congestion this can result in delayed or out of order packets arriving
> at the destination.
> 
> This patch allows packets to be routed based on their
> flow - packets in the same flow will always use the same route. This
> prevents out of order packets. There are other issues with round-robin
> based ECMP routing related to variable path MTU handling and debugging.
> See RFC2991 for more details on the problems associated with packet
> based ECMP routing.
> 
> This patch relies on the skb hash value to select between routes. The
> selection uses a hash-threshold algorithm (see RFC2992).

	What about forwarding?

	Also, we can make it lockless and to consider
nexthop weights. The DNS SRV (RFC 2782:Weight) has such WRR algorithm,
I'll try to describe it with such example, may be it can
be properly implemented but this is just to show the idea:

- 2 NHs, alive:
- nexthop 1: weight 10
- nexthop 2: weight 20

- calculate the sum of weight of all nexthops: 10+20=30,
maintain it in fib_info, may be for all alive nexthops

- get a random number in the 0..29 range (in our case L3/L4 hash % 30):

rand_val = hash % sum;

	This means the lowest bits of hash must be random.
rand_val in range 0..9 should use NH1, 10..29 NH2.

- walk the list with nexthops by increasing the running sum:

	int run;

again:
	run = 0;
	for_nexthops(fi) {
		/* run: ->10->30 */
		run += nh->nh_weight;
		if (run > rand_val)
			goto found;
	}

	/* race on NH DEAD flag change, retry? */
	smp_rmb();
	goto again;

found:
	/* use nhsel */

	Some questions remain:

- events can mark nexthops as down/dead/whatever and they may be
ignored. As result, same hash can go to different nexthop for
next route lookups. One option is to walk even dead nexthops
but if we select such one we have to to skip to the next available.
As result, hashes that hit alive NH will always use their NH,
only hashes that hit dead NH will get new NH. Then
change of dead state will not affect the binding of hash
to alive nexthop.

Regards

--
Julian Anastasov <ja@ssi.bg>
