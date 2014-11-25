From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Tue, 25 Nov 2014 14:48:30 -0800
Message-ID: <5475073E.70503@cumulusnetworks.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-9-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:60894 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbaKYWsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:48:39 -0500
In-Reply-To: <1416911328-10979-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14, 2:28 AM, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> To notify switch driver of change in STP state of bridge port, add new
> .ndo op and provide switchdev wrapper func to call ndo op. Use it in bridge
> code then.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> v2->v3:
> -changed "sw" string to "switch" to avoid confusion
> v1->v2:
> -no change
> ---
>   include/linux/netdevice.h |  5 +++++
>   include/net/switchdev.h   |  7 +++++++
>   net/bridge/br_stp.c       |  2 ++
>   net/switchdev/switchdev.c | 19 +++++++++++++++++++
>   4 files changed, 33 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ce096dc..66cb64e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1024,6 +1024,9 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    *	Called to get an ID of the switch chip this port is part of.
>    *	If driver implements this, it indicates that it represents a port
>    *	of a switch chip.
> + * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
> + *	Called to notify switch device port of bridge port STP
> + *	state change.
>    */
>   struct net_device_ops {
>   	int			(*ndo_init)(struct net_device *dev);
> @@ -1180,6 +1183,8 @@ struct net_device_ops {
>   #ifdef CONFIG_NET_SWITCHDEV
>   	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
>   							    struct netdev_phys_item_id *psid);
> +	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
> +							      u8 state);
>   #endif
>   };
>   
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 7a52360..8a6d164 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -16,6 +16,7 @@
>   
>   int netdev_switch_parent_id_get(struct net_device *dev,
>   				struct netdev_phys_item_id *psid);
> +int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>   
>   #else
>   
> @@ -25,6 +26,12 @@ static inline int netdev_switch_parent_id_get(struct net_device *dev,
>   	return -EOPNOTSUPP;
>   }
>   
> +static inline int netdev_switch_port_stp_update(struct net_device *dev,
> +						u8 state)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>   #endif
>   
>   #endif /* _LINUX_SWITCHDEV_H_ */
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index 2b047bc..35e016c 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -12,6 +12,7 @@
>    */
>   #include <linux/kernel.h>
>   #include <linux/rculist.h>
> +#include <net/switchdev.h>
>   
>   #include "br_private.h"
>   #include "br_private_stp.h"
> @@ -39,6 +40,7 @@ void br_log_state(const struct net_bridge_port *p)
>   void br_set_state(struct net_bridge_port *p, unsigned int state)
>   {
>   	p->state = state;
> +	netdev_switch_port_stp_update(p->dev, state);
>   }
>   
>   /* called under bridge lock */
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 66973de..d162b21 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -31,3 +31,22 @@ int netdev_switch_parent_id_get(struct net_device *dev,
>   	return ops->ndo_switch_parent_id_get(dev, psid);
>   }
>   EXPORT_SYMBOL(netdev_switch_parent_id_get);
> +
> +/**
> + *	netdev_switch_port_stp_update - Notify switch device port of STP
> + *					state change
> + *	@dev: port device
> + *	@state: port STP state
> + *
> + *	Notify switch device port of bridge port STP state change.
> + */
> +int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	if (!ops->ndo_switch_port_stp_update)
> +		return -EOPNOTSUPP;
> +	WARN_ON(!ops->ndo_switch_parent_id_get);
> +	return ops->ndo_switch_port_stp_update(dev, state);
> +}
> +EXPORT_SYMBOL(netdev_switch_port_stp_update);

This should also check  if offload is enabled on the bridge/port ?
