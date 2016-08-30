From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 00/12] net: Convert vrf from dst to tx hook
Date: Tue, 30 Aug 2016 10:34:05 -0700
Message-ID: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33529 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758750AbcH3Re0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:26 -0400
Received: by mail-pa0-f45.google.com with SMTP id cy9so9570858pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The motivation for this series is that ICMP Unreachable - Fragmentation
Needed packets are not handled properly for VRFs. Specifically, the
FIB lookup in __ip_rt_update_pmtu fails so no nexthop exception is
created with the reduced MTU. As a result connections stall if packets
larger than the smallest MTU in the path are generated.

While investigating that problem I also noticed that the MSS for all
connections in a VRF is based on the VRF device's MTU and not the
interface the packets ultimately go through. VRF currently uses a dst
to direct packets to the device. The first FIB lookup returns this dst
and then the lookup in the VRF driver gets the actual output route. A
side effect of this design is that the VRF dst is cached on sockets
and then used for calculations like the MSS.

This series fixes this problem by removing the output dst that points
to the VRF and always doing the actual FIB lookup. This allows the real
dst to be cached on sockets and used for MSS. Packets are diverted to
the VRF device on Tx using an l3mdev hook in the output path similar to
to what is done for Rx.

The end result is a much smaller and faster implementation for VRFs
with fewer intrusions into the network stack, less code duplication in
the VRF driver (output processing and FIB lookups) and symmetrical
packet handling for Rx and Tx paths. The l3mdev and vrf hooks are more
tightly focused on the primary goal of controlling the table used for
lookups and a secondary goal of providing device based features for VRF
such as packet socket hooks for tcpdump and netfilter hooks.

Comparison of netperf performance for a build without l3mdev (best case
performance), the old vrf driver and the VRF driver from this series.
Data are collected using VMs with virtio + vhost. The netperf client
runs in the VM and netserver runs in the host. 1-byte RR tests are done
as these packets exaggerate the performance hit due to the extra lookups
done for l3mdev and VRF.

Command: netperf -cC -H ${ip} -l 60 -t {TCP,UDP}_RR [-J red]

                      TCP_RR             UDP_RR
                   IPv4    IPv6       IPv4   IPv6
no l3mdev         30105   31101      32436  26297
vrf old           27223   28476      28912  26122
vrf new           29001   30630      31024  26351

 * Transactions per second as reported by netperf
 * netperf modified to take a bind-to-device argument -- the -J red option

About the series
- patch 1 adds the flow update (changing oif or iif to L3 master device
  and setting the flag to skip the oif check) to ipv4 and ipv6 paths just
  before hitting the rules. This catches all code paths in a single spot.

- patch 2 adds the Tx hook to push the packet to the l3mdev if relevant

- patch 3 adds some checks so the vrf device can act as a vrf-local
  loopback. These paths were not hit before since the vrf dst was
  returned from the lookup.

- patches 4 and 5 flip the ipv4 and ipv6 stacks to the tx stack

- patches 6-12 remove no longer needed l3mdev code

David Ahern (12):
  net: flow: Add l3mdev flow update
  net: l3mdev: Add hook to output path
  net: l3mdev: Allow the l3mdev to be a loopback
  net: vrf: Flip the IPv4 path from dst to tx out hook
  net: vrf: Flip the IPv6 path from dst to tx out hook
  net: remove redundant l3mdev calls
  net: l3mdev: Remove l3mdev_get_saddr
  net: ipv6: Remove l3mdev_get_saddr6
  net: l3mdev: Remove l3mdev_get_rtable
  net: l3mdev: Remove l3mdev_get_rt6_dst
  net: l3mdev: Remove l3mdev_fib_oif
  net: flow: Remove FLOWI_FLAG_L3MDEV_SRC flag

 drivers/net/vrf.c       | 545 ++++++++++++------------------------------------
 include/net/flow.h      |   3 +-
 include/net/l3mdev.h    | 132 +++++-------
 include/net/route.h     |  10 -
 net/ipv4/fib_rules.c    |   3 +
 net/ipv4/ip_output.c    |  11 +-
 net/ipv4/raw.c          |   6 -
 net/ipv4/route.c        |  24 +--
 net/ipv4/udp.c          |   6 -
 net/ipv4/xfrm4_policy.c |   2 +-
 net/ipv6/fib6_rules.c   |   3 +
 net/ipv6/ip6_output.c   |  28 +--
 net/ipv6/ndisc.c        |  11 +-
 net/ipv6/output_core.c  |   7 +
 net/ipv6/raw.c          |   7 +
 net/ipv6/route.c        |  24 +--
 net/ipv6/tcp_ipv6.c     |   8 +-
 net/ipv6/xfrm6_policy.c |   2 +-
 net/l3mdev/l3mdev.c     | 122 ++++-------
 19 files changed, 288 insertions(+), 666 deletions(-)

-- 
2.1.4
