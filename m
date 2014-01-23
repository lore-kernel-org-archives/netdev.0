From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 4/4] ipv4: mark nexthop as dead when it's subnet becomes
 unreachable
Date: Thu, 23 Jan 2014 23:58:24 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401232221010.1667@ja.home.ssi.bg>
References: <cover.1390304505.git.popovich_sergei@mail.ru> <40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru> <alpine.LFD.2.11.1401231158510.2682@ja.home.ssi.bg> <2208170.gq1LW14mJ5@tuxracer>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-450474163-1390514309=:1667"
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36561 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753913AbaAWV6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 16:58:49 -0500
In-Reply-To: <2208170.gq1LW14mJ5@tuxracer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-450474163-1390514309=:1667
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 23 Jan 2014, Sergey Popovich wrote:

> В письме от 23 января 2014 12:06:30 пользователь Julian Anastasov написал:
> > 	Hello,
> > 
> > On Tue, 21 Jan 2014, Sergey Popovich wrote:
> > > +			if (nexthop_nh->nh_dev != dev ||
> > > +			    nexthop_nh->nh_scope == scope ||
> > > +			    (ifa && !inet_ifa_match(nexthop_nh->nh_gw, ifa)))
> > 
> > 	What if nh_gw is part from another smaller/larger subnet?
> > For example, what if we still have 10.0.0.200/8 ? 10.0.10.5 is
> > still reachable, i.e. fib_check_nh() would create such NH.
> 
> 
> Please correct me if I dont understand something:
> 
> 1. fib_sync_down_dev() is used when interface is going down
> to remove entires with stray nexthops (including multipath routes).
> 
> 2. It takes as its argument device on which event (DOWN for short) is received
> and force argument to force fib info entry deletion (which is true when
> fib_sync_down_dev() called from fib_disable_ip() with 2 on UNREGISTER event.

	Correct. The rules are:

- force=2 => remove unipath/multipath fi with such NH dev
- force=1 => mark/remove remote and local gateways for dev
- force=0 => mark/remove remote gateways, keep local gateways

	My idea was that without calling fib_lookup() as
done in fib_check_nh() you can not mark NH as dead because
you are not sure that nh_gw is still reachable in different
subnet. GW can be part of many subnets! Your patch assumes
that GW can be part only from one subnet.

> Case, that patch is tries to address happens when we have two
> or more addresses on interface, and NH exists in one of such subnet.
> 
> With two or more address on iface, fib_disable_ip() is not called on single 
> address removal, so fib_sync_down_dev() also not called, and we end with 
> routes with stray nexthop.

	fib_disable_ip() is not a problem with your patch.
My concern is when last 10.0.10.1 is deleted on dummy1,
i.e. when fib_del_ifaddr() is called.

	Lets extend your example in this way:

ip -4 addr add 10.0.0.200/8 dev dummy1

	ip route get 10.0.10.5 should return the longest
match route, 10.0.10.0/24 in our case. If 10.0.10.1 is
removed ip route get 10.0.10.5 will hit 10.0.0.0/8.

	OK, lets delete the last 10.0.10.1 address on dummy1.

	Before your patch only fib_sync_down_addr() was called.
You now call fib_sync_down_dev() with force=0 and ifa, with the
goal to mark 172.16.0.0/12 as dead (it is unipath route,
so it will be removed). inet_ifa_match() checks that nh_gw
10.0.10.5 is part of the removed subnet: 10.0.10.0/24. Yes, it is.
Who will check that 10.0.10.5 is still reachable as part of
another subnet 10.0.0.0/8 ? At this point
ip -4 route add 172.16.0.0/12 proto static via 10.0.10.5
should succeed again because fib_check_nh() will see with
fib_lookup() that 10.0.10.5 is part of 10.0.0.0/8. So, the
patch wrongly marked the NH as dead.

> > IMHO, marking NH by exact nh_gw looks more acceptable because
> > the exact GW becomes unreachable. Otherwise, you will need
> > fib_lookup() as in fib_check_nh() to check that NH becomes
> > unreachable.
> 
> Not sure that I fully understand you.

	If last 10.0.10.5 is deleted we can mark NHs with
nh_gw=10.0.10.5 as dead. It is again expensive (your
new fib_sync_down_dev call) but this time fib_lookup() is
not needed because this is a local GW. That is what I mean
above.

> When deleting address and removing its subnet, instead of removing route from 
> the FIB, resolve new NH with fib_lookup() if possible, as this done in 
> fib_check_nh(), and leave route with modified NH?

	I don't say to do it. But it is the only way to
check if nh_gw is no more reachable.

> Well, sounds good, but what to do with multipath routes?
> Is this correct at all?

	fib_lookup() call is correct but expensive. That is
why it was not done before.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-450474163-1390514309=:1667--
