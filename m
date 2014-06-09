From: Andrzej Hajda <a.hajda@samsung.com>
Subject: Re: [PATCH 2/2] gpio: gpiolib: set gpiochip_remove retval to void
Date: Mon, 09 Jun 2014 15:15:37 +0200
Message-ID: <5395B379.2010706@samsung.com>
References: <20140530094025.3b78301e@canb.auug.org.au>
 <1401449454-30895-1-git-send-email-berthe.ab@gmail.com>
 <1401449454-30895-2-git-send-email-berthe.ab@gmail.com>
 <CAMuHMdV6AtjD2aqO3buzj8Eo7A7xc_+ROYnxEi2sdjMaqFiAuA@mail.gmail.com>
 <5388C0F1.90503@gmail.com> <5388CB1B.3090802@metafoo.de>
 <20140608231823.GB10112@trinity.fluff.org> <53959A93.7080308@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux MIPS Mailing List <linux-mips@linux-mips.org>, m@bues.ch,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	platform-driver-x86@vger.kernel.org,
	"linux-leds@vger.kernel.org" <linux-leds@vger.kernel.org>,
	driverdevel <devel@driverdev.osuosl.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	patches@opensource.wolfsonmicro.com,
	linux-samsungsoc@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	"linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
	Linux Media Mailing List <linux-media@vger.kernel.org>,
	spear-devel@list.st.com,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	David Daney <ddaney.cavm@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.ker
To: Lars-Peter Clausen <lars@metafoo.de>,
	Ben Dooks <ben@trinity.fluff.org>
Return-path: <linux-leds-owner@vger.kernel.org>
In-reply-to: <53959A93.7080308@metafoo.de>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/09/2014 01:29 PM, Lars-Peter Clausen wrote:
> On 06/09/2014 01:18 AM, Ben Dooks wrote:
>> On Fri, May 30, 2014 at 08:16:59PM +0200, Lars-Peter Clausen wrote:
>>> On 05/30/2014 07:33 PM, David Daney wrote:
>>>> On 05/30/2014 04:39 AM, Geert Uytterhoeven wrote:
>>>>> On Fri, May 30, 2014 at 1:30 PM, abdoulaye berthe <berthe.ab@gmail.com>
>>>>> wrote:
>>>>>> --- a/drivers/gpio/gpiolib.c
>>>>>> +++ b/drivers/gpio/gpiolib.c
>>>>>> @@ -1263,10 +1263,9 @@ static void gpiochip_irqchip_remove(struct
>>>>>> gpio_chip *gpiochip);
>>>>>>    *
>>>>>>    * A gpio_chip with any GPIOs still requested may not be removed.
>>>>>>    */
>>>>>> -int gpiochip_remove(struct gpio_chip *chip)
>>>>>> +void gpiochip_remove(struct gpio_chip *chip)
>>>>>>   {
>>>>>>          unsigned long   flags;
>>>>>> -       int             status = 0;
>>>>>>          unsigned        id;
>>>>>>
>>>>>>          acpi_gpiochip_remove(chip);
>>>>>> @@ -1278,24 +1277,15 @@ int gpiochip_remove(struct gpio_chip *chip)
>>>>>>          of_gpiochip_remove(chip);
>>>>>>
>>>>>>          for (id = 0; id < chip->ngpio; id++) {
>>>>>> -               if (test_bit(FLAG_REQUESTED, &chip->desc[id].flags)) {
>>>>>> -                       status = -EBUSY;
>>>>>> -                       break;
>>>>>> -               }
>>>>>> -       }
>>>>>> -       if (status == 0) {
>>>>>> -               for (id = 0; id < chip->ngpio; id++)
>>>>>> -                       chip->desc[id].chip = NULL;
>>>>>> -
>>>>>> -               list_del(&chip->list);
>>>>>> +               if (test_bit(FLAG_REQUESTED, &chip->desc[id].flags))
>>>>>> +                       panic("gpio: removing gpiochip with gpios still
>>>>>> requested\n");
>>>>>
>>>>> panic?
>>>>
>>>> NACK to the patch for this reason.  The strongest thing you should do here
>>>> is WARN.
>>>>
>>>> That said, I am not sure why we need this whole patch set in the first place.
>>>
>>> Well, what currently happens when you remove a device that is a
>>> provider of a gpio_chip which is still in use, is that the kernel
>>> crashes. Probably with a rather cryptic error message. So this patch
>>> doesn't really change the behavior, but makes it more explicit what
>>> is actually wrong. And even if you replace the panic() by a WARN()
>>> it will again just crash slightly later.
>>>
>>> This is a design flaw in the GPIO subsystem that needs to be fixed.
>>
>> Surely then the best way is to error out to the module unload and
>> stop the driver being unloaded?
>>
> 
> You can't error out on module unload, although that's not really relevant 
> here. gpiochip_remove() is typically called when the device that registered 
> the GPIO chip is unbound. And despite some remove() callbacks having a 
> return type of int you can not abort the removal of a device.

It is a design flaw in many subsystems having providers and consumers,
not only GPIO. The same situation is with clock providers, regulators,
phys, drm_panels, ..., at least it was such last time I have tested it.

The problem is that many frameworks assumes that lifetime of provider is
always bigger than lifetime of its consumers, and this is wrong
assumption - usually it is not possible to prevent unbinding driver from
device, so if the device is a provider there is no way to inform
consumers about his removal.

Some solution for such problems is to use some kind of availability
callbacks for requesting resources (gpios, clocks, regulators,...)
instead of simple 'getters' (clk_get, gpiod_get). Callbacks should
guarantee that the resource is always valid between callback reporting
its availability and callback reporting its removal. Such approach seems
to be complicated at the first sight but it should allow to make the
code safe and as a bonus it will allow to avoid deferred probing.
Btw I have send already RFC for such framework [1].

[1]: https://lkml.org/lkml/2014/4/30/345

Regards
Andrzej


> 
> - Lars
> 
