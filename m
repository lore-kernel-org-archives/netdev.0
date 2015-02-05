From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 00/29] net: VRF support
Date: Wed,  4 Feb 2015 18:34:01 -0700
Message-ID: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35882 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbbBEBfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:35:54 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so6719759iec.8
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:35:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel patches are also available here:
    https://github.com/dsahern/linux.git vrf-3.19

iproute2 patches are also available here:
    https://github.com/dsahern/iproute2 vrf-3.19


Background
----------
The concept of VRFs (Virtual Routing and Forwarding) has been around for over
15 years. Support for VRFs in the Linux kernel has been an often requested
feature for almost as long. For a while support was available via an out of
tree patch [1]. Since network namespaces came along, the response to queries
about VRF support for Linux was 'use namespaces'. But as mentioned previously
[2] network namespaces are not a good match for VRFs. Of the list of problems
noted the big one is that namespaces do not scale efficiently to the number
of VRFs supported by networking gear (> 1000 VRFs). Networking vendors that
want to use Linux as the OS have to carry custom solutions to this problem --
be it userspace networking stacks, extensive kernel patches (to add VRF
support or bend the implementation of namespaces), and/or patches to many
open source components. The recent addition of switchdev support in the
kernel suggests that people expect the use of Linux as a switch networking
OS to increase. Hopefully the time is right to re-open the discussion on a
salable VRF implementation for the Linux kernel.

The intent of this RFC is to get feedback on the overall idea - namely VRFs
as integer id and the nesting of VRFs within a namespace. This set includes
changes only to core IPv4 code which shows the concept; changes to the rest
of the network stack are fairly repetitive.

This patch set has a number of similarities to the original VRF patch - most
notably VRF ids as an integer index and plumbing through iproute2 and
netlink. But this set is really a complete re-implementation of the feature,
integrating VRF within a namespace and leveraging existing support for
network namespaces.

Design
------
Namespaces provide excellent separation of the networking stack from the
netdevices and up. The intent of VRFs is to provide an additional,
logical separation at the L3 layer within a namespace.

   +----------------------------------------------------------+
   | Namespace foo                                            |
   |                         +---------------+                |
   |          +------+       | L3/L4 service |                |
   |          | lldp |       |   (VRF any)   |                |
   |          +------+       +---------------+                |
   |                                                          |
   |                             +-------------------------+  |
   |                             | VRF M                   |  |
   |  +---------------------+  +-------------------------+ |  |
   |  | VRF 1 (default)     |  | VRF N                   | |  |
   |  |  +---------------+  |  |    +---------------+    | |  |
   |  |  | L3/L4 service |  |  |    | L3/L4 service |    | |  |
   |  |  | (VRF unaware) |  |  |    | (VRF unaware) |    | |  |
   |  |  +---------------+  |  |    +---------------+    | |  |
   |  |                     |  |                         | |  |
   |  |+-----+ +----------+ |  |  +-----+ +----------+   | |  |
   |  || FIB | | neighbor | |  |  | FIB | | neighbor |   | |  |
   |  |+-----+ +----------+ |  |  +-----+ +----------+   | |  |
   |  |                     |  |                         |-+  |
   |  | {dev 1}  {dev 2}    |  | {dev 3} {dev 4} {dev 5} |    |
   |  +---------------------+  +-------------------------+    |
   +----------------------------------------------------------+

