From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH V3 net-next] ixgbe: Avoid unaligned access in ixgbe_atr() for
 LLC packets
Date: Mon, 14 Mar 2016 15:47:16 -0400
Message-ID: <20160314194716.GM5084@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	sowmini.varadhan@oracle.com
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35652 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbcCNTr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:47:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For LLC based protocols like lldp, stp etc., the ethernet header
is an 802.3 header with a h_proto that is not 0x800, 0x86dd, or
even 0x806.  In this world, the skb_network_header() points at
the DSAP/SSAP/..  and is not likely to be NET_IP_ALIGNed in
ixgbe_atr().

With LLC, drivers are not likely to correctly find IPVERSION,
or "6", at hdr.ipv4->version, but will instead just needlessly
trigger an unaligned access. (IPv4/IPv6 over LLC is almost never
implemented).

The unaligned access is thus avoidable: bail out quickly after
examining skb->protocol. The only Ethernet II protocols handled
are IPv4 and IPv6

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: Alexander Duyck comments
v3: filter out all ethertypes  except for Ethernet II and (IPv4 or IPv6)

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4d6223d..aeab2fe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7574,6 +7574,11 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	if (!ring->atr_sample_rate)
 		return;
 
+	/* this function only handles IPv4 or IPv6 */
+	if (first->protocol != htons(ETH_P_IP) &&
+	    first->protocol != htons(ETH_P_IPV6))
+		return;
+
 	ring->atr_count++;
 
 	/* snag network header to get L4 type and address */
-- 
1.7.1
