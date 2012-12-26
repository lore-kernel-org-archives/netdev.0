From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V3.8 2/5] rtlwifi: rtl8192ce: Fix warning for unchecked pci_map_single() call
Date: Wed, 26 Dec 2012 16:08:08 -0600
Message-ID: <1356559691-5048-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64635 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab2LZWIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 17:08:50 -0500
In-Reply-To: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.8 implements checking of all DMA mapping calls and issues
a WARNING for the first it finds that is not checked.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 1734247..c31795e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -611,8 +611,14 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
 					    skb->data, skb->len,
 					    PCI_DMA_TODEVICE);
+
 	u8 bw_40 = 0;
 
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	rcu_read_lock();
 	sta = get_sta(hw, mac->vif, mac->bssid);
 	if (mac->opmode == NL80211_IFTYPE_STATION) {
@@ -774,6 +780,11 @@ void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)(skb->data);
 	__le16 fc = hdr->frame_control;
 
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
 
 	if (firstseg)
-- 
1.7.10.4
