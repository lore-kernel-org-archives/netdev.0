From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] rps: changes to bnx2x to get device hash
Date: Tue, 10 Nov 2009 22:53:36 -0800
Message-ID: <65634d660911102253lbfc0927i4e4c0eba6d7d765d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:10865 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbZKKGxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:53:35 -0500
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id nAB6rdU8009720
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 06:53:39 GMT
Received: from iwn35 (iwn35.prod.google.com [10.241.68.99])
	by spaceape23.eur.corp.google.com with ESMTP id nAB6r5Ca018747
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:36 -0800
Received: by iwn35 with SMTP id 35so762377iwn.26
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x changes to get Toeplitz hash on RX and out into skb.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/bnx2x.h      |    2 +-
 drivers/net/bnx2x_main.c |   47 ++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index c3b32f7..a876d78 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1295,7 +1295,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32
reg, u32 expected, int ms,
 				 AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR)


-#define MULTI_FLAGS(bp) \
+#define RSS_FLAGS(bp) \
 		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 59b58d8..1729c04 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -83,6 +83,10 @@ module_param(multi_mode, int, 0);
 MODULE_PARM_DESC(multi_mode, " Multi queue mode "
 			     "(0 Disable; 1 Enable (default))");

+static int get_hdrhash = 1;
+module_param(get_hdrhash, int, 0);
+MODULE_PARM_DESC(get_hdrhash, " Get Toeplitz hash from device");
+
 static int num_rx_queues;
 module_param(num_rx_queues, int, 0);
 MODULE_PARM_DESC(num_rx_queues, " Number of Rx queues for multi_mode=1"
@@ -1520,7 +1524,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath
*fp, int budget)
 		struct sw_rx_bd *rx_buf = NULL;
 		struct sk_buff *skb;
 		union eth_rx_cqe *cqe;
-		u8 cqe_fp_flags;
+		u8 cqe_fp_flags, cqe_fp_status_flags, cqe_fp_pars_flags;
 		u16 len, pad;

 		comp_ring_cons = RCQ_BD(sw_comp_cons);
@@ -1536,6 +1540,8 @@ static int bnx2x_rx_int(struct bnx2x_fastpath
*fp, int budget)

 		cqe = &fp->rx_comp_ring[comp_ring_cons];
 		cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
+		cqe_fp_status_flags = cqe->fast_path_cqe.status_flags;
+		cqe_fp_pars_flags = cqe->fast_path_cqe.pars_flags.flags;

 		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
 		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
@@ -1661,7 +1667,32 @@ reuse_rx:
 				goto next_rx;
 			}

-			skb->protocol = eth_type_trans(skb, bp->dev);
+
+			if (get_hdrhash && (cqe_fp_status_flags &
+			    ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG)) {
+				u8 hash_type = cqe_fp_status_flags &
+					ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE;
+
+				skb->rxhash = le32_to_cpu(
+				      cqe->fast_path_cqe.rss_hash_result);
+				if (!skb->rxhash)
+					skb->rxhash = 1;
+
+				/* unicast IPv4 packet? */
+				if (((hash_type == IPV4_HASH_TYPE) ||
+				     (hash_type == TCP_IPV4_HASH_TYPE)) &&
+				    (cqe_fp_pars_flags &
+					PARSING_FLAGS_ETHERNET_ADDRESS_TYPE)) {
+					skb->dev = bp->dev;
+					skb_reset_mac_header(skb);
+					skb_pull(skb, ETH_HLEN);
+					skb->protocol =
+					    __constant_htons(ETH_P_IP);
+				} else
+					skb->protocol =
+					    eth_type_trans(skb, bp->dev);
+			} else
+				skb->protocol = eth_type_trans(skb, bp->dev);

 			skb->ip_summed = CHECKSUM_NONE;
 			if (bp->rx_csum) {
@@ -5388,8 +5419,11 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	u16 max_agg_size;

 	if (is_multi(bp)) {
-		tstorm_config.config_flags = MULTI_FLAGS(bp);
+		tstorm_config.config_flags = RSS_FLAGS(bp);
 		tstorm_config.rss_result_mask = MULTI_MASK;
+	} else if (get_hdrhash) {
+		/* Set flags so the Toeplitz hash is provided */
+		tstorm_config.config_flags = RSS_FLAGS(bp);
 	}

 	/* Enable TPA if needed */
@@ -6223,9 +6257,10 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);

 	REG_WR(bp, SRC_REG_SOFT_RST, 1);
-	for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4) {
-		REG_WR(bp, i, 0xc0cac01a);
-		/* TODO: replace with something meaningful */
+	{
+		int i;
+		for (i = SRC_REG_KEYRSS0_0; i <= SRC_REG_KEYRSS1_9; i += 4)
+			REG_WR(bp, i, random32());
 	}
 	bnx2x_init_block(bp, SRCH_BLOCK, COMMON_STAGE);
 #ifdef BCM_CNIC
-- 
1.5.4.3
