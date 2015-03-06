From: sfeldma@gmail.com
Subject: [PATCH net-next v4 0/8] switchdev: add IPv4 routing offload
Date: Thu,  5 Mar 2015 21:21:12 -0800
Message-ID: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:38034 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbbCFFUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:33 -0500
Received: by pabrd3 with SMTP id rd3so24699307pab.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:20:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

v4:

  - Add NETIF_F_NETNS_LOCAL to rocker port feature list to keep rocker
    ports in the default netns.  Rocker hardware can't be partitioned
    to support multiple namespaces, currently.  It would be interesting
    to add netns support to rocker device by basically adding another
    match field to each table to match on some unique netns ID, with
    a port knowing it's netns ID.  Future work TDB.
  - Up-level the RTNH_F_EXTERNAL marking of routes installed to offload
    device from driver to switchdev common code.  Now driver can't skip
    routes.  Either it can install the route or it cannot.  Yes or No.
    If no on any route, all offloading is aborted by removing routes
    from offload device and setting ipv4.fib_offload_disabled so no more
    routes can be offloaded.  This is harsh, but it's our starting point.
    We can refine the policies in follow-up work.
  - Add new net.ipv4.fib_offload_disabled bool that is set if anything
    goes wrong with route offloading.  We can refine this later to make
    the setting per-device or per-device-port-netdev, but let's start
    here simple and refine in follow-up work.
  - Rebase against Alex's latest FIB changes.  I think I did everything
    correctly, and didn't run into any issues with testing, but I'd like
    Alex to look over the changes and maybe follow-up with any cleanups.

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

Scott Feldman (8):
  rtnetlink: add RTNH_F_EXTERNAL flag for fib offload
  netdevice: add IPv4 fib add/del ops
  switchdev: add IPv4 fib ndo ops wrappers
  switchdev: don't support custom ip rules, for now
  switchdev: implement IPv4 fib ndo wrappers
  ipv4: add net bool fib_offload_disabled
  fib: hook IPv4 fib for hardware offload
  rocker: implement IPv4 fib offloading

 drivers/net/ethernet/rocker/rocker.c |  483 ++++++++++++++++++++++++++++++----
 include/linux/netdevice.h            |   22 ++
 include/net/ip_fib.h                 |    2 +
 include/net/netns/ipv4.h             |    1 +
 include/net/switchdev.h              |   24 ++
 include/uapi/linux/rtnetlink.h       |    1 +
 net/ipv4/fib_frontend.c              |   13 +
 net/ipv4/fib_rules.c                 |    3 +
 net/ipv4/fib_trie.c                  |   92 ++++++-
 net/switchdev/switchdev.c            |  161 ++++++++++++
 10 files changed, 754 insertions(+), 48 deletions(-)

-- 
1.7.10.4
