From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH net-next v3 0/4] netns: allow to identify peer netns
Date: Thu,  2 Oct 2014 15:48:06 +0200
Message-ID: <1412257690-31253-1-git-send-email-nicolas.dichtel@6wind.com>
References: <542D5726.8070308@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <542D5726.8070308-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
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
the id of a peer netns.

Patch 1/4 introduces the netlink API mechanism to set and get these ids.
Patch 2/4 and 3/4 shows an example of how to use these ids in rtnetlink
messages. And patch 4/4 shows that the netlink messages can be symetric between
a GET and a SET.

iproute2 patches are available, I can send them on demand.

Here is a small screenshot to show how it can be used by userland:
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
$ ip netns exec foo ip link add ipip1 link-netnsid 0 type ipip remote 10.16.0.121 local 10.16.0.249
$ ip netns exec foo ip l ls ipip1
6: ipip1@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default 
    link/ipip 10.16.0.249 peer 10.16.0.121 link-netnsid 0

The parameter link-netnsid shows us where the interface sends and receives
packets (and thus we know where encapsulated addresses are set).

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
 include/uapi/linux/netns.h   |  31 +++++++
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
 19 files changed, 301 insertions(+), 3 deletions(-)

Comments are welcome.

Regards,
Nicolas
