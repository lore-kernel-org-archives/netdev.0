From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2] bonding: move bond-specific init after enslave
 happens
Date: Tue, 22 Oct 2013 15:38:49 +0800
Message-ID: <52662B89.9010406@huawei.com>
References: <1382348910-32724-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:28207 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390Ab3JVHjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 03:39:06 -0400
In-Reply-To: <1382348910-32724-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/10/21 17:48, Veaceslav Falico wrote:
> As Jiri noted, currently we first do all bonding-specific initialization
> (specifically - bond_select_active_slave(bond)) before we actually attach
> the slave (so that it becomes visible through bond_for_each_slave() and
> friends). This might result in bond_select_active_slave() not seeing the
> first/new slave and, thus, not actually selecting an active slave.
> 
> Fix this by moving all the bond-related init part after we've actually
> completely initialized and linked (via bond_master_upper_dev_link()) the
> new slave.
> 
> Also, remove the bond_(de/a)ttach_slave(), it's useless to have functions
> to ++/-- one int.
> 
> After this we have all the initialization of the new slave *before*
> linking, and all the stuff that needs to be done on bonding *after* it. It
> has also a bonus effect - we can remove the locking on the new slave init
> completely, and only use it for bond_select_active_slave().
> 
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
> 
> Notes:
>     v1 -> v2:
>     Move the bond_(de/a)ttach_slave() functionality, and remove these
>     functions.
> 
>  drivers/net/bonding/bond_main.c | 65 +++++++++--------------------------------
>  1 file changed, 14 insertions(+), 51 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index d90734f..2daa066 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -967,33 +967,6 @@ void bond_select_active_slave(struct bonding *bond)
>  	}
>  }
>  
> -/*--------------------------- slave list handling ---------------------------*/
> -
> -/*
> - * This function attaches the slave to the end of list.
> - *
> - * bond->lock held for writing by caller.
> - */
> -static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
> -{
> -	bond->slave_cnt++;
> -}
> -
> -/*
> - * This function detaches the slave from the list.
> - * WARNING: no check is made to verify if the slave effectively
> - * belongs to <bond>.
> - * Nothing is freed on return, structures are just unchained.
> - * If any slave pointer in bond was pointing to <slave>,
> - * it should be changed by the calling function.
> - *
> - * bond->lock held for writing by caller.
> - */
> -static void bond_detach_slave(struct bonding *bond, struct slave *slave)
> -{
> -	bond->slave_cnt--;
> -}
> -
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static inline int slave_enable_netpoll(struct slave *slave)
>  {
> @@ -1471,22 +1444,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		goto err_close;
>  	}
>  
> -	write_lock_bh(&bond->lock);
> -
>  	prev_slave = bond_last_slave(bond);
> -	bond_attach_slave(bond, new_slave);
>  
>  	new_slave->delay = 0;
>  	new_slave->link_failure_count = 0;
>  
> -	write_unlock_bh(&bond->lock);
> -
> -	bond_compute_features(bond);
> -
>  	bond_update_speed_duplex(new_slave);
>  
> -	read_lock(&bond->lock);
> -
>  	new_slave->last_arp_rx = jiffies -
>  		(msecs_to_jiffies(bond->params.arp_interval) + 1);
>  	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
> @@ -1547,12 +1511,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		}
>  	}
>  
> -	write_lock_bh(&bond->curr_slave_lock);
> -
>  	switch (bond->params.mode) {
>  	case BOND_MODE_ACTIVEBACKUP:
>  		bond_set_slave_inactive_flags(new_slave);
> -		bond_select_active_slave(bond);
>  		break;
>  	case BOND_MODE_8023AD:
>  		/* in 802.3ad mode, the internal mechanism
> @@ -1578,7 +1539,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	case BOND_MODE_ALB:
>  		bond_set_active_slave(new_slave);
>  		bond_set_slave_inactive_flags(new_slave);
> -		bond_select_active_slave(bond);
>  		break;
>  	default:
>  		pr_debug("This slave is always active in trunk mode\n");
> @@ -1596,10 +1556,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		break;
>  	} /* switch(bond_mode) */
>  
> -	write_unlock_bh(&bond->curr_slave_lock);
> -
> -	bond_set_carrier(bond);
> -
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	slave_dev->npinfo = bond->dev->npinfo;
>  	if (slave_dev->npinfo) {
> @@ -1614,8 +1570,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	}
>  #endif
>  
> -	read_unlock(&bond->lock);
> -
>  	res = netdev_rx_handler_register(slave_dev, bond_handle_frame,
>  					 new_slave);
>  	if (res) {
> @@ -1629,6 +1583,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		goto err_unregister;
>  	}
>  
> +	bond->slave_cnt++;
> +	bond_compute_features(bond);
> +	bond_set_carrier(bond);
> +
> +	if (USES_PRIMARY(bond->params.mode)) {
> +		read_lock(&bond->lock);
> +		write_lock_bh(&bond->curr_slave_lock);
> +		bond_select_active_slave(bond);
> +		write_unlock_bh(&bond->curr_slave_lock);
> +		read_unlock(&bond->lock);
> +	}
>  
>  	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
>  		bond_dev->name, slave_dev->name,
> @@ -1648,7 +1613,6 @@ err_detach:
>  
>  	vlan_vids_del_by_dev(slave_dev, bond_dev);
>  	write_lock_bh(&bond->lock);
> -	bond_detach_slave(bond, new_slave);
>  	if (bond->primary_slave == new_slave)
>  		bond->primary_slave = NULL;
>  	if (bond->curr_active_slave == new_slave) {
> @@ -1686,7 +1650,6 @@ err_free:
>  	kfree(new_slave);
>  
>  err_undo_flags:
> -	bond_compute_features(bond);
>  	/* Enslave of first slave has failed and we need to fix master's mac */
>  	if (!bond_has_slaves(bond) &&
>  	    ether_addr_equal(bond_dev->dev_addr, slave_dev->dev_addr))
> @@ -1740,6 +1703,9 @@ static int __bond_release_one(struct net_device *bond_dev,
>  
>  	write_unlock_bh(&bond->lock);
>  
> +	/* release the slave from its bond */
> +	bond->slave_cnt--;
> +
>  	bond_upper_dev_unlink(bond_dev, slave_dev);
>  	/* unregister rx_handler early so bond_handle_frame wouldn't be called
>  	 * for this slave anymore.
> @@ -1764,9 +1730,6 @@ static int __bond_release_one(struct net_device *bond_dev,
>  
>  	bond->current_arp_slave = NULL;
>  
> -	/* release the slave from its bond */
> -	bond_detach_slave(bond, slave);
> -
>  	if (!all && !bond->params.fail_over_mac) {
>  		if (ether_addr_equal(bond_dev->dev_addr, slave->perm_hwaddr) &&
>  		    bond_has_slaves(bond))
> 

Acked-by: Ding Tianhong@huawei.com
