From: Neil Horman <nhorman@redhat.com>
Subject: Re: [v3 PATCH 1/2] bonding: sync netpoll code with bridge
Date: Wed, 8 Dec 2010 08:57:46 -0500
Message-ID: <20101208135746.GD11454@hmsreliant.think-freely.org>
References: <20101208075208.5792.45247.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101208075208.5792.45247.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2010 at 02:52:08AM -0500, Amerigo Wang wrote:
> From: Amerigo Wang <amwang@redhat.com>
> Date: Thu, 2 Dec 2010 21:31:19 +0800
> Subject: [v3 PATCH 1/2] bonding: sync netpoll code with bridge
> 
> V3: remove an useless #ifdef.
> 
> This patch unifies the netpoll code in bonding with netpoll code in bridge,
> thanks to Herbert that code is much cleaner now.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> 
> ---
> 
>  drivers/net/bonding/bond_main.c |  155 ++++++++++++++++++++++++--------------
>  drivers/net/bonding/bonding.h   |   20 +++++
>  2 files changed, 118 insertions(+), 57 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0273ad0..7fafe06 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -59,7 +59,6 @@
>  #include <linux/uaccess.h>
>  #include <linux/errno.h>
>  #include <linux/netdevice.h>
> -#include <linux/netpoll.h>
>  #include <linux/inetdevice.h>
>  #include <linux/igmp.h>
>  #include <linux/etherdevice.h>
> @@ -449,15 +448,11 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
>  	}
>  
>  	skb->priority = 1;
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	if (unlikely(bond->dev->priv_flags & IFF_IN_NETPOLL)) {
> -		struct netpoll *np = bond->dev->npinfo->netpoll;
> -		slave_dev->npinfo = bond->dev->npinfo;
> +	if (unlikely(netpoll_tx_running(slave_dev))) {
>  		slave_dev->priv_flags |= IFF_IN_NETPOLL;
> -		netpoll_send_skb_on_dev(np, skb, slave_dev);
> +		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
>  		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
>  	} else
> -#endif
>  		dev_queue_xmit(skb);
>  
>  	return 0;
> @@ -1310,63 +1305,113 @@ static void bond_detach_slave(struct bonding *bond, struct slave *slave)
>  }
>  
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> -/*
> - * You must hold read lock on bond->lock before calling this.
> - */
> -static bool slaves_support_netpoll(struct net_device *bond_dev)
> +static inline int slave_enable_netpoll(struct slave *slave)
>  {
> -	struct bonding *bond = netdev_priv(bond_dev);
> -	struct slave *slave;
> -	int i = 0;
> -	bool ret = true;
> +	struct netpoll *np;
> +	int err = 0;
>  
> -	bond_for_each_slave(bond, slave, i) {
> -		if ((slave->dev->priv_flags & IFF_DISABLE_NETPOLL) ||
> -		    !slave->dev->netdev_ops->ndo_poll_controller)
> -			ret = false;
> +	np = kmalloc(sizeof(*np), GFP_KERNEL);
> +	err = -ENOMEM;
> +	if (!np)
> +		goto out;
> +
> +	np->dev = slave->dev;
> +	err = __netpoll_setup(np);
Setting up our own netpoll instance on each slave worries me a bit.  The
implication here is that, by doing so, some frames will get entirely processed
by the slave.  Most notably arp frames.  That means anything that gets queued up
to the arp_tx queue in __netpoll_rx will get processed during that poll event,
and responded to with the mac of the slave device, rather than with the mac of
the bond device, which isn't always what you want.  I think if you go with this
route, you'll need to add code to netpoll_poll_dev, right before the call to
service_arp_queue, to check if IFF_SLAVE is set in priv_flags, and move the list
to the master device, or some such.

It also seems like you'll want to zero out the other fields in the netpoll
structure.  Leaving garbage in them will be bad.  Most notably here I'm looking
at the rx_hook field.  If its non-null we're going to add a bogus pointer to the
rx_np list and call off into space at some point.

> +	if (err) {
> +		kfree(np);
> +		goto out;
>  	}
> -	return i != 0 && ret;
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
>  }
>  
>  static void bond_poll_controller(struct net_device *bond_dev)
>  {
> -	struct bonding *bond = netdev_priv(bond_dev);
> +}
> +
> +static void __bond_netpoll_cleanup(struct bonding *bond)
> +{
>  	struct slave *slave;
>  	int i;
>  
> -	bond_for_each_slave(bond, slave, i) {
> -		if (slave->dev && IS_UP(slave->dev))
> -			netpoll_poll_dev(slave->dev);
> -	}
> +	bond_for_each_slave(bond, slave, i)
> +		if (slave->dev)
Why are you checking slave->dev here?  If the dev pointer has been set to NULL
here it would seem we're not holding on to dev long enough.  If we enabled
netpoll with a dev pointer and lost it somewhere along the way, we're going to
leak that struct netpoll memory that we allocated.

> +			slave_disable_netpoll(slave);
>  }
> -
>  static void bond_netpoll_cleanup(struct net_device *bond_dev)
>  {
>  	struct bonding *bond = netdev_priv(bond_dev);
> +
> +	read_lock(&bond->lock);
> +	__bond_netpoll_cleanup(bond);
> +	read_unlock(&bond->lock);
> +}
> +
> +static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
> +{
> +	struct bonding *bond = netdev_priv(dev);
>  	struct slave *slave;
> -	const struct net_device_ops *ops;
> -	int i;
> +	int i, err = 0;
>  
>  	read_lock(&bond->lock);
> -	bond_dev->npinfo = NULL;
>  	bond_for_each_slave(bond, slave, i) {
> -		if (slave->dev) {
> -			ops = slave->dev->netdev_ops;
> -			if (ops->ndo_netpoll_cleanup)
> -				ops->ndo_netpoll_cleanup(slave->dev);
> -			else
> -				slave->dev->npinfo = NULL;
> +		if (!slave->dev)
> +			continue;
> +		err = slave_enable_netpoll(slave);
> +		if (err) {
> +			__bond_netpoll_cleanup(bond);
> +			break;
>  		}
>  	}
>  	read_unlock(&bond->lock);
> +	return err;
>  }
>  
> -#else
> +static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> +{
> +	return bond->dev->npinfo;
> +}
>  
> +#else
> +static inline int slave_enable_netpoll(struct slave *slave)
> +{
> +	return 0;
> +}
> +static inline void slave_disable_netpoll(struct slave *slave)
> +{
> +}
>  static void bond_netpoll_cleanup(struct net_device *bond_dev)
>  {
>  }
> -
> +static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
> +{
> +	return 0;
> +}
> +static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
> +{
> +	return NULL;
> +}
>  #endif
>  
>  /*---------------------------------- IOCTL ----------------------------------*/
> @@ -1804,17 +1849,19 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  	bond_set_carrier(bond);
>  
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> -	if (slaves_support_netpoll(bond_dev)) {
> -		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
> -		if (bond_dev->npinfo)
> -			slave_dev->npinfo = bond_dev->npinfo;
> -	} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
> -		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
> -		pr_info("New slave device %s does not support netpoll\n",
> -			slave_dev->name);
> -		pr_info("Disabling netpoll support for %s\n", bond_dev->name);
> +	slave_dev->npinfo = bond_netpoll_info(bond);
> +	if (slave_dev->npinfo) {
> +		if (slave_enable_netpoll(new_slave)) {
> +			read_unlock(&bond->lock);
> +			pr_info("Error, %s: master_dev is using netpoll, "
> +				 "but new slave device does not support netpoll.\n",
> +				 bond_dev->name);
> +			res = -EBUSY;
> +			goto err_close;
> +		}
>  	}
>  #endif
> +
>  	read_unlock(&bond->lock);
>  
>  	res = bond_create_slave_symlinks(bond_dev, slave_dev);
> @@ -2016,17 +2063,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
>  
>  	netdev_set_master(slave_dev, NULL);
>  
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	read_lock_bh(&bond->lock);
> -
> -	if (slaves_support_netpoll(bond_dev))
> -		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
> -	read_unlock_bh(&bond->lock);
> -	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
> -		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
> -	else
> -		slave_dev->npinfo = NULL;
> -#endif
> +	slave_disable_netpoll(slave);
>  
>  	/* close slave before restoring its mac address */
>  	dev_close(slave_dev);
> @@ -2061,6 +2098,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
>  
>  	ret = bond_release(bond_dev, slave_dev);
>  	if ((ret == 0) && (bond->slave_cnt == 0)) {
> +		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
Why are you setting IFF_DISABLE_NETPOLL here?  That seems unnecessecary

>  		pr_info("%s: destroying bond %s.\n",
>  			bond_dev->name, bond_dev->name);
>  		unregister_netdevice(bond_dev);
> @@ -2138,6 +2176,8 @@ static int bond_release_all(struct net_device *bond_dev)
>  
>  		netdev_set_master(slave_dev, NULL);
>  
> +		slave_disable_netpoll(slave);
> +
>  		/* close slave before restoring its mac address */
>  		dev_close(slave_dev);
>  
> @@ -4670,6 +4710,7 @@ static const struct net_device_ops bond_netdev_ops = {
>  	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
>  	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_netpoll_setup	= bond_netpoll_setup,
>  	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
>  	.ndo_poll_controller	= bond_poll_controller,
>  #endif
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index ad3ae46..c4f6a94 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -21,6 +21,7 @@
>  #include <linux/kobject.h>
>  #include <linux/cpumask.h>
>  #include <linux/in6.h>
> +#include <linux/netpoll.h>
>  #include "bond_3ad.h"
>  #include "bond_alb.h"
>  
> @@ -203,6 +204,9 @@ struct slave {
>  	u16    queue_id;
>  	struct ad_slave_info ad_info; /* HUGE - better to dynamically alloc */
>  	struct tlb_slave_info tlb_info;
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	struct netpoll *np;
> +#endif
>  };
>  
>  /*
> @@ -324,6 +328,22 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
>  	return slave->dev->last_rx;
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static inline void bond_netpoll_send_skb(const struct slave *slave,
> +					 struct sk_buff *skb)
> +{
> +	struct netpoll *np = slave->np;
> +
> +	if (np)
> +		netpoll_send_skb(np, skb);
> +}
> +#else
> +static inline void bond_netpoll_send_skb(const struct slave *slave,
> +					 struct sk_buff *skb)
> +{
> +}
> +#endif
> +
>  static inline void bond_set_slave_inactive_flags(struct slave *slave)
>  {
>  	struct bonding *bond = netdev_priv(slave->dev->master);
> -- 
> 1.7.1
> 
