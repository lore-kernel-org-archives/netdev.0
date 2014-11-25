From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v3 08/17] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Tue, 25 Nov 2014 10:58:32 -0500
Message-ID: <20141125155832.GG27416@gospo.rtplab.test>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-9-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44782 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbaKYP6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:58:45 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 11:28:39AM +0100, Jiri Pirko wrote:
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
>  include/linux/netdevice.h |  5 +++++
>  include/net/switchdev.h   |  7 +++++++
>  net/bridge/br_stp.c       |  2 ++
>  net/switchdev/switchdev.c | 19 +++++++++++++++++++
>  4 files changed, 33 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ce096dc..66cb64e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1024,6 +1024,9 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   *	Called to get an ID of the switch chip this port is part of.
>   *	If driver implements this, it indicates that it represents a port
>   *	of a switch chip.
> + * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
> + *	Called to notify switch device port of bridge port STP
> + *	state change.
>   */
>  struct net_device_ops {
>  	int			(*ndo_init)(struct net_device *dev);
> @@ -1180,6 +1183,8 @@ struct net_device_ops {
>  #ifdef CONFIG_NET_SWITCHDEV
>  	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
>  							    struct netdev_phys_item_id *psid);
> +	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
> +							      u8 state);
>  #endif
>  };
>  
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 7a52360..8a6d164 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -16,6 +16,7 @@
>  
>  int netdev_switch_parent_id_get(struct net_device *dev,
>  				struct netdev_phys_item_id *psid);
> +int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>  
>  #else
>  
> @@ -25,6 +26,12 @@ static inline int netdev_switch_parent_id_get(struct net_device *dev,
>  	return -EOPNOTSUPP;
>  }
>  
> +static inline int netdev_switch_port_stp_update(struct net_device *dev,
> +						u8 state)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  #endif
>  
>  #endif /* _LINUX_SWITCHDEV_H_ */
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index 2b047bc..35e016c 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -12,6 +12,7 @@
>   */
>  #include <linux/kernel.h>
>  #include <linux/rculist.h>
> +#include <net/switchdev.h>
>  
>  #include "br_private.h"
>  #include "br_private_stp.h"
> @@ -39,6 +40,7 @@ void br_log_state(const struct net_bridge_port *p)
>  void br_set_state(struct net_bridge_port *p, unsigned int state)
>  {
>  	p->state = state;
> +	netdev_switch_port_stp_update(p->dev, state);

The only thing that concerns me about this patch is the fact that there
is nothing paying attention to the return code.

This means if *something* in the driver fails to set the STP state we
have no way to feed this information back to the user to let them know
that their hardware isn't exactly functioning as we expect.

I do not expect that this first set would provide full feedback to
br_make_forwarding, br_make_blocking, etc, to allow spanning tree to
properly deal with the failure (that change is fine to add later), but a
short one-liner indicating that the call to the hardware  failed would e
good.  What about something simple like this:

void br_set_state(struct net_bridge_port *p, unsigned int state)
{
	int ret;
	p->state = state;
	ret = netdev_switch_port_stp_update(p->dev, state);
	if (ret && ret != -EOPNOTSUPP)
		br_warn(br, "error setting offload STP state for interface %s\n",
			p->dev->name);
}

>  
>  /* called under bridge lock */
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 66973de..d162b21 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -31,3 +31,22 @@ int netdev_switch_parent_id_get(struct net_device *dev,
>  	return ops->ndo_switch_parent_id_get(dev, psid);
>  }
>  EXPORT_SYMBOL(netdev_switch_parent_id_get);
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
> -- 
> 1.9.3
> 
