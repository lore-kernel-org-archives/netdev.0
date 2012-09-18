From: Anisse Astier <anisse@astier.eu>
Subject: Re: [PATCH NEXT V2] rtlwifi: rtl8192c: rtl8192ce: Add support for
 B-CUT version of RTL8188CE
Date: Tue, 18 Sep 2012 16:09:01 +0200
Message-ID: <20120918160901.22cf2261@destiny.ordissimo>
References: <1347914143-27698-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Li Chaoming <chaoming_li@realsil.com.cn>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35531 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933152Ab2IROJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:09:20 -0400
Received: by eaac11 with SMTP id c11so2857100eaa.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 07:09:19 -0700 (PDT)
In-Reply-To: <1347914143-27698-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Sep 2012 15:35:43 -0500, Larry Finger <Larry.Finger@lwfinger.net> wrote :

> Realtek devices with designation RTL8188CE-VL have the so-called B-cut
> of the wireless chip. This patch adds the special programming needed by
> these devices.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Anisse Astier <anisse@astier.eu>
> Cc: Li Chaoming <chaoming_li@realsil.com.cn>
> ---
>  drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   21 +++++++
>  drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |    3 +
>  drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   61 ++++++++++++++++++--
>  drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    4 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    6 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
>  6 files changed, 87 insertions(+), 12 deletions(-)
> ---
> V1 => V2	Remove extraneous white space.
> 
> 
> John,
> 
> This patch is too invasive to backport to the stable kernels, thus it should
> be applied to 3.7.
> 
> Thanks,
> 
> Larry
> ---
> 

[snip]

> Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> ===================================================================
> --- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> +++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> @@ -896,7 +896,6 @@ int rtl92ce_hw_init(struct ieee80211_hw
>  	struct rtl_phy *rtlphy = &(rtlpriv->phy);
>  	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>  	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
> -	static bool iqk_initialized; /* initialized to false */
>  	bool rtstatus = true;
>  	bool is92c;
>  	int err;
> @@ -921,9 +920,28 @@ int rtl92ce_hw_init(struct ieee80211_hw
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
> @@ -945,11 +963,11 @@ int rtl92ce_hw_init(struct ieee80211_hw
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
> @@ -1004,6 +1022,13 @@ static enum version_8192c _rtl92ce_read_
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
> @@ -1019,12 +1044,30 @@ static enum version_8192c _rtl92ce_read_
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
> @@ -1197,6 +1240,7 @@ static void _rtl92ce_poweroff_adapter(st
>  {
>  	struct rtl_priv *rtlpriv = rtl_priv(hw);
>  	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
> +	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
>  	u8 u1b_tmp;
>  	u32 u4b_tmp;
>  
> @@ -1225,7 +1269,8 @@ static void _rtl92ce_poweroff_adapter(st
>  	rtl_write_word(rtlpriv, REG_GPIO_IO_SEL, 0x0790);
>  	rtl_write_word(rtlpriv, REG_LEDCFG0, 0x8080);
>  	rtl_write_byte(rtlpriv, REG_AFE_PLL_CTRL, 0x80);
> -	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
> +	if (!IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
> +		rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
>  	if (rtlpcipriv->bt_coexist.bt_coexistence) {
>  		u4b_tmp = rtl_read_dword(rtlpriv, REG_AFE_XTAL_CTRL);
>  		u4b_tmp |= 0x03824800;
> @@ -1254,6 +1299,9 @@ void rtl92ce_card_disable(struct ieee802
>  		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
>  	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
>  	_rtl92ce_poweroff_adapter(hw);
> +
> +	/* after power off we should do iqk again */
> +	rtlpriv->phy.iqk_initialized = false;
>  }
>  
>  void rtl92ce_interrupt_recognized(struct ieee80211_hw *hw,

This part:
> @@ -1355,9 +1403,9 @@ static void _rtl92ce_read_txpower_info_f
>  			tempval = hwinfo[EEPROM_TXPOWERHT40_2SDIFF + i];
>  		else
>  			tempval = EEPROM_DEFAULT_HT40_2SDIFF;
> -		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_A][i] =
> +		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_A][i] =
>  		    (tempval & 0xf);
> -		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_B][i] =
> +		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_B][i] =
>  		    ((tempval & 0xf0) >> 4);
>  	}
>  
> @@ -1381,7 +1429,7 @@ static void _rtl92ce_read_txpower_info_f
>  				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
>  				rf_path, i,
>  				rtlefuse->
> -				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
> +				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
>  
>  	for (rf_path = 0; rf_path < 2; rf_path++) {
>  		for (i = 0; i < 14; i++) {
> @@ -1396,14 +1444,14 @@ static void _rtl92ce_read_txpower_info_f
>  			if ((rtlefuse->
>  			     eeprom_chnlarea_txpwr_ht40_1s[rf_path][index] -
>  			     rtlefuse->
> -			     eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][index])
> +			     eprom_chnl_txpwr_ht40_2sdf[rf_path][index])
>  			    > 0) {
>  				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
>  				    rtlefuse->
>  				    eeprom_chnlarea_txpwr_ht40_1s[rf_path]
>  				    [index] -
>  				    rtlefuse->
> -				    eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
> +				    eprom_chnl_txpwr_ht40_2sdf[rf_path]
>  				    [index];
>  			} else {
>  				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;

wasn't in V1 of the patch. Is the rename normal?


Anisse
