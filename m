From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] b44: add support for Byte Queue Limits
Date: Sat, 28 Sep 2013 23:22:18 +0200
Message-ID: <1380403338-12056-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:45281 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070Ab3I1VWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 17:22:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it possible to use some more advanced queuing
techniques with this driver.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 9b017d9..c96930f 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -596,6 +596,7 @@ static void b44_timer(unsigned long __opaque)
 static void b44_tx(struct b44 *bp)
 {
 	u32 cur, cons;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	cur  = br32(bp, B44_DMATX_STAT) & DMATX_STAT_CDMASK;
 	cur /= sizeof(struct dma_desc);
@@ -612,9 +613,14 @@ static void b44_tx(struct b44 *bp)
 				 skb->len,
 				 DMA_TO_DEVICE);
 		rp->skb = NULL;
+
+		bytes_compl += skb->len;
+		pkts_compl++;
+
 		dev_kfree_skb_irq(skb);
 	}
 
+	netdev_completed_queue(bp->dev, pkts_compl, bytes_compl);
 	bp->tx_cons = cons;
 	if (netif_queue_stopped(bp->dev) &&
 	    TX_BUFFS_AVAIL(bp) > B44_TX_WAKEUP_THRESH)
@@ -1018,6 +1024,8 @@ static netdev_tx_t b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bp->flags & B44_FLAG_REORDER_BUG)
 		br32(bp, B44_DMATX_PTR);
 
+	netdev_sent_queue(dev, skb->len);
+
 	if (TX_BUFFS_AVAIL(bp) < 1)
 		netif_stop_queue(dev);
 
@@ -1416,6 +1424,8 @@ static void b44_init_hw(struct b44 *bp, int reset_kind)
 
 	val = br32(bp, B44_ENET_CTRL);
 	bw32(bp, B44_ENET_CTRL, (val | ENET_CTRL_ENABLE));
+
+	netdev_reset_queue(bp->dev);
 }
 
 static int b44_open(struct net_device *dev)
-- 
1.7.10.4
