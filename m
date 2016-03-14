From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] ixgbe: Avoid unaligned access in ixgbe_atr() for
 LLC packets
Date: Mon, 14 Mar 2016 11:32:16 -0400
Message-ID: <20160314153216.GF5084@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19921 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933015AbcCNPcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 11:32:23 -0400
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
examining skb->protocol.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4d6223d..c3885a8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7602,6 +7602,11 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 #endif /* CONFIG_IXGBE_VXLAN */
 	}
 
+	if (skb->protocol != htons(ETH_P_IP) &&
+	    skb->protocol != htons(ETH_P_IPV6) &&
+	    skb->protocol != htons(ETH_P_ARP))
+		return;
+
 	/* Currently only IPv4/IPv6 with TCP is supported */
 	switch (hdr.ipv4->version) {
 	case IPVERSION:
-- 
1.7.1
