From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2 3.18] rtlwifi: rtl8192se: Fix connection problems
Date: Fri,  7 Nov 2014 10:05:12 -0600
Message-ID: <1415376312-27158-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:39769 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbaKGQFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 11:05:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in the vendor driver were added to rtlwifi, but some updates
to rtl8192se were missed, and the driver could neither scan nor connect.
There are other changes that will enhance performance, but this minimal
set fix the basic functionality.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - As requested by John Linville, the patch was reduced to its bare essentials
as the first version was too large to be a fix.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/pci.c           |  3 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c  |  7 +++++--
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c |  2 ++
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  | 16 ++++++++++++++++
 4 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 25daa87..2487eee 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -842,7 +842,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			break;
 		}
 		/* handle command packet here */
-		if (rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
+		if (rtlpriv->cfg->ops->rx_command_packet &&
+		    rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
 				dev_kfree_skb_any(skb);
 				goto end;
 		}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 00e0670..5761d5b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1201,6 +1201,9 @@ static int _rtl92se_set_media_status(struct ieee80211_hw *hw,
 
 	}
 
+	if (type != NL80211_IFTYPE_AP &&
+	    rtlpriv->mac80211.link_state < MAC80211_LINKED)
+		bt_msr = rtl_read_byte(rtlpriv, MSR) & ~MSR_LINK_MASK;
 	rtl_write_byte(rtlpriv, (MSR), bt_msr);
 
 	temp = rtl_read_dword(rtlpriv, TCR);
@@ -1262,6 +1265,7 @@ void rtl92se_enable_interrupt(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, INTA_MASK, rtlpci->irq_mask[0]);
 	/* Support Bit 32-37(Assign as Bit 0-5) interrupt setting now */
 	rtl_write_dword(rtlpriv, INTA_MASK + 4, rtlpci->irq_mask[1] & 0x3F);
+	rtlpci->irq_enabled = true;
 }
 
 void rtl92se_disable_interrupt(struct ieee80211_hw *hw)
@@ -1276,8 +1280,7 @@ void rtl92se_disable_interrupt(struct ieee80211_hw *hw)
 	rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	rtl_write_dword(rtlpriv, INTA_MASK, 0);
 	rtl_write_dword(rtlpriv, INTA_MASK + 4, 0);
-
-	synchronize_irq(rtlpci->pdev->irq);
+	rtlpci->irq_enabled = false;
 }
 
 static u8 _rtl92s_set_sysclk(struct ieee80211_hw *hw, u8 data)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index 77c5b5f..4b4612f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -399,6 +399,8 @@ static bool _rtl92s_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 		case 2:
 			currentcmd = &postcommoncmd[*step];
 			break;
+		default:
+			return true;
 		}
 
 		if (currentcmd->cmdid == CMDID_END) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index aadba29..fb00386 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -236,6 +236,19 @@ static void rtl92s_deinit_sw_vars(struct ieee80211_hw *hw)
 	}
 }
 
+static bool rtl92se_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue,
+				      u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
+	u8 own = (u8)rtl92se_get_desc(entry, true, HW_DESC_OWN);
+
+	if (own)
+		return false;
+	return true;
+}
+
 static struct rtl_hal_ops rtl8192se_hal_ops = {
 	.init_sw_vars = rtl92s_init_sw_vars,
 	.deinit_sw_vars = rtl92s_deinit_sw_vars,
@@ -269,6 +282,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops = {
 	.led_control = rtl92se_led_control,
 	.set_desc = rtl92se_set_desc,
 	.get_desc = rtl92se_get_desc,
+	.is_tx_desc_closed = rtl92se_is_tx_desc_closed,
 	.tx_polling = rtl92se_tx_polling,
 	.enable_hw_sec = rtl92se_enable_hw_security_config,
 	.set_key = rtl92se_set_key,
@@ -306,6 +320,8 @@ static struct rtl_hal_cfg rtl92se_hal_cfg = {
 	.maps[MAC_RCR_ACRC32] = RCR_ACRC32,
 	.maps[MAC_RCR_ACF] = RCR_ACF,
 	.maps[MAC_RCR_AAP] = RCR_AAP,
+	.maps[MAC_HIMR] = INTA_MASK,
+	.maps[MAC_HIMRE] = INTA_MASK + 4,
 
 	.maps[EFUSE_TEST] = REG_EFUSE_TEST,
 	.maps[EFUSE_CTRL] = REG_EFUSE_CTRL,
-- 
2.1.2
