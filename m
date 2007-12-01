From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY
 layer functionality
Date: Sat, 1 Dec 2007 22:07:02 +0300
Message-ID: <20071201220702.5b9e9b4d@kernel.crashing.org>
References: <20071126142906.19642.45540.stgit@localhost.localdomain>
	<47516646.9000803@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Scott Wood <scottwood@freescale.com>
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41582 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbXLATH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 14:07:29 -0500
In-Reply-To: <47516646.9000803@scram.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 01 Dec 2007 14:48:54 +0100
Jochen Friedrich wrote:

> Hi Vitaly,
> 
> > With that patch fixed.c now fully emulates MDIO bus, thus no need
> > to duplicate PHY layer functionality. That, in turn, drastically
> > simplifies the code, and drops down line count.
> >
> > As an additional bonus, now there is no need to register MDIO bus
> > for each PHY, all emulated PHYs placed on the platform fixed MDIO
> > bus. There is also no more need to pre-allocate PHYs via .config
> > option, this is all now handled dynamically.
> >
> > p.s. Don't even try to understand patch content! Better: apply patch
> > and look into resulting drivers/net/phy/fixed.c.
> >   
> If i understand your code correctly, you seem to rely on the fact 
> that fixed_phy_add() is called before the fixed MDIO bus is scanned
> for devices. How is this supposed to work for modules or for the 
> PPC_CPM_NEW_BINDING mode where the device tree is no longer scanned 
> during fs_soc initialization but during device initialization?
>
Well, this is kind of known issue - to work it around for now, place PHY lib after fs_enet in
Makefile. This way it works for me for _NEW_BINDING and mpc866ads.

> I tried to add fixed-phy support to fs_enet, but the fixed phy is not 
> found this way.
> 
The point is I have the code and it works now(for fs_enet etc.), but I need to find the way for the fixed phy pinning to work in either order with phylib. If you have ideas, please go ahead :)


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
> @@ -1174,8 +1175,24 @@ static int __devinit find_phy(struct
> device_node *np, struct device_node *phynode, *mdionode;
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
> 
> Thanks,
> Jochen


-- 
Sincerely, Vitaly
