From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 6/7 NEXT] rtlwifi: rtl8188ee: rtl8192com: rtl8192cu: rtl8192ee: rtl8723ae: rtl87323be: rtl8821ae: Use common cmd_send_packet
Date: Fri, 26 Sep 2014 16:40:27 -0500
Message-ID: <1411767628-7965-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:55324 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066AbaIZVk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:40:56 -0400
In-Reply-To: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A locking problem was found in routine _rtl92ee_cmd_send_packet() that led
to system freezes. Upon inspection, several drivers had the same problem;
however, the routines all used the same code. The common code has been
moved into rtlwifi.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/core.c               | 31 ++++++++++++++++++
 drivers/net/wireless/rtlwifi/core.h               |  1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c       | 36 ++-------------------
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c | 36 ++-------------------
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c       |  1 -
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c       | 34 ++------------------
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c       |  3 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c       |  3 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c       | 38 ++---------------------
 drivers/net/wireless/rtlwifi/wifi.h               |  1 -
 10 files changed, 45 insertions(+), 139 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index d30f416..2a6e84b 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1798,3 +1798,34 @@ bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
 	return true;
 }
 EXPORT_SYMBOL(rtl_hal_pwrseqcmdparsing);
+
+bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring;
+	struct rtl_tx_desc *pdesc;
+	unsigned long flags;
+	struct sk_buff *pskb = NULL;
+
+	ring = &rtlpci->tx_ring[BEACON_QUEUE];
+
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
+	pskb = __skb_dequeue(&ring->queue);
+	if (pskb)
+		kfree_skb(pskb);
+
+	/*this is wrong, fill_tx_cmddesc needs update*/
+	pdesc = &ring->desc[0];
+
+	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
+
+	__skb_queue_tail(&ring->queue, skb);
+
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+
+	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
+
+	return true;
+}
+EXPORT_SYMBOL(rtl_cmd_send_packet);
diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtlwifi/core.h
index cdd4727..59cd3b9 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -41,5 +41,6 @@ void rtl_addr_delay(u32 addr);
 void rtl_rfreg_delay(struct ieee80211_hw *hw, enum radio_path rfpath, u32 addr,
 		     u32 mask, u32 data);
 void rtl_bb_delay(struct ieee80211_hw *hw, u32 addr, u32 data);
+bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
index 8d4cf2e..c8058aa 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "fw.h"
@@ -512,39 +513,6 @@ void rtl88e_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
 
 }
 
-static bool _rtl88e_cmd_send_packet(struct ieee80211_hw *hw,
-				    struct sk_buff *skb)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring;
-	struct rtl_tx_desc *pdesc;
-	struct sk_buff *pskb = NULL;
-	u8 own;
-	unsigned long flags;
-
-	ring = &rtlpci->tx_ring[BEACON_QUEUE];
-
-	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-
-	pdesc = &ring->desc[0];
-	own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
-
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
-
-	__skb_queue_tail(&ring->queue, skb);
-
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
-
-	return true;
-}
-
 #define BEACON_PG		0 /* ->1 */
 #define PSPOLL_PG		2
 #define NULL_PG			3
@@ -730,7 +698,7 @@ void rtl88e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	memcpy(skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = _rtl88e_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 6a57e6d..a00861b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 #include "../rtl8192ce/reg.h"
 #include "../rtl8192ce/def.h"
 #include "fw_common.h"
@@ -538,39 +539,6 @@ void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 }
 EXPORT_SYMBOL(rtl92c_set_fw_pwrmode_cmd);
 
-static bool _rtl92c_cmd_send_packet(struct ieee80211_hw *hw,
-				struct sk_buff *skb)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring;
-	struct rtl_tx_desc *pdesc;
-	u8 own;
-	unsigned long flags;
-	struct sk_buff *pskb = NULL;
-
-	ring = &rtlpci->tx_ring[BEACON_QUEUE];
-
-	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-
-	pdesc = &ring->desc[0];
-	own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
-
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
-
-	__skb_queue_tail(&ring->queue, skb);
-
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
-
-	return true;
-}
-
 #define BEACON_PG		0 /*->1*/
 #define PSPOLL_PG		2
 #define NULL_PG			3
