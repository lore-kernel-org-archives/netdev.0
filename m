From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] of_mdio: Allow the DT to specify the phy ID and avoid autoprobing
Date: Fri, 31 Jan 2014 14:24:52 -0800
Message-ID: <CAGVrzcbVo-Zzm9kLhiptf-qWgPH9XSs29mW8g2=g=Bq=PCb0_w@mail.gmail.com>
References: <1391205045-1751-1-git-send-email-jgunthorpe@obsidianresearch.com> <1391205045-1751-2-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391205045-1751-2-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2014-01-31 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>:
> This makes the generic of_mdiobus_register parse the DT compatible string for
> the pattern ethernet-phy-idAAAA.BBBB. If present it should be a value that
> matches the phy-id register normally readable through MDIO.
>
> When the ID is given the phy autoprobing is defeated and the phy is
> created directly.
>
> This is necessary to support phy's that cannot be autoprobed when
> of_mdiobus_register is called. Specifically, my case has the phy in reset at
> of_mdiobus_register, the reset is only released once the ethernet driver
> starts, before it attaches to the phy.

Who is responsible for bringing the PHY out of reset, is it the
Ethernet/MDIO bus driver? Is the PHY put into reset using, e.g a GPIO
line or any sort of reset controller, if so, should not we have some
sort of reset handle node and handle that in a generic manner?

Is your DTS or DTB hardcoding the PHY id, or are you having your
bootloader detect the exact PHY for you, then putting back the PHY
into reset to save power, until someone uses that PHY again?

>
> Tested on ARM Kirkwood with phy id 0x01410e90 (Marvell 88E1318)
>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> ---
>  drivers/of/of_mdio.c | 30 +++++++++++++++++++++++++++++-
>  1 file changed, 29 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index d5a57a9..c93287e 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -22,6 +22,30 @@
>  MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
>  MODULE_LICENSE("GPL");
>
> +/* Extract the clause 22 phy ID from the compatible string of the form
> + * ethernet-phy-idAAAA.BBBB */
> +static int of_get_phy_id(struct device_node *device, u32 *phy_id)
> +{
> +       const char *cp;
> +       int cplen, l;
> +       unsigned int upper, lower;
> +
> +       cp = of_get_property(device, "compatible", &cplen);
> +       if (cp == NULL)
> +               return -EINVAL;
> +       while (cplen > 0) {
> +               if (sscanf(cp, "ethernet-phy-id%4x.%4x", &upper, &lower) == 2) {

You might want to guard against 0x0 and 0xffff just in case whoever
fills this information in the Device Tree was reading bogus data out
of the MDIO bus, otherwise, chances are that the "Generic PHY" driver
will be picked up, and it might still not be appropriate for driving
your PHY chip.

> +                       *phy_id = ((upper & 0xFFFF) << 16) | (lower & 0xFFFF);
> +                       return 0;
> +               }
> +
> +               l = strlen(cp) + 1;
> +               cp += l;
> +               cplen -= l;
> +       }
> +       return -EINVAL;
> +}
> +
>  /**
>   * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
>   * @mdio: pointer to mii_bus structure
> @@ -36,6 +60,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>         struct device_node *child;
>         const __be32 *paddr;
>         u32 addr;
> +       u32 phy_id;
>         bool is_c45, scanphys = false;
>         int rc, i, len;
>
> @@ -81,7 +106,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>
>                 is_c45 = of_device_is_compatible(child,
>                                                  "ethernet-phy-ieee802.3-c45");
> -               phy = get_phy_device(mdio, addr, is_c45);
> +               if (!is_c45 && !of_get_phy_id(child, &phy_id))
> +                       phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
> +               else
> +                       phy = get_phy_device(mdio, addr, is_c45);
>
>                 if (!phy || IS_ERR(phy)) {
>                         dev_err(&mdio->dev,
> --
> 1.8.1.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Florian
