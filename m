From: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH NEXT] rtlwifi: rtl8192c: rtl8192ce: Add support for
 B-CUT version of RTL8188CE
Date: Wed, 12 Sep 2012 10:37:32 +0200
Message-ID: <20120912103732.787addfd@destiny.ordissimo>
References: <1347393962-7661-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Li Chaoming <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347393962-7661-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2012 15:06:02 -0500, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote :

> Realtek devices with designation RTL8188CE-VL have the so-called B-cut
> of the wireless chip. This patch adds the special programming needed by
> these devices.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>
> Cc: Li Chaoming <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>

Tested-by: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>

Fixes both problems I reported:
 - kernel freezing/lockup when fwlps=1 (default)
 - card not working, then freeze, even if fwlps=0.


> ---
>  drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   21 +++++++
>  drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |    3 +
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   61 ++++++++++++++++++--
>  drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    4 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    6 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
>  6 files changed, 87 insertions(+), 12 deletions(-)
> ---
> 
> John,
> 
> This patch has the patch entitled "rtlwifi: rtl8192ce: Log message that
> B_CUT device may not work" as a pre-requisite. Unlike the previous patch,
> this one is too invasive to backport to the stable kernels, thus it should
> be applied to 3.7.
> 
> Thanks,
> 
> Larry
> ---
> 

[snip]

> diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> index 86d73b3..bae5269 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> @@ -896,7 +896,6 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
>  	struct rtl_phy *rtlphy = &(rtlpriv->phy);
>  	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>  	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
> -	static bool iqk_initialized; /* initialized to false */
>  	bool rtstatus = true;
>  	bool is92c;
>  	int err;
> @@ -921,9 +920,28 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
>  
>  	rtlhal->last_hmeboxnum = 0;
>  	rtl92c_phy_mac_config(hw);
> +	/* because last function modify RCR, so we update
> +	 * rcr var here, or TP will unstable for receive_config
> +	 * is wrong, RX RCR_ACRC32 will cause TP unstabel & Rx
> +	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252*/
> +	rtlpci->receive_config = rtl_read_dword(rtlpriv, REG_RCR);
> +	rtlpci->receive_config &= ~(RCR_ACRC32 | RCR_AICV);
> +	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
>  	rtl92c_phy_bb_config(hw);
>  	rtlphy->rf_mode = RF_OP_BY_SW_3WIRE;
>  	rtl92c_phy_rf_config(hw);
> +	if (IS_VENDOR_UMC_A_CUT(rtlhal->version) &&
> +	    !IS_92C_SERIAL(rtlhal->version)) {
> +		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD, 0x30255);
> +		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G2, MASKDWORD, 0x50a00);
> +	} else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
> +		rtl_set_rfreg(hw, RF90_PATH_A, 0x0C, MASKDWORD, 0x894AE);
> +		rtl_set_rfreg(hw, RF90_PATH_A, 0x0A, MASKDWORD, 0x1AF31);
> +		rtl_set_rfreg(hw, RF90_PATH_A, RF_IPA, MASKDWORD, 0x8F425);
> +		rtl_set_rfreg(hw, RF90_PATH_A, RF_SYN_G2, MASKDWORD, 0x4F200);
> +		rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK1, MASKDWORD, 0x44053);
> +		rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK2, MASKDWORD, 0x80201);
> +	}
>  	rtlphy->rfreg_chnlval[0] = rtl_get_rfreg(hw, (enum radio_path)0,
>  						 RF_CHNLBW, RFREG_OFFSET_MASK);
>  	rtlphy->rfreg_chnlval[1] = rtl_get_rfreg(hw, (enum radio_path)1,
> @@ -945,11 +963,11 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
>  
>  	if (ppsc->rfpwr_state == ERFON) {
>  		rtl92c_phy_set_rfpath_switch(hw, 1);
> -		if (iqk_initialized) {
> +		if (rtlphy->iqk_initialized) {
>  			rtl92c_phy_iq_calibrate(hw, true);
>  		} else {
>  			rtl92c_phy_iq_calibrate(hw, false);
> -			iqk_initialized = true;
> +			rtlphy->iqk_initialized = true;
>  		}
>  
>  		rtl92c_dm_check_txpower_tracking(hw);
> @@ -1004,6 +1022,13 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
>  				   ? CHIP_VENDOR_UMC_B_CUT : CHIP_UNKNOWN) |
>  				   CHIP_VENDOR_UMC));
>  		}
> +		if (IS_92C_SERIAL(version)) {
> +			value32 = rtl_read_dword(rtlpriv, REG_HPON_FSM);
> +			version = (enum version_8192c)(version |
> +				   ((CHIP_BONDING_IDENTIFIER(value32)
> +				   == CHIP_BONDING_92C_1T2R) ?
> +				   RF_TYPE_1T2R : 0));
> +		}
>  	}
>  
>  	switch (version) {
> @@ -1019,12 +1044,30 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
>  	case VERSION_A_CHIP_88C:
>  		versionid = "A_CHIP_88C";
>  		break;
> +	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_A_CUT:
> +		versionid = "A_CUT_92C_1T2R";
> +		break;
> +	case VERSION_NORMAL_UMC_CHIP_92C_A_CUT:
> +		versionid = "A_CUT_92C";
> +		break;
> +	case VERSION_NORMAL_UMC_CHIP_88C_A_CUT:
> +		versionid = "A_CUT_88C";
> +		break;
> +	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_B_CUT:
> +		versionid = "B_CUT_92C_1T2R";
> +		break;
> +	case VERSION_NORMAL_UMC_CHIP_92C_B_CUT:
> +		versionid = "B_CUT_92C";
> +		break;
> +	case VERSION_NORMAL_UMC_CHIP_88C_B_CUT:
> +		versionid = "B_CUT_88C";
> +		break;
>  	default:
>  		versionid = "Unknown. Bug?";
>  		break;
>  	}
>  
> -	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
> +	RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
>  		 "Chip Version ID: %s\n", versionid);
>  
>  	switch (version & 0x3) {
> @@ -1197,6 +1240,7 @@ static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
>  {
>  	struct rtl_priv *rtlpriv = rtl_priv(hw);
>  	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
> +	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
>  	u8 u1b_tmp;
>  	u32 u4b_tmp;
>  
> @@ -1225,7 +1269,8 @@ static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
>  	rtl_write_word(rtlpriv, REG_GPIO_IO_SEL, 0x0790);
>  	rtl_write_word(rtlpriv, REG_LEDCFG0, 0x8080);
>  	rtl_write_byte(rtlpriv, REG_AFE_PLL_CTRL, 0x80);
> -	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
> +	if (!IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
> +		rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
>  	if (rtlpcipriv->bt_coexist.bt_coexistence) {
>  		u4b_tmp = rtl_read_dword(rtlpriv, REG_AFE_XTAL_CTRL);
>  		u4b_tmp |= 0x03824800;
> @@ -1254,6 +1299,9 @@ void rtl92ce_card_disable(struct ieee80211_hw *hw)
>  		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
>  	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
>  	_rtl92ce_poweroff_adapter(hw);
> +
> +	/* after power off we should do iqk again */
> +	rtlpriv->phy.iqk_initialized = false;
>  }
>  
>  void rtl92ce_interrupt_recognized(struct ieee80211_hw *hw,
> @@ -1912,6 +1960,8 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
>  			ratr_bitmap &= 0x0f0ff0ff;
>  		break;
>  	}
> +	sta_entry->ratr_index = ratr_index;
> +
>  	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
>  		 "ratr_bitmap :%x\n", ratr_bitmap);
>  	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
> @@ -2291,3 +2341,4 @@ void rtl92ce_suspend(struct ieee80211_hw *hw)
>  void rtl92ce_resume(struct ieee80211_hw *hw)
>  {
>  }
> +
Whitespace.


Reviewed-by: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>

Regards,

Anisse
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
