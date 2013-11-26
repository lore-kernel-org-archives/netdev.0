From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 04/17] net: bnx2x calls skb_set_rxhash
Date: Tue, 26 Nov 2013 09:22:54 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311260914050.21248@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:36466 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200Ab3KZRaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 12:30:19 -0500
Received: by mail-ob0-f201.google.com with SMTP id va2so1253269obc.4
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 09:30:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_rxhash to set the rxhash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index dcafbda..7c1d45d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -728,8 +728,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		skb_reserve(skb, pad + NET_SKB_PAD);
 		skb_put(skb, len);
-		skb->rxhash = tpa_info->rxhash;
-		skb->l4_rxhash = tpa_info->l4_rxhash;
+		skb_set_rxhash(skb, tpa_info->rxhash,
+		    tpa_info->l4_rxhash ? RXHASH_TYPE_L4 : RXHASH_TYPE_L3);
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -846,6 +846,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		enum eth_rx_cqe_type cqe_fp_type;
 		u16 len, pad, queue;
 		u8 *data;
+		u32 rxhash;
 		bool l4_rxhash;
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -987,8 +988,9 @@ reuse_rx:
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
 		/* Set Toeplitz hash for a none-LRO skb */
-		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
-		skb->l4_rxhash = l4_rxhash;
+		rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
+		skb_set_rxhash(skb, rxhash,
+			       l4_rxhash ? RXHASH_TYPE_L4 : RXHASH_TYPE_L3);
 
 		skb_checksum_none_assert(skb);
 
-- 
1.8.4.1
