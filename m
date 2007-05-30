From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 10:28:10 -0700
Message-ID: <20070530102810.1689119b@freepuppy>
References: <20070530131123.10843.0@janus.isnogud.escape.de>
	<20070530131204.10843.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:58403 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbXE3RpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 13:45:13 -0400
In-Reply-To: <20070530131204.10843.5@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In addition to Patrick's comments.

> +
> +static void vcan_init(struct net_device *dev)
> +{
> +	DBG("dev %s\n", dev->name);
> +
> +	ether_setup(dev);

Do really want to do this?
  - you set different flags/type after this.
  - do you really want change_mtu to call eth_change_mtu
Better off to just copy what you want out of ether_setup if
your device is not really an ether device.


> +	memset(dev->priv, 0, STATSIZE);

Unneeded alloc_netdev always zero's

> +
> +	dev->type              = ARPHRD_CAN;
> +	dev->mtu               = sizeof(struct can_frame);
> +	dev->flags             = IFF_NOARP;
> +
> +	/* set flags according to driver capabilities */
> +	if (loopback)
> +		dev->flags |= IFF_LOOPBACK;
> +
> +	dev->open              = vcan_open;
> +	dev->stop              = vcan_stop;
> +	dev->set_config        = NULL;
unneeded

> +	dev->hard_start_xmit   = vcan_tx;
> +	dev->do_ioctl          = vcan_ioctl;
> +	dev->get_stats         = vcan_get_stats;
> +	dev->hard_header       = vcan_header;
> +	dev->rebuild_header    = vcan_rebuild_header;
> +	dev->hard_header_cache = NULL;
unneeded

> +	SET_MODULE_OWNER(dev);
> +}
> +
> +static __init int vcan_init_module(void)
> +{
> +	int i, result;
> +
> +	printk(banner);
> +
> +	/* register at least one interface */
> +	if (numdev < 1)
> +		numdev = 1;
> +
> +	printk(KERN_INFO
> +	       "vcan: registering %d virtual CAN interfaces. (loopback %s)\n",
> +	       numdev, loopback ? "enabled" : "disabled");
> +
> +	vcan_devs = kzalloc(numdev * sizeof(struct net_device *), GFP_KERNEL);
kcalloc() instead?

> +	if (!vcan_devs) {
> +		printk(KERN_ERR "vcan: Can't allocate vcan devices array!\n");
> +		return -ENOMEM;
> +	}
> +
> +	for (i = 0; i < numdev; i++) {
> +		vcan_devs[i] = alloc_netdev(STATSIZE, "vcan%d", vcan_init);
> +		if (!vcan_devs[i]) {
> +			printk(KERN_ERR "vcan: error allocating net_device\n");
> +			result = -ENOMEM;
> +			goto out;
> +		}
> +
> +		result = register_netdev(vcan_devs[i]);
> +		if (result < 0) {
> +			printk(KERN_ERR
> +			       "vcan: error %d registering interface %s\n",
> +			       result, vcan_devs[i]->name);
> +			free_netdev(vcan_devs[i]);
> +			vcan_devs[i] = NULL;
> +			goto out;
> +
> +		} else {
> +			DBG("successfully registered interface %s\n",
> +			    vcan_devs[i]->name);
> +		}
> +	}
> +
> +	return 0;
> +
> + out:
> +	for (i = 0; i < numdev; i++) {
> +		if (vcan_devs[i]) {
> +			unregister_netdev(vcan_devs[i]);
> +			free_netdev(vcan_devs[i]);
> +		}
> +	}
> +
> +	kfree(vcan_devs);
> +
> +	return result;
> +}
> +
> +static __exit void vcan_cleanup_module(void)
> +{
> +	int i;
> +
> +	for (i = 0; i < numdev; i++) {
> +		if (vcan_devs[i]) {
> +			unregister_netdev(vcan_devs[i]);
> +			free_netdev(vcan_devs[i]);
> +		}
> +	}
> +
> +	kfree(vcan_devs);
> +}
> +
> +module_init(vcan_init_module);
> +module_exit(vcan_cleanup_module);
> Index: linux-2.6.22-rc3/net/can/Kconfig
> ===================================================================
> --- linux-2.6.22-rc3.orig/net/can/Kconfig	2007-05-30 14:58:03.000000000 +0200
> +++ linux-2.6.22-rc3/net/can/Kconfig	2007-05-30 14:58:05.000000000 +0200
> @@ -77,3 +77,6 @@
>  	  Say Y here if you want the CAN core to produce a bunch of debug
>  	  messages to the system log.  Select this if you are having a
>  	  problem with CAN support and want to see more of what is going on.
> +
> +
> +source "drivers/net/can/Kconfig"
> 
> --
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
