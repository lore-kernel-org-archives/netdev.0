From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v5 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Tue, 30 Sep 2014 18:10:00 +0200
Message-ID: <542AD5D8.9090602@redhat.com>
References: <1412058434-2639-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbaI3QKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 12:10:17 -0400
In-Reply-To: <1412058434-2639-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 08:27 AM, Mahesh Bandewar wrote:
> Earlier change to use usable slave array for TLB mode had an additional
> performance advantage. So extending the same logic to all other modes
> that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
> Also consolidating this with the earlier TLB change.
> 
> The main idea is to build the usable slaves array in the control path
> and use that array for slave selection during xmit operation.
> 
> Measured performance in a setup with a bond of 4x1G NICs with 200
> instances of netperf for the modes involved (3ad, xor, tlb)
> cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
> 
> Mode        TPS-Before   TPS-After
> 
> 802.3ad   : 468,694      493,101
> TLB (lb=0): 392,583      392,965
> XOR       : 475,696      484,517
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>   (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
>       the slave that need to be removed.
>   (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>       transition gracefully.
>   (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
>       failure.
>   (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
>       will populate the array even if these parameters are not used.
>   (e) 3AD: Should handle the ad_agg_selection_logic correctly.
> v2:
>   (a) Removed rcu_read_{un}lock() calls from array manipulation code.
>   (b) Slave link-events now refresh array for all these modes.
>   (c) Moved free-array call from bond_close() to bond_uninit().
> v3:
>   (a) Fixed null pointer dereference.
>   (b) Removed bond->lock lockdep dependency.
> v4:
>   (a) Made to changes to comply with Nikolay's locking changes
>   (b) Added a work-queue to refresh slave-array when RTNL is not held
>   (c) Array refresh happens ONLY with RTNL now.
>   (d) alloc changed from GFP_ATOMIC to GFP_KERNEL
> v5:
>   (a) Consolidated all delayed slave-array updates at one place in
>       3ad_state_machine_handler()
> 
>  drivers/net/bonding/bond_3ad.c  | 140 ++++++++++++------------------
>  drivers/net/bonding/bond_alb.c  |  51 ++---------
>  drivers/net/bonding/bond_alb.h  |   8 --
>  drivers/net/bonding/bond_main.c | 185 +++++++++++++++++++++++++++++++++++++---
>  drivers/net/bonding/bonding.h   |  10 +++
>  5 files changed, 242 insertions(+), 152 deletions(-)
> 

Hi Mahesh,
Mostly okay, a few 3ad comments below.

<<<<snip>>>>
> @@ -3573,20 +3605,141 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>  	return NETDEV_TX_OK;
>  }
>  
> -/* In bond_xmit_xor() , we determine the output device by using a pre-
> - * determined xmit_hash_policy(), If the selected device is not enabled,
> - * find the next active slave.
> +/* Use this to update slave_array when (a) it's not appropriate to update
> + * slave_array right away (note that update_slave_array() may sleep)
> + * and / or (b) RTNL is not held.
>   */
> -static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
> +void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay)
>  {
> -	struct bonding *bond = netdev_priv(bond_dev);
> -	int slave_cnt = ACCESS_ONCE(bond->slave_cnt);
> +	queue_delayed_work(bond->wq, &bond->slave_arr_work, delay);
> +}
>  
> -	if (likely(slave_cnt))
> -		bond_xmit_slave_id(bond, skb,
> -				   bond_xmit_hash(bond, skb) % slave_cnt);
> -	else
> +/* Slave array work handler. Holds only RTNL */
> +static void bond_slave_arr_handler(struct work_struct *work)
> +{
> +	struct bonding *bond = container_of(work, struct bonding,
> +					    slave_arr_work.work);
> +	int ret;
> +
> +	if (!rtnl_trylock())
> +		goto err;
> +
> +	ret = bond_update_slave_arr(bond, NULL);
> +	rtnl_unlock();
> +	if (ret) {
> +		pr_warn_ratelimited("Failed to update slave array from WT\n");
So again when we don't have an active slave aggregator in 3ad mode we'll
start printing error messages here and re-scheduling until an active one
appears which could be a very long time, we'll be in a rtnl acquire/release
cycle every jiffy until we have a new active aggregator.

> +		goto err;
> +	}
> +	return;
> +
> +err:
> +	bond_slave_arr_work_rearm(bond, 1);
> +}
> +
> +/* Build the usable slaves array in control path for modes that use xmit-hash
> + * to determine the slave interface -
> + * (a) BOND_MODE_8023AD
> + * (b) BOND_MODE_XOR
> + * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
> + *
> + * The caller is expected to hold RTNL only and NO other lock!
> + */
> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
> +{
> +	struct slave *slave;
> +	struct list_head *iter;
> +	struct bond_up_slave *new_arr, *old_arr;
> +	int slaves_in_agg;
> +	int agg_id = 0;
> +	int ret = 0;
> +
> +#ifdef CONFIG_LOCKDEP
> +	WARN_ON(lockdep_is_held(&bond->mode_lock));
> +#endif
> +
> +	new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
> +			  GFP_KERNEL);
> +	if (!new_arr) {
> +		ret = -ENOMEM;
> +		pr_err("Failed to build slave-array.\n");
> +		goto out;
> +	}
> +	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +		struct ad_info ad_info;
> +
> +		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
> +			pr_debug("bond_3ad_get_active_agg_info failed\n");
> +			kfree_rcu(new_arr, rcu);
We'll continue to transmit packets in 3ad mode as the old slave array will
remain in place even though there isn't an active slave aggregator any more
which is wrong.

> +			ret = -EINVAL;
> +			goto out;
> +		}
> +		slaves_in_agg = ad_info.ports;
> +		agg_id = ad_info.aggregator_id;
> +	}
> +	bond_for_each_slave(bond, slave, iter) {
> +		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +			struct aggregator *agg;
> +
> +			agg = SLAVE_AD_INFO(slave)->port.aggregator;
> +			if (!agg || agg->aggregator_identifier != agg_id)
> +				continue;
> +		}
> +		if (!bond_slave_can_tx(slave))
> +			continue;
> +		if (skipslave == slave)
> +			continue;
> +		new_arr->arr[new_arr->count++] = slave;
> +	}
> +
> +	old_arr = rtnl_dereference(bond->slave_arr);
> +	rcu_assign_pointer(bond->slave_arr, new_arr);
> +	if (old_arr)
> +		kfree_rcu(old_arr, rcu);
> +out:
> +	if (ret != 0 && skipslave) {
> +		int idx;
> +
> +		/* Rare situation where caller has asked to skip a specific
> +		 * slave but allocation failed (most likely!). BTW this is
> +		 * only possible when the call is initiated from
> +		 * __bond_release_one(). In this situation; overwrite the
> +		 * skipslave entry in the array with the last entry from the
> +		 * array to avoid a situation where the xmit path may choose
> +		 * this to-be-skipped slave to send a packet out.
> +		 */
> +		old_arr = rtnl_dereference(bond->slave_arr);
> +		for (idx = 0; idx < old_arr->count; idx++) {
> +			if (skipslave == old_arr->arr[idx]) {
> +				old_arr->arr[idx] =
> +				    old_arr->arr[old_arr->count-1];
> +				old_arr->count--;
> +				break;
> +			}
> +		}
> +	}
> +	return ret;
> +}
> +
> +/* Use this Xmit function for 3AD as well as XOR modes. The current
> + * usable slave array is formed in the control path. The xmit function
> + * just calculates hash and sends the packet out.
> + */
> +int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct bonding *bond = netdev_priv(dev);
> +	struct slave *slave;
> +	struct bond_up_slave *slaves;
> +	unsigned int count;
> +
> +	slaves = rcu_dereference(bond->slave_arr);
> +	count = slaves ? ACCESS_ONCE(slaves->count) : 0;
> +	if (likely(count)) {
> +		slave = slaves->arr[bond_xmit_hash(bond, skb) % count];
> +		bond_dev_queue_xmit(bond, skb, slave->dev);
> +	} else {
>  		dev_kfree_skb_any(skb);
> +		atomic_long_inc(&dev->tx_dropped);
> +	}
>  
>  	return NETDEV_TX_OK;
>  }
> @@ -3682,12 +3835,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
>  		return bond_xmit_roundrobin(skb, dev);
>  	case BOND_MODE_ACTIVEBACKUP:
>  		return bond_xmit_activebackup(skb, dev);
> +	case BOND_MODE_8023AD:
>  	case BOND_MODE_XOR:
> -		return bond_xmit_xor(skb, dev);
> +		return bond_3ad_xor_xmit(skb, dev);
>  	case BOND_MODE_BROADCAST:
>  		return bond_xmit_broadcast(skb, dev);
> -	case BOND_MODE_8023AD:
> -		return bond_3ad_xmit_xor(skb, dev);
>  	case BOND_MODE_ALB:
>  		return bond_alb_xmit(skb, dev);
>  	case BOND_MODE_TLB:
> @@ -3861,6 +4013,7 @@ static void bond_uninit(struct net_device *bond_dev)
>  	struct bonding *bond = netdev_priv(bond_dev);
>  	struct list_head *iter;
>  	struct slave *slave;
> +	struct bond_up_slave *arr;
>  
>  	bond_netpoll_cleanup(bond_dev);
>  
> @@ -3869,6 +4022,12 @@ static void bond_uninit(struct net_device *bond_dev)
>  		__bond_release_one(bond_dev, slave->dev, true);
>  	netdev_info(bond_dev, "Released all slaves\n");
>  
> +	arr = rtnl_dereference(bond->slave_arr);
> +	if (arr) {
> +		kfree_rcu(arr, rcu);
> +		RCU_INIT_POINTER(bond->slave_arr, NULL);
> +	}
> +
>  	list_del(&bond->bond_list);
>  
>  	bond_debug_unregister(bond);
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 5b022da9cad2..10920f0686e2 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -179,6 +179,12 @@ struct slave {
>  	struct rtnl_link_stats64 slave_stats;
>  };
>  
> +struct bond_up_slave {
> +	unsigned int	count;
> +	struct rcu_head rcu;
> +	struct slave	*arr[0];
> +};
> +
>  /*
>   * Link pseudo-state only used internally by monitors
>   */
> @@ -193,6 +199,7 @@ struct bonding {
>  	struct   slave __rcu *curr_active_slave;
>  	struct   slave __rcu *current_arp_slave;
>  	struct   slave __rcu *primary_slave;
> +	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>  	bool     force_primary;
>  	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>  	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
> @@ -222,6 +229,7 @@ struct bonding {
>  	struct   delayed_work alb_work;
>  	struct   delayed_work ad_work;
>  	struct   delayed_work mcast_work;
> +	struct   delayed_work slave_arr_work;
>  #ifdef CONFIG_DEBUG_FS
>  	/* debugging support via debugfs */
>  	struct	 dentry *debug_dir;
> @@ -534,6 +542,8 @@ const char *bond_slave_link_status(s8 link);
>  struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>  					      struct net_device *end_dev,
>  					      int level);
> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
> +void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay);
>  
>  #ifdef CONFIG_PROC_FS
>  void bond_create_proc_entry(struct bonding *bond);
> 
