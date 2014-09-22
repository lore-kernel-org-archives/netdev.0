From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 04/11 NEXT] rtlwifi: Modify core.c for new drivers
Date: Mon, 22 Sep 2014 09:39:20 -0500
Message-ID: <1411396767-20611-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Each of the routines in the rtlwifi common driver needs to be modified
for the coming changes. This patch prepares core.c, but also touches other
files.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/base.c |   8 +-
 drivers/net/wireless/rtlwifi/base.h |   8 +-
 drivers/net/wireless/rtlwifi/core.c | 745 +++++++++++++++++++++++++-----------
 drivers/net/wireless/rtlwifi/wifi.h |  76 ++++
 4 files changed, 603 insertions(+), 234 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 3b599b6..8234cdb 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1128,8 +1128,8 @@ EXPORT_SYMBOL_GPL(rtl_is_special_data);
  * functions called by core.c
  *
  *********************************************************/
-int rtl_tx_agg_start(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u16 tid, u16 *ssn)
+int rtl_tx_agg_start(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
+		     struct ieee80211_sta *sta, u16 tid, u16 *ssn)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_tid_data *tid_data;
@@ -1158,8 +1158,8 @@ int rtl_tx_agg_start(struct ieee80211_hw *hw,
 	return 0;
 }
 
-int rtl_tx_agg_stop(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u16 tid)
+int rtl_tx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
+		    struct ieee80211_sta *sta, u16 tid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
diff --git a/drivers/net/wireless/rtlwifi/base.h b/drivers/net/wireless/rtlwifi/base.h
index 0cd0742..eaa5110 100644
--- a/drivers/net/wireless/rtlwifi/base.h
+++ b/drivers/net/wireless/rtlwifi/base.h
@@ -120,10 +120,10 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx);
 u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx);
 
 void rtl_watch_dog_timer_callback(unsigned long data);
-int rtl_tx_agg_start(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
-		     u16 tid, u16 *ssn);
-int rtl_tx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
-		    u16 tid);
+int rtl_tx_agg_start(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
+		     struct ieee80211_sta *sta, u16 tid, u16 *ssn);
+int rtl_tx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
+		    struct ieee80211_sta *sta, u16 tid);
 int rtl_tx_agg_oper(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
 		    u16 tid);
 int rtl_rx_agg_start(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 98e564d..40738e3 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -31,10 +27,12 @@
 #include "core.h"
 #include "cam.h"
 #include "base.h"
-#include "pci.h"
 #include "ps.h"
 
+#include "btcoexist/rtl_btc.h"
+#include <linux/firmware.h>
 #include <linux/export.h>
+#include <net/cfg80211.h>
 
 void rtl_addr_delay(u32 addr)
 {
@@ -103,7 +101,7 @@ void rtl_fw_cb(const struct firmware *firmware, void *context)
 	int err;
 
 	RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 "Firmware callback routine entered!\n");
+		 "Firmware callback routine entered!\n");
 	complete(&rtlpriv->firmware_loading_complete);
 	if (!firmware) {
 		if (rtlpriv->cfg->alt_fw_name) {
@@ -135,7 +133,7 @@ EXPORT_SYMBOL(rtl_fw_cb);
 /*mutex for start & stop is must here. */
 static int rtl_op_start(struct ieee80211_hw *hw)
 {
-	int err;
+	int err = 0;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
@@ -157,28 +155,33 @@ static void rtl_op_stop(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	bool support_remote_wakeup = false;
 
 	if (is_hal_stop(rtlhal))
 		return;
 
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+				      (u8 *)(&support_remote_wakeup));
 	/* here is must, because adhoc do stop and start,
 	 * but stop with RFOFF may cause something wrong,
 	 * like adhoc TP
 	 */
-	if (unlikely(ppsc->rfpwr_state == ERFOFF)) {
+	if (unlikely(ppsc->rfpwr_state == ERFOFF))
 		rtl_ips_nic_on(hw);
-	}
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
+	/* if wowlan supported, DON'T clear connected info */
+	if (!(support_remote_wakeup &&
+	      rtlhal->enter_pnp_sleep)) {
+		mac->link_state = MAC80211_NOLINK;
+		memset(mac->bssid, 0, 6);
+		mac->vendor = PEER_UNKNOWN;
 
-	mac->link_state = MAC80211_NOLINK;
-	memset(mac->bssid, 0, ETH_ALEN);
-	mac->vendor = PEER_UNKNOWN;
-
-	/*reset sec info */
-	rtl_cam_reset_sec_info(hw);
+		/* reset sec info */
+		rtl_cam_reset_sec_info(hw);
 
-	rtl_deinit_deferred_work(hw);
+		rtl_deinit_deferred_work(hw);
+	}
 	rtlpriv->intf_ops->adapter_stop(hw);
 
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
@@ -202,7 +205,6 @@ static void rtl_op_tx(struct ieee80211_hw *hw,
 
 	if (!rtlpriv->intf_ops->waitq_insert(hw, control->sta, skb))
 		rtlpriv->intf_ops->adapter_tx(hw, control->sta, skb, &tcb_desc);
-
 	return;
 
 err_free:
@@ -216,18 +218,17 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	int err = 0;
 
-	vif->driver_flags |= IEEE80211_VIF_BEACON_FILTER;
-
 	if (mac->vif) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "vif has been set!! mac->vif = 0x%p\n", mac->vif);
 		return -EOPNOTSUPP;
 	}
 
+	vif->driver_flags |= IEEE80211_VIF_BEACON_FILTER;
+
 	rtl_ips_nic_on(hw);
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
-
 	switch (ieee80211_vif_type_p2p(vif)) {
 	case NL80211_IFTYPE_P2P_CLIENT:
 		mac->p2p = P2P_ROLE_CLIENT;
@@ -238,10 +239,8 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 				 "NL80211_IFTYPE_STATION\n");
 			mac->beacon_enabled = 0;
 			rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
-					rtlpriv->cfg->maps
-					[RTL_IBSS_INT_MASKS]);
+					rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
 		}
-		mac->link_state = MAC80211_LINKED;
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
@@ -254,7 +253,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		else
 			mac->basic_rates = 0xff0;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
-				(u8 *) (&mac->basic_rates));
+				(u8 *)(&mac->basic_rates));
 
 		break;
 	case NL80211_IFTYPE_P2P_GO:
@@ -271,7 +270,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		else
 			mac->basic_rates = 0xff0;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
-				(u8 *) (&mac->basic_rates));
+					      (u8 *)(&mac->basic_rates));
 		break;
 	case NL80211_IFTYPE_MESH_POINT:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
@@ -288,7 +287,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "operation mode %d is not supported!\n", vif->type);
+			 "operation mode %d is not support!\n", vif->type);
 		err = -EOPNOTSUPP;
 		goto out;
 	}
@@ -326,8 +325,7 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 		if (mac->beacon_enabled == 1) {
 			mac->beacon_enabled = 0;
 			rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
-					rtlpriv->cfg->maps
-					[RTL_IBSS_INT_MASKS]);
+					rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
 		}
 	}
 
