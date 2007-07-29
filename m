From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ethtool_perm_addr only has one implementation
Date: Sun, 29 Jul 2007 13:39:57 -0700
Message-ID: <46ACFB1D.9010101@intel.com>
References: <20070729200815.GB21219@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35624 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933894AbXG2Uk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 16:40:28 -0400
In-Reply-To: <20070729200815.GB21219@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> All drivers implement ethtool get_perm_addr the same way -- by calling
> the generic function.  So we can inline the generic function into the
> caller and avoid going through the drivers.
> 
> Signed-off-by: Matthew Wilcox <matthew@wil.cx>

For the e100, e1000, ixgb parts:

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>


> 
> diff -u b/net/core/ethtool.c b/net/core/ethtool.c
> --- b/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -95,18 +95,6 @@
>  	return 0;
>  }
>  
> -int ethtool_op_get_perm_addr(struct net_device *dev, struct ethtool_perm_addr *addr, u8 *data)
> -{
> -	unsigned char len = dev->addr_len;
> -	if ( addr->size < len )
> -		return -ETOOSMALL;
> -
> -	addr->size = len;
> -	memcpy(data, dev->perm_addr, len);
> -	return 0;
> -}
> -
> -
>  u32 ethtool_op_get_ufo(struct net_device *dev)
>  {
>  	return (dev->features & NETIF_F_UFO) != 0;
> @@ -779,34 +767,20 @@
>  static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
>  {
>  	struct ethtool_perm_addr epaddr;
> -	u8 *data;
> -	int ret;
>  
> -	if (!dev->ethtool_ops->get_perm_addr)
> -		return -EOPNOTSUPP;
> -
> -	if (copy_from_user(&epaddr,useraddr,sizeof(epaddr)))
> +	if (copy_from_user(&epaddr, useraddr, sizeof(epaddr)))
>  		return -EFAULT;
>  
> -	data = kmalloc(epaddr.size, GFP_USER);
> -	if (!data)
> -		return -ENOMEM;
> -
> -	ret = dev->ethtool_ops->get_perm_addr(dev,&epaddr,data);
> -	if (ret)
> -		return ret;
> +	if (epaddr.size < dev->addr_len)
> +		return -ETOOSMALL;
> +	epaddr.size = dev->addr_len;
>  
> -	ret = -EFAULT;
>  	if (copy_to_user(useraddr, &epaddr, sizeof(epaddr)))
> -		goto out;
> +		return -EFAULT;
>  	useraddr += sizeof(epaddr);
> -	if (copy_to_user(useraddr, data, epaddr.size))
> -		goto out;
> -	ret = 0;
> -
> - out:
> -	kfree(data);
> -	return ret;
> +	if (copy_to_user(useraddr, dev->perm_addr, epaddr.size))
> +		return -EFAULT;
> +	return 0;
>  }
>  
>  /* The main entry point in this file.  Called from net/core/dev.c */
> @@ -976,7 +950,6 @@
>  
>  EXPORT_SYMBOL(dev_ethtool);
>  EXPORT_SYMBOL(ethtool_op_get_link);
> -EXPORT_SYMBOL_GPL(ethtool_op_get_perm_addr);
>  EXPORT_SYMBOL(ethtool_op_get_sg);
>  EXPORT_SYMBOL(ethtool_op_get_tso);
>  EXPORT_SYMBOL(ethtool_op_get_tx_csum);
> only in patch2:
> unchanged:
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -2886,7 +2886,6 @@ static const struct ethtool_ops vortex_ethtool_ops = {
>  	.set_settings           = vortex_set_settings,
>  	.get_link               = ethtool_op_get_link,
>  	.nway_reset             = vortex_nway_reset,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  #ifdef CONFIG_PCI
> only in patch2:
> unchanged:
> --- a/drivers/net/8139cp.c
> +++ b/drivers/net/8139cp.c
> @@ -1578,7 +1578,6 @@ static const struct ethtool_ops cp_ethtool_ops = {
>  	.set_wol		= cp_set_wol,
>  	.get_strings		= cp_get_strings,
>  	.get_ethtool_stats	= cp_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  	.get_eeprom_len		= cp_get_eeprom_len,
>  	.get_eeprom		= cp_get_eeprom,
>  	.set_eeprom		= cp_set_eeprom,
> only in patch2:
> unchanged:
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -2452,7 +2452,6 @@ static const struct ethtool_ops rtl8139_ethtool_ops = {
>  	.get_strings		= rtl8139_get_strings,
>  	.get_stats_count	= rtl8139_get_stats_count,
>  	.get_ethtool_stats	= rtl8139_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> only in patch2:
> unchanged:
> --- a/drivers/net/ax88796.c
> +++ b/drivers/net/ax88796.c
> @@ -580,7 +580,6 @@ static const struct ethtool_ops ax_ethtool_ops = {
>  	.set_settings		= ax_set_settings,
>  	.nway_reset		= ax_nway_reset,
>  	.get_link		= ax_get_link,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  /* setup code */
> only in patch2:
> unchanged:
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -2033,7 +2033,6 @@ static const struct ethtool_ops b44_ethtool_ops = {
>  	.get_strings		= b44_get_strings,
>  	.get_stats_count	= b44_get_stats_count,
>  	.get_ethtool_stats	= b44_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static int b44_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> only in patch2:
> unchanged:
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6269,7 +6269,6 @@ static const struct ethtool_ops bnx2_ethtool_ops = {
>  	.phys_id		= bnx2_phys_id,
>  	.get_stats_count	= bnx2_get_stats_count,
>  	.get_ethtool_stats	= bnx2_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  /* Called with rtnl_lock */
> only in patch2:
> unchanged:
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -1583,7 +1583,6 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
>  	.get_wol = get_wol,
>  	.get_tso = ethtool_op_get_tso,
>  	.set_tso = ethtool_op_set_tso,
> -	.get_perm_addr = ethtool_op_get_perm_addr
>  };
>  
>  static int in_range(int val, int lo, int hi)
> only in patch2:
> unchanged:
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -2506,7 +2506,6 @@ static const struct ethtool_ops e100_ethtool_ops = {
>  	.phys_id		= e100_phys_id,
>  	.get_stats_count	= e100_get_stats_count,
>  	.get_ethtool_stats	= e100_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static int e100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
> only in patch2:
> unchanged:
> --- a/drivers/net/e1000/e1000_ethtool.c
> +++ b/drivers/net/e1000/e1000_ethtool.c
> @@ -1973,7 +1973,6 @@ static const struct ethtool_ops e1000_ethtool_ops = {
>  	.phys_id                = e1000_phys_id,
>  	.get_stats_count        = e1000_get_stats_count,
>  	.get_ethtool_stats      = e1000_get_ethtool_stats,
> -	.get_perm_addr          = ethtool_op_get_perm_addr,
>  };
>  
>  void e1000_set_ethtool_ops(struct net_device *netdev)
> only in patch2:
> unchanged:
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -4706,7 +4706,6 @@ static const struct ethtool_ops ops = {
>  	.get_regs_len = nv_get_regs_len,
>  	.get_regs = nv_get_regs,
>  	.nway_reset = nv_nway_reset,
> -	.get_perm_addr = ethtool_op_get_perm_addr,
>  	.get_tso = ethtool_op_get_tso,
>  	.set_tso = nv_set_tso,
>  	.get_ringparam = nv_get_ringparam,
> only in patch2:
> unchanged:
> --- a/drivers/net/ixgb/ixgb_ethtool.c
> +++ b/drivers/net/ixgb/ixgb_ethtool.c
> @@ -724,7 +724,6 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
>  	.phys_id = ixgb_phys_id,
>  	.get_stats_count = ixgb_get_stats_count,
>  	.get_ethtool_stats = ixgb_get_ethtool_stats,
> -	.get_perm_addr = ethtool_op_get_perm_addr,
>  };
>  
>  void ixgb_set_ethtool_ops(struct net_device *netdev)
> only in patch2:
> unchanged:
> --- a/drivers/net/ne2k-pci.c
> +++ b/drivers/net/ne2k-pci.c
> @@ -638,7 +638,6 @@ static const struct ethtool_ops ne2k_pci_ethtool_ops = {
>  	.get_drvinfo		= ne2k_pci_get_drvinfo,
>  	.get_tx_csum		= ethtool_op_get_tx_csum,
>  	.get_sg			= ethtool_op_get_sg,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static void __devexit ne2k_pci_remove_one (struct pci_dev *pdev)
> only in patch2:
> unchanged:
> --- a/drivers/net/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/netxen/netxen_nic_ethtool.c
> @@ -755,5 +755,4 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
>  	.get_strings = netxen_nic_get_strings,
>  	.get_stats_count = netxen_nic_get_stats_count,
>  	.get_ethtool_stats = netxen_nic_get_ethtool_stats,
> -	.get_perm_addr = ethtool_op_get_perm_addr,
>  };
> only in patch2:
> unchanged:
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -1515,7 +1515,6 @@ static const struct ethtool_ops pcnet32_ethtool_ops = {
>  	.phys_id		= pcnet32_phys_id,
>  	.get_regs_len		= pcnet32_get_regs_len,
>  	.get_regs		= pcnet32_get_regs,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  /* only probes for non-PCI devices, the rest are handled by
> only in patch2:
> unchanged:
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -1904,7 +1904,6 @@ static void ql_get_pauseparam(struct net_device *ndev,
>  static const struct ethtool_ops ql3xxx_ethtool_ops = {
>  	.get_settings = ql_get_settings,
>  	.get_drvinfo = ql_get_drvinfo,
> -	.get_perm_addr = ethtool_op_get_perm_addr,
>  	.get_link = ethtool_op_get_link,
>  	.get_msglevel = ql_get_msglevel,
>  	.set_msglevel = ql_set_msglevel,
> only in patch2:
> unchanged:
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1066,7 +1066,6 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
>  	.get_strings		= rtl8169_get_strings,
>  	.get_stats_count	= rtl8169_get_stats_count,
>  	.get_ethtool_stats	= rtl8169_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg,
> only in patch2:
> unchanged:
> --- a/drivers/net/sc92031.c
> +++ b/drivers/net/sc92031.c
> @@ -1402,7 +1402,6 @@ static struct ethtool_ops sc92031_ethtool_ops = {
>  	.get_strings		= sc92031_ethtool_get_strings,
>  	.get_stats_count	= sc92031_ethtool_get_stats_count,
>  	.get_ethtool_stats	= sc92031_ethtool_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  	.get_ufo		= ethtool_op_get_ufo,
>  };
>  
> only in patch2:
> unchanged:
> --- a/drivers/net/skge.c
> +++ b/drivers/net/skge.c
> @@ -821,7 +821,6 @@ static const struct ethtool_ops skge_ethtool_ops = {
>  	.phys_id	= skge_phys_id,
>  	.get_stats_count = skge_get_stats_count,
>  	.get_ethtool_stats = skge_get_ethtool_stats,
> -	.get_perm_addr	= ethtool_op_get_perm_addr,
>  };
>  
>  /*
> only in patch2:
> unchanged:
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -3548,7 +3548,6 @@ static const struct ethtool_ops sky2_ethtool_ops = {
>  	.phys_id	= sky2_phys_id,
>  	.get_stats_count = sky2_get_stats_count,
>  	.get_ethtool_stats = sky2_get_ethtool_stats,
> -	.get_perm_addr	= ethtool_op_get_perm_addr,
>  };
>  
>  #ifdef CONFIG_SKY2_DEBUG
> only in patch2:
> unchanged:
> --- a/drivers/net/sundance.c
> +++ b/drivers/net/sundance.c
> @@ -1586,7 +1586,6 @@ static const struct ethtool_ops ethtool_ops = {
>  	.get_link = get_link,
>  	.get_msglevel = get_msglevel,
>  	.set_msglevel = set_msglevel,
> -	.get_perm_addr = ethtool_op_get_perm_addr,
>  };
>  
>  static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> only in patch2:
> unchanged:
> --- a/drivers/net/sunvnet.c
> +++ b/drivers/net/sunvnet.c
> @@ -906,7 +906,6 @@ static const struct ethtool_ops vnet_ethtool_ops = {
>  	.get_msglevel		= vnet_get_msglevel,
>  	.set_msglevel		= vnet_set_msglevel,
>  	.get_link		= ethtool_op_get_link,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static void vnet_port_free_tx_bufs(struct vnet_port *port)
> only in patch2:
> unchanged:
> --- a/drivers/net/tc35815.c
> +++ b/drivers/net/tc35815.c
> @@ -2198,7 +2198,6 @@ static const struct ethtool_ops tc35815_ethtool_ops = {
>  	.get_strings		= tc35815_get_strings,
>  	.get_stats_count	= tc35815_get_stats_count,
>  	.get_ethtool_stats	= tc35815_get_ethtool_stats,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> only in patch2:
> unchanged:
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -9294,7 +9294,6 @@ static const struct ethtool_ops tg3_ethtool_ops = {
>  	.get_ethtool_stats	= tg3_get_ethtool_stats,
>  	.get_coalesce		= tg3_get_coalesce,
>  	.set_coalesce		= tg3_set_coalesce,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
> only in patch2:
> unchanged:
> --- a/drivers/net/via-rhine.c
> +++ b/drivers/net/via-rhine.c
> @@ -1805,7 +1805,6 @@ static const struct ethtool_ops netdev_ethtool_ops = {
>  	.set_wol		= rhine_set_wol,
>  	.get_sg			= ethtool_op_get_sg,
>  	.get_tx_csum		= ethtool_op_get_tx_csum,
> -	.get_perm_addr		= ethtool_op_get_perm_addr,
>  };
>  
>  static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> only in patch2:
> unchanged:
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -270,8 +270,6 @@ u32 ethtool_op_get_sg(struct net_device *dev);
>  int ethtool_op_set_sg(struct net_device *dev, u32 data);
>  u32 ethtool_op_get_tso(struct net_device *dev);
>  int ethtool_op_set_tso(struct net_device *dev, u32 data);
> -int ethtool_op_get_perm_addr(struct net_device *dev, 
> -			     struct ethtool_perm_addr *addr, u8 *data);
>  u32 ethtool_op_get_ufo(struct net_device *dev);
>  int ethtool_op_set_ufo(struct net_device *dev, u32 data);
>  
> @@ -309,7 +307,6 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
>   * get_strings: Return a set of strings that describe the requested objects 
>   * phys_id: Identify the device
>   * get_stats: Return statistics about the device
> - * get_perm_addr: Gets the permanent hardware address
>   * 
>   * Description:
>   *
> @@ -368,7 +365,6 @@ struct ethtool_ops {
>  	int	(*phys_id)(struct net_device *, u32);
>  	int	(*get_stats_count)(struct net_device *);
>  	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
> -	int	(*get_perm_addr)(struct net_device *, struct ethtool_perm_addr *, u8 *);
>  	int	(*begin)(struct net_device *);
>  	void	(*complete)(struct net_device *);
>  	u32     (*get_ufo)(struct net_device *);
> 
