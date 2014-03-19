From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH v3 2/2] of_mdio: Allow the DT to specify the phy ID and
 avoid autoprobing
Date: Wed, 19 Mar 2014 17:40:05 -0500
Message-ID: <CAL_Jsq+cZ=SW-LtTvKwrWQYo7aV0XLXpvT2022EnAvFeDr+Zmg@mail.gmail.com>
References: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
	<1395267324-5788-2-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395267324-5788-2-git-send-email-jgunthorpe@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 5:15 PM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
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
>
> Tested on ARM Kirkwood with phy id 0x01410e90 (Marvell 88E1318)
>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Despite the outrageous commenting style issues:

Acked-by: Rob Herring <robh@kernel.org>


> ---
>  drivers/of/of_mdio.c | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
>
> For net-next
>
> v3:
>  - Use of_property_for_each_string as per Rob Herring
>  - Rebase+retest against 3.14-rc7
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 5b3c24f..9a95831 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -43,6 +43,23 @@ static void of_set_phy_supported(struct phy_device *phydev, u32 max_speed)
>         }
>  }
>
> +/* Extract the clause 22 phy ID from the compatible string of the form
> + * ethernet-phy-idAAAA.BBBB */
> +static int of_get_phy_id(struct device_node *device, u32 *phy_id)
> +{
> +       struct property *prop;
> +       const char *cp;
> +       unsigned int upper, lower;
> +
> +       of_property_for_each_string(device, "compatible", prop, cp) {
> +               if (sscanf(cp, "ethernet-phy-id%4x.%4x", &upper, &lower) == 2) {
> +                       *phy_id = ((upper & 0xFFFF) << 16) | (lower & 0xFFFF);
> +                       return 0;
> +               }
> +       }
> +       return -EINVAL;
> +}
> +
>  static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
>                                    u32 addr)
>  {
> @@ -50,11 +67,15 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>         bool is_c45;
>         int rc;
>         u32 max_speed = 0;
> +       u32 phy_id;
>
>         is_c45 = of_device_is_compatible(child,
>                                          "ethernet-phy-ieee802.3-c45");
>
> -       phy = get_phy_device(mdio, addr, is_c45);
> +       if (!is_c45 && !of_get_phy_id(child, &phy_id))
> +               phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
> +       else
> +               phy = get_phy_device(mdio, addr, is_c45);
>         if (!phy || IS_ERR(phy))
>                 return 1;
>
> --
> 1.8.1.2
>
