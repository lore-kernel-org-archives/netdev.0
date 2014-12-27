From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 23/23 V2 for 3.19]  rtlwifi: Fix error when accessing unmapped memory in skb
Date: Sat, 27 Dec 2014 14:17:37 -0600
Message-ID: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Eric Biggers <ebiggers3@gmail.com>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:59221 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaL0URq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 15:17:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These drivers use 9100-byte receive buffers, thus allocating an skb requires
an O(3) memory allocation. Under heavy memory loads and fragmentation, such
a request can fail. Previous versions of the driver have dropped the packet
and reused the old buffer; however, the new version introduced a bug in that
it released the old buffer before trying to allocate a new one. The previous
method is implemented here.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>  [v3.18]
Reported-by: Eric Biggers <ebiggers3@gmail.com>
Cc: Eric Biggers <ebiggers3@gmail.com>
---

V2 - Fixes an error in the logic of V1. Realtek is working on a change to
     the RX buffer allocation, but that is likely to be too invasive for
     a fix to -rc or stable. In the meantime, this will help.

Larry
---

 drivers/net/wireless/rtlwifi/pci.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 846a2e6..cf4e2c6 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -666,7 +666,8 @@ tx_status_ok:
 }
 
 static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
-				    u8 *entry, int rxring_idx, int desc_idx)
+				    struct sk_buff *new_skb, u8 *entry,
+				    int rxring_idx, int desc_idx)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
@@ -674,11 +675,15 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 	u8 tmp_one = 1;
 	struct sk_buff *skb;
 
+	if (likely(new_skb)) {
+		skb = new_skb;
+		goto remap;
+	}
 	skb = dev_alloc_skb(rtlpci->rxbuffersize);
 	if (!skb)
 		return 0;
-	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
 
+remap:
 	/* just set skb->cb to mapping addr for pci_unmap_single use */
 	*((dma_addr_t *)skb->cb) =
 		pci_map_single(rtlpci->pdev, skb_tail_pointer(skb),
@@ -686,6 +691,7 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 	bufferaddress = *((dma_addr_t *)skb->cb);
 	if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
 		return 0;
+	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
 	if (rtlpriv->use_new_trx_flow) {
 		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
 					    HW_DESC_RX_PREPARE,
@@ -781,6 +787,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		/*rx pkt */
 		struct sk_buff *skb = rtlpci->rx_ring[rxring_idx].rx_buf[
 				      rtlpci->rx_ring[rxring_idx].idx];
+		struct sk_buff *new_skb;
 
 		if (rtlpriv->use_new_trx_flow) {
 			rx_remained_cnt =
@@ -800,6 +807,13 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 				return;
 		}
 
+		/* get a new skb - if fail, old one will be reused */
+		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
+		if (unlikely(!new_skb)) {
+			pr_err("Allocation of new skb failed in %s\n",
+			       __func__);
+			goto no_new;
+		}
 		/* Reaching this point means: data is filled already
 		 * AAAAAAttention !!!
 		 * We can NOT access 'skb' before 'pci_unmap_single'
@@ -911,14 +925,16 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			schedule_work(&rtlpriv->works.lps_change_work);
 		}
 end:
+		skb = new_skb;
+no_new:
 		if (rtlpriv->use_new_trx_flow) {
-			_rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
+			_rtl_pci_init_one_rxdesc(hw, skb, (u8 *)buffer_desc,
 						 rxring_idx,
-					       rtlpci->rx_ring[rxring_idx].idx);
+						 rtlpci->rx_ring[rxring_idx].idx);
 		} else {
-			_rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc, rxring_idx,
+			_rtl_pci_init_one_rxdesc(hw, skb, (u8 *)pdesc,
+						 rxring_idx,
 						 rtlpci->rx_ring[rxring_idx].idx);
-
 			if (rtlpci->rx_ring[rxring_idx].idx ==
 			    rtlpci->rxringcount - 1)
 				rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc,
@@ -1307,7 +1323,7 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 		rtlpci->rx_ring[rxring_idx].idx = 0;
 		for (i = 0; i < rtlpci->rxringcount; i++) {
 			entry = &rtlpci->rx_ring[rxring_idx].buffer_desc[i];
-			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)entry,
+			if (!_rtl_pci_init_one_rxdesc(hw, NULL, (u8 *)entry,
 						      rxring_idx, i))
 				return -ENOMEM;
 		}
@@ -1332,7 +1348,7 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 
 		for (i = 0; i < rtlpci->rxringcount; i++) {
 			entry = &rtlpci->rx_ring[rxring_idx].desc[i];
-			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)entry,
+			if (!_rtl_pci_init_one_rxdesc(hw, NULL, (u8 *)entry,
 						      rxring_idx, i))
 				return -ENOMEM;
 		}
-- 
2.1.2
