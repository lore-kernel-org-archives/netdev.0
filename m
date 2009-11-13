From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/20] tg3: Use tg3_start_xmit_dma_bug for 5717 A0
Date: Fri, 13 Nov 2009 15:03:39 -0800
Message-ID: <1258153432-7036-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3241 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932460AbZKMXER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The A0 revision of the 5717 has problems with short packet fragments.
It needs to use the tg3_start_xmit_dma_bug() routine.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   27 ++++++++++++++++++---------
 drivers/net/tg3.h |    1 +
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6831289..2d58406 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5454,7 +5454,12 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 								 IPPROTO_TCP,
 								 0);
 
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) {
+			mss |= (hdr_len & 0xc) << 12;
+			if (hdr_len & 0x10)
+				base_flags |= 0x00000010;
+			base_flags |= (hdr_len & 0x3e0) << 5;
+		} else if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
 			mss |= hdr_len << 9;
 		else if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_1) ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
@@ -5479,6 +5484,10 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
+	    !mss && skb->len > ETH_DATA_LEN)
+		base_flags |= TXD_FLAG_JMB_PKT;
+
 	if (skb_dma_map(&tp->pdev->dev, skb, DMA_TO_DEVICE)) {
 		dev_kfree_skb(skb);
 		goto out_unlock;
@@ -12714,13 +12723,12 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	if (!(tp->tg3_flags3 & TG3_FLG3_5755_PLUS)) {
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-			tp->tg3_flags3 |= TG3_FLG3_SHORT_DMA_BUG;
-		else {
-			tp->tg3_flags3 |= TG3_FLG3_4G_DMA_BNDRY_BUG;
-			tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
-		}
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		tp->tg3_flags3 |= TG3_FLG3_SHORT_DMA_BUG;
+	else if (!(tp->tg3_flags3 & TG3_FLG3_5755_PLUS)) {
+		tp->tg3_flags3 |= TG3_FLG3_4G_DMA_BNDRY_BUG;
+		tp->tg3_flags3 |= TG3_FLG3_40BIT_DMA_LIMIT_BUG;
 	}
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
@@ -14077,7 +14085,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
+	    tp->pci_chip_rev_id != CHIPREV_ID_5717_A0)
 		dev->netdev_ops = &tg3_netdev_ops;
 	else
 		dev->netdev_ops = &tg3_netdev_ops_dma_bug;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5fe5760..e7916bd 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -103,6 +103,7 @@
 #define  CHIPREV_ID_5906_A1		 0xc001
 #define  CHIPREV_ID_57780_A0		 0x57780000
 #define  CHIPREV_ID_57780_A1		 0x57780001
+#define  CHIPREV_ID_5717_A0		 0x05717000
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
-- 
1.6.4.4


