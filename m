From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 00/10] net: l3mdev: Support for sockets bound to enslaved device
Date: Mon, 31 Jul 2017 20:13:16 -0700
Message-ID: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37323 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdHADNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id 72so508360pfl.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:37 -0700 (PDT)
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

Existing code for socket lookups already pass in 6+ arguments. Rather
than add another for the enslaved device index, the existing lookups
are converted to use a new sk_lookup struct. From there, the enslaved
device index becomes another element of the struct.

Patch 1 introduces sk_lookup struct and helper.

Patches 2-4 convert udp, inet and socket lookups for IPv4 to use the
new sk_lookup struct. Meant to be a conversion of IPv4 code only; no
functional change intended.

Patches 5-7 convert udp, inet and socket lookups for IPv6 to use the
new sk_lookup struct. Meant to be a conversion of IPv6 code only; no
functional change intended.

Patch 8 adds sdif to the sk_lookup struct allowing lookups to consider
a second device index.

Patches 9-10 add support for the enslaved device index to ipv4 and ipv6
socket lookups.

Changes since RFC:
- no significant logic changes; mainly whitespace cleanups

David Ahern (10):
  net: Add sk_lookup struct and helper
  net: ipv4: Convert udp socket lookups to new struct
  net: ipv4: Convert inet socket lookups to new struct
  net: ipv4: Convert raw sockets to sk_lookup
  net: ipv6: Convert udp socket lookups to new struct
  net: ipv6: Convert inet socket lookups to new struct
  net: ipv6: Convert raw sockets to sk_lookup
  net: Add sdif to sk_lookup
  net: ipv4: Support for sockets bound to enslaved device
  net: ipv6: Support for sockets bound to enslaved device

 include/linux/igmp.h                |   3 +-
 include/linux/ipv6.h                |   8 ++
 include/net/inet6_hashtables.h      |  44 ++++-----
 include/net/inet_hashtables.h       |  67 ++++++-------
 include/net/ip.h                    |  10 ++
 include/net/raw.h                   |   3 +-
 include/net/rawv6.h                 |   3 +-
 include/net/sock.h                  |  42 +++++++++
 include/net/tcp.h                   |  17 ++++
 include/net/udp.h                   |  18 +---
 net/dccp/ipv4.c                     |  19 +++-
 net/dccp/ipv6.c                     |  22 +++--
 net/ipv4/igmp.c                     |   6 +-
 net/ipv4/inet_diag.c                |  50 +++++++---
 net/ipv4/inet_hashtables.c          |  59 +++++++-----
 net/ipv4/netfilter/nf_socket_ipv4.c |  16 +++-
 net/ipv4/raw.c                      |  77 +++++++++------
 net/ipv4/raw_diag.c                 |  30 ++++--
 net/ipv4/tcp_ipv4.c                 |  64 +++++++++----
 net/ipv4/udp.c                      | 175 ++++++++++++++++++----------------
 net/ipv4/udp_diag.c                 |  89 ++++++++++++------
 net/ipv6/inet6_hashtables.c         |  75 ++++++++-------
 net/ipv6/netfilter/nf_socket_ipv6.c |  16 +++-
 net/ipv6/raw.c                      |  44 +++++----
 net/ipv6/tcp_ipv6.c                 |  63 +++++++++----
 net/ipv6/udp.c                      | 181 ++++++++++++++++++++----------------
 net/netfilter/xt_TPROXY.c           |  39 +++++---
 27 files changed, 759 insertions(+), 481 deletions(-)

-- 
2.1.4
