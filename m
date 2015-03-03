From: sfeldma@gmail.com
Subject: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Tue,  3 Mar 2015 15:31:53 -0800
Message-ID: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34321 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757638AbbCCXa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 18:30:57 -0500
Received: by pdjg10 with SMTP id g10so52343048pdj.1
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 15:30:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v3:

Changes based on v2 review comments:

  - Move check for custom rules up earlier in patch set, to keep git bisect
    safe.
  - Simplify the route add/modify failure handling to simple try until
    failure, and then on failure, undo everything.  The switchdev driver
    will return err when route can normally be installed to device, but
    the install fails for one reason or another (no space left on device,
    etc).  If a failure happens, uninstall all routes from the device,
    punting forwarding for all routes back to the kernel.
  - Scan route's full nexthop list, ensuring all nexthop devs belong
    to the same switchdev device, otherwise don't try to install route
    to device.

v2:

Changes based on v1 review comments and discussions at netconf:

  - Allow route modification, but use same ndo op used for adding route.
    Driver/device is expected to modify route in-place, if it can, to avoid
    interruption of service.
  - Add new RTNH_F_EXTERNAL flag to mark FIB entries offloaded externally.
  - Don't offload routes if using custom IP rules.  If routes are already
    offloaded, and custom IP rules are turned on, flush routes from offload
    device.  (Offloaded routes are marked with RTNH_F_EXTERNAL).
  - Use kernel's neigh resolution code to resolve route's nexthops' neigh
    MAC addrs.  (Thanks davem, works great!).
  - Use fib->fib_priority in rocker driver to give priorities to routes in
    OF-DPA unicast route table.

v1:

This patch set adds L3 routing offload support for IPv4 routes.  The idea is to
mirror routes installed in the kernel's FIB down to a hardware switch device to
offload the data forwarding path for L3.  Only the data forwarding path is
intercepted.  Control and management of the kernel's FIB remains with the
kernel.

Scott Feldman (7):
  rtnetlink: add RTNH_F_EXTERNAL flag for fib offload
  netdevice: add IPv4 fib add/del ops
  switchdev: add IPv4 fib ndo ops wrappers
  switchdev: don't support custom ip rules, for now
  switchdev: implement IPv4 fib ndo wrappers
  fib: hook IPv4 fib for hardware offload
  rocker: implement IPv4 fib offloading

 drivers/net/ethernet/rocker/rocker.c |  527 +++++++++++++++++++++++++++++++---
 include/linux/netdevice.h            |   22 ++
 include/net/ip_fib.h                 |    2 +
 include/net/switchdev.h              |   19 ++
 include/uapi/linux/rtnetlink.h       |    1 +
 net/ipv4/fib_frontend.c              |   13 +
 net/ipv4/fib_rules.c                 |    3 +
 net/ipv4/fib_trie.c                  |   63 +++-
 net/switchdev/switchdev.c            |  127 ++++++++
 9 files changed, 729 insertions(+), 48 deletions(-)

-- 
1.7.10.4
