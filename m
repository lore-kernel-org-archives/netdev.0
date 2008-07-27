From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 2/3] Blackfin EMAC Driver: enable TXDWA new feature for new silicon (rev > 0.2)
Date: Sun, 27 Jul 2008 22:45:04 +0800
Message-ID: <1217169905-7055-3-git-send-email-cooloney@kernel.org>
References: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.158]:28101 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513AbYG0Op1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 10:45:27 -0400
Received: by po-out-1718.google.com with SMTP id c31so8301863poi.1
        for <netdev@vger.kernel.org>; Sun, 27 Jul 2008 07:45:26 -0700 (PDT)
In-Reply-To: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |  103 ++++++++++++++++++++++++++++++++++++------------
 1 files changed, 77 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 17951cb..57ebe6d 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -606,36 +606,87 @@ adjust_head:
 static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	unsigned int data;
+	u16 *data;
 
 	current_tx_ptr->skb = skb;
 
-	/*
-	 * Is skb->data always 16-bit aligned?
-	 * Do we need to memcpy((char *)(tail->packet + 2), skb->data, len)?
-	 */
-	if ((((unsigned int)(skb->data)) & 0x02) == 2) {
-		/* move skb->data to current_tx_ptr payload */
-		data = (unsigned int)(skb->data) - 2;
-		*((unsigned short *)data) = (unsigned short)(skb->len);
-		current_tx_ptr->desc_a.start_addr = (unsigned long)data;
-		/* this is important! */
-		blackfin_dcache_flush_range(data, (data + (skb->len)) + 2);
-
+	if (ANOMALY_05000285) {
+		/*
+		 * TXDWA feature is not avaible to older revision < 0.3 silicon
+		 * of BF537
+		 *
+		 * Only if data buffer is ODD WORD alignment, we do not
+		 * need to memcpy
+		 */
+		u32 data_align = (u32)(skb->data) & 0x3;
+		if (data_align == 0x2) {
+			/* move skb->data to current_tx_ptr payload */
+			data = (u16 *)(skb->data) - 1;
+			*data = (u16)(skb->len);
+			current_tx_ptr->desc_a.start_addr = (u32)data;
+			/* this is important! */
+			blackfin_dcache_flush_range((u32)data,
+					(u32)((u8 *)data + skb->len + 4));
+		} else {
+			*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
+			memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
+				skb->len);
+			current_tx_ptr->desc_a.start_addr =
+				(u32)current_tx_ptr->packet;
+			if (current_tx_ptr->status.status_word != 0)
+				current_tx_ptr->status.status_word = 0;
+			blackfin_dcache_flush_range(
+				(u32)current_tx_ptr->packet,
+				(u32)(current_tx_ptr->packet + skb->len + 2));
+		}
 	} else {
-		*((unsigned short *)(current_tx_ptr->packet)) =
-		    (unsigned short)(skb->len);
-		memcpy((char *)(current_tx_ptr->packet + 2), skb->data,
-		       (skb->len));
-		current_tx_ptr->desc_a.start_addr =
-		    (unsigned long)current_tx_ptr->packet;
-		if (current_tx_ptr->status.status_word != 0)
-			current_tx_ptr->status.status_word = 0;
-		blackfin_dcache_flush_range((unsigned int)current_tx_ptr->
-					    packet,
-					    (unsigned int)(current_tx_ptr->
-							   packet + skb->len) +
-					    2);
+		/*
+		 * TXDWA feature is avaible to revision < 0.3 silicon of
+		 * BF537 and always avaible to BF52x
+		 */
+		u32 data_align = (u32)(skb->data) & 0x3;
+		if (data_align == 0x0) {
+			u16 sysctl = bfin_read_EMAC_SYSCTL();
+			sysctl |= TXDWA;
+			bfin_write_EMAC_SYSCTL(sysctl);
+
+			/* move skb->data to current_tx_ptr payload */
+			data = (u16 *)(skb->data) - 2;
+			*data = (u16)(skb->len);
+			current_tx_ptr->desc_a.start_addr = (u32)data;
+			/* this is important! */
+			blackfin_dcache_flush_range(
+					(u32)data,
+					(u32)((u8 *)data + skb->len + 4));
+		} else if (data_align == 0x2) {
+			u16 sysctl = bfin_read_EMAC_SYSCTL();
+			sysctl &= ~TXDWA;
+			bfin_write_EMAC_SYSCTL(sysctl);
+
+			/* move skb->data to current_tx_ptr payload */
+			data = (u16 *)(skb->data) - 1;
+			*data = (u16)(skb->len);
+			current_tx_ptr->desc_a.start_addr = (u32)data;
+			/* this is important! */
+			blackfin_dcache_flush_range(
+					(u32)data,
+					(u32)((u8 *)data + skb->len + 4));
+		} else {
+			u16 sysctl = bfin_read_EMAC_SYSCTL();
+			sysctl &= ~TXDWA;
+			bfin_write_EMAC_SYSCTL(sysctl);
+
+			*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
+			memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
+				skb->len);
+			current_tx_ptr->desc_a.start_addr =
+				(u32)current_tx_ptr->packet;
+			if (current_tx_ptr->status.status_word != 0)
+				current_tx_ptr->status.status_word = 0;
+			blackfin_dcache_flush_range(
+				(u32)current_tx_ptr->packet,
+				(u32)(current_tx_ptr->packet + skb->len + 2));
+		}
 	}
 
 	/* enable this packet's dma */
-- 
1.5.6

