From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2 for 3.19 2/7] rtlwifi: rtl8192ee: Fix handling of new style descriptors
Date: Tue, 20 Jan 2015 11:01:21 -0600
Message-ID: <1421773286-1039-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:54203 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbbATRBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 12:01:43 -0500
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Tan <troy_tan@realsil.com.cn>

The hardware and firmware for the RTL8192EE utilize a FIFO list of
descriptors. There were some problems with the initial implementation.
The worst of these failed to detect that the FIFO was becoming full,
which led to the device needing to be power cycled. As this condition
is not relevant to most of the devices supported by rtlwifi, a callback
routine was added to detect this situation. This patch implements the
necessary changes in the pci handler, and the linkage into the appropriate
rtl8192ee routine.

Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [V3.18]
---
 drivers/net/wireless/rtlwifi/pci.c           | 31 +++++++++++++++++++++-------
 drivers/net/wireless/rtlwifi/rtl8192ee/sw.c  |  3 +--
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h |  2 +-
 drivers/net/wireless/rtlwifi/wifi.h          |  1 +
 5 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index e25faac..a62170e 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -578,6 +578,13 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 		else
 			entry = (u8 *)(&ring->desc[ring->idx]);
 
+		if (rtlpriv->cfg->ops->get_available_desc &&
+		    rtlpriv->cfg->ops->get_available_desc(hw, prio) <= 1) {
+			RT_TRACE(rtlpriv, (COMP_INTR | COMP_SEND), DBG_DMESG,
+				 "no available desc!\n");
+			return;
+		}
+
 		if (!rtlpriv->cfg->ops->is_tx_desc_closed(hw, prio, ring->idx))
 			return;
 		ring->idx = (ring->idx + 1) % ring->entries;
@@ -641,10 +648,9 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 
 		ieee80211_tx_status_irqsafe(hw, skb);
 
-		if ((ring->entries - skb_queue_len(&ring->queue))
-				== 2) {
+		if ((ring->entries - skb_queue_len(&ring->queue)) <= 4) {
 
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 				 "more desc left, wake skb_queue@%d, ring->idx = %d, skb_queue_len = 0x%x\n",
 				 prio, ring->idx,
 				 skb_queue_len(&ring->queue));
@@ -793,7 +799,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			rx_remained_cnt =
 				rtlpriv->cfg->ops->rx_desc_buff_remained_cnt(hw,
 								      hw_queue);
-			if (rx_remained_cnt < 1)
+			if (rx_remained_cnt == 0)
 				return;
 
 		} else {	/* rx descriptor */
@@ -845,18 +851,18 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			else
 				skb_reserve(skb, stats.rx_drvinfo_size +
 					    stats.rx_bufshift);
-
 		} else {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 				 "skb->end - skb->tail = %d, len is %d\n",
 				 skb->end - skb->tail, len);
-			break;
+			dev_kfree_skb_any(skb);
+			goto new_trx_end;
 		}
 		/* handle command packet here */
 		if (rtlpriv->cfg->ops->rx_command_packet &&
 		    rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
 				dev_kfree_skb_any(skb);
-				goto end;
+				goto new_trx_end;
 		}
 
 		/*
@@ -906,6 +912,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		} else {
 			dev_kfree_skb_any(skb);
 		}
+new_trx_end:
 		if (rtlpriv->use_new_trx_flow) {
 			rtlpci->rx_ring[hw_queue].next_rx_rp += 1;
 			rtlpci->rx_ring[hw_queue].next_rx_rp %=
@@ -921,7 +928,6 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			rtlpriv->enter_ps = false;
 			schedule_work(&rtlpriv->works.lps_change_work);
 		}
-end:
 		skb = new_skb;
 no_new:
 		if (rtlpriv->use_new_trx_flow) {
@@ -1685,6 +1691,15 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 		}
 	}
 
+	if (rtlpriv->cfg->ops->get_available_desc &&
+	    rtlpriv->cfg->ops->get_available_desc(hw, hw_queue) == 0) {
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+				 "get_available_desc fail\n");
+			spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock,
+					       flags);
+			return skb->len;
+	}
+
 	if (ieee80211_is_data_qos(fc)) {
 		tid = rtl_get_tid(skb);
 		if (sta) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
index f30c916..27e28f1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/sw.c
@@ -113,8 +113,6 @@ int rtl92ee_init_sw_vars(struct ieee80211_hw *hw)
 				  RCR_HTC_LOC_CTRL		|
 				  RCR_AMF			|
 				  RCR_ACF			|
-				  RCR_ADF			|
-				  RCR_AICV			|
 				  RCR_ACRC32			|
 				  RCR_AB			|
 				  RCR_AM			|
@@ -241,6 +239,7 @@ static struct rtl_hal_ops rtl8192ee_hal_ops = {
 	.set_desc = rtl92ee_set_desc,
 	.get_desc = rtl92ee_get_desc,
 	.is_tx_desc_closed = rtl92ee_is_tx_desc_closed,
+	.get_available_desc = rtl92ee_get_available_desc,
 	.tx_polling = rtl92ee_tx_polling,
 	.enable_hw_sec = rtl92ee_enable_hw_security_config,
 	.init_sw_leds = rtl92ee_init_sw_leds,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index 51806ac..0a006c4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -551,7 +551,7 @@ static u16 get_desc_addr_fr_q_idx(u16 queue_index)
 	return desc_address;
 }
 
-void rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
+u16 rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -570,6 +570,7 @@ void rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
 		       current_tx_read_point));
 
 	rtlpci->tx_ring[q_idx].avl_desc = point_diff;
+	return point_diff;
 }
 
 void rtl92ee_pre_fill_tx_bd_desc(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
index 45fd9db..c56f305 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.h
@@ -829,7 +829,7 @@ void rtl92ee_rx_check_dma_ok(struct ieee80211_hw *hw, u8 *header_desc,
 			     u8 queue_index);
 u16	rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw,
 					  u8 queue_index);
-void rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 queue_index);
+u16 rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 queue_index);
 void rtl92ee_pre_fill_tx_bd_desc(struct ieee80211_hw *hw,
 				 u8 *tx_bd_desc, u8 *desc, u8 queue_index,
 				 struct sk_buff *skb, dma_addr_t addr);
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 3b3453a..413c2ab 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -2172,6 +2172,7 @@ struct rtl_hal_ops {
 	void (*add_wowlan_pattern)(struct ieee80211_hw *hw,
 				   struct rtl_wow_pattern *rtl_pattern,
 				   u8 index);
+	u16 (*get_available_desc)(struct ieee80211_hw *hw, u8 q_idx);
 };
 
 struct rtl_intf_ops {
-- 
2.1.2