@@ -342,12 +340,12 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	mac->vendor = PEER_UNKNOWN;
 	mac->opmode = NL80211_IFTYPE_UNSPECIFIED;
 	rtlpriv->cfg->ops->set_network_type(hw, mac->opmode);
+
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 }
-
 static int rtl_op_change_interface(struct ieee80211_hw *hw,
-				      struct ieee80211_vif *vif,
-				      enum nl80211_iftype new_type, bool p2p)
+				   struct ieee80211_vif *vif,
+				   enum nl80211_iftype new_type, bool p2p)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	int ret;
@@ -357,10 +355,221 @@ static int rtl_op_change_interface(struct ieee80211_hw *hw,
 	vif->p2p = p2p;
 	ret = rtl_op_add_interface(hw, vif);
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-		 "p2p %x\n", p2p);
+		 "p2p  %x\n", p2p);
 	return ret;
 }
 
+#ifdef CONFIG_PM
+static u16 crc16_ccitt(u8 data, u16 crc)
+{
+	u8 shift_in, data_bit, crc_bit11, crc_bit4, crc_bit15;
+	u8 i;
+	u16 result;
+
+	for (i = 0; i < 8; i++) {
+		crc_bit15 = ((crc & BIT(15)) ? 1 : 0);
+		data_bit  = (data & (BIT(0) << i) ? 1 : 0);
+		shift_in = crc_bit15 ^ data_bit;
+
+		result = crc << 1;
+		if (shift_in == 0)
+			result &= (~BIT(0));
+		else
+			result |= BIT(0);
+
+		crc_bit11 = ((crc & BIT(11)) ? 1 : 0) ^ shift_in;
+		if (crc_bit11 == 0)
+			result &= (~BIT(12));
+		else
+			result |= BIT(12);
+
+		crc_bit4 = ((crc & BIT(4)) ? 1 : 0) ^ shift_in;
+		if (crc_bit4 == 0)
+			result &= (~BIT(5));
+		else
+			result |= BIT(5);
+
+		crc = result;
+	}
+
+	return crc;
+}
+
+static u16 _calculate_wol_pattern_crc(u8 *pattern, u16 len)
+{
+	u16 crc = 0xffff;
+	u32 i;
+
+	for (i = 0; i < len; i++)
+		crc = crc16_ccitt(pattern[i], crc);
+
+	crc = ~crc;
+
+	return crc;
+}
+
+static void _rtl_add_wowlan_patterns(struct ieee80211_hw *hw,
+				     struct cfg80211_wowlan *wow)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = &rtlpriv->mac80211;
+	struct cfg80211_pkt_pattern *patterns = wow->patterns;
+	struct rtl_wow_pattern rtl_pattern;
+	const u8 *pattern_os, *mask_os;
+	u8 mask[MAX_WOL_BIT_MASK_SIZE] = {0};
+	u8 content[MAX_WOL_PATTERN_SIZE] = {0};
+	u8 broadcast_addr[6] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	u8 multicast_addr1[2] = {0x33, 0x33};
+	u8 multicast_addr2[3] = {0x01, 0x00, 0x5e};
+	u8 i, mask_len;
+	u16 j, len;
+
+	for (i = 0; i < wow->n_patterns; i++) {
+		memset(&rtl_pattern, 0, sizeof(struct rtl_wow_pattern));
+		memset(mask, 0, MAX_WOL_BIT_MASK_SIZE);
+		if (patterns[i].pattern_len > MAX_WOL_PATTERN_SIZE) {
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_WARNING,
+				 "Pattern[%d] is too long\n", i);
+			continue;
+		}
+		pattern_os = patterns[i].pattern;
+		mask_len = DIV_ROUND_UP(patterns[i].pattern_len, 8);
+		mask_os = patterns[i].mask;
+		RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+			      "pattern content\n", pattern_os,
+			       patterns[i].pattern_len);
+		RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+			      "mask content\n", mask_os, mask_len);
+		/* 1. unicast? multicast? or broadcast? */
+		if (memcmp(pattern_os, broadcast_addr, 6) == 0)
+			rtl_pattern.type = BROADCAST_PATTERN;
+		else if (memcmp(pattern_os, multicast_addr1, 2) == 0 ||
+			 memcmp(pattern_os, multicast_addr2, 3) == 0)
+			rtl_pattern.type = MULTICAST_PATTERN;
+		else if  (memcmp(pattern_os, mac->mac_addr, 6) == 0)
+			rtl_pattern.type = UNICAST_PATTERN;
+		else
+			rtl_pattern.type = UNKNOWN_TYPE;
+
+		/* 2. translate mask_from_os to mask_for_hw */
+
+/******************************************************************************
+ * pattern from OS uses 'ethenet frame', like this:
+
+		   |    6   |    6   |   2  |     20    |  Variable  |	4  |
+		   |--------+--------+------+-----------+------------+-----|
+		   |    802.3 Mac Header    | IP Header | TCP Packet | FCS |
+		   |   DA   |   SA   | Type |
+
+ * BUT, packet catched by our HW is in '802.11 frame', begin from LLC,
+
+	|     24 or 30      |    6   |   2  |     20    |  Variable  |  4  |
+	|-------------------+--------+------+-----------+------------+-----|
+	| 802.11 MAC Header |       LLC     | IP Header | TCP Packet | FCS |
+			    | Others | Tpye |
+
+ * Therefore, we need translate mask_from_OS to mask_to_hw.
+ * We should left-shift mask by 6 bits, then set the new bit[0~5] = 0,
+ * because new mask[0~5] means 'SA', but our HW packet begins from LLC,
+ * bit[0~5] corresponds to first 6 Bytes in LLC, they just don't match.
+ ******************************************************************************/
+
+		/* Shift 6 bits */
+		for (j = 0; j < mask_len - 1; j++) {
+			mask[j] = mask_os[j] >> 6;
+			mask[j] |= (mask_os[j + 1] & 0x3F) << 2;
+		}
+		mask[j] = (mask_os[j] >> 6) & 0x3F;
+		/* Set bit 0-5 to zero */
+		mask[0] &= 0xC0;
+
+		RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+			      "mask to hw\n", mask, mask_len);
+		for (j = 0; j < (MAX_WOL_BIT_MASK_SIZE + 1) / 4; j++) {
+			rtl_pattern.mask[j] = mask[j * 4];
+			rtl_pattern.mask[j] |= (mask[j * 4 + 1] << 8);
+			rtl_pattern.mask[j] |= (mask[j * 4 + 2] << 16);
+			rtl_pattern.mask[j] |= (mask[j * 4 + 3] << 24);
+		}
+
+		/* To get the wake up pattern from the mask.
+		 * We do not count first 12 bits which means
+		 * DA[6] and SA[6] in the pattern to match HW design.
+		 */
+		len = 0;
+		for (j = 12; j < patterns[i].pattern_len; j++) {
+			if ((mask_os[j / 8] >> (j % 8)) & 0x01) {
+				content[len] = pattern_os[j];
+				len++;
+			}
+		}
+
+		RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+			      "pattern to hw\n", content, len);
+		/* 3. calculate crc */
+		rtl_pattern.crc = _calculate_wol_pattern_crc(content, len);
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
+			 "CRC_Remainder = 0x%x", rtl_pattern.crc);
+
+		/* 4. write crc & mask_for_hw to hw */
+		rtlpriv->cfg->ops->add_wowlan_pattern(hw, &rtl_pattern, i);
+	}
+	rtl_write_byte(rtlpriv, 0x698, wow->n_patterns);
+}
+
+static int rtl_op_suspend(struct ieee80211_hw *hw,
+			  struct cfg80211_wowlan *wow)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct timeval ts;
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG, "\n");
+	if (WARN_ON(!wow))
+		return -EINVAL;
+
+	/* to resolve s4 can not wake up*/
+	do_gettimeofday(&ts);
+	rtlhal->last_suspend_sec = ts.tv_sec;
+
+	if ((ppsc->wo_wlan_mode & WAKE_ON_PATTERN_MATCH) && wow->n_patterns)
+		_rtl_add_wowlan_patterns(hw, wow);
+
+	rtlhal->driver_is_goingto_unload = true;
+	rtlhal->enter_pnp_sleep = true;
+
+	rtl_lps_leave(hw);
+	rtl_op_stop(hw);
+	device_set_wakeup_enable(wiphy_dev(hw->wiphy), true);
+	return 0;
+}
+
+static int rtl_op_resume(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct timeval ts;
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG, "\n");
+	rtlhal->driver_is_goingto_unload = false;
+	rtlhal->enter_pnp_sleep = false;
+	rtlhal->wake_from_pnp_sleep = true;
+
+	/* to resovle s4 can not wake up*/
+	do_gettimeofday(&ts);
+	if (ts.tv_sec - rtlhal->last_suspend_sec < 5)
+		return -1;
+
+	rtl_op_start(hw);
+	device_set_wakeup_enable(wiphy_dev(hw->wiphy), false);
+	ieee80211_resume_disconnect(mac->vif);
+	rtlhal->wake_from_pnp_sleep = false;
+	return 0;
+}
+#endif
+
 static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -373,7 +582,7 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		return 1;
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
-	if (changed & IEEE80211_CONF_CHANGE_LISTEN_INTERVAL) {	/*BIT(2)*/
+	if (changed & IEEE80211_CONF_CHANGE_LISTEN_INTERVAL) {	/* BIT(2)*/
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 			 "IEEE80211_CONF_CHANGE_LISTEN_INTERVAL\n");
 	}
