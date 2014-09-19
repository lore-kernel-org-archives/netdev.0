From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v4 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Fri, 19 Sep 2014 12:00:04 +0200
Message-ID: <541BFEA4.9080702@redhat.com>
References: <1411077211-20117-1-git-send-email-maheshb@google.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:42818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755494AbaISKAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 06:00:19 -0400
In-Reply-To: <1411077211-20117-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2014 11:53 PM, Mahesh Bandewar wrote:
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
> 
Hello Mahesh,
This looks much better, I think we've ironed out most of the issues. A few
suggestions and one issue below.
First, I think you can fold the pr_err()s from the failing slave array
update into bond_update_slave_arr(), there's no error handling or rollback
so you can save a few lines and some complexity there and just check for
the mode and do the slave array update, if there's an error it can output
it itself. The rest is inlined below.


>  drivers/net/bonding/bond_3ad.c  |  88 +++++--------------
>  drivers/net/bonding/bond_alb.c  |  51 ++---------
>  drivers/net/bonding/bond_alb.h  |   8 --
>  drivers/net/bonding/bond_main.c | 189 ++++++++++++++++++++++++++++++++++++++--
>  drivers/net/bonding/bonding.h   |  10 +++
>  5 files changed, 218 insertions(+), 128 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 7e9e522fd476..4bf3756dcc11 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -1550,6 +1550,11 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>  				__disable_port(port);
>  			}
>  		}
> +		/* RTNL may or may not be held but bond->mode_lock
> +		 * is held. It's not safe to update slave-arr here.
> +		 * Defer it to delayed-work.
> +		 */
I don't think the information about RTNL matters, the important point is
that mode_lock is held thus we can't update so we defer it. IMO You can
drop the RTNL part here and shorten it a bit :-)

