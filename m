From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCH 6/7 v2] fs_enet: Be an of_platform device when
 CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Tue, 21 Aug 2007 13:01:55 +0400
Message-ID: <20070821130155.43898b68@localhost.localdomain>
References: <20070817181718.GA15792@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58185 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153AbXHUJDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 05:03:03 -0400
In-Reply-To: <20070817181718.GA15792@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007 13:17:18 -0500
Scott Wood wrote:

> The existing OF glue code was crufty and broken.  Rather than fix it,
> it will be removed, and the ethernet driver now talks to the device
> tree directly.
> 
A bit short description, I'd rather expect some specific improvements list,
that are now up and running using device tree. Or if it is just move to new
infrastucture, let's state that, too.

Some other notes below.

> The old, non-CONFIG_PPC_CPM_NEW_BINDING code can go away once CPM
> platforms are dropped from arch/ppc (which will hopefully be soon),
> and existing arch/powerpc boards that I wasn't able to test on for
> this patchset get converted (which should be even sooner).
> 
> mii-bitbang.c now also uses the generic bitbang code.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
> Sorry, the previous version of this patch had bb_ops in the wrong
> place, and wouldn't build when not using the new binding.
> 
>  drivers/net/fs_enet/Kconfig        |    1 +
>  drivers/net/fs_enet/fs_enet-main.c |  286 ++++++++++++++++++++++--
>  drivers/net/fs_enet/fs_enet.h      |   55 +-----
>  drivers/net/fs_enet/mac-fcc.c      |   89 ++++++--
>  drivers/net/fs_enet/mac-fec.c      |   23 ++-
>  drivers/net/fs_enet/mac-scc.c      |   55 +++--
>  drivers/net/fs_enet/mii-bitbang.c  |  438
> ++++++++++++++++-------------------
> drivers/net/fs_enet/mii-fec.c      |  140 ++++++++++++-
> include/linux/fs_enet_pd.h         |    5 + 9 files changed, 740
> insertions(+), 352 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
> index e27ee21..2765e49 100644
> --- a/drivers/net/fs_enet/Kconfig
> +++ b/drivers/net/fs_enet/Kconfig
> @@ -11,6 +11,7 @@ config FS_ENET_HAS_SCC
>  config FS_ENET_HAS_FCC
>  	bool "Chip has an FCC usable for ethernet"
>  	depends on FS_ENET && CPM2
> +	select MDIO_BITBANG
>  	default y
>  
>  config FS_ENET_HAS_FEC
> diff --git a/drivers/net/fs_enet/fs_enet-main.c
> b/drivers/net/fs_enet/fs_enet-main.c index 0ec30a8..7bf29a2 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -44,12 +44,18 @@
>  #include <asm/irq.h>
>  #include <asm/uaccess.h>
>  
> +#ifdef CONFIG_PPC_CPM_NEW_BINDING
> +#include <linux/of_platform.h>
> +#endif
> +
>  #include "fs_enet.h"
>  
>  /*************************************************/
>  
> +#ifndef CONFIG_PPC_CPM_NEW_BINDING
>  static char version[] __devinitdata =
>      DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " ("
> DRV_MODULE_RELDATE ")" "\n"; +#endif
>  
>  MODULE_AUTHOR("Pantelis Antoniou <panto@intracom.gr>");
>  MODULE_DESCRIPTION("Freescale Ethernet Driver");
> @@ -953,6 +959,7 @@ static int fs_ioctl(struct net_device *dev,
> struct ifreq *rq, int cmd) extern int fs_mii_connect(struct
> net_device *dev); extern void fs_mii_disconnect(struct net_device
> *dev); 
> +#ifndef CONFIG_PPC_CPM_NEW_BINDING
>  static struct net_device *fs_init_instance(struct device *dev,
>  		struct fs_platform_info *fpi)
>  {
> @@ -1132,6 +1139,7 @@ static int fs_cleanup_instance(struct
> net_device *ndev) 
>  	return 0;
>  }
> +#endif
>  
>  /**************************************************************************************/
>  
> @@ -1140,35 +1148,279 @@ void *fs_enet_immap = NULL;
>  
>  static int setup_immap(void)
>  {
> -	phys_addr_t paddr = 0;
> -	unsigned long size = 0;
> -
>  #ifdef CONFIG_CPM1
> -	paddr = IMAP_ADDR;
> -	size = 0x10000;	/* map 64K */
> +#ifdef CONFIG_PPC_CPM_NEW_BINDING
> +	fs_enet_immap = mpc8xx_immr;
> +#else
> +	fs_enet_immap = ioremap(IMAP_ADDR, 0x4000);
> +	WARN_ON(!fs_enet_immap);
>  #endif
> -
> -#ifdef CONFIG_CPM2
> -	paddr = CPM_MAP_ADDR;
> -	size = 0x40000;	/* map 256 K */
> +#elif defined(CONFIG_CPM2)
> +	fs_enet_immap = cpm2_immr;
>  #endif
> -	fs_enet_immap = ioremap(paddr, size);
> -	if (fs_enet_immap == NULL)
> -		return -EBADF;	/* XXX ahem; maybe just
> BUG_ON? */ 
>  	return 0;
>  }
>  
> +#ifndef CONFIG_PPC_CPM_NEW_BINDING
>  static void cleanup_immap(void)
>  {
> -	if (fs_enet_immap != NULL) {
> -		iounmap(fs_enet_immap);
> -		fs_enet_immap = NULL;
> -	}
> +#if defined(CONFIG_CPM1)
> +	iounmap(fs_enet_immap);
> +#endif
>  }
> +#endif
>  
>  /**************************************************************************************/
>  
> +#ifdef CONFIG_PPC_CPM_NEW_BINDING
> +static int __devinit find_phy(struct device_node *np,
> +                              struct fs_platform_info *fpi)
> +{
> +	struct device_node *phynode, *mdionode;
> +	struct resource res;
> +	int ret = 0, len;
> +
> +	const u32 *data = of_get_property(np, "phy-handle", &len);
> +	if (!data || len != 4)
> +		return -EINVAL;
> +
> +	phynode = of_find_node_by_phandle(*data);
> +	if (!phynode)
> +		return -EINVAL;
> +
> +	mdionode = of_get_parent(phynode);
> +	if (!phynode)
> +		goto out_put_phy;
> +
> +	ret = of_address_to_resource(mdionode, 0, &res);
> +	if (ret)
> +		goto out_put_mdio;
> +
> +	data = of_get_property(phynode, "reg", &len);
> +	if (!data || len != 4)
> +		goto out_put_mdio;
> +
> +	snprintf(fpi->bus_id, 16, PHY_ID_FMT, res.start, *data);
> +
> +out_put_mdio:
> +	of_node_put(mdionode);
> +out_put_phy:
> +	of_node_put(phynode);
> +	return ret;
> +}
And without phy node? 


