From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 0/6] net: Checksum offload changes - Part V
Date: Fri, 22 Aug 2014 13:33:38 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408221315240.1209@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:39888 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbaHVUdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:33:40 -0400
Received: by mail-ie0-f202.google.com with SMTP id rl12so1020983iec.3
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:33:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on overhauling RX checksum offload. Goals of this effort
are:

- Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
- Preserve CHECKSUM_COMPLETE through encapsulation layers
- Don't do skb_checksum more than once per packet
- Unify GRO and non-GRO csum verification as much as possible
- Unify the checksum functions (checksum_init)
- Simplify code

What is in this fifth patch set:

- Added GRO checksum validation functions
- Call the GRO validations functions from TCP and GRE gro_receive
- Perform checksum verification in the UDP gro_receive path using
  GRO functions and add support for gro_receive in UDP6

Changes in V2:

- Change ip_summed to CHECKSUM_UNNECESSARY instead of moving it
  to CHECKSUM_COMPLETE from GRO checksum validation. This avoids
  performance penalty in checksumming bytes which are before the header
  GRO is at.

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)

----

Test results with this patch set are below. I did not notice any
performace regression.

Tests run:
   TCP_STREAM: super_netperf with 200 streams
   TCP_RR: super_netperf with 200 streams and -r 1,1

Device bnx2x (10Gbps):
   No GRE RSS hash (RX interrupts occur on one core)
   UDP RSS port hashing enabled.

* GRE with checksum with IPv4 encapsulated packets
  With fix:
    TCP_STREAM
        9.91% CPU utilization
        5163.78 Mbps
    TCP_RR
        50.64% CPU utilization
        219/347/502 90/95/99% latencies
        834103 tps
  Without fix:
    TCP_STREAM
        10.05% CPU utilization
        5186.22 tps
    TCP_RR
        49.70% CPU utilization
        227/338/486 90/95/99% latencies
        813450 tps

* GRE without checksum with IPv4 encapsulated packets
  With fix:
    TCP_STREAM
        10.18% CPU utilization
        5159 Mbps
    TCP_RR
        51.86% CPU utilization
        214/325/471 90/95/99% latencies
        865943 tps
  Without fix:
    TCP_STREAM
        10.26% CPU utilization
        5307.87 Mbps
    TCP_RR
        50.59% CPU utilization
        224/325/476 90/95/99% latencies
        846429 tps

*** Simulate device returns CHECKSUM_COMPLETE

* VXLAN with checksum
  With fix:
    TCP_STREAM
        13.03% CPU utilization
        9093.9 Mbps
    TCP_RR
        95.96% CPU utilization
        161/259/474 90/95/99% latencies
        1.14806e+06 tps
  Without fix:
    TCP_STREAM
        13.59% CPU utilization
        9093.97 Mbps
    TCP_RR
        93.95% CPU utilization
        160/259/484 90/95/99% latencies
        1.10262e+06 tps

* VXLAN without checksum
  With fix:
    TCP_STREAM
        13.28% CPU utilization
        9093.87 Mbps
    TCP_RR
        95.04% CPU utilization
        155/246/439 90/95/99% latencies
        1.15e+06 tps
  Without fix:
    TCP_STREAM
        13.37% CPU utilization
        9178.45 Mbps
    TCP_RR
        93.74% CPU utilization
        161/257/469 90/95/99% latencies
        1.1068e+06 Mbps