> +		bond_slave_arr_work_rearm(bond);
>  	}
>  
>  	/* if the selected aggregator is of join individuals
> @@ -1688,6 +1693,11 @@ static void ad_enable_collecting_distributing(struct port *port)
>  			 port->actor_port_number,
>  			 port->aggregator->aggregator_identifier);
>  		__enable_port(port);
> +		/* RTNL is not be held and bond->mode_lock is held.
s/is not be/is not/

> +		 * It's not safe to update slave-arr here!
> +		 * Defer it to delayed-work.
> +		 */
> +		bond_slave_arr_work_rearm(port->slave->bond);
>  	}
>  }
>  
> @@ -1704,6 +1714,11 @@ static void ad_disable_collecting_distributing(struct port *port)
>  			 port->actor_port_number,
>  			 port->aggregator->aggregator_identifier);
>  		__disable_port(port);
> +		/* RTNL is not be held and bond->mode_lock is held.
Same here.

> +		 * It's not safe to update slave-arr here!
> +		 * Defer it to delayed-work.
> +		 */
> +		bond_slave_arr_work_rearm(port->slave->bond);
>  	}
>  }
>  
> @@ -2283,6 +2298,12 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>  	port->sm_vars |= AD_PORT_BEGIN;
>  
>  	spin_unlock_bh(&slave->bond->mode_lock);
> +
> +	/* RTNL is held and mode_lock is released so it's safe
> +	 * to update slave_array here.
> +	 */
> +	if (bond_update_slave_arr(slave->bond, NULL))
> +		pr_err("Failed to build slave-array for 3ad mode.\n");
>  }
>  
>  /**
> @@ -2377,73 +2398,6 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>  	return ret;
>  }
>  
> -int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
> -{
> -	struct bonding *bond = netdev_priv(dev);
> -	struct slave *slave, *first_ok_slave;
> -	struct aggregator *agg;
> -	struct ad_info ad_info;
> -	struct list_head *iter;
> -	int slaves_in_agg;
> -	int slave_agg_no;
> -	int agg_id;
> -
> -	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
> -		netdev_dbg(dev, "__bond_3ad_get_active_agg_info failed\n");
> -		goto err_free;
> -	}
> -
> -	slaves_in_agg = ad_info.ports;
> -	agg_id = ad_info.aggregator_id;
> -
> -	if (slaves_in_agg == 0) {
> -		netdev_dbg(dev, "active aggregator is empty\n");
> -		goto err_free;
> -	}
> -
> -	slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
> -	first_ok_slave = NULL;
> -
> -	bond_for_each_slave_rcu(bond, slave, iter) {
> -		agg = SLAVE_AD_INFO(slave)->port.aggregator;
> -		if (!agg || agg->aggregator_identifier != agg_id)
> -			continue;
> -
> -		if (slave_agg_no >= 0) {
> -			if (!first_ok_slave && bond_slave_can_tx(slave))
> -				first_ok_slave = slave;
> -			slave_agg_no--;
> -			continue;
> -		}
> -
> -		if (bond_slave_can_tx(slave)) {
> -			bond_dev_queue_xmit(bond, skb, slave->dev);
> -			goto out;
> -		}
> -	}
> -
> -	if (slave_agg_no >= 0) {
> -		netdev_err(dev, "Couldn't find a slave to tx on for aggregator ID %d\n",
> -			   agg_id);
> -		goto err_free;
> -	}
> -
> -	/* we couldn't find any suitable slave after the agg_no, so use the
> -	 * first suitable found, if found.
> -	 */
> -	if (first_ok_slave)
> -		bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
> -	else
> -		goto err_free;
> -
> -out:
> -	return NETDEV_TX_OK;
> -err_free:
> -	/* no suitable interface, frame not sent */
> -	dev_kfree_skb_any(skb);
> -	goto out;
> -}
> -
>  int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>  			 struct slave *slave)
>  {
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 615f3bebd019..d2eadab787c5 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -177,7 +177,6 @@ static int tlb_initialize(struct bonding *bond)
>  static void tlb_deinitialize(struct bonding *bond)
>  {
>  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> -	struct tlb_up_slave *arr;
>  
>  	spin_lock_bh(&bond->mode_lock);
>  
> @@ -185,10 +184,6 @@ static void tlb_deinitialize(struct bonding *bond)
>  	bond_info->tx_hashtbl = NULL;
>  
>  	spin_unlock_bh(&bond->mode_lock);
> -
> -	arr = rtnl_dereference(bond_info->slave_arr);
> -	if (arr)
> -		kfree_rcu(arr, rcu);
>  }
>  
>  static long long compute_gap(struct slave *slave)
> @@ -1336,39 +1331,9 @@ out:
>  	return NETDEV_TX_OK;
>  }
>  
> -static int bond_tlb_update_slave_arr(struct bonding *bond,
> -				     struct slave *skipslave)
> -{
> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> -	struct slave *tx_slave;
> -	struct list_head *iter;
> -	struct tlb_up_slave *new_arr, *old_arr;
> -
> -	new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
> -			  GFP_ATOMIC);
> -	if (!new_arr)
> -		return -ENOMEM;
> -
> -	bond_for_each_slave(bond, tx_slave, iter) {
> -		if (!bond_slave_can_tx(tx_slave))
> -			continue;
> -		if (skipslave == tx_slave)
> -			continue;
> -		new_arr->arr[new_arr->count++] = tx_slave;
> -	}
> -
> -	old_arr = rtnl_dereference(bond_info->slave_arr);
> -	rcu_assign_pointer(bond_info->slave_arr, new_arr);
> -	if (old_arr)
> -		kfree_rcu(old_arr, rcu);
> -
> -	return 0;
> -}
> -
>  int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  {
>  	struct bonding *bond = netdev_priv(bond_dev);
> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>  	struct ethhdr *eth_data;
>  	struct slave *tx_slave = NULL;
>  	u32 hash_index;
> @@ -1389,12 +1354,14 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  							      hash_index & 0xFF,
>  							      skb->len);
>  			} else {
> -				struct tlb_up_slave *slaves;
> +				struct bond_up_slave *slaves;
> +				unsigned int count;
>  
> -				slaves = rcu_dereference(bond_info->slave_arr);
> -				if (slaves && slaves->count)
> +				slaves = rcu_dereference(bond->slave_arr);
> +				count = slaves ? ACCESS_ONCE(slaves->count) : 0;
> +				if (likely(count))
>  					tx_slave = slaves->arr[hash_index %
> -							       slaves->count];
> +							       count];
>  			}
>  			break;
>  		}
> @@ -1641,10 +1608,6 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
>  		rlb_clear_slave(bond, slave);
>  	}
>  
> -	if (bond_is_nondyn_tlb(bond))
> -		if (bond_tlb_update_slave_arr(bond, slave))
> -			pr_err("Failed to build slave-array for TLB mode.\n");
> -
>  }
>  
>  void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link)
> @@ -1669,7 +1632,7 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
>  	}
>  
>  	if (bond_is_nondyn_tlb(bond)) {
> -		if (bond_tlb_update_slave_arr(bond, NULL))
> +		if (bond_update_slave_arr(bond, NULL))
>  			pr_err("Failed to build slave-array for TLB mode.\n");
>  	}
>  }
> diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
> index 3c6a7ff974d7..1ad473b4ade5 100644
> --- a/drivers/net/bonding/bond_alb.h
> +++ b/drivers/net/bonding/bond_alb.h
> @@ -139,19 +139,11 @@ struct tlb_slave_info {
>  			 */
>  };
>  
> -struct tlb_up_slave {
> -	unsigned int	count;
> -	struct rcu_head rcu;
> -	struct slave	*arr[0];
> -};
> -
>  struct alb_bond_info {
>  	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
>  	u32			unbalanced_load;
>  	int			tx_rebalance_counter;
>  	int			lp_counter;
> -	/* -------- non-dynamic tlb mode only ---------*/
> -	struct tlb_up_slave __rcu *slave_arr;	  /* Up slaves */
>  	/* -------- rlb parameters -------- */
>  	int rlb_enabled;
>  	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 5e7987bba583..e87b802d8813 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -208,6 +208,7 @@ static int lacp_fast;
>  
>  static int bond_init(struct net_device *bond_dev);
>  static void bond_uninit(struct net_device *bond_dev);
> +static void bond_slave_arr_handler(struct work_struct *work);
>  
>  /*---------------------------- General routines -----------------------------*/
>  
> @@ -1547,6 +1548,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		unblock_netpoll_tx();
>  	}
>  
> +	if (bond_mode_uses_xmit_hash(bond) &&
> +	    bond_update_slave_arr(bond, NULL))
> +		pr_err("Failed to build slave-array.\n");
> +
>  	netdev_info(bond_dev, "Enslaving %s as %s interface with %s link\n",
>  		    slave_dev->name,
>  		    bond_is_active_slave(new_slave) ? "an active" : "a backup",
> @@ -1661,6 +1666,10 @@ static int __bond_release_one(struct net_device *bond_dev,
>  	if (BOND_MODE(bond) == BOND_MODE_8023AD)
>  		bond_3ad_unbind_slave(slave);
>  
> +	if (bond_mode_uses_xmit_hash(bond) &&
> +	    bond_update_slave_arr(bond, slave))
> +		pr_err("Failed to build slave-array.\n");
> +
>  	netdev_info(bond_dev, "Releasing %s interface %s\n",
>  		    bond_is_active_slave(slave) ? "active" : "backup",
>  		    slave_dev->name);
> @@ -1963,6 +1972,10 @@ static void bond_miimon_commit(struct bonding *bond)
>  				bond_alb_handle_link_change(bond, slave,
>  							    BOND_LINK_UP);
>  
> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
> +			    bond_update_slave_arr(bond, NULL))
> +				pr_err("Failed to build slave-array for XOR mode.\n");
> +
miimon is also supported in the other hash using modes, it's used to look
for link failure and speed/duplex changes. There's even a warning about it
for 802.3ad/TLB/ALB modes:
pr_warn("Warning: miimon must be specified, otherwise bonding will not
detect link failure, speed and duplex which are essential for 802.3ad
operation\n");
pr_warn("Forcing miimon to 100msec\n");

bond_main.c: line 4026

>  			if (!bond->curr_active_slave || slave == primary)
>  				goto do_failover;
>  
> @@ -1990,6 +2003,10 @@ static void bond_miimon_commit(struct bonding *bond)
>  				bond_alb_handle_link_change(bond, slave,
>  							    BOND_LINK_DOWN);
>  
> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
> +			    bond_update_slave_arr(bond, NULL))
> +				pr_err("Failed to build slave-array for XOR mode.\n");
> +
Same here.

>  			if (slave == rcu_access_pointer(bond->curr_active_slave))
>  				goto do_failover;
>  
> @@ -2446,6 +2463,9 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
>  
>  		if (slave_state_changed) {
>  			bond_slave_state_change(bond);
> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
> +			    bond_update_slave_arr(bond, NULL))
> +				pr_err("Failed to build slave-array for XOR mode.\n");
>  		} else if (do_failover) {
>  			block_netpoll_tx();
>  			bond_select_active_slave(bond);
> @@ -2822,8 +2842,23 @@ static int bond_slave_netdev_event(unsigned long event,
>  			if (old_duplex != slave->duplex)
>  				bond_3ad_adapter_duplex_changed(slave);
>  		}
> +		/* Refresh slave-array if applicable!
> +		 * If the setuo does not use miimon or arpmon (mode-specific!),
s/setuo/setup/

> +		 * then these event will not cause the slave-array to be
s/event/events/ ?

> +		 * refreshed. This will cause xmit to use a slave that is not
> +		 * usable. Avoid such situation by refeshing the array at these
> +		 * events. If these (miimon/arpmon) parameters are configured
> +		 * then array gets refreshed twice and that should be fine!
> +		 */
> +		if (bond_mode_uses_xmit_hash(bond) &&
> +		    bond_update_slave_arr(bond, NULL))
> +			pr_err("Failed to build slave-array.\n");
>  		break;
>  	case NETDEV_DOWN:
> +		/* Refresh slave-array if applicable! */
Please drop this comment, it doesn't bring any new information from the if().

> +		if (bond_mode_uses_xmit_hash(bond) &&
> +		    bond_update_slave_arr(bond, NULL))
> +			pr_err("Failed to build slave-array.\n");
>  		break;
>  	case NETDEV_CHANGEMTU:
>  		/* TODO: Should slaves be allowed to
> @@ -3003,6 +3038,7 @@ static void bond_work_init_all(struct bonding *bond)
>  	else
>  		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
>  	INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
> +	INIT_DELAYED_WORK(&bond->slave_arr_work, bond_slave_arr_handler);
>  }
>  
>  static void bond_work_cancel_all(struct bonding *bond)
> @@ -3012,6 +3048,7 @@ static void bond_work_cancel_all(struct bonding *bond)
>  	cancel_delayed_work_sync(&bond->alb_work);
>  	cancel_delayed_work_sync(&bond->ad_work);
>  	cancel_delayed_work_sync(&bond->mcast_work);
> +	cancel_delayed_work_sync(&bond->slave_arr_work);
>  }
>  
>  static int bond_open(struct net_device *bond_dev)
> @@ -3061,6 +3098,10 @@ static int bond_open(struct net_device *bond_dev)
>  		bond_3ad_initiate_agg_selection(bond, 1);
>  	}
>  
> +	if (bond_mode_uses_xmit_hash(bond) &&
> +	    bond_update_slave_arr(bond, NULL))
> +		pr_err("Failed to build slave-array.\n");
> +
>  	return 0;
>  }
>  
> @@ -3555,15 +3596,139 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>  	return NETDEV_TX_OK;
>  }
>  
> -/* In bond_xmit_xor() , we determine the output device by using a pre-
> - * determined xmit_hash_policy(), If the selected device is not enabled,
> - * find the next active slave.
> +/* The caller is holding bond->mode_lock and may or may not be
> + * holding RTNL.
>   */
I'd say change this comment to note that this should be used when it's not
appropriate to update the slave array right away F.e. when sleeping is not
an option or when RTNL isn't held. Currently it's only the mode_lock case,
but that may change and a more general comment would be more helpful.

> -static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
> +void bond_slave_arr_work_rearm(struct bonding *bond)
>  {
> -	struct bonding *bond = netdev_priv(bond_dev);
> +	queue_delayed_work(bond->wq, &bond->slave_arr_work, 1);
> +}
>  
> -	bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) % bond->slave_cnt);
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
> +		goto err;
> +	}
> +	return;
> +
> +err:
> +	bond_slave_arr_work_rearm(bond);
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
> +		goto out;
> +	}
> +	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
> +		struct ad_info ad_info;
> +
> +		if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
> +			pr_debug("bond_3ad_get_active_agg_info failed\n");
> +			kfree_rcu(new_arr, rcu);
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
> +		 * __bond_release_one(). In this sitation; overwrite the
s/sitation/situation/

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
> +		dev_kfree_skb_any(skb);
> +		atomic_long_inc(&dev->tx_dropped);
> +	}
>  
>  	return NETDEV_TX_OK;
>  }
> @@ -3660,12 +3825,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
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
> @@ -3839,6 +4003,7 @@ static void bond_uninit(struct net_device *bond_dev)
>  	struct bonding *bond = netdev_priv(bond_dev);
>  	struct list_head *iter;
>  	struct slave *slave;
> +	struct bond_up_slave *arr;
>  
>  	bond_netpoll_cleanup(bond_dev);
>  
> @@ -3847,6 +4012,12 @@ static void bond_uninit(struct net_device *bond_dev)
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
> index 98dc0d7ad731..4635b175256a 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -177,6 +177,12 @@ struct slave {
>  	struct kobject kobj;
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
> @@ -191,6 +197,7 @@ struct bonding {
>  	struct   slave __rcu *curr_active_slave;
>  	struct   slave __rcu *current_arp_slave;
>  	struct   slave __rcu *primary_slave;
> +	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>  	bool     force_primary;
>  	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>  	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
> @@ -220,6 +227,7 @@ struct bonding {
>  	struct   delayed_work alb_work;
>  	struct   delayed_work ad_work;
>  	struct   delayed_work mcast_work;
> +	struct   delayed_work slave_arr_work;
>  #ifdef CONFIG_DEBUG_FS
>  	/* debugging support via debugfs */
>  	struct	 dentry *debug_dir;
> @@ -531,6 +539,8 @@ const char *bond_slave_link_status(s8 link);
>  struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>  					      struct net_device *end_dev,
>  					      int level);
> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
> +void bond_slave_arr_work_rearm(struct bonding *bond);
>  
>  #ifdef CONFIG_PROC_FS
>  void bond_create_proc_entry(struct bonding *bond);
> 
