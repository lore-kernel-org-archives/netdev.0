From: Julian Anastasov <ja@ssi.bg>
Subject: Re: IGMP joins come from the wrong SA/interface
Date: Fri, 31 Jan 2014 10:51:53 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401310948270.1576@ja.home.ssi.bg>
References: <20140118191107.GA21979@sesse.net> <20140119181806.GC16462@order.stressinduktion.org> <20140120184025.GA19972@sesse.net> <20140130104709.GA21178@sesse.net> <20140130180304.GA3793@plex.lan> <20140130181229.GA32245@sesse.net>
 <20140130224411.GG25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36166 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751410AbaAaIwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 03:52:35 -0500
In-Reply-To: <20140130224411.GG25336@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 30 Jan 2014, Hannes Frederic Sowa wrote:

> On Thu, Jan 30, 2014 at 07:12:29PM +0100, Steinar H. Gunderson wrote:
> > On Thu, Jan 30, 2014 at 04:08:11PM -0200, Flavio Leitner wrote:
> > > No special multicast route, so it should go out on em1/default route.
> > 
> > Well, that's not really relevant for my bug then, is it? My problem is that
> > it goes out on the default unicast route, whereas it shouldn't.
> 
> Hmm, it looks to me that Flavio showed that it should actually work
> correctly.
> 
> > > Maybe your application is using wrong values to IP_MULTICAST_IF?
> > > strace and /proc/net/igmp as suggested might help you find out.
> > 
> > This goes for at least vlc+mplayer+xbmc. I don't think they would all be
> > buggy in the same way? (Actually I don't think any of them set
> > IP_MULTICAST_IF.)
> 
> The routing lookup is done at IP_ADD_MEMBERSHIP time. I really wonder why you
> have routed the 239.0.0.0/8 range to eth0.11. It seems to me that the kernel
> does what you told it to do. ;)
> 
> multicast flag on ip route is just used for multicast forwarding and does not
> matter for local multicast. Also if we find unicast route first (more
> specific) kernel does not do backtracking if destination is in multicast
> scope.

	May be it is a side-effect of how inet_select_addr()
works. Looking at igmpv3_newpack() it tries to send packet
on the concerned interface (selected with IP_ADD_MEMBERSHIP)
to 224.0.0.22.

	IP_ADD_MEMBERSHIP selects interface, not source.
>From the provided strace output ip_mc_find_dev() should use
ip_route_output() because imr_address is 0 and imr_ifindex
is not provided. We get the eth0.11 interface from the
239.0.0.0/8 route.

	Then IGMP really wants to use the selected
interface but the configuration tries to use different
interfaces for both multicasts. IGMP simply does not
use FIB to select address because flowi4_oif is always
provided, so the multicast 224.0.0.0/4 route is not used
for the application.

	For ipv4_is_local_multicast (224.0.0.22) we call
inet_select_addr(dev_out, 0, RT_SCOPE_LINK) to select
saddr (link or global, not host) from eth0.11.

	Steinar, now 'ip addr show' can give more information
about what source is to be selected.

	It is possible the concerned interface (eth0.11 for
239.0.0.0/8 or another) to be without addresses. Then
inet_select_addr() can try to select address from another
interface as long as there is address with scope < RT_SCOPE_LINK,
eg. scope global. Order of interfaces matters only here.

	Is 178.82.50.98 on eth0.11 or on first interface?

	To summarize: IGMP will use the same interface as
selected from route to the joined multicast group but
source can be from another device if for some reason there
is no address on this interface.

Regards

--
Julian Anastasov <ja@ssi.bg>
