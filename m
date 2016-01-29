From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates
 [mac80211]
Date: Thu, 28 Jan 2016 19:54:52 -0600
Message-ID: <56AAC66C.1080800@lwfinger.net>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
 <1453983185.2217.12.camel@sipsolutions.net>
 <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
 <1454013625.2332.9.camel@sipsolutions.net>
 <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
 <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
 <1454019155.2332.15.camel@sipsolutions.net>
 <CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040006070602000907080807"
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:36016 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbcA2By4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 20:54:56 -0500
In-Reply-To: <CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040006070602000907080807
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 01/28/2016 05:01 PM, Linus Torvalds wrote:
> On Thu, Jan 28, 2016 at 2:12 PM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
>>
>> Your best workaround may just be to ignore VHT for now - clearly it's
>> broken so using "just" HT (which is likely not that much of a penalty
>> anyway since you're apparently not using 80 MHz) will be much better.
>>
>> Go into
>>
>> _rtl_init_hw_vht_capab()
>>
>> and just remove or stub out the entire contents of that (or you could
>> just remove the "vht_supported=true" if you feel like it.)
>>
>> That should get it to HT only, which is likely tested and working
>> better.
>
> Bingo. That indeed gets me working wireless. It's not super-fast, but
> I don't think it ever has been..
>
> If somebody has a suggested patch to actually *fix* VHT on this
> chipset, that would obviously be better. And maybe it works on some
> other chipsets, but not on mine. I'll happily test patches now that
> the merge window is over and I have some time again (and I can also
> make my AP do 80MHz channels if that matters, although as Johannes
> noted it's not enabled by default).
>
> For the realtek driver people, here is what lspci says:
>
> 02:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8821AE
> 802.11ac PCIe Wireless Network Adapter
>      Subsystem: AzureWave Device 2161
>      Kernel driver in use: rtl8821ae
>
> (Numeric PCI ID: 10ec:8821, subsystem 1a3b:2161)
>
> Thanks,

Linus,

I have been running an RTL8821AE since kernel 3.18 without hitting this problem 
using a TRENDnet AC1750 dual-band AP. The UniFi may be doing something that the 
driver is not expecting.

There have also been some problems with the regdom in some models of these chips 
that I also fail to see. It appears that some vendors are not coding the EEPROM 
correctly. That should not affect your system.

Attached is a minimal patch that comments out the "vht_cap->vht_supported = 
true;" statement for both RTL8821AE and RTL8812AE in _rtl_init_hw_vht_capab(). 
Does that allow your system to work? The patch also logs some information 
regarding the channelplan and the country code. Please let me know the values 
for those.

I apparently missed a previous complaint about this issue. If you still have the 
reference, please send it to me.

Larry



--------------040006070602000907080807
Content-Type: text/x-patch;
 name="rtl8821ae_test.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rtl8821ae_test.patch"

diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index 0517a4f..2464d41 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -248,7 +248,7 @@ static void _rtl_init_hw_vht_capab(struct ieee80211_hw *hw,
 	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
 		u16 mcs_map;
 
-		vht_cap->vht_supported = true;
+		/* vht_cap->vht_supported = true; */
 		vht_cap->cap =
 			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_3895 |
 			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_7991 |
@@ -282,7 +282,7 @@ static void _rtl_init_hw_vht_capab(struct ieee80211_hw *hw,
 	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
 		u16 mcs_map;
 
-		vht_cap->vht_supported = true;
+		/* vht_cap->vht_supported = true; */
 		vht_cap->cap =
 			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_3895 |
 			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_7991 |
diff --git a/drivers/net/wireless/realtek/rtlwifi/regd.c b/drivers/net/wireless/realtek/rtlwifi/regd.c
index 5be3411..38f464e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/regd.c
+++ b/drivers/net/wireless/realtek/rtlwifi/regd.c
@@ -340,6 +340,7 @@ static int _rtl_reg_notifier_apply(struct wiphy *wiphy,
 static const struct ieee80211_regdomain *_rtl_regdomain_select(
 						struct rtl_regulatory *reg)
 {
+	pr_info("**** country code %d\n", reg->country_code);
 	switch (reg->country_code) {
 	case COUNTRY_CODE_FCC:
 		return &rtl_regdom_no_midband;
@@ -400,6 +401,7 @@ static struct country_code_to_enum_rd *_rtl_regd_find_country(u16 countrycode)
 
 static u8 channel_plan_to_country_code(u8 channelplan)
 {
+	pr_info("**** channelplan %d\n", channelplan);
 	switch (channelplan) {
 	case 0x20:
 	case 0x21:


--------------040006070602000907080807--
