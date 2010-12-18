From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 2/3] ixgbe: example of how to update ixgbe to make use of
	in-kernel Toeplitz hash
Date: Fri, 17 Dec 2010 17:00:43 -0800
Message-ID: <20101218010043.28602.43172.stgit@gitlad.jf.intel.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61152 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756797Ab0LRBBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 20:01:03 -0500
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id oBI10hNZ028779
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 17:00:43 -0800
In-Reply-To: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows ixgbe to make use of the in-kernel Toeplitz hashing so
that RX and TX hash queues can be matched up.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   47 ++++++++++++++++++++++------------------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a060610..0d0fcde 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -42,6 +42,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <scsi/fc/fc_fcoe.h>
+#include <linux/toeplitz.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -2847,27 +2848,31 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	static const u32 seed[10] = { 0xE291D73D, 0x1805EC6C, 0x2A94B30D,
-			  0xA54F2BEC, 0xEA49AF7C, 0xE214AD3D, 0xB855AABE,
-			  0x6A3E67EA, 0x14364D17, 0x3BED200D};
-	u32 mrqc = 0, reta = 0;
+	u32 mrqc = 0;
 	u32 rxcsum;
-	int i, j;
+	int i, j, indices;
 	int mask;
 
 	/* Fill out hash function seeds */
-	for (i = 0; i < 10; i++)
-		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), seed[i]);
+	for (i = 0; i < 10; i++) {
+		u32 toeplitz_key = (u32)toeplitz_get_key_byte((4 * i));
+		toeplitz_key |= (u32)toeplitz_get_key_byte((4 * i) + 1) << 8;
+		toeplitz_key |= (u32)toeplitz_get_key_byte((4 * i) + 2) << 16;
+		toeplitz_key |= (u32)toeplitz_get_key_byte((4 * i) + 3) << 24;
+		IXGBE_WRITE_REG(hw, IXGBE_RSSRK(i), toeplitz_key);
+	}
 
 	/* Fill out redirection table */
-	for (i = 0, j = 0; i < 128; i++, j++) {
-		if (j == adapter->ring_feature[RING_F_RSS].indices)
-			j = 0;
+	indices = adapter->ring_feature[RING_F_RSS].indices;
+	for (i = 0; i < 32; i++) {
+		u32 reta = 0;
 		/* reta = 4-byte sliding window of
 		 * 0x00..(indices-1)(indices-1)00..etc. */
-		reta = (reta << 8) | (j * 0x11);
-		if ((i & 3) == 3)
-			IXGBE_WRITE_REG(hw, IXGBE_RETA(i >> 2), reta);
+		for (j = 0; j < 4; j++) {
+			u32 entry = (indices * ((i * 4) + j)) >> 7;
+			reta |= entry << (8 * j);
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_RETA(i), reta);
 	}
 
 	/* Disable indicating checksum in descriptor, enables RSS hash */
@@ -6643,14 +6648,8 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 #endif
 		}
 	}
-#endif
-
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-		while (unlikely(txq >= dev->real_num_tx_queues))
-			txq -= dev->real_num_tx_queues;
-		return txq;
-	}
 
+#endif
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 		if (skb->priority == TC_PRIO_CONTROL)
 			txq = adapter->ring_feature[RING_F_DCB].indices-1;
@@ -6660,7 +6659,13 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 		return txq;
 	}
 
-	return skb_tx_hash(dev, skb);
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+		while (unlikely(txq >= dev->real_num_tx_queues))
+			txq -= dev->real_num_tx_queues;
+		return txq;
+	}
+
+	return toeplitz_select_queue(dev, skb);
 }
 
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,

