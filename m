From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V2 for 3.19 3/7] rtlwifi: rtl8192ee: Fix adhoc fail
Date: Tue, 20 Jan 2015 11:01:22 -0600
Message-ID: <1421773286-1039-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>

When the buffer descriptor index exceeds 2, then a TX HANG condition
will result.

Signed-off-by: Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [V3.18]
---
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c |  6 +-----
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c | 26 --------------------------
 2 files changed, 1 insertion(+), 31 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
index 45c128b..c5d4b80 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
@@ -666,7 +666,6 @@ void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	struct sk_buff *skb = NULL;
 
 	u32 totalpacketlen;
-	bool rtstatus;
 	u8 u1rsvdpageloc[5] = { 0 };
 	bool b_dlok = false;
 
@@ -728,10 +727,7 @@ void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = rtl_cmd_send_packet(hw, skb);
-
-	if (rtstatus)
-		b_dlok = true;
+	b_dlok = true;
 
 	if (b_dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD ,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
index 47beb49..9199559 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
@@ -85,29 +85,6 @@ static void _rtl92ee_enable_bcn_sub_func(struct ieee80211_hw *hw)
 	_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(1));
 }
 
-static void _rtl92ee_return_beacon_queue_skb(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[BEACON_QUEUE];
-	unsigned long flags;
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-	while (skb_queue_len(&ring->queue)) {
-		struct rtl_tx_buffer_desc *entry =
-						&ring->buffer_desc[ring->idx];
-		struct sk_buff *skb = __skb_dequeue(&ring->queue);
-
-		pci_unmap_single(rtlpci->pdev,
-				 rtlpriv->cfg->ops->get_desc(
-				 (u8 *)entry, true, HW_DESC_TXBUFF_ADDR),
-				 skb->len, PCI_DMA_TODEVICE);
-		kfree_skb(skb);
-		ring->idx = (ring->idx + 1) % ring->entries;
-	}
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-}
-
 static void _rtl92ee_disable_bcn_sub_func(struct ieee80211_hw *hw)
 {
 	_rtl92ee_set_bcn_ctrl_reg(hw, BIT(1), 0);
@@ -403,9 +380,6 @@ static void _rtl92ee_download_rsvd_page(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, REG_DWBCN0_CTRL + 2,
 			       bcnvalid_reg | BIT(0));
 
-		/* Return Beacon TCB */
-		_rtl92ee_return_beacon_queue_skb(hw);
