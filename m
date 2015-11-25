From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [RFCv2 bluetooth-next 1/3] 6lowpan: add debugfs support
Date: Wed, 25 Nov 2015 17:42:32 +0100
Message-ID: <5655E4F8.3050900@osg.samsung.com>
References: <1447799594-6050-1-git-send-email-alex.aring@gmail.com>
 <1447799594-6050-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de
To: Alexander Aring <alex.aring@gmail.com>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:55437 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699AbbKYQmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 11:42:36 -0500
In-Reply-To: <1447799594-6050-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17/11/15 23:33, Alexander Aring wrote:
> This patch will introduce a 6lowpan entry into the debugfs if enabled.
> Inside this 6lowpan directory we create a subdirectories of all 6lowpan
> interfaces to offer a per interface debugfs support.

This will be useful for other things as well later on. Some small 
remarks below.

> Signed-off-by: Alexander Aring<alex.aring@gmail.com>
> ---
>   include/net/6lowpan.h         |  6 ++++-
>   net/6lowpan/6lowpan_i.h       | 28 ++++++++++++++++++++++
>   net/6lowpan/Kconfig           |  7 ++++++
>   net/6lowpan/Makefile          |  1 +
>   net/6lowpan/core.c            | 25 +++++++++++++++++++-
>   net/6lowpan/debugfs.c         | 54 +++++++++++++++++++++++++++++++++++++++++++
>   net/bluetooth/6lowpan.c       | 21 +++++++++++------
>   net/ieee802154/6lowpan/core.c | 18 +++++++++++----
>   8 files changed, 146 insertions(+), 14 deletions(-)
>   create mode 100644 net/6lowpan/6lowpan_i.h
>   create mode 100644 net/6lowpan/debugfs.c
>
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index cf3bc56..e484898 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -53,6 +53,8 @@
>   #ifndef __6LOWPAN_H__
>   #define __6LOWPAN_H__
>   
> +#include <linux/debugfs.h>
> +
>   #include <net/ipv6.h>
>   #include <net/net_namespace.h>
>   
> @@ -98,6 +100,7 @@ enum lowpan_lltypes {
>   
>   struct lowpan_priv {
>   	enum lowpan_lltypes lltype;
> +	struct dentry *iface_debugfs;
>   
>   	/* must be last */
>   	u8 priv[0] __aligned(sizeof(void *));
> @@ -185,7 +188,8 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
>   	*hc_ptr += len;
>   }
>   
> -void lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype);
> +int lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype);
> +void lowpan_netdev_unsetup(struct net_device *dev);

Unsetup sounds really wrong. Can we call it teardown? Especially as we 
export this symbol.

