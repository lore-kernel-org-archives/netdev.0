From: wu zhangjin <wuzhangjin@gmail.com>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Sun, 27 Mar 2011 06:25:14 +0800
Message-ID: <AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>
	<4D8E5BA3.1090909@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herton Ronaldo Krzesinski <herton@canonical.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Roman Mamedov <rm@romanrm.ru>
To: Hin-Tak Leung <htl10@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:63472 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab1CZWZP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 18:25:15 -0400
In-Reply-To: <4D8E5BA3.1090909@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27, 2011 at 5:33 AM, Hin-Tak Leung
<htl10@users.sourceforge.net> wrote:
> Wu Zhangjin wrote:
>>
>> led can not be turned off normally when rfkill is blocked, the cause=
 is
>> the led_turn_off() function exit as not expected:
>
> Hmm. While this sounds more sensible, is it needed? And what does the
> windows driver do?
>
> I think there are two kind of LEDs - one that comes on and off with t=
he
> rfkill switch; Larry or Herton makes the 2nd one, if there is one, bl=
ink
> while there is traffic (and stay steady on otherwise).

I have used this driver on the YeeLoong netbook(only support Linux),
there is only one LED for rtl8187, when there is traffic, it blinks
perfectly, but If press the hotkey to turn off the rf, the network
interface is down, but the LED is still light, then, the users may
mistakenly think the hotkey or rfkill support doesn't work or simply
think the interface is still on. So, that's why we may need to fix it.

Regards,
Wu Zhangjin

>
>>
>> drivers/net/wireless/rtl818x/rtl8187/leds.c:
>>
>> static void led_turn_off(struct work_struct *work)
>> {
>> =A0 =A0 =A0 =A0[...]
>> =A0 =A0 =A0 =A0/* Don't change the LED, when the device is down. */
>> =A0 =A0 =A0 =A0if (!priv->vif || priv->vif->type =3D=3D NL80211_IFTY=
PE_UNSPECIFIED)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ;
>> =A0 =A0 =A0 =A0[...]
>>
>> When rfkill is blocked, the function calling order looks like this:
>>
>> net/mac80211/iface.c:
>>
>> ieee80211_do_stop
>> =A0 =A0 =A0 =A0-> drv_remove_interface =3D rtl8187_remove_interface
>> =A0 =A0 =A0 =A0-> ieee80211_stop_device
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-> led_set_brightness
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0-> led_turn_off
>> =A0 =A0 =A0 =A0-> drv_stop =3D rtl8187_stop
>>
>> rtl8187_remove_interface() set priv->vif to NULL, so, led_turn_off()
>> will return and will not be able to turn off the led. delay the sett=
ing
>> of priv->vif to rtl8187_stop() can solve it.
>>
>> Signed-off-by: Wu Zhangjin <wuzhangjin@gmail.com>
>> ---
>> =A0drivers/net/wireless/rtl818x/rtl8187/dev.c | =A0 =A08 ++++----
>> =A01 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c
>> b/drivers/net/wireless/rtl818x/rtl8187/dev.c
>> index 2bb5297..1fea0cd 100644
>> --- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
>> +++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
>> @@ -1007,6 +1007,9 @@ static void rtl8187_stop(struct ieee80211_hw *=
dev)
>> =A0 =A0 =A0 =A0u32 reg;
>> =A0 =A0 =A0 =A0mutex_lock(&priv->conf_mutex);
>> +
>> + =A0 =A0 =A0 priv->vif =3D NULL;
>> +
>> =A0 =A0 =A0 =A0rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
>> =A0 =A0 =A0 =A0reg =3D rtl818x_ioread8(priv, &priv->map->CMD);
>> @@ -1067,10 +1070,7 @@ exit:
>> =A0static void rtl8187_remove_interface(struct ieee80211_hw *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct ieee80211_vif *vif)
>> =A0{
>> - =A0 =A0 =A0 struct rtl8187_priv *priv =3D dev->priv;
>> - =A0 =A0 =A0 mutex_lock(&priv->conf_mutex);
>> - =A0 =A0 =A0 priv->vif =3D NULL;
>> - =A0 =A0 =A0 mutex_unlock(&priv->conf_mutex);
>> + =A0 =A0 =A0 /* Nothing to do */
>> =A0}
>> =A0static int rtl8187_config(struct ieee80211_hw *dev, u32 changed)
>
