From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] ixgbe: Modify setup of descriptor flags to avoid conditional jumps
Date: Sat, 17 Mar 2012 01:50:56 -0700
Message-ID: <1331974260-6383-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56951 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213Ab2CQIvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:33 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it more likely that the descriptor flags setup will use
cmov instructions instead of conditional jumps when setting up the flags.
The advantage to this is that the code should just flow a bit more
smoothly.

To do this it is necessary to set the TX_FLAGS_CSUM bit in tx_flags when
doing TSO so that we also do the checksum in addition to the segmentation
offload.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   34 ++++++++++++------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bf6d122..efce423 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6689,7 +6689,7 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 
 	/* set segmentation enable bits for TSO/FSO */
 #ifdef IXGBE_FCOE
-	if ((tx_flags & IXGBE_TX_FLAGS_TSO) || (tx_flags & IXGBE_TX_FLAGS_FSO))
+	if (tx_flags & (IXGBE_TX_FLAGS_TSO | IXGBE_TX_FLAGS_FSO))
 #else
 	if (tx_flags & IXGBE_TX_FLAGS_TSO)
 #endif
@@ -6700,33 +6700,33 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 
 static __le32 ixgbe_tx_olinfo_status(u32 tx_flags, unsigned int paylen)
 {
-	__le32 olinfo_status =
-		cpu_to_le32(paylen << IXGBE_ADVTXD_PAYLEN_SHIFT);
-
-	if (tx_flags & IXGBE_TX_FLAGS_TSO) {
-		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_TXSM |
-					    (1 << IXGBE_ADVTXD_IDX_SHIFT));
-		/* enble IPv4 checksum for TSO */
-		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
-			olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_IXSM);
-	}
+	__le32 olinfo_status = cpu_to_le32(paylen << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
 	/* enable L4 checksum for TSO and TX checksum offload */
 	if (tx_flags & IXGBE_TX_FLAGS_CSUM)
 		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_TXSM);
 
-#ifdef IXGBE_FCOE
-	/* use index 1 context for FCOE/FSO */
-	if (tx_flags & IXGBE_TX_FLAGS_FCOE)
-		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_CC |
-					    (1 << IXGBE_ADVTXD_IDX_SHIFT));
+	/* enble IPv4 checksum for TSO */
+	if (tx_flags & IXGBE_TX_FLAGS_IPV4)
+		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_IXSM);
 
+	/* use index 1 context for TSO/FSO/FCOE */
+#ifdef IXGBE_FCOE
+	if (tx_flags & (IXGBE_TX_FLAGS_TSO | IXGBE_TX_FLAGS_FCOE))
+#else
+	if (tx_flags & IXGBE_TX_FLAGS_TSO)
 #endif
+		olinfo_status |= cpu_to_le32(1 << IXGBE_ADVTXD_IDX_SHIFT);
+
 	/*
 	 * Check Context must be set if Tx switch is enabled, which it
 	 * always is for case where virtual functions are running
 	 */
+#ifdef IXGBE_FCOE
+	if (tx_flags & (IXGBE_TX_FLAGS_TXSW | IXGBE_TX_FLAGS_FCOE))
+#else
 	if (tx_flags & IXGBE_TX_FLAGS_TXSW)
+#endif
 		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_CC);
 
 	return olinfo_status;
@@ -7140,7 +7140,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	if (tso < 0)
 		goto out_drop;
 	else if (tso)
-		tx_flags |= IXGBE_TX_FLAGS_TSO;
+		tx_flags |= IXGBE_TX_FLAGS_TSO | IXGBE_TX_FLAGS_CSUM;
 	else if (ixgbe_tx_csum(tx_ring, skb, tx_flags, protocol))
 		tx_flags |= IXGBE_TX_FLAGS_CSUM;
 
-- 
1.7.7.6
