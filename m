From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: Re: [PATCH v4 1/3] can: sja1000: of: add per-compatible init hook
Date: Wed, 13 Jan 2016 10:57:49 -0500
Message-ID: <20160113155749.GB6219@localhost>
References: <1452685566-27431-1-git-send-email-mkl@pengutronix.de>
 <1452685566-27431-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452685566-27431-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Wed, Jan 13, 2016 at 12:46:04PM +0100, Marc Kleine-Budde wrote:
> From: Damien Riegel <damien.riegel@savoirfairelinux.com>
> 
> This commit adds the capability to allocate and init private data
> embedded in the sja1000_priv structure on a per-compatible basis. The
> device node is passed as a parameter of the init callback to allow
> parsing of custom device tree properties.
> 
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

I tested your serie and am okay with your changes. Just a minor comment
below, feel free to ignore it if you disagree.

> ---
>  drivers/net/can/sja1000/sja1000_platform.c | 42 +++++++++++++++++++++++-------
>  1 file changed, 33 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
> index 0552ed46a206..46378c9dbb29 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -27,6 +27,7 @@
>  #include <linux/can/platform/sja1000.h>
>  #include <linux/io.h>
>  #include <linux/of.h>
> +#include <linux/of_device.h>
>  #include <linux/of_irq.h>
>  
>  #include "sja1000.h"
> @@ -40,6 +41,11 @@ MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
>  MODULE_ALIAS("platform:" DRV_NAME);
>  MODULE_LICENSE("GPL v2");
>  
> +struct sja1000_of_data {
> +	size_t  priv_sz;
> +	int     (*init)(struct sja1000_priv *priv, struct device_node *of);
> +};
> +
>  static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
>  {
>  	return ioread8(priv->reg_base + reg);
> @@ -154,6 +160,14 @@ static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
>  		priv->cdr |= CDR_CBP; /* default */
>  }
>  
> +static struct sja1000_of_data nxp_data;
> +
> +static const struct of_device_id sp_of_table[] = {
> +	{ .compatible = "nxp,sja1000", .data = &nxp_data },
> +	{ /* sentinel */ },
> +};
> +MODULE_DEVICE_TABLE(of, sp_of_table);
> +
>  static int sp_probe(struct platform_device *pdev)
>  {
>  	int err, irq = 0;
> @@ -163,6 +177,9 @@ static int sp_probe(struct platform_device *pdev)
>  	struct resource *res_mem, *res_irq = NULL;
>  	struct sja1000_platform_data *pdata;
>  	struct device_node *of = pdev->dev.of_node;
> +	const struct of_device_id *of_id;
> +	const struct sja1000_of_data *of_data = NULL;
> +	size_t priv_sz = 0;
>  
>  	pdata = dev_get_platdata(&pdev->dev);
>  	if (!pdata && !of) {
> @@ -191,7 +208,13 @@ static int sp_probe(struct platform_device *pdev)
>  	if (!irq && !res_irq)
>  		return -ENODEV;
>  
> -	dev = alloc_sja1000dev(0);
> +	of_id = of_match_device(sp_of_table, &pdev->dev);
> +	if (of_id) {

My personal preference here would be to test of_id && of_id->data. That
way, we could avoid the declaration of nxp_data. It would also be a bit
less error prone if someone adds a new compatible in the of device
table.

Thanks,
Damien

> +		of_data = of_id->data;
> +		priv_sz = of_data->priv_sz;
> +	}
> +
> +	dev = alloc_sja1000dev(priv_sz);
>  	if (!dev)
>  		return -ENOMEM;
>  	priv = netdev_priv(dev);
> @@ -208,10 +231,17 @@ static int sp_probe(struct platform_device *pdev)
>  	dev->irq = irq;
>  	priv->reg_base = addr;
>  
> -	if (of)
> +	if (of) {
>  		sp_populate_of(priv, of);
> -	else
> +
> +		if (of_data->init) {
> +			err = of_data->init(priv, of);
> +			if (err)
> +				goto exit_free;
> +		}
> +	} else {
>  		sp_populate(priv, pdata, res_mem->flags);
> +	}
>  
>  	platform_set_drvdata(pdev, dev);
>  	SET_NETDEV_DEV(dev, &pdev->dev);
> @@ -242,12 +272,6 @@ static int sp_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> -static const struct of_device_id sp_of_table[] = {
> -	{.compatible = "nxp,sja1000"},
> -	{},
> -};
> -MODULE_DEVICE_TABLE(of, sp_of_table);
> -
>  static struct platform_driver sp_driver = {
>  	.probe = sp_probe,
>  	.remove = sp_remove,
> -- 
> 2.6.4
> 
