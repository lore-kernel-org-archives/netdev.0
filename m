From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: properly update skb when mtu > 1500
Date: Tue, 13 Dec 2011 11:40:53 +0200
Message-ID: <1323769253-8760-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3239 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab1LMJk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Dec 2011 04:40:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit e52fcb2462ac484e6dd6e68869536609f0216938 newly allocated
skb for small packets are not updated properly and dropped by stack.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 477bc97..64f5cf5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -731,22 +731,22 @@ reuse_rx:
 				bnx2x_reuse_rx_data(fp, bd_cons, bd_prod);
 				goto next_rx;
 			}
+		}
 
-			skb_put(skb, len);
-			skb->protocol = eth_type_trans(skb, bp->dev);
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, bp->dev);
 
-			/* Set Toeplitz hash for a none-LRO skb */
-			skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp);
+		/* Set Toeplitz hash for a none-LRO skb */
+		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp);
 
-			skb_checksum_none_assert(skb);
+		skb_checksum_none_assert(skb);
 
-			if (bp->dev->features & NETIF_F_RXCSUM) {
+		if (bp->dev->features & NETIF_F_RXCSUM) {
 
-				if (likely(BNX2X_RX_CSUM_OK(cqe)))
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				else
-					fp->eth_q_stats.hw_csum_err++;
-			}
+			if (likely(BNX2X_RX_CSUM_OK(cqe)))
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				fp->eth_q_stats.hw_csum_err++;
 		}
 
 		skb_record_rx_queue(skb, fp->rx_queue);
-- 
1.7.7.2
