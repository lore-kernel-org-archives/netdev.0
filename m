From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Tue, 21 Jan 2014 12:11:06 +0900
Message-ID: <CAAVeFuLP4MkfXGG1FMauvUw_J63zRXdhGwxqYy5W98L1wCQNbw@mail.gmail.com>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
 <1389941251-32692-5-git-send-email-wens@csie.org> <201401171747.46332.arnd@arndb.de>
 <CAGb2v67UKiyfJbKZ_Frk3OwZupMPoA2Ck3Hj2zsRFXBQPztavg@mail.gmail.com> <CACRpkdZOD4zeA8T5kbJ4c5NsnuzHCg1mw8rRMYNT9c4R-Qnc6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens@csie.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-sunxi <linux-sunxi@googlegroups.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:62145 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbaAUDL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 22:11:27 -0500
In-Reply-To: <CACRpkdZOD4zeA8T5kbJ4c5NsnuzHCg1mw8rRMYNT9c4R-Qnc6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 8:11 AM, Linus Walleij <linus.walleij@linaro.org> wrote:
> On Fri, Jan 17, 2014 at 6:43 PM, Chen-Yu Tsai <wens@csie.org> wrote:
>> On Sat, Jan 18, 2014 at 12:47 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>
>>>> +- NAME_shutdown-gpios  : GPIO phandle to shutdown control
>>>> +                         (phandle must be the second)
>>>> +- NAME_reset-gpios     : GPIO phandle to reset control
>>>> +
>>>> +NAME must match the rfkill-name property. NAME_shutdown-gpios or
>>>> +NAME_reset-gpios, or both, must be defined.
>>>> +
>>>
>>> I don't understand this part. Why do you include the name in the
>>> gpios property, rather than just hardcoding the property strings
>>> to "shutdown-gpios" and "reset-gpios"?
>>
>> This quirk is a result of how gpiod_get_index implements device tree
>> lookup.
>
> Why can't it just have a single property "gpios", where the first
> element is the reset GPIO and the second is the shutdown GPIO?
>
> rfkill-gpio does this:
>
> gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
> gpio = devm_gpiod_get_index(&pdev->dev, rfkill->shutdown_name, 1);
>
> The passed con ID name parameter is only there for the device
> tree case it seems. (ACPI ignores it.) So what about you just
> don't pass it at all and patch it to do like this instead:
>
> gpio = devm_gpiod_get_index(&pdev->dev, NULL, 0);
> gpio = devm_gpiod_get_index(&pdev->dev, NULL, 1);
>
> Heikki, are you OK with this change?
>
> I think this is actually necessary if the ACPI and DT unification
> pipe dream shall limp forward, we cannot have arguments passed
> that have a semantic effect on DT but not on ACPI... Drivers
> that are supposed to use both ACPI and DT will always
> have to pass NULL as con ID.

I agree that's how it should be be done with the current API if your
driver can obtain GPIOs from both ACPI and DT. This is a potential
issue, as drivers are not supposed to make assumptions about who is
going to be their GPIO provider. Let's say you started a driver with
only DT in mind, and used gpio_get(dev, con_id) to get your GPIOs. DT
bindings are thus of the form "con_id-gpio = <phandle>", and set in
stone. Then later, someone wants to use your driver with ACPI. How do
you handle that gracefully?

I'm starting to wonder, now that ACPI is a first-class GPIO provider,
whether we should not start to encourage the deprecation of the
"con_id-gpio = <phandle>" binding form in DT and only use a single
indexed GPIO property per device. The con_id parameter would then only
be used as a label, which would also have the nice side-effect that
all GPIOs used for a given function will be reported under the same
name no matter what the GPIO provider is.

>From an aesthetic point of view, I definitely prefer using con_id to
identify GPIOs instead of indexes, but I don't see how we can make it
play nice with ACPI. Thoughts?

Alex.
