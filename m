From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/2] drivers: net: phy: at803x: LED control via led subsystem
Date: Fri, 12 Jul 2013 08:19:03 +0100
Message-ID: <CAGVrzcZn+dAzWV9ObyfLn5cyE0D7rXgUkmdKOZ8rE0q1r4J3Hg@mail.gmail.com>
References: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
 <1373543855-31670-2-git-send-email-helmut.schaa@googlemail.com>
 <CAGVrzcbxuogp9umQVEFOfzg64Nb6UWZjHs_5M=bdHceRSFRE4g@mail.gmail.com> <CAGXE3d8WRU2fmRZ9DAQ4_Y=WZQwNmt9DVbLys=LkJaRPz=7FAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:64383 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757149Ab3GLHTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 03:19:44 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp12so8678860pab.35
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 00:19:43 -0700 (PDT)
In-Reply-To: <CAGXE3d8WRU2fmRZ9DAQ4_Y=WZQwNmt9DVbLys=LkJaRPz=7FAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/7/11 Helmut Schaa <helmut.schaa@googlemail.com>:
>>
>> I do like this and I believe that there is nothing specific that would
>> prevent you from making software controllable LEDs from being used
>> with other PHYs. How about you create a small LED class helper that
>> PHY drivers supporting controllable LEDs can hook into and provide
>> their own callback and LED name for setting the LED state?
>
> Hmm, nice idea. However, there is not much complexity in the code. The only
> thing worth to make generic would be the delayed register access via workqueue.
> The rest is just registering the led device :)
>
> I thought about moving the code into the generic phy code and using a new
> phy_driver callback for setting the LED state but there might be more then one
> LED pin on some PHYs (activity, speed, duplexmode etc.).

I think that the same callback for all LEDs and just take actions
based on which led_classdev pointer we get passed should be enough. I
agree with you that there is not much complexity, but for sure, if we
add support for LEDs to another PHY driver there will be similar stuff
done (registering a LED classdev, etc...) so we might just want to
specialize the led_brightness_set() callback and the number of LEDs.
One thing with moving this closer to the PHY state machine would be to
allow for better integration, like setting the LED brightness to 0
when the link goes down etc...

>
>>> +
>>> +static void at8035_led_brightness_set(struct led_classdev *led,
>>> +                                     enum led_brightness brightness)
>>> +{
>>> +       struct at8035_priv *priv = container_of(led, struct at8035_priv, led);
>>> +
>>> +       /* MDIO bus can only be used from process context */
>>> +       if (!priv->stop)
>>> +               schedule_work(&priv->led_work);
>>
>> It seems to me that you could remove the stop boolean if you move
>> led_classdev_unregister upper, provided that it guarantees it will not
>> schedule the workqueue.
>
> led_classdev_unregister will try to set brightness to 0 and thus schedule
> the work.

Ok, thanks!
--
Florian
