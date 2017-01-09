From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] net: optimize ICMP-reply code path
Date: Mon, 09 Jan 2017 16:03:59 +0100
Message-ID: <20170109150246.30215.63371.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161257AbdAIPEB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 10:04:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is optimizing the ICMP-reply code path, for ICMP packets
that gets rate limited. A remote party can easily trigger this code
path by sending packets to port number with no listening service.

Generally the patchset moves the sysctl_icmp_msgs_per_sec ratelimit
checking to earlier in the code path and removes an allocation.


Use-case: The specific case I experienced this being a bottleneck is,
sending UDP packets to a port with no listener, which obviously result
in kernel replying with ICMP Destination Unreachable (type:3), Port
Unreachable (code:3), which cause the bottleneck.

 After Eric and Paolo optimized the UDP socket code, the kernels PPS
processing capabilities is lower for no-listen ports, than normal UDP
sockets.  This is bad for capacity planning when restarting a service.

UDP no-listen benchmark 8xCPUs using pktgen_sample04_many_flows.sh:
 Baseline: 6.6 Mpps
 Patch:   14.7 Mpps
Driver mlx5 at 50Gbit/s.

---

Jesper Dangaard Brouer (3):
      Revert "icmp: avoid allocating large struct on stack"
      net: reduce cycles spend on ICMP replies that gets rate limited
      net: for rate-limited ICMP replies save one atomic operation


 net/ipv4/icmp.c |  125 +++++++++++++++++++++++++++++++++----------------------
 net/ipv6/icmp.c |   68 +++++++++++++++++++++---------
 2 files changed, 123 insertions(+), 70 deletions(-)
