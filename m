From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] phylib: Fix Freescale TBI PHY detection
Date: Wed, 14 Jan 2009 18:03:32 +0300
Message-ID: <20090114150332.GA839__8603.49835497818$1231945597$gmane$org@oksana.dev.rtsoft.ru>
References: <20090113160513.GA22083@oksana.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Giulio Benetti <giulio.benetti@micronovasrl.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090113160513.GA22083@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2009 at 07:05:13PM +0300, Anton Vorontsov wrote:
> Freescale on-chip TBI PHYs reports PHY ID as 0x0, but as of
> 
> commit 3ee82383f0098a2e13acc8cf1be8e47512f41e5a
> Author: Giulio Benetti <giulio.benetti@micronovasrl.com>
> Date:   Thu Nov 13 21:53:13 2008 +0000
> 
>     phy: fix phy address bug
> 
>     PHYID returns 0xffff and not 0xffffffff when not found and in some
>     case(at91sam9263) 0x0. Maybe this patch could be useful.
> 
> phy_device.c treats PHY ID == 0x0 as bogus IDs, and that results in
> gianfar driver failure to see the TBI PHYs. This code snippet triggers:
> 
> 	if (!priv->tbiphy) {
> 		printk(KERN_WARNING "SGMII mode requires that the device "
> 				"tree specify a tbi-handle\n");
> 		return;
> 	}
> 
> Although tbi-handle is specified in the device tree.
> 
> Btw, technically PHY ID == 0x0 is a valid ID (if we ever see a PHY
> manufactured by Xerox :-).
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> 
> There is one thing I don't actually understand though...
> 
> Andy, were you testing the TBI support on a hardware where PHY ID
> != 0x0 or maybe your TBI PHY support patch (commit b31a1d8b41513b,
> dated Tue Dec 16 15:29:15 2008) was based on a bit outdated kernel
> version? Because according to the git timestamps, the TBI support
> was not working since the submission.
> 
> Just in case, the hardware I'm seeing the PHY ID == 0x0 is
> MPC8378E-MDS.

I think I got it. Probably the TBI support patch was based on the
powerpc.git next, and the commit that broke the TBI support
was in the net-next-2.6 tree.

That explains why nobody noticed the issue.

>  drivers/net/phy/phy_device.c |    9 ---------
>  1 files changed, 0 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index e354601..0a06e4f 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -231,15 +231,6 @@ struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
>  	if ((phy_id & 0x1fffffff) == 0x1fffffff)
>  		return NULL;
>  
> -	/*
> -	 * Broken hardware is sometimes missing the pull-up resistor on the
> -	 * MDIO line, which results in reads to non-existent devices returning
> -	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
> -	 * device as well.
> -	 */
> -	if (phy_id == 0)
> -		return NULL;
> -
>  	dev = phy_device_create(bus, addr, phy_id);
>  
>  	return dev;
> -- 
> 1.5.6.5
