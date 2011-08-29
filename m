From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ixgbe: Add support for setting CC bit when SR-IOV is enabled
Date: Mon, 29 Aug 2011 01:40:59 -0700
Message-ID: <1314607268-26958-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36890 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab1H2IlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 04:41:14 -0400
In-Reply-To: <1314607268-26958-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the CC bit in the descriptor is set when
SR-IOV is enabled.  This is needed in order to support offloading
functionality when passing traffic over the internal TX switch.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 ++++++++++++++-
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index dc3b12e..58482fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -97,7 +97,8 @@
 #define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 4)
 #define IXGBE_TX_FLAGS_FCOE		(u32)(1 << 5)
 #define IXGBE_TX_FLAGS_FSO		(u32)(1 << 6)
-#define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 7)
+#define IXGBE_TX_FLAGS_TXSW		(u32)(1 << 7)
+#define IXGBE_TX_FLAGS_MAPPED_AS_PAGE	(u32)(1 << 8)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bb54d3d..d587967 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6295,7 +6295,8 @@ static bool ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	u32 type_tucmd = 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-	    if (!(tx_flags & IXGBE_TX_FLAGS_HW_VLAN))
+	    if (!(tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
+		!(tx_flags & IXGBE_TX_FLAGS_TXSW))
 			return false;
 	} else {
 		u8 l4_hdr = 0;
@@ -6398,6 +6399,13 @@ static __le32 ixgbe_tx_olinfo_status(u32 tx_flags, unsigned int paylen)
 					    (1 << IXGBE_ADVTXD_IDX_SHIFT));
 
 #endif
+	/*
+	 * Check Context must be set if Tx switch is enabled, which it
+	 * always is for case where virtual functions are running
+	 */
+	if (tx_flags & IXGBE_TX_FLAGS_TXSW)
+		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_CC);
+
 	return olinfo_status;
 }
 
@@ -6732,6 +6740,11 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
+#ifdef CONFIG_PCI_IOV
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		tx_flags |= IXGBE_TX_FLAGS_TXSW;
+
+#endif
 	/* if we have a HW VLAN tag being added default to the HW one */
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT;
-- 
1.7.6
