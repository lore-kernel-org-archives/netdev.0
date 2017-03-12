From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 00/27] afnetns: new namespace type for separation on protocol level
Date: Mon, 13 Mar 2017 00:01:24 +0100
Message-ID: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:43729 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935591AbdCLXCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:06 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 92B8C20682
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:53 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id EFB782436A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:52 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- >8 ---
Note:
* BE CAREFUL SOURCE ADDRESS SELECTION 
--- >8 ---

afnetns behaves like ordinary namespaces: clone, unshare, setns syscalls
can work with afnetns with one limitation: one cannot cross the realm
of a network namespace while changing the afnetns compartement. To get
into a new afnetns in a different net namespace, one must first change
to the net namespace and afterwards switch to the desired afnetns.

The primitive objects in the kernel an afnetns relates to are,
    - process
    - socket
    - ipv4 address
    - ipv6 address.

An afnetns basically forms a namespace around socket binds. While not
strictly necessary, it also affects the source routing, so firewall rules
are easier to maintain. It does in now way deal with the reception and
handling of multicast or broadcast sockets. As the afnetns namespaces
are connecting to the same L2 network, it does not make sense to try to
build up separation rules here, as they can be broken anyway.

In comparison to ipvlan, afnetns allows early to use early socket
demuxing.

Loopback is not possible within an afnetns until its own loopback device
is added or its private ip address is used.

The easiest way to use afnetns is to use the iproute2 interface, which
very much follows the style of ip-netns.

$ ip afnetns help
Usage: ip afnetns list
       ip afnetns add NAME
       ip afnetns del NAME
       ip afnetns exec NAME cmd ...

IP addresses carry a afnetns identifier, too. It is visible with the -d
(details) option:

$ ip -d a l dev lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0 numtxqueues 1 numrxqueues 1
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever afnet afnet:[4026531958],self
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever afnet afnet:[4026531958],self

This shows the afnetns inode number, as well as that we are currently in
the same namespace as the two specified ip addresses. In case we added
a name for the namespace with ip-afnetns, it will be visible here, too.

$ ip a a 10.0.0.1/24 dev lo afnetns test

This command adds a new ip address to the loopback device and makes it
available in the test afnetns. Commands in this namespace can use this
IP address and use it for outgoing communication.

Changelog:
v1) first published version

The same commands work for IPv6, I only used IPv4 as an example.

This is still work in progress.

Hannes Frederic Sowa (27):
  afnetns: add CLONE_NEWAFNET flag
  afnetns: basic namespace operations and representations
  afnetns: prepare for integration into ipv4
  afnetns: add net_afnetns
  afnetns: ipv6 integration
  afnetns: put afnetns pointer into struct sock
  ipv4: introduce ifa_find_rcu
  afnetns: factor out inet_allow_bind
  afnetns: add sock_afnetns
  afnetns: add ifa_find_afnetns_rcu
  afnetns: validate afnetns in inet_allow_bind
  afnetns: ipv4/udp integration
  afnetns: use inet_allow_bind in inet6_bind
  afnetns: check for afnetns in inet6_bind
  afnetns: add ipv6_get_ifaddr_afnetns_rcu
  afnetns: add udpv6 support
  afnetns: introduce __inet_select_addr
  afnetns: afnetns should influence source address selection
  afnetns: add afnetns support for tcpv4
  ipv6: move ipv6_get_ifaddr to vmlinux in case ipv6 is build as module
  afnetns: add support for tcpv6
  afnetns: track owning namespace for inet_bind
  afnetns: use user_ns from afnetns for checking for binding to port <
    1024
  afnetns: check afnetns user_ns in inet6_bind
  afnetns: ipv4: inherit afnetns from calling application
  afnetns: ipv6: inherit afnetns from calling application
  afnetns: allow only whitelisted protocols to operate inside afnetns

 Documentation/networking/afnetns.txt    |  64 +++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c |   2 +-
 fs/proc/namespaces.c                    |   3 +
 include/linux/inetdevice.h              |  22 ++++-
 include/linux/nsproxy.h                 |   3 +
 include/linux/proc_ns.h                 |   1 +
 include/net/addrconf.h                  |  26 +++++-
 include/net/afnetns.h                   |  47 ++++++++++
 include/net/if_inet6.h                  |   3 +
 include/net/inet_common.h               |   1 +
 include/net/inet_sock.h                 |   1 +
 include/net/net_namespace.h             |  12 +++
 include/net/protocol.h                  |   1 +
 include/net/route.h                     |  10 +-
 include/net/sock.h                      |  13 +++
 include/uapi/linux/if_addr.h            |   2 +
 include/uapi/linux/sched.h              |   1 +
 kernel/fork.c                           |  12 ++-
 kernel/nsproxy.c                        |  24 ++++-
 net/Kconfig                             |  10 ++
 net/core/Makefile                       |   1 +
 net/core/afnetns.c                      | 159 ++++++++++++++++++++++++++++++++
 net/core/net_namespace.c                |  25 +++++
 net/core/sock.c                         |  18 +++-
 net/ipv4/af_inet.c                      | 101 ++++++++++++++------
 net/ipv4/devinet.c                      | 104 ++++++++++++++++++---
 net/ipv4/icmp.c                         |   4 +-
 net/ipv4/igmp.c                         |   2 +-
 net/ipv4/inet_hashtables.c              |  17 +++-
 net/ipv4/route.c                        |  21 +++--
 net/ipv4/tcp_input.c                    |   3 +
 net/ipv4/udp.c                          |  22 ++++-
 net/ipv4/udplite.c                      |   3 +-
 net/ipv4/xfrm4_policy.c                 |   2 +-
 net/ipv6/addrconf.c                     | 117 +++++++++++++----------
 net/ipv6/af_inet6.c                     |  78 ++++++++++------
 net/ipv6/datagram.c                     |   6 +-
 net/ipv6/inet6_hashtables.c             |  55 ++++++++++-
 net/ipv6/ndisc.c                        |   4 +-
 net/ipv6/route.c                        |   2 +-
 net/ipv6/tcp_ipv6.c                     |   3 +-
 net/ipv6/udp.c                          |  21 +++--
 net/ipv6/udplite.c                      |   3 +-
 net/sctp/protocol.c                     |   4 +-
 net/tipc/udp_media.c                    |   2 +-
 45 files changed, 864 insertions(+), 171 deletions(-)
 create mode 100644 Documentation/networking/afnetns.txt
 create mode 100644 include/net/afnetns.h
 create mode 100644 net/core/afnetns.c

-- 
2.9.3
