From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 00/11] net: Convert vrf to tx hook
Date: Sat, 10 Sep 2016 12:09:51 -0700
Message-ID: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36822 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbcIJTL0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:26 -0400
Received: by mail-pf0-f177.google.com with SMTP id 128so39593805pfb.3
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The motivation for this series is that ICMP Unreachable - Fragmentation
Needed packets are not handled properly for VRFs. Specifically, the
FIB lookup in __ip_rt_update_pmtu fails so no nexthop exception is
created with the reduced MTU. As a result connections stall if packets
larger than the smallest MTU in the path are generated.

While investigating that problem I also noticed that the MSS for all
connections in a VRF is based on the VRF device's MTU and not the
route the packets ultimately go through. VRF currently uses a dst
to direct packets to the device. The first FIB lookup returns this dst
and then the lookup in the VRF driver gets the actual output route. A
side effect of this design is that the VRF dst is cached on sockets
and then used for calculations like the MSS.

This series fixes this problem by removing the hook in the FIB lookups
that returns the dst pointing to the VRF device to the VRF and always
doing the actual FIB lookup. This allows the real dst to be used
throughout the stack (for example the MSS). Packets are diverted to
the VRF device on Tx using an l3mdev hook in the output path similar to
to what is done for Rx. The end result is a simpler implementation for
VRF with fewer intrusions into the network stack and symmetrical packet
handling for Rx and Tx paths.

Comparison of netperf performance for a build without l3mdev (best case
performance), the old vrf driver and the VRF driver from this series.
Data are collected using VMs with virtio + vhost. The netperf client
runs in the VM and netserver runs in the host. 1-byte RR tests are done
as these packets exaggerate the performance hit due to the extra lookups
done for l3mdev and VRF.

Command: netperf -cC -H ${ip} -l 60 -t {TCP,UDP}_RR [-J red]

                      TCP_RR              UDP_RR
                   IPv4     IPv6       IPv4     IPv6
no l3mdev        29,996   30,601     31,638   24,336
vrf old          27,417   27,626     29,159   24,801
vrf new          28,036   28,372     30,110   24,857
l3mdev, no vrf   29,534   30,465     30,670   24,346

 * Transactions per second as reported by netperf
 * netperf modified to take a bind-to-device argument -- the -J red option

1. 'no l3mdev'      == NET_L3_MASTER_DEV is unset so code is compiled out
2. 'vrf old'        == data for existing implementation
3. 'vrf new'        == data with this series
4. 'l3mdev, no vrf' == NET_L3_MASTER_DEV is enabled but traffic is not
                       going through a VRF

About the series
- patch 1 adds the flow update (changing oif or iif to L3 master device
  and setting the flag to skip the oif check) to ipv4 and ipv6 paths just
  before hitting the rules. This catches all code paths in a single spot.

- patch 2 adds the Tx hook to push the packet to the l3mdev if relevant

- patch 3 adds some checks so the vrf device can act as a vrf-local
  loopback. These changes were not needed before since the vrf dst was
  returned from the lookup.

- patches 4 and 5 flip the ipv4 and ipv6 stacks to the tx hook leaving
  the route lookup to be the real one. The dst flip happens at the
  beginning of the L3 output path so the VRFs can have device based
  features such as netfilter, tc and tcpdump.

- patches 6-11 remove no longer needed l3mdev code

v2
- properly handle IPv6 link scope addresses

- keep the device xmit path and associated dst which is switched in by
  the l3_out hook. packets still need to go through the xmit path in
  case the user puts a qdisc on the vrf device and to allow tc rules.
  version 1 short circuited the tx handling and only covered netfilter
  and tcpdump.
  
David Ahern (11):
  net: flow: Add l3mdev flow update
  net: l3mdev: Add hook to output path
  net: l3mdev: Allow the l3mdev to be a loopback
  net: vrf: Flip IPv4 output path from FIB lookup hook to out hook
  net: vrf: Flip ipv6 output path
  net: l3mdev: remove redundant calls
  net: ipv4: Remove l3mdev_get_saddr
  net: ipv6: Remove l3mdev_get_saddr6
  net: l3mdev: Remove l3mdev_fib_oif
  net: l3mdev: remove get_rtable method
  net: flow: Remove FLOWI_FLAG_L3MDEV_SRC flag

 drivers/net/vrf.c       | 291 ++++++++++++++++++++++++------------------------
 include/net/flow.h      |   3 +-
 include/net/l3mdev.h    | 131 ++++++++++------------
 include/net/route.h     |  10 --
 net/ipv4/fib_rules.c    |   3 +
 net/ipv4/ip_output.c    |  11 +-
 net/ipv4/raw.c          |   6 -
 net/ipv4/route.c        |  24 ++--
 net/ipv4/udp.c          |   6 -
 net/ipv4/xfrm4_policy.c |   2 +-
 net/ipv6/fib6_rules.c   |   3 +
 net/ipv6/ip6_output.c   |  19 ++--
 net/ipv6/ndisc.c        |  11 +-
 net/ipv6/output_core.c  |   7 ++
 net/ipv6/raw.c          |   7 ++
 net/ipv6/route.c        |  30 +++--
 net/ipv6/tcp_ipv6.c     |   8 +-
 net/ipv6/xfrm6_policy.c |   2 +-
 net/l3mdev/l3mdev.c     | 105 +++++++----------
 19 files changed, 315 insertions(+), 364 deletions(-)

-- 
2.1.4
