From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/5] tg3: Add jumbo frame loopback tests to
 selftest
Date: Wed, 13 Apr 2011 14:05:07 -0700
Message-ID: <1302728708-1797-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3783 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932820Ab1DMU4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 16:56:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds jumbo frame loopback test support to the ethtool
selftest.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   34 +++++++++++++++++++++++++---------
 1 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9975cdb..52dd516 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10935,7 +10935,7 @@ static int tg3_test_memory(struct tg3 *tp)
 #define TG3_MAC_LOOPBACK	0
 #define TG3_PHY_LOOPBACK	1
 
-static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
+static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 {
 	u32 mac_mode, rx_start_idx, rx_idx, tx_idx, opaque_key;
 	u32 desc_idx, coal_now;
@@ -11033,7 +11033,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	err = -EIO;
 
-	tx_len = 1514;
+	tx_len = pktsz;
 	skb = netdev_alloc_skb(tp->dev, tx_len);
 	if (!skb)
 		return -ENOMEM;
@@ -11042,7 +11042,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	memcpy(tx_data, tp->dev->dev_addr, 6);
 	memset(tx_data + 6, 0x0, 8);
 
-	tw32(MAC_RX_MTU_SIZE, tx_len + 4);
+	tw32(MAC_RX_MTU_SIZE, tx_len + ETH_FCS_LEN);
 
 	for (i = 14; i < tx_len; i++)
 		tx_data[i] = (u8) (i & 0xff);
@@ -11098,8 +11098,6 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	desc = &rnapi->rx_rcb[rx_start_idx];
 	desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 	opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
-	if (opaque_key != RXD_OPAQUE_RING_STD)
-		goto out;
 
 	if ((desc->err_vlan & RXD_ERR_MASK) != 0 &&
 	    (desc->err_vlan != RXD_ERR_ODD_NIBBLE_RCVD_MII))
@@ -11109,9 +11107,20 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	if (rx_len != tx_len)
 		goto out;
 
-	rx_skb = tpr->rx_std_buffers[desc_idx].skb;
+	if (pktsz <= TG3_RX_STD_DMA_SZ - ETH_FCS_LEN) {
+		if (opaque_key != RXD_OPAQUE_RING_STD)
+			goto out;
+
+		rx_skb = tpr->rx_std_buffers[desc_idx].skb;
+		map = dma_unmap_addr(&tpr->rx_std_buffers[desc_idx], mapping);
+	} else {
+		if (opaque_key != RXD_OPAQUE_RING_JUMBO)
+			goto out;
+
+		rx_skb = tpr->rx_jmb_buffers[desc_idx].skb;
+		map = dma_unmap_addr(&tpr->rx_jmb_buffers[desc_idx], mapping);
+	}
 
-	map = dma_unmap_addr(&tpr->rx_std_buffers[desc_idx], mapping);
 	pci_dma_sync_single_for_cpu(tp->pdev, map, rx_len, PCI_DMA_FROMDEVICE);
 
 	for (i = 14; i < tx_len; i++) {
@@ -11177,9 +11186,13 @@ static int tg3_test_loopback(struct tg3 *tp)
 				  CPMU_CTRL_LINK_AWARE_MODE));
 	}
 
-	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
+	if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
 
+	if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
+	    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
+		err |= (TG3_MAC_LOOPBACK_FAILED << 2);
+
 	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
@@ -11189,8 +11202,11 @@ static int tg3_test_loopback(struct tg3 *tp)
 
 	if (!(tp->phy_flags & TG3_PHYFLG_PHY_SERDES) &&
 	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)) {
-		if (tg3_run_loopback(tp, TG3_PHY_LOOPBACK))
+		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
 			err |= TG3_PHY_LOOPBACK_FAILED;
+		if ((tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) &&
+		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_PHY_LOOPBACK))
+			err |= (TG3_PHY_LOOPBACK_FAILED << 2);
 	}
 
 	/* Re-enable gphy autopowerdown. */
-- 
1.7.3.4


