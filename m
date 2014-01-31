From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] rtl8192ce is disabling for too long the irqs
Date: Fri, 31 Jan 2014 00:39:36 -0600
Message-ID: <52EB4528.3040609@lwfinger.net>
References: <1391145383-18652-1-git-send-email-olivier@trillion01.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Olivier Langlois <olivier@trillion01.com>, linville@tuxdriver.com,
	chaoming_li@realsil.com.cn
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391145383-18652-1-git-send-email-olivier@trillion01.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2014 11:16 PM, Olivier Langlois wrote:
> rtl8192ce is disabling for too long the local interrupts during hw initiatialisation when performing scans
>
> The observable symptoms in dmesg can be:
>
> - underruns from ALSA playback
> - clock freezes (tstamps do not change for several dmesg entries until irqs are finaly reenabled):
>
> [  250.817669] rtlwifi:rtl_op_config():<0-0-0> 0x100
> [  250.817685] rtl8192ce:_rtl92ce_phy_set_rf_power_state():<0-1-0> IPS Set eRf nic enable
> [  250.817732] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.817796] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.817910] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818024] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818139] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818253] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818367] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:18051d59:11
> [  250.818472] rtl8192ce:_rtl92ce_init_mac():<0-1-0> reg0xec:98053f15:10
> [  250.818472] rtl8192ce:rtl92ce_sw_led_on():<0-1-0> LedAddr:4E ledpin=1
> [  250.818472] rtl8192c_common:rtl92c_download_fw():<0-1-0> Firmware Version(49), Signature(0x88c1),Size(32)
> [  250.818472] rtl8192ce:rtl92ce_enable_hw_security_config():<0-1-0> PairwiseEncAlgorithm = 0 GroupEncAlgorithm = 0
> [  250.818472] rtl8192ce:rtl92ce_enable_hw_security_config():<0-1-0> The SECR-value cc
> [  250.818472] rtl8192c_common:rtl92c_dm_check_txpower_tracking_thermal_meter():<0-1-0> Schedule TxPowerTracking direct call!!
> [  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> rtl92c_dm_txpower_tracking_callback_thermalmeter
> [  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Readback Thermal Meter = 0xe pre thermal meter 0xf eeprom_thermalmeter 0xf
> [  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Initial pathA ele_d reg0xc80 = 0x40000000, ofdm_index=0xc
> [  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Initial reg0xa24 = 0x90e1317, cck_index=0xc, ch14 0
> [  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> Readback Thermal Meter = 0xe pre thermal meter 0xf eeprom_thermalmeter 0xf delta 0x1 delta_lck 0x0 delta_iqk 0x0
> [  250.818472] rtl8192c_common:rtl92c_dm_txpower_tracking_callback_thermalmeter():<0-1-0> <===
> [  250.818472] rtl8192c_common:rtl92c_dm_initialize_txpower_tracking_thermalmeter():<0-1-0> pMgntInfo->txpower_tracking = 1
> [  250.818472] rtl8192ce:rtl92ce_led_control():<0-1-0> ledaction 3
> [  250.818472] rtl8192ce:rtl92ce_sw_led_on():<0-1-0> LedAddr:4E ledpin=1
> [  250.818472] rtlwifi:rtl_ips_nic_on():<0-1-0> before spin_unlock_irqrestore
> [  251.154656] PCM: Lost interrupts? [Q]-0 (stream=0, delta=15903, new_hw_ptr=293408, old_hw_ptr=277505)
>
> The exact code flow that causes that is:
>
> 1. wpa_supplicant send a start_scan request to the nl80211 driver
> 2. mac80211 module call rtl_op_config with IEEE80211_CONF_CHANGE_IDLE
> 3.   rtl_ips_nic_on is called which disable local irqs
> 4.     rtl92c_phy_set_rf_power_state() is called
> 5.       rtl_ps_enable_nic() is called and hw_init()is executed and then the interrupts on the device are enabled
>
> A good solution could be to refactor the code to avoid calling rtl92ce_hw_init() with the irqs disabled
> but a quick and dirty solution that has proven to work is
> to reenable the irqs during the function rtl92ce_hw_init().
>
> I think that it is safe doing so since the device interrupt will only be enabled after the init function succeed.
>
> Signed-off-by: Olivier Langlois <olivier@trillion01.com>

Sorry, I missed that your subject was a little wrong. This E-mail should have 
the title of "[PATCH 1/2] rtlwifi: rtl8192ce: Fix too long disable of IRQs". 
This way the entity that is being patched is identified in the subject in the 
git commit message. Using "fix" helps in getting it incorporated immediately. 
For the second patch, I recommend "[PATCH 2/2] rtlwifi: Fix incorrect return 
from rtl_ps_enable_nic()".

The reason GregKH sent you the message is due to a misunderstanding of the 
business about Cc to stable. Do not send the E-mail to that mailing list but 
include a line that says "Cc: Stable <stable@vger.stable.org>" immediately after 
your "Signed-off-by:" line in the body of the E-mail. When the patch gets added 
to Linus' tree, that will trigger its inclusion in the stable kernels.

Larry
