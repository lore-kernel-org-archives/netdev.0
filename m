From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/4] ipv4: add option to drop unicast encapsulated in L2
 multicast
Date: Fri, 10 Apr 2015 15:10:35 +0200
Message-ID: <1428671435.1890.22.camel@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
	 <alpine.LFD.2.11.1504101445330.1538@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	matti.gottlieb@intel.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59291 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932989AbbDJNKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 09:10:44 -0400
In-Reply-To: <alpine.LFD.2.11.1504101445330.1538@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
> 
> > +	if (IN_DEV_CONF_GET(in_dev, DROP_UNICAST_IN_L2_MULTICAST) &&
> 
> 	For this flag IN_DEV_ORCONF can be used, by this way
> all/drop_unicast_in_l2_multicast=1 can enable it for all
> interfaces.

Good point. I need to look into that for the other patches in this
series as well.

> 	So, this is the same patch as the 2014-Aug version
> but this time with flag? But how the previous problems were
> addressed? May be something is changed in kernel afterwards?
> 
> 	So, if your are back at step 1 can you check again
> the problems with this implementation?:

I think I am, sorry about that. I had focused on the CLUSTERIP problem
in your email, and decided that was solved by simply having the admin
for CLUSTERIP networks never set this flag.

> - no way to select correct skb->pkt_type in inet_rtm_getroute
> before ip_route_input, this is a chiken-egg problem, of course,
> skb->pkt_type = PACKET_HOST can work for now

This is interesting. Why does that even build an skb and route it, if it
really just cares about the struct rtable? Anyway, you're right, using
PACKET_HOST would work. I'm not really sure I see the chicken-and-egg
problem though, it's not like the result of this is used to route the
skb again or something, afaict?

> - ip_route_input is called also for ARP, so incoming ARP
> broadcasts are not replied anymore

Hm. I didn't see this in my testing so far, but I only enable this
temporarily, so perhaps by that time it was already done.

This looks like another case of using this function to not really route
anything but to just look up the route, similar to the
inet_rtm_getroute() function you pointed out. Perhaps that would warrant
splitting out somewhat.

On the other hand, there's not all that much reason not to put this into
ip_rcv_finish(), we already touch the rt->rt_type there for MIB
counters. I'll look into that.

> - CLUSTERIP

See above.

Thanks,
johannes
