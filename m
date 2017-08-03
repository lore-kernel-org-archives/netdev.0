From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/21] mlxsw: Support for IPv6 UC router
Date: Thu,  3 Aug 2017 13:28:10 +0200
Message-ID: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36134 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752064AbdHCL2f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:35 -0400
Received: by mail-wm0-f66.google.com with SMTP id d40so1808799wma.3
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

This set adds support for IPv6 unicast routes offload. The first four
patches make the FIB notification chain generic so that it could be used
by address families other than IPv4. This is done by having each address
family register its callbacks with the common code, so that its FIB tables
and rules could be dumped upon registration to the chain, while ensuring
the integrity of the dump. The exact mechanics are explained in detail in
the first patch.

The next six patches build upon this work and add the necessary callbacks
in IPv6 code. This allows listeners of the chain to receive notifications
about IPv6 routes addition, deletion and replacement as well as FIB rules
notifications.

Unlike user space notifications for IPv6 multipath routes, the FIB
notification chain notifies these on a per-nexthop basis. This allows
us to keep the common code lean and is also unnecessary, as notifications
are serialized by each table's lock whereas applications maintaining
netlink caches may suffer from concurrent dumps and deletions / additions
of routes.

The next five patches audit the different code paths reading the route's
reference count (rt6i_ref) and remove assumptions regarding its meaning.
This is needed since non-FIB users need to be able to hold a reference on
the route and a non-zero reference count no longer means the route is in
the FIB.

The last six patches enable the mlxsw driver to offload IPv6 unicast
routes to the Spectrum ASIC. Without resorting to ACLs, lookup is done
solely based on the destination IP, so the abort mechanism is invoked
upon the addition of source-specific routes.

Follow-up patch sets will increase the scale of gatewayed routes by
consolidating identical nexthop groups to one adjacency entry in the
device's adjacency table (as in IPv4), as well as add support for
NH_{ADD,DEL} events which enable support for the
'ignore_routes_with_linkdown' sysctl.


Changes in v2:
* Provide offload indication for individual nexthops (David Ahern).
* Use existing route reference count instead of adding another one.
  This resulted in several new patches to remove assumptions regarding
  current semantics of the existing reference count (David Ahern).
* Add helpers to allow non-FIB users to take a reference on route.
* Remove use of tb6_lock in mlxsw (David Ahern).
* Add IPv6 dependency to mlxsw.

Ido Schimmel (21):
  net: core: Make the FIB notification chain generic
  mlxsw: spectrum_router: Ignore address families other than IPv4
  rocker: Ignore address families other than IPv4
  net: fib_rules: Implement notification logic in core
  ipv6: fib_rules: Check if rule is a default rule
  ipv6: fib: Add FIB notifiers callbacks
  ipv6: fib: Add in-kernel notifications for route add / delete
  ipv6: fib_rules: Dump rules during registration to FIB chain
  ipv6: fib: Dump tables during registration to FIB chain
  ipv6: fib: Add offload indication to routes
  ipv6: fib: Don't assume only nodes hold a reference on routes
  ipv6: fib: Unlink replaced routes from their nodes
  ipv6: Regenerate host route according to node pointer upon loopback up
  ipv6: Regenerate host route according to node pointer upon interface
    up
  ipv6: fib: Add helpers to hold / drop a reference on rt6_info
  mlxsw: spectrum_router: Demultiplex FIB event based on family
  mlxsw: spectrum_router: Sanitize IPv6 FIB rules
  mlxsw: spectrum_router: Add support for IPv6 routes addition /
    deletion
  mlxsw: spectrum_router: Add support for route replace
  mlxsw: spectrum_router: Abort on source-specific routes
  mlxsw: spectrum_router: Don't ignore IPv6 notifications

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 855 ++++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_main.c          |   5 +
 include/net/fib_notifier.h                         |  44 ++
 include/net/fib_rules.h                            |   9 +
 include/net/ip6_fib.h                              |  51 ++
 include/net/ip_fib.h                               |  54 +-
 include/net/net_namespace.h                        |   1 +
 include/net/netns/ipv4.h                           |   1 +
 include/net/netns/ipv6.h                           |   1 +
 include/uapi/linux/ipv6_route.h                    |   1 +
 net/core/Makefile                                  |   3 +-
 net/core/fib_notifier.c                            | 164 ++++
 net/core/fib_rules.c                               |  63 ++
 net/ipv4/fib_frontend.c                            |  17 +-
 net/ipv4/fib_notifier.c                            |  99 +--
 net/ipv4/fib_rules.c                               |  44 +-
 net/ipv4/fib_semantics.c                           |   9 +-
 net/ipv4/fib_trie.c                                |   5 +-
 net/ipv6/Makefile                                  |   2 +-
 net/ipv6/addrconf.c                                |   6 +-
 net/ipv6/fib6_notifier.c                           |  61 ++
 net/ipv6/fib6_rules.c                              |  31 +
 net/ipv6/ip6_fib.c                                 | 132 +++-
 net/ipv6/route.c                                   |   8 +
 25 files changed, 1490 insertions(+), 177 deletions(-)
 create mode 100644 include/net/fib_notifier.h
 create mode 100644 net/core/fib_notifier.c
 create mode 100644 net/ipv6/fib6_notifier.c

-- 
2.9.3
