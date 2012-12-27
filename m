From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3.8 4/5 V2] rtlwifi: rtl8192se: Fix warning for unchecked pci_map_single() call
Date: Thu, 27 Dec 2012 10:37:31 -0600
Message-ID: <1356626252-4058-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1356626252-4058-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40863 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203Ab2L0Qhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 11:37:55 -0500
In-Reply-To: <1356626252-4058-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.8 implements checking of all DMA mapping calls and issues
a WARNING for the first it finds that is not checked.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

v2 - Copy-and-paste error fixed.

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 0e9f6eb..206561d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -611,6 +611,11 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 		    PCI_DMA_TODEVICE);
 	u8 bw_40 = 0;
 
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	if (mac->opmode == NL80211_IFTYPE_STATION) {
 		bw_40 = mac->bw_40;
 	} else if (mac->opmode == NL80211_IFTYPE_AP ||
@@ -763,6 +768,7 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 void rtl92se_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 	bool firstseg, bool lastseg, struct sk_buff *skb)
 {
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_tcb_desc *tcb_desc = (struct rtl_tcb_desc *)(skb->cb);
@@ -770,7 +776,12 @@ void rtl92se_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 	dma_addr_t mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
 			PCI_DMA_TODEVICE);
 
-    /* Clear all status	*/
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
+	/* Clear all status	*/
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_CMDDESC_SIZE_RTL8192S);
 
 	/* This bit indicate this packet is used for FW download. */
-- 
1.7.10.4
