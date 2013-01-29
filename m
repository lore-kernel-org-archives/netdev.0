From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 1/3][net-next] gianfar: Optimize struct gfar_priv_tx_q for two cache lines
Date: Tue, 29 Jan 2013 15:55:10 +0200
Message-ID: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:49793
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756604Ab3A2Nzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 08:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resize and regroup structure members to eliminate memory holes and
to pack the structure into 2 cache lines (from 3).
tx_ring_size was resized from 4 to 2 bytes and few members were re-grouped
in order to eliminate byte holes and achieve compactness.
Where possible, few members were grouped according to their usage and access
order (i.e. start_xmit vs. clean_tx_ring members), less important members
were pushed at the end.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.h |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 91bb2de..045c0d2 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -935,26 +935,25 @@ struct tx_q_stats {
  *	@txtime: coalescing value if based on time
  */
 struct gfar_priv_tx_q {
+	/* cacheline 1 */
 	spinlock_t txlock __attribute__ ((aligned (SMP_CACHE_BYTES)));
-	struct sk_buff ** tx_skbuff;
-	/* Buffer descriptor pointers */
-	dma_addr_t tx_bd_dma_base;
 	struct	txbd8 *tx_bd_base;
 	struct	txbd8 *cur_tx;
-	struct	txbd8 *dirty_tx;
+	unsigned int num_txbdfree;
+	unsigned short skb_curtx;
+	unsigned short tx_ring_size;
 	struct tx_q_stats stats;
-	struct	net_device *dev;
 	struct gfar_priv_grp *grp;
-	u16	skb_curtx;
-	u16	skb_dirtytx;
-	u16	qindex;
-	unsigned int tx_ring_size;
-	unsigned int num_txbdfree;
+	/* cacheline 2 */
+	struct net_device *dev;
+	struct sk_buff **tx_skbuff;
+	struct	txbd8 *dirty_tx;
+	unsigned short skb_dirtytx;
+	unsigned short qindex;
 	/* Configuration info for the coalescing features */
-	unsigned char txcoalescing;
+	unsigned int txcoalescing;
 	unsigned long txic;
-	unsigned short txcount;
-	unsigned short txtime;
+	dma_addr_t tx_bd_dma_base;
 };
 
 /*
-- 
1.6.6
