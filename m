From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 9/9] ixgbe: Rewrite code related to configuring IFCS bit in Tx descriptor
Date: Thu, 16 Aug 2012 15:48:38 -0700
Message-ID: <1345157318-23731-10-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12017 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756867Ab2HPWsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:53 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updates the code related to configuring the transmit frame
checksum.  Specifically I have updated the code so that we can only skip
inserting the checksum in the case that we are not performing some other
offload that will modify the frame data.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 16 ++++++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index fd2bc69..bffcf1f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -107,6 +107,7 @@
 #define IXGBE_TX_FLAGS_FSO		(u32)(1 << 6)
 #define IXGBE_TX_FLAGS_TXSW		(u32)(1 << 7)
 #define IXGBE_TX_FLAGS_TSTAMP		(u32)(1 << 8)
+#define IXGBE_TX_FLAGS_NO_IFCS		(u32)(1 << 9)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aa37b84..fa0d6e1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5903,9 +5903,12 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	u32 type_tucmd = 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
-		    !(first->tx_flags & IXGBE_TX_FLAGS_TXSW))
-			return;
+		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN)) {
+			if (unlikely(skb->no_fcs))
+				first->tx_flags |= IXGBE_TX_FLAGS_NO_IFCS;
+			if (!(first->tx_flags & IXGBE_TX_FLAGS_TXSW))
+				return;
+		}
 	} else {
 		u8 l4_hdr = 0;
 		switch (first->protocol) {
@@ -5967,7 +5970,6 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 {
 	/* set type for advanced descriptor with frame checksum insertion */
 	__le32 cmd_type = cpu_to_le32(IXGBE_ADVTXD_DTYP_DATA |
-				      IXGBE_ADVTXD_DCMD_IFCS |
 				      IXGBE_ADVTXD_DCMD_DEXT);
 
 	/* set HW vlan bit if vlan is present */
@@ -5987,6 +5989,10 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 #endif
 		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_TSE);
 
+	/* insert frame checksum */
+	if (!(tx_flags & IXGBE_TX_FLAGS_NO_IFCS))
+		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_IFCS);
+
 	return cmd_type;
 }
 
@@ -6092,8 +6098,6 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		if (likely(!data_len))
 			break;
 
-		if (unlikely(skb->no_fcs))
-			cmd_type &= ~(cpu_to_le32(IXGBE_ADVTXD_DCMD_IFCS));
 		tx_desc->read.cmd_type_len = cmd_type | cpu_to_le32(size);
 
 		i++;
-- 
1.7.11.2