@@ -408,8 +617,8 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 			 * is worked very well */
 			if (!rtlpriv->psc.multi_buffered)
 				queue_delayed_work(rtlpriv->works.rtl_wq,
-						&rtlpriv->works.ps_work,
-						MSECS(5));
+						   &rtlpriv->works.ps_work,
+						   MSECS(5));
 		} else {
 			rtl_swlps_rf_awake(hw);
 			rtlpriv->psc.sw_ps_enabled = false;
@@ -423,20 +632,26 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		mac->retry_long = hw->conf.long_frame_max_tx_count;
 		mac->retry_short = hw->conf.long_frame_max_tx_count;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
-					      (u8 *) (&hw->conf.
-						      long_frame_max_tx_count));
+				(u8 *)(&hw->conf.long_frame_max_tx_count));
 	}
 
-	if (changed & IEEE80211_CONF_CHANGE_CHANNEL) {
+	if (changed & IEEE80211_CONF_CHANGE_CHANNEL &&
+	    !rtlpriv->proximity.proxim_on) {
 		struct ieee80211_channel *channel = hw->conf.chandef.chan;
+		enum nl80211_chan_width width = hw->conf.chandef.width;
+		enum nl80211_channel_type channel_type = NL80211_CHAN_NO_HT;
 		u8 wide_chan = (u8) channel->hw_value;
 
+		/* channel_type is for 20&40M */
+		if (width < NL80211_CHAN_WIDTH_80)
+			channel_type =
+				cfg80211_get_chandef_type(&hw->conf.chandef);
 		if (mac->act_scanning)
 			mac->n_channels++;
 
 		if (rtlpriv->dm.supp_phymode_switch &&
-		    mac->link_state < MAC80211_LINKED &&
-		    !mac->act_scanning) {
+			mac->link_state < MAC80211_LINKED &&
+			!mac->act_scanning) {
 			if (rtlpriv->cfg->ops->chk_switch_dmdp)
 				rtlpriv->cfg->ops->chk_switch_dmdp(hw);
 		}
@@ -450,48 +665,98 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		 *info for cisco1253 bw20, so we modify
 		 *it here based on UPPER & LOWER
 		 */
-		switch (cfg80211_get_chandef_type(&hw->conf.chandef)) {
-		case NL80211_CHAN_HT20:
-		case NL80211_CHAN_NO_HT:
-			/* SC */
-			mac->cur_40_prime_sc =
-				PRIME_CHNL_OFFSET_DONT_CARE;
-			rtlphy->current_chan_bw = HT_CHANNEL_WIDTH_20;
-			mac->bw_40 = false;
-			break;
-		case NL80211_CHAN_HT40MINUS:
-			/* SC */
-			mac->cur_40_prime_sc = PRIME_CHNL_OFFSET_UPPER;
-			rtlphy->current_chan_bw =
-				HT_CHANNEL_WIDTH_20_40;
-			mac->bw_40 = true;
-
-			/*wide channel */
-			wide_chan -= 2;
-
-			break;
-		case NL80211_CHAN_HT40PLUS:
-			/* SC */
-			mac->cur_40_prime_sc = PRIME_CHNL_OFFSET_LOWER;
-			rtlphy->current_chan_bw =
-				HT_CHANNEL_WIDTH_20_40;
-			mac->bw_40 = true;
-
-			/*wide channel */
-			wide_chan += 2;
-
-			break;
-		default:
-			mac->bw_40 = false;
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
-			break;
+
+		if (width >= NL80211_CHAN_WIDTH_80) {
+			if (width == NL80211_CHAN_WIDTH_80) {
+				u32 center = hw->conf.chandef.center_freq1;
+				u32 primary =
+				(u32)hw->conf.chandef.chan->center_freq;
+
+				rtlphy->current_chan_bw =
+					HT_CHANNEL_WIDTH_80;
+				mac->bw_80 = true;
+				mac->bw_40 = true;
+				if (center > primary) {
+					mac->cur_80_prime_sc =
+					PRIME_CHNL_OFFSET_LOWER;
+					if (center - primary == 10) {
+						mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_UPPER;
+
+						wide_chan += 2;
+					} else if (center - primary == 30) {
+						mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_LOWER;
+
+						wide_chan += 6;
+					}
+				} else {
+					mac->cur_80_prime_sc =
+					PRIME_CHNL_OFFSET_UPPER;
+					if (primary - center == 10) {
+						mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_LOWER;
+
+						wide_chan -= 2;
+					} else if (primary - center == 30) {
+						mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_UPPER;
+
+						wide_chan -= 6;
+					}
+				}
+			}
+		} else {
+			switch (channel_type) {
+			case NL80211_CHAN_HT20:
+			case NL80211_CHAN_NO_HT:
+					/* SC */
+					mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_DONT_CARE;
+					rtlphy->current_chan_bw =
+						HT_CHANNEL_WIDTH_20;
+					mac->bw_40 = false;
+					mac->bw_80 = false;
+					break;
+			case NL80211_CHAN_HT40MINUS:
+					/* SC */
+					mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_UPPER;
+					rtlphy->current_chan_bw =
+						HT_CHANNEL_WIDTH_20_40;
+					mac->bw_40 = true;
+					mac->bw_80 = false;
+
+					/*wide channel */
+					wide_chan -= 2;
+
+					break;
+			case NL80211_CHAN_HT40PLUS:
+					/* SC */
+					mac->cur_40_prime_sc =
+						PRIME_CHNL_OFFSET_LOWER;
+					rtlphy->current_chan_bw =
+						HT_CHANNEL_WIDTH_20_40;
+					mac->bw_40 = true;
+					mac->bw_80 = false;
+
+					/*wide channel */
+					wide_chan += 2;
+
+					break;
+			default:
+					mac->bw_40 = false;
+					mac->bw_80 = false;
+					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+						 "switch case not processed\n");
+					break;
+			}
 		}
 
 		if (wide_chan <= 0)
 			wide_chan = 1;
 
-		/* In scanning, before we go offchannel we may send a ps = 1
+		/* In scanning, when before we offchannel we may send a ps=1
 		 * null to AP, and then we may send a ps = 0 null to AP quickly,
 		 * but first null may have caused AP to put lots of packet to
 		 * hw tx buffer. These packets must be tx'd before we go off
@@ -503,12 +768,12 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 			rtlpriv->mac80211.offchan_delay = false;
 			mdelay(50);
 		}
+
 		rtlphy->current_channel = wide_chan;
 
 		rtlpriv->cfg->ops->switch_channel(hw);
 		rtlpriv->cfg->ops->set_channel_access(hw);
-		rtlpriv->cfg->ops->set_bw_mode(hw,
-				cfg80211_get_chandef_type(&hw->conf.chandef));
+		rtlpriv->cfg->ops->set_bw_mode(hw, channel_type);
 	}
 
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
@@ -517,45 +782,25 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 }
 
 static void rtl_op_configure_filter(struct ieee80211_hw *hw,
-			     unsigned int changed_flags,
-			     unsigned int *new_flags, u64 multicast)
+				    unsigned int changed_flags,
+				    unsigned int *new_flags, u64 multicast)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	u32 rx_conf;
 
 	*new_flags &= RTL_SUPPORTED_FILTERS;
-	if (!changed_flags)
+	if (0 == changed_flags)
 		return;
 
-	/* if ssid not set to hw don't check bssid
-	 * here just used for linked scanning, & linked
-	 * and nolink check bssid is set in set network_type */
-	if ((changed_flags & FIF_BCN_PRBRESP_PROMISC) &&
-		(mac->link_state >= MAC80211_LINKED)) {
-		if (mac->opmode != NL80211_IFTYPE_AP &&
-		    mac->opmode != NL80211_IFTYPE_MESH_POINT) {
-			if (*new_flags & FIF_BCN_PRBRESP_PROMISC) {
-				rtlpriv->cfg->ops->set_chk_bssid(hw, false);
-			} else {
-				rtlpriv->cfg->ops->set_chk_bssid(hw, true);
-			}
-		}
-	}
-
-	/* must be called after set_chk_bssid since that function modifies the
-	 * RCR register too. */
-	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RCR, (u8 *)(&rx_conf));
-
 	/*TODO: we disable broadcase now, so enable here */
 	if (changed_flags & FIF_ALLMULTI) {
 		if (*new_flags & FIF_ALLMULTI) {
-			rx_conf |= rtlpriv->cfg->maps[MAC_RCR_AM] |
+			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_AM] |
 			    rtlpriv->cfg->maps[MAC_RCR_AB];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 				 "Enable receive multicast frame\n");
 		} else {
-			rx_conf &= ~(rtlpriv->cfg->maps[MAC_RCR_AM] |
+			mac->rx_conf &= ~(rtlpriv->cfg->maps[MAC_RCR_AM] |
 					  rtlpriv->cfg->maps[MAC_RCR_AB]);
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 				 "Disable receive multicast frame\n");
@@ -564,43 +809,55 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 
 	if (changed_flags & FIF_FCSFAIL) {
 		if (*new_flags & FIF_FCSFAIL) {
-			rx_conf |= rtlpriv->cfg->maps[MAC_RCR_ACRC32];
+			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_ACRC32];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 				 "Enable receive FCS error frame\n");
 		} else {
-			rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_ACRC32];
+			mac->rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_ACRC32];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 				 "Disable receive FCS error frame\n");
 		}
 	}
 
