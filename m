From: Bharat Kumar Gogada <bharat.kumar.gogada@xilinx.com>
Subject: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware interrupts after enabling local irq flags
Date: Thu, 19 Jan 2017 15:44:14 +0530
Message-ID: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kvalo@codeaurora.org>, <netdev@vger.kernel.org>,
        <rgummal@xilinx.com>, Bharat Kumar Gogada <bharatku@xilinx.com>
To: <Larry.Finger@lwfinger.net>, <chaoming_li@realsil.com.cn>,
        <linux-wireless@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0077.outbound.protection.outlook.com ([104.47.33.77]:36295
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750894AbdASKah (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 05:30:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-Realtek 8192CE chipset maintains local irq flags after enabling/disabling
hardware interrupts. 
-Hardware interrupts are enabled before enabling the local irq 
flags(these flags are being checked in interrupt handler), 
leading to race condition on some RP, where the irq line between 
bridge and GIC goes high at ASSERT_INTx and goes low only 
at DEASSERT_INTx. In this kind of RP by the time ASSERT_INTx is seen
irq_enable flag is still set to false, resulting in continuous 
interrupts seen by CPU as DEASSERT_INTx cannot be sent since 
flag is still false and making CPU stall.
-Changing the sequence of setting these irq flags.

Signed-off-by: Bharat Kumar Gogada <bharatku@xilinx.com>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
index a47be73..143766c4 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
@@ -1306,9 +1306,9 @@ void rtl92ce_enable_interrupt(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
+	rtlpci->irq_enabled = true;
 	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
 	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
-	rtlpci->irq_enabled = true;
 }
 
 void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
@@ -1316,9 +1316,9 @@ void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
+	rtlpci->irq_enabled = false;
 	rtl_write_dword(rtlpriv, REG_HIMR, IMR8190_DISABLED);
 	rtl_write_dword(rtlpriv, REG_HIMRE, IMR8190_DISABLED);
-	rtlpci->irq_enabled = false;
 }
 
 static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
-- 
2.1.1
