From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 14/27] rtlwifi: rtl8188ee: Add files for new driver - part 5
Date: Mon, 25 Feb 2013 18:13:26 -0600
Message-ID: <1361837619-2985-15-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:44104 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932199Ab3BZAO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:28 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c | 158 +++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/led.h |  38 +++++++
 2 files changed, 196 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/led.h

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/led.c b/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
new file mode 100644
index 0000000..7fac87f
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
@@ -0,0 +1,158 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "reg.h"
+#include "led.h"
+
+static void _rtl88ee_init_led(struct ieee80211_hw *hw,
+			      struct rtl_led *pled, enum rtl_led_pin ledpin)
+{
+	pled->hw = hw;
+	pled->ledpin = ledpin;
+	pled->ledon = false;
+}
+
+void rtl88ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
+{
+	u8 ledcfg;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin);
+
+
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
+		rtl_write_byte(rtlpriv,
+			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5) | BIT(6));
+		break;
+	case LED_PIN_LED1:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg & 0x10);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not processed\n");
+		break;
+	}
+	pled->ledon = true;
+}
+
+void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	u8 ledcfg;
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin);
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
+		ledcfg &= 0xf0;
+		if (pcipriv->ledctl.led_opendrain == true) {
+			rtl_write_byte(rtlpriv, REG_LEDCFG2,
+				       (ledcfg | BIT(3) | BIT(5) | BIT(6)));
+			ledcfg = rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
+			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG,
+				       ledcfg & 0xFE);
+		} else {
+			rtl_write_byte(rtlpriv, REG_LEDCFG2,
+				       (ledcfg | BIT(3) | BIT(5) | BIT(6)));
+		}
+		break;
+	case LED_PIN_LED1:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		ledcfg &= 0x10;
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, (ledcfg | BIT(3)));
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not processed\n");
+		break;
+	}
+	pled->ledon = false;
+}
+
+void rtl88ee_init_sw_leds(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	_rtl88ee_init_led(hw, &(pcipriv->ledctl.sw_led0), LED_PIN_LED0);
+	_rtl88ee_init_led(hw, &(pcipriv->ledctl.sw_led1), LED_PIN_LED1);
+}
+
+static void _rtl88ee_sw_led_control(struct ieee80211_hw *hw,
+				    enum led_ctl_mode ledaction)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
+	switch (ledaction) {
+	case LED_CTL_POWER_ON:
+	case LED_CTL_LINK:
+	case LED_CTL_NO_LINK:
+		rtl88ee_sw_led_on(hw, pLed0);
+		break;
+	case LED_CTL_POWER_OFF:
+		rtl88ee_sw_led_off(hw, pLed0);
+		break;
+	default:
+		break;
+	}
+}
+
+void rtl88ee_led_control(struct ieee80211_hw *hw,
+			enum led_ctl_mode ledaction)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+
+	if ((ppsc->rfoff_reason > RF_CHANGE_BY_PS) &&
+	    (ledaction == LED_CTL_TX ||
+	     ledaction == LED_CTL_RX ||
+	     ledaction == LED_CTL_SITE_SURVEY ||
+	     ledaction == LED_CTL_LINK ||
+	     ledaction == LED_CTL_NO_LINK ||
+	     ledaction == LED_CTL_START_TO_LINK ||
+	     ledaction == LED_CTL_POWER_ON)) {
+		return;
+	}
+	RT_TRACE(rtlpriv, COMP_LED, DBG_TRACE, "ledaction %d,\n",
+		 ledaction);
+	_rtl88ee_sw_led_control(hw, ledaction);
+}
+
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/led.h b/drivers/net/wireless/rtlwifi/rtl8188ee/led.h
new file mode 100644
index 0000000..4073f6f
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/led.h
@@ -0,0 +1,38 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92CE_LED_H__
+#define __RTL92CE_LED_H__
+
+void rtl88ee_init_sw_leds(struct ieee80211_hw *hw);
+void rtl88ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl88ee_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction);
+
+#endif
-- 
1.8.1.4
