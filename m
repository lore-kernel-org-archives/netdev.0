From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 02/42] net: introduce default
 neigh_construct/destroy ndo calls for L2 upper devices
Date: Fri, 1 Jul 2016 08:24:54 -0600
Message-ID: <54eb6809-c681-f1af-51a3-aaf52b12ef45@cumulusnetworks.com>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	tgraf@suug.ch, jhs@mojatatu.com, linville@tuxdriver.com,
	ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37594 "EHLO
	mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbcGAOY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:24:57 -0400
Received: by mail-it0-f54.google.com with SMTP id f6so18024075ith.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:24:56 -0700 (PDT)
In-Reply-To: <1467381910-3445-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/16 8:04 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> L2 upper device needs to propagate neigh_construct/destroy calls down to
> lower devices. Do this by defining default ndo functions and use them in
> team, bond, bridge and vlan.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> ---
>  drivers/net/bonding/bond_main.c |  2 ++
>  drivers/net/team/team.c         |  2 ++
>  include/linux/netdevice.h       |  4 ++++
>  net/8021q/vlan_dev.c            |  2 ++
>  net/bridge/br_device.c          |  2 ++
>  net/core/dev.c                  | 32 ++++++++++++++++++++++++++++++++
>  6 files changed, 44 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 90157e2..480d73a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4137,6 +4137,8 @@ static const struct net_device_ops bond_netdev_ops = {
>  	.ndo_add_slave		= bond_enslave,
>  	.ndo_del_slave		= bond_release,
>  	.ndo_fix_features	= bond_fix_features,
> +	.ndo_neigh_construct	= netdev_default_l2upper_neigh_construct,
> +	.ndo_neigh_destroy	= netdev_default_l2upper_neigh_destroy,
>  	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
>  	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
>  	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index f9eebea..a380649 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -2002,6 +2002,8 @@ static const struct net_device_ops team_netdev_ops = {
>  	.ndo_add_slave		= team_add_slave,
>  	.ndo_del_slave		= team_del_slave,
>  	.ndo_fix_features	= team_fix_features,
> +	.ndo_neigh_construct	= netdev_default_l2upper_neigh_construct,
> +	.ndo_neigh_destroy	= netdev_default_l2upper_neigh_destroy,
>  	.ndo_change_carrier     = team_change_carrier,
>  	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
>  	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f126119..fac5132 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3826,6 +3826,10 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
>  				   struct net_device *lower_dev);
>  void netdev_lower_state_changed(struct net_device *lower_dev,
>  				void *lower_state_info);
> +int netdev_default_l2upper_neigh_construct(struct net_device *dev,
> +					   struct neighbour *n);
> +void netdev_default_l2upper_neigh_destroy(struct net_device *dev,
> +					  struct neighbour *n);
>
>  /* RSS keys are 40 or 52 bytes long */
>  #define NETDEV_RSS_KEY_LEN 52
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 86ae75b..c8f422c 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -790,6 +790,8 @@ static const struct net_device_ops vlan_netdev_ops = {
>  	.ndo_netpoll_cleanup	= vlan_dev_netpoll_cleanup,
>  #endif
>  	.ndo_fix_features	= vlan_dev_fix_features,
> +	.ndo_neigh_construct	= netdev_default_l2upper_neigh_construct,
> +	.ndo_neigh_destroy	= netdev_default_l2upper_neigh_destroy,
>  	.ndo_fdb_add		= switchdev_port_fdb_add,
>  	.ndo_fdb_del		= switchdev_port_fdb_del,
>  	.ndo_fdb_dump		= switchdev_port_fdb_dump,
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 0c39e0f..8eecd0e 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -349,6 +349,8 @@ static const struct net_device_ops br_netdev_ops = {
>  	.ndo_add_slave		 = br_add_slave,
>  	.ndo_del_slave		 = br_del_slave,
>  	.ndo_fix_features        = br_fix_features,
> +	.ndo_neigh_construct	 = netdev_default_l2upper_neigh_construct,
> +	.ndo_neigh_destroy	 = netdev_default_l2upper_neigh_destroy,
>  	.ndo_fdb_add		 = br_fdb_add,
>  	.ndo_fdb_del		 = br_fdb_delete,
>  	.ndo_fdb_dump		 = br_fdb_dump,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index aba10d2..eb13647 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6041,6 +6041,38 @@ void netdev_lower_state_changed(struct net_device *lower_dev,
>  }
>  EXPORT_SYMBOL(netdev_lower_state_changed);
>
> +int netdev_default_l2upper_neigh_construct(struct net_device *dev,
> +					   struct neighbour *n)
> +{
> +	struct net_device *lower_dev;
> +	struct list_head *iter;
> +	int err;
> +
> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +		if (!lower_dev->netdev_ops->ndo_neigh_construct)
> +			continue;
> +		err = lower_dev->netdev_ops->ndo_neigh_construct(lower_dev, n);
> +		if (err)
> +			return err;

If the Mth lower_dev of N total fails why not call destroy on the first M-1?

> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL(netdev_default_l2upper_neigh_construct);

_GPL?


> +
> +void netdev_default_l2upper_neigh_destroy(struct net_device *dev,
> +					  struct neighbour *n)
> +{
> +	struct net_device *lower_dev;
> +	struct list_head *iter;
> +
> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +		if (!lower_dev->netdev_ops->ndo_neigh_destroy)
> +			continue;
> +		lower_dev->netdev_ops->ndo_neigh_destroy(lower_dev, n);
> +	}
> +}
> +EXPORT_SYMBOL(netdev_default_l2upper_neigh_destroy);

_GPL?

> +
>  static void dev_change_rx_flags(struct net_device *dev, int flags)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>

I do not see either of the new functions being called in this patch set; 
only hit grep shows is this patch.
