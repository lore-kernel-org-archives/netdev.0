From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 04/14] net/at91_ether: use macb defs for rx dma buffers
Date: Thu, 18 Oct 2012 23:01:09 +0200
Message-ID: <1350594079-4337-5-git-send-email-manabian@gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:57738 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932530Ab2JRVBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:37 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so6136432lag.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:36 -0700 (PDT)
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/at91_ether.c | 8 ++++----
 drivers/net/ethernet/cadence/at91_ether.h | 7 -------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 21c6c71..c76b2c4 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -741,7 +741,7 @@ static void at91ether_start(struct net_device *dev)
 	}
 
 	/* Set the Wrap bit on the last descriptor */
-	dlist->descriptors[i-1].addr |= EMAC_DESC_WRAP;
+	dlist->descriptors[i-1].addr |= MACB_BIT(RX_WRAP);
 
 	/* Reset buffer index */
 	lp->rxBuffIndex = 0;
@@ -901,7 +901,7 @@ static void at91ether_rx(struct net_device *dev)
 	unsigned int pktlen;
 
 	dlist = lp->dlist;
-	while (dlist->descriptors[lp->rxBuffIndex].addr & EMAC_DESC_DONE) {
+	while (dlist->descriptors[lp->rxBuffIndex].addr & MACB_BIT(RX_USED)) {
 		p_recv = dlist->recv_buf[lp->rxBuffIndex];
 		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
 		skb = netdev_alloc_skb(dev, pktlen + 2);
@@ -918,10 +918,10 @@ static void at91ether_rx(struct net_device *dev)
 			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 		}
 
-		if (dlist->descriptors[lp->rxBuffIndex].size & EMAC_MULTICAST)
+		if (dlist->descriptors[lp->rxBuffIndex].size & MACB_BIT(RX_MHASH_MATCH))
 			dev->stats.multicast++;
 
-		dlist->descriptors[lp->rxBuffIndex].addr &= ~EMAC_DESC_DONE;	/* reset ownership bit */
+		dlist->descriptors[lp->rxBuffIndex].addr &= ~MACB_BIT(RX_USED);	/* reset ownership bit */
 		if (lp->rxBuffIndex == MAX_RX_DESCR-1)				/* wrap after last buffer */
 			lp->rxBuffIndex = 0;
 		else
diff --git a/drivers/net/ethernet/cadence/at91_ether.h b/drivers/net/ethernet/cadence/at91_ether.h
index 63e7e06..263954b 100644
--- a/drivers/net/ethernet/cadence/at91_ether.h
+++ b/drivers/net/ethernet/cadence/at91_ether.h
@@ -63,13 +63,6 @@
 #define MAX_RBUFF_SZ	0x600		/* 1518 rounded up */
 #define MAX_RX_DESCR	9		/* max number of receive buffers */
 
-#define EMAC_DESC_DONE	0x00000001	/* bit for if DMA is done */
-#define EMAC_DESC_WRAP	0x00000002	/* bit for wrap */
-
-#define EMAC_BROADCAST	0x80000000	/* broadcast address */
-#define EMAC_MULTICAST	0x40000000	/* multicast address */
-#define EMAC_UNICAST	0x20000000	/* unicast address */
-
 struct rbf_t
 {
 	unsigned int addr;
-- 
1.7.12.3
