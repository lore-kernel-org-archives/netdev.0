From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3 v5] changes to make ipv4 routing table aware
 of next-hop link status
Date: Thu, 18 Jun 2015 15:39:38 -0400
Message-ID: <20150618193937.GO588@gospo.home.greyhouse.net>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bAswHA37ed=R90q+WGJo3peXU-_N_5CL5PMuOivxq-uYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33719 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbbFRTjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 15:39:40 -0400
Received: by qged89 with SMTP id d89so29731780qge.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 12:39:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAswHA37ed=R90q+WGJo3peXU-_N_5CL5PMuOivxq-uYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 10:51:37AM -0700, Scott Feldman wrote:
> On Thu, Jun 18, 2015 at 8:22 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > This series adds the ability to have the Linux kernel track whether or
> > not a particular route should be used based on the link-status of the
> > interface associated with the next-hop.
> >
> > Before this patch any link-failure on an interface that was serving as a
> > gateway for some systems could result in those systems being isolated
> > from the rest of the network as the stack would continue to attempt to
> > send frames out of an interface that is actually linked-down.  When the
> > kernel is responsible for all forwarding, it should also be responsible
> > for taking action when the traffic can no longer be forwarded -- there
> > is no real need to outsource link-monitoring to userspace anymore.
> >
> > This feature is only enabled with the new per-interface or ipv4 global
> > sysctls called 'ignore_routes_with_linkdown'.
> >
> > net.ipv4.conf.all.ignore_routes_with_linkdown = 0
> > net.ipv4.conf.default.ignore_routes_with_linkdown = 0
> > net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
> > ...
> >
> > When the above sysctls are set, the kernel will not only report to
> > userspace that the link is down, but it will also report to userspace
> > that a route is dead.  This will signal to userspace that the route will
> > not be selected.
> >
> > With the new sysctls set, the following behavior can be observed
> > (interface p8p1 is link-down):
> >
> > # ip route show
> > default via 10.0.5.2 dev p9p1
> > 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> > 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> > 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown
> > 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 dead linkdown
> > 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> > # ip route get 90.0.0.1
> > 90.0.0.1 via 70.0.0.2 dev p7p1  src 70.0.0.1
> >     cache
> > # ip route get 80.0.0.1
> > local 80.0.0.1 dev lo  src 80.0.0.1
> >     cache <local>
> > # ip route get 80.0.0.2
> > 80.0.0.2 via 10.0.5.2 dev p9p1  src 10.0.5.15
> >     cache
> >
> > While the route does remain in the table (so it can be modified if
> > needed rather than being wiped away as it would be if IFF_UP was
> > cleared), the proper next-hop is chosen automatically when the link is
> > down.  Now interface p8p1 is linked-up:
> >
> > # ip route show
> > default via 10.0.5.2 dev p9p1
> > 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> > 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> > 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1
> > 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1
> > 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> > 192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2
> > # ip route get 90.0.0.1
> > 90.0.0.1 via 80.0.0.2 dev p8p1  src 80.0.0.1
> >     cache
> > # ip route get 80.0.0.1
> > local 80.0.0.1 dev lo  src 80.0.0.1
> >     cache <local>
> > # ip route get 80.0.0.2
> > 80.0.0.2 dev p8p1  src 80.0.0.1
> >     cache
> >
> > and the output changes to what one would expect.
> >
> > If the global or interface sysctl is not set, the following output would be
> > expected when p8p1 is down:
> >
> > # ip route show
> > default via 10.0.5.2 dev p9p1
> > 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> > 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> > 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 linkdown
> > 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 linkdown
> > 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> >
> > If the dead flag does not appear there should be no expectation that the
> > kernel would skip using this route due to link being down.
> >
> > v2: Split kernel changes into 2 patches: first to add linkdown flag and
> > second to add new sysctl settings.  Also took suggestion from Alex to
> > simplify code by only checking sysctl during fib lookup and suggestion
> > from Scott to add a per-interface sysctl.  Added iproute2 patch to
> > recognize and print linkdown flag.
> >
> > v3: Code cleanups along with reverse-path checks suggested by Alex and
> > small fixes related to problems found when multipath was disabled.
> >
> > v4: Drop binary sysctls
> >
> > v5: Whitespace and variable declaration fixups suggested by Dave
> >
> > Though there were some that preferred not to have a configuration option
> > and to make this behavior the default when it was discussed in Ottawa
> > earlier this year since "it was time to do this."  I wanted to propose
> > the config option to preserve the current behavior for those that desire
> > it.  I'll happily remove it if Dave and Linus approve.
> >
> > An IPv6 implementation is also needed (DECnet too!), but I wanted to start with
> > the IPv4 implementation to get people comfortable with the idea before moving
> > forward.  If this is accepted the IPv6 implementation can be posted shortly.
> >
> > There was also a request for switchdev support for this, but that will be
> > posted as a followup as switchdev does not currently handle dead
> > next-hops in a multi-path case and I felt that infra needed to be added
> > first.
> 
> Andy, I finally got some time to try your patches with
> switchdev+rocker.  With static routes I see the same results as
> you...feature is working.  But, I'm not getting switchdev add/mod
> updates when link changes.  So switchdev needs to get hooked for this
> new feature.  I privately had told you switchdev was getting hooked,
> but I was getting fooled by OSPF. I had an ECMP setup and OSPF was
> pruning the ECMP nh list when a link went down due to OSPF Hellos no
> longer getting thru.  (I had "link-detect" off in zebra).  switchdev
> API should be ready to call for this linkdown event.  Need to make the
> call around where the netlink echo is sent.   (I'm assuming linkdown
> event generates NEWLINK msgs with LINKDOWN flag set).

Thanks for the testing, Scott.  I'm not surprised that you see those
results.   There are not currently any ipv4 route updates send with the
set as-is-posted, but this is because the current upstream kernel
doesn't do that either.

If we examine the way the ipv4 code currently works before my patches,
any time a route is possibly marked RTNH_F_DEAD, fib_table_flush will
eventually be called and those routes marked dead will be deleted.
Nothing happens if only a single nexthop in a multipath route is dead.
No RTM_DELROUTE messages are sent for routes that are completely dead
and no RTM_NEWROUTE for routes that are still alive with dead nexthops
to alert userspace.  No call to the switchdev layer that those next hops
are inactive and that they should not be used (of course this is not a
big deal as you stated that rocker doesn't have ECMP support, but it is
still a switchdev layer issue).

When I started to work on this, I actually wasn't aware that
RTM_DELROUTE messages were not sent for routes that were not protocol
'kernel' and didn't discover this until I started to investigate
switchdev implementation.  In hindsight resolving that inconsistency is
something that probably should have been handled first.

I've already began the process of essentially changing fib_flush/
fib_table_flush to something that is more like an update since feedback
should be provided to anyone who cares that the kernel has decided to
make a change to the routing tables and proper RTM_DELROUTE/
RTM_NEWROUTE messages should be sent both on admin down/up and if
configured link down/up when those routes were not added by the kernel.
Once the changes to morph fib_table_flush into a routine that performs
route updates the proper behavior at the switchdev layer will also be
implemented.  I'm probably a day or two away from having this in a form
that I've tested and I'm comfortable posting and had planned it as a
followup to this series along with the netconf support that was
requested by Nicolas.