+	/* if ssid not set to hw don't check bssid
+	 * here just used for linked scanning, & linked
+	 * and nolink check bssid is set in set network_type
+	 */
+	if ((changed_flags & FIF_BCN_PRBRESP_PROMISC) &&
+	    (mac->link_state >= MAC80211_LINKED)) {
+		if (mac->opmode != NL80211_IFTYPE_AP &&
+		    mac->opmode != NL80211_IFTYPE_MESH_POINT) {
+			if (*new_flags & FIF_BCN_PRBRESP_PROMISC)
+				rtlpriv->cfg->ops->set_chk_bssid(hw, false);
+			else
+				rtlpriv->cfg->ops->set_chk_bssid(hw, true);
+		}
+	}
 
 	if (changed_flags & FIF_CONTROL) {
 		if (*new_flags & FIF_CONTROL) {
-			rx_conf |= rtlpriv->cfg->maps[MAC_RCR_ACF];
+			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_ACF];
 
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 "Enable receive control frame\n");
+				 "Enable receive control frame.\n");
 		} else {
-			rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_ACF];
+			mac->rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_ACF];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 "Disable receive control frame\n");
+				 "Disable receive control frame.\n");
 		}
 	}
 
 	if (changed_flags & FIF_OTHER_BSS) {
 		if (*new_flags & FIF_OTHER_BSS) {
-			rx_conf |= rtlpriv->cfg->maps[MAC_RCR_AAP];
+			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_AAP];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 "Enable receive other BSS's frame\n");
+				 "Enable receive other BSS's frame.\n");
 		} else {
-			rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_AAP];
+			mac->rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_AAP];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 "Disable receive other BSS's frame\n");
+				 "Disable receive other BSS's frame.\n");
 		}
 	}
