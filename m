From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: [PATCH 4/4] ipv4: mark nexthop as dead when it's subnet becomes unreachable
Date: Fri, 24 Jan 2014 12:12:28 +0200
Message-ID: <2039386.VZO3kUlZdW@tuxracer>
References: <cover.1390304505.git.popovich_sergei@mail.ru> <2208170.gq1LW14mJ5@tuxracer> <alpine.LFD.2.11.1401232221010.1667@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback7.mail.ru ([94.100.176.135]:56196 "EHLO
	fallback7.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbaAXKOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 05:14:52 -0500
Received: from smtp2.mail.ru (smtp2.mail.ru [94.100.176.130])
	by fallback7.mail.ru (mPOP.Fallback_MX) with ESMTP id 3FEC8F67991F
	for <netdev@vger.kernel.org>; Fri, 24 Jan 2014 14:12:46 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=56844 helo=tuxracer.localnet)
	by smtp2.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W6dkZ-0001AI-1j
	for netdev@vger.kernel.org; Fri, 24 Jan 2014 14:12:35 +0400
In-Reply-To: <alpine.LFD.2.11.1401232221010.1667@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 	Hello,

Hello, thanks for detailed explanation.

> 
> 
> 	My idea was that without calling fib_lookup() as
> done in fib_check_nh() you can not mark NH as dead because
> you are not sure that nh_gw is still reachable in different
> subnet. GW can be part of many subnets! Your patch assumes
> that GW can be part only from one subnet.

Agree, you are completely right.

> 
> 	Lets extend your example in this way:
> 
> ip -4 addr add 10.0.0.200/8 dev dummy1
> 
> 	ip route get 10.0.10.5 should return the longest
> match route, 10.0.10.0/24 in our case. If 10.0.10.1 is
> removed ip route get 10.0.10.5 will hit 10.0.0.0/8.
> 
> 	OK, lets delete the last 10.0.10.1 address on dummy1.
> 
> 	Before your patch only fib_sync_down_addr() was called.
> You now call fib_sync_down_dev() with force=0 and ifa, with the
> goal to mark 172.16.0.0/12 as dead (it is unipath route,
> so it will be removed). inet_ifa_match() checks that nh_gw
> 10.0.10.5 is part of the removed subnet: 10.0.10.0/24. Yes, it is.
> Who will check that 10.0.10.5 is still reachable as part of
> another subnet 10.0.0.0/8 ? At this point
> ip -4 route add 172.16.0.0/12 proto static via 10.0.10.5
> should succeed again because fib_check_nh() will see with
> fib_lookup() that 10.0.10.5 is part of 10.0.0.0/8. So, the
> patch wrongly marked the NH as dead.

Really, this true thank you for pointing me on the problem. V3 of patch
makes an attempt to address this. Please review it and tell what do you
thing about.

> 
> 	If last 10.0.10.5 is deleted we can mark NHs with
> nh_gw=10.0.10.5 as dead. It is again expensive (your
> new fib_sync_down_dev call) but this time fib_lookup() is
> not needed because this is a local GW. That is what I mean
> above.
> 
> > When deleting address and removing its subnet, instead of removing route
> > from the FIB, resolve new NH with fib_lookup() if possible, as this done
> > in fib_check_nh(), and leave route with modified NH?
> 
> 	I don't say to do it. But it is the only way to
> check if nh_gw is no more reachable.
> 
> > Well, sounds good, but what to do with multipath routes?
> > Is this correct at all?
> 
> 	fib_lookup() call is correct but expensive. That is
> why it was not done before.

fib_lookup() do its job well, but I dont think we need it at all because:

  1. We known what address is removed (if any).
  2. We known device where address is removed.
  3. Each route, regargless if this unipath or multipath, has device assigned
     for each NH entry (unless NH entry is dead or route is RTN_BLACKHOLE and
     friends). fib_check_nh() checks for this.

I think we could simply iterate over interface address list to find if there
are other subnet to which NH gateway resolve, beside removed address if any?

I did tests with v3 patch and seems described problem is gone.

> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

-- 
SP5474-RIPE
Sergey Popovich
