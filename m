From: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 2/2] net: davinci_mdio: allow to create phys from dt
Date: Wed, 9 Jul 2014 10:23:34 -0400
Message-ID: <53BD5066.4000500@ti.com>
References: <1404911451-9921-1-git-send-email-grygorii.strashko@ti.com>
	<1404911451-9921-3-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
        "David S. Miller"
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1404911451-9921-3-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 July 2014 09:10 AM, Grygorii Strashko wrote:
> This patch allows to create PHYs from DT in case
> if they are explicitly defined. The of_mdiobus_register() is
> used for such purposes.
> 
> For backward compatibility, call  of_mdiobus_register() only in case
> if at least one PHY's child is defined in DT, otherwise rollback to
> mdiobus_register().
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
> ---
>  drivers/net/ethernet/ti/davinci_mdio.c |   18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 735dc53..22d3dab 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -38,6 +38,7 @@
>  #include <linux/davinci_emac.h>
>  #include <linux/of.h>
>  #include <linux/of_device.h>
> +#include <linux/of_mdio.h>
>  #include <linux/pinctrl/consumer.h>
>  
>  /*
> @@ -95,6 +96,7 @@ struct davinci_mdio_data {
>  	struct mii_bus	*bus;
>  	bool		suspended;
>  	unsigned long	access_time; /* jiffies */
> +	bool		skip_scan;
The vairiable name is not too intutive so probably add a little
bit description on what are you skipping with it.

>  };
>  
>  static void __davinci_mdio_reset(struct davinci_mdio_data *data)
> @@ -144,6 +146,9 @@ static int davinci_mdio_reset(struct mii_bus *bus)
>  	dev_info(data->dev, "davinci mdio revision %d.%d\n",
>  		 (ver >> 8) & 0xff, ver & 0xff);
>  
> +	if (data->skip_scan)
> +		return 0;
> +
>  	/* get phy mask from the alive register */
>  	phy_mask = __raw_readl(&data->regs->alive);
>  	if (phy_mask) {
> @@ -369,8 +374,17 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>  		goto bail_out;
>  	}
>  
> -	/* register the mii bus */
> -	ret = mdiobus_register(data->bus);
> +	/* register the mii bus
> +	 * Create PHYs from DT only in case if PHY child nodes are explicitly
> +	 * defined to support backward compatibility with DTs which assume that
> +	 * Davinci MDIO will always scan the bus for PHYs detection.
> +	 */
multi line comment is not as per coding style. Please fix that.
Patch as such looks good to me so with those minor fixes, feel
free to append my review tag.

Reviewed-by: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>

> +	if (dev->of_node && of_get_child_count(dev->of_node)) {
> +		data->skip_scan = true;
> +		ret = of_mdiobus_register(data->bus, dev->of_node);
> +	} else {
> +		ret = mdiobus_register(data->bus);
> +	}
>  	if (ret)
>  		goto bail_out;
>  
> 
