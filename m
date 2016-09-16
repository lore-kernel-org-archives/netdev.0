From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv4 next 0/3] IPvlan introduce l3s mode
Date: Fri, 16 Sep 2016 12:59:01 -0700
Message-ID: <1474055941-12353-1-git-send-email-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32813 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933663AbcIPT7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:59:09 -0400
Received: by mail-pa0-f67.google.com with SMTP id oz2so3811012pac.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:59:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Same old problem with new approach especially from suggestions from
earlier patch-series.

First thing is that this is introduced as a new mode rather than
modifying the old (L3) mode. So the behavior of the existing modes is
preserved as it is and the new L3s mode obeys iptables so that intended
conn-tracking can work. 

To do this, the code uses newly added l3mdev_rcv() handler and an
Iptables hook. l3mdev_rcv() to perform an inbound route lookup with the
correct (IPvlan slave) interface and then IPtable-hook at LOCAL_INPUT
to change the input device from master to the slave to complete the
formality.

Supporting stack changes are trivial changes to export symbol to get
IPv4 equivalent code exported for IPv6 and to allow netfilter hook
registration code to allow caller to hold RTNL. Please look into
individual patches for details.

Mahesh Bandewar (3):
  ipv6: Export p6_route_input_lookup symbol
  net: Add _nf_(un)register_hooks symbols
  ipvlan: Introduce l3s mode

 Documentation/networking/ipvlan.txt |  7 ++-
 drivers/net/Kconfig                 |  1 +
 drivers/net/ipvlan/ipvlan.h         |  6 +++
 drivers/net/ipvlan/ipvlan_core.c    | 94 +++++++++++++++++++++++++++++++++++++
 drivers/net/ipvlan/ipvlan_main.c    | 87 +++++++++++++++++++++++++++++++---
 include/linux/netfilter.h           |  2 +
 include/net/ip6_route.h             |  3 ++
 include/uapi/linux/if_link.h        |  1 +
 net/ipv6/route.c                    |  7 +--
 net/netfilter/core.c                | 51 ++++++++++++++++++--
 10 files changed, 243 insertions(+), 16 deletions(-)

v1: Initial post
v2: Text correction and config changed from "select" to "depends on"
v3: separated nf_hook registration logic and made it independent of port
    as nf_hook registration is independant of how many IPvlan ports are
    present in the system.
v4: Eliminated need to have "hooks_attached" per port and rely just on
    the mode. Also change BUG_ON to WARN_ON

-- 
2.8.0.rc3.226.g39d4020
