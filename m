From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/8] net: Checksum offload changes - Part VI
Date: Mon, 25 Aug 2014 17:55:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251738030.5516@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:53734 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:55:48 -0400
Received: by mail-pa0-f74.google.com with SMTP id lj1so3771679pab.3
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:55:47 -0700 (PDT)
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
  and to report new verfiied checksums for use in normal path fallback.
- Add proper support to SCTP to accept CHECKSUM_UNNECESSARY to validate
  header CRC.
- Modify drivers to set skb->csum_level instead of setting
  skb->encapsulation to indicate validation of an encapsulated
  checksum on receive.

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
        12.77% CPU utilization
        9341.93 Mbps
    TCP_RR
        91.33% CPU utilization
        157/235/391 90/95/99% latencies
        1.17991e+06 tps
  Without fix:
    TCP_STREAM
        12.45% CPU utilization
        9329.12 Mbps
    TCP_RR
        90.49% CPU utilization
        154/227/361 90/95/99% latencies
        1.17893e+06 tps

* GRE without checksum with IPv4 encapsulated packets
  With fix:
    TCP_STREAM
        17.64% CPU utilization
        9316.63 Mbps
    TCP_RR
        90.67% CPU utilization
        158/233/372 90/95/99% latencies
        1.17627e+06 tps
  Without fix:
    TCP_STREAM
        18.2% CPU utilization
        9227.35 Mbps
    TCP_RR
        89.73% CPU utilization
        154/222/343 90/95/99% latencies
        1.17868e+06 tps

* VXLAN with checksum
  With fix:
    TCP_STREAM
        20.94% CPU utilization
        9094.15 Mbps
    TCP_RR
        94.48% CPU utilization
        153/248/462 90/95/99% latencies
        1.18033e+06 tps
  Without fix:
    TCP_STREAM
        20.75% CPU utilization
        9093.67 Mbps
    TCP_RR
        94.78% CPU utilization
        149/239/441 90/95/99% latencies
        1.19141e+06 tps

* VXLAN without checksum
  With fix:
    TCP_STREAM
        25.13% CPU utilization
        9081.43 Mbps
    TCP_RR
        95.04% CPU utilization
        153/238/428 90/95/99% latencies
        1.16169e+06 tps
  Without fix:
    TCP_STREAM
        23.82% CPU utilization
        9085.64 Mbps
    TCP_RR
        93.91% CPU utilization
        156/248/458 90/95/99% latencies
        1.17247e+06 Mbps
