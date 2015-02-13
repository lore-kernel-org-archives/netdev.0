From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a
 modern way"
Date: Fri, 13 Feb 2015 10:16:09 +0800
Message-ID: <CACRpkdZGze_2=hWe414Eum_9hpNXgog5vmu6Y4R_zhg0x2z0SQ@mail.gmail.com>
References: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2015 at 12:59 AM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:

> The commit breaks the legacy platforms, ie. these not using device-tree,
> and setting up the interrupt resources with a flag to activate edge
> detection. The issue was found on the zylonite platform.
>
> The reason is that zylonite uses platform resources to pass the interrupt number
> and the irq flags (here IORESOURCE_IRQ_HIGHEDGE). It expects the driver to
> request the irq with these flags, which in turn setups the irq as high edge
> triggered.
>
> After the patch, this was supposed to be taken care of with :
>   irq_resflags = irqd_get_trigger_type(irq_get_irq_data(ndev->irq));
>
> But irq_resflags is 0 for legacy platforms, while for example in
> arch/arm/mach-pxa/zylonite.c, in struct resource smc91x_resources[] the
> irq flag is specified. This breaks zylonite because the interrupt is not
> setup as triggered, and hardware doesn't provide interrupts.
>
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>

But isn't the real problem that in the device tree case,
irq_get_irq_data(ndev->irq) will work becaus parsing an interrupt
from the device tree populates it correctly in platform_get_irq()
whereas for the legacy lookup it just fetches the number.

So to me it seems like a weakness in the platform_get_irq()
helper altogether.

Does the following work? (I can send as a separate patch for
testing if you like).

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index 9421fed40905..301f4b9ae908 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -101,6 +101,15 @@ int platform_get_irq(struct platform_device *dev,
unsigned int num)
     }

     r = platform_get_resource(dev, IORESOURCE_IRQ, num);
+    /*
+     * The resources may pass trigger flags to the irqs that need
+     * to be set up. It so happens that the trigger flags for
+     * IORESOURCE_BITS correspond 1-to-1 to the IRQF_TRIGGER*
+     * settings.
+     */
+    if (r->flags & IORESOURCE_BITS)
+        irqd_set_trigger_type(irq_get_irq_data(r->start),
+                      r->flags & IORESOURCE_BITS);


Yours,
Linus Walleij
