From: sfeldma@gmail.com
Subject: [PATCH net-next 0/4] switchdev: add IPv4 routing offload
Date: Mon,  2 Mar 2015 01:29:11 -0800
Message-ID: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36892 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbbCBJaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 04:30:08 -0500
Received: by pabrd3 with SMTP id rd3so42137472pab.4
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 01:30:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

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

Scott Feldman (4):
  rtnetlink: add RTNH_F_EXTERNAL flag for fib offload
  net: add IPv4 routing FIB support for switchdev
  rocker: implement IPv4 fib offloading
  switchdev: don't support custom ip rules, for now

 drivers/net/ethernet/rocker/rocker.c |  517 +++++++++++++++++++++++++++++++---
 include/linux/netdevice.h            |   22 ++
 include/net/ip_fib.h                 |    2 +
 include/net/switchdev.h              |   19 ++
 include/uapi/linux/rtnetlink.h       |    1 +
 net/ipv4/fib_frontend.c              |   13 +
 net/ipv4/fib_rules.c                 |    3 +
 net/ipv4/fib_trie.c                  |   60 +++-
 net/switchdev/switchdev.c            |   99 +++++++
 9 files changed, 688 insertions(+), 48 deletions(-)

-- 
1.7.10.4
