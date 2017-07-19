From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/17] mlxsw: Support for IPv6 UC router
Date: Wed, 19 Jul 2017 09:02:15 +0200
Message-ID: <20170719070232.28457-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33615 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdGSHCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 03:02:36 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so7612358wrd.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 00:02:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This set adds support for IPv6 unicast routes offload. The first four
patches make the FIB notification chain generic so that it could be used
by address families other than IPv4. This is done by having each address
family register its callbacks with the common code, so that its FIB tables
and rules could be dumped upon registration to the chain, while ensuring
the integrity of the dump. The exact mechanics are explained in detail in
the first patch.

The next seven patches build upon this work and add the necessary
callbacks in IPv6 code. This allows listeners of the chain to receive
notifications about IPv6 routes addition, deletion and replacement as
well as FIB rules notifications.

Unlike user space notifications for IPv6 multipath routes, the FIB
notification chain notifies these on a per-nexthop basis. This allows
us to keep the common code lean and is also unnecessary, as notifications
are serialized by each table's lock whereas applications maintaining
netlink caches may suffer from concurrent dumps and deletions / additions
of routes.

The last six patches enable the mlxsw driver to offload IPv6 unicast
routes to the Spectrum ASIC. Without resorting to ACLs, lookup is done
solely based on the destination IP, so the abort mechanism is invoked
upon the addition of source-specific routes.

Follow-up patch sets will increase the scale of gatewayed routes by
consolidating identical nexthop groups to one adjacency entry in the
device's adjacency table (as in IPv4), as well as add support for
NH_{ADD,DEL} events which enable support for the
'ignore_routes_with_linkdown' sysctl.

Ido Schimmel (17):
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
  ipv6: fib: Allow non-FIB users to take reference on route
  mlxsw: spectrum_router: Demultiplex FIB event based on family
  mlxsw: spectrum_router: Sanitize IPv6 FIB rules
  mlxsw: spectrum_router: Add support for IPv6 routes addition /
    deletion
  mlxsw: spectrum_router: Add support for route replace
  mlxsw: spectrum_router: Abort on source-specific routes
  mlxsw: spectrum_router: Don't ignore IPv6 notifications

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 815 ++++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_main.c          |   5 +
 include/net/fib_notifier.h                         |  44 ++
 include/net/fib_rules.h                            |   9 +
 include/net/ip6_fib.h                              |  52 ++
 include/net/ip_fib.h                               |  54 +-
 include/net/net_namespace.h                        |   1 +
 include/net/netns/ipv4.h                           |   1 +
 include/net/netns/ipv6.h                           |   1 +
 include/uapi/linux/ipv6_route.h                    |   1 +
 net/core/Makefile                                  |   3 +-
 net/core/fib_notifier.c                            | 164 +++++
 net/core/fib_rules.c                               |  63 ++
 net/ipv4/fib_frontend.c                            |  17 +-
 net/ipv4/fib_notifier.c                            |  99 ++-
 net/ipv4/fib_rules.c                               |  44 +-
 net/ipv4/fib_semantics.c                           |   9 +-
 net/ipv4/fib_trie.c                                |   5 +-
 net/ipv6/Makefile                                  |   2 +-
 net/ipv6/fib6_notifier.c                           |  61 ++
 net/ipv6/fib6_rules.c                              |  31 +
 net/ipv6/ip6_fib.c                                 | 126 +++-
 net/ipv6/route.c                                   |  23 +-
 23 files changed, 1459 insertions(+), 171 deletions(-)
 create mode 100644 include/net/fib_notifier.h
 create mode 100644 net/core/fib_notifier.c
 create mode 100644 net/ipv6/fib6_notifier.c

-- 
2.9.3
