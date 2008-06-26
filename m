From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Fix receiver hangup on Rx FIFO overflow
Date: Thu, 26 Jun 2008 17:14:15 +0900 (JST)
Message-ID: <20080626.171415.81099548.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsns2.toshiba-tops.co.jp ([202.230.225.126]:30208 "EHLO
	topsns2.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756676AbYFZIOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 04:14:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Rx FIFO overflow error, the controller consume a buffer descriptor
but currently the driver does not give it back to the controller.
This results unrecoverable 'Buffer List Exhausted' condition.  This
patch fix this problem by moving a "fbl_count--" line to proper place.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index dccea52..b07b8cb 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1736,7 +1736,6 @@ tc35815_rx(struct net_device *dev)
 			skb = lp->rx_skbs[cur_bd].skb;
 			prefetch(skb->data);
 			lp->rx_skbs[cur_bd].skb = NULL;
-			lp->fbl_count--;
 			pci_unmap_single(lp->pci_dev,
 					 lp->rx_skbs[cur_bd].skb_dma,
 					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
@@ -1792,6 +1791,7 @@ tc35815_rx(struct net_device *dev)
 #ifdef TC35815_USE_PACKEDBUFFER
 			while (lp->fbl_curid != id)
 #else
+			lp->fbl_count--;
 			while (lp->fbl_count < RX_BUF_NUM)
 #endif
 			{
