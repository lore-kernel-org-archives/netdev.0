From: akpm@linux-foundation.org
Subject: [patch 07/19] dmfe: fix two bugs
Date: Tue, 06 Mar 2007 02:41:52 -0800
Message-ID: <200703061041.l26AfqRi019753@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	maximlevitsky@gmail.com, val_henson@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34634 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbXCFKmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:00 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxim Levitsky <maximlevitsky@gmail.com>

Fix a oops on module removal due to deallocating memory before unregistring
driver Fix a NULL pointer dereference when dev_alloc_skb fails

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/dmfe.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff -puN drivers/net/tulip/dmfe.c~dmfe-fix-two-bugs drivers/net/tulip/dmfe.c
--- a/drivers/net/tulip/dmfe.c~dmfe-fix-two-bugs
+++ a/drivers/net/tulip/dmfe.c
@@ -501,14 +501,17 @@ static void __devexit dmfe_remove_one (s
 	DMFE_DBUG(0, "dmfe_remove_one()", 0);
 
  	if (dev) {
+
+		unregister_netdev(dev);
+
 		pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
 					DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
  					db->desc_pool_dma_ptr);
 		pci_free_consistent(db->pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
 					db->buf_pool_ptr, db->buf_pool_dma_ptr);
-		unregister_netdev(dev);
 		pci_release_regions(pdev);
 		free_netdev(dev);	/* free board information */
+
 		pci_set_drvdata(pdev, NULL);
 	}
 
@@ -927,7 +930,7 @@ static inline u32 cal_CRC(unsigned char 
 static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 {
 	struct rx_desc *rxptr;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *newskb;
 	int rxlen;
 	u32 rdes0;
 
@@ -980,9 +983,11 @@ static void dmfe_rx_packet(struct DEVICE
 				} else {
 					/* Good packet, send to upper layer */
 					/* Shorst packet used new SKB */
-					if ( (rxlen < RX_COPY_SIZE) &&
-						( (skb = dev_alloc_skb(rxlen + 2) )
-						!= NULL) ) {
+					if ((rxlen < RX_COPY_SIZE) &&
+						((newskb = dev_alloc_skb(rxlen + 2))
+						!= NULL)) {
+
+						skb = newskb;
 						/* size less than COPY_SIZE, allocate a rxlen SKB */
 						skb->dev = dev;
 						skb_reserve(skb, 2); /* 16byte align */
_
