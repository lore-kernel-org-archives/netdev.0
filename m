From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 1/3] net: smc91x: isolate u16 writes alignment workaround
Date: Mon, 10 Oct 2016 00:55:17 +0300
Message-ID: <CAHp75Vco13D7qQmC8vn6HGg9RYOwR-MgL2uo_cn_OSo4sk84UQ@mail.gmail.com>
References: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 9, 2016 at 11:33 PM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
> Writes to u16 has a special handling on 3 PXA platforms, where the
> hardware wiring forces these writes to be u32 aligned.
>
> This patch isolates this handling for PXA platforms as before, but
> enables this "workaround" to be set up dynamically, which will be the
> case in device-tree build types.
>
> This patch was tested on 2 PXA platforms : mainstone, which relies on
> the workaround, and lubbock, which doesn't.

> @@ -2276,6 +2277,9 @@ static int smc_drv_probe(struct platform_device *pdev)
>                 memcpy(&lp->cfg, pd, sizeof(lp->cfg));
>                 lp->io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
>         }
> +       lp->half_word_align4 =
> +               machine_is_mainstone() || machine_is_stargate2() ||
> +               machine_is_pxa_idp();

>  /* We actually can't write halfwords properly if not word aligned */
> -static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
> +static inline void _SMC_outw_align4(u16 val, void __iomem *ioaddr, int reg,
> +                                   bool use_align4_workaround)
>  {
> -       if ((machine_is_mainstone() || machine_is_stargate2() ||
> -            machine_is_pxa_idp()) && reg & 2) {
> +       if (use_align4_workaround) {
>                 unsigned int v = val << 16;
>                 v |= readl(ioaddr + (reg & ~2)) & 0xffff;
>                 writel(v, ioaddr + (reg & ~2));

> +#define SMC_outw(lp, v, a, r)                                          \
> +       _SMC_outw_align4((v), (a), (r),                                 \
> +                        IS_BUILTIN(CONFIG_ARCH_PXA) && ((r) & 2) &&    \
> +                        lp->half_word_align4)

Hmm... Isn't enough to have just (r) & 2 && lp->half_word_align4 ?


-- 
With Best Regards,
Andy Shevchenko
