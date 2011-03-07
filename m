From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch] bonding: fix netpoll in active-backup mode
Date: Mon, 7 Mar 2011 13:50:38 -0500
Message-ID: <20110307185038.GA31788@hmsreliant.think-freely.org>
References: <1299507114-12144-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58819 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab1CGSuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 13:50:52 -0500
Content-Disposition: inline
In-Reply-To: <1299507114-12144-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 10:11:50PM +0800, Amerigo Wang wrote:
> netconsole doesn't work in active-backup mode, because we don't do anything
> for nic failover in active-backup mode. This patch fixes the problem by:
> 
> 1) make slave_enable_netpoll() and slave_disable_netpoll() callable in softirq
>    context, that is, moving code after synchronize_rcu_bh() into call_rcu_bh()
>    callback function, teaching kzalloc() to use GFP_ATOMIC.
> 
> 2) disable netpoll on old slave and enable netpoll on the new slave.
> 
> Tested by ifdown the current active slave and ifup it again for several times,
> netconsole works well.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
I may be missing soething but this seems way over-complicated to me.  I presume
the problem is that in active backup mode a failover results in the new active
slave not having netpoll setup on it?  If thats the case, why not just setup
netpoll on all slaves when ndo_netpoll_setup is called on the bonding interface?
I don't see anything immeidately catastrophic that would happen as a result.
And then you wouldn't have to worry about disabling/enabling anything on a
failover (or during a panic for that matter).  As for the rcu bits?  Why are
they needed?  One would presume that wouldn't (or at least shouldn't) be able to
teardown our netpoll setup until such time as all the pending frames for that
netpoll client have been transmitted.  If we're not blocknig on that RCU isn't
really going to help.  Seems like the proper fix is take a reference to the
appropriate npinfo struct in netpoll_send_skb, and drop it from the skbs
destructor or some such.
Neil

> ---
>  drivers/net/bonding/bond_main.c |  236 +++++++++++++++++++++------------------
>  include/linux/netpoll.h         |    2 +
>  net/core/netpoll.c              |   22 ++--
>  3 files changed, 140 insertions(+), 120 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0592e6d..2d6ec1b 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -907,6 +907,121 @@ static void bond_mc_list_flush(struct net_device *bond_dev,
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
> +	np = kzalloc(sizeof(*np), GFP_ATOMIC);
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
> +static void slave_netpoll_reclaim(struct rcu_head *rp)
> +{
> +	struct netpoll *np = container_of(rp, struct netpoll, rcu);
> +	__netpoll_cleanup(np);
> +	kfree(np);
> +}
> +static inline void slave_disable_netpoll(struct slave *slave)
> +{
> +	struct netpoll *np = slave->np;
> +
> +	if (!np)
> +		return;
> +
> +	slave->np = NULL;
> +	call_rcu_bh(&np->rcu, slave_netpoll_reclaim);
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
> @@ -1155,11 +1270,20 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
>  	}
>  
>  	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
> -		if (old_active)
> +		if (old_active) {
>  			bond_set_slave_inactive_flags(old_active);
> +			if (bond_netpoll_info(bond))
> +				slave_disable_netpoll(old_active);
> +		}
>  
>  		if (new_active) {
> +			struct netpoll_info *ni;
>  			bond_set_slave_active_flags(new_active);
> +			ni = bond_netpoll_info(bond);
> +			if (ni) {
> +				new_active->dev->npinfo = ni;
> +				slave_enable_netpoll(new_active);
> +			}
>  
>  			if (bond->params.fail_over_mac)
>  				bond_do_fail_over_mac(bond, new_active,
> @@ -1280,116 +1404,6 @@ static void bond_detach_slave(struct bonding *bond, struct slave *slave)
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
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index 79358bb..9412aa5 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -23,6 +23,7 @@ struct netpoll {
>  	u8 remote_mac[ETH_ALEN];
>  
>  	struct list_head rx; /* rx_np list element */
> +	struct rcu_head rcu;
>  };
>  
>  struct netpoll_info {
> @@ -38,6 +39,7 @@ struct netpoll_info {
>  	struct delayed_work tx_work;
>  
>  	struct netpoll *netpoll;
> +	struct rcu_head rcu;
>  };
>  
>  void netpoll_poll_dev(struct net_device *dev);
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 06be243..9870dac 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -901,6 +901,18 @@ static int __init netpoll_init(void)
>  }
>  core_initcall(netpoll_init);
>  
> +static void netpoll_reclaim(struct rcu_head *rp)
> +{
> +	struct netpoll_info *npinfo = container_of(rp, struct netpoll_info, rcu);
> +	skb_queue_purge(&npinfo->arp_tx);
> +	skb_queue_purge(&npinfo->txq);
> +	cancel_delayed_work_sync(&npinfo->tx_work);
> +
> +	/* clean after last, unfinished work */
> +	__skb_queue_purge(&npinfo->txq);
> +	kfree(npinfo);
> +}
> +
>  void __netpoll_cleanup(struct netpoll *np)
>  {
>  	struct netpoll_info *npinfo;
> @@ -928,15 +940,7 @@ void __netpoll_cleanup(struct netpoll *np)
>  		rcu_assign_pointer(np->dev->npinfo, NULL);
>  
>  		/* avoid racing with NAPI reading npinfo */
> -		synchronize_rcu_bh();
> -
> -		skb_queue_purge(&npinfo->arp_tx);
> -		skb_queue_purge(&npinfo->txq);
> -		cancel_delayed_work_sync(&npinfo->tx_work);
> -
> -		/* clean after last, unfinished work */
> -		__skb_queue_purge(&npinfo->txq);
> -		kfree(npinfo);
> +		call_rcu_bh(&npinfo->rcu, netpoll_reclaim); 
>  	}
>  }
>  EXPORT_SYMBOL_GPL(__netpoll_cleanup);
> 