-
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR, (u8 *)(&rx_conf));
 }
 static int rtl_op_sta_add(struct ieee80211_hw *hw,
 			 struct ieee80211_vif *vif,
@@ -612,7 +869,7 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 	struct rtl_sta_info *sta_entry;
 
 	if (sta) {
-		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
+		sta_entry = (struct rtl_sta_info *)sta->drv_priv;
 		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
 		list_add_tail(&sta_entry->list, &rtlpriv->entry_list);
 		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
@@ -620,15 +877,17 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 			sta_entry->wireless_mode = WIRELESS_MODE_G;
 			if (sta->supp_rates[0] <= 0xf)
 				sta_entry->wireless_mode = WIRELESS_MODE_B;
-			if (sta->ht_cap.ht_supported == true)
+			if (sta->ht_cap.ht_supported)
 				sta_entry->wireless_mode = WIRELESS_MODE_N_24G;
 
 			if (vif->type == NL80211_IFTYPE_ADHOC)
 				sta_entry->wireless_mode = WIRELESS_MODE_G;
 		} else if (rtlhal->current_bandtype == BAND_ON_5G) {
 			sta_entry->wireless_mode = WIRELESS_MODE_A;
-			if (sta->ht_cap.ht_supported == true)
-				sta_entry->wireless_mode = WIRELESS_MODE_N_24G;
+			if (sta->ht_cap.ht_supported)
+				sta_entry->wireless_mode = WIRELESS_MODE_N_5G;
+			if (sta->vht_cap.vht_supported)
+				sta_entry->wireless_mode = WIRELESS_MODE_AC_5G;
 
 			if (vif->type == NL80211_IFTYPE_ADHOC)
 				sta_entry->wireless_mode = WIRELESS_MODE_A;
@@ -639,9 +898,10 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 
 		memcpy(sta_entry->mac_addr, sta->addr, ETH_ALEN);
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			 "Add sta addr is %pM\n", sta->addr);
+			"Add sta addr is %pM\n", sta->addr);
 		rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 	}
+
 	return 0;
 }
 
@@ -654,17 +914,15 @@ static int rtl_op_sta_remove(struct ieee80211_hw *hw,
 	if (sta) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 			 "Remove sta addr is %pM\n", sta->addr);
-		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
+		sta_entry = (struct rtl_sta_info *)sta->drv_priv;
 		sta_entry->wireless_mode = 0;
 		sta_entry->ratr_index = 0;
-
 		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
 		list_del(&sta_entry->list);
 		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
 	}
 	return 0;
 }
-
 static int _rtl_get_hal_qnum(u16 queue)
 {
 	int qnum;
@@ -694,8 +952,8 @@ static int _rtl_get_hal_qnum(u16 queue)
  *for rtl819x  BE = 0, BK = 1, VI = 2, VO = 3
  */
 static int rtl_op_conf_tx(struct ieee80211_hw *hw,
-		   struct ieee80211_vif *vif, u16 queue,
-		   const struct ieee80211_tx_queue_params *param)
+			  struct ieee80211_vif *vif, u16 queue,
+			  const struct ieee80211_tx_queue_params *param)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -718,14 +976,14 @@ static int rtl_op_conf_tx(struct ieee80211_hw *hw,
 }
 
 static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
-			     struct ieee80211_vif *vif,
-			     struct ieee80211_bss_conf *bss_conf, u32 changed)
+				    struct ieee80211_vif *vif,
+				    struct ieee80211_bss_conf *bss_conf,
+				    u32 changed)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	struct ieee80211_sta *sta = NULL;
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 	if ((vif->type == NL80211_IFTYPE_ADHOC) ||
@@ -743,15 +1001,14 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				mac->beacon_enabled = 1;
 				rtlpriv->cfg->ops->update_interrupt_mask(hw,
 						rtlpriv->cfg->maps
-						[RTL_IBSS_INT_MASKS],
-						0);
+						[RTL_IBSS_INT_MASKS], 0);
 
 				if (rtlpriv->cfg->ops->linked_set_reg)
 					rtlpriv->cfg->ops->linked_set_reg(hw);
 			}
 		}
 		if ((changed & BSS_CHANGED_BEACON_ENABLED &&
-			!bss_conf->enable_beacon)) {
+		    !bss_conf->enable_beacon)) {
 			if (mac->beacon_enabled == 1) {
 				RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 					 "ADHOC DISABLE BEACON\n");
@@ -772,8 +1029,12 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 	/*TODO: reference to enum ieee80211_bss_change */
 	if (changed & BSS_CHANGED_ASSOC) {
+		u8 mstatus;
 		if (bss_conf->assoc) {
 			struct ieee80211_sta *sta = NULL;
+			u8 keep_alive = 10;
+
+			mstatus = RT_MEDIA_CONNECT;
 			/* we should reset all sec info & cam
 			 * before set cam after linked, we should not
 			 * reset in disassoc, that will cause tkip->wep
@@ -791,47 +1052,89 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 			if (rtlpriv->cfg->ops->linked_set_reg)
 				rtlpriv->cfg->ops->linked_set_reg(hw);
+
 			rcu_read_lock();
 			sta = ieee80211_find_sta(vif, (u8 *)bss_conf->bssid);
 			if (!sta) {
-				pr_err("ieee80211_find_sta returned NULL\n");
 				rcu_read_unlock();
 				goto out;
 			}
-
-			if (vif->type == NL80211_IFTYPE_STATION && sta)
-				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 			RT_TRACE(rtlpriv, COMP_EASY_CONCURRENT, DBG_LOUD,
 				 "send PS STATIC frame\n");
 			if (rtlpriv->dm.supp_phymode_switch) {
 				if (sta->ht_cap.ht_supported)
 					rtl_send_smps_action(hw, sta,
-						 IEEE80211_SMPS_STATIC);
+							IEEE80211_SMPS_STATIC);
 			}
+
+			if (rtlhal->current_bandtype == BAND_ON_5G) {
+				mac->mode = WIRELESS_MODE_A;
+			} else {
+				if (sta->supp_rates[0] <= 0xf)
+					mac->mode = WIRELESS_MODE_B;
+				else
+					mac->mode = WIRELESS_MODE_G;
+			}
+
+			if (sta->ht_cap.ht_supported) {
+				if (rtlhal->current_bandtype == BAND_ON_2_4G)
+					mac->mode = WIRELESS_MODE_N_24G;
+				else
+					mac->mode = WIRELESS_MODE_N_5G;
+			}
+
+			if (sta->vht_cap.vht_supported) {
+				if (rtlhal->current_bandtype == BAND_ON_5G)
+					mac->mode = WIRELESS_MODE_AC_5G;
+				else
+					mac->mode = WIRELESS_MODE_AC_24G;
+			}
+
+			if (vif->type == NL80211_IFTYPE_STATION && sta)
+				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 			rcu_read_unlock();
 
+			/* to avoid AP Disassociation caused by inactivity */
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_KEEP_ALIVE,
+						      (u8 *)(&keep_alive));
+
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_ASSOC\n");
 		} else {
+			mstatus = RT_MEDIA_DISCONNECT;
+
 			if (mac->link_state == MAC80211_LINKED) {
 				rtlpriv->enter_ps = false;
 				schedule_work(&rtlpriv->works.lps_change_work);
 			}
-
 			if (ppsc->p2p_ps_info.p2p_ps_mode > P2P_PS_NONE)
 				rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
 			mac->link_state = MAC80211_NOLINK;
 			memset(mac->bssid, 0, ETH_ALEN);
 			mac->vendor = PEER_UNKNOWN;
+			mac->mode = 0;
 
 			if (rtlpriv->dm.supp_phymode_switch) {
 				if (rtlpriv->cfg->ops->chk_switch_dmdp)
 					rtlpriv->cfg->ops->chk_switch_dmdp(hw);
 			}
-
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_UN_ASSOC\n");
 		}
+		rtlpriv->cfg->ops->set_network_type(hw, vif->type);
+		/* For FW LPS:
+		 * To tell firmware we have connected or disconnected
+		 */
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+					      HW_VAR_H2C_FW_JOINBSSRPT,
+					      (u8 *)(&mstatus));
+		ppsc->report_linked = (mstatus == RT_MEDIA_CONNECT) ?
+				      true : false;
+
+		if (rtlpriv->cfg->ops->get_btc_status())
+			rtlpriv->btcoexist.btc_ops->btc_mediastatus_notify(
+							rtlpriv, mstatus);
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
@@ -843,11 +1146,11 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 			 "BSS_CHANGED_ERP_PREAMBLE use short preamble:%x\n",
-			 bss_conf->use_short_preamble);
+			  bss_conf->use_short_preamble);
 
 		mac->short_preamble = bss_conf->use_short_preamble;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACK_PREAMBLE,
