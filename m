From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: Cleanup logic for MRQC and MTQC configuration
Date: Tue, 17 Jul 2012 19:20:44 -0700
Message-ID: <1342578045-17778-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab2GRCUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:52 -0400
In-Reply-To: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to make the code much more readable for MTQC and MRQC
configuration.

The big change is that I simplified much of the logic so that we are
essentially handling just 4 cases and their variants. In the cases where
RSS is disabled we are actually just programming the RETA table with all
1s resulting in a single queue RSS. In the case of SR-IOV I am treating
that as a subset of VMDq. This all results int he following configuration
for the hardware:
         DCB
         En       Dis
VMDq En  VMDQ/DCB VMDq/RSS
     Dis DCB/RSS  RSS

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  116 ++++++++++++++-----------
 1 file changed, 66 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 32c8cd6..2b4b791 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2719,8 +2719,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 rttdcs;
-	u32 reg;
+	u32 rttdcs, mtqc;
 	u8 tcs = netdev_get_num_tc(adapter->netdev);
 
 	if (hw->mac.type == ixgbe_mac_82598EB)
@@ -2732,28 +2731,32 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
 
 	/* set transmit pool layout */
-	switch (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-	case (IXGBE_FLAG_SRIOV_ENABLED):
-		IXGBE_WRITE_REG(hw, IXGBE_MTQC,
-				(IXGBE_MTQC_VT_ENA | IXGBE_MTQC_64VF));
-		break;
-	default:
-		if (!tcs)
-			reg = IXGBE_MTQC_64Q_1PB;
-		else if (tcs <= 4)
-			reg = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_4TC_4TQ;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		mtqc = IXGBE_MTQC_VT_ENA;
+		if (tcs > 4)
+			mtqc |= IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ;
+		else if (tcs > 1)
+			mtqc |= IXGBE_MTQC_RT_ENA | IXGBE_MTQC_4TC_4TQ;
+		else if (adapter->ring_feature[RING_F_RSS].indices == 4)
+			mtqc |= IXGBE_MTQC_32VF;
 		else
-			reg = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ;
+			mtqc |= IXGBE_MTQC_64VF;
+	} else {
+		if (tcs > 4)
+			mtqc = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ;
+		else if (tcs > 1)
+			mtqc = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_4TC_4TQ;
+		else
+			mtqc = IXGBE_MTQC_64Q_1PB;
+	}
 
-		IXGBE_WRITE_REG(hw, IXGBE_MTQC, reg);
+	IXGBE_WRITE_REG(hw, IXGBE_MTQC, mtqc);
 
-		/* Enable Security TX Buffer IFG for multiple pb */
-		if (tcs) {
-			reg = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
-			reg |= IXGBE_SECTX_DCB;
-			IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, reg);
-		}
-		break;
+	/* Enable Security TX Buffer IFG for multiple pb */
+	if (tcs) {
+		u32 sectx = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
+		sectx |= IXGBE_SECTX_DCB;
+		IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, sectx);
 	}
 
 	/* re-enable the arbiter */
@@ -2886,11 +2889,18 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	u32 mrqc = 0, reta = 0;
 	u32 rxcsum;
 	int i, j;
-	u8 tcs = netdev_get_num_tc(adapter->netdev);
-	int maxq = adapter->ring_feature[RING_F_RSS].indices;
+	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
+
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+		rss_i = 1;
 
-	if (tcs)
-		maxq = min(maxq, adapter->num_tx_queues / tcs);
+	/*
+	 * Program table for at least 2 queues w/ SR-IOV so that VFs can
+	 * make full use of any rings they may have.  We will use the
+	 * PSRTYPE register to control how many rings we use within the PF.
+	 */
+	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) && (rss_i < 2))
+		rss_i = 2;
 
 	/* Fill out hash function seeds */
 	for (i = 0; i < 10; i++)
@@ -2898,7 +2908,7 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 
 	/* Fill out redirection table */
 	for (i = 0, j = 0; i < 128; i++, j++) {
-		if (j == maxq)
+		if (j == rss_i)
 			j = 0;
 		/* reta = 4-byte sliding window of
 		 * 0x00..(indices-1)(indices-1)00..etc. */
@@ -2912,35 +2922,36 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	rxcsum |= IXGBE_RXCSUM_PCSD;
 	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB &&
-	    (adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
-		mrqc = IXGBE_MRQC_RSSEN;
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED)
+			mrqc = IXGBE_MRQC_RSSEN;
 	} else {
-		int mask = adapter->flags & (IXGBE_FLAG_RSS_ENABLED
-					     | IXGBE_FLAG_SRIOV_ENABLED);
-
-		switch (mask) {
-		case (IXGBE_FLAG_RSS_ENABLED):
-			if (!tcs)
-				mrqc = IXGBE_MRQC_RSSEN;
-			else if (tcs <= 4)
-				mrqc = IXGBE_MRQC_RTRSS4TCEN;
+		u8 tcs = netdev_get_num_tc(adapter->netdev);
+
+		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+			if (tcs > 4)
+				mrqc = IXGBE_MRQC_VMDQRT8TCEN;	/* 8 TCs */
+			else if (tcs > 1)
+				mrqc = IXGBE_MRQC_VMDQRT4TCEN;	/* 4 TCs */
+			else if (adapter->ring_feature[RING_F_RSS].indices == 4)
+				mrqc = IXGBE_MRQC_VMDQRSS32EN;
 			else
+				mrqc = IXGBE_MRQC_VMDQRSS64EN;
+		} else {
+			if (tcs > 4)
 				mrqc = IXGBE_MRQC_RTRSS8TCEN;
-			break;
-		case (IXGBE_FLAG_SRIOV_ENABLED):
-			mrqc = IXGBE_MRQC_VMDQEN;
-			break;
-		default:
-			break;
+			else if (tcs > 1)
+				mrqc = IXGBE_MRQC_RTRSS4TCEN;
+			else
+				mrqc = IXGBE_MRQC_RSSEN;
 		}
 	}
 
 	/* Perform hash on these packet types */
-	mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4
-	      | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
-	      | IXGBE_MRQC_RSS_FIELD_IPV6
-	      | IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
+	mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4 |
+		IXGBE_MRQC_RSS_FIELD_IPV4_TCP |
+		IXGBE_MRQC_RSS_FIELD_IPV6 |
+		IXGBE_MRQC_RSS_FIELD_IPV6_TCP;
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV4_UDP)
 		mrqc |= IXGBE_MRQC_RSS_FIELD_IPV4_UDP;
@@ -3103,8 +3114,13 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
 
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED)
-		psrtype |= (adapter->num_rx_queues_per_pool << 29);
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+		int rss_i = adapter->ring_feature[RING_F_RSS].indices;
+		if (rss_i > 3)
+			psrtype |= 2 << 29;
+		else if (rss_i > 1)
+			psrtype |= 1 << 29;
+	}
 
 	for (p = 0; p < adapter->num_rx_pools; p++)
 		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(adapter->num_vfs + p),
-- 
1.7.10.4
