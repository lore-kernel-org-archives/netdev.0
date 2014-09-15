From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Sun, 14 Sep 2014 20:07:56 -0700
Message-ID: <1410750483-3236-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35106 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbaIODIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 23:08:16 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so5250654pdb.39
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 20:08:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements foo-over-udp. The idea is that we can
encapsulate different IP protocols in UDP packets. The rationale for
this is that networking devices such as NICs and switches are usually
implemented with UDP (and TCP) specific mechanims for processing. For
instance, many switches and routers will implement a 5-tuple hash
for UDP packets to perform Equal Cost Multipath Routing (ECMP) or
RSS (on NICs). Many NICs also only provide rudimentary checksum
offload (basic TCP and UDP packet), with foo-over-udp we may be
able to leverage these NICs to offload checksums of tunneled packets
(using checksum unnecessary conversion and eventually remote checksum
offload)
 
An example encapsulation of IPIP over FOU is diagrammed below. As
illustrated, the packet overhead for FOU is the 8 byte UDP header.

+------------------+
|    IPv4 hdr      |
+------------------+
|     UDP hdr      |
+------------------+
|    IPv4 hdr      |
+------------------+
|     TCP hdr      |
+------------------+
|   TCP payload    |
+------------------+

Conceptually, FOU should be able to encapsulate any IP protocol.
The FOU header (UDP hdr.) is essentially an inserted header between the
IP header and transport, so in the case of TCP or UDP encapsulation
the pseudo header would be based on the outer IP header and its length
field must not include the UDP header.

* Receive

In this patch set the RX path for FOU is implemented in a new fou
module. To enable FOU for a particular protocol, a UDP-FOU socket is
opened to the port to receive FOU packets. The socket is mapped to the
IP protocol for the packets. The XFRM mechanism used to receive
encapsulated packets (udp_encap_rcv) for the port. Upon reception, the
UDP is removed and packet is reinjected in the stack for the
corresponding protocol associated with the socket (return -protocol
from udp_encap_rcv function).

GRO is provided with the appropriate fou_gro_receive and
fou_gro_complete. These routines need to know the encapsulation
protocol so we save that in udp_offloads structure with the port
and pass it in the napi_gro_cb structure.

* TX

This patch series implements FOU transmit encapsulation for IPIP, GRE, and
SIT. This done by some common infrastructure in ip_tunnel including an
ip_tunnel_encap to perform FOU encapsulation and common configuration
to enable FOU on IP tunnels. FOU is configured on existing tunnels and
does not create any new interfaces. The transmit and receive paths are
independent, so use of FOU may be assymetric between tunnel endpoints.

* Configuration

The fou module using netlink to configure FOU receive ports. The ip
command can be augmented with a fou subcommand to support this. e.g. to
configure FOU for IPIP on port 5555:

  ip fou add port 5555 ipproto 4

GRE, IPIP, and SIT have been modified with netlink commands to
configure use of FOU on transmit. The "ip link" command will be
augmented with an encap subcommand (for supporting various forms of
secondary encapsulation). For instance, to configure an ipip tunnel
with FOU on port 5555:

  ip link add name tun1 type ipip \
    remote 192.168.1.1 local 192.168.1.2 ttl 225 \
    encap fou encap-sport auto encap-dport 5555

* Notes
  - This patch set does not implement GSO for FOU. The UDP encapsulation
    code assumes TEB, so that will need to be reimplemented.
  - When a packet is received through FOU, the UDP header is not
    actually removed for the skbuf, pointers to transport header
    and length in the IP header are updated (like in ESP/UDP RX). A
    side effect is the IP header will now appear to have an incorrect
    checksum by an external observer (e.g. tcpdump), it will be off
    by sizeof UDP header. If necessary we could adjust the checksum 
    to compensate.
  - Performance results are below. My expectation is that FOU should
    entail little overhead (clearly there is some work to do :-) ).
    Optimizing UDP socket lookup for encapsulation ports should help
    significantly.
  - I really don't expect/want devices to have special support for any
    of this. Generic checksum offload mechanisms (NETIF_HW_CSUM
    and use of CHECKSUM_COMPLETE) should be sufficient. RSS and flow
    steering is provided by commonly implemented UDP hashing. GRO/GSO
    seem fairly comparable with LRO/TSO already.

