From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/10] dynamic_debug: make netif_dbg() call
 __netdev_printk()
Date: Wed, 06 Jul 2011 14:59:03 -0700
Message-ID: <1309989543.1710.19.camel@Joe-Laptop>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
	 <889f3300a96f381aee1239ea775014fff26d93c9.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <889f3300a96f381aee1239ea775014fff26d93c9.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-07-06 at 13:25 -0400, Jason Baron wrote:
> From: Jason Baron <jbaron@redhat.com>
> 
> Previously, netif_dbg() was using dynamic_dev_dbg() to perform
> the underlying printk. Fix it to use __netdev_printk(), instead.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Jason Baron <jbaron@redhat.com>
> ---
>  include/linux/dynamic_debug.h |   12 ++++++++++++
>  include/linux/netdevice.h     |    6 ++----
>  2 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
[]
> +#define dynamic_netif_dbg(dev, cond, fmt, ...) do {			\
> +	static struct _ddebug descriptor				\
> +	__used								\
> +	__attribute__((section("__verbose"), aligned(8))) =		\
> +	{ KBUILD_MODNAME, __func__, __FILE__, fmt, __LINE__,		\
> +		_DPRINTK_FLAGS_DEFAULT };				\
> +	if (unlikely(descriptor.enabled)) {				\
> +		if (cond)						\
> +			__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);\
> +	}								\
> +	} while (0)
> +

Just nits:

I think it'd be better to use
#define dynamic_netif_dbg(etc)						\
do {									\
	etc...
} while (0)

so that there aren't 2 consecutive close braces at the same indent level.

and maybe just use one test

	if (unlikely(descriptor.enabled) && cond)
		__dynamic_netdev_dbg(&descriptor, dev, fmt, ##__VA_ARGS__);


> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 9b132ef..99c358f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2731,10 +2731,8 @@ do {								\
>  #elif defined(CONFIG_DYNAMIC_DEBUG)
>  #define netif_dbg(priv, type, netdev, format, args...)		\
>  do {								\
> -	if (netif_msg_##type(priv))				\
> -		dynamic_dev_dbg((netdev)->dev.parent,		\
> -				"%s: " format,			\
> -				netdev_name(netdev), ##args);	\
> +	dynamic_netif_dbg(netdev, (netif_msg_##type(priv)),	\
> +				  format, ##args);		\

Because you've already added dynamic_netdev_dbg,
maybe this should be:

#define netif_dbg(priv, type, netdev, format, args...)		\
do {								\
	if (netif_msg_##type(priv))				\
		dynamic_netdev_dbg(netdev, format, ##args);	\
} while (0)
