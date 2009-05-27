From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 3/5] netdev: bfin_mac: fix performance issue found by netperf
Date: Wed, 27 May 2009 02:10:13 -0400
Message-ID: <1243404615-25879-4-git-send-email-vapier@gentoo.org>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Michael Hennerich <michael.hennerich@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32890 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759759AbZE0GKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:10:18 -0400
In-Reply-To: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Hennerich <michael.hennerich@analog.com>

- Remove dead long delay
- Use proper defines
- Remove broken implementation of the TX DMA Data Alignment TXDWA feature

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |  110 +++++++++++------------------------------------
 1 files changed, 26 insertions(+), 84 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 626715c..1d63e3a 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -194,13 +194,13 @@ static int desc_list_init(void)
 		struct dma_descriptor *b = &(r->desc_b);
 
 		/* allocate a new skb for next time receive */
-		new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
+		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 		if (!new_skb) {
 			printk(KERN_NOTICE DRV_NAME
 			       ": init: low on mem - packet dropped\n");
 			goto init_error;
 		}
-		skb_reserve(new_skb, 2);
+		skb_reserve(new_skb, NET_IP_ALIGN);
 		r->skb = new_skb;
 
 		/*
@@ -566,9 +566,9 @@ static void adjust_tx_list(void)
 	 */
 	if (current_tx_ptr->next->next == tx_list_head) {
 		while (tx_list_head->status.status_word == 0) {
-			mdelay(1);
+			udelay(10);
 			if (tx_list_head->status.status_word != 0
-			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
+			    || !(bfin_read_DMA2_IRQ_STATUS() & DMA_RUN)) {
 				goto adjust_head;
 			}
 			if (timeout_cnt-- < 0) {
@@ -606,86 +606,28 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	u16 *data;
-
+	u32 data_align = (u32)(skb->data) & 0x3;
 	current_tx_ptr->skb = skb;
 
-	if (ANOMALY_05000285) {
-		/*
-		 * TXDWA feature is not avaible to older revision < 0.3 silicon
-		 * of BF537
-		 *
-		 * Only if data buffer is ODD WORD alignment, we do not
-		 * need to memcpy
-		 */
-		u32 data_align = (u32)(skb->data) & 0x3;
-		if (data_align == 0x2) {
-			/* move skb->data to current_tx_ptr payload */
-			data = (u16 *)(skb->data) - 1;
-			*data = (u16)(skb->len);
-			current_tx_ptr->desc_a.start_addr = (u32)data;
-			/* this is important! */
-			blackfin_dcache_flush_range((u32)data,
-					(u32)((u8 *)data + skb->len + 4));
-		} else {
-			*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
-			memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
-				skb->len);
-			current_tx_ptr->desc_a.start_addr =
-				(u32)current_tx_ptr->packet;
-			if (current_tx_ptr->status.status_word != 0)
-				current_tx_ptr->status.status_word = 0;
-			blackfin_dcache_flush_range(
-				(u32)current_tx_ptr->packet,
-				(u32)(current_tx_ptr->packet + skb->len + 2));
-		}
+	if (data_align == 0x2) {
+		/* move skb->data to current_tx_ptr payload */
+		data = (u16 *)(skb->data) - 1;
+				*data = (u16)(skb->len);
+		current_tx_ptr->desc_a.start_addr = (u32)data;
+		/* this is important! */
+		blackfin_dcache_flush_range((u32)data,
+				(u32)((u8 *)data + skb->len + 4));
 	} else {
-		/*
-		 * TXDWA feature is avaible to revision < 0.3 silicon of
-		 * BF537 and always avaible to BF52x
-		 */
-		u32 data_align = (u32)(skb->data) & 0x3;
-		if (data_align == 0x0) {
-			u16 sysctl = bfin_read_EMAC_SYSCTL();
-			sysctl |= TXDWA;
-			bfin_write_EMAC_SYSCTL(sysctl);
-
-			/* move skb->data to current_tx_ptr payload */
-			data = (u16 *)(skb->data) - 2;
-			*data = (u16)(skb->len);
-			current_tx_ptr->desc_a.start_addr = (u32)data;
-			/* this is important! */
-			blackfin_dcache_flush_range(
-					(u32)data,
-					(u32)((u8 *)data + skb->len + 4));
-		} else if (data_align == 0x2) {
-			u16 sysctl = bfin_read_EMAC_SYSCTL();
-			sysctl &= ~TXDWA;
-			bfin_write_EMAC_SYSCTL(sysctl);
-
-			/* move skb->data to current_tx_ptr payload */
-			data = (u16 *)(skb->data) - 1;
-			*data = (u16)(skb->len);
-			current_tx_ptr->desc_a.start_addr = (u32)data;
-			/* this is important! */
-			blackfin_dcache_flush_range(
-					(u32)data,
-					(u32)((u8 *)data + skb->len + 4));
-		} else {
-			u16 sysctl = bfin_read_EMAC_SYSCTL();
-			sysctl &= ~TXDWA;
-			bfin_write_EMAC_SYSCTL(sysctl);
-
-			*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
-			memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
-				skb->len);
-			current_tx_ptr->desc_a.start_addr =
-				(u32)current_tx_ptr->packet;
-			if (current_tx_ptr->status.status_word != 0)
-				current_tx_ptr->status.status_word = 0;
-			blackfin_dcache_flush_range(
-				(u32)current_tx_ptr->packet,
-				(u32)(current_tx_ptr->packet + skb->len + 2));
-		}
+		*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
+		memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
+			skb->len);
+		current_tx_ptr->desc_a.start_addr =
+			(u32)current_tx_ptr->packet;
+		if (current_tx_ptr->status.status_word != 0)
+			current_tx_ptr->status.status_word = 0;
+		blackfin_dcache_flush_range(
+			(u32)current_tx_ptr->packet,
+			(u32)(current_tx_ptr->packet + skb->len + 2));
 	}
 
 	/* Make sure data is really written into registers before enabling DMA */
@@ -695,7 +637,7 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 	current_tx_ptr->desc_a.config |= DMAEN;
 
 	/* tx dma is running, just return */
-	if (bfin_read_DMA2_IRQ_STATUS() & 0x08)
+	if (bfin_read_DMA2_IRQ_STATUS() & DMA_RUN)
 		goto out;
 
 	/* tx dma is not running */
@@ -721,7 +663,7 @@ static void bfin_mac_rx(struct net_device *dev)
 
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
-	new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
+	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
 		printk(KERN_NOTICE DRV_NAME
 		       ": rx: low on mem - packet dropped\n");
@@ -729,7 +671,7 @@ static void bfin_mac_rx(struct net_device *dev)
 		goto out;
 	}
 	/* reserve 2 bytes for RXDWA padding */
-	skb_reserve(new_skb, 2);
+	skb_reserve(new_skb, NET_IP_ALIGN);
 	current_rx_ptr->skb = new_skb;
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
-- 
1.6.3.1

