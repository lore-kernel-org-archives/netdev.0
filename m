From: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Subject: Re: Possible wireless issue introduced in next-20140930
Date: Thu, 23 Oct 2014 13:26:22 -0200
Message-ID: <54491E1E.6090001@gmail.com>
References: <54487346.4080604@gmail.com> <1414041815.5228.37.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414041815.5228.37.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/2014 03:23 AM, Mike Galbraith wrote:
> On Thu, 2014-10-23 at 01:17 -0200, Murilo Opsfelder Araujo wrote:
>> Hello, everyone.
>>
>> With next-20140930 my laptop does not work, i.e. after I enter my login
>> and password in KDM, the entire system becomes unresponsive and I need
>> to reset it in order to reboot (it does not even show the KDE splash
>> screen).
>>
>> It was working pretty fine with next-20140926.
>>
>> I've also tested with next-20141022 and v3.18-rc1 and no luck.
>>
>> git bisect pointed me to the commit below [1].  My wireless card is a
>> RTL8191SEvA [2].
>
> Mine is RTL8191SEvB.
>
> I was going to bisect RTL8191SE regression when I got a chance, but you
> beat me to it.
>
>> commit 38506ecefab911785d5e1aa5889f6eeb462e0954
>> Author: Larry Finger <Larry.Finger@lwfinger.net>
>> Date:   Mon Sep 22 09:39:19 2014 -0500
>>
>>       rtlwifi: rtl_pci: Start modification for new drivers
>
> Did you confirm that bisection result, ie revert it at HEAD of whichever
> tree you bisected?
>
> The revert (master) removed some warnings on the way to kaboom here, but
> the drivers is still toxic.  My log follows in case it's the same thing.
> I can't go hunting atm, maybe during the weekend if the problem hasn't
> evaporate by then.

next-20141023 does not work as well.

With commit 38506ecefab911785d5e1aa5889f6eeb462e0954 reverted, kernel 
blows up very early in boot.

Cascardo (CC:) helped me to investigate and it seems that when 
rtlpriv->cfg->ops->get_btc_status() is called, it is pointing to a NULL 
function.

With the changes below, written by Cascardo, I could get rid of 
oops/panic and system booted normally.  But there was no wifi network 
available (like if wifi card was disabled).

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c 
b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 1bff2a0..807f0f7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -253,6 +253,11 @@ static void rtl92s_deinit_sw_vars(struct 
ieee80211_hw *hw)
         }
  }

+static bool rtl92s_get_btc_status(void)
+{
+       return false;
+}
+
  static struct rtl_hal_ops rtl8192se_hal_ops = {
         .init_sw_vars = rtl92s_init_sw_vars,
         .deinit_sw_vars = rtl92s_deinit_sw_vars,
@@ -294,6 +299,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops = {
         .set_bbreg = rtl92s_phy_set_bb_reg,
         .get_rfreg = rtl92s_phy_query_rf_reg,
         .set_rfreg = rtl92s_phy_set_rf_reg,
+       .get_btc_status = rtl92s_get_btc_status,
  };

  static struct rtl_mod_params rtl92se_mod_params = {

-- 
Murilo
