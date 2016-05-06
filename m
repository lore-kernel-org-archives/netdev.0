From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 next-next 00/12] ipv6: Enable GUEoIPv6 and more fixes for v6 tunneling
Date: Fri, 6 May 2016 13:04:44 -0700
Message-ID: <1462565096-4076043-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44734 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758634AbcEFUFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:05:46 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u46K5i9E012726
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 13:05:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22rgdn50n8-5
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:05:44 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 d199da5813c511e6b7640002c99293a0-61c766d0 for <netdev@vger.kernel.org>;	Fri,
 06 May 2016 13:05:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set:
  - Fixes GRE6 to process translate flags correctly from configuration
  - Adds support for GSO and GRO for ip6ip6 and ip4ip6
  - Add support for FOU and GUE in IPv6
  - Support GRE, ip6ip6 and ip4ip6 over FOU/GUE
  - Fixes ip6_input to deal with UDP encapsulations
  - Some other minor fixes

v2:
  - Removed a check of GSO types in MPLS
  - Define GSO type SKB_GSO_IPXIP6 and SKB_GSO_IPXIP4 (based on input
    from Alexander)
  - Don't define GSO types specifally for IP6IP6 and IP4IP6, above
    fix makes that uncessary
  - Don't bother clearing encapsulation flag in UDP tunnel segment
    (another item suggested by Alexander).

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
      
Tom Herbert (12):
  gso: Remove arbitrary checks for unsupported GSO
  net: define gso types for IPx over IPv4 and IPv6
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

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   5 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c       |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   3 +-
 include/linux/netdev_features.h                   |  12 +-
 include/linux/netdevice.h                         |   4 +-
 include/linux/skbuff.h                            |   4 +-
 include/net/fou.h                                 |  10 +-
 include/net/ip6_tunnel.h                          |  22 +++-
 net/core/ethtool.c                                |   4 +-
 net/ipv4/af_inet.c                                |  20 +--
 net/ipv4/fou.c                                    | 144 +++++++++++++---------
 net/ipv4/gre_offload.c                            |  14 ---
 net/ipv4/ipip.c                                   |   2 +-
 net/ipv4/tcp_offload.c                            |  19 ---
 net/ipv4/udp_offload.c                            |  19 +--
 net/ipv6/Makefile                                 |   4 +-
 net/ipv6/fou6.c                                   | 140 +++++++++++++++++++++
 net/ipv6/ip6_gre.c                                |  95 ++++++++++++--
 net/ipv6/ip6_input.c                              |  24 +++-
 net/ipv6/ip6_offload.c                            |  22 +---
 net/ipv6/ip6_tunnel.c                             |   4 +
 net/ipv6/ip6_tunnel_core.c                        | 108 ++++++++++++++++
 net/ipv6/sit.c                                    |   4 +-
 net/ipv6/udp_offload.c                            |  13 --
 net/mpls/mpls_gso.c                               |   9 --
 net/netfilter/ipvs/ip_vs_xmit.c                   |  11 +-
 31 files changed, 511 insertions(+), 224 deletions(-)
 create mode 100644 net/ipv6/fou6.c
 create mode 100644 net/ipv6/ip6_tunnel_core.c

-- 
2.8.0.rc2
