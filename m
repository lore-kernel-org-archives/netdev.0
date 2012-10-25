From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH NEXT 16/17] rtlwifi: Modify files for addition of rtl8723ae
Date: Thu, 25 Oct 2012 13:46:45 -0500
Message-ID: <1351190806-4258-17-git-send-email-Larry.Finger@lwfinger.net>
References: <1351190806-4258-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351190806-4258-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch modifies the files of rtlwifi for the addition of a new driver
to handle the Realtek RTL8723AE wireless device, and introduces a new
routine to maintaim statistics that will be used later for roaming.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/Kconfig |   11 ++
 drivers/net/wireless/rtlwifi/debug.h |    2 +
 drivers/net/wireless/rtlwifi/pci.h   |    1 +
 drivers/net/wireless/rtlwifi/stats.c |  273 ++++++++++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/stats.h |   46 ++++++
 5 files changed, 333 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/stats.c
 create mode 100644 drivers/net/wireless/rtlwifi/stats.h

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index 6b28e92..21b1bbb 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -32,6 +32,17 @@ config RTL8192DE
 
 	If you choose to build it as a module, it will be called rtl8192de
 
+config RTL8723AE
+	tristate "Realtek RTL8723AE PCIe Wireless Network Adapter"
+	depends on MAC80211 && PCI && EXPERIMENTAL
+	select FW_LOADER
+	select RTLWIFI
+	---help---
+	This is the driver for Realtek RTL8723AE 802.11n PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called rtl8723ae
+
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
 	depends on MAC80211 && USB
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 07493d2..fd3269f 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -106,6 +106,8 @@
 #define COMP_REGD			BIT(27)
 #define COMP_CHAN			BIT(28)
 #define COMP_USB			BIT(29)
