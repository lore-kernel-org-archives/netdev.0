From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v5 0/4] netns: allow to identify peer netns
Date: Thu, 15 Jan 2015 15:11:14 +0100
Message-ID: <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
References: <87wq7g831b.fsf@x220.int.ebiederm.org>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net, cwang@twopensource.com
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49115 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859AbbAOOLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 09:11:43 -0500
In-Reply-To: <87wq7g831b.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The goal of this serie is to be able to multicast netlink messages with an
attribute that identify a peer netns.
This is needed by the userland to interpret some information contained in
netlink messages (like IFLA_LINK value, but also some other attributes in case
of x-netns netdevice (see also
http://thread.gmane.org/gmane.linux.network/315933/focus=316064 and
http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=4239)).

Ids of peer netns can be set by userland via a new rtnl cmd RTM_NEWNSID. When
the kernel needs an id for a peer (for example when advertising a new x-netns
interface via netlink), if the user didn't allocate an id, one will be
automatically allocated.
These ids are stored per netns and are local (ie only valid in the netns where
they are set). To avoid allocating an int for each peer netns, I use
idr_for_each() to retrieve the id of a peer netns. Note that it will be possible
to add a table (struct net -> id) later to optimize this lookup if needed.

Patch 1/4 introduces the rtnetlink API mechanism to set and get these ids.
Patch 2/4 and 3/4 implements an example of how to use these ids when advertising
information about a x-netns interface.
And patch 4/4 shows that the netlink messages can be symetric between a GET and
a SET.

iproute2 patches are available, I can send them on demand.

Here is a small screenshot to show how it can be used by userland.

# Initialization:
$ ip netns add foo
$ ip netns del foo
$ ip netns
$ touch /var/run/netns/init_net
$ mount --bind /proc/1/ns/net /var/run/netns/init_net
$ ip netns add foo
$ ip -n foo netns
foo
init_net
$ ip -n foo netns set init_net 0
$ ip -n foo netns set foo 1

# Only netns seen from foo have an id:
$ ip netns
foo
init_net
$ ip -n foo netns
foo (id: 1)
init_net (id: 0)

# Add a 4in4 x-netns interface with a link-netnsid option and check the dump:
$ ip -n foo link add ipip1 link-netnsid 0 type ipip remote 10.16.0.121 local 10.16.0.249
$ ip -n foo link ls ipip1
6: ipip1@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default 
    link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 0
# The parameter link-netnsid shows us where the interface sends and receives
# packets (and thus we know where encapsulated addresses are set).

# Add a 4in4 x-netns interface without a link-netnsid option and check that an
# id is allocated in init_net for foo
$ ip netns
foo
init_net
$ ip -n foo link add ipip2 type ipip remote 10.16.0.121 local 10.16.0.249
$ ip -n foo link set ipip2 netns init_net
$ ip link ls ipip2
7: ipip2@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default 
    link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 0
$ ip netns
foo (id: 0)
init_net


v4 -> v5:
  use rtnetlink instead of genetlink
  allocate automatically an id if user didn't assign one
  rename include/uapi/linux/netns.h to include/uapi/linux/net_namespace.h
  add vxlan in patch #3

RFCv3 -> v4:
  rebase on net-next
  add copyright text in the new netns.h file

RFCv2 -> RFCv3:
  ids are now defined by userland (via netlink). Ids are stored in each netns
  (and they are local to this netns).
  add get_link_net support for ip6 tunnels
  netnsid is now a s32 instead of a u32

RFCv1 -> RFCv2:
  remove useless ()
  ids are now stored in the user ns. It's possible to get an id for a peer netns
  only if the current netns and the peer netns have the same user ns parent.

 MAINTAINERS                        |   1 +
 drivers/net/vxlan.c                |   8 ++
 include/net/ip6_tunnel.h           |   1 +
 include/net/ip_tunnels.h           |   1 +
 include/net/net_namespace.h        |   4 +
 include/net/rtnetlink.h            |   2 +
 include/uapi/linux/Kbuild          |   1 +
 include/uapi/linux/if_link.h       |   1 +
 include/uapi/linux/net_namespace.h |  23 ++++
 include/uapi/linux/rtnetlink.h     |   5 +
 net/core/net_namespace.c           | 210 +++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c               |  38 ++++++-
 net/ipv4/ip_gre.c                  |   2 +
 net/ipv4/ip_tunnel.c               |   8 ++
 net/ipv4/ip_vti.c                  |   1 +
 net/ipv4/ipip.c                    |   1 +
 net/ipv6/ip6_gre.c                 |   1 +
 net/ipv6/ip6_tunnel.c              |   9 ++
 net/ipv6/ip6_vti.c                 |   1 +
 net/ipv6/sit.c                     |   1 +
 20 files changed, 316 insertions(+), 3 deletions(-)

Comments are welcome.

Regards,
Nicolas
