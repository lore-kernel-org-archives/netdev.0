From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] sh: sh_eth: Add support ethtool
Date: Tue, 11 Jan 2011 15:57:06 +0000
Message-ID: <1294761426.3637.8.camel@bwh-desktop>
References: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	yoshihiro.shimoda.uh@renesas.com
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-01-11 at 20:58 +0900, nobuhiro.iwamatsu.yj@renesas.com
wrote:
> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> 
> This commit supports following functions.
>  - get_drvinfo
>  - get_settings
>  - set_settings
>  - nway_reset
>  - get_msglevel
>  - set_msglevel
>  - get_link
>  - get_strings
>  - get_ethtool_stats
>  - get_sset_count
> 
> About other function, the device does not support.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
>  v2: reverted one part of the checks of checkpatch.pl.
>        foo *bar -> foo * bar.
> 	 changed function copying of net_device_stats from *for* to memcopy.
>  
>  drivers/net/sh_eth.c |  186 ++++++++++++++++++++++++++++++++++++++++++++++---
>  1 files changed, 174 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
> index 819c175..0b2cb7d 100644
> --- a/drivers/net/sh_eth.c
> +++ b/drivers/net/sh_eth.c
[...]
> @@ -1063,6 +1074,154 @@ static int sh_eth_phy_start(struct net_device *ndev)
>  	return 0;
>  }
>  
> +static void sh_eth_get_drvinfo(struct net_device *ndev,
> +			struct ethtool_drvinfo *info)
> +{
> +	strncpy(info->driver, "sh_eth", sizeof(info->driver) - 1);
> +	strcpy(info->version, "N/A");
> +	strcpy(info->fw_version, "N/A");
> +	strlcpy(info->bus_info, dev_name(ndev->dev.parent),
> +		sizeof(info->bus_info));
> +}

This is redundant; the default implementation already does this.

[...]
> +static int sh_eth_set_settings(struct net_device *ndev,
> +		struct ethtool_cmd *ecmd)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	unsigned long flags;
> +	int ret;
> +	u32 ioaddr = ndev->base_addr;
> +
> +	spin_lock_irqsave(&mdp->lock, flags);
> +
> +	/* disable tx and rx */
> +	sh_eth_linkdown(ioaddr);
> +
> +	ret = phy_ethtool_sset(mdp->phydev, ecmd);
> +	if (ret)
> +		goto error_exit;
> +
> +	if (ecmd->duplex == DUPLEX_FULL)
> +		mdp->duplex = 1;
> +	else
> +		mdp->duplex = 0;
> +
> +	if (mdp->cd->set_duplex)
> +		mdp->cd->set_duplex(ndev);
> +
> +error_exit:
> +	mdelay(100);

Ugh, 100 ms holding a spinlock?!

> +	/* enable tx and rx */
> +	sh_eth_linkup(ioaddr);

How do you know the link is up?  Shouldn't this be left to the link
polling function?

[...]
> +static u32 sh_eth_get_msglevel(struct net_device *ndev)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	return mdp->msg_enable;
> +}
> +
> +static void sh_eth_set_msglevel(struct net_device *ndev, u32 value)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	mdp->msg_enable = value;
> +}

This would be more useful if msg_enable was actually used anywhere in
the driver.

[...]
> @@ -1073,8 +1232,8 @@ static int sh_eth_open(struct net_device *ndev)
>  
>  	ret = request_irq(ndev->irq, sh_eth_interrupt,
>  #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
> -    defined(CONFIG_CPU_SUBTYPE_SH7764) || \
> -    defined(CONFIG_CPU_SUBTYPE_SH7757)
> +	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
> +	defined(CONFIG_CPU_SUBTYPE_SH7757)
>  				IRQF_SHARED,
>  #else
>  				0,
> @@ -1232,11 +1391,11 @@ static int sh_eth_close(struct net_device *ndev)
>  	sh_eth_ring_free(ndev);
>  
>  	/* free DMA buffer */
> -	ringsize = sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
> +	ringsize = sizeof(struct sh_eth_rxdesc) *RX_RING_SIZE;
>  	dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_desc_dma);
>  
>  	/* free DMA buffer */
> -	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
> +	ringsize = sizeof(struct sh_eth_txdesc) *TX_RING_SIZE;
>  	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
>  
>  	pm_runtime_put_sync(&mdp->pdev->dev);

Please do not include these space changes.

> @@ -1497,8 +1656,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  
>  	/* set function */
>  	ndev->netdev_ops = &sh_eth_netdev_ops;
> +	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
>  	ndev->watchdog_timeo = TX_TIMEOUT;
>  
> +	/* debug message level */
> +	mdp->msg_enable = (1 << 3) - 1;

If you're actually going to *use* msg_enable, its value should be
initialised in terms of the NETIF_MSG_* flags defined in
<linux/netdevice.h>.

>  	mdp->post_rx = POST_RX >> (devno << 1);
>  	mdp->post_fw = POST_FW >> (devno << 1);
>  
> @@ -1572,7 +1734,7 @@ static int sh_eth_runtime_nop(struct device *dev)
>  	return 0;
>  }
>  
> -static struct dev_pm_ops sh_eth_dev_pm_ops = {
> +static const struct dev_pm_ops sh_eth_dev_pm_ops = {
>  	.runtime_suspend = sh_eth_runtime_nop,
>  	.runtime_resume = sh_eth_runtime_nop,
>  };

This is worthwhile but unrelated to ethtool!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

