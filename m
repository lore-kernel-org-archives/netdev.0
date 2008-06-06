From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: msi interrupts
Date: Fri, 06 Jun 2008 13:15:32 -0400
Message-ID: <484970B4.6080500@nvidia.com>
References: <4845AEE2.1090905@nvidia.com> <20080604151854.4a6f22b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com,
	akpm@linuxfoundation.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:12792 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758662AbYFFUPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 16:15:53 -0400
In-Reply-To: <20080604151854.4a6f22b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Andrew Morton wrote:
> On Tue, 03 Jun 2008 16:51:46 -0400
> Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> 
>  > This patch adds a workaround for lost MSI interrupts. There is a race
>  > condition in the HW in which future interrupts could be missed. The
>  > workaround is to toggle the MSI irq mask.
>  >
> 
> Do you think this is a 2.6.26 thing?
It is by HW design, not related to the kernel.

> 
>  > [patch-forcedeth-msi-irq  text/plain (1.3KB)]
>  > --- old/drivers/net/forcedeth.c       2008-06-03 16:16:26.000000000 -0400
>  > +++ new/drivers/net/forcedeth.c       2008-06-03 16:31:44.000000000 -0400
>  > @@ -3277,6 +3277,20 @@
>  >       dprintk(KERN_DEBUG "%s: link change notification done.\n", 
> dev->name);
>  >  }
>  > 
>  > +static inline void nv_msi_workaround(struct net_device *dev)
>  > +{
>  > +     struct fe_priv *np = netdev_priv(dev);
>  > +     u8 __iomem *base = get_hwbase(dev);
>  > +
>  > +     /* Need to toggle the msi irq mask within the ethernet device,
>  > +      * otherwise, future interrupts will not be detected.
>  > +      */
>  > +     if (np->msi_flags & NV_MSI_ENABLED) {
>  > +             writel(0, base + NvRegMSIIrqMask);
>  > +             writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
>  > +     }
>  > +}
>  > +
>  >  static irqreturn_t nv_nic_irq(int foo, void *data)
>  >  {
>  >       struct net_device *dev = (struct net_device *) data;
>  > @@ -3299,6 +3313,8 @@
>  >               if (!(events & np->irqmask))
>  >                       break;
>  > 
>  > +             nv_msi_workaround(dev);
>  > +
>  >               spin_lock(&np->lock);
>  >               nv_tx_done(dev);
>  >               spin_unlock(&np->lock);
>  > @@ -3414,6 +3430,8 @@
>  >               if (!(events & np->irqmask))
>  >                       break;
>  > 
>  > +             nv_msi_workaround(dev);
>  > +
>  >               spin_lock(&np->lock);
>  >               nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
>  >               spin_unlock(&np->lock);
>  > @@ -3754,6 +3772,8 @@
>  >       if (!(events & NVREG_IRQ_TIMER))
>  >               return IRQ_RETVAL(0);
>  > 
>  > +     nv_msi_workaround(dev);
>  > +
>  >       spin_lock(&np->lock);
>  >       np->intr_test = 1;
>  >       spin_unlock(&np->lock);
>  >
> 
> I'm not loving the implementation.
> 
> - That `inline' adds 35 bytes more text to the driver, and we expect
>   that this often yields slower code.
> 
> - Every caller of nv_msi_workaround() already has the fe_priv* in a
>   local variable, so why not pass that in and save the additional
>   pointer calculation?
> 
> So this:
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-msi-interrupts-uninlining 
> drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-msi-interrupts-uninlining
> +++ a/drivers/net/forcedeth.c
> @@ -3277,15 +3277,14 @@ static void nv_link_irq(struct net_devic
>         dprintk(KERN_DEBUG "%s: link change notification done.\n", 
> dev->name);
>  }
> 
> -static inline void nv_msi_workaround(struct net_device *dev)
> +static void nv_msi_workaround(struct fe_priv *np)
>  {
> -       struct fe_priv *np = netdev_priv(dev);
> -       u8 __iomem *base = get_hwbase(dev);
> -
>         /* Need to toggle the msi irq mask within the ethernet device,
>          * otherwise, future interrupts will not be detected.
>          */
>         if (np->msi_flags & NV_MSI_ENABLED) {
> +               u8 __iomem *base = np->base;
> +
>                 writel(0, base + NvRegMSIIrqMask);
>                 writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
>         }
> @@ -3313,7 +3312,7 @@ static irqreturn_t nv_nic_irq(int foo, v
>                 if (!(events & np->irqmask))
>                         break;
> 
> -               nv_msi_workaround(dev);
> +               nv_msi_workaround(np);
> 
>                 spin_lock(&np->lock);
>                 nv_tx_done(dev);
> @@ -3430,7 +3429,7 @@ static irqreturn_t nv_nic_irq_optimized(
>                 if (!(events & np->irqmask))
>                         break;
> 
> -               nv_msi_workaround(dev);
> +               nv_msi_workaround(np);
> 
>                 spin_lock(&np->lock);
>                 nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
> @@ -3772,7 +3771,7 @@ static irqreturn_t nv_nic_irq_test(int f
>         if (!(events & NVREG_IRQ_TIMER))
>                 return IRQ_RETVAL(0);
> 
> -       nv_msi_workaround(dev);
> +       nv_msi_workaround(np);
> 
>         spin_lock(&np->lock);
>         np->intr_test = 1;
> _
> 
> 
> save 42 bytes of text.
> 
> Now, if the (np->msi_flags & NV_MSI_ENABLED) test is usually false then
> there might be some advantage in inlining the whole thing.  Or just
> inlining the NV_MSI_ENABLED test, but those two writel()s probably
> aren't worth the fuss of uninlining.
> 
> 
Sure, thats fine.

> 
> Semi-relatedly, the driver does an awful lot of this:
> 
>         struct fe_priv *np = get_nvpriv(dev);
>         u8 __iomem *base = get_hwbase(dev);
> 
> but get_hwbase() re-evaluates netdev_priv().  It would be more
> efficient to pass an fe_priv* into get_hwbase().  Or, better, just
> remove get_hwbase() and open-code `np->base' everywhere.
> 
> 
> 

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
