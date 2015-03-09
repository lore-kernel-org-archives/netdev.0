From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next 1/2] net: core: add of_find_net_device_by_node()
Date: Mon, 09 Mar 2015 12:22:22 -0700
Message-ID: <54FDF2EE.4070700@roeck-us.net>
References: <1425927750-23901-1-git-send-email-f.fainelli@gmail.com> <1425927750-23901-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:50090 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbCITXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:23:19 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YV3Gp-0047R5-0d
	for netdev@vger.kernel.org; Mon, 09 Mar 2015 19:23:19 +0000
In-Reply-To: <1425927750-23901-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2015 12:02 PM, Florian Fainelli wrote:
> Add a helper function which allows getting the struct net_device pointer
> associated with a given struct device_node pointer. This is useful for
> instance for DSA Ethernet devices not backed by a platform_device, but a PCI
> device.
>
> Since we need to access net_class which is not accessible outside of
> net/core/net-sysfs.c, this helper function is also added here and gated
> with CONFIG_OF_NET.
>
> Network devices initialized with SET_NETDEV_DEV() are also taken into
> account by checking for dev->parent first and then falling back to
> checking the device pointer within struct net_device.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   include/linux/of_net.h |  8 ++++++++
>   net/core/net-sysfs.c   | 25 +++++++++++++++++++++++++
>   2 files changed, 33 insertions(+)
>
> diff --git a/include/linux/of_net.h b/include/linux/of_net.h
> index 34597c8c1a4c..395e2d55c16e 100644
> --- a/include/linux/of_net.h
> +++ b/include/linux/of_net.h
> @@ -9,8 +9,11 @@
>
>   #ifdef CONFIG_OF_NET
>   #include <linux/of.h>
> +
> +struct net_device;
>   extern int of_get_phy_mode(struct device_node *np);
>   extern const void *of_get_mac_address(struct device_node *np);
> +extern struct net_device *of_find_net_device_by_node(struct device_node *np);
>   #else
>   static inline int of_get_phy_mode(struct device_node *np)
>   {
> @@ -21,6 +24,11 @@ static inline const void *of_get_mac_address(struct device_node *np)
>   {
>   	return NULL;
>   }
> +
> +static inline struct net_device *of_find_net_device_by_node(struct device_node *np)

Checkpatch warning (line too long)

> +{
> +	return NULL
> +};

; after } is unusual, and you need to add ; after NULL to get this to compile.

>   #endif
>
>   #endif /* __LINUX_OF_NET_H */
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index f2aa73bfb0e4..cf30620a88e1 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -23,6 +23,7 @@
>   #include <linux/export.h>
>   #include <linux/jiffies.h>
>   #include <linux/pm_runtime.h>
> +#include <linux/of.h>
>
>   #include "net-sysfs.h"
>
> @@ -1374,6 +1375,30 @@ static struct class net_class = {
>   	.namespace = net_namespace,
>   };
>
> +#ifdef CONFIG_OF_NET
> +static int of_dev_node_match(struct device *dev, const void *data)
> +{
> +	int ret = 0;
> +
> +	if (dev->parent)
> +		ret = dev->parent->of_node == data;
> +
> +	return ret == 0 ? dev->of_node == data : ret;

	return ret ? : dev->of_node == data;

but that is really a matter of personal preference.

Guenter
