From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V3.8 1/5] rtlwifi: Fix warning for unchecked pci_map_single() call
Date: Wed, 26 Dec 2012 16:08:07 -0600
Message-ID: <1356559691-5048-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42261 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab2LZWIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 17:08:48 -0500
In-Reply-To: <1356559691-5048-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel 3.8 implements checking of all DMA mapping calls and issues
a WARNING for the first it finds that is not checked.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/pci.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 3deacaf..4261e8e 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -743,6 +743,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 
 done:
 		bufferaddress = (*((dma_addr_t *)skb->cb));
+		if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress))
+			return;
 		tmp_one = 1;
 		rtlpriv->cfg->ops->set_desc((u8 *) pdesc, false,
 					    HW_DESC_RXBUFF_ADDR,
@@ -1115,6 +1117,10 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
 					   PCI_DMA_FROMDEVICE);
 
 			bufferaddress = (*((dma_addr_t *)skb->cb));
+			if (pci_dma_mapping_error(rtlpci->pdev, bufferaddress)) {
+				dev_kfree_skb_any(skb);
+				return 1;
+			}
 			rtlpriv->cfg->ops->set_desc((u8 *)entry, false,
 						    HW_DESC_RXBUFF_ADDR,
 						    (u8 *)&bufferaddress);
-- 
1.7.10.4