-					      &mac->short_preamble);
+					      (u8 *)(&mac->short_preamble));
 	}
 
 	if (changed & BSS_CHANGED_ERP_SLOT) {
@@ -860,13 +1163,17 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			mac->slot_time = RTL_SLOT_TIME_20;
 
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-					      &mac->slot_time);
+					      (u8 *)(&mac->slot_time));
 	}
 
 	if (changed & BSS_CHANGED_HT) {
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE, "BSS_CHANGED_HT\n");
+		struct ieee80211_sta *sta = NULL;
+
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
+			 "BSS_CHANGED_HT\n");
+
 		rcu_read_lock();
-		sta = get_sta(hw, vif, bss_conf->bssid);
+		sta = ieee80211_find_sta(vif, (u8 *)bss_conf->bssid);
 		if (sta) {
 			if (sta->ht_cap.ampdu_density >
 			    mac->current_ampdu_density)
@@ -880,7 +1187,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		rcu_read_unlock();
 
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SHORTGI_DENSITY,
-					      &mac->max_mss_density);
+					      (u8 *)(&mac->max_mss_density));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AMPDU_FACTOR,
 					      &mac->current_ampdu_factor);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AMPDU_MIN_SPACE,
@@ -889,19 +1196,19 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 	if (changed & BSS_CHANGED_BSSID) {
 		u32 basic_rates;
+		struct ieee80211_sta *sta = NULL;
 
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BSSID,
-					      (u8 *) bss_conf->bssid);
+					      (u8 *)bss_conf->bssid);
 
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG, "%pM\n",
-			 bss_conf->bssid);
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
+			 "bssid: %pM\n", bss_conf->bssid);
 
 		mac->vendor = PEER_UNKNOWN;
 		memcpy(mac->bssid, bss_conf->bssid, ETH_ALEN);
-		rtlpriv->cfg->ops->set_network_type(hw, vif->type);
 
 		rcu_read_lock();
-		sta = get_sta(hw, vif, bss_conf->bssid);
+		sta = ieee80211_find_sta(vif, (u8 *)bss_conf->bssid);
 		if (!sta) {
 			rcu_read_unlock();
 			goto out;
@@ -923,11 +1230,18 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				mac->mode = WIRELESS_MODE_N_5G;
 		}
 
+		if (sta->vht_cap.vht_supported) {
+			if (rtlhal->current_bandtype == BAND_ON_5G)
+				mac->mode = WIRELESS_MODE_AC_5G;
+			else
+				mac->mode = WIRELESS_MODE_AC_24G;
+		}
+
 		/* just station need it, because ibss & ap mode will
 		 * set in sta_add, and will be NULL here */
-		if (mac->opmode == NL80211_IFTYPE_STATION) {
+		if (vif->type == NL80211_IFTYPE_STATION) {
 			struct rtl_sta_info *sta_entry;
-			sta_entry = (struct rtl_sta_info *) sta->drv_priv;
+			sta_entry = (struct rtl_sta_info *)sta->drv_priv;
 			sta_entry->wireless_mode = mac->mode;
 		}
 
@@ -942,6 +1256,9 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			 * */
 		}
 
+		if (sta->vht_cap.vht_supported)
+			mac->vht_enable = true;
+
 		if (changed & BSS_CHANGED_BASIC_RATES) {
 			/* for 5G must << RATE_6M_INDEX = 4,
 			 * because 5G have no cck rate*/
@@ -956,40 +1273,6 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		}
 		rcu_read_unlock();
 	}
-
-	/*
-	 * For FW LPS:
-	 * To tell firmware we have connected
-	 * to an AP. For 92SE/CE power save v2.
-	 */
-	if (changed & BSS_CHANGED_ASSOC) {
-		if (bss_conf->assoc) {
-			if (ppsc->fwctrl_lps) {
-				u8 mstatus = RT_MEDIA_CONNECT;
-				u8 keep_alive = 10;
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						 HW_VAR_KEEP_ALIVE,
-						 &keep_alive);
-
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_H2C_FW_JOINBSSRPT,
-						      &mstatus);
-				ppsc->report_linked = true;
-			}
-		} else {
-			if (ppsc->fwctrl_lps) {
-				u8 mstatus = RT_MEDIA_DISCONNECT;
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_H2C_FW_JOINBSSRPT,
-						      &mstatus);
-				ppsc->report_linked = false;
-			}
-		}
-		if (rtlpriv->cfg->ops->bt_wifi_media_status_notify)
-			rtlpriv->cfg->ops->bt_wifi_media_status_notify(hw,
-							 ppsc->report_linked);
-	}
-
 out:
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 }
@@ -999,28 +1282,27 @@ static u64 rtl_op_get_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u64 tsf;
 
-	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *) (&tsf));
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *)(&tsf));
 	return tsf;
 }
 
-static void rtl_op_set_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
-			   u64 tsf)
+static void rtl_op_set_tsf(struct ieee80211_hw *hw,
+			   struct ieee80211_vif *vif, u64 tsf)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u8 bibss = (mac->opmode == NL80211_IFTYPE_ADHOC) ? 1 : 0;
 
 	mac->tsf = tsf;
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_CORRECT_TSF, &bibss);
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *)(&bibss));
 }
 
-static void rtl_op_reset_tsf(struct ieee80211_hw *hw,
-			     struct ieee80211_vif *vif)
+static void rtl_op_reset_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmp = 0;
 
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_DUAL_TSF_RST, &tmp);
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_DUAL_TSF_RST, (u8 *)(&tmp));
 }
 
 static void rtl_op_sta_notify(struct ieee80211_hw *hw,
@@ -1050,13 +1332,13 @@ static int rtl_op_ampdu_action(struct ieee80211_hw *hw,
 	case IEEE80211_AMPDU_TX_START:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_TX_START: TID:%d\n", tid);
-		return rtl_tx_agg_start(hw, sta, tid, ssn);
+		return rtl_tx_agg_start(hw, vif, sta, tid, ssn);
 	case IEEE80211_AMPDU_TX_STOP_CONT:
 	case IEEE80211_AMPDU_TX_STOP_FLUSH:
 	case IEEE80211_AMPDU_TX_STOP_FLUSH_CONT:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_TX_STOP: TID:%d\n", tid);
-		return rtl_tx_agg_stop(hw, sta, tid);
+		return rtl_tx_agg_stop(hw, vif, sta, tid);
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_TX_OPERATIONAL:TID:%d\n", tid);
@@ -1090,10 +1372,14 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw)
 		return;
 	}
 
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 1);
+
 	if (rtlpriv->dm.supp_phymode_switch) {
 		if (rtlpriv->cfg->ops->chk_switch_dmdp)
 			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
 	}
