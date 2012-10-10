From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [RFC PATCH] net/core: support runtime PM on net_device
Date: Wed, 10 Oct 2012 15:17:30 +0200
Message-ID: <1661593.Shb8QLRF9A@linux-lqwf.site>
References: <1349873913-10701-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-pm@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38090 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025Ab2JJNTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 09:19:15 -0400
In-Reply-To: <1349873913-10701-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 October 2012 20:58:33 Ming Lei wrote:
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

[..]
> +	if (pm_runtime_get_sync(&dev->dev) < 0)
> +		return -ENODEV;

-EIO would be appropriate.

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

Perhaps you should check that first.

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

Why?

	Regards
		Oliver
