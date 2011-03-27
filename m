From: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: Re: [RFC PATCH] rtl8187: Fix led support for rfkill
Date: Sun, 27 Mar 2011 00:55:59 +0000
Message-ID: <4D8E8B1E.3030709@users.sourceforge.net>
References: <1301174394-12642-1-git-send-email-wuzhangjin@gmail.com>	<4D8E5BA3.1090909@users.sourceforge.net> <AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roman Mamedov <rm-pzoh41kZ4TQvJsYlp49lxw@public.gmane.org>
To: wu zhangjin <wuzhangjin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTind3Va9J_tvZBDAPfbuyQtgxoAE+ZzG6VpU1b1q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

wu zhangjin wrote:
> On Sun, Mar 27, 2011 at 5:33 AM, Hin-Tak Leung
> <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> wrote:
>> Wu Zhangjin wrote:
>>> led can not be turned off normally when rfkill is blocked, the cause is
>>> the led_turn_off() function exit as not expected:
>> Hmm. While this sounds more sensible, is it needed? And what does the
>> windows driver do?
>>
>> I think there are two kind of LEDs - one that comes on and off with the
>> rfkill switch; Larry or Herton makes the 2nd one, if there is one, blink
>> while there is traffic (and stay steady on otherwise).
> 
> I have used this driver on the YeeLoong netbook(only support Linux),
> there is only one LED for rtl8187, when there is traffic, it blinks
> perfectly, but If press the hotkey to turn off the rf, the network
> interface is down, but the LED is still light, then, the users may
> mistakenly think the hotkey or rfkill support doesn't work or simply
> think the interface is still on. So, that's why we may need to fix it.

My laptop (a Toshiba one) has the other kind of LED - the LED only comes on and 
off in relation to the rfkill switch, and does not blink with traffic. I think 
Herton or Larry has some devices with both types.

Hmm, I seem to have the impression that there is code somewhere for switching a 
singular LED's behavior of the driver between one or the other, by echo'ing into 
sysfs or some other trickery? Or would that be a desired approach if that's not 
done at the moment?

> 
> Regards,
> Wu Zhangjin
> 
>>> drivers/net/wireless/rtl818x/rtl8187/leds.c:
>>>
>>> static void led_turn_off(struct work_struct *work)
>>> {
>>>        [...]
>>>        /* Don't change the LED, when the device is down. */
>>>        if (!priv->vif || priv->vif->type == NL80211_IFTYPE_UNSPECIFIED)
>>>                return ;
>>>        [...]
>>>
>>> When rfkill is blocked, the function calling order looks like this:
>>>
>>> net/mac80211/iface.c:
>>>
>>> ieee80211_do_stop
>>>        -> drv_remove_interface = rtl8187_remove_interface
>>>        -> ieee80211_stop_device
>>>                -> led_set_brightness
>>>                        -> led_turn_off
>>>        -> drv_stop = rtl8187_stop
>>>
>>> rtl8187_remove_interface() set priv->vif to NULL, so, led_turn_off()
>>> will return and will not be able to turn off the led. delay the setting
>>> of priv->vif to rtl8187_stop() can solve it.
>>>
>>> Signed-off-by: Wu Zhangjin <wuzhangjin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>>  drivers/net/wireless/rtl818x/rtl8187/dev.c |    8 ++++----
>>>  1 files changed, 4 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c
>>> b/drivers/net/wireless/rtl818x/rtl8187/dev.c
>>> index 2bb5297..1fea0cd 100644
>>> --- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
>>> +++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
>>> @@ -1007,6 +1007,9 @@ static void rtl8187_stop(struct ieee80211_hw *dev)
>>>        u32 reg;
>>>        mutex_lock(&priv->conf_mutex);
>>> +
>>> +       priv->vif = NULL;
>>> +
>>>        rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0);
>>>        reg = rtl818x_ioread8(priv, &priv->map->CMD);
>>> @@ -1067,10 +1070,7 @@ exit:
>>>  static void rtl8187_remove_interface(struct ieee80211_hw *dev,
>>>                                     struct ieee80211_vif *vif)
>>>  {
>>> -       struct rtl8187_priv *priv = dev->priv;
>>> -       mutex_lock(&priv->conf_mutex);
>>> -       priv->vif = NULL;
>>> -       mutex_unlock(&priv->conf_mutex);
>>> +       /* Nothing to do */
>>>  }
>>>  static int rtl8187_config(struct ieee80211_hw *dev, u32 changed)
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
