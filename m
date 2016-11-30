From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH net 04/16] net: ethernet: aurora: nb8800: fix fixed-link
 phydev leaks
Date: Wed, 30 Nov 2016 10:36:45 +0100
Message-ID: <583E9DAD.8090205@free.fr>
References: <1480357509-28074-1-git-send-email-johan@kernel.org>
 <1480357509-28074-5-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>,
        Brian Norris <computersforpeace@gmail.com>
To: Johan Hovold <johan@kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480357509-28074-5-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/11/2016 19:24, Johan Hovold wrote:

> Make sure to deregister and free any fixed-link PHY registered using
> of_phy_register_fixed_link() on probe errors and on driver unbind.
> 
> Fixes: c7dfe3abf40e ("net: ethernet: nb8800: support fixed-link DT node")
> Signed-off-by: Johan Hovold <johan@kernel.org>
> ---
>  drivers/net/ethernet/aurora/nb8800.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)

Did you use scripts/get_maintainer.pl ?

Neither the author of the driver (Mans) nor the author of
the code in question (Sebastian) were CCed on this patch.

It looks like the CC list was truncated, the last entry being

  Vivien Didelot <

Regards.


> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index 00c38bf151e6..e078d8da978c 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1466,12 +1466,12 @@ static int nb8800_probe(struct platform_device *pdev)
>  
>  	ret = nb8800_hw_init(dev);
>  	if (ret)
> -		goto err_free_bus;
> +		goto err_deregister_fixed_link;
>  
>  	if (ops && ops->init) {
>  		ret = ops->init(dev);
>  		if (ret)
> -			goto err_free_bus;
> +			goto err_deregister_fixed_link;
>  	}
>  
>  	dev->netdev_ops = &nb8800_netdev_ops;
> @@ -1504,6 +1504,9 @@ static int nb8800_probe(struct platform_device *pdev)
>  
>  err_free_dma:
>  	nb8800_dma_free(dev);
> +err_deregister_fixed_link:
> +	if (of_phy_is_fixed_link(pdev->dev.of_node))
> +		of_phy_deregister_fixed_link(pdev->dev.of_node);
>  err_free_bus:
>  	of_node_put(priv->phy_node);
>  	mdiobus_unregister(bus);
> @@ -1521,6 +1524,8 @@ static int nb8800_remove(struct platform_device *pdev)
>  	struct nb8800_priv *priv = netdev_priv(ndev);
>  
>  	unregister_netdev(ndev);
> +	if (of_phy_is_fixed_link(pdev->dev.of_node))
> +		of_phy_deregister_fixed_link(pdev->dev.of_node);
>  	of_node_put(priv->phy_node);
>  
>  	mdiobus_unregister(priv->mii_bus);
