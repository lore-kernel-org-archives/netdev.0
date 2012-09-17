From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/15] rtlwifi: rtl8723ae: Add new driver - Part 6
Date: Mon, 17 Sep 2012 16:18:45 -0500
Message-ID: <1347916754-9219-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, <chaoming_li@realsil.com.cn>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61147 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab2IQVTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 17:19:33 -0400
In-Reply-To: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is part 6 of the addition of files for a new driver to handle
the Realtek RTL8723AE wireless device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: <chaoming_li@realsil.com.cn>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c |  158 ++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h |   40 +++++++
 2 files changed, 198 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.h

Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
@@ -0,0 +1,157 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
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
+static void _rtl8723ae_init_led(struct ieee80211_hw *hw,
+				struct rtl_led *pled, enum rtl_led_pin ledpin)
+{
+	pled->hw = hw;
+	pled->ledpin = ledpin;
+	pled->ledon = false;
+}
+
+void rtl8723ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 ledcfg;
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
+		rtl_write_byte(rtlpriv,
+			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5));
+		break;
+	case LED_PIN_LED1:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg & 0x10);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	}
+	pled->ledon = true;
+}
+
+void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	u8 ledcfg;
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
+
+	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg &= 0xf0;
+		if (pcipriv->ledctl.led_opendrain == true) {
+			ledcfg &= 0x90; /* Set to software control. */
+			rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg|BIT(3)));
+			ledcfg = rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
+			ledcfg &= 0xFE;
+			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG, ledcfg);
+		} else {
+			rtl_write_byte(rtlpriv, REG_LEDCFG2,
+				       (ledcfg | BIT(3) | BIT(5)));
+		}
+		break;
+	case LED_PIN_LED1:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		ledcfg &= 0x10; /* Set to software control. */
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg|BIT(3));
+
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	}
+	pled->ledon = false;
+}
+
+void rtl8723ae_init_sw_leds(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+
+	_rtl8723ae_init_led(hw, &(pcipriv->ledctl.sw_led0), LED_PIN_LED0);
+	_rtl8723ae_init_led(hw, &(pcipriv->ledctl.sw_led1), LED_PIN_LED1);
+}
+
+static void _rtl8723ae_sw_led_control(struct ieee80211_hw *hw,
+				    enum led_ctl_mode ledaction)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
+
+	switch (ledaction) {
+	case LED_CTL_POWER_ON:
+	case LED_CTL_LINK:
+	case LED_CTL_NO_LINK:
+		rtl8723ae_sw_led_on(hw, pLed0);
+		break;
+	case LED_CTL_POWER_OFF:
+		rtl8723ae_sw_led_off(hw, pLed0);
+		break;
+	default:
+		break;
+	}
+}
+
+void rtl8723ae_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction)
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
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d,\n", ledaction);
+	_rtl8723ae_sw_led_control(hw, ledaction);
+}
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/led.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/led.h
@@ -0,0 +1,39 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
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
+void rtl8723ae_init_sw_leds(struct ieee80211_hw *hw);
+void rtl8723ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl8723ae_led_control(struct ieee80211_hw *hw,
+			   enum led_ctl_mode ledaction);
+
+#endif
