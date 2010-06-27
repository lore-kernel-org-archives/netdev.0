From: Saeed Bishara <saeed@marvell.com>
Subject: [PATCH 1/2 v3] mv643xx_eth: use sw csum for big packets
Date: Sun, 27 Jun 2010 13:26:43 +0300
Message-ID: <1277634403-1018-1-git-send-email-saeed@marvell.com>
Cc: Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dakia2.marvell.com ([65.219.4.35]:51703 "EHLO
	dakia2.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689Ab0F0K0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 06:26:46 -0400
Received: from maili.marvell.com (maili.marvell.com [10.68.76.51]) by dakia2.marvell.com with ESMTP id O2XeX6C9IxIf2WkT for <netdev@vger.kernel.org>; Sun, 27 Jun 2010 03:26:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some controllers (KW, Dove) limits the TX IP/layer4 checksum offloading to a max size.

Signed-off-by: Saeed Bishara <saeed@marvell.com>
Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
---
 drivers/net/mv643xx_eth.c   |    9 +++++++--
 include/linux/mv643xx_eth.h |    5 +++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e345ec8..73bb8ea 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -289,6 +289,7 @@ struct mv643xx_eth_shared_private {
 	unsigned int t_clk;
 	int extended_rx_coal_limit;
 	int tx_bw_control;
+	int tx_csum_limit;
 };
 
 #define TX_BW_CONTROL_ABSENT		0
@@ -776,13 +777,16 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	l4i_chk = 0;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		int hdr_len;
 		int tag_bytes;
 
 		BUG_ON(skb->protocol != htons(ETH_P_IP) &&
 		       skb->protocol != htons(ETH_P_8021Q));
 
-		tag_bytes = (void *)ip_hdr(skb) - (void *)skb->data - ETH_HLEN;
-		if (unlikely(tag_bytes & ~12)) {
+		hdr_len = (void *)ip_hdr(skb) - (void *)skb->data;
+		tag_bytes = hdr_len - ETH_HLEN;
+		if (skb->len - hdr_len > mp->shared->tx_csum_limit ||
+		    unlikely(tag_bytes & ~12)) {
 			if (skb_checksum_help(skb) == 0)
 				goto no_csum;
 			kfree_skb(skb);
@@ -2666,6 +2670,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	 * Detect hardware parameters.
 	 */
 	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+	msp->tx_csum_limit = pd->tx_csum_limit ? pd->tx_csum_limit : 9 * 1024;
 	infer_hw_params(msp);
 
 	platform_set_drvdata(pdev, msp);
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index cbbbe9b..30b0c4e 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -19,6 +19,11 @@ struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
 	struct platform_device	*shared_smi;
 	unsigned int		t_clk;
+	/*
+	 * Max packet size for Tx IP/Layer 4 checksum, when set to 0, default
+	 * limit of 9KiB will be used.
+	 */
+	int			tx_csum_limit;
 };
 
 #define MV643XX_ETH_PHY_ADDR_DEFAULT	0
-- 
1.6.0.4

