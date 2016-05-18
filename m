From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v6 tunneling
Date: Wed, 18 May 2016 09:06:08 -0700
Message-ID: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:63715 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751899AbcERQGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:06:32 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4IG2SfA005279
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 230sbg0mua-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:31 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 7be080d41d1211e689100002c99293a0-3fbf2c50 for <netdev@vger.kernel.org>;	Wed,
 18 May 2016 09:06:30 -0700
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
  - Don't define GSO types specifically for IP6IP6 and IP4IP6, above
    fix makes that unnecessary
  - Don't bother clearing encapsulation flag in UDP tunnel segment
    (another item suggested by Alexander).

v3:
  - Address some minor comments from Alexander

v4:
  - Rebase on changes to fix IP TX tunnels
  - Fix MTU issues in ip4ip6, ip6ip6
  - Add test data for above

v5:
  - Address feedback from Shmulik Ladkani regarding extension header
    code that does not return next header but in instead relies
    on returning value via nhoff. Solution here is to fix EH
    processing to return nexthdr value.
  - Refactored IPv4 encaps so that we won't need to create
    a ip6_tunnel_core.c when adding encap support IPv6.

v6:
  - Fix build issues with regard to new GSO constants
  - FIx MTU calculation issues ip6_tunnel.c pointed out byt ALex
  - Add encap_hlen into headroom for GREv6 to work with FOU/GUE

v7:
  - Added skb_set_inner_ipproto to ip4ip6 and ip6ip6
  - Clarified max_headroom in ip6_tnl_xmit
  - Set features for IPv6 tunnels
  - Other cleanup suggested by Alexander
  - Above fixes throughput performance issues in ip4ip6 and ip6ip6,
    updated test results to reflect that

Tested: Various cases of IP tunnels with netperf TCP_STREAM and TCP_RR.

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
	5307 Mbps
      200 TCP_RR
	498981 tps
	388/498/631 90/95/99% latencies
	19.75% CPU utilization (1 CPU saturated)

     - IP6IP6/GUE with RCO
      1 TCP_STREAM
	5575 Mbps
      200 TCP_RR
	1233818 tps
	143/244/451 90/95/99% latencies
	87.57 CPU utilization

     - IP4IP6
      1 TCP_STREAM
	5235 Mbps
      200 TCP_RR
	763774 tps
	250/318/466 90/95/99% latencies
	35.25% CPU utilization (1 CPU saturated)

     - IP4IP6/GUE with RCO
      1 TCP_STREAM
	5337 Mbps
      200 TCP_RR
	1196385 tps
	148/251/460 90/95/99% latencies
	87.56 CPU utilization

     - GRE with keyid
      200 TCP_RR
	744173 tps
	258/332/461 90/95/99% latencies
	34.59% CPU utilization (1 CPU saturated)
      

Tom Herbert (16):
  gso: Remove arbitrary checks for unsupported GSO
  net: define gso types for IPx over IPv4 and IPv6
  ipv6: Fix nexthdr for reinjection
  ipv6: Change "final" protocol processing for encapsulation
  net: Cleanup encap items in ip_tunnels.h
  fou: Call setup_udp_tunnel_sock
  fou: Split out {fou,gue}_build_header
  fou: Support IPv6 in fou
  ip6_tun: Add infrastructure for doing encapsulation
  fou: Add encap ops for IPv6 tunnels
  ip6_gre: Add support for fou/gue encapsulation
  ip6_tunnel: Add support for fou/gue encapsulation
  ipv6: Set features for IPv6 tunnels
  ip6ip6: Support for GSO/GRO
  ip4ip6: Support for GSO/GRO
  ipv6: Don't reset inner headers in ip6_tnl_xmit

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   5 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c       |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   3 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |   3 +-
 drivers/net/ethernet/intel/igbvf/netdev.c         |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   3 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   3 +-
 include/linux/netdev_features.h                   |  12 +-
 include/linux/netdevice.h                         |   4 +-
 include/linux/skbuff.h                            |   4 +-
 include/net/fou.h                                 |  10 +-
 include/net/inet_common.h                         |   5 +
 include/net/ip6_tunnel.h                          |  58 +++++++
 include/net/ip_tunnels.h                          |  76 +++++++--
 net/core/ethtool.c                                |   4 +-
 net/ipv4/af_inet.c                                |  32 +---
 net/ipv4/fou.c                                    | 144 +++++++++-------
 net/ipv4/gre_offload.c                            |  14 --
 net/ipv4/ip_tunnel.c                              |  45 -----
 net/ipv4/ip_tunnel_core.c                         |   9 +
 net/ipv4/ipip.c                                   |   2 +-
 net/ipv4/tcp_offload.c                            |  19 ---
 net/ipv4/udp_offload.c                            |  10 --
 net/ipv6/Makefile                                 |   1 +
 net/ipv6/fou6.c                                   | 140 ++++++++++++++++
 net/ipv6/ip6_gre.c                                |  79 ++++++++-
 net/ipv6/ip6_input.c                              |  33 +++-
 net/ipv6/ip6_offload.c                            |  77 ++++++---
 net/ipv6/ip6_tunnel.c                             | 190 ++++++++++++++++++++--
 net/ipv6/sit.c                                    |   4 +-
 net/ipv6/udp_offload.c                            |  13 --
 net/mpls/mpls_gso.c                               |  11 +-
 net/netfilter/ipvs/ip_vs_xmit.c                   |  17 +-
 36 files changed, 737 insertions(+), 310 deletions(-)
 create mode 100644 net/ipv6/fou6.c

-- 
2.8.0.rc2
