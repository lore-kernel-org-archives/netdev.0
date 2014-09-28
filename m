From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 9/11 V2 NEXT] rtlwifi: rtl8188ee: Update driver to match
 Realtek release of 06282014
Date: Sun, 28 Sep 2014 17:40:52 -0500
Message-ID: <54288E74.1080107@lwfinger.net>
References: <1411836726-12699-1-git-send-email-Larry.Finger@lwfinger.net> <1411836726-12699-2-git-send-email-Larry.Finger@lwfinger.net> <20140927194939.GA28553@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	troy_tan@realsil.com.cn, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:34918 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaI1Wky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 18:40:54 -0400
In-Reply-To: <20140927194939.GA28553@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2014 02:49 PM, Francois Romieu wrote:
>
> Larry Finger <Larry.Finger@lwfinger.net> :
> [...]
>> diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
>> index 40738e3..d30f416 100644
>> --- a/drivers/net/wireless/rtlwifi/core.c
>> +++ b/drivers/net/wireless/rtlwifi/core.c
>> @@ -28,6 +28,7 @@
>>   #include "cam.h"
>>   #include "base.h"
>>   #include "ps.h"
>> +#include "pwrseqcmd.h"
>>
>>   #include "btcoexist/rtl_btc.h"
>>   #include <linux/firmware.h>
>> @@ -1700,3 +1701,100 @@ const struct ieee80211_ops rtl_ops = {
>>   };
>>   EXPORT_SYMBOL_GPL(rtl_ops);
>>
>> +/*	Description:
>> + *		This routine deals with the Power Configuration CMD
>> + *		 parsing for RTL8723/RTL8188E Series IC.
>> + *	Assumption:
>> + *		We should follow specific format that was released from HW SD.
>
> "released" is a bit misleading if it does not mean "publicly released".
>
>> + */
>> +bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
>> +			      u8 faversion, u8 interface_type,
>> +			      struct wlan_pwr_cfg pwrcfgcmd[])
>> +{
>> +	struct wlan_pwr_cfg cfg_cmd = {0};
>> +	bool polling_bit = false;
>> +	u32 ary_idx = 0;
>
> 	u32 i;
>
>> +	u8 value = 0;
>> +	u32 offset = 0;
>
> Useless init.
>
>> +	u32 polling_count = 0;
>
> Wrong scope.
>
>> +	u32 max_polling_cnt = 5000;
>
> Inverted xmas tree for declaration.

I do not understand what you mean here.

>
>> +
>> +	do {
>
> 	while (1) {
>
>> +		cfg_cmd = pwrcfgcmd[ary_idx];
>> +		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>> +			 "rtl_hal_pwrseqcmdparsing(): offset(%#x),cut_msk(%#x), famsk(%#x), interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
>                                                                  ^^^ missing space
>
>> +			 GET_PWR_CFG_OFFSET(cfg_cmd),
>> +					    GET_PWR_CFG_CUT_MASK(cfg_cmd),
>> +			 GET_PWR_CFG_FAB_MASK(cfg_cmd),
>> +					      GET_PWR_CFG_INTF_MASK(cfg_cmd),
>> +			 GET_PWR_CFG_BASE(cfg_cmd), GET_PWR_CFG_CMD(cfg_cmd),
>> +			 GET_PWR_CFG_MASK(cfg_cmd), GET_PWR_CFG_VALUE(cfg_cmd));
>> +
>> +		if ((GET_PWR_CFG_FAB_MASK(cfg_cmd)&faversion) &&
>> +		    (GET_PWR_CFG_CUT_MASK(cfg_cmd)&cut_version) &&
>                                                   ^^^ missing spaces
>
>> +		    (GET_PWR_CFG_INTF_MASK(cfg_cmd)&interface_type)) {
>> +			switch (GET_PWR_CFG_CMD(cfg_cmd)) {
>> +			case PWR_CMD_READ:
>> +				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>> +					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
>
> It should line up after the parenthesis.
>
>> +				break;
>> +			case PWR_CMD_WRITE:
>> +				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>> +					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
>> +				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
>> +
>> +				/*Read the value from system register*/
>> +				value = rtl_read_byte(rtlpriv, offset);
>> +				value &= (~(GET_PWR_CFG_MASK(cfg_cmd)));
>
> Excess parenthsis.
>
>> +				value |= (GET_PWR_CFG_VALUE(cfg_cmd) &
>> +					  GET_PWR_CFG_MASK(cfg_cmd));
>
> Excess parenthsis.
>
>> +
>> +				/*Write the value back to sytem register*/
>> +				rtl_write_byte(rtlpriv, offset, value);
>> +				break;
>> +			case PWR_CMD_POLLING:
>> +				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
>> +					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
>
> It should line up after the parenthesis.
>
>> +				polling_bit = false;
>> +				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
>> +
>> +				do {
>> +					value = rtl_read_byte(rtlpriv, offset);
>> +
>> +					value &= GET_PWR_CFG_MASK(cfg_cmd);
>> +					if (value ==
>> +					    (GET_PWR_CFG_VALUE(cfg_cmd) &
>> +					     GET_PWR_CFG_MASK(cfg_cmd)))
>> +						polling_bit = true;
>> +					else
>> +						udelay(10);
>> +
>> +					if (polling_count++ > max_polling_cnt)
>> +						return false;
>> +				} while (!polling_bit);
>
> Simple "for" loop in disguise.
>
> An helper function may help.
>
> Imnsho the whole do { more, more, more } while (1) concept is broken.
>
> [...]
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/def.h b/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
>> index c764fff..d9ea9d0 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
>> +++ b/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
> [...]
>> @@ -225,44 +218,37 @@ enum power_polocy_config {
>>   };
>>
>>   enum interface_select_pci {
>> -	INTF_SEL1_MINICARD,
>> -	INTF_SEL0_PCIE,
>> -	INTF_SEL2_RSV,
>> -	INTF_SEL3_RSV,
>> +	INTF_SEL1_MINICARD = 0,
>> +	INTF_SEL0_PCIE = 1,
>> +	INTF_SEL2_RSV = 2,
>> +	INTF_SEL3_RSV = 3,
>
> Please use tabs to line things up.
>
> [...]
>> +	HAL_FW_C2H_CMD_READ_MACREG = 0,
>> +	HAL_FW_C2H_CMD_READ_BBREG = 1,
>> +	HAL_FW_C2H_CMD_READ_RFREG = 2,
>> +	HAL_FW_C2H_CMD_READ_EEPROM = 3,
>> +	HAL_FW_C2H_CMD_READ_EFUSE = 4,
>
> See above.
>
> [...]
>> diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
>> index f8daa61..2aa34d9 100644
>> --- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
>> +++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
> [...]
>> -			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBAL, MASKDWORD,
>> -				      value32);
>> +			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
>> +				      MASKDWORD, value32);
>
> It lacks of consistency, see the *NICE* marker below.
>
>>   			value32 = (ele_c & 0x000003C0) >> 6;
>> -			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS, value32);
>> +			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS,
>> +				      value32);
>
> ?
>
>>   			value32 = ((iqk_result_x * ele_d) >> 7) & 0x01;
>> -			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(24), value32);
>> +			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(24),
>> +				      value32);
>>   			break;
>>   		case RF90_PATH_B:
>>   			value32 = (ele_d << 22)|((ele_c & 0x3F)<<16) | ele_a;
>> -			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBAL,
>> -				      MASKDWORD, value32);
>> +			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE, MASKDWORD,
>> +				      value32);
>
> *NICE*
>
> [...]
>> @@ -210,16 +209,20 @@ static void rtl88e_set_iqk_matrix(struct ieee80211_hw *hw,
>>   	} else {
>>   		switch (rfpath) {
>>   		case RF90_PATH_A:
>> -			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBAL, MASKDWORD,
>> -				      ofdmswing_table[ofdm_index]);
>> -			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS, 0x00);
>> -			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(24), 0x00);
>> +			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
>> +				      MASKDWORD, ofdmswing_table[ofdm_index]);
>> +			rtl_set_bbreg(hw, ROFDM0_XCTXAFE,
>> +				      MASKH4BITS, 0x00);
>
> 			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS, 0x00);
>
>> +			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD,
>> +				      BIT(24), 0x00);
>
> 			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(24), 0x00);
>
>>   			break;
>>   		case RF90_PATH_B:
>> -			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBAL, MASKDWORD,
>> -				      ofdmswing_table[ofdm_index]);
>> -			rtl_set_bbreg(hw, ROFDM0_XDTXAFE, MASKH4BITS, 0x00);
>> -			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(28), 0x00);
>> +			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE,
>> +				      MASKDWORD, ofdmswing_table[ofdm_index]);
>> +			rtl_set_bbreg(hw, ROFDM0_XDTXAFE,
>> +				      MASKH4BITS, 0x00);
>
> 			rtl_set_bbreg(hw, ROFDM0_XDTXAFE, MASKH4BITS, 0x00);
>
>> +			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD,
>> +				      BIT(28), 0x00);
>
> 			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(28), 0x00);
>
> [...]
>> @@ -263,46 +266,75 @@ void rtl88e_dm_txpower_track_adjust(struct ieee80211_hw *hw,
>>   			 (pwr_val << 24);
>>   }
>>
>> -
>> -static void rtl88e_chk_tx_track(struct ieee80211_hw *hw,
>> -				enum pwr_track_control_method method,
>> -				u8 rfpath, u8 index)
>> +static void dm_tx_pwr_track_set_pwr(struct ieee80211_hw *hw,
>> +				    enum pwr_track_control_method method,
>> +				    u8 rfpath, u8 channel_mapped_index)
>>   {
>>   	struct rtl_priv *rtlpriv = rtl_priv(hw);
>> -	struct rtl_phy *rtlphy = &(rtlpriv->phy);
>> +	struct rtl_phy *rtlphy = &rtlpriv->phy;
>>   	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
>> -	int jj = rtldm->swing_idx_cck;
>> -	int i;
>>
>>   	if (method == TXAGC) {
>> -		if (rtldm->swing_flag_ofdm == true ||
>> -		    rtldm->swing_flag_cck == true) {
>> -			u8 chan = rtlphy->current_channel;
>> -			rtl88e_phy_set_txpower_level(hw, chan);
>> +		if (rtldm->swing_flag_ofdm ||
>> +		    rtldm->swing_flag_cck) {
>
> Single line.
>
>> +			rtl88e_phy_set_txpower_level(hw,
>> +						     rtlphy->current_channel);
>>   			rtldm->swing_flag_ofdm = false;
>>   			rtldm->swing_flag_cck = false;
>>   		}
>>   	} else if (method == BBSWING) {
>>   		if (!rtldm->cck_inch14) {
>> -			for (i = 0; i < 8; i++)
>> -				rtl_write_byte(rtlpriv, 0xa22 + i,
>> -					       cck_tbl_ch1_13[jj][i]);
>> +			rtl_write_byte(rtlpriv, 0xa22,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][0]);
>> +			rtl_write_byte(rtlpriv, 0xa23,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][1]);
>> +			rtl_write_byte(rtlpriv, 0xa24,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][2]);
>> +			rtl_write_byte(rtlpriv, 0xa25,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][3]);
>> +			rtl_write_byte(rtlpriv, 0xa26,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][4]);
>> +			rtl_write_byte(rtlpriv, 0xa27,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][5]);
>> +			rtl_write_byte(rtlpriv, 0xa28,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][6]);
>> +			rtl_write_byte(rtlpriv, 0xa29,
>> +				       cck_tbl_ch1_13[rtldm->swing_idx_cck][7]);
>
> ?
>
> I hope someone got the "-R" flag of patch wrong.
>
>>   		} else {
>> -			for (i = 0; i < 8; i++)
>> -				rtl_write_byte(rtlpriv, 0xa22 + i,
>> -					       cck_tbl_ch14[jj][i]);
>> +			rtl_write_byte(rtlpriv, 0xa22,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][0]);
>> +			rtl_write_byte(rtlpriv, 0xa23,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][1]);
>> +			rtl_write_byte(rtlpriv, 0xa24,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][2]);
>> +			rtl_write_byte(rtlpriv, 0xa25,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][3]);
>> +			rtl_write_byte(rtlpriv, 0xa26,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][4]);
>> +			rtl_write_byte(rtlpriv, 0xa27,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][5]);
>> +			rtl_write_byte(rtlpriv, 0xa28,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][6]);
>> +			rtl_write_byte(rtlpriv, 0xa29,
>> +				       cck_tbl_ch14[rtldm->swing_idx_cck][7]);
>
> Sic.
>
>>   		}
>>
>>   		if (rfpath == RF90_PATH_A) {
>> -			long x = rtlphy->iqk_matrix[index].value[0][0];
>> -			long y = rtlphy->iqk_matrix[index].value[0][1];
>> -			u8 indx = rtldm->swing_idx_ofdm[rfpath];
>> -			rtl88e_set_iqk_matrix(hw, indx, rfpath, x, y);
>> +			rtl88e_set_iqk_matrix(hw, rtldm->swing_idx_ofdm[rfpath],
>> +					      rfpath, rtlphy->iqk_matrix
>> +					      [channel_mapped_index].
>> +					      value[0][0],
>> +					      rtlphy->iqk_matrix
>> +					      [channel_mapped_index].
>> +					      value[0][1]);
>>   		} else if (rfpath == RF90_PATH_B) {
>> -			u8 indx = rtldm->swing_idx_ofdm[rfpath];
>> -			long x = rtlphy->iqk_matrix[indx].value[0][4];
>> -			long y = rtlphy->iqk_matrix[indx].value[0][5];
>> -			rtl88e_set_iqk_matrix(hw, indx, rfpath, x, y);
>> +			rtl88e_set_iqk_matrix(hw, rtldm->swing_idx_ofdm[rfpath],
>> +					      rfpath, rtlphy->iqk_matrix
>> +					      [channel_mapped_index].
>> +					      value[0][4],
>> +					      rtlphy->iqk_matrix
>> +					      [channel_mapped_index].
>> +					      value[0][5]);
>
> :o(
>
> I stop here. I don't enjoy playing the bad cop and this patch is feeding crap
> into the kernel.

Thanks for the review.

As I explained in V1 of these patches, I am trying to merge the kernel and 
Realtek internal code repositories in the hope that Realtek will keep the two of 
them in sync. In addition, I am hoping that they will take over maintaining 
these codes in the future.

If I insist on an absolute minimum of change in the kernel code, then the churn 
of the Realtek repo is increased, and I run the risk of failing in the process 
of merging the two repos. In my estimation, that would be a bigger disaster than 
getting some code into the kernel that is not as pretty as could be. In 
addition, I am not sure how much longer I want to volunteer full time to support 
these codes.

Larry
