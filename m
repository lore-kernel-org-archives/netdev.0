From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 14/16] rtlwifi: rtl8723be: Add files for new driver - part 7
Date: Wed,  5 Feb 2014 13:54:58 -0600
Message-ID: <1391630100-13504-15-git-send-email-Larry.Finger@lwfinger.net>
References: <1391630100-13504-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391630100-13504-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c    | 385 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/sw.h    |  35 +
 drivers/net/wireless/rtlwifi/rtl8723be/table.c | 572 +++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/table.h |  43 ++
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c   | 959 +++++++++++++++++++++++++
 5 files changed, 1994 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/trx.c

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
new file mode 100644
index 0000000..7834ae5
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -0,0 +1,385 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#include "../wifi.h"
+#include "../core.h"
+#include "../pci.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "../rtl8723com/phy_common.h"
+#include "dm.h"
+#include "hw.h"
+#include "fw.h"
+#include "../rtl8723com/fw_common.h"
+#include "sw.h"
+#include "trx.h"
+#include "led.h"
+#include "table.h"
+#include "../btcoexist/rtl_btc.h"
+
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+
+static void rtl8723be_init_aspm_vars(struct ieee80211_hw *hw)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	/*close ASPM for AMD defaultly */
+	rtlpci->const_amdpci_aspm = 0;
+
+	/* ASPM PS mode.
+	 * 0 - Disable ASPM,
+	 * 1 - Enable ASPM without Clock Req,
+	 * 2 - Enable ASPM with Clock Req,
+	 * 3 - Alwyas Enable ASPM with Clock Req,
+	 * 4 - Always Enable ASPM without Clock Req.
+	 * set defult to RTL8192CE:3 RTL8192E:2
+	 */
+	rtlpci->const_pci_aspm = 3;
+
+	/*Setting for PCI-E device */
+	rtlpci->const_devicepci_aspm_setting = 0x03;
+
+	/*Setting for PCI-E bridge */
+	rtlpci->const_hostpci_aspm_setting = 0x02;
+
+	/* In Hw/Sw Radio Off situation.
+	 * 0 - Default,
+	 * 1 - From ASPM setting without low Mac Pwr,
+	 * 2 - From ASPM setting with low Mac Pwr,
+	 * 3 - Bus D3
+	 * set default to RTL8192CE:0 RTL8192SE:2
+	 */
+	rtlpci->const_hwsw_rfoff_d3 = 0;
+
+	/* This setting works for those device with
+	 * backdoor ASPM setting such as EPHY setting.
+	 * 0 - Not support ASPM,
+	 * 1 - Support ASPM,
+	 * 2 - According to chipset.
+	 */
+	rtlpci->const_support_pciaspm = 1;
+}
+
+int rtl8723be_init_sw_vars(struct ieee80211_hw *hw)
+{
+	int err = 0;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+
+	rtl8723be_bt_reg_init(hw);
+	rtlpci->msi_support = true;
+	rtlpriv->btcoexist.btc_ops = rtl_btc_get_ops_pointer();
+
+	rtlpriv->dm.dm_initialgain_enable = 1;
+	rtlpriv->dm.dm_flag = 0;
+	rtlpriv->dm.disable_framebursting = 0;
+	rtlpriv->dm.thermalvalue = 0;
+	rtlpci->transmit_config = CFENDFORM | BIT(15) | BIT(24) | BIT(25);
+
+	mac->ht_enable = true;
+
+	/* compatible 5G band 88ce just 2.4G band & smsp */
+	rtlpriv->rtlhal.current_bandtype = BAND_ON_2_4G;
+	rtlpriv->rtlhal.bandset = BAND_ON_2_4G;
+	rtlpriv->rtlhal.macphymode = SINGLEMAC_SINGLEPHY;
+
+	rtlpci->receive_config = (RCR_APPFCS		|
+				  RCR_APP_MIC		|
+				  RCR_APP_ICV		|
+				  RCR_APP_PHYST_RXFF	|
+				  RCR_HTC_LOC_CTRL	|
+				  RCR_AMF		|
+				  RCR_ACF		|
+				  RCR_ADF		|
+				  RCR_AICV		|
+				  RCR_AB		|
+				  RCR_AM		|
+				  RCR_APM		|
+				  0);
+
+	rtlpci->irq_mask[0] = (u32) (IMR_PSTIMEOUT	|
+				     IMR_HSISR_IND_ON_INT	|
+				     IMR_C2HCMD		|
+				     IMR_HIGHDOK	|
+				     IMR_MGNTDOK	|
+				     IMR_BKDOK		|
+				     IMR_BEDOK		|
+				     IMR_VIDOK		|
+				     IMR_VODOK		|
+				     IMR_RDU		|
+				     IMR_ROK		|
+				     0);
+
+	rtlpci->irq_mask[1] = (u32)(IMR_RXFOVW | 0);
+
+	/* for debug level */
+	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
+	/* for LPS & IPS */
+	rtlpriv->psc.inactiveps = rtlpriv->cfg->mod_params->inactiveps;
+	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
+	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
+	rtlpriv->psc.reg_fwctrl_lps = 3;
+	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
+	/* for ASPM, you can close aspm through
+	 * set const_support_pciaspm = 0
+	 */
+	rtl8723be_init_aspm_vars(hw);
+
+	if (rtlpriv->psc.reg_fwctrl_lps == 1)
+		rtlpriv->psc.fwctrl_psmode = FW_PS_MIN_MODE;
+	else if (rtlpriv->psc.reg_fwctrl_lps == 2)
+		rtlpriv->psc.fwctrl_psmode = FW_PS_MAX_MODE;
+	else if (rtlpriv->psc.reg_fwctrl_lps == 3)
+		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
+
+	/* for firmware buf */
+	rtlpriv->rtlhal.pfirmware = vzalloc(0x8000);
+	if (!rtlpriv->rtlhal.pfirmware) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Can't alloc buffer for fw.\n");
+		return 1;
+	}
+
+	rtlpriv->max_fw_size = 0x8000;
+	pr_info("Using firmware %s\n", rtlpriv->cfg->fw_name);
+	err = request_firmware_nowait(THIS_MODULE, 1, rtlpriv->cfg->fw_name,
+				      rtlpriv->io.dev, GFP_KERNEL, hw,
+				      rtl_fw_cb);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Failed to request firmware!\n");
+		return 1;
+	}
+	return 0;
+}
+
+void rtl8723be_deinit_sw_vars(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_halt_notify();
+	if (rtlpriv->rtlhal.pfirmware) {
+		vfree(rtlpriv->rtlhal.pfirmware);
+		rtlpriv->rtlhal.pfirmware = NULL;
+	}
+}
+
+/* get bt coexist status */
+bool rtl8723be_get_btc_status(void)
+{
+	return true;
+}
+
+static bool is_fw_header(struct rtl92c_firmware_header *hdr)
+{
+	return (hdr->signature & 0xfff0) == 0x5300;
+}
+
+static struct rtl_hal_ops rtl8723be_hal_ops = {
+	.init_sw_vars = rtl8723be_init_sw_vars,
+	.deinit_sw_vars = rtl8723be_deinit_sw_vars,
+	.read_eeprom_info = rtl8723be_read_eeprom_info,
+	.interrupt_recognized = rtl8723be_interrupt_recognized,
+	.hw_init = rtl8723be_hw_init,
+	.hw_disable = rtl8723be_card_disable,
+	.hw_suspend = rtl8723be_suspend,
+	.hw_resume = rtl8723be_resume,
+	.enable_interrupt = rtl8723be_enable_interrupt,
+	.disable_interrupt = rtl8723be_disable_interrupt,
+	.set_network_type = rtl8723be_set_network_type,
+	.set_chk_bssid = rtl8723be_set_check_bssid,
+	.set_qos = rtl8723be_set_qos,
+	.set_bcn_reg = rtl8723be_set_beacon_related_registers,
+	.set_bcn_intv = rtl8723be_set_beacon_interval,
+	.update_interrupt_mask = rtl8723be_update_interrupt_mask,
+	.get_hw_reg = rtl8723be_get_hw_reg,
+	.set_hw_reg = rtl8723be_set_hw_reg,
+	.update_rate_tbl = rtl8723be_update_hal_rate_tbl,
+	.fill_tx_desc = rtl8723be_tx_fill_desc,
+	.fill_tx_cmddesc = rtl8723be_tx_fill_cmddesc,
+	.query_rx_desc = rtl8723be_rx_query_desc,
+	.set_channel_access = rtl8723be_update_channel_access_setting,
+	.radio_onoff_checking = rtl8723be_gpio_radio_on_off_checking,
+	.set_bw_mode = rtl8723be_phy_set_bw_mode,
+	.switch_channel = rtl8723be_phy_sw_chnl,
+	.dm_watchdog = rtl8723be_dm_watchdog,
+	.scan_operation_backup = rtl8723be_phy_scan_operation_backup,
+	.set_rf_power_state = rtl8723be_phy_set_rf_power_state,
+	.led_control = rtl8723be_led_control,
+	.set_desc = rtl8723be_set_desc,
+	.get_desc = rtl8723be_get_desc,
+	.is_tx_desc_closed = rtl8723be_is_tx_desc_closed,
+	.tx_polling = rtl8723be_tx_polling,
+	.enable_hw_sec = rtl8723be_enable_hw_security_config,
+	.set_key = rtl8723be_set_key,
+	.init_sw_leds = rtl8723be_init_sw_leds,
+	.allow_all_destaddr = rtl8723be_allow_all_destaddr,
+	.get_bbreg = rtl8723_phy_query_bb_reg,
+	.set_bbreg = rtl8723_phy_set_bb_reg,
+	.get_rfreg = rtl8723be_phy_query_rf_reg,
+	.set_rfreg = rtl8723be_phy_set_rf_reg,
+	.fill_h2c_cmd = rtl8723be_fill_h2c_cmd,
+	.get_btc_status = rtl8723be_get_btc_status,
+	.is_fw_header = is_fw_header,
+};
+
+static struct rtl_mod_params rtl8723be_mod_params = {
+	.sw_crypto = false,
+	.inactiveps = true,
+	.swctrl_lps = false,
+	.fwctrl_lps = true,
+	.debug = DBG_EMERG,
+};
+
+static struct rtl_hal_cfg rtl8723be_hal_cfg = {
+	.bar_id = 2,
+	.write_readback = true,
+	.name = "rtl8723be_pci",
+	.fw_name = "rtlwifi/rtl8723befw.bin",
+	.ops = &rtl8723be_hal_ops,
+	.mod_params = &rtl8723be_mod_params,
+	.maps[SYS_ISO_CTRL] = REG_SYS_ISO_CTRL,
+	.maps[SYS_FUNC_EN] = REG_SYS_FUNC_EN,
+	.maps[SYS_CLK] = REG_SYS_CLKR,
+	.maps[MAC_RCR_AM] = AM,
+	.maps[MAC_RCR_AB] = AB,
+	.maps[MAC_RCR_ACRC32] = ACRC32,
+	.maps[MAC_RCR_ACF] = ACF,
+	.maps[MAC_RCR_AAP] = AAP,
+
+	.maps[EFUSE_ACCESS] = REG_EFUSE_ACCESS,
+
+	.maps[EFUSE_TEST] = REG_EFUSE_TEST,
+	.maps[EFUSE_CTRL] = REG_EFUSE_CTRL,
+	.maps[EFUSE_CLK] = 0,
+	.maps[EFUSE_CLK_CTRL] = REG_EFUSE_CTRL,
+	.maps[EFUSE_PWC_EV12V] = PWC_EV12V,
+	.maps[EFUSE_FEN_ELDR] = FEN_ELDR,
+	.maps[EFUSE_LOADER_CLK_EN] = LOADER_CLK_EN,
+	.maps[EFUSE_ANA8M] = ANA8M,
+	.maps[EFUSE_HWSET_MAX_SIZE] = HWSET_MAX_SIZE,
+	.maps[EFUSE_MAX_SECTION_MAP] = EFUSE_MAX_SECTION,
+	.maps[EFUSE_REAL_CONTENT_SIZE] = EFUSE_REAL_CONTENT_LEN,
+	.maps[EFUSE_OOB_PROTECT_BYTES_LEN] = EFUSE_OOB_PROTECT_BYTES,
+
+	.maps[RWCAM] = REG_CAMCMD,
+	.maps[WCAMI] = REG_CAMWRITE,
+	.maps[RCAMO] = REG_CAMREAD,
+	.maps[CAMDBG] = REG_CAMDBG,
+	.maps[SECR] = REG_SECCFG,
+	.maps[SEC_CAM_NONE] = CAM_NONE,
+	.maps[SEC_CAM_WEP40] = CAM_WEP40,
+	.maps[SEC_CAM_TKIP] = CAM_TKIP,
+	.maps[SEC_CAM_AES] = CAM_AES,
+	.maps[SEC_CAM_WEP104] = CAM_WEP104,
+
+	.maps[RTL_IMR_BCNDMAINT6] = IMR_BCNDMAINT6,
+	.maps[RTL_IMR_BCNDMAINT5] = IMR_BCNDMAINT5,
+	.maps[RTL_IMR_BCNDMAINT4] = IMR_BCNDMAINT4,
+	.maps[RTL_IMR_BCNDMAINT3] = IMR_BCNDMAINT3,
+	.maps[RTL_IMR_BCNDMAINT2] = IMR_BCNDMAINT2,
+	.maps[RTL_IMR_BCNDMAINT1] = IMR_BCNDMAINT1,
+	.maps[RTL_IMR_BCNDOK7] = IMR_BCNDOK7,
+	.maps[RTL_IMR_BCNDOK6] = IMR_BCNDOK6,
+	.maps[RTL_IMR_BCNDOK5] = IMR_BCNDOK5,
+	.maps[RTL_IMR_BCNDOK4] = IMR_BCNDOK4,
+	.maps[RTL_IMR_BCNDOK3] = IMR_BCNDOK3,
+	.maps[RTL_IMR_BCNDOK2] = IMR_BCNDOK2,
+	.maps[RTL_IMR_BCNDOK1] = IMR_BCNDOK1,
+
+	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
+	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
+	.maps[RTL_IMR_BCNINT] = IMR_BCNDMAINT0,
+	.maps[RTL_IMR_RXFOVW] = IMR_RXFOVW,
+	.maps[RTL_IMR_RDU] = IMR_RDU,
+	.maps[RTL_IMR_ATIMEND] = IMR_ATIMEND,
+	.maps[RTL_IMR_BDOK] = IMR_BCNDOK0,
+	.maps[RTL_IMR_MGNTDOK] = IMR_MGNTDOK,
+	.maps[RTL_IMR_TBDER] = IMR_TBDER,
+	.maps[RTL_IMR_HIGHDOK] = IMR_HIGHDOK,
+	.maps[RTL_IMR_TBDOK] = IMR_TBDOK,
+	.maps[RTL_IMR_BKDOK] = IMR_BKDOK,
+	.maps[RTL_IMR_BEDOK] = IMR_BEDOK,
+	.maps[RTL_IMR_VIDOK] = IMR_VIDOK,
+	.maps[RTL_IMR_VODOK] = IMR_VODOK,
+	.maps[RTL_IMR_ROK] = IMR_ROK,
+	.maps[RTL_IBSS_INT_MASKS] = (IMR_BCNDMAINT0 | IMR_TBDOK | IMR_TBDER),
+
+	.maps[RTL_RC_CCK_RATE1M] = DESC92C_RATE1M,
+	.maps[RTL_RC_CCK_RATE2M] = DESC92C_RATE2M,
+	.maps[RTL_RC_CCK_RATE5_5M] = DESC92C_RATE5_5M,
+	.maps[RTL_RC_CCK_RATE11M] = DESC92C_RATE11M,
+	.maps[RTL_RC_OFDM_RATE6M] = DESC92C_RATE6M,
+	.maps[RTL_RC_OFDM_RATE9M] = DESC92C_RATE9M,
+	.maps[RTL_RC_OFDM_RATE12M] = DESC92C_RATE12M,
+	.maps[RTL_RC_OFDM_RATE18M] = DESC92C_RATE18M,
+	.maps[RTL_RC_OFDM_RATE24M] = DESC92C_RATE24M,
+	.maps[RTL_RC_OFDM_RATE36M] = DESC92C_RATE36M,
+	.maps[RTL_RC_OFDM_RATE48M] = DESC92C_RATE48M,
+	.maps[RTL_RC_OFDM_RATE54M] = DESC92C_RATE54M,
+
+	.maps[RTL_RC_HT_RATEMCS7] = DESC92C_RATEMCS7,
+	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
+};
+
+static DEFINE_PCI_DEVICE_TABLE(rtl8723be_pci_id) = {
+	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0xb723, rtl8723be_hal_cfg)},
+	{},
+};
+
+MODULE_DEVICE_TABLE(pci, rtl8723be_pci_id);
+
+MODULE_AUTHOR("PageHe	<page_he-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>");
+MODULE_AUTHOR("Realtek WlanFAE	<wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Realtek 8723BE 802.11n PCI wireless");
+MODULE_FIRMWARE("rtlwifi/rtl8723befw.bin");
+
+module_param_named(swenc, rtl8723be_mod_params.sw_crypto, bool, 0444);
+module_param_named(debug, rtl8723be_mod_params.debug, int, 0444);
+module_param_named(ips, rtl8723be_mod_params.inactiveps, bool, 0444);
+module_param_named(swlps, rtl8723be_mod_params.swctrl_lps, bool, 0444);
+module_param_named(fwlps, rtl8723be_mod_params.fwctrl_lps, bool, 0444);
+MODULE_PARM_DESC(swenc, "using hardware crypto (default 0 [hardware])\n");
+MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
+MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is open)\n");
+MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
+
+static const SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
+
+static struct pci_driver rtl8723be_driver = {
+	.name = KBUILD_MODNAME,
+	.id_table = rtl8723be_pci_id,
+	.probe = rtl_pci_probe,
+	.remove = rtl_pci_disconnect,
+
+	.driver.pm = &rtlwifi_pm_ops,
+};
+
+module_pci_driver(rtl8723be_driver);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.h b/drivers/net/wireless/rtlwifi/rtl8723be/sw.h
new file mode 100644
index 0000000..a7b25e76
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.h
@@ -0,0 +1,35 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#ifndef __RTL8723BE_SW_H__
+#define __RTL8723BE_SW_H__
+
+int rtl8723be_init_sw_vars(struct ieee80211_hw *hw);
+void rtl8723be_deinit_sw_vars(struct ieee80211_hw *hw);
+void rtl8723be_init_var_map(struct ieee80211_hw *hw);
+bool rtl8723be_get_btc_status(void);
+
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/table.c b/drivers/net/wireless/rtlwifi/rtl8723be/table.c
new file mode 100644
index 0000000..4b283cd
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/table.c
@@ -0,0 +1,572 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Created on  2010/ 5/18,  1:41
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *****************************************************************************/
+
+#include "table.h"
+u32 RTL8723BEPHY_REG_1TARRAY[] = {
+	0x800, 0x80040000,
+	0x804, 0x00000003,
+	0x808, 0x0000FC00,
+	0x80C, 0x0000000A,
+	0x810, 0x10001331,
+	0x814, 0x020C3D10,
+	0x818, 0x02200385,
+	0x81C, 0x00000000,
+	0x820, 0x01000100,
+	0x824, 0x00390204,
+	0x828, 0x00000000,
+	0x82C, 0x00000000,
+	0x830, 0x00000000,
+	0x834, 0x00000000,
+	0x838, 0x00000000,
+	0x83C, 0x00000000,
+	0x840, 0x00010000,
+	0x844, 0x00000000,
+	0x848, 0x00000000,
+	0x84C, 0x00000000,
+	0x850, 0x00000000,
+	0x854, 0x00000000,
+	0x858, 0x569A11A9,
+	0x85C, 0x01000014,
+	0x860, 0x66F60110,
+	0x864, 0x061F0649,
+	0x868, 0x00000000,
+	0x86C, 0x27272700,
+	0x870, 0x07000760,
+	0x874, 0x25004000,
+	0x878, 0x00000808,
+	0x87C, 0x00000000,
+	0x880, 0xB0000C1C,
+	0x884, 0x00000001,
+	0x888, 0x00000000,
+	0x88C, 0xCCC000C0,
+	0x890, 0x00000800,
+	0x894, 0xFFFFFFFE,
+	0x898, 0x40302010,
+	0x89C, 0x00706050,
+	0x900, 0x00000000,
+	0x904, 0x00000023,
+	0x908, 0x00000000,
+	0x90C, 0x81121111,
+	0x910, 0x00000002,
+	0x914, 0x00000201,
+	0x948, 0x00000000,
+	0xA00, 0x00D047C8,
+	0xA04, 0x80FF000C,
+	0xA08, 0x8C838300,
+	0xA0C, 0x2E7F120F,
+	0xA10, 0x9500BB78,
+	0xA14, 0x1114D028,
+	0xA18, 0x00881117,
+	0xA1C, 0x89140F00,
+	0xA20, 0x1A1B0000,
+	0xA24, 0x090E1317,
+	0xA28, 0x00000204,
+	0xA2C, 0x00D30000,
+	0xA70, 0x101FBF00,
+	0xA74, 0x00000007,
+	0xA78, 0x00000900,
+	0xA7C, 0x225B0606,
+	0xA80, 0x21806490,
+	0xB2C, 0x00000000,
+	0xC00, 0x48071D40,
+	0xC04, 0x03A05611,
+	0xC08, 0x000000E4,
+	0xC0C, 0x6C6C6C6C,
+	0xC10, 0x08800000,
+	0xC14, 0x40000100,
+	0xC18, 0x08800000,
+	0xC1C, 0x40000100,
+	0xC20, 0x00000000,
+	0xC24, 0x00000000,
+	0xC28, 0x00000000,
+	0xC2C, 0x00000000,
+	0xC30, 0x69E9AC44,
+	0xC34, 0x469652AF,
+	0xC38, 0x49795994,
+	0xC3C, 0x0A97971C,
+	0xC40, 0x1F7C403F,
+	0xC44, 0x000100B7,
+	0xC48, 0xEC020107,
+	0xC4C, 0x007F037F,
+	0xC50, 0x69553420,
+	0xC54, 0x43BC0094,
+	0xC58, 0x00023169,
+	0xC5C, 0x00250492,
+	0xC60, 0x00000000,
+	0xC64, 0x7112848B,
+	0xC68, 0x47C00BFF,
+	0xC6C, 0x00000036,
+	0xC70, 0x2C7F000D,
+	0xC74, 0x020610DB,
+	0xC78, 0x0000001F,
+	0xC7C, 0x00B91612,
+	0xC80, 0x390000E4,
+	0xC84, 0x20F60000,
+	0xC88, 0x40000100,
+	0xC8C, 0x20200000,
+	0xC90, 0x00020E1A,
+	0xC94, 0x00000000,
+	0xC98, 0x00020E1A,
+	0xC9C, 0x00007F7F,
+	0xCA0, 0x00000000,
+	0xCA4, 0x000300A0,
+	0xCA8, 0x00000000,
+	0xCAC, 0x00000000,
+	0xCB0, 0x00000000,
+	0xCB4, 0x00000000,
+	0xCB8, 0x00000000,
+	0xCBC, 0x28000000,
+	0xCC0, 0x00000000,
+	0xCC4, 0x00000000,
+	0xCC8, 0x00000000,
+	0xCCC, 0x00000000,
+	0xCD0, 0x00000000,
+	0xCD4, 0x00000000,
+	0xCD8, 0x64B22427,
+	0xCDC, 0x00766932,
+	0xCE0, 0x00222222,
+	0xCE4, 0x00000000,
+	0xCE8, 0x37644302,
+	0xCEC, 0x2F97D40C,
+	0xD00, 0x00000740,
+	0xD04, 0x40020401,
+	0xD08, 0x0000907F,
+	0xD0C, 0x20010201,
+	0xD10, 0xA0633333,
+	0xD14, 0x3333BC53,
+	0xD18, 0x7A8F5B6F,
+	0xD2C, 0xCC979975,
+	0xD30, 0x00000000,
+	0xD34, 0x80608000,
+	0xD38, 0x00000000,
+	0xD3C, 0x00127353,
+	0xD40, 0x00000000,
+	0xD44, 0x00000000,
+	0xD48, 0x00000000,
+	0xD4C, 0x00000000,
+	0xD50, 0x6437140A,
+	0xD54, 0x00000000,
+	0xD58, 0x00000282,
+	0xD5C, 0x30032064,
+	0xD60, 0x4653DE68,
+	0xD64, 0x04518A3C,
+	0xD68, 0x00002101,
+	0xD6C, 0x2A201C16,
+	0xD70, 0x1812362E,
+	0xD74, 0x322C2220,
+	0xD78, 0x000E3C24,
+	0xE00, 0x2D2D2D2D,
+	0xE04, 0x2D2D2D2D,
+	0xE08, 0x0390272D,
+	0xE10, 0x2D2D2D2D,
+	0xE14, 0x2D2D2D2D,
+	0xE18, 0x2D2D2D2D,
+	0xE1C, 0x2D2D2D2D,
+	0xE28, 0x00000000,
+	0xE30, 0x1000DC1F,
+	0xE34, 0x10008C1F,
+	0xE38, 0x02140102,
+	0xE3C, 0x681604C2,
+	0xE40, 0x01007C00,
+	0xE44, 0x01004800,
+	0xE48, 0xFB000000,
+	0xE4C, 0x000028D1,
+	0xE50, 0x1000DC1F,
+	0xE54, 0x10008C1F,
+	0xE58, 0x02140102,
+	0xE5C, 0x28160D05,
+	0xE60, 0x00000008,
+	0xE68, 0x001B2556,
+	0xE6C, 0x00C00096,
+	0xE70, 0x00C00096,
+	0xE74, 0x01000056,
+	0xE78, 0x01000014,
+	0xE7C, 0x01000056,
+	0xE80, 0x01000014,
+	0xE84, 0x00C00096,
+	0xE88, 0x01000056,
+	0xE8C, 0x00C00096,
+	0xED0, 0x00C00096,
+	0xED4, 0x00C00096,
+	0xED8, 0x00C00096,
+	0xEDC, 0x000000D6,
+	0xEE0, 0x000000D6,
+	0xEEC, 0x01C00016,
+	0xF14, 0x00000003,
+	0xF4C, 0x00000000,
+	0xF00, 0x00000300,
+	0x820, 0x01000100,
+	0x800, 0x83040000,
+};
+
+u32 RTL8723BEPHY_REG_ARRAY_PG[] = {
+	0, 0, 0, 0x00000e08, 0x0000ff00, 0x00004000,
+	0, 0, 0, 0x0000086c, 0xffffff00, 0x34363800,
+	0, 0, 0, 0x00000e00, 0xffffffff, 0x42444646,
+	0, 0, 0, 0x00000e04, 0xffffffff, 0x30343840,
+	0, 0, 0, 0x00000e10, 0xffffffff, 0x38404244,
+	0, 0, 0, 0x00000e14, 0xffffffff, 0x26303436
+};
+
+u32 RTL8723BE_RADIOA_1TARRAY[] = {
+	0x000, 0x00010000,
+	0x0B0, 0x000DFFE0,
+	0x0FE, 0x00000000,
+	0x0FE, 0x00000000,
+	0x0FE, 0x00000000,
+	0x0B1, 0x00000018,
+	0x0FE, 0x00000000,
+	0x0FE, 0x00000000,
+	0x0FE, 0x00000000,
+	0x0B2, 0x00084C00,
+	0x0B5, 0x0000D2CC,
+	0x0B6, 0x000925AA,
+	0x0B7, 0x00000010,
+	0x0B8, 0x0000907F,
+	0x05C, 0x00000002,
+	0x07C, 0x00000002,
+	0x07E, 0x00000005,
+	0x08B, 0x0006FC00,
+	0x0B0, 0x000FF9F0,
+	0x01C, 0x000739D2,
+	0x01E, 0x00000000,
+	0x0DF, 0x00000780,
+	0x050, 0x00067435,
+	0x051, 0x0006B04E,
+	0x052, 0x000007D2,
+	0x053, 0x00000000,
+	0x054, 0x00050400,
+	0x055, 0x0004026E,
+	0x0DD, 0x0000004C,
+	0x070, 0x00067435,
+	0x071, 0x0006B04E,
+	0x072, 0x000007D2,
+	0x073, 0x00000000,
+	0x074, 0x00050400,
+	0x075, 0x0004026E,
+	0x0EF, 0x00000100,
+	0x034, 0x0000ADD7,
+	0x035, 0x00005C00,
+	0x034, 0x00009DD4,
+	0x035, 0x00005000,
+	0x034, 0x00008DD1,
+	0x035, 0x00004400,
+	0x034, 0x00007DCE,
+	0x035, 0x00003800,
+	0x034, 0x00006CD1,
+	0x035, 0x00004400,
+	0x034, 0x00005CCE,
+	0x035, 0x00003800,
+	0x034, 0x000048CE,
+	0x035, 0x00004400,
+	0x034, 0x000034CE,
+	0x035, 0x00003800,
+	0x034, 0x00002451,
+	0x035, 0x00004400,
+	0x034, 0x0000144E,
+	0x035, 0x00003800,
+	0x034, 0x00000051,
+	0x035, 0x00004400,
+	0x0EF, 0x00000000,
+	0x0EF, 0x00000100,
+	0x0ED, 0x00000010,
+	0x044, 0x0000ADD7,
+	0x044, 0x00009DD4,
+	0x044, 0x00008DD1,
+	0x044, 0x00007DCE,
+	0x044, 0x00006CC1,
+	0x044, 0x00005CCE,
+	0x044, 0x000044D1,
+	0x044, 0x000034CE,
+	0x044, 0x00002451,
+	0x044, 0x0000144E,
+	0x044, 0x00000051,
+	0x0EF, 0x00000000,
+	0x0ED, 0x00000000,
+	0x0EF, 0x00002000,
+	0x03B, 0x000380EF,
+	0x03B, 0x000302FE,
+	0x03B, 0x00028CE6,
+	0x03B, 0x000200BC,
+	0x03B, 0x000188A5,
+	0x03B, 0x00010FBC,
+	0x03B, 0x00008F71,
+	0x03B, 0x00000900,
+	0x0EF, 0x00000000,
+	0x0ED, 0x00000001,
+	0x040, 0x000380EF,
+	0x040, 0x000302FE,
+	0x040, 0x00028CE6,
+	0x040, 0x000200BC,
+	0x040, 0x000188A5,
+	0x040, 0x00010FBC,
+	0x040, 0x00008F71,
+	0x040, 0x00000900,
+	0x0ED, 0x00000000,
+	0x082, 0x00080000,
+	0x083, 0x00008000,
+	0x084, 0x00048D80,
+	0x085, 0x00068000,
+	0x0A2, 0x00080000,
+	0x0A3, 0x00008000,
+	0x0A4, 0x00048D80,
+	0x0A5, 0x00068000,
+	0x000, 0x00033D80,
+};
+
+u32 RTL8723BEMAC_1T_ARRAY[] = {
+	0x02F, 0x00000030,
+	0x035, 0x00000000,
+	0x428, 0x0000000A,
+	0x429, 0x00000010,
+	0x430, 0x00000000,
+	0x431, 0x00000000,
+	0x432, 0x00000000,
+	0x433, 0x00000001,
+	0x434, 0x00000004,
+	0x435, 0x00000005,
+	0x436, 0x00000007,
+	0x437, 0x00000008,
+	0x43C, 0x00000004,
+	0x43D, 0x00000005,
+	0x43E, 0x00000007,
+	0x43F, 0x00000008,
+	0x440, 0x0000005D,
+	0x441, 0x00000001,
+	0x442, 0x00000000,
+	0x444, 0x00000010,
+	0x445, 0x00000000,
+	0x446, 0x00000000,
+	0x447, 0x00000000,
+	0x448, 0x00000000,
+	0x449, 0x000000F0,
+	0x44A, 0x0000000F,
+	0x44B, 0x0000003E,
+	0x44C, 0x00000010,
+	0x44D, 0x00000000,
+	0x44E, 0x00000000,
+	0x44F, 0x00000000,
+	0x450, 0x00000000,
+	0x451, 0x000000F0,
+	0x452, 0x0000000F,
+	0x453, 0x00000000,
+	0x456, 0x0000005E,
+	0x460, 0x00000066,
+	0x461, 0x00000066,
+	0x4C8, 0x000000FF,
+	0x4C9, 0x00000008,
+	0x4CC, 0x000000FF,
+	0x4CD, 0x000000FF,
+	0x4CE, 0x00000001,
+	0x500, 0x00000026,
+	0x501, 0x000000A2,
+	0x502, 0x0000002F,
+	0x503, 0x00000000,
+	0x504, 0x00000028,
+	0x505, 0x000000A3,
+	0x506, 0x0000005E,
+	0x507, 0x00000000,
+	0x508, 0x0000002B,
+	0x509, 0x000000A4,
+	0x50A, 0x0000005E,
+	0x50B, 0x00000000,
+	0x50C, 0x0000004F,
+	0x50D, 0x000000A4,
+	0x50E, 0x00000000,
+	0x50F, 0x00000000,
+	0x512, 0x0000001C,
+	0x514, 0x0000000A,
+	0x516, 0x0000000A,
+	0x525, 0x0000004F,
+	0x550, 0x00000010,
+	0x551, 0x00000010,
+	0x559, 0x00000002,
+	0x55C, 0x00000050,
+	0x55D, 0x000000FF,
+	0x605, 0x00000030,
+	0x608, 0x0000000E,
+	0x609, 0x0000002A,
+	0x620, 0x000000FF,
+	0x621, 0x000000FF,
+	0x622, 0x000000FF,
+	0x623, 0x000000FF,
+	0x624, 0x000000FF,
+	0x625, 0x000000FF,
+	0x626, 0x000000FF,
+	0x627, 0x000000FF,
+	0x638, 0x00000050,
+	0x63C, 0x0000000A,
+	0x63D, 0x0000000A,
+	0x63E, 0x0000000E,
+	0x63F, 0x0000000E,
+	0x640, 0x00000040,
+	0x642, 0x00000040,
+	0x643, 0x00000000,
+	0x652, 0x000000C8,
+	0x66E, 0x00000005,
+	0x700, 0x00000021,
+	0x701, 0x00000043,
+	0x702, 0x00000065,
+	0x703, 0x00000087,
+	0x708, 0x00000021,
+	0x709, 0x00000043,
+	0x70A, 0x00000065,
+	0x70B, 0x00000087,
+};
+
+u32 RTL8723BEAGCTAB_1TARRAY[] = {
+	0xC78, 0xFD000001,
+	0xC78, 0xFC010001,
+	0xC78, 0xFB020001,
+	0xC78, 0xFA030001,
+	0xC78, 0xF9040001,
+	0xC78, 0xF8050001,
+	0xC78, 0xF7060001,
+	0xC78, 0xF6070001,
+	0xC78, 0xF5080001,
+	0xC78, 0xF4090001,
+	0xC78, 0xF30A0001,
+	0xC78, 0xF20B0001,
+	0xC78, 0xF10C0001,
+	0xC78, 0xF00D0001,
+	0xC78, 0xEF0E0001,
+	0xC78, 0xEE0F0001,
+	0xC78, 0xED100001,
+	0xC78, 0xEC110001,
+	0xC78, 0xEB120001,
+	0xC78, 0xEA130001,
+	0xC78, 0xE9140001,
+	0xC78, 0xE8150001,
+	0xC78, 0xE7160001,
+	0xC78, 0xAA170001,
+	0xC78, 0xA9180001,
+	0xC78, 0xA8190001,
+	0xC78, 0xA71A0001,
+	0xC78, 0xA61B0001,
+	0xC78, 0xA51C0001,
+	0xC78, 0xA41D0001,
+	0xC78, 0xA31E0001,
+	0xC78, 0x671F0001,
+	0xC78, 0x66200001,
+	0xC78, 0x65210001,
+	0xC78, 0x64220001,
+	0xC78, 0x63230001,
+	0xC78, 0x62240001,
+	0xC78, 0x61250001,
+	0xC78, 0x47260001,
+	0xC78, 0x46270001,
+	0xC78, 0x45280001,
+	0xC78, 0x44290001,
+	0xC78, 0x432A0001,
+	0xC78, 0x422B0001,
+	0xC78, 0x292C0001,
+	0xC78, 0x282D0001,
+	0xC78, 0x272E0001,
+	0xC78, 0x262F0001,
+	0xC78, 0x25300001,
+	0xC78, 0x24310001,
+	0xC78, 0x09320001,
+	0xC78, 0x08330001,
+	0xC78, 0x07340001,
+	0xC78, 0x06350001,
+	0xC78, 0x05360001,
+	0xC78, 0x04370001,
+	0xC78, 0x03380001,
+	0xC78, 0x02390001,
+	0xC78, 0x013A0001,
+	0xC78, 0x003B0001,
+	0xC78, 0x003C0001,
+	0xC78, 0x003D0001,
+	0xC78, 0x003E0001,
+	0xC78, 0x003F0001,
+	0xC78, 0xFC400001,
+	0xC78, 0xFB410001,
+	0xC78, 0xFA420001,
+	0xC78, 0xF9430001,
+	0xC78, 0xF8440001,
+	0xC78, 0xF7450001,
+	0xC78, 0xF6460001,
+	0xC78, 0xF5470001,
+	0xC78, 0xF4480001,
+	0xC78, 0xF3490001,
+	0xC78, 0xF24A0001,
+	0xC78, 0xF14B0001,
+	0xC78, 0xF04C0001,
+	0xC78, 0xEF4D0001,
+	0xC78, 0xEE4E0001,
+	0xC78, 0xED4F0001,
+	0xC78, 0xEC500001,
+	0xC78, 0xEB510001,
+	0xC78, 0xEA520001,
+	0xC78, 0xE9530001,
+	0xC78, 0xE8540001,
+	0xC78, 0xE7550001,
+	0xC78, 0xE6560001,
+	0xC78, 0xE5570001,
+	0xC78, 0xAA580001,
+	0xC78, 0xA9590001,
+	0xC78, 0xA85A0001,
+	0xC78, 0xA75B0001,
+	0xC78, 0xA65C0001,
+	0xC78, 0xA55D0001,
+	0xC78, 0xA45E0001,
+	0xC78, 0x675F0001,
+	0xC78, 0x66600001,
+	0xC78, 0x65610001,
+	0xC78, 0x64620001,
+	0xC78, 0x63630001,
+	0xC78, 0x62640001,
+	0xC78, 0x61650001,
+	0xC78, 0x47660001,
+	0xC78, 0x46670001,
+	0xC78, 0x45680001,
+	0xC78, 0x44690001,
+	0xC78, 0x436A0001,
+	0xC78, 0x426B0001,
+	0xC78, 0x296C0001,
+	0xC78, 0x286D0001,
+	0xC78, 0x276E0001,
+	0xC78, 0x266F0001,
+	0xC78, 0x25700001,
+	0xC78, 0x24710001,
+	0xC78, 0x09720001,
+	0xC78, 0x08730001,
+	0xC78, 0x07740001,
+	0xC78, 0x06750001,
+	0xC78, 0x05760001,
+	0xC78, 0x04770001,
+	0xC78, 0x03780001,
+	0xC78, 0x02790001,
+	0xC78, 0x017A0001,
+	0xC78, 0x007B0001,
+	0xC78, 0x007C0001,
+	0xC78, 0x007D0001,
+	0xC78, 0x007E0001,
+	0xC78, 0x007F0001,
+	0xC50, 0x69553422,
+	0xC50, 0x69553420,
+};
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/table.h b/drivers/net/wireless/rtlwifi/rtl8723be/table.h
new file mode 100644
index 0000000..932760a
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/table.h
@@ -0,0 +1,43 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Created on  2010/ 5/18,  1:41
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL8723BE_TABLE__H_
+#define __RTL8723BE_TABLE__H_
+
+#include <linux/types.h>
+#define  RTL8723BEPHY_REG_1TARRAYLEN	388
+extern u32 RTL8723BEPHY_REG_1TARRAY[];
+#define RTL8723BEPHY_REG_ARRAY_PGLEN	36
+extern u32 RTL8723BEPHY_REG_ARRAY_PG[];
+#define	RTL8723BE_RADIOA_1TARRAYLEN	206
+extern u32 RTL8723BE_RADIOA_1TARRAY[];
+#define RTL8723BEMAC_1T_ARRAYLEN	194
+extern u32 RTL8723BEMAC_1T_ARRAY[];
+#define RTL8723BEAGCTAB_1TARRAYLEN	260
+extern u32 RTL8723BEAGCTAB_1TARRAY[];
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
new file mode 100644
index 0000000..ccec8f3
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -0,0 +1,959 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
+#include "../stats.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "trx.h"
+#include "led.h"
+#include "dm.h"
+#include "phy.h"
+
+static u8 _rtl8723be_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
+{
+	__le16 fc = rtl_get_fc(skb);
+
+	if (unlikely(ieee80211_is_beacon(fc)))
+		return QSLT_BEACON;
+	if (ieee80211_is_mgmt(fc) || ieee80211_is_ctl(fc))
+		return QSLT_MGNT;
+
+	return skb->priority;
+}
+
+/* mac80211's rate_idx is like this:
+ *
+ * 2.4G band:rx_status->band == IEEE80211_BAND_2GHZ
+ *
+ * B/G rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE1M-->DESC92C_RATE54M ==> idx is 0-->11,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ *
+ * 5G band:rx_status->band == IEEE80211_BAND_5GHZ
+ * A rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE6M-->DESC92C_RATE54M ==> idx is 0-->7,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ */
+static int _rtl8723be_rate_mapping(struct ieee80211_hw *hw,
+				   bool isht, u8 desc_rate)
+{
+	int rate_idx;
+
+	if (!isht) {
+		if (IEEE80211_BAND_2GHZ == hw->conf.chandef.chan->band) {
+			switch (desc_rate) {
+			case DESC92C_RATE1M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE2M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE5_5M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE11M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE6M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 7;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 8;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 9;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 10;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 11;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		} else {
+			switch (desc_rate) {
+			case DESC92C_RATE6M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 7;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		}
+	} else {
+		switch (desc_rate) {
+		case DESC92C_RATEMCS0:
+			rate_idx = 0;
+			break;
+		case DESC92C_RATEMCS1:
+			rate_idx = 1;
+			break;
+		case DESC92C_RATEMCS2:
+			rate_idx = 2;
+			break;
+		case DESC92C_RATEMCS3:
+			rate_idx = 3;
+			break;
+		case DESC92C_RATEMCS4:
+			rate_idx = 4;
+			break;
+		case DESC92C_RATEMCS5:
+			rate_idx = 5;
+			break;
+		case DESC92C_RATEMCS6:
+			rate_idx = 6;
+			break;
+		case DESC92C_RATEMCS7:
+			rate_idx = 7;
+			break;
+		case DESC92C_RATEMCS8:
+			rate_idx = 8;
+			break;
+		case DESC92C_RATEMCS9:
+			rate_idx = 9;
+			break;
+		case DESC92C_RATEMCS10:
+			rate_idx = 10;
+			break;
+		case DESC92C_RATEMCS11:
+			rate_idx = 11;
+			break;
+		case DESC92C_RATEMCS12:
+			rate_idx = 12;
+			break;
+		case DESC92C_RATEMCS13:
+			rate_idx = 13;
+			break;
+		case DESC92C_RATEMCS14:
+			rate_idx = 14;
+			break;
+		case DESC92C_RATEMCS15:
+			rate_idx = 15;
+			break;
+		default:
+			rate_idx = 0;
+			break;
+		}
+	}
+	return rate_idx;
+}
+
+static void _rtl8723be_query_rxphystatus(struct ieee80211_hw *hw,
+					 struct rtl_stats *pstatus, u8 *pdesc,
+					 struct rx_fwinfo_8723be *p_drvinfo,
+					 bool packet_match_bssid,
+					 bool packet_toself,
+					 bool packet_beacon)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
+	struct phy_sts_cck_8723e_t *cck_buf;
+	struct phy_status_rpt *p_phystrpt = (struct phy_status_rpt *)p_drvinfo;
+	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
+	char rx_pwr_all = 0, rx_pwr[4];
+	u8 rf_rx_num = 0, evm, pwdb_all;
+	u8 i, max_spatial_stream;
+	u32 rssi, total_rssi = 0;
+	bool is_cck = pstatus->is_cck;
+	u8 lan_idx, vga_idx;
+
+	/* Record it for next packet processing */
+	pstatus->packet_matchbssid = packet_match_bssid;
+	pstatus->packet_toself = packet_toself;
+	pstatus->packet_beacon = packet_beacon;
+	pstatus->rx_mimo_sig_qual[0] = -1;
+	pstatus->rx_mimo_sig_qual[1] = -1;
+
+	if (is_cck) {
+		u8 cck_highpwr;
+		u8 cck_agc_rpt;
+		/* CCK Driver info Structure is not the same as OFDM packet. */
+		cck_buf = (struct phy_sts_cck_8723e_t *)p_drvinfo;
+		cck_agc_rpt = cck_buf->cck_agc_rpt;
+
+		/* (1)Hardware does not provide RSSI for CCK
+		 * (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
+		if (ppsc->rfpwr_state == ERFON)
+			cck_highpwr = (u8) rtl_get_bbreg(hw,
+						       RFPGA0_XA_HSSIPARAMETER2,
+						       BIT(9));
+		else
+			cck_highpwr = false;
+
+		lan_idx = ((cck_agc_rpt & 0xE0) >> 5);
+		vga_idx = (cck_agc_rpt & 0x1f);
+		switch (lan_idx) {
+		case 7:
+			if (vga_idx <= 27)/*VGA_idx = 27~2*/
+				rx_pwr_all = -100 + 2 * (27 - vga_idx);
+			else
+				rx_pwr_all = -100;
+			break;
+		case 6:/*VGA_idx = 2~0*/
+			rx_pwr_all = -48 + 2 * (2 - vga_idx);
+			break;
+		case 5:/*VGA_idx = 7~5*/
+			rx_pwr_all = -42 + 2 * (7 - vga_idx);
+			break;
+		case 4:/*VGA_idx = 7~4*/
+			rx_pwr_all = -36 + 2 * (7 - vga_idx);
+			break;
+		case 3:/*VGA_idx = 7~0*/
+			rx_pwr_all = -24 + 2 * (7 - vga_idx);
+			break;
+		case 2:
+			if (cck_highpwr)/*VGA_idx = 5~0*/
+				rx_pwr_all = -12 + 2 * (5 - vga_idx);
+			else
+				rx_pwr_all = -6 + 2 * (5 - vga_idx);
+			break;
+		case 1:
+			rx_pwr_all = 8 - 2 * vga_idx;
+			break;
+		case 0:
+			rx_pwr_all = 14 - 2 * vga_idx;
+			break;
+		default:
+			break;
+		}
+		rx_pwr_all += 6;
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		/* CCK gain is smaller than OFDM/MCS gain,  */
+		/* so we add gain diff by experiences,
+		 * the val is 6
+		 */
+		pwdb_all += 6;
+		if (pwdb_all > 100)
+			pwdb_all = 100;
+		/* modify the offset to make the same gain index with OFDM. */
+		if (pwdb_all > 34 && pwdb_all <= 42)
+			pwdb_all -= 2;
+		else if (pwdb_all > 26 && pwdb_all <= 34)
+			pwdb_all -= 6;
+		else if (pwdb_all > 14 && pwdb_all <= 26)
+			pwdb_all -= 8;
+		else if (pwdb_all > 4 && pwdb_all <= 14)
+			pwdb_all -= 4;
+		if (!cck_highpwr) {
+			if (pwdb_all >= 80)
+				pwdb_all = ((pwdb_all - 80) << 1) +
+					   ((pwdb_all - 80) >> 1) + 80;
+			else if ((pwdb_all <= 78) && (pwdb_all >= 20))
+				pwdb_all += 3;
+			if (pwdb_all > 100)
+				pwdb_all = 100;
+		}
+
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3) Get Signal Quality (EVM) */
+		if (packet_match_bssid) {
+			u8 sq;
+
+			if (pstatus->rx_pwdb_all > 40) {
+				sq = 100;
+			} else {
+				sq = cck_buf->sq_rpt;
+				if (sq > 64)
+					sq = 0;
+				else if (sq < 20)
+					sq = 100;
+				else
+					sq = ((64 - sq) * 100) / 44;
+			}
+
+			pstatus->signalquality = sq;
+			pstatus->rx_mimo_sig_qual[0] = sq;
+			pstatus->rx_mimo_sig_qual[1] = -1;
+		}
+	} else {
+		rtlpriv->dm.rfpath_rxenable[0] = true;
+		rtlpriv->dm.rfpath_rxenable[1] = true;
+
+		/* (1)Get RSSI for HT rate */
+		for (i = RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
+			/* we will judge RF RX path now. */
+			if (rtlpriv->dm.rfpath_rxenable[i])
+				rf_rx_num++;
+
+			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f)*2) - 110;
+
+			/* Translate DBM to percentage. */
+			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
+			total_rssi += rssi;
+
+			/* Get Rx snr value in DB */
+			rtlpriv->stats.rx_snr_db[i] =
+					(long)(p_drvinfo->rxsnr[i] / 2);
+
+			/* Record Signal Strength for next packet */
+			if (packet_match_bssid)
+				pstatus->rx_mimo_signalstrength[i] = (u8) rssi;
+		}
+
+		/* (2)PWDB, Avg cacluated by hardware (for rate adaptive) */
+		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
+
+		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->rxpower = rx_pwr_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3)EVM of HT rate */
+		if (pstatus->is_ht && pstatus->rate >= DESC92C_RATEMCS8 &&
+		    pstatus->rate <= DESC92C_RATEMCS15)
+			max_spatial_stream = 2;
+		else
+			max_spatial_stream = 1;
+
+		for (i = 0; i < max_spatial_stream; i++) {
+			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+
+			if (packet_match_bssid) {
+				/* Fill value in RFD, Get the first
+				 * spatial stream only
+				 */
+				if (i == 0)
+					pstatus->signalquality =
+							(u8) (evm & 0xff);
+				pstatus->rx_mimo_sig_qual[i] =
+							(u8) (evm & 0xff);
+			}
+		}
+		if (packet_match_bssid) {
+			for (i = RF90_PATH_A; i <= RF90_PATH_B; i++)
+				rtl_priv(hw)->dm.cfo_tail[i] =
+					(char)p_phystrpt->path_cfotail[i];
+
+			rtl_priv(hw)->dm.packet_count++;
+			if (rtl_priv(hw)->dm.packet_count == 0xffffffff)
+				rtl_priv(hw)->dm.packet_count = 0;
+		}
+	}
+
+	/* UI BSS List signal strength(in percentage),
+	 * make it good looking, from 0~100.
+	 */
+	if (is_cck)
+		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
+								pwdb_all));
+	else if (rf_rx_num != 0)
+		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
+						total_rssi /= rf_rx_num));
+	/*HW antenna diversity*/
+	rtldm->fat_table.antsel_rx_keep_0 = p_phystrpt->ant_sel;
+	rtldm->fat_table.antsel_rx_keep_1 = p_phystrpt->ant_sel_b;
+	rtldm->fat_table.antsel_rx_keep_2 = p_phystrpt->antsel_rx_keep_2;
+}
+
+static void _rtl8723be_translate_rx_signal_stuff(struct ieee80211_hw *hw,
+					struct sk_buff *skb,
+					struct rtl_stats *pstatus,
+					u8 *pdesc,
+					struct rx_fwinfo_8723be *p_drvinfo)
+{
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct ieee80211_hdr *hdr;
+	u8 *tmp_buf;
+	u8 *praddr;
+	u8 *psaddr;
+	u16 fc, type;
+	bool packet_matchbssid, packet_toself, packet_beacon;
+
+	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
+
+	hdr = (struct ieee80211_hdr *)tmp_buf;
+	fc = le16_to_cpu(hdr->frame_control);
+	type = WLAN_FC_GET_TYPE(hdr->frame_control);
+	praddr = hdr->addr1;
+	psaddr = ieee80211_get_SA(hdr);
+	memcpy(pstatus->psaddr, psaddr, ETH_ALEN);
+
+	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
+	     (!ether_addr_equal(mac->bssid, (fc & IEEE80211_FCTL_TODS) ?
+				hdr->addr1 : (fc & IEEE80211_FCTL_FROMDS) ?
+				hdr->addr2 : hdr->addr3)) &&
+				(!pstatus->hwerror) &&
+				(!pstatus->crc) && (!pstatus->icv));
+
+	packet_toself = packet_matchbssid &&
+	    (!ether_addr_equal(praddr, rtlefuse->dev_addr));
+
+	/* YP: packet_beacon is not initialized,
+	 * this assignment is neccesary,
+	 * otherwise it counld be true in this case
+	 * the situation is much worse in Kernel 3.10
+	 */
+	if (ieee80211_is_beacon(hdr->frame_control))
+		packet_beacon = true;
+	else
+		packet_beacon = false;
+
+	if (packet_beacon && packet_matchbssid)
+		rtl_priv(hw)->dm.dbginfo.num_qry_beacon_pkt++;
+
+	_rtl8723be_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
+				     packet_matchbssid,
+				     packet_toself,
+				     packet_beacon);
+
+	rtl_process_phyinfo(hw, tmp_buf, pstatus);
+}
+
+static void _rtl8723be_insert_emcontent(struct rtl_tcb_desc *ptcb_desc,
+					u8 *virtualaddress)
+{
+	u32 dwtmp = 0;
+	memset(virtualaddress, 0, 8);
+
+	SET_EARLYMODE_PKTNUM(virtualaddress, ptcb_desc->empkt_num);
+	if (ptcb_desc->empkt_num == 1) {
+		dwtmp = ptcb_desc->empkt_len[0];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[0];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[1];
+	}
+	SET_EARLYMODE_LEN0(virtualaddress, dwtmp);
+
+	if (ptcb_desc->empkt_num <= 3) {
+		dwtmp = ptcb_desc->empkt_len[2];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[2];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[3];
+	}
+	SET_EARLYMODE_LEN1(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <= 5) {
+		dwtmp = ptcb_desc->empkt_len[4];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[4];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[5];
+	}
+	SET_EARLYMODE_LEN2_1(virtualaddress, dwtmp & 0xF);
+	SET_EARLYMODE_LEN2_2(virtualaddress, dwtmp >> 4);
+	if (ptcb_desc->empkt_num <= 7) {
+		dwtmp = ptcb_desc->empkt_len[6];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[6];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[7];
+	}
+	SET_EARLYMODE_LEN3(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <= 9) {
+		dwtmp = ptcb_desc->empkt_len[8];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[8];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[9];
+	}
+	SET_EARLYMODE_LEN4(virtualaddress, dwtmp);
+}
+
+bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
+			     struct rtl_stats *status,
+			     struct ieee80211_rx_status *rx_status,
+			     u8 *pdesc, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rx_fwinfo_8723be *p_drvinfo;
+	struct ieee80211_hdr *hdr;
+
+	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
+	status->packet_report_type = (u8)GET_RX_STATUS_DESC_RPT_SEL(pdesc);
+	if (status->packet_report_type == TX_REPORT2)
+		status->length = (u16) GET_RX_RPT2_DESC_PKT_LEN(pdesc);
+	else
+		status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+				  RX_DRV_INFO_SIZE_UNIT;
+	status->rx_bufshift = (u8) (GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->icv = (u16) GET_RX_DESC_ICV(pdesc);
+	status->crc = (u16) GET_RX_DESC_CRC32(pdesc);
+	status->hwerror = (status->crc | status->icv);
+	status->decrypted = !GET_RX_DESC_SWDEC(pdesc);
+	status->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
+	status->shortpreamble = (u16) GET_RX_DESC_SPLCP(pdesc);
+	status->isampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
+	status->isfirst_ampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
+	if (status->packet_report_type == NORMAL_RX)
+		status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
+	status->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
+	status->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
+
+	status->is_cck = RTL8723E_RX_HAL_IS_CCK_RATE(status->rate);
+
+	status->macid = GET_RX_DESC_MACID(pdesc);
+	if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match = BIT(2);
+	else if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match = BIT(1);
+	else if (GET_RX_STATUS_DESC_UNICAST_MATCH(pdesc))
+		status->wake_match = BIT(0);
+	else
+		status->wake_match = 0;
+	if (status->wake_match)
+		RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD,
+			 "GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch=%d\n",
+			 status->wake_match);
+	rx_status->freq = hw->conf.chandef.chan->center_freq;
+	rx_status->band = hw->conf.chandef.chan->band;
+
+
+	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size +
+				       status->rx_bufshift);
+
+	if (status->crc)
+		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
+
+	if (status->rx_is40Mhzpacket)
+		rx_status->flag |= RX_FLAG_40MHZ;
+
+	if (status->is_ht)
+		rx_status->flag |= RX_FLAG_HT;
+
+	rx_status->flag |= RX_FLAG_MACTIME_START;
+
+	/* hw will set status->decrypted true, if it finds the
+	 * frame is open data frame or mgmt frame.
+	 * So hw will not decryption robust managment frame
+	 * for IEEE80211w but still set status->decrypted
+	 * true, so here we should set it back to undecrypted
+	 * for IEEE80211w frame, and mac80211 sw will help
+	 * to decrypt it
+	 */
+	if (status->decrypted) {
+		if (!hdr) {
+			WARN_ON_ONCE(true);
+			pr_err("decrypted is true but hdr NULL in skb %p\n",
+			       rtl_get_hdr(skb));
+			return false;
+		}
+
+		if ((ieee80211_is_robust_mgmt_frame(hdr)) &&
+		    (ieee80211_has_protected(hdr->frame_control)))
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag |= RX_FLAG_DECRYPTED;
+	}
+
+	/* rate_idx: index of data rate into band's
+	 * supported rates or MCS index if HT rates
+	 * are use (RX_FLAG_HT)
+	 * Notice: this is diff with windows define
+	 */
+	rx_status->rate_idx = _rtl8723be_rate_mapping(hw, status->is_ht,
+						      status->rate);
+
+	rx_status->mactime = status->timestamp_low;
+	if (phystatus) {
+		p_drvinfo = (struct rx_fwinfo_8723be *)(skb->data +
+							status->rx_bufshift);
+
+		_rtl8723be_translate_rx_signal_stuff(hw, skb, status,
+						     pdesc, p_drvinfo);
+	}
+
+	/*rx_status->qual = status->signal; */
+	rx_status->signal = status->recvsignalpower + 10;
+	if (status->packet_report_type == TX_REPORT2) {
+		status->macid_valid_entry[0] =
+			 GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
+		status->macid_valid_entry[1] =
+			 GET_RX_RPT2_DESC_MACID_VALID_2(pdesc);
+	}
+	return true;
+}
+
+void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
+			    struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			    struct ieee80211_tx_info *info,
+			    struct ieee80211_sta *sta, struct sk_buff *skb,
+			    u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 *pdesc = (u8 *)pdesc_tx;
+	u16 seq_number;
+	__le16 fc = hdr->frame_control;
+	unsigned int buf_len = 0;
+	unsigned int skb_len = skb->len;
+	u8 fw_qsel = _rtl8723be_map_hwqueue_to_fwqueue(skb, hw_queue);
+	bool firstseg = ((hdr->seq_ctrl &
+			  cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+	bool lastseg = ((hdr->frame_control &
+			 cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+	dma_addr_t mapping;
+	u8 bw_40 = 0;
+	u8 short_gi = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_STATION) {
+		bw_40 = mac->bw_40;
+	} else if (mac->opmode == NL80211_IFTYPE_AP ||
+		mac->opmode == NL80211_IFTYPE_ADHOC) {
+		if (sta)
+			bw_40 = sta->ht_cap.cap &
+				IEEE80211_HT_CAP_SUP_WIDTH_20_40;
+	}
+	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
+	rtl_get_tcb_desc(hw, info, sta, skb, ptcb_desc);
+	/* reserve 8 byte for AMPDU early mode */
+	if (rtlhal->earlymode_enable) {
+		skb_push(skb, EM_HDR_LEN);
+		memset(skb->data, 0, EM_HDR_LEN);
+	}
+	buf_len = skb->len;
+	mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
+				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "DMA mapping error");
+		return;
+	}
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_8723be));
+	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
+		firstseg = true;
+		lastseg = true;
+	}
+	if (firstseg) {
+		if (rtlhal->earlymode_enable) {
+			SET_TX_DESC_PKT_OFFSET(pdesc, 1);
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN +
+					   EM_HDR_LEN);
+			if (ptcb_desc->empkt_num) {
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+					 "Insert 8 byte.pTcb->EMPktNum:%d\n",
+					  ptcb_desc->empkt_num);
+				_rtl8723be_insert_emcontent(ptcb_desc,
+							    (u8 *)(skb->data));
+			}
+		} else {
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+		}
+
+		/* ptcb_desc->use_driver_rate = true; */
+		SET_TX_DESC_TX_RATE(pdesc, ptcb_desc->hw_rate);
+		if (ptcb_desc->hw_rate > DESC92C_RATEMCS0)
+			short_gi = (ptcb_desc->use_shortgi) ? 1 : 0;
+		else
+			short_gi = (ptcb_desc->use_shortpreamble) ? 1 : 0;
+
+		SET_TX_DESC_DATA_SHORTGI(pdesc, short_gi);
+
+		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
+			SET_TX_DESC_AGG_ENABLE(pdesc, 1);
+			SET_TX_DESC_MAX_AGG_NUM(pdesc, 0x14);
+		}
+		SET_TX_DESC_SEQ(pdesc, seq_number);
+		SET_TX_DESC_RTS_ENABLE(pdesc, ((ptcb_desc->rts_enable &&
+						!ptcb_desc->cts_enable) ?
+						1 : 0));
+		SET_TX_DESC_HW_RTS_ENABLE(pdesc, 0);
+		SET_TX_DESC_CTS2SELF(pdesc, ((ptcb_desc->cts_enable) ?
+					      1 : 0));
+
+		SET_TX_DESC_RTS_RATE(pdesc, ptcb_desc->rts_rate);
+
+		SET_TX_DESC_RTS_SC(pdesc, ptcb_desc->rts_sc);
+		SET_TX_DESC_RTS_SHORT(pdesc,
+			((ptcb_desc->rts_rate <= DESC92C_RATE54M) ?
+			 (ptcb_desc->rts_use_shortpreamble ? 1 : 0) :
+			 (ptcb_desc->rts_use_shortgi ? 1 : 0)));
+
+		if (ptcb_desc->btx_enable_sw_calc_duration)
+			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
+
+		if (bw_40) {
+			if (ptcb_desc->packet_bw) {
+				SET_TX_DESC_DATA_BW(pdesc, 1);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
+			} else {
+				SET_TX_DESC_DATA_BW(pdesc, 0);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc, mac->cur_40_prime_sc);
+			}
+		} else {
+			SET_TX_DESC_DATA_BW(pdesc, 0);
+			SET_TX_DESC_TX_SUB_CARRIER(pdesc, 0);
+		}
+
+		SET_TX_DESC_LINIP(pdesc, 0);
+		SET_TX_DESC_PKT_SIZE(pdesc, (u16) skb_len);
+		if (sta) {
+			u8 ampdu_density = sta->ht_cap.ampdu_density;
+			SET_TX_DESC_AMPDU_DENSITY(pdesc, ampdu_density);
+		}
+		if (info->control.hw_key) {
+			struct ieee80211_key_conf *keyconf =
+						info->control.hw_key;
+			switch (keyconf->cipher) {
+			case WLAN_CIPHER_SUITE_WEP40:
+			case WLAN_CIPHER_SUITE_WEP104:
+			case WLAN_CIPHER_SUITE_TKIP:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x1);
+				break;
+			case WLAN_CIPHER_SUITE_CCMP:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x3);
+				break;
+			default:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x0);
+				break;
+			}
+		}
+
+		SET_TX_DESC_QUEUE_SEL(pdesc, fw_qsel);
+		SET_TX_DESC_DATA_RATE_FB_LIMIT(pdesc, 0x1F);
+		SET_TX_DESC_RTS_RATE_FB_LIMIT(pdesc, 0xF);
+		SET_TX_DESC_DISABLE_FB(pdesc, ptcb_desc->disable_ratefallback ?
+				       1 : 0);
+		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
+
+		if (ieee80211_is_data_qos(fc)) {
+			if (mac->rdg_en) {
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+					 "Enable RDG function.\n");
+				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
+				SET_TX_DESC_HTC(pdesc, 1);
+			}
+		}
+	}
+
+	SET_TX_DESC_FIRST_SEG(pdesc, (firstseg ? 1 : 0));
+	SET_TX_DESC_LAST_SEG(pdesc, (lastseg ? 1 : 0));
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) buf_len);
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+	SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
+	SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+
+	if (!ieee80211_is_data_qos(fc))  {
+		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
+		SET_TX_DESC_HWSEQ_SEL(pdesc, 0);
+	}
+	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
+	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
+		SET_TX_DESC_BMC(pdesc, 1);
+	}
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
+}
+
+void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
+			       bool b_firstseg, bool b_lastseg,
+			       struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u8 fw_queue = QSLT_BEACON;
+
+	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
+					    skb->data, skb->len,
+					    PCI_DMA_TODEVICE);
+
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
+
+	SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+
+	SET_TX_DESC_TX_RATE(pdesc, DESC92C_RATE1M);
+
+	SET_TX_DESC_SEQ(pdesc, 0);
+
+	SET_TX_DESC_LINIP(pdesc, 0);
+
+	SET_TX_DESC_QUEUE_SEL(pdesc, fw_queue);
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+
+	SET_TX_DESC_RATE_ID(pdesc, 0);
+	SET_TX_DESC_MACID(pdesc, 0);
+
+	SET_TX_DESC_OWN(pdesc, 1);
+
+	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_USE_RATE(pdesc, 1);
+}
+
+void rtl8723be_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
+{
+	if (istx) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			SET_TX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_TX_NEXTDESC_ADDR:
+			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *)val);
+			break;
+		default:
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_RXOWN:
+			SET_RX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_RXBUFF_ADDR:
+			SET_RX_DESC_BUFF_ADDR(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			SET_RX_DESC_PKT_LEN(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXERO:
+			SET_RX_DESC_EOR(pdesc, 1);
+			break;
+		default:
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	}
+}
+
+u32 rtl8723be_get_desc(u8 *pdesc, bool istx, u8 desc_name)
+{
+	u32 ret = 0;
+
+	if (istx) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret = GET_TX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_TXBUFF_ADDR:
+			ret = GET_TX_DESC_TX_BUFFER_ADDRESS(pdesc);
+			break;
+		default:
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret = GET_RX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			ret = GET_RX_DESC_PKT_LEN(pdesc);
+			break;
+		default:
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
+				  desc_name);
+			break;
+		}
+	}
+	return ret;
+}
+
+bool rtl8723be_is_tx_desc_closed(struct ieee80211_hw *hw,
+				 u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
+	u8 own = (u8) rtl8723be_get_desc(entry, true, HW_DESC_OWN);
+
+	/*beacon packet will only use the first
+	 *descriptor by default, and the own may not
+	 *be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	else
+		return true;
+}
+
+void rtl8723be_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	if (hw_queue == BEACON_QUEUE) {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG, BIT(4));
+	} else {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG,
+			       BIT(0) << (hw_queue));
+	}
+}
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
