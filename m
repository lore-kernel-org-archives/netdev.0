From: Anton Vorontsov <cbou@mail.ru>
Subject: Re: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY
	layer functionality
Date: Sun, 2 Dec 2007 00:34:03 +0300
Message-ID: <20071201213403.GA2350@zarina>
References: <20071126142906.19642.45540.stgit@localhost.localdomain> <47516646.9000803@scram.de>
Reply-To: cbou@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Vitaly Bordug <vitb@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Jochen Friedrich <jochen@scram.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753130AbXLAVlU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47516646.9000803@scram.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 01, 2007 at 02:48:54PM +0100, Jochen Friedrich wrote:
> Hi Vitaly,
> 
> > With that patch fixed.c now fully emulates MDIO bus, thus no need
> > to duplicate PHY layer functionality. That, in turn, drastically
> > simplifies the code, and drops down line count.
> >
> > As an additional bonus, now there is no need to register MDIO bus
> > for each PHY, all emulated PHYs placed on the platform fixed MDIO bus.
> > There is also no more need to pre-allocate PHYs via .config option,
> > this is all now handled dynamically.
> >
> > p.s. Don't even try to understand patch content! Better: apply patch
> > and look into resulting drivers/net/phy/fixed.c.
> >   
> If i understand your code correctly, you seem to rely on the fact 
> that fixed_phy_add() is called before the fixed MDIO bus is scanned for 
> devices.

Yes, indeed. The other name of "fixed phys" are "platform phys"
or "platform MDIO bus" on which virtual PHYs are placed.

That is, these phys supposed to be created by the platform setup
code (arch/). The rationale here is: we do hardware emulation, thus
to make drivers actually see that "hardware", we have to create it
early.

> I tried to add fixed-phy support to fs_enet, but the fixed phy is not 
> found this way.
> 
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -36,6 +36,7 @@
>  #include <linux/fs.h>
>  #include <linux/platform_device.h>
>  #include <linux/phy.h>
> +#include <linux/phy_fixed.h>
>  
>  #include <linux/vmalloc.h>
>  #include <asm/pgtable.h>
> @@ -1174,8 +1175,24 @@ static int __devinit find_phy(struct device_node *np,
>         struct device_node *phynode, *mdionode;
>         struct resource res;
>         int ret = 0, len;
> +       const u32 *data;
> +       struct fixed_phy_status status = {};
> +
> +       data  = of_get_property(np, "fixed-link", NULL);
> +       if (data) {
> +               status.link = 1;
> +               status.duplex = data[1];
> +               status.speed  = data[2];
> +
> +               ret = fixed_phy_add(PHY_POLL, data[0], &status);
> +               if (ret)
> +                       return ret;
> +
> +               snprintf(fpi->bus_id, 16, PHY_ID_FMT, 0, *data);
> +               return 0;
> +       }
>  
> -       const u32 *data = of_get_property(np, "phy-handle", &len);
> +       data = of_get_property(np, "phy-handle", &len);
>         if (!data || len != 4)
>                 return -EINVAL;

^^ the correct solution is to implement arch_initcall function
which will create fixed PHYs, and then leave only
snprintf(fpi->bus_id, 16, PHY_ID_FMT, 0, *data); part in the
fs_enet's find_phy().

Try add something like this to the fsl_soc.c (compile untested):

- - - -
static int __init of_add_fixed_phys(void)
{
	struct device_node *np;
	const u32 *prop;
	struct fixed_phy_status status = {};

	while ((np = of_find_node_by_name(NULL, "ethernet"))) {
		data  = of_get_property(np, "fixed-link", NULL);
		if (!data)
			continue;

		status.link = 1;
		status.duplex = data[1];
		status.speed  = data[2];

		ret = fixed_phy_add(PHY_POLL, data[0], &status);
		if (ret)
			return ret;
	}

	return 0;
}
arch_initcall(of_add_fixed_phys);
- - - -

And remove fixed_phy_add() from the fs_enet. This should work
nicely and also should be ideologically correct. ;-)

> How is this supposed to work for modules or for the
> PPC_CPM_NEW_BINDING mode where the device tree is no longer scanned
> during fs_soc initialization but during device initialization?

We should mark fixed.c as bool. Fake/virtual/fixed/platform PHYs
creation is architecture code anyway, can't be =m.

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
