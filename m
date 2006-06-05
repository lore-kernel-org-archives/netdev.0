From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Mon, 5 Jun 2006 17:53:58 -0400
Message-ID: <20060605215353.GA7381@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:43788 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751092AbWFEVyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 17:54:20 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This pull is intended for 2.6.17 if at all possible.

Thanks,

John

---

The following changes since commit 672c6108a51bf559d19595d9f8193dfd81f0f752:
  Linus Torvalds:
        Merge master.kernel.org:/.../jejb/scsi-rc-fixes-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Michael Buesch:
      bcm43xx: add DMA rx poll workaround to DMA4

 drivers/net/wireless/bcm43xx/bcm43xx_dma.c |   31 ++++++++++++++++++++--------
 1 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
index bbecba0..d0318e5 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
@@ -624,25 +624,28 @@ err_destroy_tx0:
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
@@ -660,16 +663,16 @@ struct bcm43xx_dmaring * parse_cookie(st
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
@@ -839,8 +842,18 @@ static void dma_rx(struct bcm43xx_dmarin
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
John W. Linville
linville@tuxdriver.com
