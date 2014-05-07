From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mdio: of_mdio: check for already registered phy
 before creating new instances
Date: Tue, 6 May 2014 17:55:30 -0700
Message-ID: <CAGVrzcY+3xeDzMAe1683+ypF59eMN9oTss6LC_rLShuEpmC4NA@mail.gmail.com>
References: <1399389711-32716-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:40429 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549AbaEGA4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 20:56:12 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so312169qcv.33
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 17:56:11 -0700 (PDT)
In-Reply-To: <1399389711-32716-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

2014-05-06 8:21 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> In of_mdiobus_register_phy(), check if the phy with the given address is
> already registered within the mii bus before calling phy_device_create()
> or get_phy_device().

I am not exactly sure how you could be in that sort of situation.
of_mdiobus_register() handles two different cases at the moment:

1) PHY child nodes have a valid 'reg' property, and this property is
used to register the PHY at the given address
2) if a PHY child node does not have a valid 'reg' property, which
will trigger an auto-scan and then we iterate through all 32 addresses
of the bus, we skip over PHYs that are already registered

>
> This allows us to augment auto-probed phy devices with extra information
> via DT. Without this patch, a second instance of the phydev is created
> unnecessarily.

Which piece of code is doing the auto-probing in your case? One of the
very first things that of_mdiobus_register() does is set the PHY mask
to 0xffffffff to prevent the default PHY probing method to trigger,
since we are using information from the Device Tree right after that.

>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>  drivers/of/of_mdio.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 9a95831..264ea3f 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -72,10 +72,15 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>         is_c45 = of_device_is_compatible(child,
>                                          "ethernet-phy-ieee802.3-c45");
>
> -       if (!is_c45 && !of_get_phy_id(child, &phy_id))
> -               phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
> -       else
> -               phy = get_phy_device(mdio, addr, is_c45);
> +       /* Check if the phy we're looking for is already registered */
> +       phy = mdio->phy_map[addr];
> +       if (!phy) {
> +               if (!is_c45 && !of_get_phy_id(child, &phy_id))
> +                       phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
> +               else
> +                       phy = get_phy_device(mdio, addr, is_c45);
> +       }
> +
>         if (!phy || IS_ERR(phy))
>                 return 1;
>
> --
> 1.9.0
>



-- 
Florian
