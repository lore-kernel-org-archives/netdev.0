From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH net-next 0/17] Make the network stack usable by userns root
Date: Fri, 16 Nov 2012 05:01:44 -0800
Message-ID: <87d2zd8zwn.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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


In a secondary user namespace the root user only has CAP_NET_ADMIN,
CAP_NET_RAW and CAP_NET_BIND_SERVICE with respect to the secondary user
namespace.  The test "capable(CAP_NET_ADMIN)" tests for capabilities in
the initial user namespace.

The following set of patches goes through the networking stack.  First
pushing the capable(CAP_NET_ADMIN) admin calls down farther in the stack
so individual instances can be changed.  Then where I have I it appears
safe I have relaxed the permission checks.

The code is available in git from:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git netns-v73

The netns-v73 branch is against v3.7-rc3 and merges cleanly with net-next.

In my user namespace tree I am working to allow unprivileged users to
create user namespace, and to allow the user namespace root able to
create network namespaces.  Making these patches really about allowing
unprivileged users able to use the networking stack (not that they will
be able to talk to anyone).

David I have some small dependencies on the first two patches of this
series in my later user namespace work.  So after these changes have
been reviewed if you can pull my netns-v73 branch (which is just these
patches) into net-next that will help me avoid unnecessary conflicts.

Eric

Eric W. Biederman (16):
      netns: Deduplicate and fix copy_net_ns when !CONFIG_NET_NS
      userns: make each net (net_ns) belong to a user_ns
      sysctl: Pass useful parameters to sysctl permissions
      net: Don't export sysctls to unprivileged users
      net: Push capable(CAP_NET_ADMIN) into the rtnl methods
      net: Update the per network namespace sysctls to be available to the network namespace owner
      net: Allow userns root to force the scm creds
      net: Allow userns root control of the core of the network stack.
      net: Allow userns root to control ipv4
      net: Allow userns root to control ipv6
      net: Allow userns root to control llc, netfilter, netlink, packet, and xfrm
      net: Allow userns root to control the network bridge code.
      net: Allow the userns root to control vlans.
      net: Enable some sysctls that are safe for the userns root
      net: Enable a userns root rtnl calls that are safe for unprivilged users
      net: Make CAP_NET_BIND_SERVICE per user namespace

Zhao Hongjiang (1):
      user_ns: get rid of duplicate code in net_ctl_permissions

 fs/proc/proc_sysctl.c                   |    9 +++++----
 include/linux/sysctl.h                  |    3 +--
 include/net/net_namespace.h             |   24 ++++++++++++++++--------
 kernel/nsproxy.c                        |    2 +-
 net/8021q/vlan.c                        |   12 ++++++------
 net/bridge/br_ioctl.c                   |   25 +++++++++++++------------
 net/bridge/br_sysfs_br.c                |   10 +++++-----
 net/bridge/br_sysfs_if.c                |    2 +-
 net/can/gw.c                            |    6 ++++++
 net/core/dev.c                          |   17 +++++++++++++----
 net/core/ethtool.c                      |    2 +-
 net/core/neighbour.c                    |    4 ++++
 net/core/net-sysfs.c                    |   15 ++++++++++-----
 net/core/net_namespace.c                |   23 ++++++++++++-----------
 net/core/rtnetlink.c                    |   12 +++++++++++-
 net/core/scm.c                          |    6 +++---
 net/core/sock.c                         |    7 ++++---
 net/core/sysctl_net_core.c              |    5 +++++
 net/dcb/dcbnl.c                         |    3 +++
 net/decnet/dn_dev.c                     |    6 ++++++
 net/decnet/dn_fib.c                     |    6 ++++++
 net/ipv4/af_inet.c                      |    9 ++++++---
 net/ipv4/arp.c                          |    2 +-
 net/ipv4/devinet.c                      |    4 ++--
 net/ipv4/fib_frontend.c                 |    2 +-
 net/ipv4/ip_fragment.c                  |    4 ++++
 net/ipv4/ip_gre.c                       |    4 ++--
 net/ipv4/ip_options.c                   |    6 +++---
 net/ipv4/ip_sockglue.c                  |    5 +++--
 net/ipv4/ip_vti.c                       |    4 ++--
 net/ipv4/ipip.c                         |    4 ++--
 net/ipv4/ipmr.c                         |    2 +-
 net/ipv4/netfilter/arp_tables.c         |    8 ++++----
 net/ipv4/netfilter/ip_tables.c          |    8 ++++----
 net/ipv4/route.c                        |    4 ++++
 net/ipv4/sysctl_net_ipv4.c              |    3 +++
 net/ipv4/tcp.c                          |    2 +-
 net/ipv4/tcp_cong.c                     |    3 ++-
 net/ipv6/addrconf.c                     |    4 ++--
 net/ipv6/af_inet6.c                     |    5 +++--
 net/ipv6/anycast.c                      |    2 +-
 net/ipv6/datagram.c                     |    6 +++---
 net/ipv6/ip6_flowlabel.c                |    3 ++-
 net/ipv6/ip6_gre.c                      |    4 ++--
 net/ipv6/ip6_tunnel.c                   |    4 ++--
 net/ipv6/ip6mr.c                        |    2 +-
 net/ipv6/ipv6_sockglue.c                |    7 ++++---
 net/ipv6/netfilter/ip6_tables.c         |    8 ++++----
 net/ipv6/reassembly.c                   |    4 ++++
 net/ipv6/route.c                        |    6 +++++-
 net/ipv6/sit.c                          |    8 ++++----
 net/key/af_key.c                        |    2 +-
 net/llc/af_llc.c                        |    2 +-
 net/netfilter/ipset/ip_set_core.c       |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c          |    8 ++++++--
 net/netfilter/ipvs/ip_vs_lblc.c         |    7 ++++++-
 net/netfilter/ipvs/ip_vs_lblcr.c        |    4 ++++
 net/netfilter/nf_conntrack_acct.c       |    4 ++++
 net/netfilter/nf_conntrack_ecache.c     |    4 ++++
 net/netfilter/nf_conntrack_helper.c     |    4 ++++
 net/netfilter/nf_conntrack_proto_dccp.c |    8 ++++++--
 net/netfilter/nf_conntrack_standalone.c |    4 ++++
 net/netfilter/nf_conntrack_timestamp.c  |    4 ++++
 net/netfilter/nfnetlink.c               |    2 +-
 net/netlink/af_netlink.c                |    2 +-
 net/packet/af_packet.c                  |    2 +-
 net/phonet/pn_netlink.c                 |    6 ++++++
 net/sched/act_api.c                     |    3 +++
 net/sched/cls_api.c                     |    2 ++
 net/sched/sch_api.c                     |    9 +++++++++
 net/sctp/socket.c                       |    8 +++++---
 net/sysctl_net.c                        |   15 ++++++++++++---
 net/unix/sysctl_net_unix.c              |    4 ++++
 net/xfrm/xfrm_sysctl.c                  |    4 ++++
 net/xfrm/xfrm_user.c                    |    2 +-
 75 files changed, 308 insertions(+), 140 deletions(-)
