From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC PATCH] net/core: support runtime PM on net_device
Date: Tue, 16 Oct 2012 19:07:13 +0200
Message-ID: <6849166.biYgaI8vyA@vostro.rjw.lan>
References: <1349873913-10701-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Neukum <oneukum@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([193.178.161.156]:49564 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755Ab2JPRDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 13:03:34 -0400
In-Reply-To: <1349873913-10701-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 of October 2012 20:58:33 Ming Lei wrote:
> In ioctl path on net_device, the physical deivce is often
> touched, but the physical device may have been put into runtime
> suspend state already, so cause some utilitis(ifconfig, ethtool,
> ...) to return failure in this situation.
> 
> This patch enables runtime PM on net_device and mark it as
> no_callbacks, and resumes the net_device if physical device
> is to be accessed, then suspends it after completion of the
> access.
> 
> This patch fixes the problem above.
> 
> Signed-off-by: Ming Lei <ming.lei@canonical.com>

Well, it looks good in principle.

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


> ---
>  net/core/dev.c       |   83 +++++++++++++++++++++++++++++++-------------------
>  net/core/ethtool.c   |    9 ++++--
>  net/core/net-sysfs.c |    4 +++
>  3 files changed, 63 insertions(+), 33 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index de2bad7..d46d4ed 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -135,6 +135,7 @@
>  #include <linux/net_tstamp.h>
>  #include <linux/static_key.h>
>  #include <net/flow_keys.h>
> +#include <linux/pm_runtime.h>
>  
>  #include "net-sysfs.h"
>  
> @@ -4966,39 +4967,24 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
>  /*
>   *	Perform the SIOCxIFxxx calls, inside rtnl_lock()
>   */
> -static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
> +static int __dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
>  {
>  	int err;
>  	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
>  	const struct net_device_ops *ops;
>  
> -	if (!dev)
> -		return -ENODEV;
> -
>  	ops = dev->netdev_ops;
>  
>  	switch (cmd) {
>  	case SIOCSIFFLAGS:	/* Set interface flags */
>  		return dev_change_flags(dev, ifr->ifr_flags);
>  
> -	case SIOCSIFMETRIC:	/* Set the metric on the interface
> -				   (currently unused) */
> -		return -EOPNOTSUPP;
> -
>  	case SIOCSIFMTU:	/* Set the MTU of a device */
>  		return dev_set_mtu(dev, ifr->ifr_mtu);
>  
>  	case SIOCSIFHWADDR:
>  		return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
>  
> -	case SIOCSIFHWBROADCAST:
> -		if (ifr->ifr_hwaddr.sa_family != dev->type)
> -			return -EINVAL;
> -		memcpy(dev->broadcast, ifr->ifr_hwaddr.sa_data,
> -		       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
> -		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> -		return 0;
> -
>  	case SIOCSIFMAP:
>  		if (ops->ndo_set_config) {
>  			if (!netif_device_present(dev))
> @@ -5022,21 +5008,6 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
>  		if (!netif_device_present(dev))
>  			return -ENODEV;
>  		return dev_mc_del_global(dev, ifr->ifr_hwaddr.sa_data);
> -
> -	case SIOCSIFTXQLEN:
> -		if (ifr->ifr_qlen < 0)
> -			return -EINVAL;
> -		dev->tx_queue_len = ifr->ifr_qlen;
> -		return 0;
> -
> -	case SIOCSIFNAME:
> -		ifr->ifr_newname[IFNAMSIZ-1] = '\0';
> -		return dev_change_name(dev, ifr->ifr_newname);
> -
> -	case SIOCSHWTSTAMP:
> -		err = net_hwtstamp_validate(ifr);
> -		if (err)
> -			return err;
>  		/* fall through */
>  
>  	/*
> @@ -5072,6 +5043,56 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
>  	return err;
>  }
>  
> +static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
> +{
> +	int err;
> +	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
> +	const struct net_device_ops *ops;
> +
> +	if (!dev)
> +		return -ENODEV;
> +
> +	ops = dev->netdev_ops;
> +
> +	switch (cmd) {
> +	case SIOCSIFMETRIC:	/* Set the metric on the interface
> +				   (currently unused) */
> +		return -EOPNOTSUPP;
> +
> +	case SIOCSIFHWBROADCAST:
> +		if (ifr->ifr_hwaddr.sa_family != dev->type)
> +			return -EINVAL;
> +		memcpy(dev->broadcast, ifr->ifr_hwaddr.sa_data,
> +		       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
> +		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> +		return 0;
> +
> +	case SIOCSIFTXQLEN:
> +		if (ifr->ifr_qlen < 0)
> +			return -EINVAL;
> +		dev->tx_queue_len = ifr->ifr_qlen;
> +		return 0;
> +
> +	case SIOCSIFNAME:
> +		ifr->ifr_newname[IFNAMSIZ-1] = '\0';
> +		return dev_change_name(dev, ifr->ifr_newname);
> +
> +	case SIOCSHWTSTAMP:
> +		err = net_hwtstamp_validate(ifr);
> +		if (err)
> +			return err;
> +	}
> +
> +	if (pm_runtime_get_sync(&dev->dev) < 0)
> +		return -ENODEV;
> +
> +	err = __dev_ifsioc(net, ifr, cmd);
> +
> +	pm_runtime_put(&dev->dev);
> +
> +	return err;
> +}
> +
>  /*
>   *	This function handles all "interface"-type I/O control requests. The actual
>   *	'doing' part of this is dev_ifsioc above.
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 4d64cc2..2dc43da 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -25,6 +25,7 @@
>  #include <linux/slab.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/sched.h>
> +#include <linux/pm_runtime.h>
>  
>  /*
>   * Some useful ethtool_ops methods that're device independent.
> @@ -1464,10 +1465,13 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>  			return -EPERM;
>  	}
>  
> +	if ((ret = pm_runtime_get_sync(&dev->dev)) < 0)
> +		return -ENODEV;
> +
>  	if (dev->ethtool_ops->begin) {
>  		rc = dev->ethtool_ops->begin(dev);
>  		if (rc  < 0)
> -			return rc;
> +			goto exit;
>  	}
>  	old_features = dev->features;
>  
> @@ -1648,6 +1652,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
>  
>  	if (old_features != dev->features)
>  		netdev_features_change(dev);
> -
> +exit:
> +	pm_runtime_put(&dev->dev);
>  	return rc;
>  }
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index bcf02f6..c9adb89 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -23,6 +23,7 @@
>  #include <linux/export.h>
>  #include <linux/jiffies.h>
>  #include <net/wext.h>
> +#include <linux/pm_runtime.h>
>  
>  #include "net-sysfs.h"
>  
> @@ -1415,6 +1416,9 @@ int netdev_register_kobject(struct net_device *net)
>  	if (error)
>  		return error;
>  
> +	pm_runtime_no_callbacks(dev);
> +	pm_runtime_enable(dev);
> +
>  	error = register_queue_kobjects(net);
>  	if (error) {
>  		device_del(dev);
> 
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
