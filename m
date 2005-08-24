From: Mark Huth <mhuth@mvista.com>
Subject: Re: mv643xx(2/20): use MII library for PHY management
Date: Tue, 23 Aug 2005 17:34:34 -0700
Message-ID: <430BC09A.3090401@mvista.com>
References: <20050328233807.GA28423@xyzzy> <20050328234225.GB29098@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
        Ralf Baechle
 <ralf@linux-mips.org>,
        Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite
 <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin
 Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman
 <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dale Farnsworth <dale@farnsworth.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's good to use the abstractions and common code, but in this case 
there is a significant performance difference.  The MDIO read/write on 
this family does a cpu spin wait for the mdio operation to complete. 
Last time I measured this (back when fixing up a 2.4.20 implementation) 
I got around 100 us for the mii_ioctl path, of which a good bit was in 
the spin loop waiting for the MDIO operation to complete.  A quick look 
seems to indicate the spin loop is still in this version of the driver.

Given that the NIC chip gives cheap access to the link status and a 
couple of other interesting bits, the change to use the mii library has 
a performance impact.

Mark Huth

Dale Farnsworth wrote:
> Modify link up/down handling to use the functions from the MII
> library.  Note that I track link state using the MII PHY registers
> rather than the mv643xx chip's link state registers because I think
> it's cleaner to use the MII library code rather than writing local
> driver support code. It is also useful to make the actual MII
> registers available to the user with maskable kernel printk messages
> so the MII registers are being read anyway
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> Acked-by: Dale Farnsworth <dale@farnsworth.org>
> 
> Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
> ===================================================================
> --- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
> +++ linux-2.5-enet/drivers/net/mv643xx_eth.h
> @@ -6,6 +6,7 @@
>  #include <linux/kernel.h>
>  #include <linux/spinlock.h>
>  #include <linux/workqueue.h>
> +#include <linux/mii.h>
>  
>  #include <linux/mv643xx.h>
>  
> @@ -397,6 +398,9 @@
>  
>  	u32 rx_int_coal;
>  	u32 tx_int_coal;
> +
> +	u32 msg_enable;
> +	struct mii_if_info mii;
>  };
>  
>  /* ethernet.h API list */
> Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
> ===================================================================
> --- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
> +++ linux-2.5-enet/drivers/net/mv643xx_eth.c
> @@ -74,7 +74,6 @@
>  #define PHY_WAIT_MICRO_SECONDS	10
>  
>  /* Static function declarations */
> -static int eth_port_link_is_up(unsigned int eth_port_num);
>  static void eth_port_uc_addr_get(struct net_device *dev,
>  						unsigned char *MacAddr);
>  static int mv643xx_eth_real_open(struct net_device *);
> @@ -85,8 +84,11 @@
>  #ifdef MV643XX_NAPI
>  static int mv643xx_poll(struct net_device *dev, int *budget);
>  #endif
> +static int ethernet_phy_get(unsigned int eth_port_num);
>  static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
>  static int ethernet_phy_detect(unsigned int eth_port_num);
> +static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
> +static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
>  static struct ethtool_ops mv643xx_ethtool_ops;
>  
>  static char mv643xx_driver_name[] = "mv643xx_eth";
> @@ -550,16 +552,38 @@
>  	}
>  	/* PHY status changed */
>  	if (eth_int_cause_ext & (BIT16 | BIT20)) {
> -		if (eth_port_link_is_up(port_num)) {
> -			netif_carrier_on(dev);
> +		struct ethtool_cmd cmd;
> +
> +		/* mii library handles link maintenance tasks */
> +
> +		mii_ethtool_gset(&mp->mii, &cmd);
> +		if (netif_msg_link(mp))
> +			printk(KERN_DEBUG "%s: link phy regs: "
> +			       "supported=%x advert=%x "
> +			       "autoneg=%x speed=%d duplex=%d\n",
> +			       dev->name, 
> +			       cmd.supported, cmd.advertising,
> +			       cmd.autoneg, cmd.speed, cmd.duplex);
> +
> +		if(mii_link_ok(&mp->mii) && !netif_carrier_ok(dev)) {
> +			if (netif_msg_ifup(mp))
> +				printk(KERN_INFO "%s: link up, %sMbps, %s-duplex\n",
> +				       dev->name,
> +				       cmd.speed == SPEED_1000 ? "1000" :
> +				       cmd.speed == SPEED_100 ? "100" : "10",
> +				       cmd.duplex == DUPLEX_FULL ? "full" : "half");
> +
>  			netif_wake_queue(dev);
>  			/* Start TX queue */
> -			mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG
> -								(port_num), 1);
> -		} else {
> -			netif_carrier_off(dev);
> +			mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
> +
> +		} else if(!mii_link_ok(&mp->mii) && netif_carrier_ok(dev)) {
>  			netif_stop_queue(dev);
> +			if (netif_msg_ifdown(mp))
> +				printk(KERN_INFO "%s: link down\n", dev->name);
>  		}
> +
> +		mii_check_link(&mp->mii);
>  	}
>  
>  	/*
> @@ -1379,6 +1403,10 @@
>  
>  	mp = netdev_priv(dev);
>  
> +	/* By default, log probe, interface up/down and error events */
> +	mp->msg_enable = NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN |
> +		NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR;
> +
>  	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>  	BUG_ON(!res);
>  	dev->irq = res->start;
> @@ -1415,6 +1443,15 @@
>  #endif
>  #endif
>  
> +	/* Hook up MII support for ethtool */
> +	mp->mii.dev = dev;
> +	mp->mii.mdio_read = mv643xx_mdio_read;
> +	mp->mii.mdio_write = mv643xx_mdio_write;
> +	mp->mii.phy_id = ethernet_phy_get(mp->port_num);
> +	mp->mii.phy_id_mask = 0x3f;
> +	mp->mii.reg_num_mask = 0x1f;
> +	mp->mii.supports_gmii = 1;
> +
>  	/* Configure the timeout task */
>  	INIT_WORK(&mp->tx_timeout_task,
>  			(void (*)(void *))mv643xx_eth_tx_timeout_task, dev);
> @@ -2323,21 +2360,6 @@
>  	return phy_reg_data0 & 0x1000;
>  }
>  
> -static int eth_port_link_is_up(unsigned int eth_port_num)
> -{
> -	unsigned int phy_reg_data1;
> -
> -	eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data1);
> -
> -	if (eth_port_autoneg_supported(eth_port_num)) {
> -		if (phy_reg_data1 & 0x20)	/* auto-neg complete */
> -			return 1;
> -	} else if (phy_reg_data1 & 0x4)		/* link up */
> -		return 1;
> -
> -	return 0;
> -}
> -
>  /*
>   * ethernet_get_config_reg - Get the port configuration register
>   *
> @@ -2468,6 +2490,24 @@
>  }
>  
>  /*
> + * Wrappers for MII support library.
> + */
> +static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
> +{
> +	int val;
> +	struct mv643xx_private *mp = netdev_priv(dev);
> +
> +	eth_port_read_smi_reg(mp->port_num, location, &val);
> +	return val;
> +}
> +
> +static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
> +{
> +	struct mv643xx_private *mp = netdev_priv(dev);
> +	eth_port_write_smi_reg(mp->port_num, location, val);
> +}
> +
> +/*
>   * eth_port_send - Send an Ethernet packet
>   *
>   * DESCRIPTION:
> 
> 
