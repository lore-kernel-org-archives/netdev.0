From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/7 NEXT] rtlwifi: rtl8188ee: rtl8821ae: Fix a queue locking problem
Date: Fri, 26 Sep 2014 16:40:22 -0500
Message-ID: <1411767628-7965-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411767628-7965-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The code fails to lock the skb queue, which leads to a number of problems.
This patch also fixes a Sparse warning about using a memset of 1 byte.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
---
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c | 2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c | 3 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c | 2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
index eda6617..8d4cf2e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
@@ -770,7 +770,7 @@ void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
-		memset(p2p_ps_offload, 0, 1);
+		memset(p2p_ps_offload, 0, sizeof(*p2p_ps_offload));
 		break;
 	case P2P_PS_ENABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index f74b7fb..f2b9713 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -89,7 +89,9 @@ static void _rtl88ee_return_beacon_queue_skb(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[BEACON_QUEUE];
+	unsigned long flags;
 
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	while (skb_queue_len(&ring->queue)) {
 		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
 		struct sk_buff *skb = __skb_dequeue(&ring->queue);
@@ -101,6 +103,7 @@ static void _rtl88ee_return_beacon_queue_skb(struct ieee80211_hw *hw)
 		kfree_skb(skb);
 		ring->idx = (ring->idx + 1) % ring->entries;
 	}
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 }
 
 static void _rtl88ee_disable_bcn_sub_func(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
index 6f71aaa..2efdb64 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
@@ -1757,7 +1757,7 @@ void rtl8821ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
-		memset(p2p_ps_offload, 0, 1);
+		memset(p2p_ps_offload, 0, sizeof(*p2p_ps_offload));
 		break;
 	case P2P_PS_ENABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
