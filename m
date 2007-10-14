From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH v3 4/4] FEC mpc52xx: phy part of the driver
Date: Sun, 14 Oct 2007 16:05:17 -0600
Message-ID: <fa686aa40710141505w1787e7e1g6116185001561a4d@mail.gmail.com>
References: <20071014075511.GC3000@nd47.coderock.org>
	 <20071014075958.GG3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, jgarzik@pobox.com,
	linuxppc-dev@ozlabs.org, tnt@246tnt.com, netdev@vger.kernel.org
To: "Domen Puncer" <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:24934 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665AbXJNWFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 18:05:18 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1732885wah
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2007 15:05:17 -0700 (PDT)
In-Reply-To: <20071014075958.GG3000@nd47.coderock.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/07, Domen Puncer <domen.puncer@telargo.com> wrote:
> PHY part of the driver for mpc5200(b) ethernet.

Assuming I understand correctly, this comment is not correct and this
patch just adds an MDIO bus driver.  PHY drivers are in phylib and
data transfer is setup via the core driver, correct?

It is conceivable that the PHY is connected to an alternate MDIO bus,
or the MDIO bus is used for a PHY connected to an external Ethernet
controller.

Speaking of which, is it possible to use this MDIO bus without the
core FEC being initialized?

> +static struct of_device_id fec_mdio_match[] = {
> +       {
> +               .type = "mdio",
> +               .compatible = "mpc5200b-fec-phy",

This is not a phy; it's an MDIO bus.  Also, shouldn't this be
"mpc5200-..." instead of "mpc5200b-..."?

> +       },
> +       {},
> +};
> +
> +struct of_platform_driver mpc52xx_fec_mdio_driver = {
> +       .name = "mpc5200b-fec-phy",
> +       .probe = fec_mdio_probe,
> +       .remove = fec_mdio_remove,
> +       .match_table = fec_mdio_match,

Inconsistent naming.  Please use the same prefix on all global/static
symbols (ie. use "mpc52xx_mdio_" instead of the mix of
"mpc52xx_fec_mdio_", "fec_mdio_", etc.)  I also thing that "fec_mdio_"
is too generic because there are a number of different incompatible
FEC devices.

> +};
> +
> +/* let fec driver call it, since this has to be registered before it */
> +EXPORT_SYMBOL_GPL(mpc52xx_fec_mdio_driver);

Why not have a module_init()/module_exit() in this file?  I don't
think the FEC driver calls this driver's functions directly anymore,
and it's still dependent on the of_platform bus probe order anyway.

As an added bonus, it makes your Makefile much simpler.

> +
> +
> +MODULE_LICENSE("Dual BSD/GPL");
> Index: linux.git/drivers/net/fec_mpc52xx/Makefile
> ===================================================================
> --- linux.git.orig/drivers/net/fec_mpc52xx/Makefile
> +++ linux.git/drivers/net/fec_mpc52xx/Makefile
> @@ -1,2 +1,7 @@
>  obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
>  fec_mpc52xx-objs := fec.o
> +
> +ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
> +       obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
> +       fec_mpc52xx_phy-objs := fec_phy.o
> +endif
> Index: linux.git/drivers/net/fec_mpc52xx/Kconfig
> ===================================================================
> --- linux.git.orig/drivers/net/fec_mpc52xx/Kconfig
> +++ linux.git/drivers/net/fec_mpc52xx/Kconfig
> @@ -11,5 +11,18 @@ config FEC_MPC52xx
>         ---help---
>           This option enables support for the MPC5200's on-chip
>           Fast Ethernet Controller
> +         If compiled as module, it will be called 'fec_mpc52xx.ko'.

Drop this line and make the help text the same format as the other eth
drivers in drivers/net.

> +
> +config FEC_MPC52xx_MDIO
> +       bool "FEC MII PHY driver"
> +       depends on FEC_MPC52xx
> +       default y
> +       ---help---
> +         The MPC5200's FEC can connect to the Ethernet either with
> +         an external MII PHY chip or 10 Mbps 7-wire interface
> +         (Motorola? industry standard).
> +         If your board uses an external PHY, enable this.

Not strictly true.  This enables talking to a PHY using the internal
MDIO controller.  PHY register access could just as easily be accessed
via an alternate interface.

> +         If not sure, enable.
> +         If compiled as module, it will be called 'fec_mpc52xx_phy.ko'.

Drop the module name comment.

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
grant.likely@secretlab.ca
(403) 399-0195
