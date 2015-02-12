From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] dsa: mv88e6131: support fixed PHYs
Date: Thu, 12 Feb 2015 08:13:28 -0800
Message-ID: <CAGVrzcb5Vcx3fwFf3sVBGqw9QgZp9PD3TOZhO-CT5Eevzz5rzw@mail.gmail.com>
References: <20150212141317.GB12318@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Tobias Waldekranz <tobias@waldekranz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:59924 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933AbbBLQOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 11:14:09 -0500
Received: by mail-ob0-f182.google.com with SMTP id nt9so10630880obb.13
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 08:14:08 -0800 (PST)
In-Reply-To: <20150212141317.GB12318@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-12 6:13 GMT-08:00 Tobias Waldekranz <tobias@waldekranz.com>:
> Statically setup the PCS Control on the MAC to match the fixed PHY.

bcm_sf2 supports both fixed PHYs and regular PHYs, yet we do not need
to get access to the fixed PHY status from the adjust_link callback
because you could implement a separate fixed_link_update callback for
that purpose.

Did not that work for you?

>
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
> ---
>  drivers/net/dsa/mv88e6131.c | 43 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 43 insertions(+)
>
> diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
> index eadb27c..d2b2fcf 100644
> --- a/drivers/net/dsa/mv88e6131.c
> +++ b/drivers/net/dsa/mv88e6131.c
> @@ -337,6 +337,48 @@ mv88e6131_phy_write(struct dsa_switch *ds,
>         return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
>  }
>
> +static void mv88e6131_adjust_link(struct dsa_switch *ds, int port,
> +                                 struct phy_device *phy)
> +{
> +       u16 pcs_ctrl;
> +
> +       /* PPU will configure MACs with physical PHYs */
> +       if (!fixed_phy_get_status(phy))
> +               return;
> +
> +       pcs_ctrl = mv88e6xxx_reg_read(ds, REG_PORT(port), 1);
> +
> +       /* clear all forced settings */
> +       pcs_ctrl &= ~0xff;
> +       pcs_ctrl |= BIT(2) | BIT(4) | BIT(6);
> +
> +       switch (phy->speed) {
> +       case 10:
> +               break;
> +       case 100:
> +               pcs_ctrl |= BIT(0);
> +               break;
> +       case 1000:
> +               pcs_ctrl |= BIT(1);
> +               break;
> +
> +       default:
> +               netdev_err(ds->ports[port], "unsupported speed: %d\n", phy->speed);
> +       }
> +
> +       if (phy->duplex)
> +               pcs_ctrl |= BIT(3);
> +
> +       if (phy->link)
> +               pcs_ctrl |= BIT(5);
> +
> +       if (phy->pause)
> +               pcs_ctrl |= BIT(7);
> +
> +       mv88e6xxx_reg_write(ds, REG_PORT(port), 1, pcs_ctrl);
> +       return;
> +}
> +
>  static struct mv88e6xxx_hw_stat mv88e6131_hw_stats[] = {
>         { "in_good_octets", 8, 0x00, },
>         { "in_bad_octets", 4, 0x02, },
> @@ -398,6 +440,7 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
>         .set_addr               = mv88e6xxx_set_addr_direct,
>         .phy_read               = mv88e6131_phy_read,
>         .phy_write              = mv88e6131_phy_write,
> +       .adjust_link            = mv88e6131_adjust_link,
>         .poll_link              = mv88e6xxx_poll_link,
>         .get_strings            = mv88e6131_get_strings,
>         .get_ethtool_stats      = mv88e6131_get_ethtool_stats,
> --
> 1.8.4.357.g8d83871.dirty
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
