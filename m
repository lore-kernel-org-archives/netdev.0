From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: add DMA rx poll workaround to DMA4
Date: Sun, 4 Jun 2006 11:41:16 +0200
Message-ID: <200606041141.16967.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27611
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751264AbWFDJmK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 05:42:10 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the same patch as before, but for the dscape port.
Please apply to wireless-dev.

--

Also add the Poll RX DMA Memory workaround to the DMA4
(xmitstatus) path.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
index dc11260..ebe0984 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -604,25 +604,28 @@ err_destroy_tx0:
 static u16 generate_cookie(struct bcm43xx_dmaring *ring,
 			   int slot)
 {
-	u16 cookie = 0x0000;
+	u16 cookie = 0xF000;
 
 	/* Use the upper 4 bits of the cookie as
 	 * DMA controller ID and store the slot number
-	 * in the lower 12 bits
+	 * in the lower 12 bits.
+	 * Note that the cookie must never be 0, as this
+	 * is a special value used in RX path.
 	 */
 	switch (ring->mmio_base) {
 	default:
 		assert(0);
 	case BCM43xx_MMIO_DMA1_BASE:
+		cookie = 0xA000;
 		break;
 	case BCM43xx_MMIO_DMA2_BASE:
-		cookie = 0x1000;
+		cookie = 0xB000;
 		break;
 	case BCM43xx_MMIO_DMA3_BASE:
-		cookie = 0x2000;
+		cookie = 0xC000;
 		break;
 	case BCM43xx_MMIO_DMA4_BASE:
-		cookie = 0x3000;
+		cookie = 0xD000;
 		break;
 	}
 	assert(((u16)slot & 0xF000) == 0x0000);
@@ -640,16 +643,16 @@ struct bcm43xx_dmaring * parse_cookie(st
 	struct bcm43xx_dmaring *ring = NULL;
 
 	switch (cookie & 0xF000) {
-	case 0x0000:
+	case 0xA000:
 		ring = dma->tx_ring0;
 		break;
-	case 0x1000:
+	case 0xB000:
 		ring = dma->tx_ring1;
 		break;
-	case 0x2000:
+	case 0xC000:
 		ring = dma->tx_ring2;
 		break;
-	case 0x3000:
+	case 0xD000:
 		ring = dma->tx_ring3;
 		break;
 	default:
@@ -867,8 +870,18 @@ static void dma_rx(struct bcm43xx_dmarin
 		/* We received an xmit status. */
 		struct bcm43xx_hwxmitstatus *hw = (struct bcm43xx_hwxmitstatus *)skb->data;
 		struct bcm43xx_xmitstatus stat;
+		int i = 0;
 
 		stat.cookie = le16_to_cpu(hw->cookie);
+		while (stat.cookie == 0) {
+			if (unlikely(++i >= 10000)) {
+				assert(0);
+				break;
+			}
+			udelay(2);
+			barrier();
+			stat.cookie = le16_to_cpu(hw->cookie);
+		}
 		stat.flags = hw->flags;
 		stat.cnt1 = hw->cnt1;
 		stat.cnt2 = hw->cnt2;


-- 
Greetings Michael.
