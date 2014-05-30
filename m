From: Lars-Peter Clausen <lars@metafoo.de>
Subject: Re: [PATCH 2/2] gpio: gpiolib: set gpiochip_remove retval to void
Date: Fri, 30 May 2014 20:16:59 +0200
Message-ID: <5388CB1B.3090802@metafoo.de>
References: <20140530094025.3b78301e@canb.auug.org.au>        <1401449454-30895-1-git-send-email-berthe.ab@gmail.com>        <1401449454-30895-2-git-send-email-berthe.ab@gmail.com> <CAMuHMdV6AtjD2aqO3buzj8Eo7A7xc_+ROYnxEi2sdjMaqFiAuA@mail.gmail.com> <5388C0F1.90503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: abdoulaye berthe <berthe.ab@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>, m@bues.ch,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Linux MIPS Mailing List <linux-mips@linux-mips.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	patches@opensource.wolfsonmicro.com,
	"linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
	"linux-leds@vger.kernel.org" <linux-leds@vger.kernel.org>,
	Linux Media Mailing List <linux-media@vger.kernel.org>,
	linux-samsungsoc@vger.kernel.org, spear-devel@list.st.com,
	platform-driver-x86@vg
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5388C0F1.90503@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2014 07:33 PM, David Daney wrote:
> On 05/30/2014 04:39 AM, Geert Uytterhoeven wrote:
>> On Fri, May 30, 2014 at 1:30 PM, abdoulaye berthe <berthe.ab@gmail.com>
>> wrote:
>>> --- a/drivers/gpio/gpiolib.c
>>> +++ b/drivers/gpio/gpiolib.c
>>> @@ -1263,10 +1263,9 @@ static void gpiochip_irqchip_remove(struct
>>> gpio_chip *gpiochip);
>>>    *
>>>    * A gpio_chip with any GPIOs still requested may not be removed.
>>>    */
>>> -int gpiochip_remove(struct gpio_chip *chip)
>>> +void gpiochip_remove(struct gpio_chip *chip)
>>>   {
>>>          unsigned long   flags;
>>> -       int             status = 0;
>>>          unsigned        id;
>>>
>>>          acpi_gpiochip_remove(chip);
>>> @@ -1278,24 +1277,15 @@ int gpiochip_remove(struct gpio_chip *chip)
>>>          of_gpiochip_remove(chip);
>>>
>>>          for (id = 0; id < chip->ngpio; id++) {
>>> -               if (test_bit(FLAG_REQUESTED, &chip->desc[id].flags)) {
>>> -                       status = -EBUSY;
>>> -                       break;
>>> -               }
>>> -       }
>>> -       if (status == 0) {
>>> -               for (id = 0; id < chip->ngpio; id++)
>>> -                       chip->desc[id].chip = NULL;
>>> -
>>> -               list_del(&chip->list);
>>> +               if (test_bit(FLAG_REQUESTED, &chip->desc[id].flags))
>>> +                       panic("gpio: removing gpiochip with gpios still
>>> requested\n");
>>
>> panic?
>
> NACK to the patch for this reason.  The strongest thing you should do here
> is WARN.
>
> That said, I am not sure why we need this whole patch set in the first place.

Well, what currently happens when you remove a device that is a provider of 
a gpio_chip which is still in use, is that the kernel crashes. Probably with 
a rather cryptic error message. So this patch doesn't really change the 
behavior, but makes it more explicit what is actually wrong. And even if you 
replace the panic() by a WARN() it will again just crash slightly later.

This is a design flaw in the GPIO subsystem that needs to be fixed.

- Lars
