From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] net/smsc911x: fix irq resource allocation failure
Date: Mon, 4 May 2015 15:16:50 +0200
Message-ID: <CACRpkdaMwmMYUff+_PUCQrACEu6x-2uQbvFF_t1hTmTmFeODDg@mail.gmail.com>
References: <1430730589-17378-1-git-send-email-kamlakant.patel@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	"David S . Miller" <davem@davemloft.net>
To: Kamlakant Patel <kamlakant.patel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34813 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbbEDNQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 09:16:51 -0400
Received: by oiko83 with SMTP id o83so111342600oik.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 06:16:50 -0700 (PDT)
In-Reply-To: <1430730589-17378-1-git-send-email-kamlakant.patel@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 4, 2015 at 11:09 AM,  <kamlakant.patel@broadcom.com> wrote:

> From: Kamlakant Patel <kamlakant.patel@broadcom.com>
>
> When smsc911x uses GPIO as the interrupt controller, and if both are
> loaded as modules, we get following error:
>
> "smsc911x: Could not allocate irq resource"
>
> This issue is because of smsc911x using platform_get_resource to get
> device tree based irq resource.
>
> commit "9ec36ca (of/irq: do irq resolution in platform_get_irq)" and
> commit "7085a7 (drivers: platform: parse IRQ flags from resources)" add
> support in platform_get_irq to resolve irq and irq_flags respectively
> for both modern device tree and legacy static platform data platforms.
>
> Modify smsc911x driver to use platform_get_irq to pick up irq resource
> correctly and use irq_get_trigger_type to get the IRQ trigger flags.
>
> Signed-off-by: Kamlakant Patel <kamlakant.patel@broadcom.com>

Basically identical to commit d52fdbb735c36a209f36a628d40ca9185b349ba7
"smc91x: retrieve IRQ and trigger flags in a modern way" for
the SMC91x driver, which was reverted but should now be unreverted
as the patch to driver core was merged :P


> -       irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> -       if (!irq_res) {
> +       irq = platform_get_irq(pdev, 0);
> +       if (irq <= 0) {
>                 pr_warn("Could not allocate irq resource\n");

Correct.

> -       dev->irq = irq_res->start;
> -       irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
> +       dev->irq = irq;
> +       irq_flags = irq_get_trigger_type(irq);

This slightly alters semantics, since any other flags apart from trigger
flags will also be retrieved. maybe you should still add

irq_flags &= IRQF_TRIGGER_MASK;

after this line?

Yours,
Linus Walleij
