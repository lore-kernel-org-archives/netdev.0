From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/7] net: Fixes to remote checksum offload and CHECKSUM_PARTIAL
Date: Tue, 10 Feb 2015 16:30:26 -0800
Message-ID: <1423614633-25042-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:44539 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbbBKAan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 19:30:43 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so1266928igb.5
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 16:30:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes a correctness problem with remote checksum
offload, clarifies the meaning of CHECKSUM_PARTIAL, and allows
remote checksum offload to set CHECKSUM_PARTIAL instead of
calling csum_partial and modifying the checksum.

Specifically:
  - In the GRO remote checksum path, restore the checksum after
    calling lower layer GRO functions. This is needed if the
    packet is forwarded off host with the Remote Checksum Offload
    option still present.
  - Clarify meaning of CHECKSUM PARTIAL in the receive path. Only
    the checksums referred to by checksum partial and any preceding
    checksums can be considered verified.
  - Fixes to UDP tunnel GRO complete. Need to set SKB_GSO_UDP_TUNNEL_*,
    SKB_GSO_TUNNEL_REMCSUM, and skb->encapsulation for forwarding
    case.
  - Infrastructure to allow setting of CHECKSUM_PARTIAL in remote
    checksum offload. This a potential performance benefit instead
    of calling csum_partial (potentially twice, once in GRO path
    and once in normal path). The downside of using CHECKSUM_PARTIAL
    and not actually writing the checksum is that we aren't verifying
    that the sender correctly wrote the pseudo checksum into the
    checksum field, or that the start/offset values actually point
    to a checksum. If the sender did not set up these fields correctly,
    a packet might be accepted locally, but not accepted by a peer
    when the packet is forwarded off host. Verifying these fields
    seems non-trivial, and because the fields can only be incorrect
    due to sender error and not corruption (outer checksum protects
    against that) we'll make use of CHECKSUM_PARTIAL the default. This
    behavior can be reverted as an netlink option on the encapsulation
    socket.
  - Change VXLAN and GUE to set CHECKSUM_PARTIAL in remote checksum
    offload by default, configuration hooks can revert to using
    csum_partial.

Testing:

I ran performance numbers using netperf TCP_STREAM and TCP_RR with 200
streams for GRE/GUE and for VXLAN. This compares before the fixes,
the fixes with not setting checksum partial in remote checksum offload,
and with the fixes setting checksum partial. The overall effect seems
be that using checksum partial is a slight performance win, perf
definitely shows a significant reduction of time in csum_partial on
the receive CPUs.

GRE/GUE
    TCP_STREAM 
      Before fixes
        9.22% TX CPU utilization
        13.57% RX CPU utilization
        9133 Mbps
      Not using checksum partial
        9.59% TX CPU utilization
        14.95% RX CPU utilization
        9132 Mbps
      Using checksum partial
        9.37% TX CPU utilization
        13.89% RX CPU utilization
        9132 Mbps
    TCP_RR
      Before fixes
        CPU utilization
        159/251/447 90/95/99% latencies
        1.1462e+06 tps
      Not using checksum partial
        92.94% CPU utilization
        158/253/445 90/95/99% latencies
        1.12988e+06 tps
      Using checksum partial
        92.78% CPU utilization
        158/250/450 90/95/99% latencies
        1.15343e+06 tps

VXLAN
    TCP_STREAM 
      Before fixes
        9.24% TX CPU utilization
        13.74% RX CPU utilization
        9093 Mbps
      Not using checksum partial
        9.95% TX CPU utilization
        14.66% RX CPU utilization
        9094 Mbps
      Using checksum partial
        10.24% TX CPU utilization
        13.32% RX CPU utilization
        9093 Mbps
    TCP_RR
      Before fixes
        92.91% CPU utilization
        151/241/437 90/95/99% latencies
        1.15939e+06 tps
      Not using checksum partial
        93.07% CPU utilization
        156/246/425 90/95/99% latencies
        1.1451e+06 tps
      Using checksum partial
        95.51% CPU utilization
        156/249/459 90/95/99% latencies
        1.17004e+06 tps

Tom Herbert (7):
  net: Fix remcsum in GRO path to not change packet
  net: Clarify meaning of CHECKSUM_PARTIAL for receive path
  udp: Set SKB_GSO_UDP_TUNNEL* in UDP GRO path
  net: Use more bit fields in napi_gro_cb
  net: Infrastructure for CHECKSUM_PARTIAL with remote checsum offload
  vxlan: Use checksum partial with remote checksum offload
  gue: Use checksum partial with remote checksum offload

 drivers/net/vxlan.c          | 38 +++++++++++++++++----------
 include/linux/netdevice.h    | 62 +++++++++++++++++++++++++++++++++++++-------
 include/linux/skbuff.h       | 32 ++++++++++++++++++-----
 include/net/checksum.h       |  5 ++++
 include/net/vxlan.h          |  4 ++-
 include/uapi/linux/fou.h     |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               |  1 +
 net/ipv4/fou.c               | 42 ++++++++++++++++++++----------
 net/ipv4/udp_offload.c       | 13 +++++++++-
 net/ipv6/udp_offload.c       |  6 ++++-
 11 files changed, 160 insertions(+), 45 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