This is accomplished by enhancing the current namespace checks to a
broader network context that is both a namepsace and a VRF id. The VRF
id is a tag applied to relevant structures, an integer between 1 and 4095
which allows for 4095 VRFs (could have 0 be the default VRF and then the
range is 0-4095 = 4096s VRFs). (The limitation is arguably artificial. It
is based on the genid scheme for versioning networking data which is a
32-bit integer. The VRF id is the lower 12 bits of the genid's.)

Netdevices, sk_buffs, sockets, and tasks are all tagged with a VRF id.
Network lookups (devices, sockets, addresses, routes, neighbors) require a
match of both network namespace and VRF id (or the special 'vrf any' tag;
more on that later).

Beyond the 4-byte tag in various data structures, there are no resources
allocated to a VRF so there is no need to create or destroy a VRF which is
in-line with the concept of keeping it lightweight for scalability. The
trade-off is that VRFs use the the same sysctl settings as the namespace
they are part of and, for example, MIB counters.

The VRF id of tasks defaults to 1 and is inherited parent to child. It can
be read via the file '/proc/<pid>/vrf' and can be changed anytime by writing
to this file (if preferred this can be made a prctl to change the VRF id).
This allows services to be launched in a VRF context using ip, similar to
what is done for network namespaces.
    e.g., ip vrf exec 99 /usr/sbin/sshd

(or a simpler chvrf alias/command can be used to just write the VRF id
to the proc file.)

The task's VRF id also affects viewing and modifying network configuration.
For example, 'ip addr show', 'ip route ls', 'ifconfig', 'arp -n', etc, only
show network data for the VRF associated with the task's VRF id; devices
are at the L2 layer so a command listing devices is not impacted by VRF id.

When a socket is created the VRF id is taken from the task. Socket-vrf
association for non-connected sockets can be changed using a setsockopt
(e.g., create a socket then change VRF id prior to calling bind or connect).

Network devices belong to a single VRF context which defaults to VRF 1.
They can be assigned to another VRF using IFLA_VRF attribute in link
messages. Similarly the VRF assignment is returned in the IFLA_VRF
attribute. The ip command has been modified to display the VRF id of a
device. L2 applications like lldp are not VRF aware and still work through
through all network devices within the namespace.

On RX skbs get their VRF context from the netdevice the packet is received
on. For TX the VRF context for an skb is taken from the socket. The
intention is for L3/raw sockets to be able to set the VRF context for a
packet TX using cmsg (not coded in this patch set).

VRF aware apps (e.g., L3 VPNs) can have sockets in multiple VRFs for
forwarding packets.

The special 'ANY VRF' context allows a single instance of a daemon to
provide a service across all VRFs.
    e.g., ip vrf exec any /usr/sbin/sshd 

The 'any' context applies to listen sockets only; connected sockets are in
a VRF context. Child sockets accepted by the daemon acquire the VRF context
of the network device the connection originated on.

The 'ANY VRF' context can also be used to display all addresses, routes
or neighbors in the kernel cache. That is, 'ip addr show', 'ip route ls',
'ifconfig', 'arp -n', etc, show all network data for the namespace.


About this Patch Set
--------------------
This is not a complete conversion of the networking stack, only a small
sampling to test the waters. Only changes are to core IPv4 code [2] which
is sufficient to illustrate the fundamental concept. Changes from 
struct net to net_ctx are very repetitive.

I'm sure there are a lot of oversights and bugs, but the intent here is
to solicit feedback on the overall idea.


Examples
--------
To illustrate the VRF patches consider a system with 18 NICs:
- eth0, eth17 are in default namespace (e.g., management namespace)

- eth1 - eth8 are in group1 namespace
  - eth1 - eth4 are in VRF 11
  - eth5 - eth8 are in VRF 13

- eth9 - eth16 are in group2 namespace
  - eth9 - eth12 are in VRF 21
  - eth13 - eth16 are in VRF 23

- Addresses assigned to each interface:
  - eth1: 1.1.1.1/24
  - eth2: 2.2.2.1/24
  - eth3: 3.3.3.1/24
  - eth4: 4.4.4.1/24
  - eth5: 1.1.1.1/24 (not a typo, duplicate address in different vrfs)
  - eth6: 6.6.6.1/24
  - eth7: 7.7.7.1/24
  - eth8: 8.8.8.1/24

- openlldpd is started in each namespace

1. device list is VRF agnostic
   - ifconfig -a, ip link show, /proc/net/dev
     --> default namespace shows only eth0 and eth17
     --> group1 namespace shows only eth1 - eth8
     --> group2 namespace shows only eth9 - eth16
         - ip shows vrf assignment of each link

    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 vrf 11 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
        link/ether 02:ab:cd:02:00:01 brd ff:ff:ff:ff:ff:ff

2. address, route, neighbor list is VRF aware
   - ifconfig, ip addr show, ip route ls, /proc/net/route
     --> shows only addresses for VRF id of task unless id is 'any'

   in VRF 1:
   ifconfig eth1
   eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 02:ab:cd:02:00:01  txqueuelen 1000  (Ethernet)
   ...

   No addresses are shown. But if the command is run in VRF 11 or VRF 'any' 
     ip vrf exec 11 ip addr show dev eth1
     3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 vrf 11 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 02:ab:cd:02:00:01 brd ff:ff:ff:ff:ff:ff
        inet 1.1.1.1/24 brd 1.1.1.255 scope global eth1
           valid_lft forever preferred_lft forever

3. start ssh in group1 namespace
   ip netns exec group1 ip vrf exec 11 /usr/sbin/sshd -d
   ssh to 1.1.1.1 via eth1

   ip netns exec group1 ip vrf exec 13 /usr/sbin/sshd -d
   ssh to 1.1.1.1 via eth5
   --> same namespace but different VRFs

4. One ssh instance handles VRFs in group1 namespace
   ip netns exec group1 ip vrf exec any /usr/sbin/sshd

   --> ssh to any address in the namespace works

References
----------
[1] http://sourceforge.net/projects/linux-vrf

[2] http://www.spinics.net/lists/netdev/msg298368.html

[3] To build only enable core ipv4 code. Disable IPv6, netfilter, ipsec, etc.


David Ahern (29):
  net: Introduce net_ctx and macro for context comparison
  net: Flip net_device to use net_ctx
  net: Flip sock_common to net_ctx
  net: Add net_ctx macros for skbuffs
  net: Flip seq_net_private to net_ctx
  net: Flip fib_rules and fib_rules_ops to use net_ctx
  net: Flip inet_bind_bucket to net_ctx
  net: Flip fib_info to net_ctx
  net: Flip ip6_flowlabel to net_ctx
  net: Flip neigh structs to net_ctx
  net: Flip nl_info to net_ctx
  net: Add device lookups by net_ctx
  net: Convert function arg from struct net to struct net_ctx
  net: vrf: Introduce vrf header file
  net: vrf: Add vrf to net_ctx struct
  net: vrf: Set default vrf
  net: vrf: Add vrf context to task struct
  net: vrf: Plumbing for vrf context on a socket
  net: vrf: Add vrf context to skb
  net: vrf: Add vrf context to flow struct
  net: vrf: Add vrf context to genid's
  net: vrf: Set VRF id in various network structs
  net: vrf: Enable vrf checks
  net: vrf: Add support to get/set vrf context on a device
  net: vrf: Handle VRF any context
  net: vrf: Change single_open_net to pass net_ctx
  net: vrf: Add vrf checks and context to ipv4 proc files
  iproute2: vrf: Add vrf subcommand
  iproute2: Add vrf option to ip link command

 fs/proc/base.c                   |  94 +++++++++++++++++++++++++
 fs/proc/proc_net.c               |  22 +++++-
 include/linux/inetdevice.h       |  12 ++--
 include/linux/init_task.h        |   1 +
 include/linux/netdevice.h        |  44 +++++++++++-
 include/linux/sched.h            |   2 +
 include/linux/seq_file_net.h     |  10 +--
 include/linux/skbuff.h           |   5 ++
 include/net/addrconf.h           |  22 +++---
 include/net/arp.h                |   2 +-
 include/net/dst.h                |  16 ++---
 include/net/fib_rules.h          |  10 ++-
 include/net/flow.h               |  10 ++-
 include/net/inet6_hashtables.h   |  19 +++---
 include/net/inet_hashtables.h    |  60 ++++++++++------
 include/net/inet_sock.h          |   1 +
 include/net/inet_timewait_sock.h |   1 +
 include/net/ip.h                 |  10 +--
 include/net/ip6_fib.h            |   4 +-
 include/net/ip6_route.h          |  24 +++----
 include/net/ip_fib.h             |  38 +++++++----
 include/net/ipv6.h               |  14 +++-
 include/net/neighbour.h          |  93 +++++++++++++++++++++----
 include/net/net_namespace.h      |  39 +++++++++--
 include/net/netlink.h            |   5 +-
 include/net/route.h              |  46 +++++++------
 include/net/sock.h               |  21 ++++--
 include/net/tcp.h                |   1 +
 include/net/transp_v6.h          |   2 +-
 include/net/udp.h                |   8 +--
 include/net/vrf.h                |  36 ++++++++++
 include/net/xfrm.h               |  28 ++++----
 include/uapi/linux/if_link.h     |   1 +
 include/uapi/linux/in.h          |   1 +
 kernel/fork.c                    |   2 +
 net/core/dev.c                   |  95 +++++++++++++++++++++++---
 net/core/fib_rules.c             |  36 ++++++----
 net/core/flow.c                  |   5 +-
 net/core/neighbour.c             | 106 +++++++++++++++--------------
 net/core/rtnetlink.c             |  12 ++++
 net/core/skbuff.c                |  12 ++++
 net/core/sock.c                  |   2 +
 net/ipv4/af_inet.c               |  20 ++++--
 net/ipv4/arp.c                   |  76 ++++++++++++---------
 net/ipv4/datagram.c              |   6 +-
 net/ipv4/devinet.c               |  64 ++++++++++++------
 net/ipv4/fib_frontend.c          |  83 ++++++++++++++---------
 net/ipv4/fib_rules.c             |  12 ++--
 net/ipv4/fib_semantics.c         |  38 +++++++----
 net/ipv4/fib_trie.c              |  24 +++++--
 net/ipv4/icmp.c                  |  40 ++++++-----
 net/ipv4/igmp.c                  |  53 +++++++++------
 net/ipv4/inet_connection_sock.c  |  23 ++++---
 net/ipv4/inet_diag.c             |  13 ++--
 net/ipv4/inet_hashtables.c       |  42 +++++++-----
 net/ipv4/inet_timewait_sock.c    |   1 +
 net/ipv4/ip_input.c              |   6 +-
 net/ipv4/ip_options.c            |  20 +++---
 net/ipv4/ip_output.c             |  16 +++--
 net/ipv4/ip_sockglue.c           |  32 +++++++--
 net/ipv4/ipconfig.c              |   6 +-
 net/ipv4/ipmr.c                  |  53 +++++++++------
 net/ipv4/netfilter.c             |  13 ++--
 net/ipv4/ping.c                  |  41 +++++------
 net/ipv4/proc.c                  |  10 +--
 net/ipv4/raw.c                   |  48 ++++++++-----
 net/ipv4/route.c                 | 143 +++++++++++++++++++++++----------------
 net/ipv4/syncookies.c            |   6 +-
 net/ipv4/tcp_ipv4.c              |  57 +++++++++-------
 net/ipv4/tcp_minisocks.c         |   1 +
 net/ipv4/udp.c                   | 122 ++++++++++++++++++---------------
 net/ipv4/udp_diag.c              |  11 +--
 net/ipv4/xfrm4_policy.c          |  14 ++--
 net/netlink/af_netlink.c         |  12 ++++
 net/sctp/protocol.c              |  10 +--
 net/xfrm/xfrm_policy.c           |   9 +--
 76 files changed, 1415 insertions(+), 682 deletions(-)
 create mode 100644 include/net/vrf.h

-- 
1.9.3 (Apple Git-50)
