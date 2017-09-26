From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH v2 0/2] Introduce MPLS over GRE
Date: Tue, 26 Sep 2017 11:22:49 +0200
Message-ID: <cover.1506416988.git.amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, equinox@diac24.net
To: netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:44866 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968431AbdIZJXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 05:23:10 -0400
Received: by mail-wm0-f45.google.com with SMTP id m127so14699340wmm.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 02:23:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces the MPLS over GRE encapsulation (RFC 4023).

Various applications of MPLS make use of label stacks with multiple
entries.  In some cases, it is possible to replace the top label of
the stack with an IP-based encapsulation, thereby, it is possible for
two LSRs that are adjacent on an LSP to be separated by an IP network,
even if that IP network does not provide MPLS.

Changes in v2:
  - wrap ip tunnel functions under ifdef in mpls file.
  - fix indentation.
  - check return code.

An example of configuration:


         node1                LER1                       LER2                node2
        +-----+             +------+                   +------+             +-----+
        |     |             |      |                   |      |             |     |
        |     |             |      |p3  GRE tunnel   p4|      |             |     |
        |     |p1         p2|      +-------------------+      |p5         p6|     |
        |     +-------------+      +-------------------+      +------------+|     |
        |     |10.100.0.0/24|      |                   |      |10.200.0.0/24|     |
        |     |fd00:100::/64|      |  10.125.0.0/24    |      |fd00:200::/64|     |
        |     |             |      |  fd00:125::/64    |      |             |     |
        |     |             |      |                   |      |             |     |
        |     |             |      |                   |      |             |     |
        |     |             |      |                   |      |             |     |
        |     |             |      |                   |      |             |     |
        +-----+             +------+                   +------+             +-----+


		###	node1	###

ip link set p1 up
ip addr add 10.100.0.1/24 dev p1

		###	LER1	###

ip link set p2 up
ip addr add 10.100.0.2/24 dev p2

ip link set p3 up
ip addr add 10.125.0.1/24 dev p3

modprobe mpls_router
sysctl -w net.mpls.conf.p2.input=1
sysctl -w net.mpls.conf.p3.input=1
sysctl -w net.mpls.platform_labels=1000

ip link add gre1 type gre ttl 64 local 10.125.0.1 remote 10.125.0.2 dev p3
ip link set dev gre1 up

ip -M route add 111 as 222 dev gre1
ip -M route add 555 as 666 via inet 10.100.0.1 dev p2

		###	LER2	###

ip link set p5 up
ip addr add 10.200.0.2/24 dev p5

ip link set p4 up
ip addr add 10.125.0.2/24 dev p4

modprobe mpls_router
sysctl -w net.mpls.conf.p4.input=1
sysctl -w net.mpls.conf.p5.input=1
sysctl -w net.mpls.platform_labels=1000

ip link add gre1 type gre ttl 64 local 10.125.0.2 remote 10.125.0.1 dev p4
ip link set dev gre1 up

ip -M route add 444 as 555 dev gre1
ip -M route add 222 as 333 via inet 10.200.0.1 dev p5

		###	node2	###

ip link set p6 up
ip addr add 10.200.0.1/24 dev p6


Now using this scapy to forge and send packets from the port p1 of node1:

p = Ether(src='de:ed:01:0c:41:09', dst='de:ed:01:2f:3b:ba')
p /= MPLS(s=1, ttl=64, label=111)/Raw(load='\xde')
sendp(p, iface="p1", count=20, inter=0.1)

Amine Kherbouche (2):
  mpls: expose stack entry function
  ip_tunnel: add mpls over gre encapsulation

 include/linux/mpls.h           |  3 +++
 include/net/gre.h              |  3 +++
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/gre_demux.c           | 22 +++++++++++++++++++++
 net/ipv4/ip_gre.c              |  9 +++++++++
 net/ipv6/ip6_gre.c             |  7 +++++++
 net/mpls/af_mpls.c             | 45 ++++++++++++++++++++++++++++++++++++++++--
 7 files changed, 88 insertions(+), 2 deletions(-)

-- 
2.1.4
