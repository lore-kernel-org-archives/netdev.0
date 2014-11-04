From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 0/7] gue: Remote checksum offload
Date: Tue,  4 Nov 2014 09:06:50 -0800
Message-ID: <1415120817-2105-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:48425 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaKDRHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:07:21 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so6982855igb.4
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:07:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set implements remote checksum offload for
GUE, which is a mechanism that provides checksum offload of
encapsulated packets using rudimentary offload capabilities found in
most Network Interface Card (NIC) devices. The outer header checksum
for UDP is enabled in packets and, with some additional meta
information in the GUE header, a receiver is able to deduce the
checksum to be set for an inner encapsulated packet. Effectively this
offloads the computation of the inner checksum. Enabling the outer
checksum in encapsulation has the additional advantage that it covers
more of the packet than the inner checksum including the encapsulation
headers.

Remote checksum offload is described in:
http://tools.ietf.org/html/draft-herbert-remotecsumoffload-01

The GUE transmit and receive paths are modified to support the
remote checksum offload option. The option contains a checksum
offset and checksum start which are directly derived from values
set in stack when doing CHECKSUM_PARTIAL. On receipt of the option, the
operation is to calculate the packet checksum from "start" to end of
the packet (normally derived for checksum complete), and then set 
the resultant value at checksum "offset" (the checksum field has
already been primed with the pseudo header). This emulates a NIC
that implements NETIF_F_HW_CSUM.

The primary purpose of this feature is to eliminate cost of performing
checksum calculation over a packet when encpasulating.

In this patch set:
  - Move fou_build_header into fou.c and split it into a couple of
    functions
  - Enable offloading of outer UDP checksum in encapsulation
  - Change udp_offload to support remote checksum offload, includes
    new GSO type and ensuring encapsulated layers (TCP) doesn't try to
    set a checksum covered by RCO
  - TX support for RCO with GUE. This is configured through ip_tunnel
    and set the option on transmit when packet being encapsulated is
    CHECKSUM_PARTIAL
  - RX support for RCO with GUE for normal and GRO paths. Includes
    resolving the offloaded checksum

v2:
  Address comments from davem: Move accounting for private option
  field in gue_encap_hlen to patch in which we add the remote checksum
  offload option.

Testing:

I ran performance numbers using netperf TCP_STREAM and TCP_RR with 200
streams, comparing GUE with and without remote checksum offload (doing
checksum-unnecessary to complete conversion in both cases). These
were run on mlnx4 and bnx2x. Some mlnx4 results are below.

GRE/GUE
    TCP_STREAM 
      IPv4, with remote checksum offload
        9.71% TX CPU utilization
        7.42% RX CPU utilization
        36380 Mbps
      IPv4, without remote checksum offload
        12.40% TX CPU utilization
        7.36% RX CPU utilization
        36591 Mbps
    TCP_RR
      IPv4, with remote checksum offload
        77.79% CPU utilization
	91/144/216 90/95/99% latencies
        1.95127e+06 tps
      IPv4, without remote checksum offload
        78.70% CPU utilization
        89/152/297 90/95/99% latencies
        1.95458e+06 tps


IPIP/GUE
    TCP_STREAM 
      With remote checksum offload
        10.30% TX CPU utilization
        7.43% RX CPU utilization
        36486 Mbps
      Without remote checksum offload
        12.47% TX CPU utilization
        7.49% RX CPU utilization
        36694 Mbps
    TCP_RR
      With remote checksum offload
        77.80% CPU utilization
        87/153/270 90/95/99% latencies
        1.98735e+06 tps
      Without remote checksum offload
        77.98% CPU utilization
        87/150/287 90/95/99% latencies
        1.98737e+06 tps

SIT/GUE
    TCP_STREAM 
      With remote checksum offload
        9.68% TX CPU utilization
        7.36% RX CPU utilization
        35971 Mbps
      Without remote checksum offload
        12.95% TX CPU utilization
        8.04% RX CPU utilization
        36177 Mbps
    TCP_RR
      With remote checksum offload
        79.32% CPU utilization
        94/158/295 90/95/99% latencies
        1.88842e+06 tps
      Without remote checksum offload
        80.23% CPU utilization
        94/149/226 90/95/99% latencies
        1.90338e+06 tps

VXLAN
    TCP_STREAM 
        35.03% TX CPU utilization
        20.85% RX CPU utilization
        36230 Mbps
    TCP_RR
        77.36% CPU utilization
        84/146/270 90/95/99% latencies
        2.08063e+06 tps

We can also look at CPU time in csum_partial using perf (with bnx2x
setup). For GRE with TCP_STREAM I see:

    With remote checksum offload
        0.33% TX
        1.81% RX
    Without remote checksum offload
        6.00% TX
        0.51% RX

I suspect the fact that time in csum_partial noticably increases
with remote checksum offload for RX is due to taking the cache miss on
the encapsulated header in that function. By similar reasoning, if on
the TX side the packet were not in cache (say we did a splice from a
file whose data was never touched by the CPU) the CPU savings for TX
would probably be more pronounced.

Tom Herbert (7):
  net: Move fou_build_header into fou.c and refactor
  udp: Offload outer UDP tunnel csum if available
  gue: Add infrastructure for flags and options
  udp: Changes to udp_offload to support remote checksum offload
  gue: Protocol constants for remote checksum offload
  gue: TX support for using remote checksum offload option
  gue: Receive side of remote checksum offload

 include/linux/netdev_features.h |   4 +-
 include/linux/netdevice.h       |   1 +
 include/linux/skbuff.h          |   4 +-
 include/net/fou.h               |  38 ++++
 include/net/gue.h               | 103 ++++++++++-
 include/uapi/linux/if_tunnel.h  |   1 +
 net/core/skbuff.c               |   4 +-
 net/ipv4/Kconfig                |   9 +
 net/ipv4/af_inet.c              |   1 +
 net/ipv4/fou.c                  | 388 +++++++++++++++++++++++++++++++++++-----
 net/ipv4/ip_tunnel.c            |  61 ++-----
 net/ipv4/tcp_offload.c          |   1 +
 net/ipv4/udp_offload.c          |  66 +++++--
 net/ipv6/ip6_offload.c          |   1 +
 net/ipv6/udp_offload.c          |   1 +
 15 files changed, 565 insertions(+), 118 deletions(-)
 create mode 100644 include/net/fou.h

-- 
2.1.0.rc2.206.gedb03e5
