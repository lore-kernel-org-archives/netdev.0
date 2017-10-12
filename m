From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2] net: ftgmac100: Request clock and set speed
Date: Thu, 12 Oct 2017 20:20:12 +0200
Message-ID: <1507832412.25065.250.camel@kernel.crashing.org>
References: <20171012033201.12845-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Jeffery <andrew@aj.id.au>
To: Joel Stanley <joel@jms.id.au>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012033201.12845-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-10-12 at 11:32 +0800, Joel Stanley wrote:
> According to the ASPEED datasheet, gigabit speeds require a clock of
> 100MHz or higher. Other speeds require 25MHz or higher. This patch
> configures a 100MHz clock if the system has a direct-attached
> PHY, or 25MHz if the system is running NC-SI which is limited to 100MHz.
> 
> There appear to be no other upstream users of the FTGMAC100 driver so it
> is hard to know the clocking requirements of other platforms. Therefore
> a conservative approach was taken with enabling clocks. If the platform
> is not ASPEED, both requesting the clock and configuring the speed is
> skipped.

We might still be able to check the PHY capabilities and it might also
be possible to do the live change as you were doing previously but it
needs testing. So I'm ok with this patch for now, and later I might be
able to try the live change option on the eval board (provided I still
have one) when I come back to Australia.

> Signed-off-by: Joel Stanley <joel@jms.id.au>
> ---
> Andrew, as I'm travelling can you please test this on the evb and a
> palmetto? Use my wip/aspeed-v4.14-clk branch, or OpenBMC's dev-4.13.
> 
> David, please wait for Andrew's tested-by before applying.
> 
> Cheers!
> 
> v2:
>  - only touch the clocks on Aspeed platforms
>  - unconditionally call clk_unprepare_disable
> 
>  drivers/net/ethernet/faraday/ftgmac100.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
> 
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 9ed8e4b81530..cd352bf41da1 100644
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
> @@ -1734,6 +1739,22 @@ static void ftgmac100_ncsi_handler(struct ncsi_dev *nd)
>  		    nd->link_up ? "up" : "down");
>  }
>  
> +static void ftgmac100_setup_clk(struct ftgmac100_priv *priv)
> +{
> +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(priv->clk))
> +		return;
> +
> +	clk_prepare_enable(priv->clk);
> +
> +	/* Aspeed specifies a 100MHz clock is required for up to
> +	 * 1000Mbit link speeds. As NCSI is limited to 100Mbit, 25MHz
> +	 * is sufficient
> +	 */
> +	clk_set_rate(priv->clk, priv->is_ncsi ? FTGMAC_25MHZ :
> +			FTGMAC_100MHZ);
> +}
> +
>  static int ftgmac100_probe(struct platform_device *pdev)
>  {
>  	struct resource *res;
> @@ -1830,6 +1851,9 @@ static int ftgmac100_probe(struct platform_device *pdev)
>  			goto err_setup_mdio;
>  	}
>  
> +	if (priv->is_aspeed)
> +		ftgmac100_setup_clk(priv);
> +
>  	/* Default ring sizes */
>  	priv->rx_q_entries = priv->new_rx_q_entries = DEF_RX_QUEUE_ENTRIES;
>  	priv->tx_q_entries = priv->new_tx_q_entries = DEF_TX_QUEUE_ENTRIES;
> @@ -1883,6 +1907,8 @@ static int ftgmac100_remove(struct platform_device *pdev)
>  
>  	unregister_netdev(netdev);
>  
> +	clk_disable_unprepare(priv->clk);
> +
>  	/* There's a small chance the reset task will have been re-queued,
>  	 * during stop, make sure it's gone before we free the structure.
>  	 */