+
 	if (mac->link_state == MAC80211_LINKED) {
 		rtlpriv->enter_ps = false;
 		schedule_work(&rtlpriv->works.lps_change_work);
@@ -1102,11 +1388,11 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw)
 		rtl_ips_nic_on(hw);
 	}
 
-	/* Dual mac */
+	/* Dul mac */
 	rtlpriv->rtlhal.load_imrandiqk_setting_for2g = false;
 
 	rtlpriv->cfg->ops->led_control(hw, LED_CTL_SITE_SURVEY);
-	rtlpriv->cfg->ops->scan_operation_backup(hw, SCAN_OPT_BACKUP);
+	rtlpriv->cfg->ops->scan_operation_backup(hw, SCAN_OPT_BACKUP_BAND0);
 }
 
 static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw)
@@ -1120,13 +1406,13 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw)
 	if (rtlpriv->link_info.higher_busytraffic)
 		return;
 
-	/*p2p will use 1/6/11 to scan */
+	/* p2p will use 1/6/11 to scan */
 	if (mac->n_channels == 3)
 		mac->p2p_in_use = true;
 	else
 		mac->p2p_in_use = false;
 	mac->n_channels = 0;
-	/* Dual mac */
+	/* Dul mac */
 	rtlpriv->rtlhal.load_imrandiqk_setting_for2g = false;
 
 	if (mac->link_state == MAC80211_LINKED_SCANNING) {
@@ -1138,6 +1424,8 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw)
 	}
 
 	rtlpriv->cfg->ops->scan_operation_backup(hw, SCAN_OPT_RESTORE);
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 0);
 }
 
 static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
@@ -1145,7 +1433,6 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			  struct ieee80211_key_conf *key)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u8 key_type = NO_ENCRYPTION;
 	u8 key_idx;
 	bool group_key = false;
@@ -1161,13 +1448,13 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	}
 	/* To support IBSS, use sw-crypto for GTK */
 	if (((vif->type == NL80211_IFTYPE_ADHOC) ||
-	     (vif->type == NL80211_IFTYPE_MESH_POINT)) &&
-	      !(key->flags & IEEE80211_KEY_FLAG_PAIRWISE))
+	    (vif->type == NL80211_IFTYPE_MESH_POINT)) &&
+	   !(key->flags & IEEE80211_KEY_FLAG_PAIRWISE))
 		return -ENOSPC;
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 		 "%s hardware based encryption for keyidx: %d, mac: %pM\n",
-		 cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
-		 sta ? sta->addr : bcast_addr);
+		  cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
+		  sta ? sta->addr : bcast_addr);
 	rtlpriv->sec.being_setkey = true;
 	rtl_ips_nic_on(hw);
 	mutex_lock(&rtlpriv->locks.conf_mutex);
@@ -1191,21 +1478,23 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:CCMP\n");
 		break;
 	case WLAN_CIPHER_SUITE_AES_CMAC:
-		/*HW doesn't support CMAC encryption, use software CMAC */
+		/* HW don't support CMAC encryption,
+		 * use software CMAC encryption
+		 */
 		key_type = AESCMAC_ENCRYPTION;
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:CMAC\n");
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 "HW don't support CMAC encryption, use software CMAC\n");
+			 "HW don't support CMAC encrypiton, use software CMAC encrypiton\n");
 		err = -EOPNOTSUPP;
 		goto out_unlock;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "alg_err:%x!!!!\n",
-			 key->cipher);
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "alg_err:%x!!!!:\n", key->cipher);
 		goto out_unlock;
 	}
 	if (key_type == WEP40_ENCRYPTION ||
-			key_type == WEP104_ENCRYPTION ||
-			mac->opmode == NL80211_IFTYPE_ADHOC)
+	   key_type == WEP104_ENCRYPTION ||
+	   vif->type == NL80211_IFTYPE_ADHOC)
 		rtlpriv->sec.use_defaultkey = true;
 
 	/* <2> get key_idx */
@@ -1219,14 +1508,14 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	 * 1) wep only: is just for wep enc, in this condition
 	 * rtlpriv->sec.pairwise_enc_algorithm == NO_ENCRYPTION
 	 * will be true & enable_hw_sec will be set when wep
-	 * key setting.
+	 * ke setting.
 	 * 2) wep(group) + AES(pairwise): some AP like cisco
 	 * may use it, in this condition enable_hw_sec will not
 	 * be set when wep key setting */
 	/* we must reset sec_info after lingked before set key,
 	 * or some flag will be wrong*/
 	if (vif->type == NL80211_IFTYPE_AP ||
-	    vif->type == NL80211_IFTYPE_MESH_POINT) {
+		vif->type == NL80211_IFTYPE_MESH_POINT) {
 		if (!group_key || key_type == WEP40_ENCRYPTION ||
 			key_type == WEP104_ENCRYPTION) {
 			if (group_key)
@@ -1234,11 +1523,11 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			rtlpriv->cfg->ops->enable_hw_sec(hw);
 		}
 	} else {
-		if ((!group_key) || (mac->opmode == NL80211_IFTYPE_ADHOC) ||
-		     rtlpriv->sec.pairwise_enc_algorithm == NO_ENCRYPTION) {
+		if ((!group_key) || (vif->type == NL80211_IFTYPE_ADHOC) ||
+		    rtlpriv->sec.pairwise_enc_algorithm == NO_ENCRYPTION) {
 			if (rtlpriv->sec.pairwise_enc_algorithm ==
 			    NO_ENCRYPTION &&
-			    (key_type == WEP40_ENCRYPTION ||
+			   (key_type == WEP40_ENCRYPTION ||
 			    key_type == WEP104_ENCRYPTION))
 				wep_only = true;
 			rtlpriv->sec.pairwise_enc_algorithm = key_type;
@@ -1310,7 +1599,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			 "disable key delete one entry\n");
 		/*set local buf about wep key. */
 		if (vif->type == NL80211_IFTYPE_AP ||
-		    vif->type == NL80211_IFTYPE_MESH_POINT) {
+			vif->type == NL80211_IFTYPE_MESH_POINT) {
 			if (sta)
 				rtl_cam_del_entry(hw, sta->addr);
 		}
@@ -1323,13 +1612,10 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		 *or clear all entry here.
 		 */
 		rtl_cam_delete_one_entry(hw, mac_addr, key_idx);
-
-		rtl_cam_reset_sec_info(hw);
-
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "cmd_err:%x!!!!\n", cmd);
+			 "cmd_err:%x!!!!:\n", cmd);
 	}
 out_unlock:
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
@@ -1359,7 +1645,7 @@ static void rtl_op_rfkill_poll(struct ieee80211_hw *hw)
 
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "wireless radio switch turned %s\n",
-				 radio_state ? "on" : "off");
+				  radio_state ? "on" : "off");
 
 			blocked = (rtlpriv->rfkill.rfkill_state == 1) ? 0 : 1;
 			wiphy_rfkill_set_hw_state(hw->wiphy, blocked);
