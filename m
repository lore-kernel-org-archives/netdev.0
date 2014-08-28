From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 0/8] net: Checksum offload changes - Part VI
Date: Wed, 27 Aug 2014 21:26:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272114490.505@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:38721 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaH1Efh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 00:35:37 -0400
Received: by mail-oi0-f73.google.com with SMTP id u20so215295oif.0
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 21:35:36 -0700 (PDT)
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

What is in this sixth patch set:

- Clarify the specific requirements of devices returning
  CHECKSUM_UNNECESSARY (comments in skbuff.h).
- Add csum_level field to skbuff. This is used to express how
  many checksums are covered by CHECKSUM_UNNECESSARY (stores n - 1).
- Change __skb_checksum_validate_needed to "consume" each checksum
  as indicated by csum_level as layers of the the packet are parsed.
- Remove skb_pop_rcv_encapsulation, no longer needed in the new
  csum_level model.
- Allow GRO path to "consume" checksums provided in CHECKSUM_UNNECESSARY
  and to report new verfied checksums for use in normal path fallback.
- Add proper support to SCTP to accept CHECKSUM_UNNECESSARY to validate
  header CRC.
- Modify drivers to set skb->csum_level instead of setting
  skb->encapsulation to indicate validation of an encapsulated
  checksum on receive.

v2:

Allocate a new 16 bits for flags in skbuff.

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)

----

Test results with this patch set are below. I did not see any
obvious performace regression.

Tests run:
   TCP_STREAM: super_netperf with 200 streams
   TCP_RR: super_netperf with 200 streams and -r 1,1

Device bnx2x (10Gbps):
   No GRE RSS hash (RX interrupts occur on one core)
   UDP RSS port hashing enabled.

* GRE with checksum with IPv4 encapsulated packets
  With fix:
    TCP_STREAM
        12.56% CPU utilization
        9341.21 Mbps
    TCP_RR
        90.96% CPU utilization
        155/230/367 90/95/99% latencies
        1.18032e+06 tps
  Without fix:
    TCP_STREAM
        12.09% CPU utilization
        9330.38 Mbps
    TCP_RR
        91.91% CPU utilization
        155/231/369 90/95/99% latencies
        1.17714e+06 tps

* GRE without checksum with IPv4 encapsulated packets
  With fix:
    TCP_STREAM
        18.53% CPU utilization
        9320.57 Mbps
    TCP_RR
        89.23% CPU utilization
        157/229/365 90/95/99% latencies
        1.17998e+06 tps
  Without fix:
    TCP_STREAM
        18.4% CPU utilization
        9240.72 Mbps
    TCP_RR
        91.61% CPU utilization
        158/235/370 90/95/99% latencies
        1.17375e+06 tps

* VXLAN with checksum
  With fix:
    TCP_STREAM
        19.90% CPU utilization
        9094.12 Mbps
    TCP_RR
        94.62% CPU utilization
        152/245/459 90/95/99% latencies
        1.18346e+06 tps
  Without fix:
    TCP_STREAM
        20.68% CPU utilization
        9175.63 Mbps
    TCP_RR
        95.15% CPU utilization
        151/243/459 90/95/99% latencies
        1.17244e+06 tps
* VXLAN with checksum
  With fix:
    TCP_STREAM
        23.97% CPU utilization
        9086.91 Mbps
    TCP_RR
        92.45% CPU utilization
        154/241/436 90/95/99% latencies
        1.17305e+06 tps
  Without fix:
    TCP_STREAM
        24.02% CPU utilization
        9084.82 Mbps
    TCP_RR
        94.1% CPU utilization
        154/244/449 90/95/99% latencies
        1.16107e+06 tps
