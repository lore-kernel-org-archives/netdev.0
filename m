From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/3 for 3.18] rtlwifi: rtl8192ce: Fix kernel crashes due to missing callback entry
Date: Fri, 28 Nov 2014 10:41:15 -0600
Message-ID: <1417192876-12101-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1417192876-12101-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417192876-12101-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In the major update of the rtlwifi-family of drivers, one of the callback entries
was missed, which leads to memory corruption. Unfortunately, this corruption
never caused a kernel oops, but showed up in other parts of the system.
This patch is one of three needed to fix the kernel regression reported at
https://bugzilla.kernel.org/show_bug.cgi?id=88951.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Reported-by: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Tested-by: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Catalin Iacob <iacobcatalin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |  3 +++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 17 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h |  2 ++
 3 files changed, 22 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 46ea076..dd5aa08 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -228,6 +228,7 @@ static struct rtl_hal_ops rtl8192ce_hal_ops = {
 	.led_control = rtl92ce_led_control,
 	.set_desc = rtl92ce_set_desc,
 	.get_desc = rtl92ce_get_desc,
+	.is_tx_desc_closed = rtl92ce_is_tx_desc_closed,
 	.tx_polling = rtl92ce_tx_polling,
 	.enable_hw_sec = rtl92ce_enable_hw_security_config,
 	.set_key = rtl92ce_set_key,
@@ -271,6 +272,8 @@ static struct rtl_hal_cfg rtl92ce_hal_cfg = {
 	.maps[MAC_RCR_ACRC32] = ACRC32,
 	.maps[MAC_RCR_ACF] = ACF,
 	.maps[MAC_RCR_AAP] = AAP,
+	.maps[MAC_HIMR] = REG_HIMR,
+	.maps[MAC_HIMRE] = REG_HIMRE,
 
 	.maps[EFUSE_TEST] = REG_EFUSE_TEST,
 	.maps[EFUSE_CTRL] = REG_EFUSE_CTRL,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 0916275..e88dcd0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -739,6 +739,23 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_name)
 	return ret;
 }
 
+bool rtl92ce_is_tx_desc_closed(struct ieee80211_hw *hw,
+			       u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
+	u8 own = (u8)rtl92ce_get_desc(entry, true, HW_DESC_OWN);
+
+	/*beacon packet will only use the first
+	 *descriptor defautly,and the own may not
+	 *be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	return true;
+}
+
 void rtl92ce_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
index 9a39ec4..4bec4b0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.h
@@ -723,6 +723,8 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 void rtl92ce_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 		      u8 desc_name, u8 *val);
 u32 rtl92ce_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl92ce_is_tx_desc_closed(struct ieee80211_hw *hw,
+			       u8 hw_queue, u16 index);
 void rtl92ce_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
 void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			     bool b_firstseg, bool b_lastseg,
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
