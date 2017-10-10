From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: ftgmac100: Request clock and set speed
Date: Tue, 10 Oct 2017 10:14:29 +0200
Message-ID: <1507623269.25065.202.camel@kernel.crashing.org>
References: <20171010044925.21078-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Jeffery <andrew@aj.id.au>
To: Joel Stanley <joel@jms.id.au>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010044925.21078-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-10 at 15:19 +1030, Joel Stanley wrote:
> According to the ASPEED datasheet, gigabit speeds require a clock of
> 100MHz or higher. Other speeds require 25MHz or higher.

Did you try "live" changing by either using ethtool or plugging into
switches/hubs at different speed ?

Also this is aspeed'isms, we should probably keep that under an
is_aspeed test.

My assumption is that we wouldn't bother, and just leave the freq
set based on whether there's a physical gigabit capable connection or
not (ie, real gigabit PHY vs. NC-SI really). But if it can help save a
few milliwatts..

> Signed-off-by: Joel Stanley <joel@jms.id.au>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 9ed8e4b81530..870ebd857978 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -21,6 +21,7 @@
>  
>  #define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt
>  
> +#include <linux/clk.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/etherdevice.h>
>  #include <linux/ethtool.h>
> @@ -59,6 +60,9 @@
>  /* Min number of tx ring entries before stopping queue */
>  #define TX_THRESHOLD		(MAX_SKB_FRAGS + 1)
>  
> +#define FTGMAC_100MHZ		100000000
> +#define FTGMAC_25MHZ		25000000
> +
>  struct ftgmac100 {
>  	/* Registers */
>  	struct resource *res;
> @@ -96,6 +100,7 @@ struct ftgmac100 {
>  	struct napi_struct napi;
>  	struct work_struct reset_task;
>  	struct mii_bus *mii_bus;
> +	struct clk *clk;
>  
>  	/* Link management */
>  	int cur_speed;
> @@ -142,18 +147,22 @@ static int ftgmac100_reset_mac(struct ftgmac100 *priv, u32 maccr)
>  static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
>  {
>  	u32 maccr = 0;
> +	int freq = 0;
>  
>  	switch (priv->cur_speed) {
>  	case SPEED_10:
>  	case 0: /* no link */
> +		freq = FTGMAC_25MHZ;
>  		break;
>  
>  	case SPEED_100:
>  		maccr |= FTGMAC100_MACCR_FAST_MODE;
> +		freq = FTGMAC_25MHZ;
>  		break;
>  
>  	case SPEED_1000:
>  		maccr |= FTGMAC100_MACCR_GIGA_MODE;
> +		freq = FTGMAC_100MHZ;
>  		break;
>  	default:
>  		netdev_err(priv->netdev, "Unknown speed %d !\n",
> @@ -161,6 +170,9 @@ static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
>  		break;
>  	}
>  
> +	if (freq && priv->clk)
> +		clk_set_rate(priv->clk, freq);
> +
>  	/* (Re)initialize the queue pointers */
>  	priv->rx_pointer = 0;
>  	priv->tx_clean_pointer = 0;
> @@ -1775,6 +1787,13 @@ static int ftgmac100_probe(struct platform_device *pdev)
>  	priv->dev = &pdev->dev;
>  	INIT_WORK(&priv->reset_task, ftgmac100_reset_task);
>  
> +	/* Enable clock if present */
> +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> +	if (!IS_ERR(priv->clk))
> +		clk_prepare_enable(priv->clk);
> +	else
> +		priv->clk = NULL;
> +
>  	/* map io memory */
>  	priv->res = request_mem_region(res->start, resource_size(res),
>  				       dev_name(&pdev->dev));
> @@ -1883,6 +1902,9 @@ static int ftgmac100_remove(struct platform_device *pdev)
>  
>  	unregister_netdev(netdev);
>  
> +	if (priv->clk)
> +		clk_disable_unprepare(priv->clk);
> +
>  	/* There's a small chance the reset task will have been re-queued,
>  	 * during stop, make sure it's gone before we free the structure.
>  	 */
