From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Tue, 23 Sep 2014 15:20:25 +0200
Message-ID: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:46009 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbaIWNUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 09:20:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to be able to multicast netlink messages with an
attribute that identify a peer netns.
This is needed by the userland to interpret some informations contained in
netlink messages (like IFLA_LINK value, but also some other attributes in case
of x-netns netdevice (see also
http://thread.gmane.org/gmane.linux.network/315933/focus=316064 and
http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=4239)).

Ids are stored in the parent user namespace. These ids are valid only inside
this user namespace. The user can retrieve these ids via a new netlink messages,
but only if peer netns are in the same user namespace.

Patch 1/5 and 2/5 introduce the netlink API mechanism to exports these ids to
the userland.
Patch 3/5 and 4/5 shows an example of how to use these ids in rtnetlink
messages. And patch 5/5 shows that the netlink messages can be symetric between
a GET and a SET.

iproute2 patches are available, I can send them on demand.

Here is a small screenshot to show how it can be used by userland:
$ ip netns add foo
$ ip netns del foo
$ ip netns
$ touch /var/run/netns/init_net
$ mount --bind /proc/1/ns/net /var/run/netns/init_net
$ ip netns add foo
$ ip netns
foo (id: 3)
init_net (id: 1)
$ ip netns exec foo ip netns
foo (id: 3)
init_net (id: 1)
$ ip netns exec foo ip link add ipip1 link-netnsid 1 type ipip remote 10.16.0.121 local 10.16.0.249
$ ip netns exec foo ip l ls ipip1
6: ipip1@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default 
    link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 1

The parameter link-netnsid shows us where the interface sends and receives
packets (and thus we know where encapsulated addresses are set).

RFCv1 -> RFCv2:
  remove useless ()
  ids are now stored in the user ns. It's possible to get an id for a peer netns
  only if the current netns and the peer netns have the same user ns parent.

 MAINTAINERS                    |   1 +
 include/linux/user_namespace.h |   4 ++
 include/net/ip_tunnels.h       |   1 +
 include/net/net_namespace.h    |  12 +++++
 include/net/rtnetlink.h        |   2 +
 include/uapi/linux/Kbuild      |   1 +
 include/uapi/linux/if_link.h   |   1 +
 include/uapi/linux/netns.h     |  29 ++++++++++
 kernel/user_namespace.c        |   6 +++
 net/core/net_namespace.c       | 119 ++++++++++++++++++++++++++++++++++++++++-
 net/core/rtnetlink.c           |  47 ++++++++++++++--
 net/ipv4/ip_gre.c              |   2 +
 net/ipv4/ip_tunnel.c           |   8 +++
 net/ipv4/ip_vti.c              |   1 +
 net/ipv4/ipip.c                |   1 +
 net/ipv6/sit.c                 |   1 +
 net/netlink/genetlink.c        |   4 ++
 17 files changed, 236 insertions(+), 4 deletions(-)

Comments are welcome.

Regards,
Nicolas
