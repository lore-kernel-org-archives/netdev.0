From: Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
Subject: Re: [PATCH 1/4] ipv4: add option to drop unicast encapsulated in L2
 multicast
Date: Sat, 11 Apr 2015 13:39:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504111305440.2449@ja.home.ssi.bg>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>  <alpine.LFD.2.11.1504101445330.1538@ja.home.ssi.bg> <1428671435.1890.22.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matti.gottlieb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428671435.1890.22.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 10 Apr 2015, Johannes Berg wrote:

> > - no way to select correct skb->pkt_type in inet_rtm_getroute
> > before ip_route_input, this is a chiken-egg problem, of course,
> > skb->pkt_type = PACKET_HOST can work for now
> 
> This is interesting. Why does that even build an skb and route it, if it
> really just cares about the struct rtable? Anyway, you're right, using
> PACKET_HOST would work. I'm not really sure I see the chicken-and-egg
> problem though, it's not like the result of this is used to route the
> skb again or something, afaict?

	If we want to set correct pkt_type here we should
know the type of daddr (multicast => PACKET_MULTICAST,
broadcast => PACKET_BROADCAST, etc) and we can know it only
after routing (rt_type). I hope we will not do other checks
with pkt_type, so we can put some comment that
skb->pkt_type = PACKET_HOST is just to make
DROP_UNICAST_IN_L2_MULTICAST check happy.

> > - ip_route_input is called also for ARP, so incoming ARP
> > broadcasts are not replied anymore
> 
> Hm. I didn't see this in my testing so far, but I only enable this
> temporarily, so perhaps by that time it was already done.

	I didn't tested it myself, may be you can try:

other_host_on_LAN# arp -d patched_box
other_host_on_LAN# arping -c 1 -I eth0 patched_box

	There must be reply for broadcast requests.

> This looks like another case of using this function to not really route
> anything but to just look up the route, similar to the
> inet_rtm_getroute() function you pointed out. Perhaps that would warrant
> splitting out somewhat.

	Yes, ARP essentially performs rp_filter check (note
that arp_filter check is limited only to local targets, not
to proxy_arp) and target address type check.

	The solution would be to add skb->protocol == htons(ETH_P_IP)
check.

> On the other hand, there's not all that much reason not to put this into
> ip_rcv_finish(), we already touch the rt->rt_type there for MIB
> counters. I'll look into that.

	May be in ip_local_deliver_finish because:

- ip_forward() already has PACKET_HOST check.

- for broadcast/multicast dests we do not care

- CLUSTERIP works in LOCAL_IN (after ip_rcv_finish), LOCAL_IN
is here: ip_rcv_finish->dst_input->ip_local_deliver->
ip_local_deliver_finish

Regards

--
Julian Anastasov <ja-FgGsKACvmQM@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
