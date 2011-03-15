From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Tue, 15 Mar 2011 12:00:33 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103151135110.1729@ja.ssi.bg>
References: <20110307.205815.193699096.davem@davemloft.net> <alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg> <20110308.103801.193702247.davem@davemloft.net> <20110308.110352.189704727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54709 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750893Ab1COJzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 05:55:32 -0400
In-Reply-To: <20110308.110352.189704727.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Tue, 8 Mar 2011, David Miller wrote:

> 	change_nexthops(fi) {
> +		nexthop_nh->nh_cfg_scope = cfg->fc_scope;
> 		nexthop_nh->nh_saddr = inet_select_addr(nexthop_nh->nh_dev,
> 							nexthop_nh->nh_gw,
> -							nexthop_nh->nh_scope);
> +							nexthop_nh->nh_cfg_scope);
> 	} endfor_nexthops(fi)

 	I see another problem with nh_saddr. fib_info
is reused when NHs and some parameters are equal but the
scope is not part of the fib_info and it is wrong to cache
route scope in NH or even in fib_info. The problem is
that we can expose in nh_saddr addresses with wrong
scope for the route. It happens when two routes with
different route scope reuse same fib_info.

 	First thought is that the field fa_scope can be
moved into fib_scope in struct fib_info, not to use
nh_cfg_scope. Then fib_find_info can differentiate the
entries by fib_scope. It means, fib_info will not be reused
if fib_scope is different. For FIB_RES_PREFSRC I assume we
can access fib_info from nh->nh_parent safely when
refreshing nh_saddr.

 	Here is a script that demonstrates the wrong
exposing:

#! /bin/sh -x

dev=eth1

ip link set $dev up
ip addr flush $dev
ip route flush dev $dev

# address that we want to show only to site
ip addr add 1.2.3.4/24 brd + dev $dev scope site

# first route learns 1.2.3.4 as nh_saddr, it is suitable for site
ip route add 5.6.7.0/24 via 1.2.3.6 dev $dev scope site

# our global primary address for universe, bigger subnet
ip addr add 1.2.3.5/23 brd + dev $dev scope global

# second route reuses same fib_info, exposes site address
# 1.2.3.4 to the 4.3.2.0 world
ip route add 4.3.2.0/24 via 1.2.3.6 dev $dev scope global

# show results:

# we must see src 1.2.3.4:
ip route get 5.6.7.8

# we must see src 1.2.3.5. Old kernels show 1.2.3.5, but we
# show 1.2.3.4:
ip route get 4.3.2.1

Regards

--
Julian Anastasov <ja@ssi.bg>
