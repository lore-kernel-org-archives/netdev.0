From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Tue, 8 Mar 2011 08:43:49 -0500
Message-ID: <20110308134348.GB19072@hmsreliant.think-freely.org>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48819 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754469Ab1CHNn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 08:43:56 -0500
Content-Disposition: inline
In-Reply-To: <1299578336-5888-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2011 at 05:58:56PM +0800, Amerigo Wang wrote:
> V2: avoid calling slave_diable_netpoll() with write_lock_bh() held.
> 
> netconsole doesn't work in active-backup mode, because we don't do anything
> for nic failover in active-backup mode. We should disable netpoll on the
> failing slave when it is detected down and enable netpoll when it becomes
> the active slave.
> 
You still haven't explained why it needs to be this way.  what exactly is the
shortcomming with leaving netpoll enabled on all slaves, regardless of state?
It should be sufficient if, during a failover in a mode where the inactive slave
should not tx data, that you simply clear the slave __LINK_STATE_START bit.  That will
prevent higher layers from sending any queued data without you needing to muck
about with netpoll state.

Neil

> Tested by ifdown the current active slave and ifup it again for several times,
> netconsole works well.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> 
> ---
> 
>  drivers/net/bonding/bond_main.c |  236 +++++++++++++++++++++------------------
>  1 files changed, 125 insertions(+), 111 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0592e6d..102a558 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -907,6 +907,120 @@ static void bond_mc_list_flush(struct net_device *bond_dev,
>  	}
>  }
>  
> +/*--------------------------- Netpoll code ---------------------------*/
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static inline int slave_enable_netpoll(struct slave *slave)
> +{
> +	struct netpoll *np;
> +	int err = 0;
> +
> +	if (slave->np)
> +		return 0;
> +
> +	np = kzalloc(sizeof(*np), GFP_KERNEL);
> +	err = -ENOMEM;
> +	if (!np)
> +		goto out;
> +
> +	np->dev = slave->dev;
> +	err = __netpoll_setup(np);
> +	if (err) {
> +		kfree(np);
> +		goto out;
> +	}
> +	slave->np = np;
> +out:
> +	return err;
> +}
> +static inline void slave_disable_netpoll(struct slave *slave)
> +{
> +	struct netpoll *np = slave->np;
> +
> +	if (!np)
> +		return;
> +
> +	slave->np = NULL;
> +	synchronize_rcu_bh();
> +	__netpoll_cleanup(np);
> +	kfree(np);
> +}
> +static inline bool slave_dev_support_netpoll(struct net_device *slave_dev)
> +{
> +	if (slave_dev->priv_flags & IFF_DISABLE_NETPOLL)
> +		return false;
> +	if (!slave_dev->netdev_ops->ndo_poll_controller)
> +		return false;
> +	return true;
> +}
> +
> +static void bond_poll_controller(struct net_device *bond_dev)
> +{
> +}
> +
> +static void __bond_netpoll_cleanup(struct bonding *bond)
> +{
> +	struct slave *slave;
> +	int i;
> +
> +	bond_for_each_slave(bond, slave, i)
> +		if (IS_UP(slave->dev))
> +			slave_disable_netpoll(slave);
> +}
> +static void bond_netpoll_cleanup(struct net_device *bond_dev)
> +{
> +	struct bonding *bond = netdev_priv(bond_dev);
> +
> +	read_lock(&bond->lock);
> +	__bond_netpoll_cleanup(bond);
> +	read_unlock(&bond->lock);
> +}
> +
> +static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
> +{
> +	struct bonding *bond = netdev_priv(dev);
> +	struct slave *slave;
> +	int i, err = 0;
> +
> +	read_lock(&bond->lock);
> +	bond_for_each_slave(bond, slave, i) {
> +		if (!IS_UP(slave->dev))
> +			continue;
> +		err = slave_enable_netpoll(slave);
> +		if (err) {
> +			__bond_netpoll_cleanup(bond);
> +			break;
> +		}
> +	}
> +	read_unlock(&bond->lock);
> +	return err;
> +}
> +
> +static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> +{
> +	return bond->dev->npinfo;
> +}
> +
> +#else
> +static inline int slave_enable_netpoll(struct slave *slave)
> +{
> +	return 0;
> +}
> +static inline void slave_disable_netpoll(struct slave *slave)
> +{
> +}
> +static void bond_netpoll_cleanup(struct net_device *bond_dev)
> +{
> +}
> +static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
> +{
> +	return 0;
> +}
> +static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> +{
> +	return NULL;
> +}
> +#endif
> +
>  /*--------------------------- Active slave change ---------------------------*/
>  
>  /*
> @@ -1159,6 +1273,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>  			bond_set_slave_inactive_flags(old_active);
>  
>  		if (new_active) {
> +			struct netpoll_info *ni;
>  			bond_set_slave_active_flags(new_active);
>  
>  			if (bond->params.fail_over_mac)
> @@ -1174,6 +1289,13 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>  			}
>  
>  			write_unlock_bh(&bond->curr_slave_lock);
> +
> +			ni = bond_netpoll_info(bond);
> +			if (ni) {
> +				new_active->dev->npinfo = ni;
> +				slave_enable_netpoll(new_active);
> +			}
> +
>  			read_unlock(&bond->lock);
>  
>  			netdev_bonding_change(bond->dev, NETDEV_BONDING_FAILOVER);
> @@ -1280,116 +1402,6 @@ static void bond_detach_slave(struct bonding *bond, struct slave *slave)
>  	bond->slave_cnt--;
>  }
>  
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -static inline int slave_enable_netpoll(struct slave *slave)
> -{
> -	struct netpoll *np;
> -	int err = 0;
> -
> -	np = kzalloc(sizeof(*np), GFP_KERNEL);
> -	err = -ENOMEM;
> -	if (!np)
> -		goto out;
> -
> -	np->dev = slave->dev;
> -	err = __netpoll_setup(np);
> -	if (err) {
> -		kfree(np);
> -		goto out;
> -	}
> -	slave->np = np;
> -out:
> -	return err;
> -}
> -static inline void slave_disable_netpoll(struct slave *slave)
> -{
> -	struct netpoll *np = slave->np;
> -
> -	if (!np)
> -		return;
> -
> -	slave->np = NULL;
> -	synchronize_rcu_bh();
> -	__netpoll_cleanup(np);
> -	kfree(np);
> -}
> -static inline bool slave_dev_support_netpoll(struct net_device *slave_dev)
> -{
> -	if (slave_dev->priv_flags & IFF_DISABLE_NETPOLL)
> -		return false;
> -	if (!slave_dev->netdev_ops->ndo_poll_controller)
> -		return false;
> -	return true;
> -}
> -
> -static void bond_poll_controller(struct net_device *bond_dev)
> -{
> -}
> -
> -static void __bond_netpoll_cleanup(struct bonding *bond)
> -{
> -	struct slave *slave;
> -	int i;
> -
> -	bond_for_each_slave(bond, slave, i)
> -		if (IS_UP(slave->dev))
> -			slave_disable_netpoll(slave);
> -}
> -static void bond_netpoll_cleanup(struct net_device *bond_dev)
> -{
> -	struct bonding *bond = netdev_priv(bond_dev);
> -
> -	read_lock(&bond->lock);
> -	__bond_netpoll_cleanup(bond);
> -	read_unlock(&bond->lock);
> -}
> -
> -static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
> -{
> -	struct bonding *bond = netdev_priv(dev);
> -	struct slave *slave;
> -	int i, err = 0;
> -
> -	read_lock(&bond->lock);
> -	bond_for_each_slave(bond, slave, i) {
> -		if (!IS_UP(slave->dev))
> -			continue;
> -		err = slave_enable_netpoll(slave);
> -		if (err) {
> -			__bond_netpoll_cleanup(bond);
> -			break;
> -		}
> -	}
> -	read_unlock(&bond->lock);
> -	return err;
> -}
> -
> -static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> -{
> -	return bond->dev->npinfo;
> -}
> -
> -#else
> -static inline int slave_enable_netpoll(struct slave *slave)
> -{
> -	return 0;
> -}
> -static inline void slave_disable_netpoll(struct slave *slave)
> -{
> -}
> -static void bond_netpoll_cleanup(struct net_device *bond_dev)
> -{
> -}
> -static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
> -{
> -	return 0;
> -}
> -static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> -{
> -	return NULL;
> -}
> -#endif
> -
>  /*---------------------------------- IOCTL ----------------------------------*/
>  
>  static int bond_sethwaddr(struct net_device *bond_dev,
> @@ -2532,8 +2544,10 @@ static void bond_miimon_commit(struct bonding *bond)
>  				bond_alb_handle_link_change(bond, slave,
>  							    BOND_LINK_DOWN);
>  
> -			if (slave == bond->curr_active_slave)
> +			if (slave == bond->curr_active_slave) {
> +				slave_disable_netpoll(slave);
>  				goto do_failover;
> +			}
>  
>  			continue;
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
