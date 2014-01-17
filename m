From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Sat, 18 Jan 2014 00:11:56 +0100
Message-ID: <CACRpkdZOD4zeA8T5kbJ4c5NsnuzHCg1mw8rRMYNT9c4R-Qnc6A@mail.gmail.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
	<1389941251-32692-5-git-send-email-wens@csie.org>
	<201401171747.46332.arnd@arndb.de>
	<CAGb2v67UKiyfJbKZ_Frk3OwZupMPoA2Ck3Hj2zsRFXBQPztavg@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDE6RCFOWIARBPHR42LAKGQEYXO32LQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAGb2v67UKiyfJbKZ_Frk3OwZupMPoA2Ck3Hj2zsRFXBQPztavg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Jan 17, 2014 at 6:43 PM, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> wrote:
> On Sat, Jan 18, 2014 at 12:47 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:

>>> +- NAME_shutdown-gpios  : GPIO phandle to shutdown control
>>> +                         (phandle must be the second)
>>> +- NAME_reset-gpios     : GPIO phandle to reset control
>>> +
>>> +NAME must match the rfkill-name property. NAME_shutdown-gpios or
>>> +NAME_reset-gpios, or both, must be defined.
>>> +
>>
>> I don't understand this part. Why do you include the name in the
>> gpios property, rather than just hardcoding the property strings
>> to "shutdown-gpios" and "reset-gpios"?
>
> This quirk is a result of how gpiod_get_index implements device tree
> lookup.

Why can't it just have a single property "gpios", where the first
element is the reset GPIO and the second is the shutdown GPIO?

rfkill-gpio does this:

gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
gpio = devm_gpiod_get_index(&pdev->dev, rfkill->shutdown_name, 1);

The passed con ID name parameter is only there for the device
tree case it seems. (ACPI ignores it.) So what about you just
don't pass it at all and patch it to do like this instead:

gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);
gpio = devm_gpiod_get_index(&pdev->dev, NULL, 1);

Heikki, are you OK with this change?

I think this is actually necessary if the ACPI and DT unification
pipe dream shall limp forward, we cannot have arguments passed
that have a semantic effect on DT but not on ACPI... Drivers
that are supposed to use both ACPI and DT will always
have to pass NULL as con ID.

> If con_id is given, it is prepended to "gpios" as the property string.
> con_id is also used as the label passed to gpiod_request, which is
> then shown in /sys/kernel/debug/gpio.

If your problem  is really what turns up in debugfs, then we need
to figure out a way to label gpios outside of the *gpiod_get* calls.

The string passed in *gpiod_get* is a "connection ID" not a proper
name for the GPIO.

Yours,
Linus Walleij
