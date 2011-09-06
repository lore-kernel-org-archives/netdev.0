From: Julian Anastasov <ja@ssi.bg>
Subject: RE: [PATCH] net: Prefer non link-local source addresses
Date: Tue, 6 Sep 2011 22:48:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109061946170.1521@ja.ssi.bg>
References: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com> <alpine.LFD.2.00.1109020041140.1799@ja.ssi.bg> <A0C485B929C0994A889B2580ECDF807648D4D928@EXCHANGE.corp.kentrox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Harris, Jeff" <Jeff_Harris@kentrox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51472 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754108Ab1IFTtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 15:49:13 -0400
In-Reply-To: <A0C485B929C0994A889B2580ECDF807648D4D928@EXCHANGE.corp.kentrox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 6 Sep 2011, Harris, Jeff wrote:

> In this case, the address scope values are being set properly.  The link-local address has link scope and the routable address has global scope.  When the inet_select_addr function is called, the dst address is 0 and the scope is 253 (link scope).  So, in this case, both address could match.  It just happens that the link local address is first in the list for the device.

	Yes, all primary addresses are sorted in decreasing
scope, link before global. For non-gatewayed routes (nh_gw=0)
inet_select_addr always selects the first address with
scope <= the route's scope.

> This condition looks to be arising from the use of interface routes on our device (e.g. ip route add default dev eth0).  The routes are being installed with link scope.  Forcing a scope of global causes a scope of 0 in inet_select_addr which then selects the routable address always.  I have not found any definite documentation on whether local or global should be used for the route, but the default behavior of the 'ip' command is to use link scope on these routes and global on routes with a gateway address. 

	It is not good idea to have scope link for default route
if you plan to contact the world because link routes can
select link addresses for the target network. That is what
you see as a problem. May be ip route should use scope
global as default value for route 0.0.0.0/0.

	You have 2 choices:

1. Preferred: Use global scope for the default route:

ip route add default scope global dev eth0
or
ip route add default nexthop dev eth0 (not recommended)

	Global routes will not select link addresses.

2. Specify prefsrc for the route

ip route add default dev eth0 src <Global_IP>

	but you risk to cause problems for MSG_DONTROUTE users if
scope remains 'link' for target addresses that are not really
onlink.

> Also, I have only been able to test against 2.6.33 which we use on our embedded device.  It is not easy to update to a more recent version.  The patch, though, applied cleanly to the latest stable version.
> 
> Jeff
> 
> -----Original Message-----
> From: Julian Anastasov [mailto:ja@ssi.bg] 
> Sent: Thursday, September 01, 2011 6:15 PM
> To: Harris, Jeff
> Cc: David S. Miller; Alexey Kuznetsov; James Morris; Hideaki YOSHIFUJI; Patrick McHardy; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] net: Prefer non link-local source addresses
> 
> 
> 	Hello,
> 
> On Thu, 1 Sep 2011, Jeff Harris wrote:
> 
> > Section 2.6.1 of RFC 3927 specifies that if link-local and routable addresses
> > are available on an interface, a routable address is preferred.  Update the
> > IPv4 source address selection algorithm to use a 169.254.x.x address only if
> > another matching address is not found.
> > 
> > Tested combinations of configured IP addresses with and without link-local to
> > verify a link-local address was chosen only if no routable address was
> > present.
> 
> 	As David Lamparter already said, isn't the scope value
> suitable for this purpose? Eg.
> ip addr add 169.254.5.5/16 brd + dev eth0 scope link
> 
> 	iproute2 already has function default_scope() in
> ip/ipaddress.c that assigns scope if it is not specified
> while adding address. May be we can add RT_SCOPE_LINK for
> 169.254 there?
> 
> 	Another such place is inet_set_ifa() in
> net/ipv4/devinet.c where we can assign scope, so that
> ifconfig works too.
> 
> 	I see also that net/ipv6/addrconf.c (sit_add_v4_addrs)
> avoids link-local addresses. What I mean is that the scope
> can be checked at many places and it is a mechanism that
> already works.
> 
> 	As result, we will not complicate inet_select_addr.

Regards

--
Julian Anastasov <ja@ssi.bg>
