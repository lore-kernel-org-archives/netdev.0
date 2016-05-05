From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 00/14] ipv6: Enable GUEoIPv6 and more fixes for v6 tunneling
Date: Wed, 4 May 2016 18:02:30 -0700
Message-ID: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39975 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbcEEBCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 21:02:54 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u450wjFC022416
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 18:02:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22qcem67tx-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 04 May 2016 18:02:52 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 170da822125d11e6b1ad0002c9dfb610-b2eeac50 for <netdev@vger.kernel.org>;	Wed,
 04 May 2016 18:02:50 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set:
  - Fixes GRE6 to process translate flags correctly from configuration
  - Adds support for GSO and GRO for ip6ip6 and ip4ip6
  - Add support for FOU and GUE in IPv6
  - Support GRE, ip6ip6 and ip4ip6 over FOU/GUE
  - Fixes ip6_input to deal with UDP encapsulations
  - Some other minor fixes


Tested:
   Tested a variety of case, but not the full matrix (which is quite
   large now). Most of the obivous cases (e.g. GRE) work fine. Still
   some issues probably with GSO/GRO being effective in all cases.

    - IPv4/GRE/GUE/IPv6 with RCO
      1 TCP_STREAM
      	6616 Mbps
      200 TCP_RR
	1244043 tps
        141/243/446 90/95/99% latencies
	86.61% CPU utilization
    - IPv6/GRE/GUE/IPv6 with RCO
      1 TCP_STREAM
	6940 Mbps
      200 TCP_RR
	1270903 tps
	138/236/440 90/95/99% latencies
	87.51% CPU utilization

     - IP6IP6
      1 TCP_STREAM
	2576 Mbps
      200 TCP_RR
	498981 tps
	388/498/631 90/95/99% latencies
	19.75% CPU utilization (1 CPU saturated)

     - IP6IP6/GUE/IPv6 with RCO
      1 TCP_STREAM
	1854 Mbps
      200 TCP_RR
	1233818 tps
	143/244/451 90/95/99% latencies
	87.57 CPU utilization

     - IP4IP6
      1 TCP_STREAM
      200 TCP_RR
	763774 tps
	250/318/466 90/95/99% latencies
	35.25% CPU utilization (1 CPU saturated)

     - GRE with keyid
      200 TCP_RR
	744173 tps
	258/332/461 90/95/99% latencies
	34.59% CPU utilization (1 CPU saturated)
      

Tom Herbert (14):
  gso: Remove arbitrary checks for unsupported GSO
  gre6: Fix flag translations
  udp: Don't set skb->encapsulation with RCO
  fou: Call setup_udp_tunnel_sock
  fou: Split out {fou,gue}_build_header
  fou: Add encap ops for IPv6 tunnels
  ipv6: Fix nexthdr for reinjection
  ipv6: Change "final" protocol processing for encapsulation
  fou: Support IPv6 in fou
  ip6_tun: Add infrastructure for doing encapsulation
  ip6_gre: Add support for fou/gue encapsulation
  ip6_tunnel: Add support for fou/gue encapsulation
  ip6ip6: Support for GSO/GRO
  ip4ip6: Support for GSO/GRO

 include/linux/netdev_features.h |   8 ++-
 include/linux/netdevice.h       |   2 +
 include/linux/skbuff.h          |   4 ++
 include/net/fou.h               |  10 +--
 include/net/inet_common.h       |   5 ++
 include/net/ip6_tunnel.h        |  22 +++++-
 net/core/ethtool.c              |   1 +
 net/ipv4/af_inet.c              |  30 ++-------
 net/ipv4/fou.c                  | 144 ++++++++++++++++++++++++----------------
 net/ipv4/gre_offload.c          |  14 ----
 net/ipv4/tcp_offload.c          |  19 ------
 net/ipv4/udp_offload.c          |  20 ++----
 net/ipv6/Makefile               |   4 +-
 net/ipv6/fou6.c                 | 140 ++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_gre.c              |  95 +++++++++++++++++++++++---
 net/ipv6/ip6_input.c            |  24 +++++--
 net/ipv6/ip6_offload.c          |  76 +++++++++++++++------
 net/ipv6/ip6_tunnel.c           | 101 ++++++++++++++++++++++++++--
 net/ipv6/ip6_tunnel_core.c      | 108 ++++++++++++++++++++++++++++++
 net/ipv6/udp_offload.c          |  13 ----
 20 files changed, 652 insertions(+), 188 deletions(-)
 create mode 100644 net/ipv6/fou6.c
 create mode 100644 net/ipv6/ip6_tunnel_core.c

-- 
2.8.0.rc2
