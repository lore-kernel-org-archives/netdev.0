From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] of_mdio: fix phy interrupt passing
Date: Mon, 17 Feb 2014 09:26:29 -0800
Message-ID: <CAGVrzcYeuTA0Yd5YyOTuWQfnwLw9zP87MaYJOLwprZRCtvuaXw@mail.gmail.com>
References: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Likely <grant.likely@linaro.org>,
	linux-kernel@lists.codethink.co.uk,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

2014-02-17 8:29 GMT-08:00 Ben Dooks <ben.dooks@codethink.co.uk>:
> The of_mdiobus_register_phy() is not setting phy->irq this causing
> some drivers to incorrectly assume that the PHY does not have an
> IRQ associated with it or install an interrupt handler for the
> PHY.
>
> Simplify the code setting irq and set the phy->irq at the same
> time so that the case if mdio->irq is not NULL is easier to read.

The real bug fix, which is not properly explained here, is that
irq_of_parse_and_map() should return values > 0 when the interrupt is
valid, so this makes me wonder why we are not propagating the return
value from irq_of_parse_and_map() in case the call to
of_irq_parse_one() does return something non-zero?

Other than that, I agree with the resolution, but it deserves a better
commit message, and eventually doing this in two steps:

- first fix the bug by changing the if (!mdio->irq[addr]) into a if
(mdio->irq[addr] <= 0)
- second submit a patch which cleanups the assignment

>
> This fixes the issue:
>  net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI
>
> to the correct:
>  net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI
>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
>  drivers/of/of_mdio.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 875b7b6..7b3e7b0 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -44,7 +44,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>  {
>         struct phy_device *phy;
>         bool is_c45;
> -       int rc, prev_irq;
> +       int rc;
>         u32 max_speed = 0;
>
>         is_c45 = of_device_is_compatible(child,
> @@ -55,11 +55,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>                 return 1;
>
>         if (mdio->irq) {
> -               prev_irq = mdio->irq[addr];
> -               mdio->irq[addr] =
> -                       irq_of_parse_and_map(child, 0);
> -               if (!mdio->irq[addr])
> -                       mdio->irq[addr] = prev_irq;
> +               rc = irq_of_parse_and_map(child, 0);
> +               if (rc > 0) {
> +                       mdio->irq[addr] = rc;
> +                       phy->irq = rc;
> +               }
>         }
>
>         /* Associate the OF node with the device structure so it
> --
> 1.8.5.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
