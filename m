From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 0/5] udp: Generalize GSO for UDP tunnels
Date: Mon, 29 Sep 2014 20:22:28 -0700
Message-ID: <1412047353-28502-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58911 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbaI3DWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 23:22:46 -0400
Received: by mail-pa0-f42.google.com with SMTP id et14so956557pad.1
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 20:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set generalizes the UDP tunnel segmentation functions so
that they can work with various protocol encapsulations. The primary
change is to set the inner_protocol field in the skbuff when creating
the encapsulated packet, and then in skb_udp_tunnel_segment this data
is used to determine the function for segmenting the encapsulated
packet. The inner_protocol field is overloaded to take either an
Ethertype or IP protocol.

The inner_protocol is set on transmit using skb_set_inner_ipproto or
skb_set_inner_protocol functions. VXLAN and IP tunnels (for fou GSO)
were modified to call these.

Notes:
  - GSO for GRE/UDP where GRE checksum is enabled does not work.
    Handling this will require some special case code.
  - Software GSO now supports many varieties of encapsulation with
    SKB_GSO_UDP_TUNNEL{_CSUM}. We still need a mechanism to query
    for device support of particular combinations (I intend to
    add ndo_gso_check for that).
  - MPLS seems to be the only previous user of inner_protocol. I don't
    believe these patches can affect that. For supporting GSO with
    MPLS over UDP, the inner_protocol should be set using the
    helper functions in this patch.
  - GSO for L2TP/UDP should also be straightforward now.

v2:
  - Respin for Eric's restructuring of skbuff.

Tested GRE, IPIP, and SIT over fou as well as VLXAN. This was
done using 200 TCP_STREAMs in netperf.

 GRE
    IPv4, FOU, UDP checksum enabled
      TCP_STREAM TSO enabled on tun interface
        14.04% TX CPU utilization
        13.17% RX CPU utilization
        9211 Mbps
      TCP_STREAM TSO disabled on tun interface
        27.82% TX CPU utilization
        25.41% RX CPU utilization
        9336 Mbps
    IPv4, FOU, UDP checksum disabled
      TCP_STREAM TSO enabled on tun interface
        13.14% TX CPU utilization
        23.18% RX CPU utilization
        9277 Mbps
      TCP_STREAM TSO disabled on tun interface
        30.00% TX CPU utilization
        31.28% RX CPU utilization
        9327 Mbps

  IPIP
    FOU, UDP checksum enabled
      TCP_STREAM TSO enabled on tun interface
        15.28% TX CPU utilization
        13.92% RX CPU utilization
        9342 Mbps
      TCP_STREAM TSO disabled on tun interface
        27.82% TX CPU utilization
        25.41% RX CPU utilization
        9336 Mbps
    FOU, UDP checksum disabled
      TCP_STREAM TSO enabled on tun interface
        15.08% TX CPU utilization
        24.64% RX CPU utilization
        9226 Mbps
      TCP_STREAM TSO disabled on tun interface
        30.00% TX CPU utilization
        31.28% RX CPU utilization
        9327 Mbps

  SIT
    FOU, UDP checksum enabled
      TCP_STREAM TSO enabled on tun interface
        14.47% TX CPU utilization
        14.58% RX CPU utilization
        9106 Mbps
      TCP_STREAM TSO disabled on tun interface
        31.82% TX CPU utilization
        30.82% RX CPU utilization
        9204 Mbps
    FOU, UDP checksum disabled
      TCP_STREAM TSO enabled on tun interface
        15.70% TX CPU utilization
        27.93% RX CPU utilization
        9097 Mbps
      TCP_STREAM TSO disabled on tun interface
        33.48% TX CPU utilization
        37.36% RX CPU utilization
        9197 Mbps

   VXLAN
      TCP_STREAM TSO enabled on tun interface
        16.42% TX CPU utilization
        23.66% RX CPU utilization
        9081 Mbps
      TCP_STREAM TSO disabled on tun interface
        30.32% TX CPU utilization
        30.55% RX CPU utilization
        9185 Mbps

   Baseline (no encp, TSO and LRO enabled)
      TCP_STREAM
        11.85% TX CPU utilization
        15.13% RX CPU utilization
        9452 Mbps

Tom Herbert (5):
  udp: Generalize skb_udp_segment
  sit: Set inner IP protocol in sit
  ipip: Set inner IP protocol in ipip
  gre: Set inner protocol in v4 and v6 GRE transmit
  vxlan: Set inner protocol before transmit

 drivers/net/vxlan.c    |  4 ++++
 include/linux/skbuff.h | 26 +++++++++++++++++++++++--
 include/net/udp.h      |  3 ++-
 net/ipv4/ip_gre.c      |  2 ++
 net/ipv4/ipip.c        |  2 ++
 net/ipv4/udp_offload.c | 51 +++++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv6/ip6_gre.c     |  8 ++++++--
 net/ipv6/sit.c         |  4 ++++
 net/ipv6/udp_offload.c |  2 +-
 9 files changed, 91 insertions(+), 11 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
