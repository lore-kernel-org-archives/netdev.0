From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Fri, 13 Nov 2015 10:38:48 -0800
Message-ID: <56462E38.5090600@gmail.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	sfeldma@gmail.com, jiri@resnulli.us, nikolay@cumulusnetworks.com,
	idosch@mellanox.com, gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35743 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932744AbbKMSjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 13:39:47 -0500
Received: by pacej9 with SMTP id ej9so842911pac.2
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 10:39:46 -0800 (PST)
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/15 08:02, Premkumar Jonnala wrote:
> Packet forwarding to/from bond interfaces is done in software.
> 
> This patch enables certain platforms to bridge traffic to/from
> bond interfaces in hardware.  Notifications are sent out when 
> the "active" slave set for a bond interface is updated in 
> software.  Platforms use the notifications to program the 
> hardware accordingly.  The changes have been verified to work 
> with configured and 802.3ad bond interfaces.

This is a good explanation of why you want the changes, and how this is
implemented in a system utilizing that, but this is not documenting why
you are making these changes to the bonding code, nor how they are
supposed to be used by an implementor driver, since there is no such
user posted (yet?).

You introduce two new NDOs which are not documented in the commit
message which would be nice to explain, in particular, why adding new
NDOs and not switchdev attributes and methods for instance?

Also, is it possible to move some of the logic into a notifier instead
of having to maintain an array of slaves and an array of slaves to discard?

> 
> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
> 
> ---
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index b4351ca..4b53733 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3759,6 +3759,101 @@ err:
>  	bond_slave_arr_work_rearm(bond, 1);
>  }
>  
> +static int slave_present(struct slave *slave, struct bond_up_slave *arr)
> +{
> +	int i;
> +
> +	if (!arr)
> +		return 0;
> +
> +	for (i = 0; i < arr->count; i++) {
> +		if (arr->arr[i] == slave)
> +			return 1;
> +	}
> +	return 0;
> +}
> +
> +/* Send notification to clear/remove slaves for 'bond' in 'arr' except for
> + * slaves in 'ignore_arr'.
> + */
> +static int bond_slave_arr_clear_notify(struct bonding *bond,
> +				struct bond_up_slave *arr,
> +				struct bond_up_slave *ignore_arr)
> +{
> +	struct slave *slave;
> +	struct net_device *slave_dev;
> +	int i, rv;
> +	const struct net_device_ops *ops;
> +
> +	if (!bond->dev || !arr)
> +		return -EINVAL;
> +
> +	rv = 0;
> +	for (i = 0; i < arr->count; i++) {
> +		slave = arr->arr[i];
> +		if (!slave || !slave->dev)
> +			continue;
> +
> +		slave_dev = slave->dev;
> +		if (slave_present(slave, ignore_arr)) {
> +			netdev_dbg(bond->dev, "ignoring clear of slave %s\n",
> +				slave_dev->name);
> +			continue;
> +		}
> +		ops = slave_dev->netdev_ops;
> +		if (!ops || !ops->ndo_bond_slave_discard) {
> +			netdev_dbg(bond->dev, "No slave discard ops for %s\n",
> +				slave_dev->name);
> +			continue;
> +		}
> +		rv = ops->ndo_bond_slave_discard(slave_dev, bond->dev);
> +		if (rv < 0)
> +			return rv;
> +	}
> +	return rv;
> +}
> +
> +/* Send notification about updated slaves for 'bond' except for slaves in
> + * 'ignore_arr'.
> + */
> +static int bond_slave_arr_set_notify(struct bonding *bond,
> +				struct bond_up_slave *ignore_arr)
> +{
> +	struct slave *slave;
> +	struct net_device *slave_dev;
> +	struct bond_up_slave *arr;
> +	int i, rv;
> +	const struct net_device_ops *ops;
> +
> +	if (!bond || !bond->dev)
> +		return -EINVAL;
> +	rv = 0;
> +
> +	arr = rtnl_dereference(bond->slave_arr);
> +	if (!arr)
> +		return -EINVAL;
> +
> +	for (i = 0; i < arr->count; i++) {
> +		slave = arr->arr[i];
> +		slave_dev = slave->dev;
> +		if (slave_present(slave, ignore_arr)) {
> +			netdev_dbg(bond->dev, "ignoring add of slave %s\n",
> +				slave->dev->name);
> +			continue;
> +		}
> +		ops = slave_dev->netdev_ops;
> +		if (!ops || !ops->ndo_bond_slave_add) {
> +			netdev_dbg(bond->dev, "No slave add ops for %s\n",
> +				slave_dev->name);
> +			continue;
> +		}
> +		rv = ops->ndo_bond_slave_add(slave_dev, bond->dev);
> +		if (rv < 0)
> +			return rv;
> +	}
> +	return rv;
> +}
> +
>  /* Build the usable slaves array in control path for modes that use xmit-hash
>   * to determine the slave interface -
>   * (a) BOND_MODE_8023AD
> @@ -3771,7 +3866,7 @@ int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>  {
>  	struct slave *slave;
>  	struct list_head *iter;
> -	struct bond_up_slave *new_arr, *old_arr;
> +	struct bond_up_slave *new_arr, *old_arr, *discard_arr = 0;
>  	int agg_id = 0;
>  	int ret = 0;
>  
> @@ -3786,6 +3881,12 @@ int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>  		pr_err("Failed to build slave-array.\n");
>  		goto out;
>  	}
> +	discard_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
> +			GFP_KERNEL);
> +	if (!discard_arr) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
>  	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>  		struct ad_info ad_info;
>  
> @@ -3797,6 +3898,7 @@ int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>  			 */
>  			old_arr = rtnl_dereference(bond->slave_arr);
>  			if (old_arr) {
> +				bond_slave_arr_clear_notify(bond, old_arr, 0);
>  				RCU_INIT_POINTER(bond->slave_arr, NULL);
>  				kfree_rcu(old_arr, rcu);
>  			}
> @@ -3809,8 +3911,10 @@ int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>  			struct aggregator *agg;
>  
>  			agg = SLAVE_AD_INFO(slave)->port.aggregator;
> -			if (!agg || agg->aggregator_identifier != agg_id)
> +			if (!agg || agg->aggregator_identifier != agg_id) {
> +				discard_arr->arr[discard_arr->count++] = slave;
>  				continue;
> +			}
>  		}
>  		if (!bond_slave_can_tx(slave))
>  			continue;
> @@ -3820,10 +3924,15 @@ int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>  	}
>  
>  	old_arr = rtnl_dereference(bond->slave_arr);
> +	bond_slave_arr_clear_notify(bond, old_arr, new_arr);
> +	bond_slave_arr_clear_notify(bond, discard_arr, 0);
>  	rcu_assign_pointer(bond->slave_arr, new_arr);
> +	bond_slave_arr_set_notify(bond, old_arr);
>  	if (old_arr)
>  		kfree_rcu(old_arr, rcu);
>  out:
> +	if (discard_arr)
> +		kfree(discard_arr);
>  	if (ret != 0 && skipslave) {
>  		int idx;
>  
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4ac653b..facc35f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1236,6 +1236,10 @@ struct net_device_ops {
>  							 bool proto_down);
>  	int			(*ndo_fill_metadata_dst)(struct net_device *dev,
>  						       struct sk_buff *skb);
> +	int		(*ndo_bond_slave_add)(struct net_device *slave_dev,
> +				struct net_device *bond);
> +	int		(*ndo_bond_slave_discard)(struct net_device *slave_dev,
> +				struct net_device *bond);
>  };
>  
>  /**
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Florian
