From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] yellowfin: Fix buffer underrun after dev_alloc_skb() failure
Date: Fri, 07 Aug 2009 19:57:28 +0200
Message-ID: <4A7C6B08.1040800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:48191 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbZHGRxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 13:53:54 -0400
Received: by ewy10 with SMTP id 10so1709526ewy.37
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 10:53:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dev_alloc_skb fails in the first iteration, a buffer underrun occurs.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Is this the best way to fix this? Untested, please review.

diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index a075801..a82ac32 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -728,7 +728,7 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 static void yellowfin_init_ring(struct net_device *dev)
 {
 	struct yellowfin_private *yp = netdev_priv(dev);
-	int i;
+	int i, j;
 
 	yp->tx_full = 0;
 	yp->cur_rx = yp->cur_tx = 0;
@@ -753,6 +753,11 @@ static void yellowfin_init_ring(struct net_device *dev)
 		yp->rx_ring[i].addr = cpu_to_le32(pci_map_single(yp->pci_dev,
 			skb->data, yp->rx_buf_sz, PCI_DMA_FROMDEVICE));
 	}
+	if (i != RX_RING_SIZE) {
+		for (j = 0; j < i; j++)
+			dev_kfree_skb(yp->rx_skbuff[j]);
+		return;
+	}
 	yp->rx_ring[i-1].dbdma_cmd = cpu_to_le32(CMD_STOP);
 	yp->dirty_rx = (unsigned int)(i - RX_RING_SIZE);
 
