From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: switchdev: Add
 switchdev_port_bridge_getlink_deferred
Date: Mon, 9 Jan 2017 18:11:36 -0200
Message-ID: <20170109201135.GE3771@localhost.localdomain>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109194503.10713-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@resnulli.us
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55340 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751061AbdAIULl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 15:11:41 -0500
Content-Disposition: inline
In-Reply-To: <20170109194503.10713-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 11:45:02AM -0800, Florian Fainelli wrote:
> Add switchdev_port_bridge_getlink_deferred() which does a deferred
> object dump operation, this is required for e.g: DSA switches which
> typically have sleeping I/O operations which is incompatible with being
> in atomic context obviously.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  include/net/switchdev.h   |  3 ++
>  net/switchdev/switchdev.c | 79 ++++++++++++++++++++++++++++++++++++++---------
>  2 files changed, 67 insertions(+), 15 deletions(-)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index eba80c4fc56f..087761b0df49 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -189,6 +189,9 @@ int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
>  int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>  				  struct net_device *dev, u32 filter_mask,
>  				  int nlflags);
> +int switchdev_port_bridge_getlink_deferred(struct sk_buff *skb, u32 pid,
> +					   u32 seq, struct net_device *dev,
> +					   u32 filter_mask, int nlflags);
>  int switchdev_port_bridge_setlink(struct net_device *dev,
>  				  struct nlmsghdr *nlh, u16 flags);
>  int switchdev_port_bridge_dellink(struct net_device *dev,
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 4fa9972d72d2..ab614a9dd872 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -776,12 +776,14 @@ static int switchdev_port_vlan_dump_cb(struct switchdev_obj *obj)
>  	return err;
>  }
>  
> -static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
> -				    u32 filter_mask)
> +static int __switchdev_port_vlan_fill(struct sk_buff *skb,
> +				      struct net_device *dev,
> +				      u32 filter_mask, u32 obj_flags)
>  {
>  	struct switchdev_vlan_dump dump = {
>  		.vlan.obj.orig_dev = dev,
>  		.vlan.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
> +		.vlan.obj.flags = obj_flags,
>  		.skb = skb,
>  		.filter_mask = filter_mask,
>  	};
> @@ -802,17 +804,27 @@ static int switchdev_port_vlan_fill(struct sk_buff *skb, struct net_device *dev,
>  	return err == -EOPNOTSUPP ? 0 : err;
>  }
>  
> -/**
> - *	switchdev_port_bridge_getlink - Get bridge port attributes
> - *
> - *	@dev: port device
> - *
> - *	Called for SELF on rtnl_bridge_getlink to get bridge port
> - *	attributes.
> - */
> -int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
> -				  struct net_device *dev, u32 filter_mask,
> -				  int nlflags)
> +static int switchdev_port_vlan_fill_deferred(struct sk_buff *skb,
> +					     struct net_device *dev,
> +					     u32 filter_mask)
> +{
> +	return __switchdev_port_vlan_fill(skb, dev, filter_mask,
> +					  SWITCHDEV_F_DEFER);
> +}
> +
> +static int switchdev_port_vlan_fill(struct sk_buff *skb,
> +				    struct net_device *dev,
> +				    u32 filter_mask)
> +{
> +	return __switchdev_port_vlan_fill(skb, dev, filter_mask, 0);
> +}
> +
> +static int __switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid,
> +					   u32 seq, struct net_device *dev,
> +					   u32 filter_mask, int nlflags,
> +					   int (*fill_cb)(struct sk_buff *skb,
> +							  struct net_device *d,
> +							  u32 filter_mask))
>  {
>  	struct switchdev_attr attr = {
>  		.orig_dev = dev,
> @@ -829,12 +841,49 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>  	if (err && err != -EOPNOTSUPP)
>  		return err;
>  
> -	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
> +	return ndo_dflt_bridge_getlink(skb, pid, seq, d, mode,

Was this s/dev/d/ by mistake?

>  				       attr.u.brport_flags, mask, nlflags,
> -				       filter_mask, switchdev_port_vlan_fill);
> +				       filter_mask, fill_cb);
> +}
> +
> +/**
> + *	switchdev_port_bridge_getlink - Get bridge port attributes
> + *
> + *	@dev: port device
> + *
> + *	Called for SELF on rtnl_bridge_getlink to get bridge port
> + *	attributes.
> + */
> +int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
> +				  struct net_device *dev, u32 filter_mask,
> +				  int nlflags)
> +{
> +	return __switchdev_port_bridge_getlink(skb, pid, seq, dev, filter_mask,
> +					       nlflags,
> +					       switchdev_port_vlan_fill);
>  }
>  EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink);
>  
> +/**
> + *	switchdev_port_bridge_getlink_deferred - Get bridge port attributes
> + *	(deferred variant)
> + *
> + *	@dev: port device
> + *
> + *	Called for SELF on rtnl_bridge_getlink to get bridge port
> + *	attributes.
> + */
> +int switchdev_port_bridge_getlink_deferred(struct sk_buff *skb, u32 pid,
> +					   u32 seq, struct net_device *dev,
> +					   u32 filter_mask,
> +					   int nlflags)
> +{
> +	return __switchdev_port_bridge_getlink(skb, pid, seq, dev, filter_mask,
> +					       nlflags,
> +					       switchdev_port_vlan_fill_deferred);
> +}
> +EXPORT_SYMBOL_GPL(switchdev_port_bridge_getlink_deferred);
> +
>  static int switchdev_port_br_setflag(struct net_device *dev,
>  				     struct nlattr *nlattr,
>  				     unsigned long brport_flag)
> -- 
> 2.9.3
> 
