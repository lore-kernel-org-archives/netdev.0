From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 4/4 v3] ipv4: mark nexthop as dead when it's subnet
 becomes unreachable
Date: Fri, 24 Jan 2014 23:49:59 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401242221410.1717@ja.home.ssi.bg>
References: <cover.1390304505.git.popovich_sergei@mail.ru> <alpine.LFD.2.11.1401232221010.1667@ja.home.ssi.bg> <2039386.VZO3kUlZdW@tuxracer> <1521507.ObZglEaf1D@tuxracer>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36152 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751939AbaAXVuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 16:50:09 -0500
In-Reply-To: <1521507.ObZglEaf1D@tuxracer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 24 Jan 2014, Sergey Popovich wrote:

> -int fib_sync_down_dev(struct net_device *dev, int force)
> +static inline bool fib_sync_down_gw(struct fib_nh *nh,
> +				    struct in_ifaddr *ifr)
> +{
> +	if (!ifr)
> +		return true;
> +
> +	if (nh->nh_flags & RTNH_F_ONLINK)
> +		return false;
> +
> +	if (!inet_ifa_match(nh->nh_gw, ifr))
> +		return false;
> +

	You need to walk subnets here, not IPs, so
for_primary_ifa() instead of for_ifa() will save some
cycles. But for me such change still looks expensive
and does not fix the root of the problem:

- You fix the problem from IP address point of view.
The actual problem is that subnet is removed, i.e.
it is the route removal that is making GWs unreachable.
I can ip route delete some link route and cause GWs
to become unreachable.

- not sure that walking the ifa_list is a fast operation

- sadly, the NHs can not survive the secondary address
promotion as done in __inet_del_ifa().

	You can have additional optimization in
fib_del_ifaddr() while calling fib_sync_down_dev():
do nothing if secondary address is deleted because its
subnet (primary address) should be present. For example:

	if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local) |
	    (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
	     fib_sync_down_dev(dev, ifa, 0)))

> +	for_ifa(ifr->ifa_dev) {

	Below ifa == ifr check will not be needed when
for_primary_ifa() is used or when fib_sync_down_dev() is
called only for primary IPs. We can see some ifr in the
list only if it is secondary IP deleted during the promotion
process. Without promotion, the primary/secondary ifa is
unlinked before the NETDEV_DOWN notification and we do
not see it here.

> +		if (unlikely(ifa == ifr))
> +			continue;
> +		if (inet_ifa_match(nh->nh_gw, ifa))
> +			return false;
> +	} endfor_ifa(ifr->ifa_dev);
> +
> +	return true;

Regards

--
Julian Anastasov <ja@ssi.bg>
