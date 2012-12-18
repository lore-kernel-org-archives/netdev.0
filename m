From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch net-next 1/4] net: add change_carrier netdev op
Date: Tue, 18 Dec 2012 17:02:51 -0600
Message-ID: <1355871771.30992.44.camel@dcbw.foobar.com>
References: <1355868858-1713-1-git-send-email-jiri@resnulli.us>
	 <1355868858-1713-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367Ab2LRXBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 18:01:21 -0500
In-Reply-To: <1355868858-1713-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 23:14 +0100, Jiri Pirko wrote:
> This allows a driver to register change_carrier callback which will be
> called whenever user will like to change carrier state. This is useful
> for devices like dummy, gre, team and so on.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/netdevice.h |  9 +++++++++
>  net/core/dev.c            | 19 +++++++++++++++++++
>  2 files changed, 28 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 02e0f6b..8047330 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -891,6 +891,11 @@ struct netdev_fcoe_hbainfo {
>   * int (*ndo_bridge_setlink)(struct net_device *dev, struct nlmsghdr *nlh)
>   * int (*ndo_bridge_getlink)(struct sk_buff *skb, u32 pid, u32 seq,
>   *			     struct net_device *dev)
> + *
> + * int (*ndo_change_carrier)(struct net_device *dev, bool new_carrier);
> + *	Called to update device carrier. Soft-devices which do not manage
> + *	real hardware like dummy, team, etc. can define this to provide
> + *	possibility to set their carrier state.

How about something like:

---
Called to change device carrier.  Virtual devices (like dummy, team,
etc) which do not represent real hardware may define this to allow their
userspace components to manage their virtual carrier state.  Devices
that determine carrier state from physical hardware properties (eg
network cables) or protocol-dependent mechanisms (eg
USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
---

I'm just worried that without some clearer wording, somebody will end up
implementing the function for an actual hardware driver down the road
and expect things to work when they change the carrier to "on" but the
protocol isn't set up or cable isn't plugged in.  I'm also worried that
it might be used to simply work around bugs in the drivers that should
be fixed in the drivers instead.

Dan

>  struct net_device_ops {
>  	int			(*ndo_init)(struct net_device *dev);
> @@ -1008,6 +1013,8 @@ struct net_device_ops {
>  	int			(*ndo_bridge_getlink)(struct sk_buff *skb,
>  						      u32 pid, u32 seq,
>  						      struct net_device *dev);
> +	int			(*ndo_change_carrier)(struct net_device *dev,
> +						      bool new_carrier);
>  };
>  
>  /*
> @@ -2194,6 +2201,8 @@ extern int		dev_set_mtu(struct net_device *, int);
>  extern void		dev_set_group(struct net_device *, int);
>  extern int		dev_set_mac_address(struct net_device *,
>  					    struct sockaddr *);
> +extern int		dev_change_carrier(struct net_device *,
> +					   bool new_carrier);
>  extern int		dev_hard_start_xmit(struct sk_buff *skb,
>  					    struct net_device *dev,
>  					    struct netdev_queue *txq);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d0cbc93..268a714 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5027,6 +5027,25 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
>  }
>  EXPORT_SYMBOL(dev_set_mac_address);
>  
> +/**
> + *	dev_change_carrier - Change device carrier
> + *	@dev: device
> + *	@new_carries: new value
> + *
> + *	Change device carrier
> + */
> +int dev_change_carrier(struct net_device *dev, bool new_carrier)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	if (!ops->ndo_change_carrier)
> +		return -EOPNOTSUPP;
> +	if (!netif_device_present(dev))
> +		return -ENODEV;
> +	return ops->ndo_change_carrier(dev, new_carrier);
> +}
> +EXPORT_SYMBOL(dev_change_carrier);
> +
>  /*
>   *	Perform the SIOCxIFxxx calls, inside rcu_read_lock()
>   */
