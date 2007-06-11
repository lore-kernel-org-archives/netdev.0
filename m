From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Mon, 11 Jun 2007 15:00:37 -0700
Message-ID: <20070611150037.34a33f43.randy.dunlap@oracle.com>
References: <20070611213721.23014.4812.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com, joe@perches.com,
	shemminger@linux-foundation.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:64580 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbXFKWCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 18:02:07 -0400
In-Reply-To: <20070611213721.23014.4812.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Jun 2007 14:37:21 -0700 Auke Kok wrote:

>  include/linux/netdevice.h |   38 ++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c            |    5 +++++
>  net/core/ethtool.c        |   14 +++++++-------
>  3 files changed, 50 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3a70f55..d185f41 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -540,6 +540,8 @@ struct net_device
>  	struct device		dev;
>  	/* space for optional statistics and wireless sysfs groups */
>  	struct attribute_group  *sysfs_groups[3];
> +
> +	int			msg_enable;
>  };
>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>  
> @@ -838,6 +840,42 @@ enum {
>  	NETIF_MSG_WOL		= 0x4000,
>  };
>  
> +#define ndev_err(netdev, level, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
> +		printk(KERN_ERR "%s: %s: " format, (netdev)->name, \
> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)
> +

I would still do what Steve H. suggested, i.e., only evaluate
macro args one time.  E.g. (not tested & reformatted :)

+#define ndev_err(netdev, level, format, arg...) \
+	do { \
+		struct net_device *__nd = netdev; \
+		if ((__nd)->msg_enable & NETIF_MSG_##level) \
+			printk(KERN_ERR "%s: %s: " format, (__nd)->name, \
+				(__nd)->dev.parent->bus_id, ## arg); \
+	} while (0)
+

Dropping the braces around the printk() too.

etc...

> +#define ndev_warn(netdev, level, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
> +		printk(KERN_WARNING "%s: %s: " format, (netdev)->name, \
> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)
> +
> +#define ndev_notice(netdev, level, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
> +		printk(KERN_NOTICE "%s: %s: " format, (netdev)->name, \
> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)
> +
> +#define ndev_info(netdev, level, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
> +		printk(KERN_INFO "%s: %s: " format, (netdev)->name, \
> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)
> +
> +#ifdef DEBUG
> +#define ndev_debug(netdev, level, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##level) { \
> +		printk(KERN_DEBUG "%s: %s: " format, (netdev)->name, \
> +		(netdev)->dev.parent->bus_id, ## arg); } } while (0)
> +#else
> +/* Force type-checking on ndev_dbg() when DEBUG is not set */
> +static inline int __attribute__ ((format (printf, 3, 4)))
> +__ndev_dbg(struct net_device * netdev, u32 level, const char *format, ...)
> +{
> +	return 0;
> +}
> +#define ndev_dbg(netdev, level, fmt, args...) \
> +	__ndev_dbg(netdev, NETIF_MSG_##level, fmt, ##args)
> +#endif
> +
>  #define netif_msg_drv(p)	((p)->msg_enable & NETIF_MSG_DRV)
>  #define netif_msg_probe(p)	((p)->msg_enable & NETIF_MSG_PROBE)
>  #define netif_msg_link(p)	((p)->msg_enable & NETIF_MSG_LINK)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
