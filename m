From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 0/4] netns: allow to identify peer netns
Date: Thu, 30 Oct 2014 16:25:24 +0100
Message-ID: <1414682728-4532-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1412257690-31253-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The goal of this serie is to be able to multicast netlink messages with an
attribute that identify a peer netns.
This is needed by the userland to interpret some informations contained in
netlink messages (like IFLA_LINK value, but also some other attributes in case
of x-netns netdevice (see also
http://thread.gmane.org/gmane.linux.network/315933/focus=316064 and
http://thread.gmane.org/gmane.linux.kernel.containers/28301/focus=4239)).

Ids of peer netns are set by userland via a new genl messages. These ids are
stored per netns and are local (ie only valid in the netns where they are set).
To avoid allocating an int for each peer netns, I use idr_for_each() to retrieve
the id of a peer netns. Note that it will be possible to add a table (struct net
-> id) later to optimize this lookup if needed.

Patch 1/4 introduces the netlink API mechanism to set and get these ids.
Patch 2/4 and 3/4 implements an example of how to use these ids in rtnetlink
messages. And patch 4/4 shows that the netlink messages can be symetric between
a GET and a SET.

iproute2 patches are available, I can send them on demand.

Here is a small screenshot to show how it can be used by userland.

First, setup netns and required ids:
$ ip netns add foo
$ ip netns del foo
$ ip netns
$ touch /var/run/netns/init_net
$ mount --bind /proc/1/ns/net /var/run/netns/init_net
$ ip netns add foo
$ ip netns exec foo ip netns set init_net 0
$ ip netns
foo
init_net
$ ip netns exec foo ip netns
foo
init_net (id: 0)

Now, add and display an ipip tunnel, with its link part in init_net (id 0 in
netns foo) and the netdevice in foo:
$ ip netns exec foo ip link add ipip1 link-netnsid 0 type ipip remote 10.16.0.121 local 10.16.0.249
$ ip netns exec foo ip l ls ipip1
6: ipip1@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default 
    link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 0

The parameter link-netnsid shows us where the interface sends and receives
packets (and thus we know where encapsulated addresses are set).

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

 MAINTAINERS                  |   1 +
 include/net/ip6_tunnel.h     |   1 +
 include/net/ip_tunnels.h     |   1 +
 include/net/net_namespace.h  |   5 ++
 include/net/rtnetlink.h      |   2 +
 include/uapi/linux/Kbuild    |   1 +
 include/uapi/linux/if_link.h |   1 +
 include/uapi/linux/netns.h   |  38 +++++++++
 net/core/net_namespace.c     | 195 +++++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c         |  38 ++++++++-
 net/ipv4/ip_gre.c            |   2 +
 net/ipv4/ip_tunnel.c         |   8 ++
 net/ipv4/ip_vti.c            |   1 +
 net/ipv4/ipip.c              |   1 +
 net/ipv6/ip6_gre.c           |   1 +
 net/ipv6/ip6_tunnel.c        |   9 ++
 net/ipv6/ip6_vti.c           |   1 +
 net/ipv6/sit.c               |   1 +
 net/netlink/genetlink.c      |   4 +
 19 files changed, 308 insertions(+), 3 deletions(-)

Comments are welcome.

Regards,
Nicolas
