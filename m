From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 15/20] tg3: Consider rx_std_prod_idx a hw mailbox
Date: Fri, 13 Nov 2009 15:03:47 -0800
Message-ID: <1258153432-7036-16-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3244 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932468AbZKMXEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes how the code uses the rx_std_prod_idx member.  In the
following patch, the code will be changed so that it will act just like
a hardware mailbox.  This patch prepares the code so that memory barriers
can be more easily inserted.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 59a715a..beda9bf 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4537,6 +4537,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 {
 	struct tg3 *tp = tnapi->tp;
 	u32 work_mask, rx_std_posted = 0;
+	u32 std_prod_idx, jmb_prod_idx;
 	u32 sw_idx = tnapi->rx_rcb_ptr;
 	u16 hw_idx;
 	int received;
@@ -4550,6 +4551,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 	rmb();
 	work_mask = 0;
 	received = 0;
+	std_prod_idx = tpr->rx_std_prod_idx;
+	jmb_prod_idx = tpr->rx_jmb_prod_idx;
 	while (sw_idx != hw_idx && budget > 0) {
 		struct ring_info *ri;
 		struct tg3_rx_buffer_desc *desc = &tnapi->rx_rcb[sw_idx];
@@ -4564,13 +4567,13 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			ri = &tpr->rx_std_buffers[desc_idx];
 			dma_addr = pci_unmap_addr(ri, mapping);
 			skb = ri->skb;
-			post_ptr = &tpr->rx_std_prod_idx;
+			post_ptr = &std_prod_idx;
 			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
 			ri = &tpr->rx_jmb_buffers[desc_idx];
 			dma_addr = pci_unmap_addr(ri, mapping);
 			skb = ri->skb;
-			post_ptr = &tpr->rx_jmb_prod_idx;
+			post_ptr = &jmb_prod_idx;
 		} else
 			goto next_pkt_nopost;
 
@@ -4687,14 +4690,14 @@ next_pkt_nopost:
 
 	/* Refill RX ring(s). */
 	if (work_mask & RXD_OPAQUE_RING_STD) {
-		sw_idx = tpr->rx_std_prod_idx % TG3_RX_RING_SIZE;
+		tpr->rx_std_prod_idx = std_prod_idx % TG3_RX_RING_SIZE;
 		tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
-			     sw_idx);
+			     tpr->rx_std_prod_idx);
 	}
 	if (work_mask & RXD_OPAQUE_RING_JUMBO) {
-		sw_idx = tpr->rx_jmb_prod_idx % TG3_RX_JUMBO_RING_SIZE;
+		tpr->rx_jmb_prod_idx = jmb_prod_idx % TG3_RX_JUMBO_RING_SIZE;
 		tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
-			     sw_idx);
+			     tpr->rx_jmb_prod_idx);
 	}
 	mmiowb();
 
-- 
1.6.4.4


