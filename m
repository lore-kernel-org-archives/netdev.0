From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/4] net: Generic UDP Encapsulation
Date: Wed,  1 Oct 2014 21:46:35 -0700
Message-ID: <1412225199-24942-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61607 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbaJBEqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:46:51 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so1393027pdb.21
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:46:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic UDP Encapsulation (GUE) is UDP encapsulation protocol that
encapsulates packets of various IP protocols. The GUE protocol is
described in http://tools.ietf.org/html/draft-herbert-gue-01.

The receive path of GUE is implemented in the FOU over UDP module (FOU).
This includes a UDP encap receive function for GUE as well as GUE
specific GRO functions. Management and configuration of GUE ports shares
most of the same code with FOU.

For the transmit path, the previous FOU support for IPIP, sit, and GRE
was simply extended for GUE (when GUE is enabled insert the GUE
header on transmit in addition to UDP header inserted for FOU).

Semantically GUE is the same as FOU in that the encapsulation (UDP
and GUE headers) that are inserted on transmission and removed on
reception so that IP packet is processed with the inner header.

This patch set includes:
 - Some fixes to FOU, removal of IPv4,v6 specific GRO functions
 - Support to configure a GUE receive port
 - Implementation of GUE receive path (normal and GRO)
 - Additions to ip_tunnel netlink to configure GUE
 - GUE header inserion in ip_tunnel transmit path

Follow on patches will include

Testng:

I ran performance numbers using netperf TCP_RR with 200 streams,
comparing encapsulation without GUE, encapsulation with GUE, and
encapsulation with FOU.

 GRE
    TCP_STREAM
      IPv4, FOU, UDP checksum enabled
        14.04% TX CPU utilization
        13.17% RX CPU utilization
        9211 Mbps
      IPv4, GUE, UDP checksum enabled
        14.99% TX CPU utilization
        13.79% RX CPU utilization
        9185 Mbps
      IPv4, FOU, UDP checksum disabled
        13.14% TX CPU utilization
        23.18% RX CPU utilization
        9277 Mbps
      IPv4, GUE, UDP checksum disabled
        13.66% TX CPU utilization
        23.57% RX CPU utilization
        9184 Mbps
    TCP_RR
      IPv4, FOU, UDP checksum enabled
        94.2% CPU utilization
        155/249/460 90/95/99% latencies
        1.17018e+06 tps
      IPv4, GUE, UDP checksum enabled
        93.9% CPU utilization
        158/253/472 90/95/99% latencies
        1.15045e+06 tps


  IPIP
    TCP_STREAM
      FOU, UDP checksum enabled
        15.28% TX CPU utilization
        13.92% RX CPU utilization
        9342 Mbps
      GUE, UDP checksum enabled
        13.99% TX CPU utilization
        13.34% RX CPU utilization
        9210 Mbps
      FOU, UDP checksum disabled
        15.08% TX CPU utilization
        24.64% RX CPU utilization
        9226 Mbps
      GUE, UDP checksum disabled
        15.90% TX CPU utilization
        24.77% RX CPU utilization
        9197 Mbps
    TCP_RR
      FOU, UDP checksum enabled
        94.23% CPU utilization
        149/237/429 90/95/99% latencies
        1.19553e+06 tps
      GUE, UDP checksum enabled
        93.75% CPU utilization
        152/243/442 90/95/99% latencies
        1.17027e+06 tps

  SIT
    TCP_STREAM
      FOU, UDP checksum enabled
        14.47% TX CPU utilization
        14.58% RX CPU utilization
        9106 Mbps
      GUE, UDP checksum enabled
        15.09% TX CPU utilization
        14.84% RX CPU utilization
        9080 Mbps
      FOU, UDP checksum disabled
        15.70% TX CPU utilization
        27.93% RX CPU utilization
        9097 Mbps
      GUE, UDP checksum disabled
        15.04% TX CPU utilization
        27.54% RX CPU utilization
        9073 Mbps
    TCP_RR
      FOU, UDP checksum enabled
        96.9% CPU utilization
        170/281/581 90/95/99% latencies
        1.03372e+06 tps
      GUE, UDP checksum enabled
        97.16% CPU utilization
        172/286/576 90/95/99% latencies
        1.00469e+06 tps

Tom Herbert (4):
  ip_tunnel: Account for secondary encapsulation header in max_headroom
  fou: eliminate IPv4,v6 specific GRO functions
  gue: Receive side for Generic UDP Encapsulation
  ip_tunnel: Add GUE support

 include/linux/netdevice.h      |   3 +
 include/uapi/linux/fou.h       |   7 ++
 include/uapi/linux/if_tunnel.h |   1 +
 net/ipv4/fou.c                 | 224 ++++++++++++++++++++++++++++++++++-------
 net/ipv4/ip_tunnel.c           |  15 ++-
 net/ipv4/udp_offload.c         |   1 +
 net/ipv6/udp_offload.c         |   1 +
 7 files changed, 212 insertions(+), 40 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
