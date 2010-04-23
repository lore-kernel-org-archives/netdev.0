From: Tom Herbert <therbert@google.com>
Subject: [PATCH] bnx2x: add support for receive hashing
Date: Thu, 22 Apr 2010 22:54:16 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:27936 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609Ab0DWFyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 01:54:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bnx2x to extract Toeplitz hash out of the receive descriptor
for use in skb->rxhash.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 0819530..8bd2368 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1330,7 +1330,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY | \
 		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY)
 
-#define MULTI_FLAGS(bp) \
+#define RSS_FLAGS(bp) \
 		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0c6dba2..613f727 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1582,7 +1582,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		struct sw_rx_bd *rx_buf = NULL;
 		struct sk_buff *skb;
 		union eth_rx_cqe *cqe;
-		u8 cqe_fp_flags;
+		u8 cqe_fp_flags, cqe_fp_status_flags;
 		u16 len, pad;
 
 		comp_ring_cons = RCQ_BD(sw_comp_cons);
@@ -1598,6 +1598,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 		cqe = &fp->rx_comp_ring[comp_ring_cons];
 		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
+		cqe_fp_status_flags = cqe->fast_path_cqe.status_flags;
 
 		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
 		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
@@ -1727,6 +1728,12 @@ reuse_rx:
 
 			skb->protocol = eth_type_trans(skb, bp->dev);
 
+			if ((bp->dev->features & ETH_FLAG_RXHASH) &&
+			    (cqe_fp_status_flags &
+			     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
+				skb->rxhash = le32_to_cpu(
+				    cqe->fast_path_cqe.rss_hash_result);
+
 			skb->ip_summed = CHECKSUM_NONE;
 			if (bp->rx_csum) {
 				if (likely(BNX2X_RX_CSUM_OK(cqe)))
@@ -5750,10 +5757,10 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	u32 offset;
 	u16 max_agg_size;
 
-	if (is_multi(bp)) {
-		tstorm_config.config_flags = MULTI_FLAGS(bp);
+	tstorm_config.config_flags = RSS_FLAGS(bp);
+
+	if (is_multi(bp))
 		tstorm_config.rss_result_mask = MULTI_MASK;
-	}
 
 	/* Enable TPA if needed */
 	if (bp->flags & TPA_ENABLE_FLAG)
@@ -6629,10 +6636,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);
 
 	REG_WR(bp, SRC_REG_SOFT_RST, 1);
-	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
-		REG_WR(bp, i, 0xc0cac01a);
-		/* TODO: replace with something meaningful */
-	}
+	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4)
+		REG_WR(bp, i, random32());
 	bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
 #ifdef BCM_CNIC
 	REG_WR(bp, SRC_REG_KEYSEARCH_0, 0x63285672);
@@ -11001,6 +11006,11 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
 		changed = 1;
 	}
 
+	if (data & ETH_FLAG_RXHASH)
+		dev->features |= NETIF_F_RXHASH;
+	else
+		dev->features &= ~NETIF_F_RXHASH;
+
 	if (changed && netif_running(dev)) {
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
 		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
