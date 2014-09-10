From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Wed, 10 Sep 2014 15:20:37 +0200
Message-ID: <54105025.9040802@redhat.com>
References: <1410309999-10596-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
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
Received: from mx1.redhat.com ([209.132.183.28]:48176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbaIJNUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:20:54 -0400
In-Reply-To: <1410309999-10596-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/14 02:46, Mahesh Bandewar wrote:
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
>    (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
>        the slave that need to be removed.
>    (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>        transition gracefully.
>    (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
>        failure.
>    (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
>        will populate the array even if these parameters are not used.
>    (e) 3AD: Should handle the ad_agg_selection_logic correctly.
> v2:
>    (a) Removed rcu_read_{un}lock() calls from array manipulation code.
>    (b) Slave link-events now refresh array for all these modes.
>    (c) Moved free-array call from bond_close() to bond_uninit().
>
>   drivers/net/bonding/bond_3ad.c  |  76 +++----------------
>   drivers/net/bonding/bond_alb.c  |  51 ++-----------
>   drivers/net/bonding/bond_alb.h  |   8 --
>   drivers/net/bonding/bond_main.c | 158 +++++++++++++++++++++++++++++++++++++---
>   drivers/net/bonding/bonding.h   |   8 ++
>   5 files changed, 170 insertions(+), 131 deletions(-)
>
Hello Mahesh,
First a question, if a bond device in XOR mode is up and we enslave a single 
slave how would it start transmitting ? Same question, if we are enslaving a 
second device then the array will be rebuild with only the first upon NETDEV_UP 
(of course all this is in the case miimon is 0).
The NETDEV_UP upon enslave happens before the slave is linked in.
One side note, you can now simplify these patches and drop the checks for 
bond->lock since Dave applied my patches.

A few more important problems below.

> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index ee2c73a9de39..1549e718074a 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -1579,6 +1579,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>   				__disable_port(port);
>   			}
>   		}
> +		if (bond_update_slave_arr(bond, NULL))
> +			pr_err("Failed to build slave-array for 3ad mode.\n");
>   	}
>
>   	/* if the selected aggregator is of join individuals
> @@ -1717,6 +1719,8 @@ static void ad_enable_collecting_distributing(struct port *port)
>   			 port->actor_port_number,
>   			 port->aggregator->aggregator_identifier);
>   		__enable_port(port);
> +		if (bond_update_slave_arr(port->slave->bond, NULL))
> +			pr_err("Failed to build slave-array for 3ad mode.\n");
>   	}
>   }
>
> @@ -1733,6 +1737,8 @@ static void ad_disable_collecting_distributing(struct port *port)
>   			 port->actor_port_number,
>   			 port->aggregator->aggregator_identifier);
>   		__disable_port(port);
> +		if (bond_update_slave_arr(port->slave->bond, NULL))
> +			pr_err("Failed to build slave-array for 3ad mode.\n");
>   	}
>   }
>
> @@ -2311,6 +2317,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>   	 */
>   	port->sm_vars |= AD_PORT_BEGIN;
>
> +	if (bond_update_slave_arr(slave->bond, NULL))
> +		pr_err("Failed to build slave-array for 3ad mode.\n");
> +
>   	__release_state_machine_lock(port);
>   }
>
> @@ -2407,73 +2416,6 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>   	return ret;
>   }
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
>   int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>   			 struct slave *slave)
>   {
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 73c21e233131..c44cabd8f2ba 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -200,7 +200,6 @@ static int tlb_initialize(struct bonding *bond)
>   static void tlb_deinitialize(struct bonding *bond)
>   {
>   	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> -	struct tlb_up_slave *arr;
>
>   	_lock_tx_hashtbl_bh(bond);
>
> @@ -208,10 +207,6 @@ static void tlb_deinitialize(struct bonding *bond)
>   	bond_info->tx_hashtbl = NULL;
>
>   	_unlock_tx_hashtbl_bh(bond);
> -
> -	arr = rtnl_dereference(bond_info->slave_arr);
> -	if (arr)
> -		kfree_rcu(arr, rcu);
>   }
>
>   static long long compute_gap(struct slave *slave)
> @@ -1409,39 +1404,9 @@ out:
>   	return NETDEV_TX_OK;
>   }
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
>   int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>   {
>   	struct bonding *bond = netdev_priv(bond_dev);
> -	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>   	struct ethhdr *eth_data;
>   	struct slave *tx_slave = NULL;
>   	u32 hash_index;
> @@ -1462,12 +1427,14 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>   							      hash_index & 0xFF,
>   							      skb->len);
>   			} else {
> -				struct tlb_up_slave *slaves;
> +				struct bond_up_slave *slaves;
> +				unsigned int count;
>
> -				slaves = rcu_dereference(bond_info->slave_arr);
> -				if (slaves && slaves->count)
> +				slaves = rcu_dereference(bond->slave_arr);
> +				count = slaves->count;
^^^^^^^^^^^^^^^
What happens if slaves is still NULL ? We'll dereference a NULL pointer here.
I'm beginning to think you don't test these submissions at all, I hit the 
obvious NULL pointer dereference immediately after trying to enslave a device in 
XOR mode with these patches applied.

> +				if (slaves && count)
>   					tx_slave = slaves->arr[hash_index %
> -							       slaves->count];
> +							       count];
>   			}
>   			break;
>   		}
> @@ -1733,10 +1700,6 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
>   		rlb_clear_slave(bond, slave);
>   	}
>
> -	if (bond_is_nondyn_tlb(bond))
> -		if (bond_tlb_update_slave_arr(bond, slave))
> -			pr_err("Failed to build slave-array for TLB mode.\n");
> -
>   }
>
>   /* Caller must hold bond lock for read */
> @@ -1762,7 +1725,7 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
>   	}
>
>   	if (bond_is_nondyn_tlb(bond)) {
> -		if (bond_tlb_update_slave_arr(bond, NULL))
> +		if (bond_update_slave_arr(bond, NULL))
>   			pr_err("Failed to build slave-array for TLB mode.\n");
>   	}
>   }
> diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
> index aaeac61d03cf..5fc76c01636c 100644
> --- a/drivers/net/bonding/bond_alb.h
> +++ b/drivers/net/bonding/bond_alb.h
> @@ -139,20 +139,12 @@ struct tlb_slave_info {
>   			 */
>   };
>
> -struct tlb_up_slave {
> -	unsigned int	count;
> -	struct rcu_head rcu;
> -	struct slave	*arr[0];
> -};
> -
>   struct alb_bond_info {
>   	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
>   	spinlock_t		tx_hashtbl_lock;
>   	u32			unbalanced_load;
>   	int			tx_rebalance_counter;
>   	int			lp_counter;
> -	/* -------- non-dynamic tlb mode only ---------*/
> -	struct tlb_up_slave __rcu *slave_arr;	  /* Up slaves */
>   	/* -------- rlb parameters -------- */
>   	int rlb_enabled;
>   	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index f0f5eab0fab1..456cda67383b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1693,6 +1693,10 @@ static int __bond_release_one(struct net_device *bond_dev,
>   	if (BOND_MODE(bond) == BOND_MODE_8023AD)
>   		bond_3ad_unbind_slave(slave);
>
> +	if (bond_mode_uses_xmit_hash(bond) &&
> +	    bond_update_slave_arr(bond, slave))
> +		pr_err("Failed to build slave-array.\n");
> +
>   	write_unlock_bh(&bond->lock);
>
>   	netdev_info(bond_dev, "Releasing %s interface %s\n",
> @@ -2009,6 +2013,10 @@ static void bond_miimon_commit(struct bonding *bond)
>   				bond_alb_handle_link_change(bond, slave,
>   							    BOND_LINK_UP);
>
> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
> +			    bond_update_slave_arr(bond, NULL))
> +				pr_err("Failed to build slave-array for XOR mode.\n");
> +
>   			if (!bond->curr_active_slave ||
>   			    (slave == bond->primary_slave))
>   				goto do_failover;
> @@ -2037,6 +2045,10 @@ static void bond_miimon_commit(struct bonding *bond)
>   				bond_alb_handle_link_change(bond, slave,
>   							    BOND_LINK_DOWN);
>
> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
> +			    bond_update_slave_arr(bond, NULL))
> +				pr_err("Failed to build slave-array for XOR mode.\n");
> +
>   			if (slave == rcu_access_pointer(bond->curr_active_slave))
>   				goto do_failover;
>
> @@ -2500,6 +2512,9 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
>
>   		if (slave_state_changed) {
>   			bond_slave_state_change(bond);
> +			if (BOND_MODE(bond) == BOND_MODE_XOR &&
> +			    bond_update_slave_arr(bond, NULL))
> +				pr_err("Failed to build slave-array for XOR mode.\n");
>   		} else if (do_failover) {
>   			/* the bond_select_active_slave must hold RTNL
>   			 * and curr_slave_lock for write.
> @@ -2893,11 +2908,23 @@ static int bond_slave_netdev_event(unsigned long event,
>   			if (old_duplex != slave->duplex)
>   				bond_3ad_adapter_duplex_changed(slave);
>   		}
> +		/* Refresh slave-array if applicable!
> +		 * If the setuo does not use miimon or arpmon (mode-specific!),
> +		 * then these event will not cause the slave-array to be
> +		 * refreshed. This will cause xmit to use a slave that is not
> +		 * usable. Avoid such situation by refeshing the array at these
> +		 * events. If these (miimon/arpmon) parameters are configured
> +		 * then array gets refreshed twice and that should be fine!
> +		 */
> +		if (bond_mode_uses_xmit_hash(bond) &&
> +		    bond_update_slave_arr(bond, NULL))
> +			pr_err("Failed to build slave-array for XOR mode.\n");
>   		break;
>   	case NETDEV_DOWN:
> -		/*
> -		 * ... Or is it this?
> -		 */
> +		/* Refresh slave-array if applicable! */
> +		if (bond_mode_uses_xmit_hash(bond) &&
> +		    bond_update_slave_arr(bond, NULL))
> +			pr_err("Failed to build slave-array for XOR mode.\n");
>   		break;
>   	case NETDEV_CHANGEMTU:
>   		/*
> @@ -3143,6 +3170,10 @@ static int bond_open(struct net_device *bond_dev)
>   		bond_3ad_initiate_agg_selection(bond, 1);
>   	}
>
> +	if (bond_mode_uses_xmit_hash(bond) &&
> +	    bond_update_slave_arr(bond, NULL))
> +		pr_err("Failed to build slave-array for XOR mode.\n");
> +
>   	return 0;
>   }
>
> @@ -3684,15 +3715,112 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>   	return NETDEV_TX_OK;
>   }
>
> -/* In bond_xmit_xor() , we determine the output device by using a pre-
> - * determined xmit_hash_policy(), If the selected device is not enabled,
> - * find the next active slave.
> +/* Build the usable slaves array in control path for modes that use xmit-hash
> + * to determine the slave interface -
> + * (a) BOND_MODE_8023AD
> + * (b) BOND_MODE_XOR
> + * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
>    */
> -static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>   {
> -	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	struct list_head *iter;
> +	struct bond_up_slave *new_arr, *old_arr;
> +	int slaves_in_agg;
> +	int agg_id = 0;
> +	int ret = 0;
> +
> +	if (!bond_has_slaves(bond))
> +	    goto out;
> +
> +	new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
> +			  GFP_ATOMIC);
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
>
> -	bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) % bond->slave_cnt);
> +	old_arr = rcu_dereference_protected(bond->slave_arr,
> +					    lockdep_rtnl_is_held() ||
> +					    lockdep_is_held(&bond->lock) ||
> +					    lockdep_is_held(&bond->curr_slave_lock));
> +	rcu_assign_pointer(bond->slave_arr, new_arr);
> +	if (old_arr)
> +		kfree_rcu(old_arr, rcu);
> +
> +out:
> +	if (ret != 0 && skipslave) {
> +		int idx;
> +
> +		/* Rare situation where caller has asked to skip a specific
> +		 * slave but allocation failed (most likely!). BTW this is
> +		 * only possible when the call is initiated from
> +		 * __bond_release_one(). In this sitation; overwrite the
> +		 * skipslave entry in the array with the last entry from the
> +		 * array to avoid a situation where the xmit path may choose
> +		 * this to-be-skipped slave to send a packet out.
> +		 */
> +		old_arr = rcu_dereference_protected(bond->slave_arr,
> +					    lockdep_is_held(&bond->lock) &&
> +					    lockdep_rtnl_is_held());
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
> +	count = slaves->count;
^^^^^^^^^^^
Same here, if slaves is NULL we'll dereference a NULL ptr.

> +	if (slaves && count) {
> +		slave = slaves->arr[bond_xmit_hash(bond, skb) % count];
> +		bond_dev_queue_xmit(bond, skb, slave->dev);
> +	} else {
> +		dev_kfree_skb_any(skb);
> +		atomic_long_inc(&dev->tx_dropped);
> +	}
>
>   	return NETDEV_TX_OK;
>   }
> @@ -3794,12 +3922,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
>   		return bond_xmit_roundrobin(skb, dev);
>   	case BOND_MODE_ACTIVEBACKUP:
>   		return bond_xmit_activebackup(skb, dev);
> +	case BOND_MODE_8023AD:
>   	case BOND_MODE_XOR:
> -		return bond_xmit_xor(skb, dev);
> +		return bond_3ad_xor_xmit(skb, dev);
>   	case BOND_MODE_BROADCAST:
>   		return bond_xmit_broadcast(skb, dev);
> -	case BOND_MODE_8023AD:
> -		return bond_3ad_xmit_xor(skb, dev);
>   	case BOND_MODE_ALB:
>   		return bond_alb_xmit(skb, dev);
>   	case BOND_MODE_TLB:
> @@ -3980,6 +4107,7 @@ static void bond_uninit(struct net_device *bond_dev)
>   	struct bonding *bond = netdev_priv(bond_dev);
>   	struct list_head *iter;
>   	struct slave *slave;
> +	struct bond_up_slave *arr;
>
>   	bond_netpoll_cleanup(bond_dev);
>
> @@ -3988,6 +4116,12 @@ static void bond_uninit(struct net_device *bond_dev)
>   		__bond_release_one(bond_dev, slave->dev, true);
>   	netdev_info(bond_dev, "Released all slaves\n");
>
> +	arr = rtnl_dereference(bond->slave_arr);
> +	if (arr) {
> +		kfree_rcu(arr, rcu);
> +		RCU_INIT_POINTER(bond->slave_arr, NULL);
> +	}
> +
>   	list_del(&bond->bond_list);
>
>   	bond_debug_unregister(bond);
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 64b36ba65b89..5642cccd4469 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -177,6 +177,12 @@ struct slave {
>   	struct kobject kobj;
>   };
>
> +struct bond_up_slave {
> +	unsigned int	count;
> +	struct rcu_head rcu;
> +	struct slave	*arr[0];
> +};
> +
>   /*
>    * Link pseudo-state only used internally by monitors
>    */
> @@ -196,6 +202,7 @@ struct bonding {
>   	struct   slave __rcu *curr_active_slave;
>   	struct   slave __rcu *current_arp_slave;
>   	struct   slave *primary_slave;
> +	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>   	bool     force_primary;
>   	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>   	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
> @@ -534,6 +541,7 @@ const char *bond_slave_link_status(s8 link);
>   struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>   					      struct net_device *end_dev,
>   					      int level);
> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>
>   #ifdef CONFIG_PROC_FS
>   void bond_create_proc_entry(struct bonding *bond);
>
