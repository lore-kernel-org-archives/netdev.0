From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v3 net-next 0/7] net: l3mdev: Support for sockets bound to enslaved device
Date: Mon,  7 Aug 2017 08:44:15 -0700
Message-ID: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36932 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdHGPoh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:44:37 -0400
Received: by mail-pg0-f67.google.com with SMTP id 83so699727pgb.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 08:44:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A missing piece to the VRF puzzle is the ability to bind sockets to
devices enslaved to a VRF. This patch set adds the enslaved device
index, sdif, to IPv4 and IPv6 socket lookups. The end result for users
is the following scope options for services:

1. "global" services - sockets not bound to any device

   Allows 1 service to work across all network interfaces with
   connected sockets bound to the VRF the connection originates
   (Requires net.ipv4.tcp_l3mdev_accept=1 for TCP and
    net.ipv4.udp_l3mdev_accept=1 for UDP)

2. "VRF" local services - sockets bound to a VRF

   Sockets work across all network interfaces enslaved to a VRF but
   are limited to just the one VRF.

3. "device" services - sockets bound to a specific network interface

   Service works only through the one specific interface.

v3
- convert __inet_lookup_established in dccp_v4_err; missed in v2

v2
- remove sk_lookup struct and add sdif as an argument to existing
  functions

Changes since RFC:
- no significant logic changes; mainly whitespace cleanups

David Ahern (7):
  net: ipv4: add second dif to udp socket lookups
  net: ipv4: add second dif to inet socket lookups
  net: ipv4: add second dif to raw socket lookups
  net: ipv4: add second dif to multicast source filter
  net: ipv6: add second dif to udp socket lookups
  net: ipv6: add second dif to inet6 socket lookups
  net: ipv6: add second dif to raw socket lookups

 include/linux/igmp.h           |  3 +-
 include/linux/ipv6.h           | 10 +++++++
 include/net/inet6_hashtables.h | 22 ++++++++------
 include/net/inet_hashtables.h  | 31 +++++++++++---------
 include/net/ip.h               | 10 +++++++
 include/net/raw.h              |  2 +-
 include/net/rawv6.h            |  2 +-
 include/net/tcp.h              | 20 +++++++++++++
 include/net/udp.h              |  4 +--
 net/dccp/ipv4.c                |  4 +--
 net/dccp/ipv6.c                |  4 +--
 net/ipv4/igmp.c                |  6 ++--
 net/ipv4/inet_hashtables.c     | 27 ++++++++++-------
 net/ipv4/raw.c                 | 18 ++++++++----
 net/ipv4/raw_diag.c            |  4 +--
 net/ipv4/tcp_ipv4.c            | 13 +++++----
 net/ipv4/udp.c                 | 66 ++++++++++++++++++++++++------------------
 net/ipv4/udp_diag.c            | 10 +++----
 net/ipv6/inet6_hashtables.c    | 28 +++++++++++-------
 net/ipv6/raw.c                 | 13 +++++----
 net/ipv6/tcp_ipv6.c            | 13 +++++----
 net/ipv6/udp.c                 | 47 ++++++++++++++++--------------
 net/netfilter/xt_TPROXY.c      |  6 ++--
 23 files changed, 228 insertions(+), 135 deletions(-)

-- 
2.1.4
