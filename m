From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/5] Add support for offloads with IPv6 GRE tunnels
Date: Thu, 14 Apr 2016 15:33:30 -0400
Message-ID: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34180 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcDNTdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:33:38 -0400
Received: by mail-pa0-f45.google.com with SMTP id ot11so47592900pab.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 12:33:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables the use of segmentation and checksum offloads
with IPv6 based GRE tunnels.

In order to enable this series I had to make a change to
iptunnel_handle_offloads so that it would no longer free the skb.  This was
necessary as there were multiple paths in the IPv6 GRE code that required
the skb to still be present so it could be freed.  As it turned out I
believe this actually fixes a bug that was present in FOU/GUE based tunnels
anyway.

Below is a quick breakdown of the performance gains seen with a simple
netperf test passing traffic through a ip6gretap tunnel and then an i40e
interface:

Throughput Throughput  Local Local   Result 
           Units       CPU   Service Tag    
                       Util  Demand         
                       %  
3544.93    10^6bits/s  6.30  4.656   "before"
13081.75   10^6bits/s  3.75  0.752   "after"

---

Alexander Duyck (5):
      ip_tunnel_core: iptunnel_handle_offloads returns int and doesn't free skb
      ip6gretap: Fix MTU to allow for Ethernet header
      ip6gre: Add support for basic offloads offloads excluding GSO
      GRE: Add support for GRO/GSO of IPv6 GRE traffic
      ip6gre: Add support for GSO


 drivers/net/geneve.c            |   32 ++++++---------
 drivers/net/vxlan.c             |    6 +--
 include/net/ip_tunnels.h        |    2 -
 include/net/udp_tunnel.h        |    3 -
 net/ipv4/fou.c                  |   16 ++++----
 net/ipv4/gre_offload.c          |   14 ++++++-
 net/ipv4/ip_gre.c               |   20 +++-------
 net/ipv4/ip_tunnel_core.c       |   13 ++----
 net/ipv4/ipip.c                 |    7 +--
 net/ipv6/ip6_gre.c              |   81 +++++++++++++++++++++++++++------------
 net/ipv6/sit.c                  |   14 +++----
 net/netfilter/ipvs/ip_vs_xmit.c |    6 +--
 12 files changed, 116 insertions(+), 98 deletions(-)
