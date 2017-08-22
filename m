From: Priit Laes <plaes@plaes.org>
Subject: Re: Crash due to fbca164776e438 - "net: stmmac: Use the right
 logging function in stmmac_mdio_register"
Date: Tue, 22 Aug 2017 19:20:57 +0000
Message-ID: <20170822192057.GB6429@plaes.org>
References: <20170822184757.GA6429@plaes.org>
 <6d3c8253-1e31-761f-4b50-0bf087047753@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Romain Perier <romain.perier@collabora.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Chen-Yu Tsai <wens@csie.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6d3c8253-1e31-761f-4b50-0bf087047753@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 12:01:32PM -0700, Florian Fainelli wrote:
> On 08/22/2017 11:47 AM, Priit Laes wrote:
> > Hi!
> > 
> > I'm running into following crash during boot on Cubietruck A20, with the patch
> > fbca164776e438
> > (net: stmmac: Use the right logging function in stmmac_mdio_register) applied:
> > 
> > [snip]
> > sun7i-dwmac 1c50000.ethernet: PTP uses main clock
> > sun7i-dwmac 1c50000.ethernet: no reset control found
> > sun7i-dwmac 1c50000.ethernet: no regulator found
> > sun7i-dwmac 1c50000.ethernet: Ring mode enabled
> > sun7i-dwmac 1c50000.ethernet: DMA HW capability register supported
> > sun7i-dwmac 1c50000.ethernet: Normal descriptors
> > libphy: stmmac: probed
> > Unable to handle kernel NULL pointer dereference at virtual address 00000048
> 
> Yes indeed:
> 
> (gdb) p/x (int)&((struct phy_driver *)0)->name
> $2 = 0x48
> 
> The following should fix it:
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 9493fb369682..810f6fd2f639 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -877,15 +877,17 @@ EXPORT_SYMBOL(phy_attached_info);
>  #define ATTACHED_FMT "attached PHY driver [%s] (mii_bus:phy_addr=%s,
> irq=%d)"
>  void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
>  {
> +       const char *drv_name = phydev->drv ? phydev->drv->name : "unbound";
> +
>         if (!fmt) {
>                 dev_info(&phydev->mdio.dev, ATTACHED_FMT "\n",
> -                        phydev->drv->name, phydev_name(phydev),
> +                        drv_name, phydev_name(phydev),
>                          phydev->irq);
>         } else {
>                 va_list ap;
> 
>                 dev_info(&phydev->mdio.dev, ATTACHED_FMT,
> -                        phydev->drv->name, phydev_name(phydev),
> +                        drv_name, phydev_name(phydev),
>                          phydev->irq);
> 
>                 va_start(ap, fmt);
> 

Thanks, patch works.

Tested-By: Priit Laes <plaes@plaes.org>

With reverted patch:

sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
sun7i-dwmac 1c50000.ethernet (unnamed net_device) (uninitialized): PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)

With changes by Florian:

mdio_bus stmmac-0:00: attached PHY driver [unbound] (mii_bus:phy_addr=stmmac-0:00, irq=-1)
mdio_bus stmmac-0:01: attached PHY driver [unbound] (mii_bus:phy_addr=stmmac-0:01, irq=-1)


Päikest,
Priit :)
