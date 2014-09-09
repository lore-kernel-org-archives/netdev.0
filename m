From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/3] net: enable GRO for IPIP and SIT
Date: Tue,  9 Sep 2014 11:23:13 -0700
Message-ID: <1410286996-302-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:45687 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbaIISXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:23:34 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so9474537pde.33
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:23:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets populates the IPIP and SIT offload structures with
gro_receive and gro_complete functions. This enables use of GRO
for these. Also, fixed a problem in IPv6 where we were not properly
initializing flush_id.

Peformance results are below. Note that these tests were done on bnx2x
which doesn't provide RX checksum offload of IPIP or SIT (i.e. does
not give CHEKCSUM_COMPLETE). Also, we don't get 4-tuple hash for RSS
only 2-tuple in this case so all the packets between two hosts are
winding up on the same queue. Net result is the interrupting CPU is
the bottleneck in GRO (checksumming every packet there).

Testing:

netperf TCP_STREAM between two hosts using bnx2x.

* Before fix

IPIP
  1 connection
    6.53% CPU utilization
    6544.71 Mbps
  20 connections
    13.79% CPU utilization
    9284.54 Mbps

SIT
  1 connection
    6.68% CPU utilization
    5653.36 Mbps
  20 connections
    18.88% CPU utilization
    9154.61 Mbps

* After fix

IPIP
  1 connection
    5.73% CPU utilization
    9279.53 Mbps
  20 connections
    7.14% CPU utilization
    7279.35 Mbps

SIT
  1 connection
    2.95% CPU utilization
    9143.36 Mbps
  20 connections
    7.09% CPU utilization
    6255.3 Mbps

Tom Herbert (3):
  ipv6: Clear flush_id to make GRO work
  ipip: Add gro callbacks to ipip offload
  sit: Add gro callbacks to sit_offload

 net/ipv4/af_inet.c     | 2 ++
 net/ipv6/ip6_offload.c | 5 +++++
 2 files changed, 7 insertions(+)

-- 
2.1.0.rc2.206.gedb03e5
