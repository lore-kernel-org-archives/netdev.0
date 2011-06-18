From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/3] net/fec: add device tree support
Date: Sat, 18 Jun 2011 10:22:20 -0600
Message-ID: <20110618162220.GI8195@ponder.secretlab.ca>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-3-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1308410354-21387-3-git-send-email-shawn.guo@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 11:19:13PM +0800, Shawn Guo wrote:
> It adds device tree data parsing support for fec driver.
> 
> Signed-off-by: Jason Liu <jason.hui@linaro.org>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt |   14 ++++++++++
>  drivers/net/fec.c                                 |   28 +++++++++++++++++++++
>  2 files changed, 42 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> new file mode 100644
> index 0000000..705111d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -0,0 +1,14 @@
> +* Freescale Fast Ethernet Controller (FEC)
> +
> +Required properties:
> +- compatible : should be "fsl,<soc>-fec", "fsl,fec"

Ditto to comment on last patch.  "fsl,fec" is to generic.
"fsl,imx51-soc" should be the generic value.

Otherwise looks okay to me, and I don't see any problem with queueing
it up for v3.1 with that change since it doesn't depend on any other
patches.

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> +- reg : address and length of the register set for the device
> +- interrupts : should contain fec interrupt
> +
> +Example:
> +
> +fec@83fec000 {
> +	compatible = "fsl,imx51-fec", "fsl,fec";
> +	reg = <0x83fec000 0x4000>;
> +	interrupts = <87>;
> +};
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 885d8ba..ef3d175 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -44,6 +44,8 @@
>  #include <linux/platform_device.h>
>  #include <linux/phy.h>
>  #include <linux/fec.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
>  
>  #include <asm/cacheflush.h>
>  
> @@ -78,6 +80,26 @@ static struct platform_device_id fec_devtype[] = {
>  	{ }
>  };
>  
> +#ifdef CONFIG_OF
> +static const struct of_device_id fec_dt_ids[] = {
> +	{ .compatible = "fsl,fec", .data = &fec_devtype[0], },
> +	{},
> +};
> +
> +static const struct of_device_id *
> +fec_get_of_device_id(struct platform_device *pdev)
> +{
> +	return of_match_device(fec_dt_ids, &pdev->dev);
> +}
> +#else
> +#define fec_dt_ids NULL
> +static inline struct of_device_id *
> +fec_get_of_device_id(struct platform_device *pdev)
> +{
> +	return NULL;
> +}
> +#endif
> +
>  static unsigned char macaddr[ETH_ALEN];
>  module_param_array(macaddr, byte, NULL, 0);
>  MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
> @@ -1363,6 +1385,11 @@ fec_probe(struct platform_device *pdev)
>  	struct net_device *ndev;
>  	int i, irq, ret = 0;
>  	struct resource *r;
> +	const struct of_device_id *of_id;
> +
> +	of_id = fec_get_of_device_id(pdev);
> +	if (of_id)
> +		pdev->id_entry = (struct platform_device_id *) of_id->data;
>  
>  	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	if (!r)
> @@ -1531,6 +1558,7 @@ static struct platform_driver fec_driver = {
>  #ifdef CONFIG_PM
>  		.pm	= &fec_pm_ops,
>  #endif
> +		.of_match_table = fec_dt_ids,
>  	},
>  	.id_table = fec_devtype,
>  	.probe	= fec_probe,
> -- 
> 1.7.4.1
> 
> _______________________________________________
> devicetree-discuss mailing list
> devicetree-discuss@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/devicetree-discuss