>   
>   /**
>    * lowpan_header_decompress - replace 6LoWPAN header with IPv6 header
> diff --git a/net/6lowpan/6lowpan_i.h b/net/6lowpan/6lowpan_i.h
> new file mode 100644
> index 0000000..33b2605
> --- /dev/null
> +++ b/net/6lowpan/6lowpan_i.h
> @@ -0,0 +1,28 @@
> +#ifndef __6LOWPAN_I_H
> +#define __6LOWPAN_I_H
> +
> +#include <linux/netdevice.h>
> +
> +#ifdef CONFIG_6LOWPAN_DEBUGFS
> +int lowpan_dev_debugfs_init(struct net_device *dev);
> +void lowpan_dev_debugfs_uninit(struct net_device *dev);

Exit instead of uninit?
> +
> +int __init lowpan_debugfs_init(void);
> +void lowpan_debugfs_exit(void);
> +#else
> +static inline int lowpan_dev_debugfs_init(struct net_device *dev)
> +{
> +	return 0;
> +}
> +
> +void lowpan_dev_debugfs_uninit(struct net_device *dev) { }
> +
> +static inline int __init lowpan_debugfs_init(void)
> +{
> +	return 0;
> +}
> +
> +static inline void lowpan_debugfs_exit(void) { }
> +#endif /* CONFIG_6LOWPAN_DEBUGFS */
> +
> +#endif /* __6LOWPAN_I_H */
> diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
> index 7fa0f38..01c901c 100644
> --- a/net/6lowpan/Kconfig
> +++ b/net/6lowpan/Kconfig
> @@ -5,6 +5,13 @@ menuconfig 6LOWPAN
>   	  This enables IPv6 over Low power Wireless Personal Area Network -
>   	  "6LoWPAN" which is supported by IEEE 802.15.4 or Bluetooth stacks.
>   
> +config 6LOWPAN_DEBUGFS
> +	bool "6LoWPAN debugfs support"
> +	depends on 6LOWPAN
> +	---help---
> +	  This enables 6LoWPAN debugfs support. For example to manipulate
> +	  IPHC context information at runtime.
> +
>   menuconfig 6LOWPAN_NHC
>   	tristate "Next Header Compression Support"
>   	depends on 6LOWPAN
> diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
> index c6ffc55..54cad8d 100644
> --- a/net/6lowpan/Makefile
> +++ b/net/6lowpan/Makefile
> @@ -1,6 +1,7 @@
>   obj-$(CONFIG_6LOWPAN) += 6lowpan.o
>   
>   6lowpan-y := core.o iphc.o nhc.o
> +6lowpan-$(CONFIG_6LOWPAN_DEBUGFS) += debugfs.o
>   
>   #rfc6282 nhcs
>   obj-$(CONFIG_6LOWPAN_NHC_DEST) += nhc_dest.o
> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
> index 83b19e0..fe58509 100644
> --- a/net/6lowpan/core.c
> +++ b/net/6lowpan/core.c
> @@ -15,7 +15,9 @@
>   
>   #include <net/6lowpan.h>
>   
> -void lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
> +#include "6lowpan_i.h"
> +
> +int lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
>   {
>   	dev->addr_len = EUI64_ADDR_LEN;
>   	dev->type = ARPHRD_6LOWPAN;
> @@ -23,11 +25,25 @@ void lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
>   	dev->priv_flags |= IFF_NO_QUEUE;
>   
>   	lowpan_priv(dev)->lltype = lltype;
> +
> +	return lowpan_dev_debugfs_init(dev);
>   }
>   EXPORT_SYMBOL(lowpan_netdev_setup);
>   
> +void lowpan_netdev_unsetup(struct net_device *dev)
> +{
> +	lowpan_dev_debugfs_uninit(dev);
> +}
> +EXPORT_SYMBOL(lowpan_netdev_unsetup);
> +
>   static int __init lowpan_module_init(void)
>   {
> +	int ret;
> +
> +	ret = lowpan_debugfs_init();
> +	if (ret < 0)
> +		return ret;
> +
>   	request_module_nowait("ipv6");
>   
>   	request_module_nowait("nhc_dest");
> @@ -40,6 +56,13 @@ static int __init lowpan_module_init(void)
>   
>   	return 0;
>   }
> +
> +static void __exit lowpan_module_exit(void)
> +{
> +	lowpan_debugfs_exit();
> +}
> +
>   module_init(lowpan_module_init);
> +module_exit(lowpan_module_exit);
>   
>   MODULE_LICENSE("GPL");
> diff --git a/net/6lowpan/debugfs.c b/net/6lowpan/debugfs.c
> new file mode 100644
> index 0000000..b0a26fd
> --- /dev/null
> +++ b/net/6lowpan/debugfs.c
> @@ -0,0 +1,54 @@
> +/* This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Authors:
> + * (C) 2015 Pengutronix, Alexander Aring<aar@pengutronix.de>
> + * Copyright (c)  2015 Nordic Semiconductor. All Rights Reserved.
> + */
> +
> +#include <net/6lowpan.h>
> +
> +#include "6lowpan_i.h"
> +
> +static struct dentry *lowpan_debugfs;
> +
> +int lowpan_dev_debugfs_init(struct net_device *dev)
> +{
> +	struct lowpan_priv *lpriv = lowpan_priv(dev);
> +
> +	/* creating the root */
> +	lpriv->iface_debugfs = debugfs_create_dir(dev->name, lowpan_debugfs);
> +	if (!lpriv->iface_debugfs)
> +		goto fail;
> +
> +	return 0;
> +
> +fail:
> +	lowpan_dev_debugfs_uninit(dev);
> +	return -EINVAL;
> +}
> +
> +void lowpan_dev_debugfs_uninit(struct net_device *dev)
> +{
> +	debugfs_remove_recursive(lowpan_priv(dev)->iface_debugfs);
> +}
> +
> +int __init lowpan_debugfs_init(void)
> +{
> +	lowpan_debugfs = debugfs_create_dir("6lowpan", NULL);
> +	if (!lowpan_debugfs)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +void lowpan_debugfs_exit(void)
> +{
> +	debugfs_remove_recursive(lowpan_debugfs);
> +}
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index 9e9cca3..d10ce57 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -825,16 +825,14 @@ static int setup_netdev(struct l2cap_chan *chan, struct lowpan_dev **dev)
>   	list_add_rcu(&(*dev)->list, &bt_6lowpan_devices);
>   	spin_unlock(&devices_lock);
>   
> -	lowpan_netdev_setup(netdev, LOWPAN_LLTYPE_BTLE);
> +	err = lowpan_netdev_setup(netdev, LOWPAN_LLTYPE_BTLE);
> +	if (err < 0)
> +		goto free_netdev;
>   
>   	err = register_netdev(netdev);
>   	if (err < 0) {
>   		BT_INFO("register_netdev failed %d", err);
> -		spin_lock(&devices_lock);
> -		list_del_rcu(&(*dev)->list);
> -		spin_unlock(&devices_lock);
> -		free_netdev(netdev);
> -		goto out;
> +		goto unsetup_lowpan;

Again teardown, please.

>   	}
>   
>   	BT_DBG("ifindex %d peer bdaddr %pMR type %d my addr %pMR type %d",
> @@ -844,7 +842,15 @@ static int setup_netdev(struct l2cap_chan *chan, struct lowpan_dev **dev)
>   
>   	return 0;
>   
> -out:
> +unsetup_lowpan:
> +	lowpan_netdev_unsetup(netdev);
> +
> +free_netdev:
> +	spin_lock(&devices_lock);
> +	list_del_rcu(&(*dev)->list);
> +	spin_unlock(&devices_lock);
> +	free_netdev(netdev);
> +
>   	return err;
>   }
>   
> @@ -1348,6 +1354,7 @@ static void disconnect_devices(void)
>   		ifdown(entry->netdev);
>   		BT_DBG("Unregistering netdev %s %p",
>   		       entry->netdev->name, entry->netdev);
> +		lowpan_netdev_unsetup(entry->netdev);
>   		unregister_netdev(entry->netdev);
>   		kfree(entry);
>   	}
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
> index 20c49c7..3b42a75 100644
> --- a/net/ieee802154/6lowpan/core.c
> +++ b/net/ieee802154/6lowpan/core.c
> @@ -161,16 +161,23 @@ static int lowpan_newlink(struct net *src_net, struct net_device *ldev,
>   				wdev->needed_headroom;
>   	ldev->needed_tailroom = wdev->needed_tailroom;
>   
> -	lowpan_netdev_setup(ldev, LOWPAN_LLTYPE_IEEE802154);
> +	ret = lowpan_netdev_setup(ldev, LOWPAN_LLTYPE_IEEE802154);
> +	if (ret < 0)
> +		goto dev_put;
>   
>   	ret = register_netdevice(ldev);
> -	if (ret < 0) {
> -		dev_put(wdev);
> -		return ret;
> -	}
> +	if (ret < 0)
> +		goto unsetup_lowpan;
>   

Teardown
>   	wdev->ieee802154_ptr->lowpan_dev = ldev;
>   	return 0;
> +
> +unsetup_lowpan:
> +	lowpan_netdev_unsetup(ldev);
> +
> +dev_put:
> +	dev_put(wdev);
> +	return ret;
>   }
>   
>   static void lowpan_dellink(struct net_device *ldev, struct list_head *head)
> @@ -180,6 +187,7 @@ static void lowpan_dellink(struct net_device *ldev, struct list_head *head)
>   	ASSERT_RTNL();
>   
>   	wdev->ieee802154_ptr->lowpan_dev = NULL;
> +	lowpan_netdev_unsetup(ldev);
>   	unregister_netdevice(ldev);
>   	dev_put(wdev);
>   }

If you are going to change the th uninit to exit and the unsetup to 
teardown you can add my review.

Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