@@ -754,7 +722,7 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = _rtl92c_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index f72f0db..7c5fbaf 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -122,7 +122,6 @@ static struct rtl_hal_ops rtl8192cu_hal_ops = {
 	.fill_tx_desc = rtl92cu_tx_fill_desc,
 	.fill_fake_txdesc = rtl92cu_fill_fake_txdesc,
 	.fill_tx_cmddesc = rtl92cu_tx_fill_cmddesc,
-	.cmd_send_packet = rtl92cu_cmd_send_packet,
 	.query_rx_desc = rtl92cu_rx_query_desc,
 	.set_channel_access = rtl92cu_update_channel_access_setting,
 	.radio_onoff_checking = rtl92cu_gpio_radio_on_off_checking,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
index 3c4a9a9..45c128b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/fw.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "fw.h"
@@ -541,37 +542,6 @@ void rtl92ee_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw, u8 mstatus)
 	rtl92ee_fill_h2c_cmd(hw, H2C_92E_MSRRPT, 3, parm);
 }
 
-static bool _rtl92ee_cmd_send_packet(struct ieee80211_hw *hw,
-				     struct sk_buff *skb)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring;
-	struct rtl_tx_desc *pdesc;
-	unsigned long flags;
-	struct sk_buff *pskb = NULL;
-
-	ring = &rtlpci->tx_ring[BEACON_QUEUE];
-
-	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-	/*this is wrong, fill_tx_cmddesc needs update*/
-	pdesc = &ring->desc[0];
-
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
-
-	__skb_queue_tail(&ring->queue, skb);
-
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
-
-	return true;
-}
-
 #define BEACON_PG		0 /* ->1 */
 #define PSPOLL_PG		2
 #define NULL_PG			3
@@ -758,7 +728,7 @@ void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = _rtl92ee_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
index 97d92e2..b7c0d38 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "fw.h"
@@ -473,7 +474,7 @@ void rtl8723e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = rtl8723_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
index 0c07992..69d4f0f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "fw.h"
@@ -467,7 +468,7 @@ void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = rtl8723_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
index 2efdb64..95e9562 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
@@ -26,6 +26,7 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../base.h"
+#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "fw.h"
@@ -742,39 +743,6 @@ void rtl8821ae_set_fw_global_info_cmd(struct ieee80211_hw *hw)
 		      remote_wakeup_sec_info, H2C_8821AE_AOAC_GLOBAL_INFO_LEN);
 }
 
-static bool _rtl8821ae_cmd_send_packet(struct ieee80211_hw *hw,
-				struct sk_buff *skb)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring;
-	struct rtl_tx_desc *pdesc;
-	struct sk_buff *pskb = NULL;
-	u8 own;
-	unsigned long flags;
-
-	ring = &rtlpci->tx_ring[BEACON_QUEUE];
-
-	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-
-	pdesc = &ring->desc[0];
-	own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
-
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
-
-	__skb_queue_tail(&ring->queue, skb);
-
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
-
-	return true;
-}
-
 #define BEACON_PG		0
 #define PSPOLL_PG		1
 #define NULL_PG			2
@@ -1581,7 +1549,7 @@ out:
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet_8812, totalpacketlen);
 
-	rtstatus = _rtl8821ae_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
@@ -1706,7 +1674,7 @@ out:
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet_8821, totalpacketlen);
 
-	rtstatus = _rtl8821ae_cmd_send_packet(hw, skb);
+	rtstatus = rtl_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
 		b_dlok = true;
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 050a242..c2b4786 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -2101,7 +2101,6 @@ struct rtl_hal_ops {
 	void (*fill_tx_cmddesc) (struct ieee80211_hw *hw, u8 *pdesc,
 				 bool firstseg, bool lastseg,
 				 struct sk_buff *skb);
-	bool (*cmd_send_packet)(struct ieee80211_hw *hw, struct sk_buff *skb);
 	bool (*query_rx_desc) (struct ieee80211_hw *hw,
 			       struct rtl_stats *stats,
 			       struct ieee80211_rx_status *rx_status,
-- 
1.8.4.5
