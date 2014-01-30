From: Olivier Langlois <olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>
Subject: [PATCH] rtl8192ce is disabling the irqs for too long
Date: Thu, 30 Jan 2014 01:22:29 -0500
Message-ID: <1391062949-14502-1-git-send-email-olivier@trillion01.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mlang45-KttuZimePZJWk0Htik3J/w@public.gmane.org,
	Olivier Langlois <olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

rtl8192ce is disabling for too long the local interrupts during hw initiatialisation when performing scans

The observable symptoms in dmesg can be:

- underruns from ALSA playback
- clock freezes (tstamps do not change for several dmesg entries until irqs are finaly reenabled):

[  250.817669] rtlwifi:rtl_op_config():<0-0-0> 0x100
[  250.817685] rtl8192ce:_rtl92ce_phy_set_rf_power_state():<0-1-0> IPS Set eRf nic enable
[  250.817732] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.817796] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.817910] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818024] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818139] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818253] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818367] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
[  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:98053f15:10
[  250.818472] rtl8192ce:rtl92ce_sw_led_on():<0-1-0> LedAddr:4E ledpin=1
[  250.818472] rtl8192c_common:rtl92c_download_fw():<0-1-0> Firmware Version(49), Signature(0x88c1),Size(32)
[  250.818472] rtl8192ce:rtl92ce_enable_hw_security_config():<0-1-0> PairwiseEncAlgorithm = 0 GroupEncAlgorithm = 0
[  250.818472] rtl8192ce:rtl92ce_enable_hw_security_config():<0-1-0> The SECR-value cc
[  250.818472] rtl8192c_common:rtl92c_dm_check_txpower_tracking_thermal_meter():<0-1-0> Schedule TxPowerTracking direct call!!
[  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> rtl92c_dm_txpower_tracking_callback_thermalmeter
[  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Readback Thermal Meter = 0xe pre thermal meter 0xf eeprom_thermalmeter 0xf
[  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Initial pathA ele_d reg0xc80 = 0x40000000, ofdm_index=0xc
[  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Initial reg0xa24 = 0x90e1317, cck_index=0xc, ch14 0
[  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Readback Thermal Meter = 0xe pre thermal meter 0xf eeprom_thermalmeter 0xf delta 0x1 delta_lck 0x0 delta_iqk 0x0
[  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> <===
[  250.818472] rtl8192c_common:rtl92c_dm_initialize_txpower_tracking_thermalmeter():<0-1-0> pMgntInfo->txpower_tracking = 1
[  250.818472] rtl8192ce:rtl92ce_led_control():<0-1-0> ledaction 3
[  250.818472] rtl8192ce:rtl92ce_sw_led_on():<0-1-0> LedAddr:4E ledpin=1
[  250.818472] rtlwifi:rtl_ips_nic_on():<0-1-0> before spin_unlock_irqrestore
[  251.154656] PCM: Lost interrupts? [Q]-0 (stream=0, delta=15903, new_hw_ptr=293408, old_hw_ptr=277505)

The exact code flow that causes that is:

1. wpa_supplicant send a start_scan request to the nl80211 driver
2. mac80211 module call rtl_op_config with IEEE80211_CONF_CHANGE_IDLE
3.   rtl_ips_nic_on is called which disable local irqs
4.     rtl92c_phy_set_rf_power_state() is called
5.       rtl_ps_enable_nic() is called and hw_init()is executed and interrupts on the device

A good solution could be to refactor the code to avoid calling rtl92ce_hw_init() with the irqs disabled
but a quick and dirty solution that has proven to work is
to reenable the irqs during the function rtl92ce_hw_init().

I think that it is safe doing so since the device interrupt will only be enabled after the init function succeed.

Signed-off-by: Olivier Langlois <olivier-VxAV575H0jR+kJTeVDPgHg@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/ps.c           |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 18 ++++++++++++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 0d81f76..a56e9b3 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -48,7 +48,7 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 
 	/*<2> Enable Adapter */
 	if (rtlpriv->cfg->ops->hw_init(hw))
-		return 1;
+		return false;
 	RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 
 	/*<3> Enable Interrupt */
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index a82b30a..2eb0b38 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -937,14 +937,26 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	bool is92c;
 	int err;
 	u8 tmp_u1b;
+	unsigned long flags;
 
 	rtlpci->being_init_adapter = true;
+
+	/* Since this function can take a very long time (up to 350 ms)
+	 * and can be called with irqs disabled, reenable the irqs
+	 * to let the other devices continue being serviced.
+	 *
+	 * It is safe doing so since our own interrupts will only be enabled
+	 * in a subsequent step.
+	 */
+	local_save_flags(flags);
+	local_irq_enable();
+
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus = _rtl92ce_init_mac(hw);
 	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err = 1;
-		return err;
+		goto exit;
 	}
 
 	err = rtl92c_download_fw(hw);
@@ -952,7 +964,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Failed to download FW. Init HW without FW now..\n");
 		err = 1;
-		return err;
+		goto exit;
 	}
 
 	rtlhal->last_hmeboxnum = 0;
@@ -1032,6 +1044,8 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "under 1.5V\n");
 	}
 	rtl92c_dm_init(hw);
+exit:
+	local_irq_restore(flags);
 	rtlpci->being_init_adapter = false;
 	return err;
 }
-- 
1.8.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