* Performance

Ran netperf TCP_RR and TCP_STREAM tests across various configurations.
This was performed on bnx2x and I disabled TSO/GSO on sender to get
fair comparison for FOU versus non-FOU. CPU utilization is reported
for receive in TCP_STREAM.

  GRE
    IPv4, FOU, UDP checksum enabled
      TCP_STREAM
        24.85% CPU utilization
        9310.6 Mbps
      TCP_RR
        94.2% CPU utilization
        155/249/460 90/95/99% latencies
        1.17018e+06 tps
    IPv4, FOU, UDP checksum disabled
      TCP_STREAM
        31.04% CPU utilization
        9302.22 Mbps
      TCP_RR
        94.13% CPU utilization
        154/239/419 90/95/99% latencies
        1.17555e+06 tps
    IPv4, no FOU
      TCP_STREAM
        23.13% CPU utilization
        9354.58 Mbps
      TCP_RR
        90.24% CPU utilization
        156/228/360 90/95/99% latencies
        1.18169e+06 tps

  IPIP
    FOU, UDP checksum enabled
      TCP_STREAM
        24.13% CPU utilization
        9328 Mbps
      TCP_RR
        94.23
        149/237/429 90/95/99% latencies
        1.19553e+06 tps
    FOU, UDP checksum disabled
      TCP_STREAM
        29.13% CPU utilization
        9370.25 Mbps
      TCP_RR
        94.13% CPU utilization
        149/232/398 90/95/99% latencies
        1.19225e+06 tps
    No FOU
      TCP_STREAM
        10.43% CPU utilization
        5302.03 Mbps
      TCP_RR
        51.53% CPU utilization
        215/324/475 90/95/99% latencies
        864998 tps

  SIT
    FOU, UDP checksum enabled
      TCP_STREAM
        30.38% CPU utilization
        9176.76 Mbps
      TCP_RR
        96.9% CPU utilization
        170/281/581 90/95/99% latencies
        1.03372e+06 tps
    FOU, UDP checksum disabled
      TCP_STREAM
        39.6% CPU utilization
        9176.57 Mbps
      TCP_RR
        97.14% CPU utilization
        167/272/548 90/95/99% latencies
        1.03203e+06 tps
    No FOU
      TCP_STREAM
        11.2% CPU utilization
        4636.05 Mbps
      TCP_RR
        59.51% CPU utilization
        232/346/489 90/95/99% latencies
        813199 tps

v2:
  - Removed encap IP tunnel ioctls, configuration is done by netlink
    only.
  - Don't export fou_create and fou_destroy, they are currently
    intended to be called within fou module only.
  - Filled on tunnel netlink structures and functions for new values.

Tom Herbert (7):
  net: Export inet_offloads and inet6_offloads
  fou: Support for foo-over-udp RX path
  fou: Add GRO support
  net: Changes to ip_tunnel to support foo-over-udp encapsulation
  sit: TX path for sit/UDP foo-over-udp encapsulation
  ipip: TX path for IPIP/UDP foo-over-udp encapsulation
  gre: TX path for GRE/UDP foo-over-udp encapsulation

 include/linux/netdevice.h      |   3 +-
 include/net/ip_tunnels.h       |  19 ++-
 include/uapi/linux/fou.h       |  32 ++++
 include/uapi/linux/if_tunnel.h |  16 ++
 net/ipv4/Kconfig               |  10 ++
 net/ipv4/Makefile              |   1 +
 net/ipv4/fou.c                 | 369 +++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c              |  98 ++++++++++-
 net/ipv4/ip_tunnel.c           |  91 +++++++++-
 net/ipv4/ipip.c                |  86 +++++++++-
 net/ipv4/protocol.c            |   1 +
 net/ipv4/udp_offload.c         |   5 +-
 net/ipv6/protocol.c            |   1 +
 net/ipv6/sit.c                 | 107 ++++++++++--
 14 files changed, 815 insertions(+), 24 deletions(-)
 create mode 100644 include/uapi/linux/fou.h
 create mode 100644 net/ipv4/fou.c

-- 
2.1.0.rc2.206.gedb03e5
