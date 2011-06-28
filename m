From: David Miller <davem@davemloft.net>
Subject: Re: what's causing "ip_rt_bug"?
Date: Mon, 27 Jun 2011 20:55:44 -0700 (PDT)
Message-ID: <20110627.205544.111681152997205782.davem@davemloft.net>
References: <alpine.LFD.2.00.1106180227400.1583@ja.ssi.bg>
	<4DFC627F.7040007@wpkg.org>
	<alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mangoo@wpkg.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bazsi@balabit.hu, hidden@balabit.hu
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756451Ab1F1D4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:56:01 -0400
In-Reply-To: <alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 18 Jun 2011 20:53:59 +0300 (EEST)

> 	Hm, if it happens "sometimes", can it be some
> problem with tproxy and TIME_WAIT sockets? I see that
> tproxy_sk_is_transparent has special treatment for TW
> sockets while ip_route_me_harder is different. As result,
> may be input route is assigned for TW packets.
> 
> 	May be inet_sk_flowi_flags() needs fixing, not
> sure. But following patch is first step to fix this
> problem. I don't have setup to test this patch.

TPROXY has special code to make sure that time-wait sockets
are not assigned to skb->sk, as explained in commit
d503b30bd648b3cb4e5f50b65d27e389960cc6d9, that would cause
all kinds of crashes in nfnetlink_log etc.

Therefore we would see skb->sk==NULL at ip_route_me_harder()
in that case.

> ===========================================================
> 
> 	Avoid creating input routes with ip_route_me_harder.
> It does not work for locally generated packets. Instead,
> restrict sockets to provide valid saddr for output route (or
> unicast saddr for transparent proxy). For other traffic
> allow saddr to be unicast or local but if callers forget
> to check saddr type use 0 for the output route.
> 
> 	The resulting handling should be:
> 
> - REJECT TCP:
> 	- in INPUT we can provide addr_type = RTN_LOCAL but
> 	better allow rejecting traffic delivered with
> 	local route (no IP address => use RTN_UNSPEC to
> 	allow also RTN_UNICAST).
> 	- FORWARD: RTN_UNSPEC => allow RTN_LOCAL/RTN_UNICAST
> 	saddr, add fix to ignore RTN_BROADCAST and RTN_MULTICAST
> 	- OUTPUT: RTN_UNSPEC
> 
> - NAT, mangle, ip_queue, nf_ip_reroute: RTN_UNSPEC in LOCAL_OUT
> 
> - IPVS:
> 	- use RTN_LOCAL in LOCAL_OUT and FORWARD after SNAT
> 	to restrict saddr to be local
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Unless someone gives some negative feedback soon I'm going to
apply this.