> +
> +#ifdef CONFIG_FS_ENET_HAS_FEC
> +#define IS_FEC(match) ((match)->data == &fs_fec_ops)
> +#else
> +#define IS_FEC(match) 0
> +#endif
> +

Since we're talking directly with device tree, why bother with CONFIG_ stuff? We are able to figure it out from dts..

> +static int __devinit fs_enet_probe(struct of_device *ofdev,
> +                                   const struct of_device_id *match)
> +{
> +	struct net_device *ndev;
> +	struct fs_enet_private *fep;
> +	struct fs_platform_info *fpi;
> +	const u32 *data;
> +	const u8 *mac_addr;
> +	int privsize, len, ret = -ENODEV;
> +
> +	fpi = kzalloc(sizeof(*fpi), GFP_KERNEL);
> +	if (!fpi)
> +		return -ENOMEM;
> +
> +	if (!IS_FEC(match)) {
> +		data = of_get_property(ofdev->node,
> "fsl,cpm-command", &len);
> +		if (!data || len != 4)
> +			goto out_free_fpi;
> +
> +		fpi->cp_command = *data;
> +	}
> +
> +	fpi->rx_ring = 32;
> +	fpi->tx_ring = 32;
> +	fpi->rx_copybreak = 240;
> +	fpi->use_napi = 0;
> +	fpi->napi_weight = 17;
> +

move params over to  dts?

> +	ret = find_phy(ofdev->node, fpi);
> +	if (ret)
> +		goto out_free_fpi;
> +
so we're hosed without phy node.

> +	privsize = sizeof(*fep) +
> +	           sizeof(struct sk_buff **) *
> +	           (fpi->rx_ring + fpi->tx_ring);
> +
> +	ndev = alloc_etherdev(privsize);
> +	if (!ndev) {
> +		ret = -ENOMEM;
> +		goto out_free_fpi;
> +	}
> +
> +	SET_MODULE_OWNER(ndev);
> +	dev_set_drvdata(&ofdev->dev, ndev);
> +
> +	fep = netdev_priv(ndev);
> +	fep->dev = &ofdev->dev;
> +	fep->fpi = fpi;
> +	fep->ops = match->data;
> +
> +	ret = fep->ops->setup_data(ndev);
> +	if (ret)
> +		goto out_free_dev;
> +
> +	fep->rx_skbuff = (struct sk_buff **)&fep[1];
> +	fep->tx_skbuff = fep->rx_skbuff + fpi->rx_ring;
> +
> +	spin_lock_init(&fep->lock);
> +	spin_lock_init(&fep->tx_lock);
> +
> +	mac_addr = of_get_mac_address(ofdev->node);
> +	if (mac_addr)
> +		memcpy(ndev->dev_addr, mac_addr, 6);
> +
> +	ret = fep->ops->allocate_bd(ndev);
> +	if (ret)
> +		goto out_cleanup_data;
> +
> +	fep->rx_bd_base = fep->ring_base;
> +	fep->tx_bd_base = fep->rx_bd_base + fpi->rx_ring;
> +
> +	fep->tx_ring = fpi->tx_ring;
> +	fep->rx_ring = fpi->rx_ring;
> +
> +	ndev->open = fs_enet_open;
> +	ndev->hard_start_xmit = fs_enet_start_xmit;
> +	ndev->tx_timeout = fs_timeout;
> +	ndev->watchdog_timeo = 2 * HZ;
> +	ndev->stop = fs_enet_close;
> +	ndev->get_stats = fs_enet_get_stats;
> +	ndev->set_multicast_list = fs_set_multicast_list;
> +	if (fpi->use_napi) {
> +		ndev->poll = fs_enet_rx_napi;
> +		ndev->weight = fpi->napi_weight;
> +	}
> +	ndev->ethtool_ops = &fs_ethtool_ops;
> +	ndev->do_ioctl = fs_ioctl;
> +
> +	init_timer(&fep->phy_timer_list);
> +
> +	netif_carrier_off(ndev);
> +
> +	ret = register_netdev(ndev);
> +	if (ret)
> +		goto out_free_bd;
> +
> +	printk(KERN_INFO "%s: fs_enet:
> %02x:%02x:%02x:%02x:%02x:%02x\n",
> +	       ndev->name,
> +	       ndev->dev_addr[0], ndev->dev_addr[1],
> ndev->dev_addr[2],
> +	       ndev->dev_addr[3], ndev->dev_addr[4],
> ndev->dev_addr[5]); +
> +	return 0;
> +
> +out_free_bd:
> +	fep->ops->free_bd(ndev);
> +out_cleanup_data:
> +	fep->ops->cleanup_data(ndev);
> +out_free_dev:
> +	free_netdev(ndev);
> +	dev_set_drvdata(&ofdev->dev, NULL);
> +out_free_fpi:
> +	kfree(fpi);
> +	return ret;
> +}
> +
> +static int fs_enet_remove(struct of_device *ofdev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
> +	struct fs_enet_private *fep = netdev_priv(ndev);
> +
> +	unregister_netdev(ndev);
> +
> +	fep->ops->free_bd(ndev);
> +	fep->ops->cleanup_data(ndev);
> +	dev_set_drvdata(fep->dev, NULL);
> +
> +	free_netdev(ndev);
> +	return 0;
> +}
> +
> +static struct of_device_id fs_enet_match[] = {
> +#ifdef CONFIG_FS_ENET_HAS_SCC

same nagging. Are we able to get rid of Kconfig arcane defining which SoC currently plays the game for fs_enet?

[snip]...

-- 
Sincerely, Vitaly
