From: Tom Herbert <therbert@google.com>
Subject: [PATCH 02/15] net: bnx2x calls skb_set_hash
Date: Tue, 17 Dec 2013 23:23:11 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312172316370.24389@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:55601 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab3LRHXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:23:12 -0500
Received: by mail-pd0-f201.google.com with SMTP id r10so817735pdi.4
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 23:23:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ec96130..787fef6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -728,8 +728,9 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		skb_reserve(skb, pad + NET_SKB_PAD);
 		skb_put(skb, len);
-		skb->rxhash = tpa_info->rxhash;
-		skb->l4_rxhash = tpa_info->l4_rxhash;
+		skb_set_hash(skb, tpa_info->rxhash,
+			     tpa_info->l4_rxhash ?
+			     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -846,6 +847,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		enum eth_rx_cqe_type cqe_fp_type;
 		u16 len, pad, queue;
 		u8 *data;
+		u32 rxhash;
 		bool l4_rxhash;
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -987,8 +989,9 @@ reuse_rx:
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
 		/* Set Toeplitz hash for a none-LRO skb */
-		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
-		skb->l4_rxhash = l4_rxhash;
+		rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
+		skb_set_hash(skb, rxhash,
+			     l4_rxhash ? PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
 
 		skb_checksum_none_assert(skb);
 
-- 
1.8.5.1
