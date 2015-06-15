From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 0/3 v4] changes to make ipv4 routing table aware of next-hop link status
Date: Mon, 15 Jun 2015 12:33:18 -0400
Message-ID: <1434386001-1157-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:34489 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbbFOQeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 12:34:03 -0400
Received: by qkdm188 with SMTP id m188so35366461qkd.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 09:34:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds the ability to have the Linux kernel track whether or
not a particular route should be used based on the link-status of the
interface associated with the next-hop.

Before this patch any link-failure on an interface that was serving as a
gateway for some systems could result in those systems being isolated
from the rest of the network as the stack would continue to attempt to
send frames out of an interface that is actually linked-down.  When the
kernel is responsible for all forwarding, it should also be responsible
for taking action when the traffic can no longer be forwarded -- there
is no real need to outsource link-monitoring to userspace anymore.

This feature is only enabled with the new per-interface or ipv4 global
sysctls called 'ignore_routes_with_linkdown'.

net.ipv4.conf.all.ignore_routes_with_linkdown = 0
net.ipv4.conf.default.ignore_routes_with_linkdown = 0
net.ipv4.conf.lo.ignore_routes_with_linkdown = 0
...

When the above sysctls are set, the kernel will not only report to
userspace that the link is down, but it will also report to userspace
that a route is dead.  This will signal to userspace that the route will
not be selected.

With the new sysctls set, the following behavior can be observed
(interface p8p1 is link-down):

# ip route show 
default via 10.0.5.2 dev p9p1 
10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 dead linkdown
90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 
# ip route get 90.0.0.1 
90.0.0.1 via 70.0.0.2 dev p7p1  src 70.0.0.1 
    cache 
# ip route get 80.0.0.1 
local 80.0.0.1 dev lo  src 80.0.0.1 
    cache <local> 
# ip route get 80.0.0.2
80.0.0.2 via 10.0.5.2 dev p9p1  src 10.0.5.15 
    cache 

While the route does remain in the table (so it can be modified if
needed rather than being wiped away as it would be if IFF_UP was
cleared), the proper next-hop is chosen automatically when the link is
down.  Now interface p8p1 is linked-up:

# ip route show 
default via 10.0.5.2 dev p9p1 
10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 
90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 
192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
# ip route get 90.0.0.1 
90.0.0.1 via 80.0.0.2 dev p8p1  src 80.0.0.1 
    cache 
# ip route get 80.0.0.1 
local 80.0.0.1 dev lo  src 80.0.0.1 
    cache <local> 
# ip route get 80.0.0.2
80.0.0.2 dev p8p1  src 80.0.0.1 
    cache 

and the output changes to what one would expect.

If the global or interface sysctl is not set, the following output would be
expected when p8p1 is down:

# ip route show 
default via 10.0.5.2 dev p9p1 
10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 linkdown
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 linkdown
90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 

If the dead flag does not appear there should be no expectation that the
kernel would skip using this route due to link being down.

v2: Split kernel changes into 2 patches: first to add linkdown flag and
second to add new sysctl settings.  Also took suggestion from Alex to
simplify code by only checking sysctl during fib lookup and suggestion
from Scott to add a per-interface sysctl.  Added iproute2 patch to
recognize and print linkdown flag.

v3: Code cleanups along with reverse-path checks suggested by Alex and
small fixes related to problems found when multipath was disabled.

v4: Drop binary sysctls

Though there were some that preferred not to have a configuration option
and to make this behavior the default when it was discussed in Ottawa
earlier this year since "it was time to do this."  I wanted to propose
the config option to preserve the current behavior for those that desire
it.  I'll happily remove it if Dave and Linus approve.

An IPv6 implementation is also needed (DECnet too!), but I wanted to start with
the IPv4 implementation to get people comfortable with the idea before moving
forward.  If this is accepted the IPv6 implementation can be posted shortly.

There was also a request for switchdev support for this, but that will be
posted as a followup as switchdev does not currently handle dead
next-hops in a multi-path case and I felt that infra needed to be added
first.

FWIW, we have been running the original version of this series with a
global sysctl and our customers have been happily using a backported
version for IPv4 and IPv6 for >6 months.

Andy Gospodarek (3):
  net: track link-status of ipv4 nexthops
  net: ipv4 sysctl option to ignore routes when nexthop link is down
  iproute2: add support to print 'linkdown' nexthop flag

 include/linux/inetdevice.h        |   3 +
 include/net/fib_rules.h           |   3 +-
 include/net/ip_fib.h              |  21 ++++---
 include/uapi/linux/ip.h           |   1 +
 include/uapi/linux/rtnetlink.h    |   3 +
 net/ipv4/devinet.c                |   2 +
 net/ipv4/fib_frontend.c           |  32 ++++++----
 net/ipv4/fib_lookup.h             |   2 +-
 net/ipv4/fib_rules.c              |   5 +-
 net/ipv4/fib_semantics.c          | 123 ++++++++++++++++++++++++++++++++------
 net/ipv4/fib_trie.c               |  20 ++++++-
 net/ipv4/netfilter/ipt_rpfilter.c |   2 +-
 net/ipv4/route.c                  |  10 ++--
 ip/iproute.c                      |   4 +
 14 files changed, 181 insertions(+), 50 deletions(-)

-- 
1.9.3