@@ -1370,11 +1656,13 @@ static void rtl_op_rfkill_poll(struct ieee80211_hw *hw)
 }
 
 /* this function is called by mac80211 to flush tx buffer
- * before switch channel or power save, or tx buffer packet
+ * before switch channle or power save, or tx buffer packet
  * maybe send after offchannel or rf sleep, this may cause
  * dis-association by AP */
-static void rtl_op_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
-			 u32 queues, bool drop)
+static void rtl_op_flush(struct ieee80211_hw *hw,
+			 struct ieee80211_vif *vif,
+			 u32 queues,
+			 bool drop)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
@@ -1389,10 +1677,12 @@ const struct ieee80211_ops rtl_ops = {
 	.add_interface = rtl_op_add_interface,
 	.remove_interface = rtl_op_remove_interface,
 	.change_interface = rtl_op_change_interface,
+#ifdef CONFIG_PM
+	.suspend = rtl_op_suspend,
+	.resume = rtl_op_resume,
+#endif
 	.config = rtl_op_config,
 	.configure_filter = rtl_op_configure_filter,
-	.sta_add = rtl_op_sta_add,
-	.sta_remove = rtl_op_sta_remove,
 	.set_key = rtl_op_set_key,
 	.conf_tx = rtl_op_conf_tx,
 	.bss_info_changed = rtl_op_bss_info_changed,
@@ -1404,6 +1694,9 @@ const struct ieee80211_ops rtl_ops = {
 	.sw_scan_start = rtl_op_sw_scan_start,
 	.sw_scan_complete = rtl_op_sw_scan_complete,
 	.rfkill_poll = rtl_op_rfkill_poll,
+	.sta_add = rtl_op_sta_add,
+	.sta_remove = rtl_op_sta_remove,
 	.flush = rtl_op_flush,
 };
 EXPORT_SYMBOL_GPL(rtl_ops);
+
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 9e990be..50bf739 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -181,6 +181,31 @@ enum rf_tx_num {
 #define PACKET_ARP			2
 #define PACKET_EAPOL			3
 
+#define	MAX_SUPPORT_WOL_PATTERN_NUM	16
+#define	RSVD_WOL_PATTERN_NUM		1
+#define	WKFMCAM_ADDR_NUM		6
+#define	WKFMCAM_SIZE			24
+
+#define	MAX_WOL_BIT_MASK_SIZE		16
+/* MIN LEN keeps 13 here */
+#define	MIN_WOL_PATTERN_SIZE		13
+#define	MAX_WOL_PATTERN_SIZE		128
+
+#define	WAKE_ON_MAGIC_PACKET		BIT(0)
+#define	WAKE_ON_PATTERN_MATCH		BIT(1)
+
+#define	WOL_REASON_PTK_UPDATE		BIT(0)
+#define	WOL_REASON_GTK_UPDATE		BIT(1)
+#define	WOL_REASON_DISASSOC		BIT(2)
+#define	WOL_REASON_DEAUTH		BIT(3)
+#define	WOL_REASON_AP_LOST		BIT(4)
+#define	WOL_REASON_MAGIC_PKT		BIT(5)
+#define	WOL_REASON_UNICAST_PKT		BIT(6)
+#define	WOL_REASON_PATTERN_PKT		BIT(7)
+#define	WOL_REASON_RTD3_SSID_MATCH	BIT(8)
+#define	WOL_REASON_REALWOW_V2_WAKEUPPKT	BIT(9)
+#define	WOL_REASON_REALWOW_V2_ACKLOST	BIT(10)
+
 struct txpower_info_2g {
 	u8 index_cck_base[MAX_RF_PATH][MAX_CHNL_GROUP_24G];
 	u8 index_bw40_base[MAX_RF_PATH][MAX_CHNL_GROUP_24G];
@@ -811,6 +836,14 @@ enum rt_polarity_ctl {
 	RT_POLARITY_HIGH_ACT = 1,
 };
 
+enum wolpattern_type {
+	UNICAST_PATTERN = 0,
+	MULTICAST_PATTERN = 1,
+	BROADCAST_PATTERN = 2,
+	DONT_CARE_DA = 3,
+	UNKNOWN_TYPE = 4,
+};
+
 struct octet_string {
 	u8 *octet;
 	u16 length;
@@ -1262,6 +1295,17 @@ struct rtl_mac {
 	/* skb wait queue */
 	struct sk_buff_head skb_waitq[MAX_TID_COUNT];
 
+	u8 ht_stbc_cap;
+	u8 ht_cur_stbc;
+
+	/*vht support*/
+	u8 vht_enable;
+	u8 bw_80;
+	u8 vht_cur_ldpc;
+	u8 vht_cur_stbc;
+	u8 vht_stbc_cap;
+	u8 vht_ldpc_cap;
+
 	/*RDG*/
 	bool rdg_en;
 
@@ -1426,6 +1470,20 @@ struct rtl_hal {
 
 	u16 rx_tag;/*for 92ee*/
 	u8 rts_en;
+
+	/*for wowlan*/
+	bool wow_enable;
+	bool enter_pnp_sleep;
+	bool wake_from_pnp_sleep;
+	bool wow_enabled;
+	__kernel_time_t last_suspend_sec;
+	u32 wowlan_fwsize;
+	u8 *wowlan_firmware;
+
+	u8 hw_rof_enable; /*Enable GPIO[9] as WL RF HW PDn source*/
+
+	bool real_wow_v2_enable;
+	bool re_init_llt_table;
 };
 
 struct rtl_security {
@@ -1772,6 +1830,15 @@ struct rtl_ps_ctl {
 	struct rtl_p2p_ps_info p2p_ps_info;
 	u8 pwr_mode;
 	u8 smart_ps;
+
+	/* wake up on line */
+	u8 wo_wlan_mode;
+	u8 arp_offload_enable;
+	u8 gtk_offload_enable;
+	/* Used for WOL, indicates the reason for waking event.*/
+	u32 wakeup_reason;
+	/* Record the last waking time for comparison with setting key. */
+	u64 last_wakeup_time;
 };
 
 struct rtl_stats {
@@ -1892,6 +1959,12 @@ struct rtl_tcb_desc {
 
 struct rtl92c_firmware_header;
 
+struct rtl_wow_pattern {
+	u8 type;
+	u16 crc;
+	u32 mask[4];
+};
+
 struct rtl_hal_ops {
 	int (*init_sw_vars) (struct ieee80211_hw *hw);
 	void (*deinit_sw_vars) (struct ieee80211_hw *hw);
@@ -1999,6 +2072,9 @@ struct rtl_hal_ops {
 	bool (*is_fw_header) (struct rtl92c_firmware_header *hdr);
 	u32 (*rx_command_packet)(struct ieee80211_hw *hw,
 				 struct rtl_stats status, struct sk_buff *skb);
+	void (*add_wowlan_pattern)(struct ieee80211_hw *hw,
+				   struct rtl_wow_pattern *rtl_pattern,
+				   u8 index);
 };
 
 struct rtl_intf_ops {
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