+#define COMP_EASY_CONCURRENT	COMP_USB /* reuse of this bit is OK */
+#define COMP_BT_COEXIST			BIT(30)
 
 /*--------------------------------------------------------------
 		Define the rt_print components
diff --git a/drivers/net/wireless/rtlwifi/pci.h b/drivers/net/wireless/rtlwifi/pci.h
index 241448f..b29de93 100644
--- a/drivers/net/wireless/rtlwifi/pci.h
+++ b/drivers/net/wireless/rtlwifi/pci.h
@@ -152,6 +152,7 @@ struct rtl8192_rx_ring {
 
 struct rtl_pci {
 	struct pci_dev *pdev;
+	bool irq_enabled;
 
 	bool driver_is_goingto_unload;
 	bool up_first_time;
diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
new file mode 100644
index 0000000..25f6f42
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -0,0 +1,273 @@
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
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *****************************************************************************/
+#include "wifi.h"
+#include "stats.h"
+#include <linux/export.h>
+
+u8 rtl_query_rxpwrpercentage(char antpower)
+{
+	if ((antpower <= -100) || (antpower >= 20))
+		return 0;
+	else if (antpower >= 0)
+		return 100;
+	else
+		return 100 + antpower;
+}
+EXPORT_SYMBOL(rtl_query_rxpwrpercentage);
+
+u8 rtl_evm_db_to_percentage(char value)
+{
+	char ret_val;
+	ret_val = value;
+
+	if (ret_val >= 0)
+		ret_val = 0;
+	if (ret_val <= -33)
+		ret_val = -33;
+	ret_val = 0 - ret_val;
+	ret_val *= 3;
+	if (ret_val == 99)
+		ret_val = 100;
+
+	return ret_val;
+}
+EXPORT_SYMBOL(rtl_evm_db_to_percentage);
+
+static long rtl_translate_todbm(struct ieee80211_hw *hw,
+				u8 signal_strength_index)
+{
+	long signal_power;
+
+	signal_power = (long)((signal_strength_index + 1) >> 1);
+	signal_power -= 95;
+	return signal_power;
+}
+
+long rtl_signal_scale_mapping(struct ieee80211_hw *hw, long currsig)
+{
+	long retsig;
+
+	if (currsig >= 61 && currsig <= 100)
+		retsig = 90 + ((currsig - 60) / 4);
+	else if (currsig >= 41 && currsig <= 60)
+		retsig = 78 + ((currsig - 40) / 2);
+	else if (currsig >= 31 && currsig <= 40)
+		retsig = 66 + (currsig - 30);
+	else if (currsig >= 21 && currsig <= 30)
+		retsig = 54 + (currsig - 20);
+	else if (currsig >= 5 && currsig <= 20)
+		retsig = 42 + (((currsig - 5) * 2) / 3);
+	else if (currsig == 4)
+		retsig = 36;
+	else if (currsig == 3)
+		retsig = 27;
+	else if (currsig == 2)
+		retsig = 18;
+	else if (currsig == 1)
+		retsig = 9;
+	else
+		retsig = currsig;
+
+	return retsig;
+}
+EXPORT_SYMBOL(rtl_signal_scale_mapping);
+
+static void rtl_process_ui_rssi(struct ieee80211_hw *hw,
+				struct rtl_stats *pstatus)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u8 rfpath;
+	u32 last_rssi, tmpval;
+
+	rtlpriv->stats.rssi_calculate_cnt++;
+
+	if (rtlpriv->stats.ui_rssi.total_num++ >= PHY_RSSI_SLID_WIN_MAX) {
+		rtlpriv->stats.ui_rssi.total_num = PHY_RSSI_SLID_WIN_MAX;
+		last_rssi = rtlpriv->stats.ui_rssi.elements[
+			rtlpriv->stats.ui_rssi.index];
+		rtlpriv->stats.ui_rssi.total_val -= last_rssi;
+	}
+	rtlpriv->stats.ui_rssi.total_val += pstatus->signalstrength;
+	rtlpriv->stats.ui_rssi.elements[rtlpriv->stats.ui_rssi.index++] =
+	    pstatus->signalstrength;
+	if (rtlpriv->stats.ui_rssi.index >= PHY_RSSI_SLID_WIN_MAX)
+		rtlpriv->stats.ui_rssi.index = 0;
+	tmpval = rtlpriv->stats.ui_rssi.total_val /
+		rtlpriv->stats.ui_rssi.total_num;
+	rtlpriv->stats.signal_strength = rtl_translate_todbm(hw,
+		(u8) tmpval);
+	pstatus->rssi = rtlpriv->stats.signal_strength;
+
+	if (pstatus->is_cck)
+		return;
+
+	for (rfpath = RF90_PATH_A; rfpath < rtlphy->num_total_rfpath;
+	     rfpath++) {
+		if (rtlpriv->stats.rx_rssi_percentage[rfpath] == 0) {
+			rtlpriv->stats.rx_rssi_percentage[rfpath] =
+			    pstatus->rx_mimo_signalstrength[rfpath];
+
+		}
+		if (pstatus->rx_mimo_signalstrength[rfpath] >
+		    rtlpriv->stats.rx_rssi_percentage[rfpath]) {
+			rtlpriv->stats.rx_rssi_percentage[rfpath] =
+			    ((rtlpriv->stats.rx_rssi_percentage[rfpath] *
+			      (RX_SMOOTH_FACTOR - 1)) +
+			     (pstatus->rx_mimo_signalstrength[rfpath])) /
+			    (RX_SMOOTH_FACTOR);
+			rtlpriv->stats.rx_rssi_percentage[rfpath] =
+			    rtlpriv->stats.rx_rssi_percentage[rfpath] + 1;
+		} else {
+			rtlpriv->stats.rx_rssi_percentage[rfpath] =
+			    ((rtlpriv->stats.rx_rssi_percentage[rfpath] *
+			      (RX_SMOOTH_FACTOR - 1)) +
+			     (pstatus->rx_mimo_signalstrength[rfpath])) /
+			    (RX_SMOOTH_FACTOR);
+		}
+	}
+}
+
+static void rtl_update_rxsignalstatistics(struct ieee80211_hw *hw,
+					  struct rtl_stats *pstatus)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int weighting = 0;
+
+	if (rtlpriv->stats.recv_signal_power == 0)
+		rtlpriv->stats.recv_signal_power = pstatus->recvsignalpower;
+	if (pstatus->recvsignalpower > rtlpriv->stats.recv_signal_power)
+		weighting = 5;
+	else if (pstatus->recvsignalpower < rtlpriv->stats.recv_signal_power)
+		weighting = (-5);
+	rtlpriv->stats.recv_signal_power = (rtlpriv->stats.recv_signal_power *
+		5 + pstatus->recvsignalpower + weighting) / 6;
+}
+
+static void rtl_process_pwdb(struct ieee80211_hw *hw, struct rtl_stats *pstatus)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_sta_info *drv_priv = NULL;
+	struct ieee80211_sta *sta = NULL;
+	long undecorated_smoothed_pwdb;
+
+	rcu_read_lock();
+	if (rtlpriv->mac80211.opmode != NL80211_IFTYPE_STATION)
+		sta = rtl_find_sta(hw, pstatus->psaddr);
+
+	/* adhoc or ap mode */
+	if (sta) {
+		drv_priv = (struct rtl_sta_info *) sta->drv_priv;
+		undecorated_smoothed_pwdb =
+			drv_priv->rssi_stat.undecorated_smoothed_pwdb;
+	} else {
+		undecorated_smoothed_pwdb =
+			rtlpriv->dm.undecorated_smoothed_pwdb;
+	}
+
+	if (undecorated_smoothed_pwdb < 0)
+		undecorated_smoothed_pwdb = pstatus->rx_pwdb_all;
+	if (pstatus->rx_pwdb_all > (u32) undecorated_smoothed_pwdb) {
+		undecorated_smoothed_pwdb = (((undecorated_smoothed_pwdb) *
+		      (RX_SMOOTH_FACTOR - 1)) +
+		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
+		undecorated_smoothed_pwdb = undecorated_smoothed_pwdb + 1;
+	} else {
+		undecorated_smoothed_pwdb = (((undecorated_smoothed_pwdb) *
+		      (RX_SMOOTH_FACTOR - 1)) +
+		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
+	}
+
+	if (sta) {
+		drv_priv->rssi_stat.undecorated_smoothed_pwdb =
+			undecorated_smoothed_pwdb;
+	} else {
+		rtlpriv->dm.undecorated_smoothed_pwdb =
+					 undecorated_smoothed_pwdb;
+	}
+	rcu_read_unlock();
+
+	rtl_update_rxsignalstatistics(hw, pstatus);
+}
+
+static void rtl_process_ui_link_quality(struct ieee80211_hw *hw,
+					struct rtl_stats *pstatus)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 last_evm, n_stream, tmpval;
+
+	if (pstatus->signalquality == 0)
+		return;
+
+	if (rtlpriv->stats.ui_link_quality.total_num++ >=
+	    PHY_LINKQUALITY_SLID_WIN_MAX) {
+		rtlpriv->stats.ui_link_quality.total_num =
+		    PHY_LINKQUALITY_SLID_WIN_MAX;
+		last_evm = rtlpriv->stats.ui_link_quality.elements[
+			rtlpriv->stats.ui_link_quality.index];
+		rtlpriv->stats.ui_link_quality.total_val -= last_evm;
+	}
+	rtlpriv->stats.ui_link_quality.total_val += pstatus->signalquality;
+	rtlpriv->stats.ui_link_quality.elements[
+		rtlpriv->stats.ui_link_quality.index++] =
+						 pstatus->signalquality;
+	if (rtlpriv->stats.ui_link_quality.index >=
+	    PHY_LINKQUALITY_SLID_WIN_MAX)
+		rtlpriv->stats.ui_link_quality.index = 0;
+	tmpval = rtlpriv->stats.ui_link_quality.total_val /
+	    rtlpriv->stats.ui_link_quality.total_num;
+	rtlpriv->stats.signal_quality = tmpval;
+	rtlpriv->stats.last_sigstrength_inpercent = tmpval;
+	for (n_stream = 0; n_stream < 2; n_stream++) {
+		if (pstatus->rx_mimo_sig_qual[n_stream] != -1) {
+			if (rtlpriv->stats.rx_evm_percentage[n_stream] == 0) {
+				rtlpriv->stats.rx_evm_percentage[n_stream] =
+				    pstatus->rx_mimo_sig_qual[n_stream];
+			}
+			rtlpriv->stats.rx_evm_percentage[n_stream] =
+			    ((rtlpriv->stats.rx_evm_percentage[n_stream]
+			      * (RX_SMOOTH_FACTOR - 1)) +
+			     (pstatus->rx_mimo_sig_qual[n_stream] * 1)) /
+			    (RX_SMOOTH_FACTOR);
+		}
+	}
+}
+
+void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
+	struct rtl_stats *pstatus)
+{
+
+	if (!pstatus->packet_matchbssid)
+		return;
+
+	rtl_process_ui_rssi(hw, pstatus);
+	rtl_process_pwdb(hw, pstatus);
+	rtl_process_ui_link_quality(hw, pstatus);
+}
+EXPORT_SYMBOL(rtl_process_phyinfo);
diff --git a/drivers/net/wireless/rtlwifi/stats.h b/drivers/net/wireless/rtlwifi/stats.h
new file mode 100644
index 0000000..0dbdc52
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/stats.h
@@ -0,0 +1,46 @@
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
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL_STATS_H__
+#define __RTL_STATS_H__
+
+#define	PHY_RSSI_SLID_WIN_MAX			100
+#define	PHY_LINKQUALITY_SLID_WIN_MAX		20
+#define	PHY_BEACON_RSSI_SLID_WIN_MAX		10
+
+/* Rx smooth factor */
+#define	RX_SMOOTH_FACTOR			20
+
+u8 rtl_query_rxpwrpercentage(char antpower);
+u8 rtl_evm_db_to_percentage(char value);
+long rtl_signal_scale_mapping(struct ieee80211_hw *hw, long currsig);
+void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
+	struct rtl_stats *pstatus);
+
+#endif
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
