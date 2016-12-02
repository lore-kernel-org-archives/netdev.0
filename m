From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] adm80211: add checks for dma mapping errors
Date: Sat,  3 Dec 2016 00:52:46 +0300
Message-ID: <1480715566-17027-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver does not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/admtek/adm8211.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/admtek/adm8211.c b/drivers/net/wireless/admtek/adm8211.c
index 70ecd82d674d..2b4a3eb38dfa 100644
--- a/drivers/net/wireless/admtek/adm8211.c
+++ b/drivers/net/wireless/admtek/adm8211.c
@@ -413,6 +413,13 @@ static void adm8211_interrupt_rci(struct ieee80211_hw *dev)
 						       skb_tail_pointer(newskb),
 						       RX_PKT_SIZE,
 						       PCI_DMA_FROMDEVICE);
+				if (pci_dma_mapping_error(priv->pdev,
+					   priv->rx_buffers[entry].mapping)) {
+					priv->rx_buffers[entry].skb = NULL;
+					dev_kfree_skb(newskb);
+					skb = NULL;
+					/* TODO: update rx dropped stats */
+				}
 			} else {
 				skb = NULL;
 				/* TODO: update rx dropped stats */
@@ -1450,6 +1457,12 @@ static int adm8211_init_rings(struct ieee80211_hw *dev)
 						  skb_tail_pointer(rx_info->skb),
 						  RX_PKT_SIZE,
 						  PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(priv->pdev, rx_info->mapping)) {
+			dev_kfree_skb(rx_info->skb);
+			rx_info->skb = NULL;
+			break;
+		}
+
 		desc->buffer1 = cpu_to_le32(rx_info->mapping);
 		desc->status = cpu_to_le32(RDES0_STATUS_OWN | RDES0_STATUS_SQL);
 	}
@@ -1613,7 +1626,7 @@ static void adm8211_calc_durations(int *dur, int *plcp, size_t payload_len, int
 }
 
 /* Transmit skb w/adm8211_tx_hdr (802.11 header created by hardware) */
-static void adm8211_tx_raw(struct ieee80211_hw *dev, struct sk_buff *skb,
+static int adm8211_tx_raw(struct ieee80211_hw *dev, struct sk_buff *skb,
 			   u16 plcp_signal,
 			   size_t hdrlen)
 {
@@ -1625,6 +1638,8 @@ static void adm8211_tx_raw(struct ieee80211_hw *dev, struct sk_buff *skb,
 
 	mapping = pci_map_single(priv->pdev, skb->data, skb->len,
 				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(priv->pdev, mapping))
+		return -ENOMEM;
 
 	spin_lock_irqsave(&priv->lock, flags);
 
@@ -1657,6 +1672,8 @@ static void adm8211_tx_raw(struct ieee80211_hw *dev, struct sk_buff *skb,
 
 	/* Trigger transmit poll */
 	ADM8211_CSR_WRITE(TDR, 0);
+
+	return 0;
 }
 
 /* Put adm8211_tx_hdr on skb and transmit */
@@ -1710,7 +1727,10 @@ static void adm8211_tx(struct ieee80211_hw *dev,
 
 	txhdr->retry_limit = info->control.rates[0].count;
 
-	adm8211_tx_raw(dev, skb, plcp_signal, hdrlen);
+	if (adm8211_tx_raw(dev, skb, plcp_signal, hdrlen)) {
+		/* Drop packet */
+		ieee80211_free_txskb(dev, skb);
+	}
 }
 
 static int adm8211_alloc_rings(struct ieee80211_hw *dev)
-- 
2.7.4
