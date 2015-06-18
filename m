From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/3 v5] changes to make ipv4 routing table aware
 of next-hop link status
Date: Thu, 18 Jun 2015 10:51:37 -0700
Message-ID: <CAE4R7bAswHA37ed=R90q+WGJo3peXU-_N_5CL5PMuOivxq-uYg@mail.gmail.com>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34170 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134AbbFRRv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 13:51:58 -0400
Received: by oigx81 with SMTP id x81so63114012oig.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 10:51:58 -0700 (PDT)
In-Reply-To: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 8:22 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> This series adds the ability to have the Linux kernel track whether or
> not a particular route should be used based on the link-status of the
> interface associated with the next-hop.
>
> Before this patch any link-failure on an interface that was serving as a
> gateway for some systems could result in those systems being isolated
> from the rest of the network as the stack would continue to attempt to
> send frames out of an interface that is actually linked-down.  When the
> kernel is responsible for all forwarding, it should also be responsible
> for taking action when the traffic can no longer be forwarded -- there
> is no real need to outsource link-monitoring to userspace anymore.
>
> This feature is only enabled with the new per-interface or ipv4 global
> sysctls called 'ignore_routes_with_linkdown'.
>
> net.ipv4.conf.all.ignore_routes_with_linkdown = 0
> net.ipv4.conf.default.ignore_routes_with_linkdown = 0
> net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
> ...
>
> When the above sysctls are set, the kernel will not only report to
> userspace that the link is down, but it will also report to userspace
> that a route is dead.  This will signal to userspace that the route will
> not be selected.
>
> With the new sysctls set, the following behavior can be observed
> (interface p8p1 is link-down):
>
> # ip route show
> default via 10.0.5.2 dev p9p1
> 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown
> 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 dead linkdown
> 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> # ip route get 90.0.0.1
> 90.0.0.1 via 70.0.0.2 dev p7p1  src 70.0.0.1
>     cache
> # ip route get 80.0.0.1
> local 80.0.0.1 dev lo  src 80.0.0.1
>     cache <local>
> # ip route get 80.0.0.2
> 80.0.0.2 via 10.0.5.2 dev p9p1  src 10.0.5.15
>     cache
>
> While the route does remain in the table (so it can be modified if
> needed rather than being wiped away as it would be if IFF_UP was
> cleared), the proper next-hop is chosen automatically when the link is
> down.  Now interface p8p1 is linked-up:
>
> # ip route show
> default via 10.0.5.2 dev p9p1
> 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1
> 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1
> 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
> 192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2
> # ip route get 90.0.0.1
> 90.0.0.1 via 80.0.0.2 dev p8p1  src 80.0.0.1
>     cache
> # ip route get 80.0.0.1
> local 80.0.0.1 dev lo  src 80.0.0.1
>     cache <local>
> # ip route get 80.0.0.2
> 80.0.0.2 dev p8p1  src 80.0.0.1
>     cache
>
> and the output changes to what one would expect.
>
> If the global or interface sysctl is not set, the following output would be
> expected when p8p1 is down:
>
> # ip route show
> default via 10.0.5.2 dev p9p1
> 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15
> 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
> 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 linkdown
> 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 linkdown
> 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2
>
> If the dead flag does not appear there should be no expectation that the
> kernel would skip using this route due to link being down.
>
> v2: Split kernel changes into 2 patches: first to add linkdown flag and
> second to add new sysctl settings.  Also took suggestion from Alex to
> simplify code by only checking sysctl during fib lookup and suggestion
> from Scott to add a per-interface sysctl.  Added iproute2 patch to
> recognize and print linkdown flag.
>
> v3: Code cleanups along with reverse-path checks suggested by Alex and
> small fixes related to problems found when multipath was disabled.
>
> v4: Drop binary sysctls
>
> v5: Whitespace and variable declaration fixups suggested by Dave
>
> Though there were some that preferred not to have a configuration option
> and to make this behavior the default when it was discussed in Ottawa
> earlier this year since "it was time to do this."  I wanted to propose
> the config option to preserve the current behavior for those that desire
> it.  I'll happily remove it if Dave and Linus approve.
>
> An IPv6 implementation is also needed (DECnet too!), but I wanted to start with
> the IPv4 implementation to get people comfortable with the idea before moving
> forward.  If this is accepted the IPv6 implementation can be posted shortly.
>
> There was also a request for switchdev support for this, but that will be
> posted as a followup as switchdev does not currently handle dead
> next-hops in a multi-path case and I felt that infra needed to be added
> first.

Andy, I finally got some time to try your patches with
switchdev+rocker.  With static routes I see the same results as
you...feature is working.  But, I'm not getting switchdev add/mod
updates when link changes.  So switchdev needs to get hooked for this
new feature.  I privately had told you switchdev was getting hooked,
but I was getting fooled by OSPF. I had an ECMP setup and OSPF was
pruning the ECMP nh list when a link went down due to OSPF Hellos no
longer getting thru.  (I had "link-detect" off in zebra).  switchdev
API should be ready to call for this linkdown event.  Need to make the
call around where the netlink echo is sent.   (I'm assuming linkdown
event generates NEWLINK msgs with LINKDOWN flag set).

-scott
