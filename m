From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v4 net-next 0/8] Local Checksum Offload
Date: Fri, 5 Feb 2016 20:39:34 +0000
Message-ID: <56B50886.1050201@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:58069 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753308AbcBEUjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 15:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested with VxLAN, GRE and FOU-IPIP tunnels.  Not tested with GENEVE,
 because iproute2 doesn't support enabling checksums on GENEVE tunnels.
Also tested VxLAN with IPv6 (as both inner and outer protocol).

Changes from v3:
 * Fixed inverted checksum values introduced in v3.
 * Don't mangle zero checksums in GRE.
 * Clear skb->encapsulation in iptunnel_handle_offloads when not using
   CHECKSUM_PARTIAL, lest drivers incorrectly interpret that as a request
   for inner checksum offload.

Changes from v2:
 * Added support for IPv4 GRE.
 * Split out 'always set up for checksum offload' into its own patch.
 * Removed csum_help from iptunnel_handle_offloads.
 * Rewrote LCO callers to only fold once.
 * Simplified nocheck handling.

Changes from v1:
 * Enabled support in more encapsulation protocols.
   I think it now covers everything except GRE.
 * Wrote up some documentation covering TX checksum offload, LCO and RCO.

Edward Cree (8):
  net: local checksum offload for encapsulation
  net: udp: always set up for CHECKSUM_PARTIAL offload
  net: enable LCO for udp_tunnel_handle_offloads() users
  net: vxlan: enable local checksum offload
  fou: enable LCO in FOU and GUE
  net: gre: Implement LCO for GRE over IPv4
  net: ip_tunnel: remove 'csum_help' argument to
    iptunnel_handle_offloads
  Documentation/networking: add checksum-offloads.txt to explain LCO

 Documentation/networking/00-INDEX              |   2 +
 Documentation/networking/checksum-offloads.txt | 119 +++++++++++++++++++++++++
 drivers/net/vxlan.c                            |  18 ++--
 include/linux/skbuff.h                         |  26 ++++++
 include/net/ip_tunnels.h                       |   3 +-
 include/net/udp_tunnel.h                       |   2 +-
 net/ipv4/fou.c                                 |  14 ++-
 net/ipv4/ip_gre.c                              |  17 +++-
 net/ipv4/ip_tunnel_core.c                      |  22 ++---
 net/ipv4/ipip.c                                |   2 +-
 net/ipv4/udp.c                                 |  28 ++----
 net/ipv6/ip6_checksum.c                        |  23 ++---
 net/ipv6/sit.c                                 |   4 +-
 net/netfilter/ipvs/ip_vs_xmit.c                |   6 +-
 14 files changed, 201 insertions(+), 85 deletions(-)
 create mode 100644 Documentation/networking/checksum-offloads.txt
