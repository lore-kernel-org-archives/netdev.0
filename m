From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] dm9000: Fix irq trigger type setup on non-dt platforms
Date: Tue, 09 Aug 2016 19:20:44 +0200
Message-ID: <878tw5x3ir.fsf@belgarion.home>
References: <1470758408-14248-1-git-send-email-s.nawrocki@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linus.walleij@linaro.org, tglx@linutronix.de,
	b.zolnierkie@samsung.com, linux-kernel@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
To: Sylwester Nawrocki <s.nawrocki@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470758408-14248-1-git-send-email-s.nawrocki@samsung.com>
	(Sylwester Nawrocki's message of "Tue, 09 Aug 2016 18:00:08 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sylwester Nawrocki <s.nawrocki@samsung.com> writes:

> Commit b5a099c67a1c36b "net: ethernet: davicom: fix devicetree irq
> resource" causes an interrupt storm after the ethernet interface
> is activated on S3C24XX platform (ARM non-dt), due to the interrupt
> trigger type not being set properly.
>
> It seems, after adding parsing of IRQ flags in commit 7085a7401ba54e92b
> "drivers: platform: parse IRQ flags from resources", there is no path
> for non-dt platforms where irq_set_type callback could be invoked when
> we don't pass the trigger type flags to the request_irq() call.
>
> In case of a board where the regression is seen the interrupt trigger
> type flags are passed through a platform device's resource and it is
> not currently handled properly without passing the irq trigger type
> flags to the request_irq() call.  In case of OF an of_irq_get() call
> within platform_get_irq() function seems to be ensuring required irq_chip
> setup, but there is no equivalent code for non OF/ACPI platforms.
>
> This patch mostly restores irq trigger type setting code which has been
> removed in commit ("net: ethernet: davicom: fix devicetree irq resource").
>
> Fixes: b5a099c67a1c36b913 ("net: ethernet: davicom: fix devicetree irq resource")
>
> Signed-off-by: Sylwester Nawrocki <s.nawrocki@samsung.com>
> ---
>
> Perhaps instead the core could be configuring the irqchip automatically as it
> is done for OF/ACPI cases. I had doubts though if trying to make such changes
> for a bug fix patch was the right thing to do.
Hi Sylvester,

You're right, and I came to the same conclusion a bit earlier, in [1], but I
didn't notice my FAI didn't actually send the mail. Your analysis of the core in
non-OF/ACPI case is the reason I didn't post a patch for dm9000 ... I was
overconfident in finding a reason in irq core code within a couple of days.

Therefore:
Acked-by: Robert Jarzmik <robert.jarzmik@free.fr>

And I can make a test for you on my cm-x300 board, even if your patch is very
alike the draft I had in my internal tree since then.

Cheers.

--
Robert

[1] Non-delivered mail, shame on me
From: Robert Jarzmik <robert.jarzmik@free.fr>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org "David S. Miller" <davem@davemloft.net>
Subject: platform_get_irq and trigger types
X-URL: http://belgarath.falguerolles.org/
Date: Sat, 21 May 2016 11:16:09 +0200
Message-ID: <87y473hiue.fsf@belgarion.home>
User-Agent: Gnus/5.130008 (Ma Gnus v0.8) Emacs/24.4 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain

Hi Linus,

I was bitten again by the rising/falling flags of interrupt flags.

The commit which triggered this "regression" (the wording regression is rather
incorrect so please don't take this as an incentive to revert) is :
   b5a099c67a1c ("net: ethernet: davicom: fix devicetree irq resource")

The exact context is that for platform type builds, the irq rising edge flag is
not activated in the irqchip, ie. in the gpio-pxa.c pxa_gpio_irq_type() is not
called. The board used for this test is arch/arm/mach-pxa/cm-x300.c (line 200).

Now I've started to add printks here and there, and from a first glance :
 - platform_get_irq() is correctly calling irqd_set_trigger_type()
 - but upon the request_irq() in drivers/net/ethernet/davicom/dm9000.c:1319,
   these flags are not taken into account
   => this is where commit b5a099c67a1c comes into play
   => re-adding irq_get_trigger_type(dev->irq) to the passed flags does solve the
      issue

I tried to ponder whether my commit was wrong, or if it's the gpio-pxa.c which
is wrong, or something else. My inner feeling is that dm9000.c code is now
correct, and that something else is happening that I don't understand.

I'm bringing this to your attention if you have an idea before I begin to dig
deeper, add printk() and go down to the problem.

Cheers.

-- 
Robert
